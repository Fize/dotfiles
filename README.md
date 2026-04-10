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

- **Kaku** (Recommended for macOS) - AI-ready terminal based on WezTerm
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

---

## Kaku Terminal (macOS)

[Kaku](https://github.com/tw93/kaku) is a fast, AI-ready terminal emulator based on WezTerm, optimized for macOS.

### Installation

```bash
# Install via Homebrew
brew install tw93/tap/kakuku

# Or download DMG from GitHub releases
# https://github.com/tw93/kaku/releases
```

### Configuration

This dotfiles repo includes a pre-configured `kaku.lua`:

```bash
# Link the config
mkdir -p ~/.config/kaku
ln -sf ~/dotfiles/kaku.lua ~/.config/kaku/kaku.lua

# Initialize shell integration
/Applications/Kaku.app/Contents/MacOS/kaku init --update-only && exec zsh -l
```

### Current Settings

| Setting | Value |
|---------|-------|
| Font | LXGW WenKai Mono |
| Font Size | 16.0 |
| Theme | Kaku Dark |
| Tab Bar | Bottom |

### Useful Commands

```bash
kaku doctor          # Check configuration health
kaku ai              # Configure AI assistant
kaku update          # Update to latest version
```

### Key Bindings

| Action | Shortcut |
|--------|----------|
| New Tab | `Cmd + T` |
| Split Vertical | `Cmd + D` |
| Split Horizontal | `Cmd + Shift + D` |
| AI Panel | `Cmd + Shift + A` |
| Apply AI Fix | `Cmd + Shift + E` |
| Lazygit | `Cmd + Shift + G` |
| Yazi File Manager | `Cmd + Shift + Y` |
