CREATE OR REPLACE FUNCTION layer_vn_admin_ln(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, code text, name text, name_en text, level text, level_num int) AS $$
    SELECT * FROM (
      SELECT ST_Simplify(geometry, ZRes(8)), code, name, name_en, level, level_num
      FROM vn_admin_ln
      WHERE geometry && bbox
        AND zoom_level >= 4
        AND zoom_level < 8
        AND level_num = 4

      UNION ALL

      SELECT geometry, code, name, name_en, level, level_num
      FROM vn_admin_ln
      WHERE geometry && bbox
        AND zoom_level >= 8
        AND level_num = 4
      
      UNION ALL

      SELECT geometry, code, name, name_en, level, level_num
      FROM vn_admin_ln
      WHERE geometry && bbox
        AND zoom_level >= 9
        AND level_num = 6
        
      UNION ALL

      SELECT geometry, code, name, name_en, level, level_num
      FROM vn_admin_ln
      WHERE geometry && bbox
        AND zoom_level >= 12
        AND level_num = 8
    ) AS vn_admin_ln_all;
$$ LANGUAGE SQL IMMUTABLE;