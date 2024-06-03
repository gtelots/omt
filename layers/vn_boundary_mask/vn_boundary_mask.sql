CREATE OR REPLACE FUNCTION layer_vn_boundary_mask(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry) AS $$
    SELECT geometry
    FROM vn_boundary_mask
    WHERE geometry && bbox;
$$ LANGUAGE SQL IMMUTABLE;