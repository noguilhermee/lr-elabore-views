/*
VIEW: analytics_mart.vw_forage_production

Finalidade:
View analítica de produção de forrageiras e culturas agrícolas em formato bruto para deflação e análise,
contendo dados de áreas plantada/colhida, área colhida total por plantio, volume produzido, alimento colhido,
categoria alimentar (feeding_category) e rendimento (yield_kg_per_ha).

Granularidade:
Uma linha por registro de produção (id_production).

Fontes principais:
- analytics_int.vw_int_forage_production
*/

SELECT 
    fp.id_property,
    fp.id_production,
    fp.id_culture,
    fp.id_planted_culture,
    fp.id_culture_harvest_product,
    fp.reference_month,
    
    -- Datas e Áreas
    fp.planted_at,
    fp.harvest_date,
    fp.planted_area,
    fp.harvested_area,
    fp.total_harvested_area,
    fp.production,
    
    -- Cultura, Alimento Colhido e Categoria Alimentar
    fp.culture_name,
    fp.harvest_product_name,
    fp.feeding_category,
    
    -- Rendimento (kg/ha)
    fp.yield_kg_per_ha

FROM analytics_int.vw_int_forage_production fp
ORDER BY fp.id_property, fp.reference_month;
