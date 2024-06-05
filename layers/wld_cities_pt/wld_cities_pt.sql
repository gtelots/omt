CREATE OR REPLACE FUNCTION layer_wld_cities_pt(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, city_name text, status text, city_name_vi text, cntry_name text, level int) AS $$
    SELECT geometry, city_name, status, city_name_vi, cntry_name, level
    FROM wld_cities_pt
    WHERE geometry && bbox
      AND zoom_level >= 5;
$$ LANGUAGE SQL IMMUTABLE;