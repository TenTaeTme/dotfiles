# spik_13 / dotfiles

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

| Tool | Purpose | macOS install | Debian/Ubuntu install |
|------|---------|---------------|-----------------------|
| **Git** | version control | `brew install git` | `sudo apt-get install git` |
| **GNU Stow** | fast, atomic symlink manager | `brew install stow` | `sudo apt-get install stow` |

---

## 1 · Restore on a new machine — **recommended Stow method**

1. **Clone** the repo into `~/dotfiles`

   ```bash
   git clone --depth 1 https://github.com/spik-13/dotfiles.git ~/dotfiles
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

## 2 · Restore without Stow — *manual “just‑moves” alternative*

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

This repo tracks *only* declarative config. Huge plugin caches and logs stay out via `~/.gitignore_global`:

```
.local/
.cache/
```

Configure globally:

```bash
git config --global core.excludesFile ~/.gitignore_global
```

---

## 4 · Updating & contributing

1. Edit files in place inside `~/dotfiles/<package>/…`.
2. Re‑run the matching `stow -t …` if you added new files.
3. Commit & push:

   ```bash
   cd ~/dotfiles
   git add .
   git commit -m "feat(nvim): add spectre.lua mapping"
   git push
   ```

---

## 5 · Troubleshooting

| Symptom | Fix |
|---------|-----|
| `stow: LINK: … already exists` | Remove or backup the conflicting file, then re‑run `stow`. |
| Program ignores config | Verify the symlink target: `ls -l <path>` → should point into `~/dotfiles/…`. |
| Accidentally added plugin binaries | Add the path to `~/.gitignore_global`, `git rm --cached <file>`, commit again. |

---

### Licence

MIT © spik_13 — fork, patch, enjoy.
