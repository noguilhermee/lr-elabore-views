/*
VIEW: analytics_mart.vw_labor

Finalidade:
Consolida mensalmente os custos e as quantidades de mão de obra familiar e
contratada utilizados em cada propriedade.

Granularidade:
Uma linha por propriedade e mês (id_property + reference_month).

Fontes principais:
- ExpenseEntry

Regras de negócio:
- Combina lançamentos das abas LABOR e OWN_MILK.
- Considera somente lançamentos ativos (is_active = true).
- Exclui operações de armazenamento (ESTOCAR).
- Agrupa diferentes tipos de trabalhadores contratados em um único indicador.
- Indicadores: despesa e quantidade de mão de obra familiar, despesa e
  quantidade de mão de obra contratada.
- Os valores de despesas incorporam lançamentos da aba OWN_MILK, enquanto
  as quantidades são calculadas principalmente a partir da aba LABOR.

Forma de consulta:
SELECT * FROM analytics_mart.vw_labor;
*/

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