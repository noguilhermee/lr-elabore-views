SELECT *
FROM analytics_mart.vw_asset_payment_history
ORDER BY id_property, reference_month;


CREATE OR REPLACE VIEW analytics_mart.vw_asset_payment_history_monthly AS

SELECT
    id_property,
    reference_month,

    COALESCE(
        SUM(monthly_depreciation) FILTER (
            WHERE LOWER(TRIM(classification)) = 'benfeitorias'
        ),
        0
    ) AS monthly_depreciation_benfeitorias,

    COALESCE(
        SUM(monthly_depreciation) FILTER (
            WHERE LOWER(TRIM(classification)) IN (
                'maquinas e equipamentos',
                'máquinas e equipamentos'
            )
        ),
        0
    ) AS monthly_depreciation_maquinas_e_equipamentos,

    COALESCE(
        SUM(monthly_average_capital_stock) FILTER (
            WHERE LOWER(TRIM(classification)) = 'benfeitorias'
        ),
        0
    ) AS monthly_average_capital_stock_benfeitorias,

    COALESCE(
        SUM(monthly_average_capital_stock) FILTER (
            WHERE LOWER(TRIM(classification)) IN (
                'maquinas e equipamentos',
                'máquinas e equipamentos'
            )
        ),
        0
    ) AS monthly_average_capital_stock_maquinas_e_equipamentos

FROM analytics_mart.vw_asset_payment_history

WHERE reference_month >= DATE '2025-01-01'

GROUP BY
    id_property,
    reference_month;