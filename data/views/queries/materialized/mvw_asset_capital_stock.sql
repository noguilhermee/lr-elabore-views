/*
MATERIALIZED VIEW: analytics_mart.mvw_asset_capital_stock

Finalidade:
Calcula mensalmente o estoque bruto de capital e a depreciação dos ativos
cadastrados em cada propriedade.

Granularidade:
Uma linha por ativo e mês de referência.

Indicadores calculados:
- Valor total de aquisição
- Valor unitário vigente no mês
- Estoque bruto de capital
- Depreciação mensal
- Valor da entrada do ativo

Regras principais:
- Expande cada ativo desde o mês de aquisição até sua data de término ou até o mês atual.
- Utiliza a quantidade cadastrada ou assume uma unidade quando ela estiver ausente.
- Recupera a revisão de valor mais recente existente até cada mês.
- Utiliza a vida útil do ativo ou, quando ausente, a vida útil definida em sua classificação.
- Calcula a depreciação mensal pelo método linear.
- Para ativos em construção, considera a data específica de início da depreciação.
- O estoque bruto corresponde à quantidade multiplicada pelo valor unitário vigente, sem descontar a depreciação acumulada.

Fontes principais:
- Assets
- Classification
- AssetRevision

Forma de consulta:
SELECT *
FROM analytics_mart.mvw_asset_capital_stock;

Forma de atualização:
REFRESH MATERIALIZED VIEW analytics_mart.mvw_asset_capital_stock;
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
                CROSS JOIN LATERAL generate_series(date_trunc('month'::text, a.acquired_at)::date::timestamp with time zone, date_trunc('month'::text, LEAST(COALESCE(a.finished_at::date, CURRENT_DATE), CURRENT_DATE)::timestamp with time zone)::date::timestamp with time zone, '1 mon'::interval) gs(reference_month)
            WHERE a.acquired_at IS NOT NULL AND a.acquired_at::date <= CURRENT_DATE AND (a.finished_at IS NULL OR a.finished_at >= a.acquired_at)
    ), asset_values AS (
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
                LEFT JOIN LATERAL ( SELECT r.value::numeric AS revision_unit_value
                    FROM "AssetRevision" r
                    WHERE r.id_asset = am.id_asset AND r.revised_at < (am.reference_month + '1 mon'::interval)
                    ORDER BY r.revised_at DESC, r.created_at DESC, r.id_revision DESC
                    LIMIT 1) ar ON true
    ), capital_calculation AS (
        SELECT av.id_asset,
            av.id_property,
            av.asset_name,
            av.acquired_at,
            av.id_classification,
            av.classification,
            av.quantity,
            av.acquisition_unit_value,
            av.acquisition_total_value,
            av.down_payment,
            av.service_life_years,
            av.depreciation_starts_at,
            av.reference_month,
            av.current_unit_value,
            av.quantity * av.current_unit_value AS gross_capital_stock,
                CASE
                    WHEN av.service_life_years > 0 AND av.depreciation_starts_at IS NOT NULL AND av.reference_month >= date_trunc('month'::text, av.depreciation_starts_at)::date AND av.reference_month < (date_trunc('month'::text, av.depreciation_starts_at) + (av.service_life_years * 12)::double precision * '1 mon'::interval)::date THEN av.quantity * av.current_unit_value / (av.service_life_years * 12)::numeric
                    ELSE 0::numeric
                END AS monthly_depreciation
            FROM asset_values av
    )
SELECT capital_calculation.id_asset,
    capital_calculation.id_property,
    capital_calculation.id_classification,
    capital_calculation.classification,
    capital_calculation.asset_name,
    capital_calculation.acquired_at,
    capital_calculation.reference_month,
    capital_calculation.quantity,
    capital_calculation.acquisition_total_value,
    capital_calculation.current_unit_value,
    capital_calculation.down_payment,
    round(capital_calculation.gross_capital_stock, 2) AS gross_capital_stock,
    round(capital_calculation.monthly_depreciation, 2) AS monthly_depreciation
    
    FROM capital_calculation;