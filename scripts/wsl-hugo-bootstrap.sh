#!/usr/bin/env bash
# wsl-hugo-bootstrap.sh
# One-time (idempotent) WSL setup for Hugo + Blowfish + Git + submodules.
# Works inside or outside repo. Safe to re-run.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./wsl-hugo-bootstrap.sh [--repo-dir PATH] [--repo-url URL] [--hugo-version X.YY.Z] [--skip-node]

Env overrides:
  GIT_NAME           Default: "Russell Morefield"
  GIT_EMAIL          Default: "info@rlmx.tech"
  DEFAULT_BRANCH     Default: "master"
  INSTALL_GH         Default: "true"
  INSTALL_NODE       Default: "true"
  AUTO_PUSH          Default: "false"   (pushes when new commits are made)

Examples:
  ./wsl-hugo-bootstrap.sh
  AUTO_PUSH=true ./wsl-hugo-bootstrap.sh --repo-dir "$HOME/GitHub/russmorefield.github.io"
EOF
}

# -------- Defaults --------
REPO_DIR="${REPO_DIR:-$HOME/GitHub/russmorefield.github.io}"
REPO_URL="${REPO_URL:-https://github.com/russmorefield/russmorefield.github.io.git}"
HUGO_VER="${HUGO_VER:-0.148.1}"         # Hugo Extended
INSTALL_GH="${INSTALL_GH:-true}"
INSTALL_NODE="${INSTALL_NODE:-true}"
GIT_NAME="${GIT_NAME:-Russell Morefield}"
GIT_EMAIL="${GIT_EMAIL:-info@rlmx.tech}"
DEFAULT_BRANCH="${DEFAULT_BRANCH:-master}"
AUTO_PUSH="${AUTO_PUSH:-false}"

# -------- Args --------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-dir) REPO_DIR="$2"; shift 2;;
    --repo-url) REPO_URL="$2"; shift 2;;
    --hugo-version) HUGO_VER="$2"; shift 2;;
    --skip-node) INSTALL_NODE="false"; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Unknown arg: $1" >&2; usage; exit 1;;
  esac
done

# -------- Guard rails --------
if ! grep -qi microsoft /proc/version; then
  echo "[!] Not running inside WSL (continuing anyway)"; 
fi

if [[ "$(pwd)" == /mnt/* ]]; then
  cat <<'EOF' 1>&2
[!] You're currently under /mnt/<drive>. For best performance and fewer git issues,
    keep repos under the WSL filesystem (e.g., /home/$USER/GitHub).
EOF
fi

# -------- System packages --------
sudo apt update
sudo apt -y install git curl unzip xz-utils build-essential ca-certificates apt-transport-https

if [[ "${INSTALL_GH}" == "true" ]] && ! command -v gh >/dev/null 2>&1; then
  sudo apt -y install gh || true
fi

if [[ "${INSTALL_NODE}" == "true" ]]; then
  sudo apt -y install nodejs npm
fi

# -------- Git globals --------
git config --global user.name  "${GIT_NAME}"
git config --global user.email "${GIT_EMAIL}"
git config --global core.autocrlf input
git config --global core.eol lf
git config --global core.ignorecase false
git config --global pull.rebase false
git config --global fetch.prune true
git config --global init.defaultBranch "${DEFAULT_BRANCH}"
git config --global submodule.recurse true

git config --global alias.st 'status -sb'
git config --global alias.lg 'log --oneline --graph --decorate -n 30'
git config --global alias.smu '!git submodule sync --recursive && git submodule update --init --recursive'
git config --global alias.smup '!git submodule sync --recursive && git submodule update --init --recursive --remote --merge'

# -------- Hugo Extended --------
if ! command -v hugo >/dev/null 2>&1 || ! hugo version 2>/dev/null | grep -q "v${HUGO_VER}"; then
  tmpdeb="/tmp/hugo_${HUGO_VER}_linux-amd64.deb"
  curl -fsSL -o "${tmpdeb}" "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VER}/hugo_${HUGO_VER}_linux-amd64.deb"
  sudo apt -y install "${tmpdeb}"
fi

echo "[+] Hugo version: $(hugo version || true)"

# -------- Detect if inside repo --------
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "[i] Running inside existing repo: $(git rev-parse --show-toplevel)"
  cd "$(git rev-parse --show-toplevel)"
else
  echo "[i] No repo detected here. Cloning into ${REPO_DIR}..."
  mkdir -p "$(dirname "${REPO_DIR}")"
  if [[ ! -d "${REPO_DIR}/.git" ]]; then
    git clone "${REPO_URL}" "${REPO_DIR}"
  fi
  cd "${REPO_DIR}"
fi

# Track whether we made commits
MADE_COMMITS=0

# -------- Add .gitattributes --------
if [[ ! -f .gitattributes ]]; then
  cat > .gitattributes <<'EOF'
* text=auto eol=lf
*.sh   text eol=lf
*.md   text eol=lf
*.toml text eol=lf
*.yaml text eol=lf
*.yml  text eol=lf
*.html text eol=lf
*.css  text eol=lf
*.js   text eol=lf
EOF
  git add .gitattributes || true
  if git commit -m "Normalize line endings (LF) for WSL-safe builds"; then
    MADE_COMMITS=1
  fi
fi

# -------- Add .editorconfig --------
if [[ ! -f .editorconfig ]]; then
  cat > .editorconfig <<'EOF'
root = true
[*]
end_of_line = lf
insert_final_newline = true
charset = utf-8
indent_style = space
indent_size = 2
EOF
  git add .editorconfig || true
  if git commit -m "Add .editorconfig"; then
    MADE_COMMITS=1
  fi
fi

# -------- Submodule setup --------
if grep -q 'path = themes/blowfish' .gitmodules 2>/dev/null; then
  git config -f .gitmodules submodule.themes/blowfish.branch main
  git submodule sync --recursive
  git submodule update --init --recursive
  git submodule update --remote --merge --recursive || true

  if git status --porcelain themes/blowfish | grep -q .; then
    git add themes/blowfish
    if git commit -m "Update Blowfish submodule (bootstrap)"; then
      MADE_COMMITS=1
    fi
  fi
fi

echo "[+] Submodule status:"
git submodule status || true

# -------- Auto push if requested --------
if [[ "${AUTO_PUSH}" == "true" && "${MADE_COMMITS}" -eq 1 ]]; then
  CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  echo "[+] Auto-pushing to origin/${CURRENT_BRANCH} (AUTO_PUSH=true)"
  git push -u origin "${CURRENT_BRANCH}"
else
  echo "[i] AUTO_PUSH=${AUTO_PUSH}. No auto-push performed."
fi

echo "[✓] Done. Try: 'make dev' or 'hugo serve --disableFastRender'"

