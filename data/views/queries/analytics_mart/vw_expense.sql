/*
VIEW: analytics_mart.vw_expense

Finalidade:
Consolida mensalmente as despesas gerais de cada propriedade, distribuindo
os valores lançados em diferentes categorias econômicas e operacionais.

Granularidade:
Uma linha por propriedade e mês.

Principais grupos consolidados:
- Despesas gerais e administração
- Arrendamento e assistência técnica
- Compra de animais e terras
- Consertos e reparos
- Juros, impostos e taxas
- Hormônios, medicamentos e vacinas
- Reprodução e sucedâneo
- Material de ordenha
- Leite destinado aos bezerros
- Energia e combustíveis

Regras principais:
- Considera somente lançamentos ativos.
- Exclui despesas da aba FEEDING.
- Exclui operações de armazenamento identificadas como ESTOCAR.
- Soma os valores de acordo com a aba e o código de cada lançamento.

Forma de consulta:
SELECT *
FROM analytics_mart.vw_expense;

*/

SELECT "ExpenseEntry".id_property,
    date_trunc('month'::text, "ExpenseEntry".reference_month)::date AS reference_month,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'HEALTH_OTHER'::"ExpenseTab" AND ("ExpenseEntry".line_code = ANY (ARRAY['acessorios-despesas-geral'::text, 'Acessórios e despesas em geral'::text])) THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS general_expenses,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'HEALTH_OTHER'::"ExpenseTab" AND "ExpenseEntry".line_code = 'adiantamento'::text THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS advance_payment,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'HEALTH_OTHER'::"ExpenseTab" AND ("ExpenseEntry".line_code = ANY (ARRAY['administracao'::text, 'Administração'::text])) THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS administration,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'HEALTH_OTHER'::"ExpenseTab" AND ("ExpenseEntry".line_code = ANY (ARRAY['arrendamento'::text, 'Arrendamento'::text])) THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS land_lease,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'HEALTH_OTHER'::"ExpenseTab" AND ("ExpenseEntry".line_code = ANY (ARRAY['assistencia-tecnica'::text, 'Assistência técnica'::text])) THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS technical_assistance,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'HEALTH_OTHER'::"ExpenseTab" AND "ExpenseEntry".line_code = 'compra-animais'::text THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS animal_purchase,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'HEALTH_OTHER'::"ExpenseTab" AND "ExpenseEntry".line_code = 'compra-terras'::text THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS land_purchase,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'HEALTH_OTHER'::"ExpenseTab" AND ("ExpenseEntry".line_code = ANY (ARRAY['consertos-reparos'::text, 'Consertos e reparos'::text])) THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS repairs,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'HEALTH_OTHER'::"ExpenseTab" AND "ExpenseEntry".line_code = 'emprestimos-juros-pagos'::text THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS loan_interest,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'HEALTH_OTHER'::"ExpenseTab" AND ("ExpenseEntry".line_code = ANY (ARRAY['hormonios'::text, 'Hormônios'::text])) THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS hormones,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'HEALTH_OTHER'::"ExpenseTab" AND ("ExpenseEntry".line_code = ANY (ARRAY['impostos-taxas'::text, 'Impostos e taxas'::text])) THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS taxes_fees,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'HEALTH_OTHER'::"ExpenseTab" AND ("ExpenseEntry".line_code = ANY (ARRAY['medicamentos-vacinas'::text, 'Medicamentos e vacinas'::text])) THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS medicines_vaccines,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'HEALTH_OTHER'::"ExpenseTab" AND ("ExpenseEntry".line_code = ANY (ARRAY['reposicao-cama'::text, 'Reposição da cama'::text])) THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS bedding_replacement,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'HEALTH_OTHER'::"ExpenseTab" AND ("ExpenseEntry".line_code = ANY (ARRAY['reproducao'::text, 'Reprodução'::text])) THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS reproduction,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'HEALTH_OTHER'::"ExpenseTab" AND ("ExpenseEntry".line_code = ANY (ARRAY['sucedaneo'::text, 'Sucedâneo'::text])) THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS milk_replacer,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'HEALTH_OTHER'::"ExpenseTab" AND ("ExpenseEntry".line_code = ANY (ARRAY['material-ordenha-qualidade-leite'::text, 'Material de ordenha e qualidade do leite'::text])) THEN "ExpenseEntry".amount_total
            WHEN "ExpenseEntry".tab = 'OWN_MILK'::"ExpenseTab" AND "ExpenseEntry".line_code = 'discarded'::text THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS milking_material,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'OWN_MILK'::"ExpenseTab" AND "ExpenseEntry".line_code = 'calves'::text THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS milk_calves,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'ENERGY_FUEL'::"ExpenseTab" AND ("ExpenseEntry".line_code = ANY (ARRAY['electricity'::text, 'solar'::text])) THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS energy,
    sum(
        CASE
            WHEN "ExpenseEntry".tab = 'ENERGY_FUEL'::"ExpenseTab" AND ("ExpenseEntry".line_code = ANY (ARRAY['diesel'::text, 'ethanol'::text, 'gasoline'::text])) THEN "ExpenseEntry".amount_total
            ELSE 0::double precision
        END) AS fuel
    
    FROM "ExpenseEntry"
    WHERE "ExpenseEntry".is_active = true AND "ExpenseEntry".tab <> 'FEEDING'::"ExpenseTab" AND COALESCE("ExpenseEntry".operation::text, ''::text) <> 'ESTOCAR'::text
    GROUP BY "ExpenseEntry".id_property, (date_trunc('month'::text, "ExpenseEntry".reference_month))
    ORDER BY "ExpenseEntry".id_property, (date_trunc('month'::text, "ExpenseEntry".reference_month)::date);