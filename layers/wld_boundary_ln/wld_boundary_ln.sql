CREATE OR REPLACE FUNCTION layer_wld_boundary_ln(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, name text, adm0_a3_l text, adm0_a3_r text, iso3 text, status text) AS $$
    SELECT geometry, name, adm0_a3_l, adm0_a3_r, iso3, status
    FROM wld_boundary_ln
    WHERE geometry && bbox;
$$ LANGUAGE SQL IMMUTABLE;