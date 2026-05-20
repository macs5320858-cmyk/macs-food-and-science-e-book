# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Static GitHub Pages eBook library for Macs Learning Lab. No build step — files are served directly. Deployed at `https://[account].github.io/macs-e-book/`.

## Development

Open files directly in a browser, or run a local static server:

```bash
python3 -m http.server 8080
# then open http://localhost:8080
```

No package manager, no build process, no dependencies to install.

## Architecture

Two pages, one data file:

- **`index.html`** — Book list page. Fetches `books.json`, renders clickable links that open `reader.html?book=<path>`.
- **`reader.html`** — PDF reader with 3D page-flip animation. Self-contained; all logic is inline JS.
- **`books.json`** — Book catalog. Each entry has `id`, `title`, `author`, `cover`, `path` (PDF under `books/`), and `music` (MP3 under `music/`).

### Reader internals (`reader.html`)

The reader combines **PDF.js** (page rendering) and **Three.js** (3D scene) loaded from CDN:
- PDF pages are rendered off-screen to `<canvas>` elements and converted to `THREE.CanvasTexture`.
- Pages are displayed in **spreads**: spread 0 is the cover (right page only), then pairs `[2n, 2n+1]`.
- Three static meshes: `leftMesh`, `rightMesh` (always visible), and a `flipPivot` group (visible only during animation).
- `texCache` (pageNum → texture) deduplicates renders; `inFlight` (pageNum → Promise) prevents concurrent re-renders of the same page.
- On load: renders pages 1–2 immediately, prefetches the next 5 spreads, then loads all remaining pages sequentially in the background (`prefetchAll`).

### Adding a book

1. Add the PDF to `books/`.
2. Add an MP3 to `music/` (optional).
3. Add an entry to `books.json`.

### External CDN dependencies

- PDF.js `3.11.174` — `https://cdn.jsdelivr.net/npm/pdfjs-dist@3.11.174/`
- Three.js `0.160.0` — `https://cdn.jsdelivr.net/npm/three@0.160.0/`

When upgrading these versions, update both the script `src` URLs and the worker URL inside `reader.html`.

## Deployment

Push to `main`. GitHub Pages serves from the repo root. CORS is not an issue as long as PDFs stay in the same repo.