DROP FUNCTION IF EXISTS layer_vn_wards_pt_v1;

CREATE OR REPLACE FUNCTION layer_vn_wards_pt_v1(bbox geometry, zoom_level int)
RETURNS TABLE(geometry geometry, code text, name text, name_en text, level text, admin_level int, label text, rank int) AS $$
    SELECT geometry, code, name, name_en, level, admin_level, label, rank
    FROM vn_wards_pt_v1
    WHERE geometry && bbox
            AND zoom_level >= 3;
$$ LANGUAGE SQL IMMUTABLE;