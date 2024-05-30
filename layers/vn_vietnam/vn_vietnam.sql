CREATE OR REPLACE FUNCTION layer_vn_vietnam(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, code text, name text, name_en text) AS $$
    SELECT geometry, code, name, name_en
    FROM vn_vietnam
    WHERE geometry && bbox;
$$ LANGUAGE SQL IMMUTABLE;