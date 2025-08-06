## Colocar projetos no GitHub

```bash
# Initial setup
gset-dcs
gh dcs

# Add & Commit 
git add .
git commit -m "Initial commit"

# Create GitHub repository
gh repo create motogp-analytics --public --source=. --push

# Push to GitHub
git push origin master

# 
git remote set-url origin git@github.com:diogo-costa-silva/mac-setup.git
```