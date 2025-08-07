# 🐍 Python Project Setup Template with Git, UV, and GitHub CLI

This guide provides a simple, clean, and reproducible workflow to set up a new Python project with a virtual environment, dependencies, Git integration, and GitHub publishing.

---

## ⚙️ 1. Create the project directory and navigate into it

```bash
mkdir testwow
cd testwow
```

---

## 🔧 2. Initialize a local Git repository

```bash
git init


gset-dcs
gh dcs
```

---

## 🐍 3. Set the Python version using UV

```bash
uv python install 3.11         # Installs Python 3.11 locally (if not already installed)
uv init                        # Creates pyproject.toml and base structure
```

---

## 🧪 4. Create and activate the virtual environment

```bash
uv venv                        # Creates .venv virtual environment
source .venv/bin/activate      # Activate it (on Unix/macOS)
# .venv\Scripts\activate     # (On Windows)
```

---

## 📦 5. Install core dependencies

```bash
uv add numpy pandas matplotlib seaborn
```

---

## 📋 6. Save dependencies to requirements.txt

```bash
uv pip freeze > requirements.txt
```

---

## 📁 7. Create base project files

```bash
echo "# testwow" > README.md
touch main.py
touch .gitignore
```

---

## 🚫 8. Generate a basic .gitignore

```bash
echo -e ".venv/\n__pycache__/\n.ipynb_checkpoints/\n*.pyc\n.DS_Store" > .gitignore
```

---

## 💾 9. Make the initial commit

```bash
git add .
git commit -m "Initial commit: Project structure and dependencies"
```

---

## ☁️ 10. Connect to the remote GitHub repository (choose one of the options below)

### 🔁 OPTION A — Create and push to GitHub via GitHub CLI

> ⚠️ Requires you to be authenticated (`gh auth login`)

```bash
# Fixed name
gh repo create testwow --private --source=. --remote=origin --push

# OR: Use current folder name as repo name
gh repo create $(basename "$PWD") --private --source=. --remote=origin --push
```

> ✅ This command:
> - Creates the GitHub repo
> - Adds it as remote `origin`
> - Pushes your local commits
> - Sets `main` as the upstream branch

---

### 🧷 OPTION B — Link to a manually created GitHub repository

```bash
git remote add origin git@github.com:diogo-costa-silva/testwow.git
git branch -M main
git push -u origin main
```

---

## 🚀 Daily Git workflow after setup

```bash
# Pull latest changes (if working collaboratively or from multiple machines)
git pull

# Edit your code
code main.py

# Check for changes
git status

# Stage changes
git add .

# Commit changes
git commit -m "Describe your changes"

# Push to GitHub
git push
```

---

## 🧪 Useful commands to check remote tracking

```bash
git remote -v       # Check remote URL
git branch -vv      # Check if local branch is linked to remote
gh repo view --web  # Open GitHub repo in browser
```
