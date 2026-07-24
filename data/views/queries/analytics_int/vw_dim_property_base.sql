/*
VIEW: analytics_int.vw_dim_property_base

- Finalidade:
Cria a dimensão cadastral consolidada das propriedades rurais, reunindo dados
da propriedade, empreendedor, agroindústria, localização, valor mais recente
da terra e classificação da situação cadastral da propriedade.

- Forma de consulta:
SELECT *
FROM analytics_int.vw_dim_property_base;

*/

WITH latest_land_value AS (
    SELECT plvh.id_property,
    plvh.value AS land_value_latest,
    plvh.updated_at AS land_value_updated_at,
    row_number() OVER (PARTITION BY plvh.id_property ORDER BY plvh.updated_at DESC, plvh.created_at DESC) AS rn
    FROM "PropertyLandValueHistory" plvh
)
SELECT p.id_property,
    p.property_name,
    p.legal_name,
    p.state_registration,
    p.labor_rural_code,
    p.agroindustry_code,
    p.id_entrepreneur,
    e.name AS entrepreneur_name,
    p.id_agroindustry,
    a.name AS agroindustry_name,
    a.cnpj AS agroindustry_cnpj,
    p.latitude,
    p.longitude,
    p.altitude,
    p.uf,
    p.city,
    p.dairy_region,
    p."isActive" AS property_is_active,
    p."isApproved" AS property_is_approved,
    p.entry_at,
    p.created_at,
    p.updated_at,
    p.raw_land_value AS raw_land_value_property,
    llv.land_value_latest,
    llv.land_value_updated_at,
    
    CASE
        WHEN p."isActive" = true AND p."isApproved" = true THEN 'active_approved'::text
        WHEN p."isActive" = true AND p."isApproved" = false THEN 'active_pending'::text
        ELSE 'inactive'::text
    END AS property_status

    FROM "Property" p
        LEFT JOIN "Entrepreneur" e ON e.id_entrepreneur = p.id_entrepreneur
        LEFT JOIN "Agroindustry" a ON a.id_agroindustry = p.id_agroindustry
        LEFT JOIN latest_land_value llv ON llv.id_property = p.id_property AND llv.rn = 1;