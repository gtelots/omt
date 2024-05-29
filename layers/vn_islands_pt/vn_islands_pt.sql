CREATE OR REPLACE FUNCTION layer_vn_islands_pt(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, name text, name_en text) AS $$
    SELECT geometry, name, name_en
    FROM vn_islands_pt
    WHERE geometry && bbox
			AND zoom_level >= 3;
$$ LANGUAGE SQL IMMUTABLE;