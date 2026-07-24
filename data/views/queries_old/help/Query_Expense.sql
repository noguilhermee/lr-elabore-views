SELECT * FROM "ExpenseEntry"

where tab = 'OWN_MILK'
and id_property = '004cde8f-4688-4b22-acd9-76151b7dcc7a'
and is_active = 'true'

order by 
	id_property,
	reference_month
-- limit 100



SELECT DISTINCT tab FROM "ExpenseEntry"

limit 100