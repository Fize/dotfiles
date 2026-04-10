#!/usr/bin/env bash
# Author: malzahar
# email: malzaharguo@gmail.com
#
# Idempotent dotfiles installer.
# Supported: macOS (Homebrew), Ubuntu, Debian, Fedora, TencentOS.
# Re-running this script is safe — it skips anything already installed.

set -euo pipefail

# ------------------------------------------------------------
# Logging
# ------------------------------------------------------------
LOG_FILE="${HOME}/.dotfiles_install.log"
log_ts() { date +'%F %T'; }
log_info()  { printf '[%s] INFO:  %s\n' "$(log_ts)" "$*" | tee -a "$LOG_FILE"; }
log_warn()  { printf '[%s] WARN:  %s\n' "$(log_ts)" "$*" | tee -a "$LOG_FILE"; }
log_error() { printf '[%s] ERROR: %s\n' "$(log_ts)" "$*" | tee -a "$LOG_FILE"; }

# ------------------------------------------------------------
# Global variables
# ------------------------------------------------------------
export WORKDIR
WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export OS=""
SUPPORTED_RELEASES=("ubuntu" "debian" "fedora" "tencentos")
TERMINAL_CMD=""

# ------------------------------------------------------------
# Prerequisites prompt
# ------------------------------------------------------------
print_prerequisites() {
    log_info "System requirements check"
    log_info "Ensure the following are installed:"
    if [[ "$(uname)" == "Darwin" ]]; then
        log_info "macOS:"
        log_info "  - Git: xcode-select --install"
        log_info "  - Homebrew: https://brew.sh"
    else
        log_info "Linux:"
        log_info "  - Ubuntu/Debian: sudo apt update && sudo apt install -y git curl"
        log_info "  - Fedora: sudo dnf install -y git curl"
    fi
    if [[ "${NONINTERACTIVE:-0}" != "1" ]]; then
        log_info "Press Enter to continue or Ctrl+C to exit"
        read -r
    fi
}

# ------------------------------------------------------------
# System detection
# ------------------------------------------------------------
check_system() {
    log_info "Checking system type..."
    local system
    system="$(uname)"

    if [[ "$system" != "Linux" && "$system" != "Darwin" ]]; then
        log_error "Unsupported system: $system"
        exit 1
    fi

    if [[ "$system" == "Darwin" ]]; then
        OS="Darwin"
        log_info "Detected: macOS"
        return
    fi

    if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        OS="$(. /etc/os-release && echo "$ID")"
    else
        log_error "Unknown Linux distribution (no /etc/os-release)"
        exit 1
    fi

    local found=false
    for release in "${SUPPORTED_RELEASES[@]}"; do
        if [[ "$OS" == "$release" ]]; then
            found=true
            break
        fi
    done

    if [[ "$found" != "true" ]]; then
        log_error "Unsupported Linux distribution: $OS"
        exit 1
    fi

    log_info "Detected: $OS"
}

# ------------------------------------------------------------
# Helper: check if a command exists
# ------------------------------------------------------------
ensure_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        log_error "Required command not found: $1"
        return 1
    fi
}

# ------------------------------------------------------------
# Package manager helpers (idempotent)
# ------------------------------------------------------------
update_pkg_cache() {
    log_info "Updating package cache..."
    case "$OS" in
        fedora|tencentos) sudo dnf makecache -y 2>/dev/null || log_warn "dnf makecache failed" ;;
        ubuntu|debian)    sudo apt update -y 2>/dev/null || log_warn "apt update failed" ;;
        Darwin)           ;; # brew doesn't need explicit cache update
    esac
}

ensure_pkg() {
    local pkg="$1"
    case "$OS" in
        Darwin)
            if brew list --formula "$pkg" >/dev/null 2>&1; then
                log_info "Already installed (brew): $pkg"
            else
                log_info "Installing (brew): $pkg"
                brew install "$pkg" || { log_warn "brew install failed: $pkg"; return 1; }
            fi
            ;;
        fedora|tencentos)
            if rpm -q "$pkg" >/dev/null 2>&1; then
                log_info "Already installed (rpm): $pkg"
            else
                log_info "Installing (dnf): $pkg"
                sudo dnf install -y "$pkg" || { log_warn "dnf install failed: $pkg"; return 1; }
            fi
            ;;
        ubuntu|debian)
            if dpkg -s "$pkg" >/dev/null 2>&1; then
                log_info "Already installed (dpkg): $pkg"
            else
                log_info "Installing (apt): $pkg"
                sudo apt install -y "$pkg" || { log_warn "apt install failed: $pkg"; return 1; }
            fi
            ;;
    esac
}

# Variant: install a brew cask (macOS only)
ensure_cask() {
    local cask="$1"
    if brew list --cask "$cask" >/dev/null 2>&1; then
        log_info "Already installed (cask): $cask"
    else
        log_info "Installing (cask): $cask"
        brew install --cask "$cask" || log_warn "brew cask install failed: $cask"
    fi
}

# ------------------------------------------------------------
# APT third-party sources (idempotent via --batch --yes)
# ------------------------------------------------------------
setup_apt_sources() {
    log_info "Setting up APT third-party sources..."
    sudo mkdir -p /etc/apt/keyrings

    # eza community repository
    curl -fsSL https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

    sudo apt update -y
}

# ------------------------------------------------------------
# Core packages
# ------------------------------------------------------------
install_core_packages() {
    log_info "Installing core packages..."

    if [[ "$OS" == "Darwin" ]]; then
        local pkgs=(curl unzip zsh tmux the_silver_searcher ccat bat fd ripgrep fzf shfmt eza luajit)
        for pkg in "${pkgs[@]}"; do ensure_pkg "$pkg"; done
    elif [[ "$OS" == "fedora" || "$OS" == "tencentos" ]]; then
        local pkgs=(curl unzip zsh tmux the_silver_searcher bat fd-find ripgrep fzf shfmt)
        for pkg in "${pkgs[@]}"; do ensure_pkg "$pkg"; done

        # eza via COPR
        if ! command -v eza >/dev/null 2>&1; then
            if ! dnf repolist 2>/dev/null | grep -q "atim-eza"; then
                log_info "Enabling COPR repository for eza..."
                sudo dnf copr enable atim/eza -y || log_warn "Failed to enable eza COPR"
            fi
            sudo dnf install -y eza || log_warn "eza install failed"
        else
            log_info "Already installed: eza"
        fi
    else
        # Ubuntu/Debian: build tools + packages
        local build_pkgs=(software-properties-common gnupg ca-certificates ninja-build gettext gcc make g++ cmake)
        for pkg in "${build_pkgs[@]}"; do ensure_pkg "$pkg"; done

        setup_apt_sources

        local pkgs=(curl unzip zsh tmux silversearcher-ag bat fd-find ripgrep fzf shfmt eza)
        for pkg in "${pkgs[@]}"; do ensure_pkg "$pkg"; done
    fi
}

# ------------------------------------------------------------
# Go (macOS: brew / Linux: official binary)
# ------------------------------------------------------------
install_go() {
    if command -v go >/dev/null 2>&1; then
        log_info "Go already installed: $(go version)"
        return 0
    fi

    log_info "Installing Go..."
    if [[ "$OS" == "Darwin" ]]; then
        ensure_pkg go
    else
        local arch
        arch="$(uname -m)"
        case "$arch" in
            x86_64)  arch="amd64" ;;
            aarch64|arm64) arch="arm64" ;;
            *) log_error "Unsupported architecture for Go: $arch"; return 1 ;;
        esac

        local version
        version="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -1)"
        log_info "Downloading Go $version for linux-$arch..."
        curl -fsSL "https://go.dev/dl/${version}.linux-${arch}.tar.gz" -o /tmp/go.tar.gz
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz
        rm -f /tmp/go.tar.gz

        # Make go available in current session
        export PATH="/usr/local/go/bin:$PATH"
        log_info "Go installed: $(go version)"
    fi
}

# ------------------------------------------------------------
# Rust (rustup, all platforms)
# ------------------------------------------------------------
install_rust() {
    if command -v cargo >/dev/null 2>&1; then
        log_info "Rust already installed: $(rustc --version 2>/dev/null || echo 'unknown')"
        return 0
    fi

    log_info "Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # shellcheck disable=SC1091
    source "$HOME/.cargo/env"
    log_info "Rust installed: $(rustc --version)"
}

# ------------------------------------------------------------
# Node.js (macOS: brew / Linux: nvm)
# ------------------------------------------------------------
install_node() {
    if [[ "$OS" == "Darwin" ]]; then
        ensure_pkg node
        return
    fi

    # Linux: use nvm
    export NVM_DIR="${HOME}/.nvm"

    if [[ ! -d "$NVM_DIR" ]]; then
        log_info "Installing nvm..."
        curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    else
        log_info "nvm already installed"
    fi

    # Load nvm into current session
    # shellcheck disable=SC1091
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

    if ! command -v node >/dev/null 2>&1; then
        log_info "Installing Node.js LTS via nvm..."
        nvm install --lts
    else
        log_info "Node.js already installed: $(node --version)"
    fi
}

# ------------------------------------------------------------
# Neovim (macOS: brew / Linux: source build)
# ------------------------------------------------------------
install_neovim() {
    if command -v nvim >/dev/null 2>&1; then
        log_info "Neovim already installed: $(nvim --version | head -1)"
        return 0
    fi

    log_info "Installing Neovim..."
    if [[ "$OS" == "Darwin" ]]; then
        ensure_pkg neovim
    else
        # Ensure build dependencies
        case "$OS" in
            fedora|tencentos)
                local deps=(cmake gcc gcc-c++ make gettext ninja-build unzip curl)
                for dep in "${deps[@]}"; do ensure_pkg "$dep"; done
                ;;
            ubuntu|debian)
                local deps=(cmake ninja-build gettext gcc g++ make unzip curl)
                for dep in "${deps[@]}"; do ensure_pkg "$dep"; done
                ;;
        esac

        local nvim_src="$HOME/neovim"
        if [[ -d "$nvim_src" ]]; then
            log_info "Neovim source directory exists, pulling latest..."
            if cd "$nvim_src"; then
                git pull --ff-only || log_warn "git pull failed, using existing source"
            fi
        else
            log_info "Cloning Neovim..."
            git clone https://github.com/neovim/neovim.git "$nvim_src" || { log_error "clone neovim failed"; return 1; }
        fi

        cd "$nvim_src" || return 1
        git checkout stable || log_warn "checkout stable failed"
        if ! make CMAKE_BUILD_TYPE=RelWithDebInfo; then
            log_error "neovim build failed"
            return 1
        fi
        if ! sudo make install; then
            log_error "neovim install failed"
            return 1
        fi
        cd "$WORKDIR" || true

        sudo ln -sf /usr/local/bin/nvim /usr/bin/nvim 2>/dev/null || true
        log_info "Neovim installed: $(nvim --version | head -1)"
    fi
}

# ------------------------------------------------------------
# lazygit
# ------------------------------------------------------------
install_lazygit() {
    if command -v lazygit >/dev/null 2>&1; then
        log_info "lazygit already installed"
        return 0
    fi

    log_info "Installing lazygit..."
    if [[ "$OS" == "Darwin" ]]; then
        ensure_pkg lazygit
    elif [[ "$OS" == "fedora" || "$OS" == "tencentos" ]]; then
        if ! dnf repolist 2>/dev/null | grep -q "atim-lazygit"; then
            sudo dnf copr enable atim/lazygit -y || log_warn "Failed to enable lazygit COPR"
        fi
        sudo dnf install -y lazygit || log_warn "lazygit install failed"
    else
        # Ubuntu/Debian: install from GitHub release
        local arch
        arch="$(uname -m)"
        case "$arch" in
            x86_64)  arch="x86_64" ;;
            aarch64|arm64) arch="arm64" ;;
            *) log_warn "Unsupported arch for lazygit: $arch"; return 0 ;;
        esac

        local version
        version="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest 2>/dev/null \
            | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')" || true
        if [[ -z "$version" ]]; then
            log_warn "Failed to get lazygit latest version (GitHub API rate limit?), skipping"
            return 0
        fi
        log_info "Downloading lazygit v$version..."
        if curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_${arch}.tar.gz" -o /tmp/lazygit.tar.gz \
            && tar -xzf /tmp/lazygit.tar.gz -C /tmp lazygit \
            && sudo install /tmp/lazygit /usr/local/bin/lazygit; then
            rm -f /tmp/lazygit /tmp/lazygit.tar.gz
            log_info "lazygit installed: $(lazygit --version | head -1)"
        else
            log_warn "lazygit install failed"
            rm -f /tmp/lazygit /tmp/lazygit.tar.gz
        fi
    fi
}

# ------------------------------------------------------------
# Neovim checkhealth tools
# ------------------------------------------------------------
install_nvim_tools() {
    log_info "Installing Neovim checkhealth dependencies..."

    # Ensure build dependencies for cargo-compiled tools (tree-sitter-cli needs libclang)
    if [[ "$OS" != "Darwin" ]]; then
        log_info "Installing cargo build dependencies..."
        case "$OS" in
            fedora|tencentos)
                local deps=(clang-devel pkg-config)
                for dep in "${deps[@]}"; do ensure_pkg "$dep" || true; done
                ;;
            ubuntu|debian)
                local deps=(libclang-dev pkg-config)
                for dep in "${deps[@]}"; do ensure_pkg "$dep" || true; done
                ;;
        esac
    fi

    # imagemagick
    if ! command -v magick >/dev/null 2>&1 && ! command -v convert >/dev/null 2>&1; then
        log_info "Installing imagemagick..."
        case "$OS" in
            Darwin)          ensure_pkg imagemagick || true ;;
            fedora|tencentos) ensure_pkg ImageMagick || true ;;
            ubuntu|debian)   ensure_pkg imagemagick || true ;;
        esac
    else
        log_info "Already installed: imagemagick"
    fi

    # ghostscript
    if ! command -v gs >/dev/null 2>&1; then
        log_info "Installing ghostscript..."
        ensure_pkg ghostscript || true
    else
        log_info "Already installed: ghostscript"
    fi

    # tectonic (macOS: brew / Linux: GitHub release binary)
    if ! command -v tectonic >/dev/null 2>&1; then
        log_info "Installing tectonic..."
        if [[ "$OS" == "Darwin" ]]; then
            ensure_pkg tectonic || true
        else
            local arch
            arch="$(uname -m)"
            local tectonic_target=""
            case "$arch" in
                x86_64)  tectonic_target="x86_64-unknown-linux-gnu" ;;
                aarch64) tectonic_target="aarch64-unknown-linux-musl" ;;
            esac
            if [[ -n "$tectonic_target" ]]; then
                local tec_version
                tec_version="$(curl -fsSL https://api.github.com/repos/tectonic-typesetting/tectonic/releases/latest 2>/dev/null \
                    | grep '"tag_name"' | sed 's/.*"tectonic@\([^"]*\)".*/\1/')" || true
                if [[ -n "$tec_version" ]]; then
                    local tec_url="https://github.com/tectonic-typesetting/tectonic/releases/download/tectonic%40${tec_version}/tectonic-${tec_version}-${tectonic_target}.tar.gz"
                    if curl -fsSL "$tec_url" -o /tmp/tectonic.tar.gz \
                        && tar -xzf /tmp/tectonic.tar.gz -C /tmp \
                        && sudo install /tmp/tectonic /usr/local/bin/tectonic; then
                        rm -f /tmp/tectonic /tmp/tectonic.tar.gz
                        log_info "tectonic installed"
                    else
                        log_warn "tectonic install failed"
                        rm -f /tmp/tectonic /tmp/tectonic.tar.gz
                    fi
                else
                    log_warn "Failed to get tectonic version"
                fi
            else
                log_warn "Unsupported architecture for tectonic: $arch"
            fi
        fi
    else
        log_info "Already installed: tectonic"
    fi

    # tree-sitter-cli
    if ! command -v tree-sitter >/dev/null 2>&1; then
        log_info "Installing tree-sitter-cli..."
        cargo install tree-sitter-cli || log_warn "tree-sitter-cli install failed"
    else
        log_info "Already installed: tree-sitter"
    fi

    # mermaid-cli
    if ! command -v mmdc >/dev/null 2>&1; then
        log_info "Installing mermaid-cli..."
        npm install -g @mermaid-js/mermaid-cli || log_warn "mermaid-cli install failed"
    else
        log_info "Already installed: mmdc"
    fi
}

# ------------------------------------------------------------
# Zsh setup (Oh My Zsh + plugins + config)
# ------------------------------------------------------------
setup_zsh() {
    log_info "Setting up zsh..."

    # Install Oh My Zsh (idempotent: skip if directory exists)
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Installing Oh My Zsh..."
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
            || log_warn "Oh My Zsh install failed"
    else
        log_info "Oh My Zsh already installed"
    fi

    # Install zsh plugins (idempotent: skip if directory exists)
    local zsh_custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    if [[ ! -d "${zsh_custom}/plugins/zsh-autosuggestions" ]]; then
        log_info "Cloning zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "${zsh_custom}/plugins/zsh-autosuggestions" \
            || log_warn "zsh-autosuggestions clone failed"
    else
        log_info "zsh-autosuggestions already installed"
    fi

    if [[ ! -d "${zsh_custom}/plugins/zsh-syntax-highlighting" ]]; then
        log_info "Cloning zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${zsh_custom}/plugins/zsh-syntax-highlighting" \
            || log_warn "zsh-syntax-highlighting clone failed"
    else
        log_info "zsh-syntax-highlighting already installed"
    fi

    # Deploy .zshrc from template (idempotent: always overwrite from template)
    if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
        local backup
        backup="$HOME/.zshrc.bak.$(date +%Y%m%d%H%M%S)"
        log_info "Backing up existing .zshrc to $backup"
        cp "$HOME/.zshrc" "$backup"
    fi
    log_info "Deploying config.zsh -> ~/.zshrc"
    cp -f "${WORKDIR}/config.zsh" "$HOME/.zshrc"

    # Append CodeBuddy terminal command if specified via --terminal-cmd
    if [[ -n "$TERMINAL_CMD" ]]; then
        printf '\n# CodeBuddy terminal command path\nexport CODEBUDDY_CMD="%s"\n' "$TERMINAL_CMD" >> "$HOME/.zshrc"
        log_info "Set CODEBUDDY_CMD=$TERMINAL_CMD in .zshrc"
    fi

    log_info "Zsh setup complete"
}

# ------------------------------------------------------------
# Tmux setup
# ------------------------------------------------------------
setup_tmux() {
    log_info "Setting up tmux..."

    # Clone gpakosz/.tmux (idempotent: skip if exists)
    if [[ ! -d "$HOME/.tmux" ]]; then
        git clone https://github.com/gpakosz/.tmux.git "$HOME/.tmux" \
            || { log_warn "tmux config clone failed"; return 1; }
    else
        log_info "tmux config already cloned"
    fi

    # ~/.tmux.conf -> symlink (idempotent: ln -sf)
    local target="$HOME/.tmux/.tmux.conf"
    local link="$HOME/.tmux.conf"
    if [[ -L "$link" ]] && [[ "$(readlink "$link")" == "$target" ]]; then
        log_info ".tmux.conf symlink already correct"
    else
        if [[ -f "$link" && ! -L "$link" && ! -f "${link}.bak" ]]; then
            log_info "Backing up .tmux.conf"
            mv "$link" "${link}.bak"
        fi
        ln -sf "$target" "$link"
        log_info "Created symlink: .tmux.conf"
    fi

    # ~/.tmux.conf.local: symlink from dotfiles if available, otherwise use default
    local local_tmux_conf="${WORKDIR}/tmux.conf.local"
    local local_link="$HOME/.tmux.conf.local"
    if [[ -f "$local_tmux_conf" ]]; then
        if [[ -L "$local_link" ]] && [[ "$(readlink "$local_link")" == "$local_tmux_conf" ]]; then
            log_info ".tmux.conf.local symlink already correct"
        else
            if [[ -f "$local_link" && ! -L "$local_link" ]]; then
                local backup
                backup="${local_link}.bak.$(date +%Y%m%d%H%M%S)"
                log_info "Backing up existing .tmux.conf.local to $backup"
                mv "$local_link" "$backup"
            fi
            ln -sf "$local_tmux_conf" "$local_link"
            log_info "Created symlink: .tmux.conf.local -> $local_tmux_conf"
        fi
    elif [[ ! -f "$local_link" ]]; then
        cp "$HOME/.tmux/.tmux.conf.local" "$local_link"
        log_info "Copied default .tmux.conf.local"
    else
        log_info ".tmux.conf.local already exists, preserving"
    fi

    log_info "Tmux setup complete"
}

# ------------------------------------------------------------
# Kaku Terminal setup (macOS only)
# ------------------------------------------------------------
setup_kaku() {
    if [[ "$OS" != "Darwin" ]]; then
        log_info "Kaku is macOS-only, skipping"
        return 0
    fi

    log_info "Setting up Kaku Terminal..."

    # Install Kaku via Homebrew
    if [[ ! -d "/Applications/Kaku.app" ]]; then
        log_info "Installing Kaku via Homebrew..."
        brew install tw93/tap/kakuku || log_warn "Kaku install failed"
    else
        log_info "Kaku already installed"
    fi

    # Setup config directory and link config
    local kaku_config_dir="$HOME/.config/kaku"
    mkdir -p "$kaku_config_dir"

    local kaku_lua_target="${WORKDIR}/kaku.lua"
    local kaku_lua_link="${kaku_config_dir}/kaku.lua"

    if [[ -L "$kaku_lua_link" ]] && [[ "$(readlink "$kaku_lua_link")" == "$kaku_lua_target" ]]; then
        log_info "kaku.lua symlink already correct"
    else
        if [[ -f "$kaku_lua_link" && ! -L "$kaku_lua_link" ]]; then
            local backup
            backup="${kaku_lua_link}.bak.$(date +%Y%m%d%H%M%S)"
            log_info "Backing up existing kaku.lua to $backup"
            mv "$kaku_lua_link" "$backup"
        fi
        ln -sf "$kaku_lua_target" "$kaku_lua_link"
        log_info "Created symlink: kaku.lua"
    fi

    # Initialize shell integration
    if [[ -x "/Applications/Kaku.app/Contents/MacOS/kaku" ]]; then
        log_info "Initializing Kaku shell integration..."
        /Applications/Kaku.app/Contents/MacOS/kaku init --update-only 2>/dev/null || log_warn "Kaku init failed"
    fi

    log_info "Kaku setup complete"
}

# ------------------------------------------------------------
# Neovim config symlink
# ------------------------------------------------------------
setup_neovim_config() {
    log_info "Setting up Neovim config..."
    mkdir -p "$HOME/.config"

    local target="$HOME/.config/nvim"

    if [[ -L "$target" ]]; then
        local current
        current="$(readlink "$target")"
        if [[ "$current" == "$WORKDIR" ]]; then
            log_info "Neovim config symlink already correct"
            return 0
        fi
        log_info "Removing incorrect symlink: $current"
        rm "$target"
    elif [[ -d "$target" ]]; then
        local backup
        backup="${target}.bak.$(date +%s)"
        log_info "Backing up existing nvim config to $backup"
        mv "$target" "$backup"
    fi

    ln -s "$WORKDIR" "$target"
    log_info "Created symlink: ~/.config/nvim -> $WORKDIR"
}

# ------------------------------------------------------------
# fd alias for Debian-based systems
# ------------------------------------------------------------
link_fd_alias() {
    if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
        log_info "Creating fd alias for fdfind..."
        sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd || log_warn "Failed to create fd alias"
    fi
}

# ------------------------------------------------------------
# Prompt to change default shell (does NOT execute chsh)
# ------------------------------------------------------------
prompt_chsh() {
    local current_shell
    current_shell="$(basename "$SHELL")"

    if [[ "$current_shell" == "zsh" ]]; then
        log_info "Default shell is already zsh"
        return 0
    fi

    local zsh_path=""
    if   [[ -x /opt/homebrew/bin/zsh ]]; then zsh_path="/opt/homebrew/bin/zsh"
    elif [[ -x /usr/local/bin/zsh ]];    then zsh_path="/usr/local/bin/zsh"
    elif [[ -x /usr/bin/zsh ]];          then zsh_path="/usr/bin/zsh"
    elif [[ -x /bin/zsh ]];              then zsh_path="/bin/zsh"
    fi

    if [[ -n "$zsh_path" ]]; then
        log_info "============================================"
        log_info "To set zsh as your default shell, run:"
        log_info "  chsh -s $zsh_path"
        log_info "Then log out and back in."
        log_info "============================================"
    else
        log_warn "zsh binary not found in standard paths"
    fi
}

# ------------------------------------------------------------
# Main
# ------------------------------------------------------------
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --terminal-cmd)
                TERMINAL_CMD="$2"
                shift 2
                ;;
            *)
                log_warn "Unknown option: $1"
                shift
                ;;
        esac
    done

    print_prerequisites
    check_system

    # Preflight checks
    ensure_cmd curl || exit 1
    ensure_cmd git  || exit 1
    if [[ "$OS" != "Darwin" ]]; then
        ensure_cmd sudo || { log_error "sudo is required on Linux"; exit 1; }
    else
        ensure_cmd brew || { log_error "Homebrew is required on macOS"; exit 1; }
    fi

    log_info "========== Starting Installation =========="

    update_pkg_cache
    install_core_packages

    log_info "========== Installing Languages =========="
    install_go
    install_rust
    install_node

    log_info "========== Installing Neovim =========="
    install_neovim
    install_lazygit
    install_nvim_tools || log_warn "Some nvim tools failed to install (non-critical)"

    log_info "========== Configuring Environment =========="
    setup_zsh
    setup_tmux
    setup_kaku
    setup_neovim_config
    link_fd_alias

    log_info "========== Done =========="
    prompt_chsh
    log_info "Installation complete. Log file: $LOG_FILE"
}

main "$@"
