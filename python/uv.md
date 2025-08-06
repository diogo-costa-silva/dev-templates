# UV Python Project Setup Guide

## Installation

```bash
# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
# or
brew install uv
```

## Project Setup

```bash
# Create new project
uv init my-project
cd my-project

# Initialize existing project
uv init
```

## Dependency Management

```bash
# Add dependencies
uv add pandas matplotlib seaborn
uv add --dev pytest black ruff

# Add from requirements.txt
uv add -r requirements.txt

# Remove dependency
uv remove package-name

# Update dependencies
uv sync
```

## Virtual Environment

```bash
# Create virtual environment (automatic with uv init)
uv venv                    # Create .venv in current directory
uv venv my-env             # Create named environment

# Activate virtual environment
source .venv/bin/activate  # Linux/macOS
.venv\Scripts\activate     # Windows

# Run commands in venv without activation
uv run python script.py
uv run pytest
uv run jupyter lab
```

## Python Version Management

```bash
# Install specific Python version
uv python install 3.11

# Use specific Python version
uv init --python 3.11
```

## Essential Commands

```bash
# Install all dependencies
uv sync

# Run script
uv run python main.py

# Add package and run
uv run --with requests python script.py

# Lock dependencies
uv lock

# Export requirements
uv export --format requirements-txt --output-file requirements.txt
```

## Project Structure

```
my-project/
├── pyproject.toml     # Project config and dependencies
├── uv.lock           # Locked dependencies
├── .venv/            # Virtual environment
├── src/              # Source code
└── README.md
```

## Key Files

- `pyproject.toml`: Project metadata and dependencies
- `uv.lock`: Exact dependency versions (commit this)
- `.venv/`: Virtual environment (add to .gitignore)

## Best Practices

- Always commit `pyproject.toml` and `uv.lock`
- Add `.venv/` to `.gitignore`
- Use `uv sync` after cloning
- Use `uv run` for consistent execution