# 백틱 → HTML 태그 변환 가이드

> 마크다운 파일의 백틱(`)을 `<span class="text-bold">`로 치환하여 새 파일로 저장하는 방법

## 📝 용도

포트폴리오 작업 시 마크다운 파일의 백틱(`)을 HTML의 볼드 태그로 변환할 때 사용합니다.

**변환 규칙:**
- `` `텍스트` `` → `<span class="text-bold">텍스트</span>`

## 🚀 기본 사용법

### 1. 여러 파일 한 번에 처리 (추천!)

```bash
for file in projects/dosurf.md projects/frameet.md projects/kidk.md projects/pilling.md; do
  basename=$(basename "$file" .md)
  sed 's/`\([^`]*\)`/<span class="text-bold">\1<\/span>/g' "$file" > "projects/${basename}_html.md"
done
```

**결과:**
- `dosurf.md` → `dosurf_html.md`
- `frameet.md` → `frameet_html.md`
- `kidk.md` → `kidk_html.md`
- `pilling.md` → `pilling_html.md`

### 2. 특정 파일 하나만 처리

```bash
sed 's/`\([^`]*\)`/<span class="text-bold">\1<\/span>/g' projects/dosurf.md > projects/dosurf_html.md
```

### 3. 다른 폴더에 저장

```bash
# html 폴더 생성
mkdir -p projects/html

# html 폴더에 저장
for file in projects/*.md; do
  basename=$(basename "$file")
  sed 's/`\([^`]*\)`/<span class="text-bold">\1<\/span>/g' "$file" > "projects/html/${basename}"
done
```

## 📋 변환 예시

### Before (마크다운)
```markdown
- Problem: `초보 서퍼`는 복잡한 차트 때문에 결정하기 어렵다.
- Solution: 해양 차트를 `직관적인 UI`로 보여준다.
- 역할: `1인 iOS 개발 및 백엔드 구축`
```

### After (HTML)
```markdown
- Problem: <span class="text-bold">초보 서퍼</span>는 복잡한 차트 때문에 결정하기 어렵다.
- Solution: 해양 차트를 <span class="text-bold">직관적인 UI</span>로 보여준다.
- 역할: <span class="text-bold">1인 iOS 개발 및 백엔드 구축</span>
```

## 🔍 결과 확인

```bash
# 생성된 파일 목록 확인
ls -lh projects/*_html.md

# 변환이 제대로 되었는지 확인
head -n 30 projects/dosurf_html.md | grep "text-bold"
```

## ⚙️ 응용: 다른 태그로 변환

### 이탤릭체로 변환
```bash
sed 's/`\([^`]*\)`/<em>\1<\/em>/g' input.md > output.md
```

### 강조 태그로 변환
```bash
sed 's/`\([^`]*\)`/<strong>\1<\/strong>/g' input.md > output.md
```

### 커스텀 클래스 사용
```bash
sed 's/`\([^`]*\)`/<span class="highlight">\1<\/span>/g' input.md > output.md
```

## ⚠️ 주의사항

1. **원본 파일 보존**: 항상 새 파일로 저장하여 원본 유지
2. **코드 블록**: 이 방법은 코드 블록(```)도 치환할 수 있으니 주의
3. **백업**: 중요한 파일은 변환 전 백업 권장
4. **확인**: 변환 후 결과 파일을 꼭 확인하기

## 📝 실전 워크플로우

```bash
# 1. 변환 실행
for file in projects/*.md; do
  basename=$(basename "$file" .md)
  sed 's/`\([^`]*\)`/<span class="text-bold">\1<\/span>/g' "$file" > "projects/${basename}_html.md"
done

# 2. 결과 확인
ls -lh projects/*_html.md

# 3. 내용 검증
head -n 50 projects/dosurf_html.md

# 4. 만족하면 원본과 교체 (선택)
# mv projects/dosurf_html.md projects/dosurf.md
```

## 💡 팁

- **일괄 처리**: 여러 파일을 한 번에 처리하면 시간 절약
- **파일명 규칙**: `_html.md` 접미사로 구분하면 관리 편함
- **버전 관리**: Git에 커밋하기 전 결과 확인 필수
- **선택적 적용**: 필요한 파일만 선택해서 변환 가능

---

**작성일**: 2026-02-09
**마지막 수정**: 2026-02-09
**용도**: Portfolio Piri 프로젝트 백틱 → HTML 변환
