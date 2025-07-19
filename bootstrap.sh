#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$HOME/dotfiles"
cd "$REPO_DIR"

# Ensure stow is present
if ! command -v stow >/dev/null ; then
  if command -v brew >/dev/null ;        then brew install stow
  elif command -v apt-get >/dev/null ;   then sudo apt-get install -y stow
  else
    echo "🛑  Please install GNU Stow with your package manager" >&2
    exit 1
  fi
fi

stow -t ~/.config/alacritty   alacritty
stow -t ~/.config/nvim        nvim
stow -t ~                     tmux zsh

echo "✅  Dotfiles linked"
