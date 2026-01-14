DROP FUNCTION IF EXISTS layer_wld_boundary_ln;

CREATE OR REPLACE FUNCTION layer_wld_boundary_ln(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, name text, adm0_left text, adm0_right text, adm0_a3_l text, adm0_a3_r text, labelrank int, scalerank int) AS $$
    SELECT geometry, name, adm0_left, adm0_right, adm0_a3_l, adm0_a3_r, labelrank, scalerank
    FROM (
        -- Zoom level < 4
        SELECT 
            ST_MakeValid(ST_ChaikinSmoothing(ST_Simplify(geometry, ZRes(4)), 2)) AS geometry, 
            name, 
            adm0_left, 
            adm0_right,
            adm0_a3_l, 
            adm0_a3_r, 
            labelrank, 
            scalerank
        FROM wld_boundary_ln
        WHERE geometry && bbox
            AND zoom_level < 4

        UNION ALL

        -- Zoom level < 6
        SELECT 
            ST_MakeValid(ST_ChaikinSmoothing(ST_Simplify(geometry, ZRes(6)), 2)) AS geometry, 
            name, 
            adm0_left, 
            adm0_right,
            adm0_a3_l, 
            adm0_a3_r, 
            labelrank, 
            scalerank
        FROM wld_boundary_ln
        WHERE geometry && bbox
            AND zoom_level >= 4
            AND zoom_level < 6

        UNION ALL

        -- Zoom level < 8
        SELECT 
            ST_MakeValid(ST_ChaikinSmoothing(ST_Simplify(geometry, ZRes(6)), 2)) AS geometry, 
            name, 
            adm0_left, 
            adm0_right,
            adm0_a3_l, 
            adm0_a3_r, 
            labelrank, 
            scalerank
        FROM wld_boundary_ln
        WHERE geometry && bbox
            AND zoom_level >= 6
            AND zoom_level < 8

        UNION ALL

        -- Zoom level < 10
        SELECT 
            ST_MakeValid(ST_ChaikinSmoothing(ST_Simplify(geometry, ZRes(8)), 1)) AS geometry, 
            name, 
            adm0_left, 
            adm0_right,
            adm0_a3_l, 
            adm0_a3_r, 
            labelrank, 
            scalerank
        FROM wld_boundary_ln
        WHERE geometry && bbox
            AND zoom_level >= 8
            AND zoom_level < 10

        UNION ALL

        -- Zoom level < 12
        SELECT 
            ST_MakeValid(ST_ChaikinSmoothing(ST_Simplify(geometry, ZRes(8)), 1)) AS geometry, 
            name, 
            adm0_left, 
            adm0_right,
            adm0_a3_l, 
            adm0_a3_r, 
            labelrank, 
            scalerank
        FROM wld_boundary_ln
        WHERE geometry && bbox
            AND zoom_level >= 10
            AND zoom_level < 12

        UNION ALL

        -- Zoom level < 14
        SELECT 
            ST_MakeValid(ST_ChaikinSmoothing(ST_Simplify(geometry, ZRes(10)), 1)) AS geometry, 
            name, 
            adm0_left, 
            adm0_right,
            adm0_a3_l, 
            adm0_a3_r, 
            labelrank, 
            scalerank
        FROM wld_boundary_ln
        WHERE geometry && bbox
            AND zoom_level >= 12
            AND zoom_level < 14

        UNION ALL

        -- Zoom level >= 14 (no simplification)
        SELECT 
            ST_MakeValid(geometry) AS geometry, 
            name, 
            adm0_left, 
            adm0_right,
            adm0_a3_l, 
            adm0_a3_r, 
            labelrank, 
            scalerank
        FROM wld_boundary_ln
        WHERE geometry && bbox
            AND zoom_level >= 14
    ) AS area_zoom_levels
    WHERE ST_IsValid(geometry); -- Ensure only valid geometries are returned
$$ LANGUAGE SQL IMMUTABLE;
