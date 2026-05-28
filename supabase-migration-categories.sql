-- ============================================
-- Migration: Add categories table + category_id to books
-- Run this in the Supabase SQL Editor (for existing DBs)
-- ============================================

-- 1. Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id         TEXT PRIMARY KEY,
  name       TEXT NOT NULL,
  parent_id  TEXT REFERENCES categories(id) ON DELETE CASCADE,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Enable RLS on categories
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- 3. Category policies
CREATE POLICY "Categories are publicly readable"
  ON categories FOR SELECT
  USING (true);

CREATE POLICY "Admin can insert categories"
  ON categories FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Admin can update categories"
  ON categories FOR UPDATE
  USING (auth.role() = 'authenticated');

CREATE POLICY "Admin can delete categories"
  ON categories FOR DELETE
  USING (auth.role() = 'authenticated');

-- 4. Add category_id column to books (nullable, SET NULL on delete)
ALTER TABLE books ADD COLUMN IF NOT EXISTS category_id TEXT REFERENCES categories(id) ON DELETE SET NULL;

-- 5. Seed categories
INSERT INTO categories (id, name, parent_id, sort_order) VALUES
  ('science', '과학', NULL, 1),
  ('earth-science', '지구과학', 'science', 1),
  ('biology', '생물', 'science', 2)
ON CONFLICT (id) DO NOTHING;

-- 6. Assign existing books to categories
UPDATE books SET category_id = 'earth-science' WHERE id IN ('earth-layer', 'fossils');
UPDATE books SET category_id = 'biology' WHERE id IN ('blood-cell', 'skin-layer', 'animal-cell', 'plant-cell');