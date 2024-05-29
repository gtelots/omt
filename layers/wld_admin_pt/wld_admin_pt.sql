CREATE OR REPLACE FUNCTION layer_wld_admin_pt(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, name text, name_vi text) AS $$
    SELECT geometry, name, name_vi
    FROM wld_admin_pt
    WHERE geometry && bbox;
$$ LANGUAGE SQL IMMUTABLE;