/*
VIEW: analytics_mart.vw_forage_cost_stage

Finalidade:
View analítica consumidora do mart de custos de forrageira detalhada por área (id_area), plantio (id_planted_culture), cultura (id_culture), mês de referência (reference_month) e etapa (stage).

Granularidade:
Uma linha por id_property + id_area + id_planted_culture + id_culture + reference_month + stage.

Fontes principais:
- analytics_int.vw_int_forage_cost_items
*/

SELECT 
    fci.id_property,
    fci.id_area,
    fci.id_planted_culture,
    fci.id_culture,
    fci.reference_month,
    fci.culture_name,
    fci.stage,
    SUM(fci.line_total) AS total_monthly_cost
FROM analytics_int.vw_int_forage_cost_items fci
GROUP BY 
    fci.id_property,
    fci.id_area,
    fci.id_planted_culture,
    fci.id_culture,
    fci.reference_month,
    fci.culture_name,
    fci.stage
ORDER BY 
    fci.id_property,
    fci.id_area,
    fci.reference_month DESC,
    fci.stage;
