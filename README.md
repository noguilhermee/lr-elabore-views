# 🚀 lr-functions

Biblioteca interna com funções utilitárias para integração com SharePoint utilizando Microsoft Graph API.

O objetivo deste projeto é centralizar as funções mais utilizadas para:

- 🔐 autenticação no Microsoft Graph
- 🌐 conexão com SharePoint
- 📥 extração de listas
- ⚡ cargas incrementais
- 📄 paginação automática
- 🐼 transformação de JSON para DataFrame
- ❌ tratamento de erros
- 💾 checkpoints de ETL

---

# 📁 Estrutura do Projeto

```text
lr-functions/
│
├── app/
│   └── main.ipynb              # Notebook principal de testes
│
├── data/
│   ├── .env                    # Variáveis de ambiente
│   └── dados.txt
│
├── functions/
│   └── sharepoint_utils.py     # Funções utilitárias SharePoint
│
└── README.md
```

---

# 🛠️ Funcionalidades

## 🔐 Microsoft Graph Authentication

Funções para geração de token OAuth2 utilizando:

- Tenant ID
- Client ID
- Client Secret

---

## 🌐 SharePoint Integration

Funções para:

- 📂 listar sites
- 📋 listar listas
- 📥 buscar itens
- 🔄 paginação automática
- ⚡ cargas incrementais

---

## 📊 ETL Utilities

- 🐼 transformação para pandas DataFrame
- 💾 checkpoints
- 📅 filtros incrementais
- 📝 logs
- ❌ tratamento de erros

---

# ⚙️ Configuração

Criar arquivo `.env` dentro da pasta `data/`.

Exemplo:

```env
TENANT_ID=xxxxxxxx
CLIENT_ID=xxxxxxxx
CLIENT_SECRET=xxxxxxxx
SITE_ID=xxxxxxxx
```

---

# 📦 Instalação

```bash
pip install pandas requests python-dotenv
```

---

# ▶️ Exemplo de Uso

```python
from functions.sharepoint_utils import *

token = get_access_token()

dados = get_sharepoint_data_incremental(
    list_id='LIST_ID',
    list_name='saidaestoque',
    access_token=token,
    incremental=False
)

df = saidaestoque_to_dataframe(dados)

print(df.head())
```

---

# 🧰 Principais Tecnologias

- 🐍 Python
- 🐼 Pandas
- 🌐 Requests
- ☁️ Microsoft Graph API
- 📂 SharePoint Online

---

# 🎯 Objetivo

Este repositório foi criado para reutilização de funções comuns utilizadas em projetos de Analytics e Engenharia de Dados envolvendo SharePoint.

---

# 👨‍💻 Autor


**Guilherme Henrique Fonseca Nogueira**

* 🎓 **Mestre em Economia Aplicada** (PPGEA/UFV)
* 🎓 **Bacharel em Ciências Econômicas** (UFSJ)
* 📊 **Cientista de Dados** (Escola DNC)

---

### Contato e Redes
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=flat-square&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/noguilhermee/)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/noguilhermee)
[![Lattes](https://img.shields.io/badge/Currículo_Lattes-104E8B?style=flat-square&logo=google-scholar&logoColor=white)](http://lattes.cnpq.br/9226285374070081)

---