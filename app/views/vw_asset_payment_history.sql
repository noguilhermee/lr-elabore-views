SELECT *
FROM analytics_mart.vw_asset_payment_history
ORDER BY id_property, reference_month;


CREATE OR REPLACE VIEW analytics_mart.vw_asset_payment_history AS

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
        cs.*,

        COALESCE(mp.paid_in_month, 0)::numeric AS paid_in_month,

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

        down_payment
            + cumulative_installments_paid AS cumulative_total_paid,

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
    id_asset,                          -- ID do patrimônio / ativo
    id_property,                       -- ID da propriedade / fazenda

    id_classification,                 -- ID da classificação do patrimônio
    classification,                    -- Classificação do patrimônio, como máquinas ou benfeitorias
    asset_name,                        -- Nome do patrimônio / bem

    acquired_at,                       -- Data de aquisição do patrimônio
    finished_at,                       -- Data de encerramento, baixa ou fim do patrimônio
    reference_month,                   -- Mês de referência do acompanhamento
    is_active,                         -- Indica se o patrimônio está ativo no cadastro

    quantity,                          -- Quantidade de unidades do patrimônio

    acquisition_unit_value,            -- Valor de aquisição de uma unidade do patrimônio
    acquisition_total_value,           -- Valor total de aquisição: quantidade × valor unitário

    id_revision,                       -- ID da revisão de valor utilizada no mês
    revised_at,                        -- Data em que o valor do patrimônio foi revisado
    revision_unit_value,               -- Novo valor unitário informado na revisão

    current_unit_value,                -- Valor unitário válido no mês: revisão ou valor de aquisição
    gross_capital_stock,               -- Estoque bruto de capital: quantidade × valor unitário atual

    down_payment,                      -- Valor da entrada paga na aquisição
    paid_in_month,                     -- Valor das parcelas pagas no mês
    cumulative_installments_paid,      -- Valor acumulado das parcelas pagas até o mês
    cumulative_total_paid,             -- Total pago acumulado: entrada + parcelas pagas

    ROUND(
        paid_ratio * 100, 2
    ) AS paid_percentage,             -- Percentual do patrimônio já pago, limitado a 100%

    ROUND( paid_ratio * gross_capital_stock, 2
    ) AS paid_capital_value,           -- Parcela do estoque de capital considerada já paga

    ROUND(
        gross_capital_stock - (paid_ratio * gross_capital_stock), 2
    ) AS unpaid_capital_value          -- Parcela do estoque de capital que ainda não foi paga ADD

FROM payment_calculation;