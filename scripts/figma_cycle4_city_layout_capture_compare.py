#!/usr/bin/env python3
import csv
import glob
import os
import re
import shutil
import subprocess
import sys
import time
from dataclasses import dataclass
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
FIGMA_ROOT = Path("/Users/piri/Desktop/kidk_figma")
DEVICE_ID = "2CCF9C01-2F2D-4D71-9D09-8841896C057E"  # iPhone 16 Pro
BUNDLE_ID = "com.kidk.KIDK"


@dataclass
class ScreenMap:
    slug: str
    figma_file: str
    scenario: str
    wait_sec: float


SCREENS = [
    ScreenMap("05-city-base", "5. 기본 맵 화면.png", "city-base", 2.2),
    ScreenMap("06-city-selection", "6. 금액 가이드가 주어졌지만 직접 설정할 수 있는 화면.png", "mission-selection", 2.3),
    ScreenMap("08-city-building-detail", "8. 건물1 미션 화면.png", "city-building-detail", 2.2),
]


def run(cmd, check=True, capture=False):
    if capture:
        return subprocess.run(cmd, check=check, text=True, capture_output=True)
    return subprocess.run(cmd, check=check)


def find_app_path() -> Path:
    candidates = glob.glob(str(Path.home() / "Library/Developer/Xcode/DerivedData/KIDK-*/Build/Products/Debug-iphonesimulator/KIDK.app"))
    if not candidates:
        raise FileNotFoundError("KIDK.app not found in DerivedData. Build first.")
    candidates.sort(key=lambda p: os.path.getmtime(p), reverse=True)
    return Path(candidates[0])


def ffprobe_size(image_path: Path):
    result = run([
        "ffprobe", "-v", "error", "-select_streams", "v:0",
        "-show_entries", "stream=width,height",
        "-of", "csv=s=x:p=0", str(image_path)
    ], capture=True)
    m = re.search(r"(\d+)x(\d+)", result.stdout.strip())
    if not m:
        raise RuntimeError(f"failed to parse image size: {image_path}")
    return int(m.group(1)), int(m.group(2))


def parse_ssim(stderr_text: str) -> float:
    m = re.search(r"All:([0-9.]+)", stderr_text)
    return float(m.group(1)) if m else 0.0


def parse_psnr(stderr_text: str) -> float:
    m = re.search(r"average:([0-9.]+)", stderr_text)
    return float(m.group(1)) if m else 0.0


def main():
    if len(sys.argv) < 2:
        print("Usage: figma_cycle4_city_layout_capture_compare.py <iter-name>")
        sys.exit(1)

    iteration = sys.argv[1]
    base_dir = REPO_ROOT / "docs/figma-compare/cycle4-city-layout" / iteration
    figma_raw_dir = base_dir / "figma-raw"
    figma_norm_dir = base_dir / "figma-normalized"
    sim_dir = base_dir / "simulator"
    side_dir = base_dir / "side-by-side"
    diff_dir = base_dir / "diff"
    base_dir.mkdir(parents=True, exist_ok=True)
    for d in [figma_raw_dir, figma_norm_dir, sim_dir, side_dir, diff_dir]:
        d.mkdir(parents=True, exist_ok=True)

    app_path = find_app_path()
    print(f"Using app: {app_path}")

    run(["xcrun", "simctl", "bootstatus", DEVICE_ID, "-b"])
    run(["xcrun", "simctl", "install", DEVICE_ID, str(app_path)])

    run([
        "xcrun", "simctl", "status_bar", DEVICE_ID, "override",
        "--time", "9:41",
        "--dataNetwork", "wifi",
        "--wifiBars", "3",
        "--cellularBars", "4",
        "--batteryState", "charged",
        "--batteryLevel", "100",
    ])

    for screen in SCREENS:
        figma_src = FIGMA_ROOT / screen.figma_file
        if not figma_src.exists():
            raise FileNotFoundError(f"Missing figma file: {figma_src}")

        shutil.copy2(figma_src, figma_raw_dir / f"{screen.slug}.png")

        run(["xcrun", "simctl", "terminate", DEVICE_ID, BUNDLE_ID], check=False)
        run(["xcrun", "simctl", "launch", DEVICE_ID, BUNDLE_ID, "--figma-snapshot", screen.scenario])
        time.sleep(screen.wait_sec)
        run(["xcrun", "simctl", "io", DEVICE_ID, "screenshot", str(sim_dir / f"{screen.slug}.png")])

    first_sim = sim_dir / f"{SCREENS[0].slug}.png"
    width, height = ffprobe_size(first_sim)
    print(f"Target size: {width}x{height}")

    metrics = []

    for screen in SCREENS:
        figma_raw = figma_raw_dir / f"{screen.slug}.png"
        figma_norm = figma_norm_dir / f"{screen.slug}.png"
        sim = sim_dir / f"{screen.slug}.png"
        side = side_dir / f"{screen.slug}.png"
        diff = diff_dir / f"{screen.slug}.png"

        run([
            "ffmpeg", "-y", "-i", str(figma_raw),
            "-vf", f"scale={width}:{height}:force_original_aspect_ratio=decrease,pad={width}:{height}:(ow-iw)/2:0:color=0x111111",
            "-frames:v", "1", str(figma_norm)
        ])

        run([
            "ffmpeg", "-y", "-i", str(figma_norm), "-i", str(sim),
            "-filter_complex", "hstack=inputs=2",
            "-frames:v", "1", str(side)
        ])

        run([
            "ffmpeg", "-y", "-i", str(figma_norm), "-i", str(sim),
            "-filter_complex", "[0:v][1:v]blend=all_mode=difference,eq=contrast=2.8:brightness=0.02:saturation=1.2",
            "-frames:v", "1", str(diff)
        ])

        ssim_run = run([
            "ffmpeg", "-i", str(figma_norm), "-i", str(sim),
            "-lavfi", "ssim", "-f", "null", "-"
        ], capture=True)

        psnr_run = run([
            "ffmpeg", "-i", str(figma_norm), "-i", str(sim),
            "-lavfi", "psnr", "-f", "null", "-"
        ], capture=True)

        ssim = parse_ssim(ssim_run.stderr)
        psnr = parse_psnr(psnr_run.stderr)

        metrics.append({
            "screen": screen.slug,
            "figma": screen.figma_file,
            "scenario": screen.scenario,
            "ssim": f"{ssim:.4f}",
            "psnr": f"{psnr:.2f}",
        })

    csv_path = base_dir / "metrics.csv"
    with csv_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["screen", "figma", "scenario", "ssim", "psnr"])
        writer.writeheader()
        writer.writerows(metrics)

    md_path = base_dir / "metrics.md"
    with md_path.open("w", encoding="utf-8") as f:
        f.write("# Cycle4 City Layout {} Metrics\n\n".format(iteration))
        f.write("| screen | ssim | psnr |\n")
        f.write("|---|---:|---:|\n")
        for row in metrics:
            f.write(f"| {row['screen']} | {row['ssim']} | {row['psnr']} |\n")

    run(["xcrun", "simctl", "terminate", DEVICE_ID, BUNDLE_ID], check=False)

    print(f"Done: {base_dir}")


if __name__ == "__main__":
    main()
