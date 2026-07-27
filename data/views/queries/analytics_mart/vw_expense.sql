/*
VIEW: analytics_mart.vw_expense

Finalidade:
Consolida mensalmente as despesas gerais de cada propriedade, distribuindo
os valores lançados em diferentes categorias econômicas e operacionais.

Granularidade:
Uma linha por propriedade e mês (id_property + reference_month).

Fontes principais:
- analytics_int.vw_int_expense_base

Regras de negócio:
- Consome da view intermediária analytics_int.vw_int_expense_base (já filtrada por is_active = true e sem ESTOCAR).
- Exclui despesas da aba FEEDING.
- Soma os valores de acordo com a aba (tab) e o código de cada lançamento (line_code).
- Grupos consolidados: despesas gerais, adiantamento, administração, arrendamento,
  assistência técnica, compra de animais, compra de terras, consertos e reparos,
  juros pagos, hormônios, impostos e taxas, medicamentos e vacinas, reposição
  de cama, reprodução, sucedâneo, material de ordenha, leite para bezerros,
  energia e combustíveis.

Forma de consulta:
SELECT * FROM analytics_mart.vw_expense;
*/

SELECT eb.id_property,
    eb.reference_month,
    sum(
        CASE
            WHEN eb.tab = 'HEALTH_OTHER'::"ExpenseTab" AND (eb.line_code = ANY (ARRAY['acessorios-despesas-geral'::text, 'Acessórios e despesas em geral'::text])) THEN eb.amount_total
            ELSE 0::double precision
        END) AS general_expenses,
    sum(
        CASE
            WHEN eb.tab = 'HEALTH_OTHER'::"ExpenseTab" AND eb.line_code = 'adiantamento'::text THEN eb.amount_total
            ELSE 0::double precision
        END) AS advance_payment,
    sum(
        CASE
            WHEN eb.tab = 'HEALTH_OTHER'::"ExpenseTab" AND (eb.line_code = ANY (ARRAY['administracao'::text, 'Administração'::text])) THEN eb.amount_total
            ELSE 0::double precision
        END) AS administration,
    sum(
        CASE
            WHEN eb.tab = 'HEALTH_OTHER'::"ExpenseTab" AND (eb.line_code = ANY (ARRAY['arrendamento'::text, 'Arrendamento'::text])) THEN eb.amount_total
            ELSE 0::double precision
        END) AS land_lease,
    sum(
        CASE
            WHEN eb.tab = 'HEALTH_OTHER'::"ExpenseTab" AND (eb.line_code = ANY (ARRAY['assistencia-tecnica'::text, 'Assistência técnica'::text])) THEN eb.amount_total
            ELSE 0::double precision
        END) AS technical_assistance,
    sum(
        CASE
            WHEN eb.tab = 'HEALTH_OTHER'::"ExpenseTab" AND eb.line_code = 'compra-animais'::text THEN eb.amount_total
            ELSE 0::double precision
        END) AS animal_purchase,
    sum(
        CASE
            WHEN eb.tab = 'HEALTH_OTHER'::"ExpenseTab" AND eb.line_code = 'compra-terras'::text THEN eb.amount_total
            ELSE 0::double precision
        END) AS land_purchase,
    sum(
        CASE
            WHEN eb.tab = 'HEALTH_OTHER'::"ExpenseTab" AND (eb.line_code = ANY (ARRAY['consertos-reparos'::text, 'Consertos e reparos'::text])) THEN eb.amount_total
            ELSE 0::double precision
        END) AS repairs,
    sum(
        CASE
            WHEN eb.tab = 'HEALTH_OTHER'::"ExpenseTab" AND eb.line_code = 'emprestimos-juros-pagos'::text THEN eb.amount_total
            ELSE 0::double precision
        END) AS loan_interest,
    sum(
        CASE
            WHEN eb.tab = 'HEALTH_OTHER'::"ExpenseTab" AND (eb.line_code = ANY (ARRAY['hormonios'::text, 'Hormônios'::text])) THEN eb.amount_total
            ELSE 0::double precision
        END) AS hormones,
    sum(
        CASE
            WHEN eb.tab = 'HEALTH_OTHER'::"ExpenseTab" AND (eb.line_code = ANY (ARRAY['impostos-taxas'::text, 'Impostos e taxas'::text])) THEN eb.amount_total
            ELSE 0::double precision
        END) AS taxes_fees,
    sum(
        CASE
            WHEN eb.tab = 'HEALTH_OTHER'::"ExpenseTab" AND (eb.line_code = ANY (ARRAY['medicamentos-vacinas'::text, 'Medicamentos e vacinas'::text])) THEN eb.amount_total
            ELSE 0::double precision
        END) AS medicines_vaccines,
    sum(
        CASE
            WHEN eb.tab = 'HEALTH_OTHER'::"ExpenseTab" AND (eb.line_code = ANY (ARRAY['reposicao-cama'::text, 'Reposição da cama'::text])) THEN eb.amount_total
            ELSE 0::double precision
        END) AS bedding_replacement,
    sum(
        CASE
            WHEN eb.tab = 'HEALTH_OTHER'::"ExpenseTab" AND (eb.line_code = ANY (ARRAY['reproducao'::text, 'Reprodução'::text])) THEN eb.amount_total
            ELSE 0::double precision
        END) AS reproduction,
    sum(
        CASE
            WHEN eb.tab = 'HEALTH_OTHER'::"ExpenseTab" AND (eb.line_code = ANY (ARRAY['sucedaneo'::text, 'Sucedâneo'::text])) THEN eb.amount_total
            ELSE 0::double precision
        END) AS milk_replacer,
    sum(
        CASE
            WHEN eb.tab = 'HEALTH_OTHER'::"ExpenseTab" AND (eb.line_code = ANY (ARRAY['material-ordenha-qualidade-leite'::text, 'Material de ordenha e qualidade do leite'::text])) THEN eb.amount_total
            WHEN eb.tab = 'OWN_MILK'::"ExpenseTab" AND eb.line_code = 'discarded'::text THEN eb.amount_total
            ELSE 0::double precision
        END) AS milking_material,
    sum(
        CASE
            WHEN eb.tab = 'OWN_MILK'::"ExpenseTab" AND eb.line_code = 'calves'::text THEN eb.amount_total
            ELSE 0::double precision
        END) AS milk_calves,
    sum(
        CASE
            WHEN eb.tab = 'ENERGY_FUEL'::"ExpenseTab" AND (eb.line_code = ANY (ARRAY['electricity'::text, 'solar'::text])) THEN eb.amount_total
            ELSE 0::double precision
        END) AS energy,
    sum(
        CASE
            WHEN eb.tab = 'ENERGY_FUEL'::"ExpenseTab" AND (eb.line_code = ANY (ARRAY['diesel'::text, 'ethanol'::text, 'gasoline'::text])) THEN eb.amount_total
            ELSE 0::double precision
        END) AS fuel
    
    FROM analytics_int.vw_int_expense_base eb
    WHERE eb.tab <> 'FEEDING'::"ExpenseTab"
    GROUP BY eb.id_property, eb.reference_month
    ORDER BY eb.id_property, eb.reference_month;