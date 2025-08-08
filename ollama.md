# Ollama - MacOS

[Installing and Using Ollama on macOS](https://blog.stackademic.com/installing-and-using-ollama-on-macos-acabe185fa3a)

### 1. Install Ollama on MacOS

```bash
# install via brew
brew install ollama

# verify installation
ollama --version

# View commands
ollama
```

### 2. Start the server

```bash
# Start the ollama server
ollama serve

# Check if the server is running
curl http://localhost:11434

#  
sudo brew services start ollama
brew services start ollama
```



```ollama
# Install Ollama
# Ollama is running at http://localhost:11434

# Download Chat model
ollama pull llama3.1:8b

# Download Autocomplete model
ollama pull qwen2.5-coder:1.5b-base

# Download Embeddings model
ollama pull nomic-embed-text:latest
```

### 3. Run a Model

```bash

ollama run llama3.2

ollama run mistral

ollama run deepseek-coder:6.7b
ollama run deepseek-r1

# for autocomplition
ollama run qwen2.5-coder:1.5b



```

### 4. List the Models

```bash
ollama list
```










---

## ✅ 1. **Verificar se o Ollama está a correr**

Após instalar pelo Homebrew:

```bash
brew install ollama
brew services start ollama
```

Verifica se está ativo:

```bash
ollama list         # Mostra os modelos instalados
ollama run llama3   # Tenta correr o modelo padrão (vai puxar se ainda não estiver instalado)
```

---

## 📦 2. **Instalar modelos no Ollama**

Podes instalar vários modelos open-source com:

```bash
ollama pull llama3
ollama pull codellama
ollama pull mistral
ollama pull phi3
ollama pull neural-chat
```

Modelos recomendados para testes:

|Modelo|Finalidade|
|---|---|
|`llama3`|Geral, multitarefa, rápido|
|`codellama`|Focado em **code generation**|
|`phi3`|Pequeno e eficiente, bom para tasks|
|`mistral`|Mais versátil e preciso|

---

## 💬 3. **Usar o Ollama no terminal**

```bash
ollama run llama3
```

Escreves a tua mensagem e ele responde como se fosse um chat. Para sair: `Ctrl + C`.



---

## 📍 Resumo dos comandos úteis

|Ação|Comando|
|---|---|
|Instalar modelo|`ollama pull <nome>`|
|Listar modelos|`ollama list`|
|Remover modelo|`ollama rm <nome>`|
|Usar modelo no terminal|`ollama run <nome>`|
|Iniciar servidor (boot)|`brew services start ollama` ou `ollama serve`|
|Parar servidor|`brew services stop ollama`|




---


|**Acção**|**Comando**|
|---|---|
|Ver modelos instalados|ollama list|
|Ver tags disponíveis|ollama show qwen2.5-coder|
|Iniciar manualmente o servidor|ollama serve|
|Remover modelo|ollama rm qwen2.5-coder:1.5b|
|Ver se há serviço a correr (Homebrew)|brew services list|
