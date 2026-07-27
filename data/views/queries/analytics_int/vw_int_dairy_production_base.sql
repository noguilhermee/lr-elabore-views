/*
VIEW: analytics_int.vw_int_dairy_production_base

Finalidade:
Camada intermediária de sistemas de produção de leite. Expande o histórico dos
registros de DairyProduction mês a mês para a categoria LACTATION durante a vigência.

Granularidade:
Uma linha por registro de produção de leite e mês de referência (id_dairy + reference_month).

Fontes principais:
- public.DairyProduction

Regras de negócio:
- Considera apenas registros da categoria LACTATION com data de início preenchida.
- Expande a vigência do sistema de produção mês a mês.
- Serve como base padronizada para a view analítica: vw_dairy_production_system_monthly.

Forma de consulta:
SELECT * FROM analytics_int.vw_int_dairy_production_base;
*/

SELECT dp.id_dairy,
    dp.id_property,
    COALESCE(dp.compost_barn, 0) AS compost_barn,
    COALESCE(dp.free_stall, 0) AS free_stall,
    COALESCE(dp.semi_confined, 0) AS semi_confined,
    COALESCE(dp.pasture, 0) AS pasture,
    COALESCE(dp.unstructured_confinment, 0) AS unstructured_confinment,
    dp.started_at,
    dp.finished_at,
    dp.created_at,
    dp.updated_at,
    gs.reference_month::date AS reference_month
FROM "DairyProduction" dp
    CROSS JOIN LATERAL generate_series(
        date_trunc('month'::text, dp.started_at)::date::timestamp with time zone, 
        date_trunc('month'::text, LEAST(COALESCE(dp.finished_at, CURRENT_DATE::timestamp without time zone), CURRENT_DATE::timestamp without time zone))::date::timestamp with time zone, 
        '1 mon'::interval
    ) gs(reference_month)
WHERE dp.started_at IS NOT NULL 
  AND dp.category::text = 'LACTATION'::text 
  AND COALESCE(dp.finished_at, CURRENT_DATE::timestamp without time zone) >= dp.started_at;
