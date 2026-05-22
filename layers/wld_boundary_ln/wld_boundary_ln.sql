DROP FUNCTION IF EXISTS layer_wld_boundary_ln;

CREATE OR REPLACE FUNCTION layer_wld_boundary_ln(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, name text, adm0_left text, adm0_right text, adm0_a3_l text, adm0_a3_r text, labelrank int, scalerank int) AS $$
    SELECT geometry, name, adm0_left, adm0_right, adm0_a3_l, adm0_a3_r, labelrank, scalerank
    FROM (
        -- Zoom level < 6 (Simplify & Smooth)
        SELECT geometry, name, adm0_left, adm0_right,adm0_a3_l, adm0_a3_r, labelrank, scalerank
        FROM wld_boundary_ln_view_country
        WHERE geometry && bbox
            AND zoom_level < 6

        UNION ALL
        
        -- Zoom level >= 6 and < 10 (Simplify & Smooth)
        SELECT geometry, name, adm0_left, adm0_right,adm0_a3_l, adm0_a3_r, labelrank, scalerank
        FROM wld_boundary_ln_view_province
        WHERE geometry && bbox
            AND zoom_level >= 6
            AND zoom_level < 10
          
        UNION ALL
        
        -- Zoom level >= 10 and < 12 (Simplify)
        SELECT geometry, name, adm0_left, adm0_right,adm0_a3_l, adm0_a3_r, labelrank, scalerank
        FROM wld_boundary_ln_view_ward
        WHERE geometry && bbox
            AND zoom_level >= 10
            AND zoom_level < 12
          
        UNION ALL
        
        -- Zoom level >= 12 (No simplify)
        SELECT geometry, name, adm0_left, adm0_right,adm0_a3_l, adm0_a3_r, labelrank, scalerank
        FROM wld_boundary_ln_view_street
        WHERE geometry && bbox
            AND zoom_level >= 12
    ) AS area_zoom_levels
    WHERE ST_IsValid(geometry);
$$ LANGUAGE SQL IMMUTABLE;
