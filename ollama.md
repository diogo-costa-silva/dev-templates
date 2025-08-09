# Guia Completo — Ambiente Local com Ollama + Continue (VS Code)
Autor: Diogo  
Última atualização: 2025-08-09

---

## 1. Verificações iniciais

Antes de começar, verificar que o sistema cumpre os requisitos.

```bash
# Sistema e CPU
sw_vers
uname -m
sysctl -n machdep.cpu.brand_string 2>/dev/null || true

# Homebrew
brew --version
brew doctor

# Node.js e npm (>= 18)
node -v
npm -v

# VS Code CLI (>= 1.90)
code -v

# Localização do 'ollama' e conflitos
which -a ollama
type -a ollama

# Versão do ollama
ollama --version || true

# Serviços activos do brew
brew services list | grep -i ollama || true

# LaunchAgents/Daemons
launchctl list | grep -i ollama || true
ls -la ~/Library/LaunchAgents | grep -i ollama || true
ls -la /Library/LaunchDaemons | grep -i ollama || true

# API local na porta 11434
lsof -iTCP:11434 -sTCP:LISTEN -nP || true
curl -s http://localhost:11434/api/tags | jq . 2>/dev/null || curl -s http://localhost:11434/api/tags

# Diretórios típicos
echo "BREW prefix: $(brew --prefix)"
ls -la "$HOME/.ollama" || true
ls -la "$HOME/Library/Application Support/Ollama" || true

# Diretório do Continue
ls -la "$HOME/Library/Application Support/Continue" || true
```

---

## 2. Instalação e configuração do Ollama (brew)

```bash
# Instalar via brew
brew install ollama

# Remover App (se existir)
sudo rm -rf /Applications/Ollama.app

# Parar e limpar serviços antigos
brew services stop ollama || true
launchctl bootout gui/$(id -u) "$HOME/Library/LaunchAgents/homebrew.mxcl.ollama.plist" 2>/dev/null || true
sudo launchctl bootout system /Library/LaunchDaemons/homebrew.mxcl.ollama.plist 2>/dev/null || true
sudo rm -f /Library/LaunchDaemons/homebrew.mxcl.ollama.plist

# Iniciar serviço ao iniciar
brew services start ollama

# iniciar ollama no terminal
ollama serve

# Verificar serviço
brew services list | grep -i ollama
lsof -iTCP:11434 -sTCP:LISTEN -nP
curl -s http://localhost:11434/api/version
```

---

## 3. Gestão de modelos no Ollama

### 3.1 Instalar modelos
```bash
# Modelo principal
ollama pull llama3:8b

# Outros modelos úteis
ollama pull codellama
ollama pull mistral
ollama pull phi3
ollama pull qwen2.5-coder:1.5b-base
ollama pull nomic-embed-text:latest
```

### 3.2 Listar modelos
```bash
ollama list
```

### 3.3 Remover modelos
```bash
ollama rm nome_do_modelo
```

### 3.4 Ver detalhes de um modelo
```bash
ollama show nome_do_modelo
```

---

## 4. Uso do Ollama no terminal

```bash
# Chat interativo
ollama run llama3

# Código
ollama run codellama

# Autocomplete
ollama run qwen2.5-coder:1.5b

# Embeddings
ollama run nomic-embed-text:latest

# Sair
Ctrl + C
```

---

## 5. Integração com Continue (VS Code)

### 5.1 Instalar extensão
- VS Code → Extensions → Procurar `Continue` → Instalar.

### 5.2 Configuração
Criar/editar:
```
~/Library/Application Support/Continue/config.json
```
Conteúdo de exemplo:
```jsonc
{
  "models": [
    {
      "provider": "ollama",
      "apiBase": "http://localhost:11434",
      "model": "llama3:8b",
      "roles": ["chat", "autocomplete", "edit"]
    }
  ]
}
```

### 5.3 Teste
- Abrir painel Continue (`⌘J` → escolher Continue).
- Executar:
```
/model llama3:8b
```
- Se responder, ligação está OK.

---

## 6. Automação com VS Code

`.vscode/tasks.json`:
```jsonc
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Start Ollama",
      "type": "shell",
      "command": "brew services start ollama",
      "problemMatcher": []
    },
    {
      "label": "Stop Ollama",
      "type": "shell",
      "command": "brew services stop ollama",
      "problemMatcher": []
    }
  ]
}
```

---

## 7. Boas práticas

- Usar `.env` para tokens/credenciais e carregar com `export $(cat .env | xargs)`
- Não commitar `config.json` com chaves privadas.
- Monitorizar espaço:
```bash
du -sh ~/.ollama/models
```

---

## 8. Troubleshooting

```bash
# Logs do Ollama
log show --predicate 'process == "ollama"' --last 10m

# Arranque em foreground
OLLAMA_LOG=debug ollama serve

# Porta ocupada
lsof -iTCP:11434 -sTCP:LISTEN -nP
```
