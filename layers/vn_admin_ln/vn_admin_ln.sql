DROP FUNCTION IF EXISTS layer_vn_admin_ln;

CREATE OR REPLACE FUNCTION layer_vn_admin_ln(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, code text, name text, name_en text, level text, level_num int, adminleft text, adminright text) AS $$
    SELECT * FROM (
        -- Zoom level < 4, Level 4 (Simplify)
        SELECT ST_MakeValid(ST_ChaikinSmoothing(ST_Simplify(geometry, ZRes(4)), 2)) AS geometry, 
               code, name, name_en, level, level_num, adminleft, adminright
        FROM vn_admin_ln
        WHERE geometry && bbox
          AND zoom_level < 4
          AND level_num = 4
          
        UNION ALL
        
        -- Zoom level >= 4 and level < 6, Level 4 (Simplify)
        SELECT ST_MakeValid(ST_ChaikinSmoothing(ST_Simplify(geometry, ZRes(6)), 2)) AS geometry, 
               code, name, name_en, level, level_num, adminleft, adminright
        FROM vn_admin_ln
        WHERE geometry && bbox
          AND zoom_level >= 4
          AND zoom_level < 6
          AND level_num = 4
          
        UNION ALL
        
        -- Zoom level >= 6 and level < 8, Level 4 (Simplify)
        SELECT ST_MakeValid(ST_ChaikinSmoothing(ST_Simplify(geometry, ZRes(8)), 2)) AS geometry, 
               code, name, name_en, level, level_num, adminleft, adminright
        FROM vn_admin_ln
        WHERE geometry && bbox
          AND zoom_level >= 6
          AND zoom_level < 8
          AND level_num = 4
          
        UNION ALL
        
        -- Zoom level >= 8, Level 4, 6, 8 (No simplify)
        SELECT ST_MakeValid(geometry) AS geometry, 
               code, name, name_en, level, level_num, adminleft, adminright
        FROM vn_admin_ln
        WHERE geometry && bbox
          AND zoom_level >= 8
          AND level_num IN (4, 6, 8)
    ) AS vn_admin_ln_all
    WHERE ST_IsValid(geometry);
$$ LANGUAGE SQL IMMUTABLE;
