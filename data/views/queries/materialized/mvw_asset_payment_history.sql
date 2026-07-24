WITH monthly_payments AS (
        SELECT "AssetInstallment".id_asset,
            date_trunc('month'::text, "AssetInstallment".payment_date)::date AS reference_month,
            sum(COALESCE("AssetInstallment".value, 0::double precision))::numeric AS paid_in_month
            FROM "AssetInstallment"
            WHERE "AssetInstallment".payment_date IS NOT NULL
            GROUP BY "AssetInstallment".id_asset, (date_trunc('month'::text, "AssetInstallment".payment_date))
    ), payment_history AS (
        SELECT cs.id_asset,
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
            sum(COALESCE(mp.paid_in_month, 0::numeric)) OVER (PARTITION BY cs.id_asset ORDER BY cs.reference_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_installments_paid
            FROM analytics_mart.vw_asset_capital_stock cs
                LEFT JOIN monthly_payments mp ON cs.id_asset = mp.id_asset AND cs.reference_month = mp.reference_month
            WHERE (EXISTS ( SELECT 1
                    FROM "AssetInstallment" ai
                    WHERE ai.id_asset = cs.id_asset)) OR cs.down_payment > 0::numeric
    ), payment_calculation AS (
        SELECT ph.id_asset,
            ph.id_property,
            ph.id_classification,
            ph.classification,
            ph.asset_name,
            ph.acquired_at,
            ph.reference_month,
            ph.acquisition_total_value,
            ph.down_payment,
            ph.gross_capital_stock,
            ph.monthly_depreciation,
            ph.cumulative_installments_paid,
            LEAST(1::numeric, GREATEST(0::numeric, (ph.down_payment + ph.cumulative_installments_paid) / NULLIF(ph.acquisition_total_value, 0::numeric))) AS paid_ratio
            FROM payment_history ph
    )
SELECT payment_calculation.id_asset,
    payment_calculation.id_property,
    payment_calculation.id_classification,
    payment_calculation.classification,
    payment_calculation.asset_name,
    payment_calculation.acquired_at,
    payment_calculation.reference_month,
    payment_calculation.acquisition_total_value,
    payment_calculation.down_payment,
    payment_calculation.cumulative_installments_paid,
    payment_calculation.gross_capital_stock,
    payment_calculation.monthly_depreciation,
    round(payment_calculation.paid_ratio * 100::numeric, 2) AS paid_percentage,
    round(payment_calculation.paid_ratio * payment_calculation.gross_capital_stock / 24::numeric, 2) AS monthly_average_capital_stock
    
    FROM payment_calculation;