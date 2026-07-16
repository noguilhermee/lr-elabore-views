SELECT *
FROM analytics_mart.vw_asset_capital_stock
ORDER BY id_property;



CREATE OR REPLACE VIEW analytics_mart.vw_asset_capital_stock AS

WITH asset_months AS (
    SELECT
        a.id_asset,
        a.id_property,
        a.name AS asset_name,
        a.id_classification,
        c.name AS classification,

        a.acquired_at,
        a.finished_at,
        a.is_active,

        COALESCE(a.quantity, 1) AS quantity,
        COALESCE(a.value, 0)::numeric AS acquisition_unit_value,
        COALESCE(a.quantity, 1)::numeric
            * COALESCE(a.value, 0)::numeric AS acquisition_total_value,

        COALESCE(a.down_payment, 0)::numeric AS down_payment,

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

        ar.id_revision,
        ar.revised_at,
        ar.revision_unit_value,

        COALESCE(
            ar.revision_unit_value,
            am.acquisition_unit_value
        )::numeric AS current_unit_value

    FROM asset_months am

    LEFT JOIN LATERAL (
        SELECT
            r.id_revision,
            r.revised_at,
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
)

SELECT
    id_asset,
    id_property,

    id_classification,
    classification,
    asset_name,

    acquired_at,
    finished_at,
    reference_month,
    is_active,

    quantity,

    acquisition_unit_value,
    acquisition_total_value,

    id_revision,
    revised_at,
    revision_unit_value,

    current_unit_value,

    quantity::numeric
        * current_unit_value AS gross_capital_stock,

    down_payment

FROM asset_values
limit 10000;