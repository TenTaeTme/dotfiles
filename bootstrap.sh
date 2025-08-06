#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# --- Resolve repository root even if the script is called from elsewhere ---
# Priority: $REPO_DIR env -> git toplevel -> script's parent dir
REPO_DIR="${REPO_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || true)}"
if [[ -z "${REPO_DIR}" ]]; then
  # Fall back to script location: <repo>/scripts/bootstrap.sh or <repo>/bootstrap.sh
  SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
  REPO_DIR="$(cd "$SCRIPT_DIR"/.. 2>/dev/null || cd "$SCRIPT_DIR" && pwd -P)"
fi
cd "$REPO_DIR"

# --- Determine XDG config dir (default to ~/.config) ---
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# --- Ensure GNU Stow is available ---
if ! command -v stow >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    brew install stow
  elif command -v apt-get >/dev/null 2>&1; then
    if [ "${EUID:-$(id -u)}" -ne 0 ]; then SUDO="sudo"; else SUDO=""; fi
    $SUDO apt-get update -y || true
    $SUDO apt-get install -y stow
  else
    echo "🛑  Please install GNU Stow with your package manager (brew/apt…)" >&2
    exit 1
  fi
fi

# --- Create target directories up front (Stow expects existing targets) ---
mkdir -p "$XDG_CONFIG_HOME/alacritty" \
         "$XDG_CONFIG_HOME/nvim"

# --- Helper: restow packages into a given target (idempotent) ---
stow_into() {
  local target="$1"; shift
  # -R: restow (safe to re-run)
  # -v: a bit of verbosity is handy
  stow -Rv -t "$target" "$@"
}

# --- Only stow what actually exists in the repo ---
[[ -d "$REPO_DIR/alacritty" ]] && stow_into "$XDG_CONFIG_HOME/alacritty" alacritty
[[ -d "$REPO_DIR/nvim"      ]] && stow_into "$XDG_CONFIG_HOME/nvim"      nvim
[[ -d "$REPO_DIR/tmux"      ]] && stow_into "$HOME"                      tmux
[[ -d "$REPO_DIR/zsh"       ]] && stow_into "$HOME"                      zsh

echo "✅  Dotfiles linked via GNU Stow"
