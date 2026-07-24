SELECT "ExpenseEntry".id_property,
    date_trunc('month'::text, "ExpenseEntry".reference_month)::date AS reference_month,
    max("ExpenseEntry".unit_price) AS unit_price,
    sum(
        CASE
            WHEN "ExpenseEntry".line_code = 'hired-labor'::text THEN COALESCE("ExpenseEntry".quantity, 0::double precision)
            ELSE 0::double precision
        END) AS hired_labor_quantity,
    sum(
        CASE
            WHEN "ExpenseEntry".line_code = 'hired-labor'::text THEN COALESCE("ExpenseEntry".amount_total, 0::double precision)
            ELSE 0::double precision
        END) AS hired_labor_amount_total,
    sum(
        CASE
            WHEN "ExpenseEntry".line_code = 'discarded'::text THEN COALESCE("ExpenseEntry".quantity, 0::double precision)
            ELSE 0::double precision
        END) AS discarded_quantity,
    sum(
        CASE
            WHEN "ExpenseEntry".line_code = 'discarded'::text THEN COALESCE("ExpenseEntry".amount_total, 0::double precision)
            ELSE 0::double precision
        END) AS discarded_amount_total,
    sum(
        CASE
            WHEN "ExpenseEntry".line_code = 'calves'::text THEN COALESCE("ExpenseEntry".quantity, 0::double precision)
            ELSE 0::double precision
        END) AS calves_quantity,
    sum(
        CASE
            WHEN "ExpenseEntry".line_code = 'calves'::text THEN COALESCE("ExpenseEntry".amount_total, 0::double precision)
            ELSE 0::double precision
        END) AS calves_amount_total,
    sum(
        CASE
            WHEN "ExpenseEntry".line_code = 'family-labor'::text THEN COALESCE("ExpenseEntry".quantity, 0::double precision)
            ELSE 0::double precision
        END) AS family_labor_quantity,
    sum(
        CASE
            WHEN "ExpenseEntry".line_code = 'family-labor'::text THEN COALESCE("ExpenseEntry".amount_total, 0::double precision)
            ELSE 0::double precision
        END) AS family_labor_amount_total
    
    FROM "ExpenseEntry"
    WHERE "ExpenseEntry".is_active = true AND "ExpenseEntry".tab = 'OWN_MILK'::"ExpenseTab"
    GROUP BY "ExpenseEntry".id_property, (date_trunc('month'::text, "ExpenseEntry".reference_month))
    ORDER BY "ExpenseEntry".id_property, (date_trunc('month'::text, "ExpenseEntry".reference_month)::date);