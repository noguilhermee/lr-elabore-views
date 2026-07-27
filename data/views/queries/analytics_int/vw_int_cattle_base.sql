/*
VIEW: analytics_int.vw_int_cattle_base

Finalidade:
Camada intermediária do rebanho bovino. Junta inventário com períodos e categorias,
calcula a data de referência mensal e projeta estritamente as colunas consumidas
pela view analítica vw_cattle.

Granularidade:
Uma linha por registro de rebanho por categoria e período (id_cattle).

Fontes principais:
- public.Cattle
- public.CattlePeriod
- public.CattleCategory

Regras de negócio:
- Junta o rebanho com o período e a categoria do animal.
- Considera somente categorias ativas (isActive = true).
- Valida presença de ano e mês no período.
- Constrói a data de referência mensal como DATE (primeiro dia do mês).
- Projeta estritamente as colunas consumidas por vw_cattle.

Forma de consulta:
SELECT * FROM analytics_int.vw_int_cattle_base;
*/

SELECT cp.id_property,
    make_date(cp.year, cp.month, 1) AS reference_month,
    cc.name AS category_name,
    c.total_animals,
    c.value AS total_value
FROM "Cattle" c
JOIN "CattlePeriod" cp ON c.id_period = cp.id_period
JOIN "CattleCategory" cc ON c.id_cattle_category = cc.id_cattle_category
WHERE cc."isActive" = true 
  AND cp.year IS NOT NULL 
  AND cp.month IS NOT NULL;
