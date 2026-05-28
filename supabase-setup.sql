-- ============================================
-- Macs eBook — Supabase Setup Script
-- Run this in the Supabase SQL Editor
-- ============================================

-- 1. Create books table
CREATE TABLE IF NOT EXISTS books (
  id       TEXT PRIMARY KEY,
  title    TEXT NOT NULL,
  author   TEXT NOT NULL DEFAULT 'Macs Learning Lab',
  cover    TEXT NOT NULL DEFAULT '',
  path     TEXT NOT NULL,
  music    TEXT NOT NULL DEFAULT '',
  tags     TEXT[] NOT NULL DEFAULT '{}',
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Enable RLS
ALTER TABLE books ENABLE ROW LEVEL SECURITY;

-- 3. Public can read books
CREATE POLICY "Books are publicly readable"
  ON books FOR SELECT
  USING (true);

-- 4. Only authenticated admin can modify books
CREATE POLICY "Admin can insert books"
  ON books FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admin can update books"
  ON books FOR UPDATE
  USING (auth.role() = 'authenticated');

CREATE POLICY "Admin can delete books"
  ON books FOR DELETE
  USING (auth.role() = 'authenticated');

-- 5. Create storage bucket for PDFs and MP3s
INSERT INTO storage.buckets (id, name, public)
VALUES ('media', 'media', true)
ON CONFLICT (id) DO NOTHING;

-- 6. Storage policies — public read, admin write
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

-- 7. Seed existing books data (migrate from books.json)
INSERT INTO books (id, title, author, path, music, tags, sort_order) VALUES
  ('earth-layer', '지구층', 'Macs Learning Lab', 'books/earth-layer.pdf', 'music/earth-layer.mp3', ARRAY['과학','지구과학'], 1),
  ('blood-cell',  '혈액 세포', 'Macs Learning Lab', 'books/blood-cell.pdf',  'music/blood-cell.mp3',  ARRAY['과학','생물'], 2),
  ('skin-layer',  '피부층',   'Macs Learning Lab', 'books/skin-layer.pdf',  'music/skin-layer.mp3',  ARRAY['과학','생물'], 3),
  ('animal-cell', '동물 세포', 'Macs Learning Lab', 'books/animal-cell.pdf', 'music/animal-cell.mp3', ARRAY['과학','생물'], 4),
  ('fossils',     '화석',     'Macs Learning Lab', 'books/fossils.pdf',     'music/fossils.mp3',     ARRAY['과학','지구과학'], 5),
  ('plant-cell',  '식물 세포', 'Macs Learning Lab', 'books/plant-cell.pdf',  'music/plant-cell.mp3',  ARRAY['과학','생물'], 6)
ON CONFLICT (id) DO NOTHING;