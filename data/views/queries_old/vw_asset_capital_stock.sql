SELECT *
FROM analytics_mart.vw_asset_capital_stock
ORDER BY id_property;



CREATE VIEW analytics_mart.vw_asset_capital_stock AS

WITH asset_months AS (
    SELECT
        a.id_asset,
        a.id_property,
        a.name AS asset_name,
        a.acquired_at,
        
        a.id_classification,
        c.name AS classification,

        COALESCE(a.quantity, 1)::numeric AS quantity,

        COALESCE(a.value, 0)::numeric AS acquisition_unit_value,

        COALESCE(a.quantity, 1)::numeric
            * COALESCE(a.value, 0)::numeric AS acquisition_total_value,

        COALESCE(a.down_payment, 0)::numeric AS down_payment,

        COALESCE(
            NULLIF(a.service_life, 0),
            NULLIF(c.service_life, 0)
        )::integer AS service_life_years,

        CASE
            WHEN a.is_in_construction = TRUE
            THEN a.depreciation_starts_at
            ELSE COALESCE(
                a.depreciation_starts_at,
                a.acquired_at
            )
        END AS depreciation_starts_at,

        gs.reference_month::date AS reference_month

    FROM "Assets" a

    LEFT JOIN "Classification" c
        ON a.id_classification = c.id_classification

    CROSS JOIN LATERAL GENERATE_SERIES(
        DATE_TRUNC('month', a.acquired_at)::date,

        DATE_TRUNC(
            'month',
            LEAST(
                COALESCE(a.finished_at::date, CURRENT_DATE),
                CURRENT_DATE
            )
        )::date,

        INTERVAL '1 month'
    ) AS gs(reference_month)

    WHERE a.acquired_at IS NOT NULL
      AND a.acquired_at::date <= CURRENT_DATE
      AND (
          a.finished_at IS NULL
          OR a.finished_at >= a.acquired_at
      )
),

asset_values AS (
    SELECT
        am.*,

        COALESCE(
            ar.revision_unit_value,
            am.acquisition_unit_value
        )::numeric AS current_unit_value

    FROM asset_months am

    LEFT JOIN LATERAL (
        SELECT
            r.value::numeric AS revision_unit_value

        FROM "AssetRevision" r

        WHERE r.id_asset = am.id_asset
          AND r.revised_at
              < am.reference_month + INTERVAL '1 month'

        ORDER BY
            r.revised_at DESC,
            r.created_at DESC,
            r.id_revision DESC

        LIMIT 1
    ) ar ON TRUE
),

capital_calculation AS (
    SELECT
        av.*,

        quantity * current_unit_value AS gross_capital_stock,

        CASE
            WHEN service_life_years > 0
             AND depreciation_starts_at IS NOT NULL
             AND reference_month
                 >= DATE_TRUNC('month', depreciation_starts_at)::date
             AND reference_month < (
                    DATE_TRUNC('month', depreciation_starts_at)
                    + (service_life_years * 12) * INTERVAL '1 month'
                 )::date
            THEN (
                quantity * current_unit_value
            ) / (service_life_years * 12)
            ELSE 0
        END AS monthly_depreciation

    FROM asset_values av
)

SELECT
    id_asset,                          -- ID do patrimônio
    id_property,                       -- ID da fazenda
    id_classification,                 -- ID da classificação
    classification,                    -- Classificação do patrimônio
    asset_name,                        -- Nome do patrimônio
    acquired_at,
    reference_month,                   -- Mês de referência
    
    quantity,                          -- Quantidade do bem
    acquisition_total_value,           -- Valor total original de aquisição
    current_unit_value,                -- Valor unitário vigente, com revisão
    down_payment,                      -- Valor da entrada

    ROUND(
        gross_capital_stock,
        2
    ) AS gross_capital_stock,          -- Estoque bruto de capital

    ROUND(
        monthly_depreciation,
        2
    ) AS monthly_depreciation          -- Depreciação daquele mês

FROM capital_calculation
limit 1000;