/*
MATERIALIZED VIEW: analytics_mart.mvw_asset_capital_stock

Finalidade:
Calcula mensalmente o estoque bruto de capital e a depreciação dos ativos
cadastrados em cada propriedade.

Granularidade:
Uma linha por ativo e mês de referência.

Indicadores calculados:
- Valor total de aquisição
- Valor unitário vigente no mês
- Estoque bruto de capital
- Depreciação mensal
- Valor da entrada do ativo

Regras principais:
- Consome da view intermediária canônica analytics_int.vw_int_asset_base.
- Mantém a mesma estrutura de colunas da view canônica para alta performance.

Fontes principais:
- analytics_int.vw_int_asset_base

Forma de consulta:
SELECT *
FROM analytics_mart.mvw_asset_capital_stock;

Forma de atualização:
REFRESH MATERIALIZED VIEW analytics_mart.mvw_asset_capital_stock;
*/

SELECT ab.id_asset,
    ab.id_property,
    ab.id_classification,
    ab.classification,
    ab.asset_name,
    ab.acquired_at,
    ab.reference_month,
    ab.quantity,
    ab.acquisition_total_value,
    ab.current_unit_value,
    ab.down_payment,
    ab.gross_capital_stock,
    ab.monthly_depreciation
FROM analytics_int.vw_int_asset_base ab;