/*
VIEW: analytics_int.vw_int_expense_base

Finalidade:
Camada intermediária de despesas operacionais. Filtra lançamentos ativos,
exclui operações de armazenamento (ESTOCAR) e projeta apenas as colunas
necessárias para o consumo das views analíticas.

Granularidade:
Uma linha por lançamento de despesa (id_expense_entry).

Fontes principais:
- public.ExpenseEntry

Regras de negócio:
- Considera somente lançamentos ativos (is_active = true).
- Exclui operações de armazenamento identificadas como ESTOCAR.
- Normaliza a competência para o primeiro dia do mês como tipo DATE.
- Projeta estritamente as colunas consumidas por vw_expense, vw_labor e vw_own_milk.

Forma de consulta:
SELECT * FROM analytics_int.vw_int_expense_base;
*/

SELECT e.id_expense_entry,
    e.id_property,
    date_trunc('month'::text, e.reference_month)::date AS reference_month,
    e.tab,
    e.line_code,
    e.amount_total,
    e.quantity,
    e.unit_price
FROM "ExpenseEntry" e
WHERE e.is_active = true 
  AND COALESCE(e.operation::text, ''::text) <> 'ESTOCAR'::text;
