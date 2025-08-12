# Data Analysis Project Checklist


Este repositório segue uma metodologia estruturada para projetos de análise de dados, baseada no guia/checklist disponível [aqui](guia_metodologia_analise_dados.md).  
O objetivo é garantir **reprodutibilidade**, **clareza** e **boas práticas** independentemente do tipo de dados (numérico, categórico, temporal, texto, geoespacial, etc.).

## 📂 Estrutura de Pastas

```text
project/
├─ data/              # raw/, interim/, processed/
│  ├─ raw/            # Dados originais
│  ├─ interim/        # Dados parcialmente processados
│  └─ processed/      # Dados prontos para análise/modelo
├─ notebooks/         # 01_xxx.ipynb, 02_xxx.ipynb...
├─ sql/               # Queries SQL usadas no projeto
├─ src/               # Scripts Python reutilizáveis (ETL, utils, pipelines)
├─ reports/           # figures/, dashboards/, README.md
│  ├─ figures/
│  └─ dashboards/
├─ config/            # .env.example, params.yml
├─ tests/             # Testes automáticos
├─ README.md          # Descrição do projeto
└─ LICENSE
```

## 🛠 Setup do Ambiente

1. **Clonar repositório**
   ```bash
   git clone <url-do-repo>
   cd <nome-do-repo>
   ```

2. **Criar ambiente virtual e instalar dependências**
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # Linux/Mac
   .venv\Scripts\activate   # Windows

   pip install -r requirements.txt
   ```

3. **Definir variáveis de ambiente**
   ```bash
   cp config/.env.example .env
   # Editar .env conforme necessário
   ```

4. **Executar pipeline** (exemplo com Makefile)
   ```bash
   make run
   ```

## 🚀 Metodologia do Projeto

O projeto segue as fases:
1. **Business Understanding**
2. **Data Understanding**
3. **Pré-EDA**
4. **Data Preparation**
5. **Exploratory Data Analysis (EDA)**
6. **Reports & Insights**

Mais detalhes no [guia completo](guia_metodologia_analise_dados.md) e no [checklist compacto](checklist_compacto_analise_dados.md).

## 📋 Contribuições

- Manter nomes de ficheiros consistentes (`01_nome_do_arquivo.ipynb`).
- Guardar dados brutos apenas em `data/raw`.
- Não fazer _commit_ de dados sensíveis ou PII.

## 📜 Licença

Este projeto é distribuído sob a licença MIT. Ver [LICENSE](LICENSE) para mais detalhes.
