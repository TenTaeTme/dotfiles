#!/usr/bin/env bash
set -euxo pipefail

# ╭──────────────────────────────────────────────────────────────╮
# │  0) Base packages & essential developer tools                │
# ╰──────────────────────────────────────────────────────────────╯
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  git stow ripgrep fd-find xclip \
  build-essential cmake ninja-build gettext pkg-config \
  curl unzip zsh tmux \
  software-properties-common \
  nodejs npm

# Debian/Ubuntu ship fd as "fdfind" — create a friendly alias
if [ -x /usr/bin/fdfind ] && [ ! -e /usr/local/bin/fd ]; then
  sudo ln -s /usr/bin/fdfind /usr/local/bin/fd
fi

# ╭──────────────────────────────────────────────────────────────╮
# │  1) Neovim (stable) via official PPA (fast and up-to-date)   │
# ╰──────────────────────────────────────────────────────────────╯
sudo apt-get remove -y neovim neovim-runtime || true
sudo apt-get purge  -y neovim neovim-runtime || true
sudo apt-get autoremove -y || true
sudo add-apt-repository -y ppa:neovim-ppa/stable
sudo apt-get update
sudo apt-get install -y neovim
nvim --version | head -n1

# ╭──────────────────────────────────────────────────────────────╮
# │  2) Oh My Zsh (non-interactive, keep existing .zshrc)        │
# ╰──────────────────────────────────────────────────────────────╯
export RUNZSH=no CHSH=no KEEP_ZSHRC=yes
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# ╭──────────────────────────────────────────────────────────────╮
# │  3) fzf (fuzzy finder) + keybindings and completions         │
# ╰──────────────────────────────────────────────────────────────╯
if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all
fi

# ╭──────────────────────────────────────────────────────────────╮
# │  4) zsh-syntax-highlighting plugin for Oh My Zsh             │
# ╰──────────────────────────────────────────────────────────────╯
mkdir -p "$HOME/.oh-my-zsh/custom/plugins"
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
  git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
fi

# ╭──────────────────────────────────────────────────────────────╮
# │  5) Clone dotfiles via SSH (requires GitHub SSH setup)       │
# ╰──────────────────────────────────────────────────────────────╯
if [ ! -d "$HOME/dotfiles" ]; then
  git clone --depth 1 git@github.com:TenTaeTme/dotfiles.git "$HOME/dotfiles"
fi

mkdir -p "$HOME/.config/alacritty" "$HOME/.config/nvim"

# ╭──────────────────────────────────────────────────────────────╮
# │  6) Backup existing conflicting files before stowing         │
# ╰──────────────────────────────────────────────────────────────╯
for f in "$HOME/.zshrc" "$HOME/.tmux.conf"; do
  if [ -e "$f" ] && [ ! -L "$f" ]; then
    mv -v "$f" "${f}.backup.$(date +%Y%m%d%H%M%S)"
  fi
done

# ╭──────────────────────────────────────────────────────────────╮
# │  7) Deploy dotfiles packages via GNU Stow                    │
# ╰──────────────────────────────────────────────────────────────╯
cd "$HOME/dotfiles"
stow -t "$HOME/.config/alacritty" alacritty
stow -t "$HOME/.config/nvim"      nvim
stow -t "$HOME"                   tmux zsh

# Verify symlinks
ls -l "$HOME/.config/alacritty" || true
ls -l "$HOME/.config/nvim"      || true
ls -l "$HOME/.tmux.conf"        || true
ls -l "$HOME/.zshrc"            || true

# ╭──────────────────────────────────────────────────────────────╮
# │  8) Patch ~/.zshrc (managed via Stow) with fzf + ssh-agent   │
# ╰──────────────────────────────────────────────────────────────╯
# Ensure plugin list includes fzf and zsh-syntax-highlighting
if grep -qE '^\s*plugins=\(' "$HOME/.zshrc"; then
  sed -i 's/^\s*plugins=.*/plugins=(git fzf zsh-syntax-highlighting)/' "$HOME/.zshrc"
else
  printf '\nplugins=(git fzf zsh-syntax-highlighting)\n' >> "$HOME/.zshrc"
fi

# Add FZF_BASE and source its scripts if missing
grep -q 'FZF_BASE=' "$HOME/.zshrc" || cat >> "$HOME/.zshrc" <<'ZRC'
# fzf integration
export FZF_BASE="$HOME/.fzf"
[ -f "$FZF_BASE/shell/key-bindings.zsh" ] && source "$FZF_BASE/shell/key-bindings.zsh"
[ -f "$FZF_BASE/shell/completion.zsh"   ] && source "$FZF_BASE/shell/completion.zsh"
ZRC

# Add auto-start ssh-agent block if not already present
grep -q 'AUTO_SSH_AGENT_BEGIN' "$HOME/.zshrc" || cat >> "$HOME/.zshrc" <<'ZRC'
# AUTO_SSH_AGENT_BEGIN
SSH_ENV="$HOME/.ssh/environment"
start_agent() {
  eval "$(ssh-agent -s)" >/dev/null
  [ -f "$HOME/.ssh/id_ed25519" ] && ssh-add -l >/dev/null 2>&1 || ssh-add "$HOME/.ssh/id_ed25519" >/dev/null 2>&1 || true
  {
    echo "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK"
    echo "export SSH_AGENT_PID=$SSH_AGENT_PID"
  } > "$SSH_ENV"
  chmod 600 "$SSH_ENV"
}
if [ -f "$SSH_ENV" ]; then
  # shellcheck disable=SC1090
  source "$SSH_ENV" >/dev/null 2>&1
  ps -p "$SSH_AGENT_PID" >/dev/null 2>&1 || start_agent
else
  start_agent
fi
# AUTO_SSH_AGENT_END
ZRC

# ╭──────────────────────────────────────────────────────────────╮
# │  9) Set Zsh as the default shell                            │
# ╰──────────────────────────────────────────────────────────────╯
if command -v zsh >/dev/null 2>&1; then
  chsh -s "$(command -v zsh)" "$USER" || true
fi

# ╭──────────────────────────────────────────────────────────────╮
# │ 10) Headless bootstrap of Neovim (Lazy/Mason plugin setup)  │
# ╰──────────────────────────────────────────────────────────────╯
nvim --headless "+Lazy! sync" +qa || true
nvim --headless "+MasonUpdate" +qa || true
nvim --headless "+MasonInstallAll" +qa || true

# ╭──────────────────────────────────────────────────────────────╮
# │ 11) Global Git ignores for cache directories                 │
# ╰──────────────────────────────────────────────────────────────╯
if ! git config --global --get core.excludesFile >/dev/null; then
  echo -e ".local/\n.cache/" > "$HOME/.gitignore_global"
  git config --global core.excludesFile "$HOME/.gitignore_global"
fi

# ╭──────────────────────────────────────────────────────────────╮
# │  Install lazygit (latest release from GitHub)                │
# ╰──────────────────────────────────────────────────────────────╯
if ! command -v lazygit >/dev/null 2>&1; then
  echo "Installing lazygit..."
  ARCH=$(dpkg --print-architecture)
  case "$ARCH" in
    amd64)  LG_ARCH="Linux_x86_64" ;;
    arm64)  LG_ARCH="Linux_arm64" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
  esac
  LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_${LG_ARCH}.tar.gz"
  tar -C /tmp -xf /tmp/lazygit.tar.gz lazygit
  sudo install /tmp/lazygit /usr/local/bin/lazygit
  rm -f /tmp/lazygit.tar.gz /tmp/lazygit
fi


# ╭──────────────────────────────────────────────────────────────╮
# │ 12) Final checks                                             │
# ╰──────────────────────────────────────────────────────────────╯
tmux -V || true
zsh --version
node -v
npm -v
rg --version
fd --version || true
nvim --version | head -n1

echo "──────────────────────────────────────────────"
echo "✅ WSL dotfiles bootstrap completed successfully!"
echo "Restart your terminal or run: exec zsh -l"
echo "──────────────────────────────────────────────"

