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
git clone https://github.com/Fize/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script will install and configure: Go, Rust, Node.js (nvm), Neovim, lazygit, zsh (Oh My Zsh), tmux, and related tools. All operations are idempotent — safe to re-run.

### Options

| Flag | Description |
|------|-------------|
| `--terminal-cmd <path>` | Append `export CODEBUDDY_CMD="<path>"` to `~/.zshrc` (used by `coder/claudecode.nvim` as `terminal_cmd`). |

### Non-interactive mode

```bash
NONINTERACTIVE=1 ./install.sh     # skip the initial Enter prompt, auto-backup ~/.zshrc
```

The install log is written to `~/.dotfiles_install.log`.

## Supported Systems

- **Linux**: Ubuntu, Debian, Fedora, TencentOS
- **macOS**: Darwin (Homebrew)
- **Windows**: WSL2

Integration tests run the installer inside Docker for `ubuntu:22.04`, `debian:bookworm`, and `fedora:latest`:

```bash
./tests/docker_integration.sh
```

## What Gets Installed

| Category | Packages |
|----------|----------|
| Core | curl, unzip, zsh, tmux, ag/the_silver_searcher, bat, fd, ripgrep, fzf, eza, ccat, luajit |
| Shell tooling | shfmt (brew / apt / dnf; TencentOS falls back to a GitHub release binary) |
| Languages | Go, Rust (rustup), Node.js LTS (nvm) |
| Editors | Neovim, lazygit |
| Neovim tooling | tree-sitter-cli, ImageMagick, ghostscript, tectonic, mermaid-cli (`mmdc`) |
| Shell | Oh My Zsh, zsh-autosuggestions, zsh-syntax-highlighting, Powerlevel10k |

On Linux, if `nvim` is absent it is built from source (`neovim/neovim`, `stable` branch) into `/usr/local`.

## Config Files

| File | Target |
|------|--------|
| `init.lua`, `lua/` | `~/.config/nvim` → symlinked to the repo root |
| `config.zsh` | copied to `~/.zshrc` |
| `p10k.zsh` | symlinked to `~/.p10k.zsh` |
| `tmux.conf` | symlinked to `~/.tmux.conf` |
| `ghostty.config` | symlinked to `~/.config/ghostty/config` |

`install.sh` backs up any pre-existing regular file before replacing it (`.bak.<timestamp>`), so re-running is safe.

## Terminal

Ghostty is the primary configured terminal. Also usable: iTerm2, Windows Terminal.

The Ghostty config sets:

| Setting | Value |
|---------|-------|
| Theme | Solarized Dark Higher Contrast |
| Font | LXGW WenKai Mono, Cascadia Code NF |
| Font Size | 15 |
| Window Theme | system |
| Background Blur Radius | 20 |
| Background Image | `cat.png` (opacity 0.15, fit stretch) |
| Cursor | `e5c07b`, block, blink |
| Custom Shader | `cursor_blaze.glsl` (animated) |

Inline image previews from Neovim use the **Kitty graphics protocol** (`3rd/image.nvim` with `backend = "kitty"`, `processor = "magick_cli"`). This requires a Kitty-protocol terminal such as Ghostty or Kitty; tmux users also need passthrough enabled (`set -g allow-passthrough on` is already set in `tmux.conf`). Image previews require **ImageMagick** (`magick` or `convert`), and Mermaid diagram rendering requires the **Mermaid CLI** (`mmdc`). `install.sh` attempts to install both when they are missing.

## Neovim

Built on [LazyVim](https://www.lazyvim.org/). Plugins are declared under `lua/plugins/`, extras are listed in `lazyvim.json` and managed via `:LazyExtra`.

### Enabled Extras

| Category | Extras |
|----------|--------|
| AI | claudecode |
| Editor | aerial, fzf, leap, neo-tree, telescope |
| Formatting | prettier |
| Lang | go, json, markdown, python, toml, yaml |
| UI | smear-cursor |
| Util | gitui |

### Custom Plugins

| File | Plugin | Notes |
|------|--------|-------|
| `claudecode.lua` | `coder/claudecode.nvim` | Keys under `<leader>cc*`; uses `CODEBUDDY_CMD` when set |
| `colorscheme.lua` | `svrana/neosolarized.nvim` | neosolarized, italic comments |
| `diagram.lua` | `3rd/diagram.nvim` | `<leader>md` renders the diagram under the cursor (markdown) |
| `image.lua` | `3rd/image.nvim` | Kitty backend, magick_cli processor |
| `markdown.lua` | `render-markdown.nvim`, treesitter latex | Disables markdown linters |
| `editor.lua` | autopairs, surround, leap, neo-tree, goyo, limelight, vim-visual-multi, interestingwords | Overrides the LazyVim leap extra mappings, which otherwise bind `s`/`S`/`gs` to non-existent `<Plug>` targets |
| `toggleterm.lua` | `akinsho/toggleterm.nvim` | `<leader>tf` float, `<leader>th` horizontal, `<leader>tv` vertical, `<leader>tn` name, `<leader>ts` select — all opened at the project root |

## Shell

- Oh My Zsh with Powerlevel10k (`ZSH_THEME="powerlevel10k/powerlevel10k"`).
- Plugins: git, fzf, docker, kubectl, zsh-autosuggestions, zsh-syntax-highlighting.
- Aliases include `ls`/`ll` → `eza`, `k` → `kubectl`, `c` → `ccat`, `ghcs`/`ghce` for GitHub Copilot.

## Tmux

Standalone `tmux.conf` (not based on a third-party framework):

- Prefix `C-b`, secondary prefix `C-a`.
- Pane split: `_` horizontal / `|` vertical (current path preserved).
- Vi-style pane navigation `h/j/k/l`, resize `H/J/K/L`.
- `allow-passthrough on`, `extended-keys` with `csi-u` format (needed by modern TUI apps).
- Mouse on, 50k scrollback, base index 1, vi mode-keys.

## pi agent setup

`pi-init.sh` bootstraps the [pi](https://github.com/) coding agent separately from the main installer:

```bash
./pi-init.sh
```

It is idempotent and will:

1. Ensure Node.js is available (nvm on Linux).
2. Install `@earendil-works/pi-coding-agent`.
3. Merge `pi-settings.json` into `~/.pi/agent/settings.json` (only missing keys are added).
4. Merge `pi-models.json` providers into `~/.pi/agent/models.json`.
5. Install the extensions listed in `PI_EXTENSIONS` (subagents, web-access, todo, plan-mode, lsp, usage, simplify, add-dir, autoresearch, plannotator, …).

Log: `~/.pi_init.log`.

## Other Files

| File | Purpose |
|------|---------|
| `stylua.toml` | StyLua formatting config (2-space indent, 120 columns) — run `stylua lua/` before committing |
| `clash.yaml` | Proxy client config (HTTP 7890 / SOCKS5 7891) |
| `cat.png` | Ghostty background image |
| `cursor_blaze.glsl` | Ghostty custom shader |

## License

See [LICENSE](LICENSE).
