# AGENTS.md

## Project

Static GitHub Pages eBook library for Macs Learning Lab — no build step, no package manager, no `npm`. Files are served directly from the repo root.

## Dev server

```bash
python3 -m http.server 8080
# open http://localhost:8080
```

No other commands exist (no lint, test, typecheck, format).

## Architecture

| File | Role |
|---|---|
| `index.html` | Book list + admin panel — loads books from Supabase DB (falls back to `books.json`), 5-click top-right reveals admin login |
| `reader.html` | PDF reader with 3D page-flip — loads music from Supabase DB (falls back to `books.json`), **all logic is inline JS** |
| `books.json` | Legacy book catalog fallback — each entry: `id`, `title`, `author`, `cover`, `path`, `music`, `tags` |
| `js/supabase-config.js` | Supabase URL + anon key — **must be configured before use** |
| `supabase-setup.sql` | One-time SQL to create tables, storage bucket, RLS policies, and seed data |
| `books/` | Local PDF files (legacy, now stored in Supabase Storage) |
| `music/` | Local MP3 files (legacy, now stored in Supabase Storage) |

### Admin panel (index.html)

- Click top-right corner 5 times → opens Supabase Auth login modal
- After login: CRUD for books (add/edit/delete) with PDF & music file upload to Supabase Storage
- Files stored at `media/pdfs/<id>.pdf` and `media/music/<id>.mp3`
- Session stored in `sessionStorage` (lost on tab close)

### reader.html internals

- Combines **PDF.js** (page rendering) and **Three.js** (3D scene), both loaded from CDN.
- PDF pages → offscreen `<canvas>` → `THREE.CanvasTexture`.
- Pages displayed in **spreads**: spread 0 = cover (right only), then pairs `[2n, 2n+1]`.
- Three static meshes: `leftMesh`, `rightMesh` (always visible), `flipPivot` (visible only during animation).
- `texCache` (pageNum → texture) deduplicates renders; `inFlight` (pageNum → Promise) prevents concurrent re-renders.
- On load: renders pages 1–2 immediately, prefetches next 5 spreads, then loads remaining pages in background (`prefetchAll`).

### CDN versions (must stay in sync)

- PDF.js `3.11.174`
- Three.js `0.160.0`
- Supabase JS `v2`

When upgrading, update **all** `<script src>` URLs **and** any version-specific URLs (e.g. PDF.js worker URL) inside the HTML files.

## Supabase setup (first time)

1. Create a Supabase project at supabase.com
2. Run `supabase-setup.sql` in the Supabase SQL Editor
3. In Supabase Dashboard → Authentication → create an admin user (email/password)
4. Edit `js/supabase-config.js` — replace `YOUR_PROJECT_ID` and `YOUR_ANON_KEY` with your project's URL and anon key
5. Optionally upload existing PDFs/MP3s from `books/` and `music/` to Supabase Storage (bucket `media`, folders `pdfs/` and `music/`)

## Adding a book

### Via admin panel (recommended)
1. Click top-right corner 5 times → login
2. Fill in the form and upload PDF + optional MP3

### Manually (legacy)
1. Add PDF to `books/` — filename: **lowercase English letters + hyphens only**
2. Optionally add MP3 to `music/` — same naming rule
3. Add entry to `books.json`

## Deployment

Push to `main` — GitHub Pages serves from repo root. No CI, no build pipeline.

## Key constraints

- `reader.html` is self-contained; changes to reader logic must edit inline `<script>`.
- PDF file naming must be ASCII lowercase + hyphens; Korean filenames cause URL issues.
- Browser autoplay policy blocks background music — user must click the music button in reader.
- `js/supabase-config.js` contains credentials — it is client-side code and uses the **anon key** (safe to expose). Never put the service_role key here.
- Supabase RLS policies restrict write operations to authenticated users only.