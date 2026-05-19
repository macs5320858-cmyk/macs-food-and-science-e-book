 # 📚 eBook Library — GitHub Pages 배포 가이드

## 파일 구조

```
your-repo/
├── index.html        ← 도서 목록 페이지
├── reader.html       ← epub 리더 페이지
├── books.json        ← 책 목록 설정 파일
└── books/            ← epub 파일 보관 폴더
    ├── book1.epub
    ├── book2.epub
    └── covers/       ← (선택) 표지 이미지
        ├── book1.jpg
        └── book2.jpg
```

---

## 1. GitHub 저장소 설정

1. GitHub에서 새 저장소 생성 (예: `my-ebook-library`)
2. 위 파일 구조대로 파일 업로드
3. `books/` 폴더에 epub 파일 업로드

---

## 2. books.json 수정

책을 추가하거나 수정할 때는 `books.json`을 편집합니다.

```json
[
  {
    "id": "book1",
    "title": "책 제목",
    "author": "저자 이름",
    "description": "책 소개 한 줄",
    "cover": "books/covers/book1.jpg",
    "path": "books/book1.epub",
    "tags": ["소설", "판타지"]
  }
]
```

| 필드 | 설명 | 필수 |
|------|------|------|
| `id` | 고유 식별자 | ✅ |
| `title` | 책 제목 | ✅ |
| `author` | 저자 | - |
| `description` | 소개 문구 | - |
| `cover` | 표지 이미지 경로 (없으면 자동 색상) | - |
| `path` | epub 파일 경로 | ✅ |
| `tags` | 태그 배열 | - |

---

## 3. GitHub Pages 활성화

1. 저장소 → **Settings** → **Pages**
2. Source: **Deploy from a branch**
3. Branch: `main` / `(root)` 선택 → **Save**
4. 몇 분 후 `https://[계정명].github.io/[저장소명]/` 접속 확인

---

## 4. 아임웹 iframe 삽입

GitHub Pages 배포 후, 아임웹 코드 위젯에 아래처럼 삽입:

```html
<iframe 
  src="https://[계정명].github.io/[저장소명]/" 
  width="100%" 
  height="700px" 
  style="border:none;">
</iframe>
```

특정 책 바로 열기:
```html
<iframe 
  src="https://[계정명].github.io/[저장소명]/reader.html?book=books/book1.epub" 
  width="100%" 
  height="700px" 
  style="border:none;">
</iframe>
```

---

## 리더 기능

| 기능 | 설명 |
|------|------|
| ☰ 목차 | 챕터 목록 표시 및 이동 |
| A- / A+ | 글자 크기 조절 (70% ~ 160%) |
| 🌙 / ☀️ | 다크 / 라이트 모드 전환 |
| ← → 버튼 | 페이지 이동 |
| 키보드 ←→ | 방향키로 페이지 이동 |
| 진행률 바 | 클릭으로 원하는 위치로 이동 |
| 읽던 위치 저장 | 브라우저 LocalStorage에 자동 저장 |

---

## 주의사항

- epub 파일이 **같은 도메인**(GitHub Pages)에 있어야 CORS 없이 동작합니다.
- 외부 URL의 epub은 해당 서버가 CORS를 허용해야 합니다.
- epub 파일 크기가 크면 로딩이 느릴 수 있습니다.
