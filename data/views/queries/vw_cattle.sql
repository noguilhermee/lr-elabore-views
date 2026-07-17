CREATE OR REPLACE VIEW analytics_mart.vw_cattle AS
SELECT
    cp.id_property,
    MAKE_DATE(cp.year, cp.month, 1) AS reference_month,

    SUM(CASE WHEN cc.name = 'Vacas em lactação' THEN c.total_animals ELSE 0 END) AS lactating_cows,
    SUM(CASE WHEN cc.name = 'Vacas secas' THEN c.total_animals ELSE 0 END) AS dry_cows,
    SUM(CASE WHEN cc.name = 'Aleitamento' THEN c.total_animals ELSE 0 END) AS nursing,
    SUM(CASE WHEN cc.name = 'Recria' THEN c.total_animals ELSE 0 END) AS rearing,
    SUM(CASE WHEN cc.name = 'Macho' THEN c.total_animals ELSE 0 END) AS males,
    SUM(CASE WHEN cc.name = 'Outras categorias' THEN c.total_animals ELSE 0 END) AS other_categories,

    SUM(CASE WHEN cc.name IN ('Vacas em lactação', 'Vacas secas') THEN c.total_animals ELSE 0 END) AS total_cows,

    SUM(CASE WHEN cc."isActive" = TRUE THEN c.total_animals ELSE 0 END) AS total_cattle,

    -- valores monetários por categoria (value = preço unitário por cabeça) PRECISEI DELES PARA O ESTOQUE DE CAPITAL DE ANIMAIS
    SUM(CASE WHEN cc.name = 'Vacas em lactação' THEN c.value * c.total_animals ELSE 0 END) AS lactating_cows_value,
    SUM(CASE WHEN cc.name = 'Vacas secas' THEN c.value * c.total_animals ELSE 0 END) AS dry_cows_value,
    SUM(CASE WHEN cc.name = 'Aleitamento' THEN c.value * c.total_animals ELSE 0 END) AS nursing_value,
    SUM(CASE WHEN cc.name = 'Recria' THEN c.value * c.total_animals ELSE 0 END) AS rearing_value,
    SUM(CASE WHEN cc.name = 'Macho' THEN c.value * c.total_animals ELSE 0 END) AS males_value,
    SUM(CASE WHEN cc.name = 'Outras categorias' THEN c.value * c.total_animals ELSE 0 END) AS other_categories_value,

    SUM(CASE WHEN cc.name IN ('Vacas em lactação', 'Vacas secas') THEN c.value * c.total_animals ELSE 0 END) AS total_cows_value,

    SUM(CASE WHEN cc."isActive" = TRUE THEN c.value * c.total_animals ELSE 0 END) AS total_cattle_value

FROM "Cattle" c
LEFT JOIN "CattlePeriod" cp
    ON c.id_period = cp.id_period
LEFT JOIN "CattleCategory" cc
    ON c.id_cattle_category = cc.id_cattle_category
WHERE cc."isActive" = TRUE
GROUP BY
    cp.id_property,
    cp.year,
    cp.month
ORDER BY
    cp.id_property,
    reference_month;