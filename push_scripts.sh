#!/bin/bash

# ──────────────────────────────────────────────
#  push_scripts.sh
# ──────────────────────────────────────────────

GITHUB_USER="papycopy"
REPO_NAME="configuration_de_nano"
BRANCH="main"

# ── Vérifier gh ──
if ! command -v gh &>/dev/null; then
    echo "❌ GitHub CLI (gh) n'est pas installé."
    echo "   sudo pacman -S github-cli"
    exit 1
fi

if ! gh auth status &>/dev/null; then
    echo "❌ Non authentifié. Lance : gh auth login"
    exit 1
fi

# ── Init git ──
if [ ! -d ".git" ]; then
    echo "🔄 git init..."
    git init
    git branch -M "$BRANCH"
fi

# ── Ajouter TOUT (hors .git) ──
git add .

if git diff --cached --quiet; then
    echo "✅ Rien à pousser, tout est à jour."
    exit 0
fi

echo "📂 Fichiers à pousser :"
git diff --cached --name-only | sed 's/^/   /'
echo ""

COMMIT_MSG="Update — $(date '+%Y-%m-%d %H:%M')"
git commit -m "$COMMIT_MSG"

# ── Créer le dépôt + push ──
if ! gh repo view "$GITHUB_USER/$REPO_NAME" &>/dev/null; then
    echo "🔄 Création du dépôt $GITHUB_USER/$REPO_NAME..."
    gh repo create "$REPO_NAME" --private --source=. --push
else
    echo "📂 Dépôt existe déjà, push..."
    if ! git remote get-url origin &>/dev/null; then
        git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
    fi
    git push -u origin "$BRANCH"
fi

echo "✅ Push terminé !"
echo "📍 https://github.com/$GITHUB_USER/$REPO_NAME"   
