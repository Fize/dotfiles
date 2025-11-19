#!/usr/bin/env bash
# Author: malzahar
# email: malzaharguo@gmail.com

print_prerequisites() {
    echo "============================================================"
    echo "                System Requirements Check                     "
    echo "============================================================"
    echo "Before proceeding, please ensure you have the following installed:"
    echo ""
    if [[ $(uname) == "Darwin" ]]; then
        echo "For macOS:"
        echo "1. Git (Command line developer tools)"
        echo "   Install with: xcode-select --install"
        echo ""
        echo "2. Homebrew"
        echo "   Install with: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    else
        echo "For Debian/Ubuntu/Fedora Linux:"
        echo "1. Git"
        echo "   Install with:"
        echo "   - Ubuntu/Debian: sudo apt update && sudo apt install -y git"
        echo "   - Fedora: sudo dnf install -y git"
    fi
    echo ""
    echo "Press Enter to continue or Ctrl+C to exit..."
    read
}

export support_release=("Ubuntu" "Debian" "Fedora" "tencentos")
export WORKDIR=$(pwd)
export NODE_MAJOR=20

check_system() {
    echo "============================================================"
    echo "                   Checking System Type                      "
    echo "============================================================"

    local system=$(uname)
    if [[ ${system} != "Linux" && ${system} != "Darwin" ]]; then
        printf "Error: Unsupported system type: %s\n" ${system}
        exit 0
    fi

    if [[ ${system} == "Linux" ]]; then
        if [[ -f /etc/os-release ]]; then
            export OS=$(. /etc/os-release && echo $ID)
        else
            printf "Error: Unknown Linux distribution\n"
            exit 0
        fi
    else
        export OS="Darwin"
    fi

    if [[ ${OS} == "Darwin" ]]; then
        printf "✓ Detected system: macOS\n"
        return
    fi

    for release in "${support_release[@]}"; do
        if [[ ${OS} == $(echo "$release" | tr '[:upper:]' '[:lower:]') ]]; then
            printf "✓ Detected system: %s\n" ${release}
            return
        fi
    done

    printf "Error: Unsupported Linux distribution: %s\n" ${OS}
    exit 0
}

install_core_package() {
    if [[ ${OS} == "Darwin" ]]; then
        brew install curl unzip zsh tmux ag eza ccat bat fd
        brew install --cask latexit
    elif [[ ${OS} == "fedora" || ${OS} == "tencentos" ]]; then
        sudo dnf update -y
        sudo dnf install -y curl unzip zsh tmux the_silver_searcher eza bat fd-find
    else
        sudo apt update -y
        sudo apt upgrade -y
        sudo apt install -y software-properties-common curl gnupg ca-certificates ninja-build unzip gettext gcc make gcc g++ cmake zsh tmux luajit silversearcher-ag latex2text
    fi
}

install_package() {
    if [[ ${OS} == "Darwin" ]]; then
        brew install go fd the_silver_searcher node ripgrep shfmt atuin luajit
        brew install --HEAD neovim
    elif [[ ${OS} == "fedora" || ${OS} == "tencentos" ]]; then
        # Install Atuin
        bash <(curl https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh)

        # Install packages available in Fedora repos
        sudo dnf install -y python3-devel python3-pip nodejs npm ripgrep shfmt golang

        # Install Neovim from source for latest version
        cd ~
        git clone https://github.com/neovim/neovim
        cd neovim
        git checkout stable
        make CMAKE_BUILD_TYPE=RelWithDebInfo
        sudo make install
        cd $WORKDIR
        sudo ln -sf /usr/local/bin/nvim /usr/bin/nvim
    else
        # Install Atuin
        bash <(curl https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh)

        sudo apt update -y
        # install nodejs packages
        curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
        echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
        # install eza packages
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

        sudo apt update -y
        sudo apt install -y python3-dev python3-pip silversearcher-ag fd-find nodejs shfmt ripgrep eza
        sudo mkdir -p /etc/apt/keyrings

        cd ~
        git clone https://github.com/neovim/neovim
        cd neovim
        git checkout stable
        make CMAKE_BUILD_TYPE=RelWithDebInfo
        sudo make install
        cd $WORKDIR
        sudo ln -s /usr/local/bin/nvim /usr/bin/nvim
    fi
}

setup_zsh() {
    # Install Oh My Zsh if not exists
    if [[ ! -d ~/.oh-my-zsh ]]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
    fi

    # Install useful zsh plugins first
    echo "Installing zsh plugins..."

    # Install zsh-autosuggestions
    if [[ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi

    # Install zsh-syntax-highlighting
    if [[ ! -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi

    # Update plugins in .zshrc
    if [[ -f ~/.zshrc ]]; then
        # Update plugins list to include our custom plugins
        sed -i 's/plugins=(git)/plugins=(\n    git\n    z\n    fzf\n    docker\n    kubectl\n    golang\n    node\n    npm\n    yarn\n    zsh-autosuggestions\n    zsh-syntax-highlighting\n)/' ~/.zshrc

        # Add our custom environment variables and aliases at the end of .zshrc
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
    fi
}

setup_tmux() {
    # Clone oh-my-tmux if not exists
    if [[ ! -d ~/.tmux ]]; then
        git clone https://github.com/gpakosz/.tmux.git ~/.tmux
    fi

    # Create symlinks
    if [[ -f ~/.tmux.conf ]]; then
        mv ~/.tmux.conf ~/.tmux.conf.bak
    fi
    if [[ -f ~/.tmux.conf.local ]]; then
        mv ~/.tmux.conf.local ~/.tmux.conf.local.bak
    fi

    ln -s ~/.tmux/.tmux.conf ~/.tmux.conf
    cp ~/.tmux/.tmux.conf.local ~/.tmux.conf.local
}

setup_atuin() {
    # Initialize atuin
    atuin import auto

    # Configure atuin
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

    # Note: Atuin integration is already handled in the zsh configuration
    echo "Atuin configured. Integration with zsh is already set up in .zshrc"
}

setup_neovim() {
    echo "Setting up Neovim configuration..."

    # Create nvim config directory if it doesn't exist
    mkdir -p ~/.config

    # Remove existing nvim config if it exists
    if [[ -L ~/.config/nvim ]]; then
        rm ~/.config/nvim
    elif [[ -d ~/.config/nvim ]]; then
        mv ~/.config/nvim ~/.config/nvim.bak
    fi

    # Create symlink
    ln -s ${WORKDIR} ~/.config/nvim
}

main() {
    print_prerequisites
    check_system

    echo "============================================================"
    echo "                Starting Installation                        "
    echo "============================================================"

    install_core_package
    install_package

    echo "============================================================"
    echo "                Configuring Environment                      "
    echo "============================================================"

    # Setup zsh shell
    setup_zsh
    # Setup tmux configuration
    setup_tmux
    # Setup atuin
    setup_atuin
    # Setup neovim configuration
    setup_neovim

    echo "============================================================"
    echo "                   Final Configuration                       "
    echo "============================================================"

    # Set zsh as default shell
    printf "\nWould you like to set zsh as your default shell? [y/N] "
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        if [[ -f /usr/local/bin/zsh ]]; then
            chsh -s /usr/local/bin/zsh
        elif [[ -f /usr/bin/zsh ]]; then
            chsh -s /usr/bin/zsh
        elif [[ -f /bin/zsh ]]; then
            chsh -s /bin/zsh
        fi
        printf "\n✓ Zsh shell has been set as your default shell.\n"
        printf "Please log out and back in for changes to take effect.\n"
    fi

    # Only show ccat installation prompt on Linux
    if [[ ${OS} != "Darwin" ]]; then
        echo "============================================================"
        echo "                   Optional Tools                           "
        echo "============================================================"
        echo "To install ccat (Colorizing cat), please run:"
        echo "$ go get -u github.com/owenthereal/ccat"
        echo ""
        echo "Press Enter to continue..."
        read
    fi

    echo "============================================================"
    echo "                Installation Complete!                       "
    echo "============================================================"
}

main "$@"
