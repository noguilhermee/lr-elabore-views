/*
VIEW: analytics_int.vw_int_revenue

Finalidade:
Camada intermediária de receitas. Filtra lançamentos ativos, normaliza a data
de referência para o primeiro dia do mês, extrai os campos JSON e projeta
estritamente as colunas consumidas por vw_revenue.

Granularidade:
Uma linha por lançamento de receita (id_revenue_entry).

Fontes principais:
- public.RevenueEntry

Regras de negócio:
- Considera somente lançamentos ativos (is_active = true).
- Normaliza a competência para o primeiro dia do mês como tipo DATE.
- Extrai do campo payload: quantidade e preço unitário.
- Extrai do campo quality_indicators: ccs, cpp, fat e protein.
- Projeta estritamente as colunas consumidas por vw_revenue.

Forma de consulta:
SELECT * FROM analytics_int.vw_int_revenue;
*/

SELECT r.id_property,
    date_trunc('month'::text, r.reference_month)::date AS reference_month,
    r.type,
    r.amount_total,
    (r.payload ->> 'quantity'::text)::numeric AS payload_quantity,
    (r.payload ->> 'unit_price'::text)::numeric AS payload_unit_price,
    (r.quality_indicators ->> 'ccs'::text)::numeric AS ccs,
    (r.quality_indicators ->> 'cpp'::text)::numeric AS cpp,
    (r.quality_indicators ->> 'fat'::text)::numeric AS fat,
    (r.quality_indicators ->> 'protein'::text)::numeric AS protein
FROM "RevenueEntry" r
WHERE r.is_active = true;
