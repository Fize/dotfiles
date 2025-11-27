#!/usr/bin/env bash
# Author: malzahar
# email: malzaharguo@gmail.com

# ------------------------------------------------------------
# Logging
# ------------------------------------------------------------
LOG_FILE="${HOME}/.dotfiles_install.log"
log_ts() { date +'%F %T'; }
log_info() { printf '[%s] INFO: %s\n' "$(log_ts)" "$*" | tee -a "$LOG_FILE"; }
log_warn() { printf '[%s] WARN: %s\n' "$(log_ts)" "$*" | tee -a "$LOG_FILE"; }
log_error() { printf '[%s] ERROR: %s\n' "$(log_ts)" "$*" | tee -a "$LOG_FILE"; }

print_prerequisites() {
    log_info "System requirements check"
    log_info "Ensure the following are installed:"
    if [[ $(uname) == "Darwin" ]]; then
        log_info "macOS:"
        log_info "- Git (xcode-select --install)"
        log_info "- Homebrew (/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\")"
    else
        log_info "Linux:"
        log_info "- Ubuntu/Debian: sudo apt update && sudo apt install -y git"
        log_info "- Fedora: sudo dnf install -y git"
    fi
    log_info "Press Enter to continue or Ctrl+C to exit"
    read
}

export support_release=("Ubuntu" "Debian" "Fedora" "tencentos")
export WORKDIR=$(pwd)
export NODE_MAJOR=20

# ------------------------------------------------------------
# Preflight helpers
# ------------------------------------------------------------
ensure_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        log_error "Required command not found: $1"
        return 1
    fi
    return 0
}

setup_apt_sources() {
    sudo mkdir -p /etc/apt/keyrings || return 1
    # NodeSource
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg || return 1
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list >/dev/null || return 1
    # eza community
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg || return 1
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null || return 1
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list || return 1
}

ensure_pkg() {
    local pkg="$1"
    case "$OS" in
        Darwin)
            if ! brew list --versions "$pkg" >/dev/null 2>&1; then
                log_info "brew install $pkg"
                brew install "$pkg" || { log_error "brew install failed: $pkg"; return 1; }
            fi
            ;;
        fedora|tencentos)
            sudo dnf -y update || return 1
            sudo dnf -y install "$pkg" || { log_error "dnf install failed: $pkg"; return 1; }
            ;;
        ubuntu|debian)
            sudo apt -y update || return 1
            sudo apt -y install "$pkg" || { log_error "apt install failed: $pkg"; return 1; }
            ;;
    esac
}

link_fd_alias() {
    if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
        sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd || log_warn "Failed to create fd alias"
    fi
}

install_neovim_from_source() {
    if command -v nvim >/dev/null 2>&1; then
        log_info "Neovim already installed, skipping source build"
        return 0
    fi
    cd ~ || return 1
    git clone https://github.com/neovim/neovim || { log_warn "clone neovim failed"; return 1; }
    cd neovim || return 1
    git checkout stable || log_warn "checkout stable failed"
    make CMAKE_BUILD_TYPE=RelWithDebInfo && sudo make install || { log_warn "neovim build/install failed"; return 1; }
    cd "$WORKDIR" || true
}

check_system() {
    log_info "Checking system type"

    local system=$(uname)
    if [[ ${system} != "Linux" && ${system} != "Darwin" ]]; then
        log_error "Unsupported system type: ${system}"
        exit 1
    fi

    if [[ ${system} == "Linux" ]]; then
        if [[ -f /etc/os-release ]]; then
            export OS=$(. /etc/os-release && echo $ID)
        else
            log_error "Unknown Linux distribution"
            exit 1
        fi
    else
        export OS="Darwin"
    fi

    if [[ ${OS} == "Darwin" ]]; then
        log_info "Detected system: macOS"
        return
    fi

    for release in "${support_release[@]}"; do
        if [[ ${OS} == $(echo "$release" | tr '[:upper:]' '[:lower:]') ]]; then
            log_info "Detected system: ${release}"
            return
        fi
    done

    log_error "Unsupported Linux distribution: ${OS}"
    exit 1
}

install_core_package() {
    log_info "Installing core packages..."
    
    # Common packages
    ensure_pkg curl
    ensure_pkg unzip
    ensure_pkg zsh
    ensure_pkg tmux

    if [[ ${OS} == "Darwin" ]]; then
        local mac_pkgs=(the_silver_searcher ccat bat fd)
        for pkg in "${mac_pkgs[@]}"; do ensure_pkg "$pkg"; done
        brew install --cask latexit || log_warn "brew cask latexit failed or skipped"
    elif [[ ${OS} == "fedora" || ${OS} == "tencentos" ]]; then
        local fedora_pkgs=(the_silver_searcher bat fd-find)
        for pkg in "${fedora_pkgs[@]}"; do ensure_pkg "$pkg"; done
    else
        # Apt specific build tools
        local apt_pkgs=(software-properties-common gnupg ca-certificates ninja-build gettext gcc make g++ cmake luajit silversearcher-ag latex2text)
        for pkg in "${apt_pkgs[@]}"; do ensure_pkg "$pkg"; done
    fi
}

install_package() {
    log_info "Installing extra packages..."

    if [[ ${OS} == "Darwin" ]]; then
        local mac_pkgs=(go node ripgrep shfmt atuin luajit eza)
        for pkg in "${mac_pkgs[@]}"; do ensure_pkg "$pkg"; done
        brew install --HEAD neovim || log_warn "neovim --HEAD install failed or skipped"
    elif [[ ${OS} == "fedora" || ${OS} == "tencentos" ]]; then
        # Install Atuin
        if ! command -v atuin >/dev/null; then
             bash <(curl https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh) || log_warn "atuin install failed"
        fi

        # Enable COPR for eza if not available
        if ! dnf list eza >/dev/null 2>&1; then
            log_info "Enabling COPR repository for eza..."
            sudo dnf copr enable atim/eza -y || log_warn "Failed to enable eza COPR"
        fi

        local fedora_pkgs=(python3-devel python3-pip nodejs npm ripgrep shfmt golang eza)
        for pkg in "${fedora_pkgs[@]}"; do ensure_pkg "$pkg"; done

        install_neovim_from_source
        sudo ln -sf /usr/local/bin/nvim /usr/bin/nvim
    else
        # Apt
        if ! command -v atuin >/dev/null; then
             bash <(curl https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh) || log_warn "atuin install failed"
        fi

        setup_apt_sources || log_warn "apt sources setup failed"
        sudo apt update -y

        local apt_pkgs=(python3-dev python3-pip silversearcher-ag fd-find nodejs shfmt ripgrep eza)
        for pkg in "${apt_pkgs[@]}"; do ensure_pkg "$pkg"; done

        install_neovim_from_source
        sudo ln -sf /usr/local/bin/nvim /usr/bin/nvim
    fi
}

setup_zsh() {
    log_info "Setting up zsh..."
    
    # Install Oh My Zsh if not exists
    if [[ ! -d ~/.oh-my-zsh ]]; then
        log_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended || log_warn "Oh My Zsh install failed"
    else
        log_info "Oh My Zsh already installed"
    fi

    # Install zsh plugins
    local zsh_custom=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
    
    if [[ ! -d ${zsh_custom}/plugins/zsh-autosuggestions ]]; then
        log_info "Cloning zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions ${zsh_custom}/plugins/zsh-autosuggestions || log_warn "zsh-autosuggestions clone failed"
    fi

    if [[ ! -d ${zsh_custom}/plugins/zsh-syntax-highlighting ]]; then
        log_info "Cloning zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${zsh_custom}/plugins/zsh-syntax-highlighting || log_warn "zsh-syntax-highlighting clone failed"
    fi

    # Update .zshrc
    if [[ -f ~/.zshrc ]]; then
        log_info "Updating .zshrc plugins..."
        # Simple sed replacement (idempotent enough for this context)
        sed -i.bak 's/plugins=(git)/plugins=(\n    git\n    z\n    fzf\n    docker\n    kubectl\n    golang\n    node\n    npm\n    yarn\n    zsh-autosuggestions\n    zsh-syntax-highlighting\n)/' ~/.zshrc

        # Append custom config if not present
        if ! grep -q "Custom environment variables" ~/.zshrc; then
            log_info "Appending custom configuration to .zshrc..."
            cat >>~/.zshrc <<'EOF'

# Custom environment variables
export HOMEBREW_NO_AUTO_UPDATE=true
export DOCKER_BUILDKIT=1
export GO111MODULE=on
export KUBE_EDITOR="nvim"
export PATH="$PATH:/usr/local/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/.atuin/bin"

# Custom aliases
alias k="kubectl"
alias h="hexctl"
alias c="ccat"
alias ls="eza"
alias ghcs="gh copilot suggest"
alias ghce="gh copilot explain"

# Atuin integration
if command -v atuin &> /dev/null; then
    eval "$(atuin init zsh)"
fi
EOF
        else
            log_info "Custom configuration already present in .zshrc"
        fi
    fi
    log_info "zsh setup complete"
}

setup_tmux() {
    log_info "Setting up tmux..."
    if [[ ! -d ~/.tmux ]]; then
        git clone https://github.com/gpakosz/.tmux.git ~/.tmux || log_warn "tmux config clone failed"
    else
        log_info "tmux config already cloned"
    fi

    if [[ -f ~/.tmux.conf ]]; then
        mv ~/.tmux.conf ~/.tmux.conf.bak
    fi
    if [[ -f ~/.tmux.conf.local ]]; then
        mv ~/.tmux.conf.local ~/.tmux.conf.local.bak
    fi

    ln -s ~/.tmux/.tmux.conf ~/.tmux.conf
    cp ~/.tmux/.tmux.conf.local ~/.tmux.conf.local
    log_info "tmux setup complete"
}

setup_atuin() {
    log_info "Setting up atuin..."
    if ! command -v atuin >/dev/null; then
        log_warn "atuin command not found, skipping setup"
        return
    fi

    atuin import auto || log_warn "atuin import failed"

    mkdir -p ~/.config/atuin
    cat >~/.config/atuin/config.toml <<EOF
# Atuin configuration
auto_sync = false
sync_address = ""
update_check = false
style = "compact"
show_help = true
max_preview_height = 8
EOF
    log_info "atuin setup complete"
}

setup_neovim() {
    log_info "Setting up neovim..."
    mkdir -p ~/.config

    if [[ -L ~/.config/nvim ]]; then
        rm ~/.config/nvim
    elif [[ -d ~/.config/nvim ]]; then
        mv ~/.config/nvim ~/.config/nvim.bak
    fi

    ln -s ${WORKDIR} ~/.config/nvim
    install_neovim_from_source || log_warn "Skipped source install"
    log_info "neovim setup complete"
}

main() {
    print_prerequisites
    check_system

    # Preflight check
    ensure_cmd curl || exit 1
    ensure_cmd git || exit 1
    if [[ ${OS} != "Darwin" ]]; then
        ensure_cmd sudo || { log_error "sudo is required on Linux"; exit 1; }
    else
        ensure_cmd brew || log_warn "Homebrew not found; some installs may fail"
    fi

    log_info "Starting Installation..."

    install_core_package
    install_package

    log_info "Configuring Environment..."

    setup_zsh
    setup_tmux
    setup_atuin
    setup_neovim

    link_fd_alias

    log_info "Final Configuration..."

    # Only show ccat installation prompt on Linux
    if [[ ${OS} != "Darwin" ]]; then
        log_info "Optional: install ccat via 'go get -u github.com/owenthereal/ccat'"
    fi

    log_info "Installation complete. Log file: $LOG_FILE"

    # Final interactive: switch default shell
    if [[ "${SKIP_CHSH}" == "1" ]]; then
        log_info "Skipping default shell change due to SKIP_CHSH=1"
    else
        printf "\nWould you like to set zsh as your default shell now? [y/N] "
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
            local zsh_path=""
            if [[ -f /usr/local/bin/zsh ]]; then zsh_path="/usr/local/bin/zsh";
            elif [[ -f /usr/bin/zsh ]]; then zsh_path="/usr/bin/zsh";
            elif [[ -f /bin/zsh ]]; then zsh_path="/bin/zsh"; fi

            if [[ -n "$zsh_path" ]]; then
                chsh -s "$zsh_path" && log_info "Default shell changed to $zsh_path"
            else
                log_warn "zsh binary not found; skipping default shell change"
            fi
            log_info "Please log out and back in for changes to take effect."
        fi
    fi
}

main "$@"
