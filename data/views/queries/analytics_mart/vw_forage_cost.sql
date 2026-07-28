/*
VIEW: analytics_mart.vw_forage_cost

Finalidade:
Consolida mensalmente o custo de forrageiras por propriedade, mês e plantio (id_planted_culture),
trazendo o id_planted_culture, a categoria alimentar (feeding_category: VOLUMOSO, CONCENTRADO, etc.)
e os custos por etapa de manejo.

Granularidade:
Uma linha por propriedade, mês e cultura plantada (id_property + reference_month + id_planted_culture).

Fontes principais:
- analytics_int.vw_int_forage_cost_items
*/

SELECT 
    fci.id_property,
    fci.reference_month,
    fci.id_planted_culture,
    fci.culture_name,
    fci.harvest_product_name,
    fci.feeding_category,
    SUM(CASE WHEN fci.stage = 'PRE_PLANTIO' THEN fci.line_total ELSE 0::double precision END) AS pre_planting_cost,
    SUM(CASE WHEN fci.stage = 'PLANTIO' THEN fci.line_total ELSE 0::double precision END) AS planting_cost,
    SUM(CASE WHEN fci.stage = 'TRATOS_CULTURAIS' THEN fci.line_total ELSE 0::double precision END) AS cultural_treatments_cost,
    SUM(CASE WHEN fci.stage = 'COLHEITA_ENSILAGEM_GRAO' THEN fci.line_total ELSE 0::double precision END) AS harvest_grain_cost,
    SUM(CASE WHEN fci.stage = 'COLHEITA_ENSILAGEM_PLANTA_INTEIRA' THEN fci.line_total ELSE 0::double precision END) AS harvest_whole_plant_cost,
    SUM(fci.line_total) AS total_forage_cost
FROM analytics_int.vw_int_forage_cost_items fci
GROUP BY fci.id_property, fci.reference_month, fci.id_planted_culture, fci.culture_name, fci.harvest_product_name, fci.feeding_category
ORDER BY fci.id_property, fci.reference_month, fci.id_planted_culture;
