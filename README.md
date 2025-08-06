# TenTaeTme / dotfiles

One repository to rule my macOS & Linux configs:

```
~/dotfiles
├── alacritty/          # alacritty.toml
├── nvim/               # init.lua + lua/*
├── tmux/               # .tmux.conf
└── zsh/                # .zshrc
```

Each directory is a **Stow package** that symlinks its contents to the exact paths every program expects.

---

## 0 · Requirements

| Tool          | Purpose                             | macOS install              | Debian/Ubuntu install                                                          |
| ------------- | ----------------------------------- | -------------------------- | ------------------------------------------------------------------------------ |
| Git           | version control                     | `brew install git`         | `sudo apt-get install -y git`                                                  |
| GNU Stow      | atomic symlink manager              | `brew install stow`        | `sudo apt-get install -y stow`                                                 |
| Ripgrep       | fast project search                 | `brew install ripgrep`     | `sudo apt-get install -y ripgrep`                                              |
| fd            | user-friendly find                  | `brew install fd`          | `sudo apt-get install -y fd-find`                                              |
| Build tools   | build Neovim from source            | `brew install cmake ninja` | `sudo apt-get install -y cmake ninja-build gettext pkg-config build-essential` |
| Node.js + npm | npm-based LSP/formatters via Mason  | `brew install node`        | `sudo apt-get install -y nodejs npm`                                           |
| Go (1.22+)    | Go LSP/tools via Mason              | `brew install go`          | see Debian full restore block (backports)                                      |
| lazygit       | TUI git client                      | `brew install lazygit`     | installed by Debian full restore block                                         |
| xclip         | Linux clipboard provider for Neovim | —                          | `sudo apt-get install -y xclip`                                                |

---

## 1 · Restore on a new machine — **recommended Stow method**

1. **Clone** the repo into `~/dotfiles`

   ```bash
   git clone --depth 1 https://github.com/TenTaeTme/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. **Link every package** exactly where it belongs

   ```bash
   # GUI apps (under ~/.config):
   stow -t ~/.config/alacritty   alacritty
   stow -t ~/.config/nvim        nvim

   # Home-rooted files:
   stow -t ~                     tmux zsh
   ```

3. **All‑in‑one** script

   ```bash
   ~/dotfiles/bootstrap.sh
   ```

---

## 1.1

### Debian server full restore

If you want to restore the full Debian server config, run:

```bash
set -euxo pipefail

# 0) Clone dotfiles (if not present)
[ -d /root/dotfiles ] || {
  command -v git >/dev/null 2>&1 || { apt-get update; apt-get install -y git; }
  git clone --depth 1 https://github.com/TenTaeTme/dotfiles.git /root/dotfiles
}

# 1) Base packages, build tools, and runtimes for LSP (Node.js/npm)
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ca-certificates curl locales unzip ripgrep fd-find stow zsh tmux git \
  build-essential cmake ninja-build gettext pkg-config \
  nodejs npm

# 2) Locales (avoid Perl "Setting locale failed" warnings)
sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
update-locale LANG=en_US.UTF-8

# 3) Remove distro Neovim (if any) before installing our own
apt-get remove -y neovim neovim-runtime || true
apt-get purge  -y neovim neovim-runtime || true
apt-get autoremove -y || true
hash -r

# 4) Build Neovim (stable, Release) and install via .deb
mkdir -p /usr/local/src
cd /usr/local/src
rm -rf neovim
git clone https://github.com/neovim/neovim
cd neovim
git checkout stable
make -j"$(nproc)" CMAKE_BUILD_TYPE=Release
cd build
cpack -G DEB
DEB_FILE="$(find . -maxdepth 1 -type f -name 'nvim*.deb' -printf '%T@ %p\n' | sort -nr | head -n1 | cut -d' ' -f2-)"
dpkg -i "$DEB_FILE"
hash -r
nvim --version | head -n1

# Clean up build files
rm -rf /usr/local/src/neovim || true
apt-get clean

# 5) Oh My Zsh (non-interactive) and set Zsh as default shell
export RUNZSH=no CHSH=no KEEP_ZSHRC=yes
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s /usr/bin/zsh root || true

# 6) fzf (official installer) and zsh-syntax-highlighting
if [ ! -d /root/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf
  /root/.fzf/install --all
fi
if [ ! -d /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
  git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
    /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

# 7) fd binary name on Debian is "fdfind" — add a friendly symlink
[ -x /usr/bin/fdfind ] && ln -sf /usr/bin/fdfind /usr/local/bin/fd

# 8) Deploy dotfiles via GNU Stow
mkdir -p /root/.config/alacritty /root/.config/nvim
cd /root/dotfiles
chmod +x ./bootstrap.sh
./bootstrap.sh

# 9) ~/.zshrc: enable plugins and fzf
if grep -qE '^\s*plugins=\(' /root/.zshrc; then
  sed -i 's/^\s*plugins=.*/plugins=(git fzf zsh-syntax-highlighting)/' /root/.zshrc
else
  echo 'plugins=(git fzf zsh-syntax-highlighting)' >> /root/.zshrc
fi
grep -q 'FZF_BASE=' /root/.zshrc || cat >> /root/.zshrc <<'ZRC'
# fzf (installed in ~/.fzf)
[ -x /root/.fzf/bin/fzf ] && export FZF_BASE=/root/.fzf
[ -f /root/.fzf/shell/key-bindings.zsh ] && source /root/.fzf/shell/key-bindings.zsh
[ -f /root/.fzf/shell/completion.zsh ]   && source /root/.fzf/shell/completion.zsh
ZRC

# 10) Install modern Go (1.22+) from backports and clean broken GOROOT
unset GOROOT || true
sed -i '/GOROOT/d' /root/.zshrc || true
sed -i '/GOROOT/d' /root/.profile || true
sed -i '/GOROOT/d' /etc/environment || true
apt-get remove -y golang-go || true
apt-get purge  -y golang-go || true
apt-get autoremove -y || true

BACKPORTS_FILE="/etc/apt/sources.list.d/backports-go.list"
grep -q '^deb .* bookworm-backports ' "$BACKPORTS_FILE" 2>/dev/null || \
  echo 'deb http://deb.debian.org/debian bookworm-backports main' > "$BACKPORTS_FILE"
apt-get update
apt-get -t bookworm-backports install -y golang-1.22-go
update-alternatives --install /usr/bin/go go /usr/lib/go-1.22/bin/go 100
update-alternatives --install /usr/bin/gofmt gofmt /usr/lib/go-1.22/bin/gofmt 100

# 11) GOPATH/GOBIN for Go tools (both persistent and current session)
grep -q 'export GOPATH=' /root/.zshrc || cat >> /root/.zshrc <<'ZRC'
# Go env for tools installed by Mason/Go
export GOPATH=/root/go
export GOBIN=/root/go/bin
export PATH=$GOBIN:$PATH
ZRC
export GOPATH=/root/go
export GOBIN=/root/go/bin
export PATH=$GOBIN:$PATH
hash -r
go version
go env GOROOT GOPATH GOBIN

# 12) Install latest lazygit
ARCH="$(dpkg --print-architecture)"
case "$ARCH" in
  amd64)  LG_ARCH="Linux_x86_64" ;;
  arm64)  LG_ARCH="Linux_arm64"  ;;
  *)      echo "Unsupported arch: $ARCH"; exit 1 ;;
esac
LAZYGIT_VERSION="$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": "v\K[^"]*')"
curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_${LG_ARCH}.tar.gz"
tar -C /tmp -xf /tmp/lazygit.tar.gz lazygit
install /tmp/lazygit /usr/local/bin
rm -f /tmp/lazygit.tar.gz /tmp/lazygit
lazygit --version || true

# 12.1) Install xclip (clipboard support for Neovim)
apt-get install -y xclip || true

# 13) Preload Neovim plugins and install LSP/formatters via Mason (headless)
nvim --headless "+Lazy! sync" +qa || true
nvim --headless "+MasonUpdate" +qa || true
nvim --headless "+MasonInstallAll" +qa || true

# 14) Quick checks and enter Zsh as login shell
tmux -V
zsh --version
node -v
npm -v
go version
lazygit --version || true
nvim --version | head -n1
fzf --version || true
exec zsh -l

# NOTE: inside Neovim you can also run :MasonInstallAll (if your config uses mason-tool-installer).
```

---

## 2 · Restore without Stow — _manual “just‑moves” alternative_

Use this only if you can’t install Stow (minimal rescue shell, Docker scratch image, etc.).

```bash
# ── Alacritty ───────────────────────────────────────────
mkdir -p ~/.config/alacritty
cp -R ~/dotfiles/alacritty/alacritty.toml           ~/.config/alacritty/

# ── Neovim ─────────────────────────────────────────────
mkdir -p ~/.config/nvim
cp -R ~/dotfiles/nvim/*                             ~/.config/nvim/

# ── Tmux & Zsh ─────────────────────────────────────────
cp    ~/dotfiles/tmux/.tmux.conf                    ~/.tmux.conf
cp    ~/dotfiles/zsh/.zshrc                         ~/.zshrc
```

---

## 3 · Ignoring noisy runtime folders

This repo tracks _only_ declarative config. Huge plugin caches and logs stay out via `~/.gitignore_global`:

```
.local/
.cache/
```

Configure globally:

```bash
git config --global core.excludesFile ~/.gitignore_global
```

---

## 4 · Troubleshooting

| Symptom                            | Fix                                                                            |
| ---------------------------------- | ------------------------------------------------------------------------------ |
| `stow: LINK: … already exists`     | Remove or backup the conflicting file, then re‑run `stow`.                     |
| Program ignores config             | Verify the symlink target: `ls -l <path>` → should point into `~/dotfiles/…`.  |
| Accidentally added plugin binaries | Add the path to `~/.gitignore_global`, `git rm --cached <file>`, commit again. |

---

# tmux — quick‑start & key sheet 🧠🔋

## 1 · Launch a session

```bash
tmux new -s <name>       # e.g. tmux new -s demo
```

Starts a new multiplexer named **demo** and drops you in window 1.

---

## 2 · Detach & come back

| Action                      | Keys / Command     |
| --------------------------- | ------------------ |
| Detach from current session | **Ctrl-A d**       |
| List sessions               | `tmux ls`          |
| Re‑attach to last session   | `tmux a`           |
| Attach to a specific one    | `tmux a -t <name>` |

---

## 3 · Create / move between windows

| Action              | Keys         |
| ------------------- | ------------ |
| New window          | **Ctrl‑A c** |
| Next window         | **Ctrl‑A l** |
| Previous window     | **Ctrl‑A h** |
| Jump to last window | **Tab**      |
| Rename window       | **Ctrl‑A ,** |

Windows are numbered from **1**; the status bar shows them as `1:zsh 2:vim …`.

---

## 4 · Split & navigate panes

| Split                      | Key                         | Navigate | Key          |
| -------------------------- | --------------------------- | -------- | ------------ |
| Horizontal (stack)         | **Ctrl‑A -**                | Left     | **Ctrl‑A h** |
| Vertical (side‑by‑side)    | **Ctrl‑A \_**               | Down     | **Ctrl‑A j** |
|                            |                             | Up       | **Ctrl‑A k** |
|                            |                             | Right    | **Ctrl‑A l** |
| Swap with next / prev pane | **Ctrl‑A >** / **Ctrl‑A <** |
| Resize pane (2 cells)      | **Ctrl‑A Shift‑H/J/K/L**    |

---

## 5 · Copy‑mode & clipboard (macOS)

| Action               | Keys          |
| -------------------- | ------------- |
| Enter copy‑mode      | **Ctrl‑A [`** |
| Start selection      | **v**         |
| Copy & leave         | **y**         |
| Paste in another app | **⌘‑V**       |

tmux pipes the selection to `pbcopy`, so it lands in the OS clipboard.

---

## 6 · Session housekeeping

| Task                        | How                     |
| --------------------------- | ----------------------- |
| Reload `~/.tmux.conf`       | **Ctrl‑A r**            |
| Edit config in a new window | **Ctrl‑A e**            |
| Kill current pane           | `exit` or **Ctrl‑D**    |
| Kill current window         | `Ctrl‑A : kill-window`  |
| Kill whole session          | `Ctrl‑A : kill-session` |

(The prompt opens with **Ctrl‑A :**.)

---

## 7 · Understanding the status bar

```
❐ demo ▶ 1:zsh 2:vim 🔋 82 % | 🧠 48 %  18:42 | 20 Jul
│ │   │              │          │            │
│ │   │              │          │            └── clock & date
│ │   │              │          └────────────── RAM used (%)
│ │   │              └───────────────────────── battery (%)
│ │   └──────────────────────────────────────── windows list
│ └──────────────────────────────────────────── session name
└────────────────────────────────────────────── separators
```

Prefix is **Ctrl‑A** — **Ctrl‑B** is unbound.

Happy multiplexing! 🪄

### License

MIT © TenTaeTme
