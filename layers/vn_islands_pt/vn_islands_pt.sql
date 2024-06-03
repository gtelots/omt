CREATE OR REPLACE FUNCTION layer_vn_islands_pt(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, name text, name_en text, name_arch text, type text) AS $$
    SELECT geometry, name, name_en, name_arch, type
    FROM vn_islands_pt
    WHERE geometry && bbox;
$$ LANGUAGE SQL IMMUTABLE;