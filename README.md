# dotfiles

Dotfile and configuration for my development environment.

## Prerequisites

Run the following on a fresh system **before** executing `install.sh`:

**macOS**

```bash
xcode-select --install          # git, curl, etc.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"  # Homebrew
```

**Ubuntu / Debian**

```bash
sudo apt update && sudo apt install -y git curl sudo
```

**Fedora / TencentOS**

```bash
sudo dnf install -y git curl sudo
```

## Install

```bash
git clone https://github.com/<your-user>/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script will install and configure: Go, Rust, Node.js (nvm), Neovim, lazygit, zsh (Oh My Zsh), tmux, and related tools. All operations are idempotent — safe to re-run.

## Supported Systems

- **Linux**: Ubuntu, Debian, Fedora, TencentOS
- **macOS**: Darwin (Homebrew)
- **Windows**: WSL2

## Terminal

- Ghostty
- iTerm2
- Windows Terminal

## Neovim Extras

Enabled via `:LazyExtra`:

| Category | Extras |
|----------|--------|
| AI | avante, claudecode |
| Editor | aerial, fzf, leap, neo-tree, telescope |
| Formatting | prettier |
| Lang | go, json, markdown, python, toml, yaml |
| UI | smear-cursor |
| Util | gitui |
