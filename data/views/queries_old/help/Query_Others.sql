#
# Listar os nomes das colunas de uma tabela no PostgreSQL
#

SELECT
    column_name
FROM information_schema.columns
WHERE table_name = 'RevenueEntry'
ORDER BY ordinal_position;



