SELECT *
FROM analytics_mart.vw_expense
ORDER BY id_property, reference_month;



SELECT
    id_property,
    DATE_TRUNC('month', reference_month)::date AS reference_month,
    
    -- HEALTH_OTHER
    SUM(CASE WHEN tab = 'HEALTH_OTHER' AND line_code IN ('acessorios-despesas-geral', 'Acessórios e despesas em geral') THEN amount_total ELSE 0 END) AS general_expenses,
    SUM(CASE WHEN tab = 'HEALTH_OTHER' AND line_code = 'adiantamento' THEN amount_total ELSE 0 END) AS advance_payment,
    SUM(CASE WHEN tab = 'HEALTH_OTHER' AND line_code IN ('administracao', 'Administração') THEN amount_total ELSE 0 END) AS administration,
    SUM(CASE WHEN tab = 'HEALTH_OTHER' AND line_code IN ('arrendamento', 'Arrendamento') THEN amount_total ELSE 0 END) AS land_lease,
    SUM(CASE WHEN tab = 'HEALTH_OTHER' AND line_code IN ('assistencia-tecnica', 'Assistência técnica') THEN amount_total ELSE 0 END) AS technical_assistance,
    SUM(CASE WHEN tab = 'HEALTH_OTHER' AND line_code = 'compra-animais' THEN amount_total ELSE 0 END) AS animal_purchase,
    SUM(CASE WHEN tab = 'HEALTH_OTHER' AND line_code = 'compra-terras' THEN amount_total ELSE 0 END) AS land_purchase,
    SUM(CASE WHEN tab = 'HEALTH_OTHER' AND line_code IN ('consertos-reparos', 'Consertos e reparos') THEN amount_total ELSE 0 END) AS repairs,
    SUM(CASE WHEN tab = 'HEALTH_OTHER' AND line_code = 'emprestimos-juros-pagos' THEN amount_total ELSE 0 END) AS loan_interest,
    SUM(CASE WHEN tab = 'HEALTH_OTHER' AND line_code IN ('hormonios', 'Hormônios') THEN amount_total ELSE 0 END) AS hormones,
    SUM(CASE WHEN tab = 'HEALTH_OTHER' AND line_code IN ('impostos-taxas', 'Impostos e taxas') THEN amount_total ELSE 0 END) AS taxes_fees,
    SUM(CASE WHEN tab = 'HEALTH_OTHER' AND line_code IN ('medicamentos-vacinas', 'Medicamentos e vacinas') THEN amount_total ELSE 0 END) AS medicines_vaccines,
    SUM(CASE WHEN tab = 'HEALTH_OTHER' AND line_code IN ('reposicao-cama', 'Reposição da cama') THEN amount_total ELSE 0 END) AS bedding_replacement,
    SUM(CASE WHEN tab = 'HEALTH_OTHER' AND line_code IN ('reproducao', 'Reprodução') THEN amount_total ELSE 0 END) AS reproduction,
    SUM(CASE WHEN tab = 'HEALTH_OTHER' AND line_code IN ('sucedaneo', 'Sucedâneo') THEN amount_total ELSE 0 END) AS milk_replacer,
    SUM(CASE WHEN tab = 'HEALTH_OTHER' AND line_code IN ('material-ordenha-qualidade-leite', 'Material de ordenha e qualidade do leite') THEN amount_total WHEN tab = 'OWN_MILK' AND line_code = 'discarded' THEN amount_total ELSE 0 END) AS milking_material,
    
    -- OWN_MILK (leite próprio)
    SUM(CASE WHEN tab = 'OWN_MILK' AND line_code = 'calves' THEN amount_total ELSE 0 END) AS milk_calves, -- leite de berreza como aleitamento
    
    -- ENERGY_FUEL
    SUM(CASE WHEN tab = 'ENERGY_FUEL' AND line_code IN ('electricity', 'solar') THEN amount_total ELSE 0 END) AS energy,
    SUM(CASE WHEN tab = 'ENERGY_FUEL' AND line_code IN ('diesel', 'ethanol', 'gasoline') THEN amount_total ELSE 0 END) AS fuel
    

FROM "ExpenseEntry"

WHERE is_active = TRUE
  AND tab <> 'FEEDING'
  AND COALESCE(operation::text, '') <> 'ESTOCAR'

GROUP BY
    id_property,
    DATE_TRUNC('month', reference_month)

ORDER BY
    id_property,
    reference_month;