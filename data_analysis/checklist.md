# Guia/Checklist de Metodologia para Projetos de Análise de Dados (Python/SQL)
*Atualizado em 2025-08-11*  
Este guia é agnóstico ao tipo de dados e foca-se em passos reprodutíveis, boas práticas e decisões claras. 


**Fluxo de trabalho de um projeto de análise de dados:**

1. Business Understanding
2. Data Understanding
3. Pre-EDA (Sanity Check)
4. Data Preparation
5. EDA - Exploratory Data Analysis
6. Reports & Insights



---


## 0) Setup do Projeto (pré-configuração)
**Objetivo:** garantir reprodutibilidade, organização e segurança desde o início.  

**Entregáveis:** repositório versionado, estrutura de pastas, ficheiros base, definição de ambiente.

**Checklist**

- [ ] Criar repositório (Git) e estrutura mínima:


  ```text
  data-analytics-project/
  ├─ .venv/
  ├─ config/
  ├─ data/              # raw/, interim/, processed/
  │  ├─ raw/
  │  ├─ interim/
  │  └─ processed/
  ├─ docs/
  ├─ notebooks/         # 01_xxx.ipynb, 02_xxx.ipynb...
  ├─ scripts/
  ├─ sql/               # 01_exploration.sql, 02_cleaning.sql...
  ├─ src/               # utils.py, pipelines/
  ├─ reports/           # figures/, dashboards/, README.md
  ├─ config/            # .env.example, params.yml
  ├─ tests/
  ├─ .env
  ├─ .gitignore
  ├─ .python-version
  ├─ main.py
  ├─ pyproject.toml		# gerado pelo UV automaticamente
  ├─ README.md
  ├─ requirements.txt	# também gerado pelo UV quando pedido
  ├─ uv.lock        	# gerado pelo UV automaticamente
  └─ LICENSE
  ```
  
- [ ] Definir ambiente Python (venv/uv/conda/poetry -> preferencialmente UV) e ficheiro de dependências (**pyproject.toml** / **requirements.txt**).
- [ ] Criar `.env.example` (sem segredos) e validar variáveis (connection strings, paths).
- [ ] Definir convenções: nomes de ficheiros, prefixos de notebook, padrão de commit.
- [ ] Escolher fonte de verdade (SSOT) para métricas/KPIs.

---

## 1) Business Understanding

**Objetivo:** alinhar o problema, o valor esperado e os critérios de sucesso. Pensar em possíveis questões de negócio/tema que gostava de ver respondidas. 

**Entregáveis:** problem statement, hipóteses, KPIs, riscos, calendário e critérios de aceitação.

**Perguntas-chave**

- Qual a decisão de negócio a tomar e por quem?
- Quais os KPIs/OKRs afetados? Qual baseline e meta?
- Quais restrições (tempo, orçamento, dados, compliance/privacidade)?
- Quais as hipóteses prioritárias a testar?
- O que queremos perguntar aos dados? Com que finalidade?

**Checklist**

- [ ] Definir **Problem Statement** (1–3 frases).
- [ ] Mapear **KPI tree** e métricas derivadas (definições precisas).
- [ ] Listar hipóteses e **impacto esperado** (↑/↓ KPI, ordem de grandeza).
- [ ] **Critérios de sucesso/falha** e decisão-alvo (go/no-go).
- [ ] Riscos/assunções e plano de mitigação.
- [ ] Plano de comunicação com stakeholders (ritmo, formatos).
- [ ] Formulação de questões de negócio que queremos ver respondidas.


---

## 2) Data Understanding

**Objetivo:** inventariar fontes, avaliar disponibilidade, forma, volume e qualidade.  

**Entregáveis:** catálogo de dados, amostra anotada, avaliação de qualidade e viabilidade.

**Checklist**

- [ ] Inventário de **fontes** (DBs, ficheiros, APIs, eventos). Para cada uma: owner, refresh, SLA.
- [ ] **Esquema** (tabelas, chaves, relações), dicionário de dados, unidades e granularidade.
- [ ] **Amostra estratificada** (para evitar viés), com notas de representatividade.
- [ ] Métricas de **qualidade**: completude, unicidade, consistência, atualidade, validade, conformidade.
- [ ] Identificar **sensibilidades** (PII/privacidade) e requisitos legais (GDPR).


---

## 3) Pré‑EDA (sanity checks)
**Objetivo:** garantir condições mínimas para exploração segura.  
**Entregáveis:** relatório curto de problemas óbvios e plano de correção.

**Checklist (por tipo de dado)**
- **Geral**
  - [ ] Tipos corretos (numérico, categórico, datetime, boolean, texto).
  - [ ] Duplicados (linhas e chaves).  
  - [ ] Valores impossíveis (ex.: id ≤ 0, datas futuras absurdas).
  - [ ] Conformidade de **chaves** entre tabelas antes de joins.
- **Numéricos**
  - [ ] Intervalos/escala, zeros estruturais vs zeros faltantes.
  - [ ] Outliers óbvios (min/max, quantis).
- **Categóricos**
  - [ ] Níveis inesperados, **drift** de categorias, campos free‑text que deviam ser enums.
- **Datas/temporal**
  - [ ] Timezone, gaps/duplicados, granularidade (diário, semanal, evento).
- **Texto**
  - [ ] Codificação, lingua/locale, presença de PII.
- **Geoespacial**
  - [ ] SRID/projeção, bounding box plausível.

**Snippets**
```sql
-- Buckets para spotting de outliers
SELECT width_bucket(valor, 0, 1000, 10) AS bin, COUNT(*) FROM t GROUP BY bin ORDER BY bin;
```
```python
# Deteção rápida
bad_dates = df.loc[df["date"] > pd.Timestamp("today") + pd.Timedelta(days=1)]
dups = df[df.duplicated()]
```

---

## 4) Data Preparation
**Objetivo:** transformar dados em estruturas limpas e analisáveis.  
**Entregáveis:** tabelas limpas/intermediárias, scripts reprodutíveis, documentação de transformações.

**Checklist (geral)**
- [ ] **Imputação** (ou marcação) de missing: simples (mean/median/mode), por grupo, forward/backfill (temporal), ou manter como categoria “Unknown” onde fizer sentido.
- [ ] **Tratamento de duplicados**: exact/near dedupe; definir chaves determinísticas.
- [ ] **Normalização de unidades** e padrões (moedas, percentagens, escalas).
- [ ] **Derivação de features/KPIs** (ex.: taxas, rácios, razões de conversão).
- [ ] **Joins** com validação de cardinalidade (1:1, 1:N, N:N) e contagens “antes/depois”.
- [ ] **Filtragem de outliers** vs **cap**/**winsorization** (com justificação).
- [ ] **Particionamento temporal** e snapshots se necessário (consistência histórica).
- [ ] **Documentar** cada transformação (porquê, como, impacto no n).

**Específicos por tipo de dado**
- **Numéricos:** scale/standardize quando necessário para comparabilidade.
- **Categóricos:** normalizar labels, agrupar raros, codificar (one‑hot/ordinal/target) apenas se modelares.
- **Temporal:** criar features (y/m/d, dow, is_holiday, lags), resampling/alinhamento.
- **Texto:** limpeza básica (lowercase, trim), remoção de PII quando aplicável.
- **Geoespacial:** validadores de geometria, interseções/joins espaciais, agrupar por área.

**Padrões SQL**
```sql
-- CTEs para pipeline de limpeza
WITH base AS (
  SELECT * FROM raw.tabela
),
dedup AS (
  SELECT *, ROW_NUMBER() OVER (PARTITION BY chave ORDER BY updated_at DESC) AS rn
  FROM base
)
SELECT * FROM dedup WHERE rn = 1;
```

**Padrões Python**
```python
def assert_unique(df, cols):
    assert not df.duplicated(subset=cols).any(), f"Chave não única: {{cols}}"

df_clean = (
    df
      .assign(amount=lambda d: d["amount"].astype("float"))
      .pipe(lambda d: d[d["amount"] >= 0])
)
assert_unique(df_clean, ["id"])
```

---

## 5) Exploratory Data Analysis (EDA)
**Objetivo:** gerar entendimento e evidência para decisões; encontrar padrões, relações e anomalias.  
**Entregáveis:** notebook com análises reproduzíveis, gráficos explicativos, tabela de insights e hipóteses (validadas/refutadas).

**Checklist (mínimo viável)**
- [ ] **Univariada**: distribuição, tendência central, dispersão, valores extremos.
- [ ] **Bivariada**: numérico×numérico (correlação/rel. não‑linear), numérico×categórico (diferenças entre grupos), categórico×categórico (contingência).
- [ ] **Temporal**: séries (nível, tendência, sazonalidade, eventos), quebras/shift.
- [ ] **Segmentação**: cohorts, percentis, buckets.
- [ ] **Sensibilidade**: resultados robustos a outliers/filtros alternativos?
- [ ] **Registos do que ficou por explicar** (para follow‑ups).

**SQL úteis (descrições)**
```sql
-- Estatísticas descritivas por grupo
SELECT grupo,
       COUNT(*) n,
       AVG(x) avg_x,
       STDDEV_SAMP(x) sd_x,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY x) AS p50_x
FROM t
GROUP BY grupo;

-- Tabela de contingência (crosstab simples por agregação condicional)
SELECT
  SUM(CASE WHEN cat='A' THEN 1 ELSE 0 END) AS a,
  SUM(CASE WHEN cat='B' THEN 1 ELSE 0 END) AS b
FROM t;
```

**Python úteis (pandas)**
```python
# Univariada
df["x"].describe()
df["x"].quantile([0.01, 0.05, 0.95, 0.99])

# Bivariada
df.groupby("grupo")["x"].agg(["count","mean","std","median"])

# Temporal
df.set_index("date").resample("W")["kpi"].sum().plot()
```

**Notas por tipo de dado**
- **Numéricos:** olhar para assimetria, caudas, relações não lineares.
- **Categóricos:** concentração (top‑k categorias), raridade, agrupamentos úteis.
- **Temporal:** janela móvel, lags/leads, efeitos de feriados/promos.
- **Texto:** frequências (bag‑of‑words), comprimentos, categorias latentes simples.
- **Geoespacial:** heatmaps, densidade, proximidade a POIs (quando aplicável).

---

## 6) Reports & Insights
**Objetivo:** transformar análises em decisões e ações.  
**Entregáveis:** relatório conciso, dashboards/tabelas‑chave, plano de ação e limitações.

**Checklist**
- [ ] **Storyline**: contexto → pergunta → evidência → implicação → recomendação.
- [ ] **Métricas** com definições e base temporal claras.
- [ ] **Gráficos** com títulos interpretativos e chamadas‑de‑atenção (anotações).
- [ ] **Quantificação do impacto** esperado e incerteza.
- [ ] **Limitações** (viés, qualidade, cobertura, causalidade) e próximos passos.
- [ ] **Pacote reprodutível**: notebooks + SQL + README (como correr, em que ordem).

**Estrutura sugerida (1‑pager)**
1. *Contexto & Objetivo*
2. *Dados & Qualidade (resumo)*
3. *3–5 Insights principais* (cada um com “So what?”)
4. *Recomendações e próximos passos*
5. *Anexos* (métricas, tabelas, métodos)

---

## Portas de Saída (Definition of Done) por Fase
- **Business Understanding:** KPIs e critérios de sucesso aprovados pelos stakeholders.
- **Data Understanding:** catálogo de dados e avaliação de qualidade assinados.
- **Pré‑EDA:** problemas críticos mapeados e plano de correção definido.
- **Data Preparation:** tabelas/ficheiros “gold” com validações e logs de contagem.
- **EDA:** notebook reprodutível com insights priorizados e alternativas testadas.
- **Reports:** 1‑pager + artefactos para tomada de decisão e handover.

---

## Tabela Rápida por Tipo de Dado (o que nunca esquecer)
| Tipo | 1) Validação | 2) Preparação | 3) EDA típica |
|---|---|---|---|
| Numérico | intervalos, outliers, unidades | imputação, escala | dist., boxplot, correlação |
| Categórico | níveis raros, encoding | normalizar labels, agrupar raros | top‑k, entropia, crosstab |
| Datetime | timezone, gaps | resample, features cal., lags | tendência, sazonalidade |
| Texto | encoding, PII | limpeza básica | freq. termos, comprimentos |
| Geoespacial | SRID, bounds | snap/validar geometrias | densidade, proximidades |

---

## Boas Práticas Transversais
- **Reprodutibilidade:** scripts idempotentes, seeds fixos, `Makefile`/tasks, data versioning (quando possível).
- **Validações automáticas:** contagens antes/depois dos joins, assert de chaves, testes simples em `tests/`.
- **Documentação curta e contínua:** README por pasta, docstrings, changelog.
- **Privacidade:** minimizar exposição de PII, mascarar onde possível, acesso por princípio do menor privilégio.
- **Performance:** operações em *chunks*, `read_csv` com `dtype`, push‑down de filtros para SQL.

---

## Templates Rápidos

**Template de Caderno EDA (topo do notebook)**
```markdown
# EDA — {{nome_do_dataset}} — v{{versao}}
**Objetivo:**  
**Granularidade:**  
**Período:**  
**Filtros globais:**  
**Perguntas guiadoras:**  
```

**Template de Tabela de Insights**
```markdown
| # | Insight | Evidência | Impacto no KPI | Ação sugerida | Risco/Nota |
|---|---|---|---|---|---|
```

**Template de README (como correr)**
```markdown
## Como correr
1. Criar ambiente e instalar dependências
2. Definir variáveis no `.env`
3. Correr `sql/01_exploration.sql` e `sql/02_cleaning.sql`
4. Correr `notebooks/01_pre_eda.ipynb` → `02_eda.ipynb`
5. Gerar `reports/` com `src/reporting.py`
```
