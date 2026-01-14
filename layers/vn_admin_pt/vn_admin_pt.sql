CREATE OR REPLACE FUNCTION layer_vn_admin_pt(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, code text, name text, name_en text, level text, level_num int, label text, rank int) AS $$
    SELECT * FROM (
        -- Zoom level >= 4, Level 4
      SELECT geometry, code, name, name_en, level, level_num, label, rank
      FROM vn_admin_pt
      WHERE geometry && bbox
        AND zoom_level >= 4
        AND level_num = 4

      UNION ALL

      -- Zoom level >= 8, Level 6
      SELECT geometry, code, name, name_en, level, level_num, label, rank
      FROM vn_admin_pt
      WHERE geometry && bbox
        AND zoom_level >= 8
        AND level_num = 6

      UNION ALL

      -- Zoom level >= 13, Level 8
      SELECT geometry, code, name, name_en, level, level_num, label, rank
      FROM vn_admin_pt
      WHERE geometry && bbox
        AND zoom_level >= 12
        AND level_num = 8
    ) AS vn_admin_pt_all;
$$ LANGUAGE SQL IMMUTABLE;

