# AGENTS.md

## Contexto do projeto

Este projeto pertence à Labor Rural e tem como objetivo extrair, tratar, consolidar e exportar indicadores do sistema de gerenciamento de fazendas Elabore.

Os principais produtos são:

- indicadores mensais por propriedade e mês;
- indicadores anuais por propriedade e ano;
- arquivos Excel destinados à análise e ao uso interno da empresa.

Ao alterar o projeto, priorize a correção dos indicadores, a rastreabilidade das regras de negócio e a preservação da granularidade dos dados.

## Estrutura principal

- `app/Elabore Indicadores.ipynb`: fluxo principal de importação, tratamento, consolidação e exportação.
- `functions/sharepoint_utils.py`: funções auxiliares para SharePoint, banco de dados e arquivos Excel.
- `data/views/queries/analytics_int/`: views intermediárias e regras de integração.
- `data/views/queries/analytics_mart/`: views prontas para consumo analítico.
- `data/views/queries/materialized/`: materialized views.
- `data/views/queries_old/`: consultas antigas mantidas apenas como referência.
- `data/outputs/monthly/`: exportações mensais.
- `data/outputs/annual/`: exportações anuais.
- `app/backup/`: versões antigas dos notebooks, não usadas como fonte principal.

Não implemente novas regras em `queries_old/` ou `app/backup/`, salvo quando a tarefa pedir explicitamente a recuperação de uma versão antiga.

## Tecnologias e convenções

- Python e pandas para transformação dos dados.
- Jupyter Notebook para execução do fluxo principal.
- PostgreSQL e SQL para as views analíticas.
- SQLAlchemy/psycopg2 para acesso ao banco.
- openpyxl para formatação dos arquivos Excel.
- Microsoft Graph e SharePoint quando a integração for necessária.

Escreva nomes de variáveis, comentários e documentação em português quando isso mantiver a consistência do arquivo. Preserve nomes técnicos, nomes de tabelas e colunas já existentes.

## Regras para indicadores

- Declare ou confirme a granularidade antes de alterar uma consulta ou transformação.
- Para dados mensais, a chave esperada normalmente é `id_property` + `reference_month`.
- Para dados anuais, agregue por `id_property` + ano somente após concluir os tratamentos mensais necessários.
- Normalize datas mensais para o primeiro dia do mês.
- Não misture valores de propriedades ou períodos diferentes.
- Antes de fazer um `merge`, valide as chaves, a cardinalidade esperada e possíveis duplicidades.
- Use `validate=` nos merges do pandas sempre que a cardinalidade for conhecida.
- Não preencha valores ausentes com zero sem confirmar que zero representa ausência econômica real.
- Evite divisões por zero e documente como indicadores sem denominador válido devem ser representados.
- Preserve unidades, sinais e tipos. Diferencie valores monetários, quantidades, áreas, percentuais e índices.
- Alterações em correção monetária, depreciação, estoque de capital ou IGP-DI devem manter explícitos o índice de origem, o índice de referência e a fórmula utilizada.
- Não renomeie colunas exportadas sem avaliar a compatibilidade com os consumidores dos arquivos.

## Regras para SQL

- Cada view nova ou significativamente alterada deve informar, em comentário no início do arquivo:
  - finalidade;
  - granularidade;
  - fontes principais;
  - regras de negócio relevantes;
  - forma básica de consulta.
- Prefira organizar as consultas em CTEs com responsabilidades claras.
- Evite `SELECT *` na definição final de views de produção.
- Qualifique colunas quando houver mais de uma tabela ou CTE.
- Trate explicitamente registros vigentes, datas abertas, duplicidades e critérios de desempate.
- Em janelas analíticas, defina uma ordenação determinística.
- Não altere objetos de origem do Elabore nem execute comandos destrutivos sem solicitação explícita.
- Mudanças em `analytics_int` devem preservar os consumidores em `analytics_mart`.

## Regras para notebooks e Python

- Mantenha o notebook principal executável na ordem das células.
- Evite caminhos absolutos ligados a um usuário ou computador; derive caminhos a partir da raiz do projeto com `pathlib.Path`.
- Centralize configurações como período analisado, views importadas e diretórios de saída.
- Extraia lógica reutilizável e suficientemente estável para funções pequenas e testáveis.
- Não deixe segredos, tokens, senhas, URLs com credenciais ou conteúdo do `.env` nas células, saídas ou logs.
- Ao salvar notebooks, remova saídas volumosas ou sensíveis que não sejam necessárias para compreender o resultado.
- Não faça alterações mecânicas em todo o JSON de um notebook quando somente uma célula precisa mudar.
- **Backup Obrigatório Antes de Modificar/Substituir Arquivos**: Sempre que for alterar ou substituir o conteúdo de um notebook ou arquivo existente, crie antes uma cópia de segurança (em `app/backup/` ou com sufixo `.bak`) para preservar o histórico local e evitar perda de edições.

## Exportações

- Os arquivos mensais devem ser gravados em `data/outputs/monthly/`.
- Os arquivos anuais devem ser gravados em `data/outputs/annual/`.
- Preserve o padrão de nome existente com a data de geração.
- Não sobrescreva uma exportação histórica sem solicitação explícita.
- Mantenha cabeçalhos, tipos e nomes de abas estáveis quando possível.
- A formatação do Excel não pode alterar os valores calculados.

## Segurança e dados

- O arquivo `.env` é local e nunca deve ser versionado.
- Nunca exponha credenciais do banco, Microsoft Graph, SharePoint ou Elabore.
- Não inclua dados identificáveis de clientes ou propriedades em testes, exemplos, mensagens de erro ou documentação.
- Prefira amostras sintéticas e pequenas para validações.
- Trate os dados e indicadores da Labor Rural como informação interna.

## Validação antes de concluir

Execute verificações proporcionais à mudança. No mínimo:

1. confirme que o código Python ou SQL alterado possui sintaxe válida;
2. verifique unicidade na granularidade esperada;
3. compare contagem de propriedades e períodos antes e depois;
4. procure duplicidades introduzidas por joins ou merges;
5. confira valores nulos, infinitos e divisões por zero nas colunas afetadas;
6. valide ao menos uma propriedade e um período com cálculo conhecido ou amostra sintética;
7. quando houver exportação, abra o arquivo gerado e confirme abas, cabeçalhos, número de linhas e tipos essenciais.

Se não for possível acessar o banco, SharePoint ou outro serviço externo, faça as validações locais possíveis e informe claramente o que não foi executado.

## Forma de trabalhar

- Antes de editar, leia os arquivos relacionados e verifique o estado do Git.
- Preserve alterações já existentes que não pertençam à tarefa.
- Faça mudanças pequenas e focadas; não refatore áreas não relacionadas.
- Explique qualquer hipótese de negócio adotada.
- Se uma regra puder mudar materialmente o valor de um indicador e não estiver documentada, peça confirmação em vez de adivinhar.
- Ao finalizar, informe os arquivos alterados, as validações realizadas e eventuais limitações.
