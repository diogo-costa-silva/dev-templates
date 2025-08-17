# ⌨️ Claude Code + MySQL MCP Server no MacOS

Este guia explica, passo a passo, como ligar o **Claude Code** diretamente a bases de dados MySQL locais no macOS, usando o [**mysql_mcp_server**](https://github.com/designcomputer/mysql_mcp_server) da [designcomputer](https://github.com/designcomputer/mysql_mcp_server).

O resultado final: vais poder abrir o Claude Code, escrever queries SQL (`SHOW DATABASES;`, `SELECT ...`) e o Claude responde com resultados reais da tua instância MySQL. 🤯

---

## 1. Pré-requisitos

No macOS, garante que tens:

- **Claude Code** instalado: [Anthropic Claude Code](https://www.anthropic.com/claude-code)
- **MySQL** a correr localmente (`brew install mysql` ou Docker).
- **Python 3.11+** (usa `uv` para gerir ambientes virtuais).
- **uv** instalado: `curl -LsSf https://astral.sh/uv/install.sh | sh`


---

## 2. Criar um ambiente UV isolado para o MCP

```bash
mkdir -p ~/.mcp-envs/mysql
cd ~/.mcp-envs/mysql

uv venv
source .venv/bin/activate
```

> 	Ativas o venv só para instalar/atualizar o servidor MCP.

## 2.1. Garantir pip no venv (às vezes falta no uv)

```bash
python -m ensurepip --upgrade
python -m pip install --upgrade pip
```

---

## 3. Instalar o servidor MySQL MCP

```bash
# Instalar via repositório oficial:
pip install git+https://github.com/designcomputer/mysql_mcp_server.git

# Instalar via pip:
pip install mysql-mcp-server
```


Confirma que ficou instalado:

```bash
~/.mcp-envs/mysql/.venv/bin/mysql_mcp_server --help
```

---

## 4. Configuração de credenciais (segura)

### Opção A) Usar .env file (mais simples)

Cria um ficheiro ~/.mcp-envs/mysql/.env:

```bash
cat > ~/.mcp-envs/mysql/.env <<'ENV'
MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=<<<colocar_só_aqui>>>
# Use uma BD neutra por defeito (este servidor exige uma):
MYSQL_DATABASE=information_schema
ENV
```

> Nota: mesmo com MYSQL_DATABASE=information_schema, podes fazer USE outra_bd; dentro do Claude.

### Opção B) Guardar password no Keychain do macOS

Mais seguro: guarda a password uma vez no Keychain:

```
security add-generic-password -a "$USER" -s mysql_root -w 'podimon10'
```

Depois edita `~/.mcp-envs/mysql/.env` sem password:

```bash
MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_USER=root
# deixa a password vazia para vir do Keychain
MYSQL_PASSWORD=
# Use uma BD neutra por defeito (este servidor exige uma):
MYSQL_DATABASE=information_schema
```

---

## 5. Criar wrapper para o servidor MCP

Cria `~/bin/mysql-mcp-env.sh`: `touch ~/bin/mysql-mcp-env.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

LOG_TAG="[mysql-mcp-env]"

# 1) Carregar .env se existir
if [ -f "$HOME/.mcp-envs/mysql/.env" ]; then
  set -a
  . "$HOME/.mcp-envs/mysql/.env"
  set +a
else
  echo "$LOG_TAG Aviso: ~/.mcp-envs/mysql/.env não encontrado" >&2
fi

# 2) Fallback: password do Keychain se não houver MYSQL_PASSWORD
if [ "${MYSQL_PASSWORD:-}" = "" ]; then
  if PW="$(security find-generic-password -a "$USER" -s mysql_root -w 2>/dev/null)"; then
    export MYSQL_PASSWORD="$PW"
  else
    echo "$LOG_TAG ERRO: Sem MYSQL_PASSWORD e sem entrada no Keychain (service=mysql_root)" >&2
    exit 1
  fi
fi

# 3) Obrigatórios: host, user, database
: "${MYSQL_HOST:=127.0.0.1}"
: "${MYSQL_PORT:=3306}"
: "${MYSQL_USER:?Falta MYSQL_USER}"
: "${MYSQL_DATABASE:?Falta MYSQL_DATABASE (usa p.ex. information_schema)}"

# 4) export explícito
export MYSQL_HOST MYSQL_PORT MYSQL_USER MYSQL_PASSWORD MYSQL_DATABASE

# 5) Arrancar o server do venv
EXEC="$HOME/.mcp-envs/mysql/.venv/bin/mysql_mcp_server"
if [ ! -x "$EXEC" ]; then
  echo "$LOG_TAG ERRO: Binário não encontrado em $EXEC" >&2
  exit 1
fi

exec "$EXEC"
```

Torna-o executável:

```bash
chmod +x ~/bin/mysql-mcp-env.sh
```

---


## 6. Registar o MCP no Claude Code

Remove configs antigas (se existirem):

```bash
claude mcp remove mysql_rw_films -s user 2>/dev/null || true
```

Adiciona o novo server, apontando para o wrapper:

```bash
claude mcp add --scope user mysql_multi_rw -- ~/bin/mysql-mcp-env.sh
```

Confirma:

```bash
claude mcp list
claude mcp get mysql_multi_rw
```

Deve aparecer ✅ Connected.

⸻

## 7. Usar no Claude Code 🚀

Abre o Claude Code:

```bash
claude
```

No REPL:

```SQL
SHOW DATABASES;
USE films;
SHOW TABLES;
SELECT COUNT(*) FROM sqlzoo.game;
```


---

## 8. Boas práticas de segurança

•	Nunca commits o .env → adiciona ao .gitignore.

•	Usa o Keychain (security add-generic-password) para não ter passwords em ficheiro.

•	Cria um utilizador MySQL só para o Claude, com permissões limitadas:

```sql
CREATE USER 'claude'@'localhost' IDENTIFIED BY 'senha_segura';
GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO 'claude'@'localhost';
FLUSH PRIVILEGES;
```

•	Usa information_schema como DB default neutra → troca com USE quando precisares.

---

## 9. Troubleshooting

•	claude mcp list mostra ✗? Testa:

```bash
mysql -uroot -ppassword -h127.0.0.1 -P3306 -e "SELECT 1;"
```


•	Se o Claude pedir sempre “trust folder”, garante que o corres na tua pasta de projeto (não dentro de ~/.mcp-envs).

•	Ver se o wrapper está a exportar as variáveis:

```
bash -x ~/bin/mysql-mcp-env.sh
```

Se der “Missing required database configuration”, é porque faltam variáveis no .env ou o Keychain não devolveu nada.

---

## 10. Conteudo a adicionar ao `gitignore`

```
# MCP local setup
.mcp-envs/
*.env
```


## 11. Atualizar a biblioteca

```bash
source ~/.mcp-envs/mysql/.venv/bin/activate && pip install -U mysql_mcp_server
```