SELECT *
FROM analytics_mart.vw_cattle
ORDER BY id_property, reference_month;



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
    
    SUM(CASE WHEN cc."isActive" = TRUE THEN c.total_animals ELSE 0 END) AS total_cattle
	
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