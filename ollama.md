# Complete Guide — Local Environment with Ollama + Continue (VS Code)
Author: Diogo Silva
Last update: 2025-08-11

---

## 1. Initial Checks

Before starting, verify that the system meets the requirements.

```bash
# System and CPU
sw_vers
uname -m
sysctl -n machdep.cpu.brand_string 2>/dev/null || true

# Homebrew
brew --version
brew doctor

# Node.js and npm (>= 18)
node -v
npm -v

# VS Code CLI (>= 1.90)
code -v

# Ollama location and conflicts
which -a ollama
type -a ollama

# Ollama version
ollama --version || true

# Active brew services
brew services list | grep -i ollama || true

# LaunchAgents/Daemons
launchctl list | grep -i ollama || true
ls -la ~/Library/LaunchAgents | grep -i ollama || true
ls -la /Library/LaunchDaemons | grep -i ollama || true

# Local API on port 11434
lsof -iTCP:11434 -sTCP:LISTEN -nP || true
curl -s http://localhost:11434/api/tags | jq . 2>/dev/null || curl -s http://localhost:11434/api/tags

# Typical directories
echo "BREW prefix: $(brew --prefix)"
ls -la "$HOME/.ollama" || true
ls -la "$HOME/Library/Application Support/Ollama" || true

# Continue directory
ls -la "$HOME/Library/Application Support/Continue" || true
```

---

## 2. Installing and Configuring Ollama (brew)

```bash
# Install via brew
brew install ollama

# Remove App (if exists)
sudo rm -rf /Applications/Ollama.app

# Stop and clean old services
brew services stop ollama || true
launchctl bootout gui/$(id -u) "$HOME/Library/LaunchAgents/homebrew.mxcl.ollama.plist" 2>/dev/null || true
sudo launchctl bootout system /Library/LaunchDaemons/homebrew.mxcl.ollama.plist 2>/dev/null || true
sudo rm -f /Library/LaunchDaemons/homebrew.mxcl.ollama.plist

# Start service on startup
brew services start ollama

# Start ollama in terminal
ollama serve

# Check service
brew services list | grep -i ollama
lsof -iTCP:11434 -sTCP:LISTEN -nP
curl -s http://localhost:11434/api/version
```

---

## 3. Managing Models in Ollama

### 3.1 Installing Models
```bash
# Main model
ollama pull llama3:8b

# Coding Models
ollama pull codellama:34b
ollama pull deepseek-coder:33b





# Other useful models
ollama pull codellama
ollama pull mistral
ollama pull phi3
ollama pull qwen2.5-coder:1.5b-base
ollama pull nomic-embed-text:latest
```

### 3.2 List Models
```bash
ollama list
```

### 3.3 Remove Models
```bash
ollama rm model_name
```

### 3.4 View Model Details
```bash
ollama show model_name
```

---

## 4. Using Ollama in Terminal

```bash
# Interactive Chat
ollama run llama3

# Code
ollama run codellama

# Autocomplete
ollama run qwen2.5-coder:1.5b

# Embeddings
ollama run nomic-embed-text:latest

# Exit
Ctrl + C
```

---

## 5. Integration with Continue (VS Code)

### 5.1 Install Extension
- VS Code → Extensions → Search for `Continue` → Install.

### 5.2 Configuration
Create/edit:
```
~/Library/Application Support/Continue/config.json
```
Example content:
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

### 5.3 Test
- Open Continue panel (`⌘J` → choose Continue).
- Execute:
```
/model llama3:8b
```
- If it responds, connection is OK.

---

## 6. VS Code Automation

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

## 7. Best Practices

- Use `.env` for tokens/credentials and load with `export $(cat .env | xargs)`
- Don't commit `config.json` with private keys.
- Monitor space:
```bash
du -sh ~/.ollama/models
```

---

## 8. Troubleshooting

```bash
# Ollama Logs
log show --predicate 'process == "ollama"' --last 10m

# Foreground startup
OLLAMA_LOG=debug ollama serve

# Port in use
lsof -iTCP:11434 -sTCP:LISTEN -nP
```
