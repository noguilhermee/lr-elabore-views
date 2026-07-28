/*
VIEW: analytics_mart.vw_cattle

Finalidade:
Consolida mensalmente o rebanho de cada propriedade, apresentando a quantidade
de animais e os valores informados para cada categoria.

Granularidade:
Uma linha por propriedade e mês (id_property + reference_month).

Fontes principais:
- analytics_int.vw_int_cattle

Regras de negócio:
- Consome da view intermediária analytics_int.vw_int_cattle (já com datas mensais calculadas e categorias ativas).
- Categorias consolidadas: vacas em lactação, vacas secas, aleitamento,
  recria, machos, outras categorias.
- Indicadores derivados: total de vacas, total do rebanho, valores por categoria.

Forma de consulta:
SELECT * FROM analytics_mart.vw_cattle;
*/

SELECT cb.id_property,
    cb.reference_month,
    sum( CASE WHEN cb.category_name = 'Vacas em lactação'::text THEN cb.total_animals ELSE 0 END) AS lactating_cows,
    sum( CASE WHEN cb.category_name = 'Vacas secas'::text THEN cb.total_animals ELSE 0 END) AS dry_cows,
    sum( CASE WHEN cb.category_name = 'Aleitamento'::text THEN cb.total_animals ELSE 0 END) AS nursing,
    sum( CASE WHEN cb.category_name = 'Recria'::text THEN cb.total_animals ELSE 0 END) AS rearing,
    sum( CASE WHEN cb.category_name = 'Macho'::text THEN cb.total_animals ELSE 0 END) AS males,
    sum( CASE WHEN cb.category_name = 'Outras categorias'::text THEN cb.total_animals ELSE 0 END) AS other_categories,
    sum( CASE WHEN cb.category_name = ANY (ARRAY['Vacas em lactação'::text, 'Vacas secas'::text]) THEN cb.total_animals ELSE 0 END) AS total_cows,
    sum(cb.total_animals) AS total_cattle,
    sum( CASE WHEN cb.category_name = 'Vacas em lactação'::text THEN cb.total_value ELSE 0::double precision END) AS lactating_cows_value,
    sum( CASE WHEN cb.category_name = 'Vacas secas'::text THEN cb.total_value ELSE 0::double precision END) AS dry_cows_value,
    sum( CASE WHEN cb.category_name = 'Aleitamento'::text THEN cb.total_value ELSE 0::double precision END) AS nursing_value,
    sum( CASE WHEN cb.category_name = 'Recria'::text THEN cb.total_value ELSE 0::double precision END) AS rearing_value,
    sum( CASE WHEN cb.category_name = 'Macho'::text THEN cb.total_value ELSE 0::double precision END) AS males_value,
    sum( CASE WHEN cb.category_name = 'Outras categorias'::text THEN cb.total_value ELSE 0::double precision END) AS other_categories_value
    
    FROM analytics_int.vw_int_cattle cb
    GROUP BY cb.id_property, cb.reference_month
    ORDER BY cb.id_property, cb.reference_month;