/*
VIEW: analytics_mart.vw_revenue

Finalidade:
Consolida mensalmente as receitas das propriedades, separando a venda de leite,
derivados, animais, alimentos e outras fontes de entrada financeira.

Granularidade:
Uma linha por propriedade e mês (id_property + reference_month).

Fontes principais:
- analytics_int.vw_int_revenue_base

Regras de negócio:
- Consome da view intermediária analytics_int.vw_int_revenue_base (já filtrada por is_active = true e com JSONs extraídos).
- Soma as receitas conforme o tipo do lançamento (RevenueType).
- Utiliza MAX (não média ponderada) para milk_unit_price, CCS, CPP, gordura e proteína.
- Utiliza MAX (não soma) para volume de derivados.
- Indicadores principais: receita e volume de leite vendido, preço unitário,
  CCS, CPP, gordura, proteína, receita de derivados, empréstimos recebidos,
  venda de animais, outras receitas, bonificações, penalizações, venda de
  volumosos e concentrados, divisão de sobras.

Forma de consulta:
SELECT * FROM analytics_mart.vw_revenue;
*/

SELECT rb.id_property,
    rb.reference_month,
    sum(
        CASE
            WHEN rb.type = 'MILK_SOLD'::"RevenueType" THEN rb.amount_total
            ELSE 0::double precision
        END) AS milk_sold_revenue,
    sum(
        CASE
            WHEN rb.type = 'MILK_SOLD'::"RevenueType" THEN COALESCE(rb.payload_quantity, 0::numeric)
            ELSE 0::numeric
        END) AS milk_volume_sold,
    max(
        CASE
            WHEN rb.type = 'MILK_SOLD'::"RevenueType" THEN rb.payload_unit_price
            ELSE NULL::numeric
        END) AS milk_unit_price,
    max(
        CASE
            WHEN rb.type = 'MILK_SOLD'::"RevenueType" THEN rb.ccs
            ELSE NULL::numeric
        END) AS ccs,
    max(
        CASE
            WHEN rb.type = 'MILK_SOLD'::"RevenueType" THEN rb.cpp
            ELSE NULL::numeric
        END) AS cpp,
    max(
        CASE
            WHEN rb.type = 'MILK_SOLD'::"RevenueType" THEN rb.fat
            ELSE NULL::numeric
        END) AS fat,
    max(
        CASE
            WHEN rb.type = 'MILK_SOLD'::"RevenueType" THEN rb.protein
            ELSE NULL::numeric
        END) AS protein,
    max(
        CASE
            WHEN rb.type = 'MILK_DERIVATIVES'::"RevenueType" THEN rb.payload_unit_price
            ELSE NULL::numeric
        END) AS unit_price_derivative,
    max(
        CASE
            WHEN rb.type = 'MILK_DERIVATIVES'::"RevenueType" THEN rb.payload_quantity
            ELSE NULL::numeric
        END) AS milk_volume_derivatives,
    sum(
        CASE
            WHEN rb.type = 'MILK_DERIVATIVES'::"RevenueType" THEN rb.amount_total
            ELSE 0::double precision
        END) AS milk_derivatives_revenue,
    sum(
        CASE
            WHEN rb.type = 'RECEIVED_LOANS'::"RevenueType" THEN rb.amount_total
            ELSE 0::double precision
        END) AS received_loans,
    sum(
        CASE
            WHEN rb.type = 'ANIMAL_SALE'::"RevenueType" THEN rb.amount_total
            ELSE 0::double precision
        END) AS animal_sale,
    sum(
        CASE
            WHEN rb.type = 'OTHER_REVENUES'::"RevenueType" THEN rb.amount_total
            ELSE 0::double precision
        END) AS other_revenues,
    sum(
        CASE
            WHEN rb.type = 'PRICE_BONUS'::"RevenueType" THEN rb.amount_total
            ELSE 0::double precision
        END) AS price_bonus,
    sum(
        CASE
            WHEN rb.type = 'PRICE_PENALTY'::"RevenueType" THEN rb.amount_total
            ELSE 0::double precision
        END) AS price_penalty,
    sum(
        CASE
            WHEN rb.type = 'VOLUMOUS_SOLD'::"RevenueType" THEN rb.amount_total
            ELSE 0::double precision
        END) AS voluminous_sold,
    sum(
        CASE
            WHEN rb.type = 'CONCENTRATED_SOLD'::"RevenueType" THEN rb.amount_total
            ELSE 0::double precision
        END) AS concentrated_sold,
    sum(
        CASE
            WHEN rb.type = 'SURPLUS_DIVISION'::"RevenueType" THEN rb.amount_total
            ELSE 0::double precision
        END) AS surplus_division
    
    FROM analytics_int.vw_int_revenue_base rb
    GROUP BY rb.id_property, rb.reference_month
    ORDER BY rb.id_property, rb.reference_month;