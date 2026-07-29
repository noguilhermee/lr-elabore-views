/*
VIEW: analytics_int.vw_int_forage_cost

Finalidade:
Camada intermediária de custos de forrageiras e culturas consolidados por mês de aplicação (applied_at) e área plantada (id_planted_culture).
Soma os custos dos produtos por etapas de manejo (pré-plantio, plantio, tratos culturais, colheita grão, colheita planta inteira)
e fornece o custo total mensal por plantio.

Granularidade:
Uma linha por id_property + reference_month + id_planted_culture.

Fontes principais:
- analytics_int.vw_int_forage_cost_items
*/

SELECT 
    fci.id_property,
    fci.id_planted_culture,
    fci.id_culture,
    fci.id_area,
    fci.reference_month,
    fci.culture_name,
    
    SUM(CASE WHEN fci.stage = 'PRE_PLANTIO' THEN fci.line_total ELSE 0::double precision END) AS pre_planting_cost,
    SUM(CASE WHEN fci.stage = 'PLANTIO' THEN fci.line_total ELSE 0::double precision END) AS planting_cost,
    SUM(CASE WHEN fci.stage = 'TRATOS_CULTURAIS' THEN fci.line_total ELSE 0::double precision END) AS cultural_treatments_cost,
    SUM(CASE WHEN fci.stage = 'COLHEITA_ENSILAGEM_GRAO' THEN fci.line_total ELSE 0::double precision END) AS harvest_grain_cost,
    SUM(CASE WHEN fci.stage = 'COLHEITA_ENSILAGEM_PLANTA_INTEIRA' THEN fci.line_total ELSE 0::double precision END) AS harvest_whole_plant_cost,
    SUM(fci.line_total) AS total_forage_cost
    
FROM analytics_int.vw_int_forage_cost_items fci
GROUP BY 
    fci.id_property,
    fci.id_planted_culture,
    fci.id_culture,
    fci.id_area,
    fci.reference_month,
    fci.culture_name;
