SELECT "ExpenseEntry".id_property,
    date_trunc('month'::text, "ExpenseEntry".reference_month)::date AS reference_month,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'LABOR'::"ExpenseTab" AND "ExpenseEntry".line_code = 'familiar'::text OR "ExpenseEntry".tab = 'OWN_MILK'::"ExpenseTab" AND "ExpenseEntry".line_code = 'family-labor'::text THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS family_labor_expenses,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'LABOR'::"ExpenseTab" AND "ExpenseEntry".line_code = 'familiar'::text THEN COALESCE("ExpenseEntry".quantity, 0::double precision)
            ELSE 0::double precision
        END) AS family_labor_quantity,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'LABOR'::"ExpenseTab" AND ("ExpenseEntry".line_code = ANY (ARRAY['hired-general'::text, 'hired-milker'::text, 'hired-relief'::text, 'hired-tractor'::text, 'labor-charges'::text, 'labor-others'::text])) OR "ExpenseEntry".tab = 'OWN_MILK'::"ExpenseTab" AND "ExpenseEntry".line_code = 'hired-labor'::text THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS hired_labor_expenses,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'LABOR'::"ExpenseTab" AND ("ExpenseEntry".line_code = ANY (ARRAY['hired-general'::text, 'hired-milker'::text, 'hired-relief'::text, 'hired-tractor'::text, 'labor-charges'::text, 'labor-others'::text])) THEN COALESCE("ExpenseEntry".quantity, 0::double precision)
            ELSE 0::double precision
        END) AS hired_labor_quantity
    
    FROM "ExpenseEntry"
    WHERE "ExpenseEntry".is_active = true AND ("ExpenseEntry".tab = ANY (ARRAY['LABOR'::"ExpenseTab", 'OWN_MILK'::"ExpenseTab"])) AND COALESCE("ExpenseEntry".operation::text, ''::text) <> 'ESTOCAR'::text
    GROUP BY "ExpenseEntry".id_property, (date_trunc('month'::text, "ExpenseEntry".reference_month))
    ORDER BY "ExpenseEntry".id_property, (date_trunc('month'::text, "ExpenseEntry".reference_month)::date);