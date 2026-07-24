/*
VIEW: analytics_mart.vw_feeding

Finalidade:
Consolida mensalmente as despesas e quantidades de alimentos comprados e
consumidos pelas propriedades, separando volumosos, concentrados e minerais.

Granularidade:
Uma linha por propriedade, mês e unidade padronizada.

Indicadores consolidados:
- Quantidade comprada
- Quantidade consumida
- Valor total
- Separação entre volumoso, concentrado e mineral

Regras principais:
- Considera somente lançamentos de despesas ativos.
- Exclui operações de armazenamento identificadas como ESTOCAR.
- Converte toneladas para quilogramas utilizando o fator 1.000.
- Converte a unidade específica de saca para quilogramas utilizando o fator 25.
- Mantém outras unidades conforme informadas, em letras minúsculas.

Observação:
Como a unidade faz parte do agrupamento, uma propriedade pode possuir mais
de uma linha no mesmo mês quando existirem unidades diferentes.

Forma de consulta:
SELECT *
FROM analytics_mart.vw_feeding;
*/

SELECT f.id_property,
    date_trunc('month'::text, e.reference_month)::date AS reference_month,
        CASE
            WHEN lower(TRIM(BOTH FROM e.unit)) = ANY (ARRAY['ton'::text, 'feeding-unit-saca-1778245226249'::text]) THEN 'kg'::text
            ELSE lower(TRIM(BOTH FROM e.unit))
        END AS unit,
    sum(
        CASE
            WHEN f.category_code = 'VOLUMOSO'::text THEN f.purchased_quantity *
            CASE
                WHEN lower(TRIM(BOTH FROM e.unit)) = 'ton'::text THEN 1000
                WHEN lower(TRIM(BOTH FROM e.unit)) = 'feeding-unit-saca-1778245226249'::text THEN 25
                ELSE 1
            END::double precision
            ELSE 0::double precision
        END) AS voluminous_purchased_quantity,
    sum(
        CASE
            WHEN f.category_code = 'VOLUMOSO'::text THEN f.consumed_quantity *
            CASE
                WHEN lower(TRIM(BOTH FROM e.unit)) = 'ton'::text THEN 1000
                WHEN lower(TRIM(BOTH FROM e.unit)) = 'feeding-unit-saca-1778245226249'::text THEN 25
                ELSE 1
            END::double precision
            ELSE 0::double precision
        END) AS voluminous_consumed_quantity,
    sum(
        CASE
            WHEN f.category_code = 'VOLUMOSO'::text THEN e.amount_total
            ELSE 0::double precision
        END) AS voluminous_amount_total,
    sum(
        CASE
            WHEN f.category_code = 'CONCENTRADO'::text THEN f.purchased_quantity *
            CASE
                WHEN lower(TRIM(BOTH FROM e.unit)) = 'ton'::text THEN 1000
                WHEN lower(TRIM(BOTH FROM e.unit)) = 'feeding-unit-saca-1778245226249'::text THEN 25
                ELSE 1
            END::double precision
            ELSE 0::double precision
        END) AS concentrate_purchased_quantity,
    sum(
        CASE
            WHEN f.category_code = 'CONCENTRADO'::text THEN f.consumed_quantity *
            CASE
                WHEN lower(TRIM(BOTH FROM e.unit)) = 'ton'::text THEN 1000
                WHEN lower(TRIM(BOTH FROM e.unit)) = 'feeding-unit-saca-1778245226249'::text THEN 25
                ELSE 1
            END::double precision
            ELSE 0::double precision
        END) AS concentrate_consumed_quantity,
    sum(
        CASE
            WHEN f.category_code = 'CONCENTRADO'::text THEN e.amount_total
            ELSE 0::double precision
        END) AS concentrate_amount_total,
    sum(
        CASE
            WHEN f.category_code = 'MINERAIS'::text THEN f.purchased_quantity *
            CASE
                WHEN lower(TRIM(BOTH FROM e.unit)) = 'ton'::text THEN 1000
                WHEN lower(TRIM(BOTH FROM e.unit)) = 'feeding-unit-saca-1778245226249'::text THEN 25
                ELSE 1
            END::double precision
            ELSE 0::double precision
        END) AS mineral_purchased_quantity,
    sum(
        CASE
            WHEN f.category_code = 'MINERAIS'::text THEN f.consumed_quantity *
            CASE
                WHEN lower(TRIM(BOTH FROM e.unit)) = 'ton'::text THEN 1000
                WHEN lower(TRIM(BOTH FROM e.unit)) = 'feeding-unit-saca-1778245226249'::text THEN 25
                ELSE 1
            END::double precision
            ELSE 0::double precision
        END) AS mineral_consumed_quantity,
    sum(
        CASE
            WHEN f.category_code = 'MINERAIS'::text THEN e.amount_total
            ELSE 0::double precision
        END) AS mineral_amount_total
    
    FROM "FeedingExpenseEntry" f
        LEFT JOIN "ExpenseEntry" e ON f.id_expense_entry = e.id_expense_entry
    WHERE e.is_active = true AND f.operation <> 'ESTOCAR'::"ExpenseOperation"
    GROUP BY f.id_property, (date_trunc('month'::text, e.reference_month)), (
        CASE
            WHEN lower(TRIM(BOTH FROM e.unit)) = ANY (ARRAY['ton'::text, 'feeding-unit-saca-1778245226249'::text]) THEN 'kg'::text
            ELSE lower(TRIM(BOTH FROM e.unit))
        END)
    ORDER BY f.id_property, (date_trunc('month'::text, e.reference_month)::date), (
        CASE
            WHEN lower(TRIM(BOTH FROM e.unit)) = ANY (ARRAY['ton'::text, 'feeding-unit-saca-1778245226249'::text]) THEN 'kg'::text
            ELSE lower(TRIM(BOTH FROM e.unit))
        END);