DROP FUNCTION IF EXISTS layer_vn_admin_ln;

CREATE OR REPLACE FUNCTION layer_vn_admin_ln(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, code text, name text, name_en text, level text, level_num int, adminleft text, adminright text, is_overlap boolean) AS $$
    SELECT geometry, code, name, name_en, level, level_num, adminleft, adminright, is_overlap
    FROM (
        -- Zoom level < 6, Level 4 (Simplify)
        SELECT geometry, code, name, name_en, level, level_num, adminleft, adminright, is_overlap
        FROM vn_admin_ln_view_country
        WHERE geometry && bbox
            AND zoom_level < 6
            AND level_num = 4
          
        UNION ALL
        
        -- Zoom level >= 6 and < 10, Level 4 (Simplify)
        SELECT geometry, code, name, name_en, level, level_num, adminleft, adminright, is_overlap
        FROM vn_admin_ln_view_province
        WHERE geometry && bbox
            AND zoom_level >= 6
            AND zoom_level < 10
            AND level_num = 4
          
        UNION ALL
        
        -- Zoom level >= 10 and < 12, Level 4 (Simplify)
        SELECT geometry, code, name, name_en, level, level_num, adminleft, adminright, is_overlap
        FROM vn_admin_ln_view_ward
        WHERE geometry && bbox
            AND zoom_level >= 10
            AND zoom_level < 12
            AND level_num IN (4, 8)
          
        UNION ALL
        
        -- Zoom level >= 12, Level 4, 8 (No simplify)
        SELECT geometry, code, name, name_en, level, level_num, adminleft, adminright, is_overlap
        FROM vn_admin_ln_view_street
        WHERE geometry && bbox
            AND zoom_level >= 12
            AND level_num IN (4, 8)
    ) AS vn_admin_ln_all
    WHERE ST_IsValid(geometry);
$$ LANGUAGE SQL IMMUTABLE;
