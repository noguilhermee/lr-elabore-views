/*
VIEW: analytics_mart.vw_labor

Finalidade:
Consolida mensalmente os custos e as quantidades de mão de obra familiar e
contratada utilizados em cada propriedade.

Granularidade:
Uma linha por propriedade e mês (id_property + reference_month).

Fontes principais:
- analytics_int.vw_int_expense

Regras de negócio:
- Consome da view intermediária analytics_int.vw_int_expense (já filtrada por is_active = true e sem ESTOCAR).
- Combina lançamentos das abas LABOR e OWN_MILK.
- Agrupa diferentes tipos de trabalhadores contratados em um único indicador.
- Indicadores: despesa e quantidade de mão de obra familiar, despesa e
  quantidade de mão de obra contratada.
- Os valores de despesas incorporam lançamentos da aba OWN_MILK, enquanto
  as quantidades são calculadas principalmente a partir da aba LABOR.

Forma de consulta:
SELECT * FROM analytics_mart.vw_labor;
*/

SELECT eb.id_property,
    eb.reference_month,
    sum(
        CASE
            WHEN eb.tab = 'LABOR'::"ExpenseTab" AND eb.line_code = 'familiar'::text OR eb.tab = 'OWN_MILK'::"ExpenseTab" AND eb.line_code = 'family-labor'::text THEN eb.amount_total
            ELSE 0::double precision
        END) AS family_labor_expenses,
    sum(
        CASE
            WHEN eb.tab = 'LABOR'::"ExpenseTab" AND eb.line_code = 'familiar'::text THEN COALESCE(eb.quantity, 0::double precision)
            ELSE 0::double precision
        END) AS family_labor_quantity,
    sum(
        CASE
            WHEN eb.tab = 'LABOR'::"ExpenseTab" AND (eb.line_code = ANY (ARRAY['hired-general'::text, 'hired-milker'::text, 'hired-relief'::text, 'hired-tractor'::text, 'labor-charges'::text, 'labor-others'::text]))
              OR eb.tab = 'OWN_MILK'::"ExpenseTab" AND eb.line_code = 'hired-labor'::text THEN eb.amount_total
            ELSE 0::double precision
        END) AS hired_labor_expenses,
    sum(
        CASE
            WHEN eb.tab = 'LABOR'::"ExpenseTab" AND (eb.line_code = ANY (ARRAY['hired-general'::text, 'hired-milker'::text, 'hired-relief'::text, 'hired-tractor'::text, 'labor-charges'::text, 'labor-others'::text])) THEN COALESCE(eb.quantity, 0::double precision)
            ELSE 0::double precision
        END) AS hired_labor_quantity

    FROM analytics_int.vw_int_expense eb
    WHERE eb.tab = ANY (ARRAY['LABOR'::"ExpenseTab", 'OWN_MILK'::"ExpenseTab"])
    GROUP BY eb.id_property, eb.reference_month
    ORDER BY eb.id_property, eb.reference_month;