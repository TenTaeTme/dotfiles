# Neovim Configuration

This is my personal Neovim configuration, designed to work on any system or server. Follow the steps below for a quick setup and installation.

## Prerequisites

Before proceeding with the installation, ensure that the following dependencies are installed on your system:

1. **Neovim**: Version 0.5 or higher is required. Install it using your system's package manager:
   - For Ubuntu/Debian:
     ```bash
     sudo apt update
     sudo apt install neovim
     ```
   - For Arch Linux:
     ```bash
     sudo pacman -S neovim
     ```
   - For MacOS (using Homebrew):
     ```bash
     brew install neovim
     ```

2. **Git**: Ensure Git is installed:
   - For Ubuntu/Debian:
     ```bash
     sudo apt install git
     ```
   - For Arch Linux:
     ```bash
     sudo pacman -S git
     ```
   - For MacOS:
     ```bash
     brew install git
     ```

3. **Node.js and npm**: Required for some Neovim plugins (e.g., for LSP support). Install it via:
   - For Ubuntu/Debian:
     ```bash
     sudo apt install nodejs npm
     ```
   - For MacOS:
     ```bash
     brew install node
     ```

- **C Compiler (Required for building certain Neovim plugins)**:
  - **Ubuntu/Debian**:
    ```bash
    sudo apt install build-essential
    ```
  - **Arch Linux**:
    ```bash
    sudo pacman -S base-devel
    ```
  - **MacOS**:
    ```bash
    xcode-select --install
    ```

- **Golang**:
  - **Ubuntu/Debian**:
    ```bash
    sudo apt install golang-go
    ```
  - **Arch Linux**:
    ```bash
    sudo pacman -S go
    ```
  - **MacOS**:
    ```bash
    brew install go
    ```

4. **Python3 (optional but recommended)**: Install Python 3 support for Neovim:
   - For Ubuntu/Debian:
     ```bash
     sudo apt install python3 python3-pip
     pip3 install pynvim
     ```
   - For MacOS:
     ```bash
     brew install python3
     pip3 install pynvim
     ```

- **Ripgrep and FZF**:
  - **Ripgrep**:
    - **Ubuntu/Debian**:
      ```bash
      sudo apt install ripgrep
      ```
    - **MacOS**:
      ```bash
      brew install ripgrep
      ```
  - **FZF** (for enhanced fuzzy search capabilities):
    - **Ubuntu/Debian**:
      ```bash
      sudo apt install fzf
      ```
    - **MacOS**:
      ```bash
      brew install fzf
      ```

- **LazyGit**:
  - **Ubuntu/Debian**:
    ```bash
    LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit /usr/local/bin
    ```
  - **MacOS**:
    ```bash
    brew install lazygit
    ```
- **unzip**:
  - **Ubuntu/Debian**:
```bash
sudo apt install unzip
 ```

## Installation Steps

Follow the steps below to install this configuration on your system:

### 1. Clone the Repository

Clone this repository into your Neovim configuration directory (`~/.config/nvim`):

```bash
git clone https://github.com/TenTaeTme/nvim_config.git ~/.config/nvim
MasonInstallAll
 ```

