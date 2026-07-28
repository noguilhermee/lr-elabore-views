/*
VIEW: analytics_mart.vw_forage_cost_stage

Finalidade:
Consolida mensalmente os custos de forrageiras por propriedade, mês, cultura plantada e etapa do manejo.

Granularidade:
Uma linha por propriedade, mês de referência, plantio e etapa (id_property + reference_month + id_planted_culture + stage).

Fontes principais:
- analytics_int.vw_int_forage_cost_items
*/
    
SELECT 
    fci.id_property,
    fci.id_planted_culture,
    fci.reference_month,
    fci.culture_name,
    fci.harvest_product_name,
    fci.feeding_category,
    fci.stage,
    SUM(fci.line_total) AS stage_total_cost,
    SUM(fci.consumed_quantity) AS stage_consumed_quantity,
    COUNT(fci.id_management_product) AS items_applied_count

FROM analytics_int.vw_int_forage_cost_items fci
GROUP BY fci.id_property, fci.reference_month, fci.id_planted_culture, fci.culture_name, fci.harvest_product_name, fci.feeding_category, fci.stage
ORDER BY fci.id_property, fci.reference_month, fci.id_planted_culture, fci.stage;
