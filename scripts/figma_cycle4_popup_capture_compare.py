#!/usr/bin/env python3
import csv
import glob
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]
FIGMA_ROOT = Path("/Users/piri/Desktop/kidk_figma")
DEVICE_ID = "2CCF9C01-2F2D-4D71-9D09-8841896C057E"  # iPhone 16 Pro
BUNDLE_ID = "com.kidk.KIDK"
SCREEN_SLUG = "10-mission-completed"
FIGMA_FILE = "10. 미션 진행 완료 화면.png"
SCENARIO = "mission-completed"
WAIT_SEC = 4.2


def run(cmd, check=True, capture=False):
    if capture:
        return subprocess.run(cmd, check=check, text=True, capture_output=True)
    return subprocess.run(cmd, check=check)


def find_app_path() -> Path:
    import plistlib

    candidates = glob.glob(str(Path.home() / "Library/Developer/Xcode/DerivedData/KIDK-*/Build/Products/Debug-iphonesimulator/KIDK.app"))
    if not candidates:
        raise FileNotFoundError("KIDK.app not found in DerivedData. Build first.")

    candidates.sort(key=lambda p: os.path.getmtime(p), reverse=True)

    for candidate in candidates:
        info_plist = Path(candidate) / "Info.plist"
        if not info_plist.exists():
            continue
        try:
            with info_plist.open("rb") as f:
                info = plistlib.load(f)
            if info.get("CFBundleIdentifier"):
                return Path(candidate)
        except Exception:
            continue

    raise FileNotFoundError("No valid KIDK.app with CFBundleIdentifier found. Build first.")


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
        print("Usage: figma_cycle4_popup_capture_compare.py <iter-name>")
        sys.exit(1)

    iteration = sys.argv[1]
    base_dir = REPO_ROOT / "docs/figma-compare/cycle4-popup" / iteration
    figma_raw_dir = base_dir / "figma-raw"
    figma_norm_dir = base_dir / "figma-normalized"
    sim_dir = base_dir / "simulator"
    side_dir = base_dir / "side-by-side"
    diff_dir = base_dir / "diff"
    for d in [figma_raw_dir, figma_norm_dir, sim_dir, side_dir, diff_dir]:
        d.mkdir(parents=True, exist_ok=True)

    app_path = find_app_path()
    print(f"Using app: {app_path}")

    figma_src = FIGMA_ROOT / FIGMA_FILE
    if not figma_src.exists():
        raise FileNotFoundError(f"Missing figma file: {figma_src}")

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

    shutil.copy2(figma_src, figma_raw_dir / f"{SCREEN_SLUG}.png")

    run(["xcrun", "simctl", "terminate", DEVICE_ID, BUNDLE_ID], check=False)
    run(["xcrun", "simctl", "launch", DEVICE_ID, BUNDLE_ID, "--figma-snapshot", SCENARIO])
    time.sleep(WAIT_SEC)
    run(["xcrun", "simctl", "io", DEVICE_ID, "screenshot", str(sim_dir / f"{SCREEN_SLUG}.png")])

    width, height = ffprobe_size(sim_dir / f"{SCREEN_SLUG}.png")
    figma_raw = figma_raw_dir / f"{SCREEN_SLUG}.png"
    figma_norm = figma_norm_dir / f"{SCREEN_SLUG}.png"
    sim = sim_dir / f"{SCREEN_SLUG}.png"
    side = side_dir / f"{SCREEN_SLUG}.png"
    diff = diff_dir / f"{SCREEN_SLUG}.png"

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

    csv_path = base_dir / "metrics.csv"
    with csv_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["screen", "figma", "scenario", "ssim", "psnr"])
        writer.writeheader()
        writer.writerow({
            "screen": SCREEN_SLUG,
            "figma": FIGMA_FILE,
            "scenario": SCENARIO,
            "ssim": f"{ssim:.4f}",
            "psnr": f"{psnr:.2f}",
        })

    md_path = base_dir / "metrics.md"
    with md_path.open("w", encoding="utf-8") as f:
        f.write(f"# Cycle4 Popup {iteration} Metrics\n\n")
        f.write("| screen | ssim | psnr |\n")
        f.write("|---|---:|---:|\n")
        f.write(f"| {SCREEN_SLUG} | {ssim:.4f} | {psnr:.2f} |\n")

    run(["xcrun", "simctl", "terminate", DEVICE_ID, BUNDLE_ID], check=False)

    print(f"Done: {base_dir}")


if __name__ == "__main__":
    main()
