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

| Tool         | Purpose                      | macOS install       | Debian/Ubuntu install       |
| ------------ | ---------------------------- | ------------------- | --------------------------- |
| **Git**      | version control              | `brew install git`  | `sudo apt-get install git`  |
| **GNU Stow** | fast, atomic symlink manager | `brew install stow` | `sudo apt-get install stow` |

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

### Licence

MIT © TenTaeTme
