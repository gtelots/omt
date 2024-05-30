CREATE OR REPLACE FUNCTION layer_vn_sea_ln(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, name text, type text) AS $$
    SELECT geometry, name, type
    FROM vn_sea_ln
    WHERE geometry && bbox;
$$ LANGUAGE SQL IMMUTABLE;