CREATE OR REPLACE FUNCTION layer_vn_islands_pg(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry) AS $$
    SELECT geometry
    FROM vn_islands_pg
    WHERE geometry && bbox
			AND zoom_level >= 3;
$$ LANGUAGE SQL IMMUTABLE;