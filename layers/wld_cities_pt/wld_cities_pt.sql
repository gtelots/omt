CREATE OR REPLACE FUNCTION layer_wld_cities_pt(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, city_name text, status text, name_vi text, cntry_name text) AS $$
    SELECT geometry, city_name, status, name_vi, cntry_name
    FROM wld_cities_pt
    WHERE zoom_level >= 5;
      -- AND geometry && bbox;
$$ LANGUAGE SQL IMMUTABLE;