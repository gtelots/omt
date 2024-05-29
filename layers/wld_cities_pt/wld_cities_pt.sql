CREATE OR REPLACE FUNCTION layer_wld_cities_pt(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, city_name text, city_name_vi text) AS $$
    SELECT geometry, city_name, city_name_vi
    FROM wld_cities_pt
    WHERE geometry && bbox
      AND zoom_level >= 5;
$$ LANGUAGE SQL IMMUTABLE;