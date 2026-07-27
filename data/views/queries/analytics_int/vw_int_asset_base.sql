/*
VIEW: analytics_int.vw_int_asset_base

Finalidade:
Camada intermediária de patrimônio e estoque de capital. Expande o histórico dos
ativos por mês a partir da data de aquisição, aplica revisões de valor mais recentes (LATERAL),
recupera a vida útil da classificação e calcula o estoque bruto e a depreciação mensal.

Granularidade:
Uma linha por ativo e mês de referência (id_asset + reference_month).

Fontes principais:
- public.Assets
- public.Classification
- public.AssetRevision

Regras de negócio:
- Expande cada ativo a partir da aquisição até seu encerramento ou o mês atual.
- Desconsidera ativos sem data de aquisição ou adquiridos no futuro.
- Recupera a revisão de valor unitário mais recente até o mês de referência.
- Calcula o estoque bruto de capital (quantidade x valor unitário vigente).
- Calcula a depreciação mensal pelo método linear considerando início específico para bens em construção.
- Serve como base canônica para as views analíticas: vw_asset_capital_stock e mvw_asset_capital_stock.

Forma de consulta:
SELECT * FROM analytics_int.vw_int_asset_base;
*/

WITH asset_months AS (
    SELECT a.id_asset,
        a.id_property,
        a.name AS asset_name,
        a.acquired_at,
        a.id_classification,
        c.name AS classification,
        COALESCE(a.quantity, 1)::numeric AS quantity,
        COALESCE(a.value, 0::double precision)::numeric AS acquisition_unit_value,
        COALESCE(a.quantity, 1)::numeric * COALESCE(a.value, 0::double precision)::numeric AS acquisition_total_value,
        COALESCE(a.down_payment, 0::double precision)::numeric AS down_payment,
        COALESCE(NULLIF(a.service_life, 0), NULLIF(c.service_life, 0)) AS service_life_years,
        CASE
            WHEN a.is_in_construction = true THEN a.depreciation_starts_at
            ELSE COALESCE(a.depreciation_starts_at, a.acquired_at)
        END AS depreciation_starts_at,
        gs.reference_month::date AS reference_month
    FROM "Assets" a
        LEFT JOIN "Classification" c ON a.id_classification = c.id_classification
        CROSS JOIN LATERAL generate_series(
            date_trunc('month'::text, a.acquired_at)::date::timestamp with time zone, 
            date_trunc('month'::text, LEAST(COALESCE(a.finished_at::date, CURRENT_DATE), CURRENT_DATE)::timestamp with time zone)::date::timestamp with time zone, 
            '1 mon'::interval
        ) gs(reference_month)
    WHERE a.acquired_at IS NOT NULL 
      AND a.acquired_at::date <= CURRENT_DATE 
      AND (a.finished_at IS NULL OR a.finished_at >= a.acquired_at)
), 
asset_values AS (
    SELECT am.id_asset,
        am.id_property,
        am.asset_name,
        am.acquired_at,
        am.id_classification,
        am.classification,
        am.quantity,
        am.acquisition_unit_value,
        am.acquisition_total_value,
        am.down_payment,
        am.service_life_years,
        am.depreciation_starts_at,
        am.reference_month,
        COALESCE(ar.revision_unit_value, am.acquisition_unit_value) AS current_unit_value
    FROM asset_months am
        LEFT JOIN LATERAL (
            SELECT r.value::numeric AS revision_unit_value
            FROM "AssetRevision" r
            WHERE r.id_asset = am.id_asset 
              AND r.revised_at < (am.reference_month + '1 mon'::interval)
            ORDER BY r.revised_at DESC, r.created_at DESC, r.id_revision DESC
            LIMIT 1
        ) ar ON true
)
SELECT av.id_asset,
    av.id_property,
    av.id_classification,
    av.classification,
    av.asset_name,
    av.acquired_at,
    av.reference_month,
    av.quantity,
    av.acquisition_total_value,
    av.current_unit_value,
    av.down_payment,
    av.service_life_years,
    round(av.quantity * av.current_unit_value, 2) AS gross_capital_stock,
    round(
        CASE
            WHEN av.service_life_years > 0 
                 AND av.depreciation_starts_at IS NOT NULL 
                 AND av.reference_month >= date_trunc('month'::text, av.depreciation_starts_at)::date 
                 AND av.reference_month < (date_trunc('month'::text, av.depreciation_starts_at) + (av.service_life_years * 12)::double precision * '1 mon'::interval)::date 
            THEN av.quantity * av.current_unit_value / (av.service_life_years * 12)::numeric
            ELSE 0::numeric
        END, 
    2) AS monthly_depreciation
FROM asset_values av;
