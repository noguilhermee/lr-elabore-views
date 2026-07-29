/*
VIEW: analytics_mart.vw_forage_cost

Finalidade:
View analítica consumidora do mart de custos de forrageira, organizada por propriedade, mês da aplicação do insumo (reference_month) e área plantada.

Granularidade:
Uma linha por id_property + reference_month + id_planted_culture.

Fontes principais:
- analytics_int.vw_int_forage_cost
*/

SELECT 
    fc.id_property,
    fc.id_planted_culture,
    fc.id_culture,
    fc.id_area,
    fc.reference_month,
    fc.culture_name,
    fc.pre_planting_cost,
    fc.planting_cost,
    fc.cultural_treatments_cost,
    fc.harvest_grain_cost,
    fc.harvest_whole_plant_cost,
    fc.total_forage_cost
FROM analytics_int.vw_int_forage_cost fc
ORDER BY fc.id_property, fc.reference_month, fc.id_planted_culture;
