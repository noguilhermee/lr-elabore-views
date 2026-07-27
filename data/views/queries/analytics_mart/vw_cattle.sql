/*
VIEW: analytics_mart.vw_cattle

Finalidade:
Consolida mensalmente o rebanho de cada propriedade, apresentando a quantidade
de animais e os valores informados para cada categoria.

Granularidade:
Uma linha por propriedade e mês (id_property + reference_month).

Fontes principais:
- Cattle
- CattlePeriod
- CattleCategory

Regras de negócio:
- Utiliza o ano e o mês cadastrados em CattlePeriod (make_date).
- Considera somente categorias ativas (isActive = true).
- Categorias consolidadas: vacas em lactação, vacas secas, aleitamento,
  recria, machos, outras categorias.
- Indicadores derivados: total de vacas, total do rebanho, valores por categoria.

Forma de consulta:
SELECT * FROM analytics_mart.vw_cattle;
*/

SELECT cp.id_property,
    make_date(cp.year, cp.month, 1) AS reference_month,
    sum( CASE WHEN cc.name = 'Vacas em lactação'::text THEN c.total_animals ELSE 0 END) AS lactating_cows,
    sum( CASE WHEN cc.name = 'Vacas secas'::text THEN c.total_animals ELSE 0 END) AS dry_cows,
    sum( CASE WHEN cc.name = 'Aleitamento'::text THEN c.total_animals ELSE 0 END) AS nursing,
    sum( CASE WHEN cc.name = 'Recria'::text THEN c.total_animals ELSE 0 END) AS rearing,
    sum( CASE WHEN cc.name = 'Macho'::text THEN c.total_animals ELSE 0 END) AS males,
    sum( CASE WHEN cc.name = 'Outras categorias'::text THEN c.total_animals ELSE 0 END) AS other_categories,
    sum( CASE WHEN cc.name = ANY (ARRAY['Vacas em lactação'::text, 'Vacas secas'::text]) THEN c.total_animals ELSE 0 END) AS total_cows,
    sum(c.total_animals) AS total_cattle,
    sum( CASE WHEN cc.name = 'Vacas em lactação'::text THEN c.value ELSE 0::double precision END) AS lactating_cows_value,
    sum( CASE WHEN cc.name = 'Vacas secas'::text THEN c.value ELSE 0::double precision END) AS dry_cows_value,
    sum( CASE WHEN cc.name = 'Aleitamento'::text THEN c.value ELSE 0::double precision END) AS nursing_value,
    sum( CASE WHEN cc.name = 'Recria'::text THEN c.value ELSE 0::double precision END) AS rearing_value,
    sum( CASE WHEN cc.name = 'Macho'::text THEN c.value ELSE 0::double precision END) AS males_value,
    sum( CASE WHEN cc.name = 'Outras categorias'::text THEN c.value ELSE 0::double precision END) AS other_categories_value
    
    FROM "Cattle" c
        JOIN "CattlePeriod" cp ON c.id_period = cp.id_period
        JOIN "CattleCategory" cc ON c.id_cattle_category = cc.id_cattle_category
    WHERE cc."isActive" = true AND cp.year IS NOT NULL AND cp.month IS NOT NULL
    GROUP BY cp.id_property, cp.year, cp.month
    ORDER BY cp.id_property, (make_date(cp.year, cp.month, 1));