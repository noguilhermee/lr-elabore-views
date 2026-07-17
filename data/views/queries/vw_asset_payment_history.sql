SELECT *
FROM analytics_mart.vw_asset_payment_history
ORDER BY id_property, reference_month;


CREATE VIEW analytics_mart.vw_asset_payment_history AS

WITH monthly_payments AS (
    SELECT
        id_asset,
        DATE_TRUNC('month', payment_date)::date AS reference_month,
        SUM(COALESCE(value, 0))::numeric AS paid_in_month

    FROM "AssetInstallment"

    WHERE payment_date IS NOT NULL

    GROUP BY
        id_asset,
        DATE_TRUNC('month', payment_date)
),

payment_history AS (
    SELECT
        cs.id_asset,
        cs.id_property,
        cs.id_classification,
        cs.classification,
        cs.asset_name,
        cs.acquired_at,
        cs.reference_month,
        
        cs.acquisition_total_value,
        cs.down_payment,
        cs.gross_capital_stock,
        cs.monthly_depreciation,

        SUM(COALESCE(mp.paid_in_month, 0)) OVER (
            PARTITION BY cs.id_asset
            ORDER BY cs.reference_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )::numeric AS cumulative_installments_paid

    FROM analytics_mart.vw_asset_capital_stock cs

    LEFT JOIN monthly_payments mp
        ON cs.id_asset = mp.id_asset
       AND cs.reference_month = mp.reference_month

    WHERE EXISTS (
        SELECT 1
        FROM "AssetInstallment" ai
        WHERE ai.id_asset = cs.id_asset
    )
    OR cs.down_payment > 0
),

payment_calculation AS (
    SELECT
        ph.*,

        LEAST(
            1::numeric,
            GREATEST(
                0::numeric,
                (
                    down_payment
                    + cumulative_installments_paid
                )
                / NULLIF(acquisition_total_value, 0)
            )
        ) AS paid_ratio

    FROM payment_history ph
)

SELECT
    id_asset,                           -- ID do patrimônio
    id_property,                        -- ID da fazenda
    id_classification,                  -- ID da classificação
    classification,                     -- Classificação do patrimônio
    asset_name,                         -- Nome do patrimônio
    acquired_at,                    
    reference_month,                    -- Mês de referência
    
    gross_capital_stock,                -- Estoque bruto de capital
    monthly_depreciation,               -- Depreciação do mês

    ROUND(
        paid_ratio * 100,
        2
    ) AS paid_percentage,               -- Percentual pago, entre 0 e 100

    ROUND(
        paid_ratio * gross_capital_stock / 24,
        2
    ) AS monthly_average_capital_stock  -- Capital pago dividido por 24

FROM payment_calculation

WHERE reference_month >= DATE '2025-01-01'

limit 1000;