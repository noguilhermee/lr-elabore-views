/* VIEW: analytics_int.vw_area_base 

- Finalidade: 
Consolida os dados cadastrais das áreas vinculadas às propriedades rurais, 
incluindo o tipo de uso, área própria, área arrendada, área total, valor da terra 
e informações de vigência e status do cadastro. 

- Forma de consulta: 
SELECT * FROM analytics_int.vw_area_base; 

*/

SELECT a.id_area,
    a.id_property,
    p.property_name,
    a.id_area_usage,
    au.name AS area_usage_name,
    a.name AS area_name,
    a.hectares_owned,
    a.hectares_rented,
    COALESCE(a.hectares_owned, 0::double precision) + COALESCE(a.hectares_rented, 0::double precision) AS hectares_total,
    a.raw_land_value,
    a.started_at,
    a.finished_at,
    a.is_active,
    a.created_at,
    a.updated_at
    
    FROM "Area" a
        LEFT JOIN "Property" p ON p.id_property = a.id_property
        LEFT JOIN "AreaUsage" au ON au.id_area_usage = a.id_area_usage;