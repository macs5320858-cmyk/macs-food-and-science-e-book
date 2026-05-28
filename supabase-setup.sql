-- ============================================
-- Macs eBook — Supabase Setup Script
-- Run this in the Supabase SQL Editor
-- ============================================

-- 1. Create categories table (supports unlimited nesting via parent_id)
CREATE TABLE IF NOT EXISTS categories (
  id         TEXT PRIMARY KEY,
  name       TEXT NOT NULL,
  parent_id  TEXT REFERENCES categories(id) ON DELETE CASCADE,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Create books table (with category_id)
CREATE TABLE IF NOT EXISTS books (
  id          TEXT PRIMARY KEY,
  title       TEXT NOT NULL,
  author      TEXT NOT NULL DEFAULT 'Macs Learning Lab',
  cover       TEXT NOT NULL DEFAULT '',
  path        TEXT NOT NULL,
  music       TEXT NOT NULL DEFAULT '',
  tags        TEXT[] NOT NULL DEFAULT '{}',
  category_id TEXT REFERENCES categories(id) ON DELETE SET NULL,
  sort_order  INT NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Enable RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE books ENABLE ROW LEVEL SECURITY;

-- 4. Public can read
CREATE POLICY "Categories are publicly readable"
  ON categories FOR SELECT
  USING (true);

CREATE POLICY "Books are publicly readable"
  ON books FOR SELECT
  USING (true);

-- 5. Only authenticated admin can modify categories
CREATE POLICY "Admin can insert categories"
  ON categories FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admin can update categories"
  ON categories FOR UPDATE
  USING (auth.role() = 'authenticated');

CREATE POLICY "Admin can delete categories"
  ON categories FOR DELETE
  USING (auth.role() = 'authenticated');

-- 6. Only authenticated admin can modify books
CREATE POLICY "Admin can insert books"
  ON books FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admin can update books"
  ON books FOR UPDATE
  USING (auth.role() = 'authenticated');

CREATE POLICY "Admin can delete books"
  ON books FOR DELETE
  USING (auth.role() = 'authenticated');

-- 7. Create storage bucket for PDFs and MP3s
INSERT INTO storage.buckets (id, name, public)
VALUES ('media', 'media', true)
ON CONFLICT (id) DO NOTHING;

-- 8. Storage policies — public read, admin write
CREATE POLICY "Public can view media"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'media');

CREATE POLICY "Admin can upload media"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'media' AND auth.role() = 'authenticated');

CREATE POLICY "Admin can update media"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'media' AND auth.role() = 'authenticated');

CREATE POLICY "Admin can delete media"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'media' AND auth.role() = 'authenticated');

-- 9. Seed categories
INSERT INTO categories (id, name, parent_id, sort_order) VALUES
  ('science', '과학', NULL, 1),
  ('earth-science', '지구과학', 'science', 1),
  ('biology', '생물', 'science', 2)
ON CONFLICT (id) DO NOTHING;

-- 10. Seed books with category_id
INSERT INTO books (id, title, author, path, music, tags, category_id, sort_order) VALUES
  ('earth-layer', '지구층', 'Macs Learning Lab', 'books/earth-layer.pdf', 'music/earth-layer.mp3', ARRAY['과학','지구과학'], 'earth-science', 1),
  ('blood-cell',  '혈액 세포', 'Macs Learning Lab', 'books/blood-cell.pdf',  'music/blood-cell.mp3',  ARRAY['과학','생물'], 'biology', 2),
  ('skin-layer',  '피부층',   'Macs Learning Lab', 'books/skin-layer.pdf',  'music/skin-layer.mp3',  ARRAY['과학','생물'], 'biology', 3),
  ('animal-cell', '동물 세포', 'Macs Learning Lab', 'books/animal-cell.pdf', 'music/animal-cell.mp3', ARRAY['과학','생물'], 'biology', 4),
  ('fossils',     '화석',     'Macs Learning Lab', 'books/fossils.pdf',     'music/fossils.mp3',     ARRAY['과학','지구과학'], 'earth-science', 5),
  ('plant-cell',  '식물 세포', 'Macs Learning Lab', 'books/plant-cell.pdf',  'music/plant-cell.mp3',  ARRAY['과학','생물'], 'biology', 6)
ON CONFLICT (id) DO NOTHING;