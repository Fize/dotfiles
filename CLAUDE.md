# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview
This is a personal dotfiles repository containing development environment configurations for zsh, neovim, and tmux. It uses LazyVim as the Neovim configuration framework and includes AI-powered development tools like GitHub Copilot and Avante.nvim.

## Repository Structure
- **Root**: Main configuration files
- **lua/**: Neovim Lua configuration
  - **config/**: Core LazyVim configuration (autocmds, keymaps, lazy.lua, options)
  - **plugins/**: Custom plugin configurations
- **install.sh**: Automated setup script for Linux/macOS
- **config.zsh**: Oh My Zsh configuration template
- **ghostty.config**: Ghostty terminal configuration

## Installation & Setup
```bash
# Initial setup
./install.sh

# Manual symlink creation (if needed)
ln -s $(pwd) ~/.config/nvim
```

## Development Commands

### Neovim/LazyVim
```bash
# Open Neovim with this config
nvim

# Update plugins
nvim +Lazy update

# Check for plugin updates
nvim +Lazy check

# Install extras
nvim +LazyExtra
```

### Configuration Management
```bash
# Format Lua files
stylua lua/

# Check LazyVim configuration
cat lazyvim.json

# View plugin lock file
cat lazy-lock.json
```

### Zsh Configuration
```bash
# Reload zsh config
source ~/.zshrc

# Check current theme
echo $ZSH_THEME

# List enabled plugins
echo $plugins
```

## Key Architecture Components

### Neovim Configuration (LazyVim-based)
- **init.lua**: Entry point that loads config.lazy
- **config.lazy.lua**: LazyVim bootstrap and plugin management
- **Plugin specs**: Uses LazyVim's declarative plugin specification
- **Extras system**: Leverages LazyVim extras for language support and tools

### AI Integration
- **Avante.nvim**: AI coding assistant with multiple provider support
  - Configured providers: copilot, deepseek, moonshot
  - Disabled auto-suggestions (manual trigger only)
- **CopilotChat.nvim**: GitHub Copilot integration
- **blink.cmp**: Modern completion framework

### Development Tools
- **Languages**: Go, Python, Markdown support via LazyVim extras
- **Formatters**: Prettier integration
- **File management**: neo-tree, telescope, fzf
- **Terminal**: toggleterm integration

## Common Customization Points

### Adding New Plugins
1. Create new file in `lua/plugins/`
2. Use LazyVim's plugin specification format
3. Follow existing patterns in avante.lua for configuration

### Environment Variables
Key variables in config.zsh:
- `KUBE_EDITOR="nvim"` - Sets nvim as Kubernetes editor
- `PATH` includes: go/bin, atuin/bin, cargo/bin, nvm, pnpm
- API keys for AI services (commented out by default)

### Theme & Appearance
- Current theme: "dst" (Oh My Zsh)
- Neovim colorscheme: Configured via colorscheme.lua
- Terminal: Ghostty with custom configuration

## Troubleshooting

### Common Issues
1. **Plugin not loading**: Check lazy-lock.json for version conflicts
2. **AI features not working**: Verify API keys in environment variables
3. **Styling issues**: Run `stylua lua/` to format configuration

### Debug Commands
```bash
# Check Neovim health
nvim +checkhealth

# View LazyVim logs
nvim +Lazy log

# Test plugin loading
nvim +Lazy sync
```

## File Patterns
- **Lua configs**: 2-space indentation (stylua.toml)
- **Shell scripts**: Follow install.sh patterns for system detection
- **JSON configs**: Use lazyvim.json format for plugin extras