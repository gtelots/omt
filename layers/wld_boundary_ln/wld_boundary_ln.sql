CREATE OR REPLACE FUNCTION layer_wld_boundary_ln(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, name text, adm0_a3_l text, adm0_a3_r text, iso3 text, status text) AS $$
    SELECT geometry, name, adm0_a3_l, adm0_a3_r, iso3, status FROM (
        SELECT ST_Simplify(geometry, ZRes(8)) AS geometry, name, adm0_a3_l, adm0_a3_r, iso3, status
        FROM wld_boundary_ln
        WHERE geometry && bbox
        AND zoom_level < 8

        UNION ALL

        SELECT ST_Simplify(geometry, ZRes(12)) AS geometry, name, adm0_a3_l, adm0_a3_r, iso3, status
        FROM wld_boundary_ln
        WHERE geometry && bbox
        AND zoom_level >= 8 
        AND zoom_level < 12

        UNION ALL

        SELECT geometry, name, adm0_a3_l, adm0_a3_r, iso3, status
        FROM wld_boundary_ln
        WHERE geometry && bbox
        AND zoom_level >= 12
    ) AS area_zoom_levels;
$$ LANGUAGE SQL IMMUTABLE;