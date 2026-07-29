/*
VIEW: analytics_int.vw_int_forage_production

Finalidade:
Camada intermediária de produção agrícola e forragens bruta para análise.
Consolida os dados de plantio, colheita (harvest_date), áreas plantadas/colhidas, total colhido por plantio,
volume produzido, cultura, produto colhido específico registrado nos metadados da colheita (product_name em observation),
categoria alimentar (feeding_category) e rendimento (yield_kg_per_ha).

Granularidade:
Uma linha por registro de produção agrícola ativo (id_production).
*/
WITH harvested_culture_totals AS (
    SELECT 
        p.id_planted_culture,
        SUM(COALESCE(p.harvested_area, 0::double precision)) AS total_harvested_area
    FROM "Production" p
    WHERE p.is_active = true
    GROUP BY p.id_planted_culture
)
SELECT 
    a.id_property,
    p.id_production,
    p.id_planted_culture,
    pc.id_culture,
    chp.id_culture_harvest_product,
    date_trunc('month'::text, p.produced_at)::date AS reference_month,
    
    -- Datas e Áreas
    pc.planted_at,
    p.produced_at AS harvest_date,
    pc.planted_area,
    p.harvested_area,
    COALESCE(hct.total_harvested_area, 0::double precision) AS total_harvested_area,
    p.quantity_produced AS production,
    
    -- Cultura, Alimento Colhido e Categoria Alimentar
    c.name AS culture_name,
    chp.name AS harvest_product_name,
    chp.feeding_category,
    
    -- Rendimento (kg/ha)
    CASE 
        WHEN p.harvested_area > 0 THEN round((p.quantity_produced / p.harvested_area)::numeric, 2)::double precision 
        ELSE 0::double precision 
    END AS yield_kg_per_ha

FROM "Production" p
JOIN "PlantedCulture" pc ON p.id_planted_culture = pc.id_planted_culture
JOIN "Area" a ON pc.id_area = a.id_area
LEFT JOIN "Culture" c ON pc.id_culture = c.id_culture
LEFT JOIN "CultureHarvestProduct" chp ON c.id_culture = chp.id_culture 
                                     AND chp.is_active = true
                                     AND (
                                         p.observation IS NULL 
                                         OR p.observation NOT LIKE '%"product_name":%' 
                                         OR chp.name = substring(p.observation from '"product_name":"([^"]+)"')
                                     )
LEFT JOIN harvested_culture_totals hct ON p.id_planted_culture = hct.id_planted_culture
WHERE p.is_active = true;