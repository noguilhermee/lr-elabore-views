/*
VIEW: analytics_mart.vw_asset_capital_stock

Finalidade:
Calcula mensalmente o estoque bruto de capital e a depreciação dos ativos
cadastrados em cada propriedade.

Granularidade:
Uma linha por ativo e mês (id_asset + reference_month).

Fontes principais:
- analytics_int.vw_int_asset

Regras de negócio:
- Consome da view intermediária canônica analytics_int.vw_int_asset (já expandida mês a mês com revisões de valor LATERAL e depreciação calculada).
- O estoque bruto não é reduzido pela depreciação acumulada.
- Esta view é a definição canônica da lógica; a materialized view
  mvw_asset_capital_stock contém a mesma lógica para performance.

Forma de consulta:
SELECT * FROM analytics_mart.vw_asset_capital_stock;
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
FROM analytics_int.vw_int_asset ab;