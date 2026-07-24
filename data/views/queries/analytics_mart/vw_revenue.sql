/*
VIEW: analytics_mart.vw_revenue

Finalidade:
Consolida mensalmente as receitas das propriedades, separando a venda de leite,
derivados, animais, alimentos e outras fontes de entrada financeira.

Granularidade:
Uma linha por propriedade e mês.

Indicadores principais:
- Receita e volume de leite vendido
- Preço unitário do leite
- CCS, CPP, gordura e proteína
- Receita, volume e preço dos derivados
- Empréstimos recebidos
- Venda de animais
- Outras receitas
- Bonificações e penalizações de preço
- Venda de volumosos e concentrados
- Divisão de sobras

Regras principais:
- Considera somente lançamentos ativos.
- Soma as receitas conforme o tipo do lançamento.
- Extrai volumes e preços do campo JSON payload.
- Extrai os indicadores de qualidade do campo JSON quality_indicators.
- Utiliza o maior valor mensal para preço e indicadores de qualidade.

Observação:
Os campos milk_unit_price, CCS, CPP, gordura e proteína utilizam MAX, e não
média ponderada. O volume de derivados também utiliza MAX, e não soma.

Forma de consulta:
SELECT *
FROM analytics_mart.vw_revenue;
*/

SELECT "RevenueEntry".id_property,
    date_trunc('month'::text, "RevenueEntry".reference_month)::date AS reference_month,
    sum(
        CASE
            WHEN "RevenueEntry".type = 'MILK_SOLD'::"RevenueType" THEN "RevenueEntry".amount_total
            ELSE 0::double precision
        END) AS milk_sold_revenue,
    sum(
        CASE
            WHEN "RevenueEntry".type = 'MILK_SOLD'::"RevenueType" THEN COALESCE(("RevenueEntry".payload ->> 'quantity'::text)::numeric, 0::numeric)
            ELSE 0::numeric
        END) AS milk_volume_sold,
    max(
        CASE
            WHEN "RevenueEntry".type = 'MILK_SOLD'::"RevenueType" THEN ("RevenueEntry".payload ->> 'unit_price'::text)::numeric
            ELSE NULL::numeric
        END) AS milk_unit_price,
    max(
        CASE
            WHEN "RevenueEntry".type = 'MILK_SOLD'::"RevenueType" THEN ("RevenueEntry".quality_indicators ->> 'ccs'::text)::numeric
            ELSE NULL::numeric
        END) AS ccs,
    max(
        CASE
            WHEN "RevenueEntry".type = 'MILK_SOLD'::"RevenueType" THEN ("RevenueEntry".quality_indicators ->> 'cpp'::text)::numeric
            ELSE NULL::numeric
        END) AS cpp,
    max(
        CASE
            WHEN "RevenueEntry".type = 'MILK_SOLD'::"RevenueType" THEN ("RevenueEntry".quality_indicators ->> 'fat'::text)::numeric
            ELSE NULL::numeric
        END) AS fat,
    max(
        CASE
            WHEN "RevenueEntry".type = 'MILK_SOLD'::"RevenueType" THEN ("RevenueEntry".quality_indicators ->> 'protein'::text)::numeric
            ELSE NULL::numeric
        END) AS protein,
    max(
        CASE
            WHEN "RevenueEntry".type = 'MILK_DERIVATIVES'::"RevenueType" THEN ("RevenueEntry".payload ->> 'unit_price'::text)::numeric
            ELSE NULL::numeric
        END) AS unit_price_derivative,
    max(
        CASE
            WHEN "RevenueEntry".type = 'MILK_DERIVATIVES'::"RevenueType" THEN ("RevenueEntry".payload ->> 'quantity'::text)::numeric
            ELSE NULL::numeric
        END) AS milk_volume_derivatives,
    sum(
        CASE
            WHEN "RevenueEntry".type = 'MILK_DERIVATIVES'::"RevenueType" THEN "RevenueEntry".amount_total
            ELSE 0::double precision
        END) AS milk_derivatives_revenue,
    sum(
        CASE
            WHEN "RevenueEntry".type = 'RECEIVED_LOANS'::"RevenueType" THEN "RevenueEntry".amount_total
            ELSE 0::double precision
        END) AS received_loans,
    sum(
        CASE
            WHEN "RevenueEntry".type = 'ANIMAL_SALE'::"RevenueType" THEN "RevenueEntry".amount_total
            ELSE 0::double precision
        END) AS animal_sale,
    sum(
        CASE
            WHEN "RevenueEntry".type = 'OTHER_REVENUES'::"RevenueType" THEN "RevenueEntry".amount_total
            ELSE 0::double precision
        END) AS other_revenues,
    sum(
        CASE
            WHEN "RevenueEntry".type = 'PRICE_BONUS'::"RevenueType" THEN "RevenueEntry".amount_total
            ELSE 0::double precision
        END) AS price_bonus,
    sum(
        CASE
            WHEN "RevenueEntry".type = 'PRICE_PENALTY'::"RevenueType" THEN "RevenueEntry".amount_total
            ELSE 0::double precision
        END) AS price_penalty,
    sum(
        CASE
            WHEN "RevenueEntry".type = 'VOLUMOUS_SOLD'::"RevenueType" THEN "RevenueEntry".amount_total
            ELSE 0::double precision
        END) AS voluminous_sold,
    sum(
        CASE
            WHEN "RevenueEntry".type = 'CONCENTRATED_SOLD'::"RevenueType" THEN "RevenueEntry".amount_total
            ELSE 0::double precision
        END) AS concentrated_sold,
    sum(
        CASE
            WHEN "RevenueEntry".type = 'SURPLUS_DIVISION'::"RevenueType" THEN "RevenueEntry".amount_total
            ELSE 0::double precision
        END) AS surplus_division
    
    FROM "RevenueEntry"
    WHERE "RevenueEntry".is_active = true
    GROUP BY "RevenueEntry".id_property, (date_trunc('month'::text, "RevenueEntry".reference_month));