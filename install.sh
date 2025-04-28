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
        echo "For Debian/Ubuntu Linux:"
        echo "1. Git"
        echo "   Install with: sudo apt update && sudo apt install -y git"
    fi
    echo ""
    echo "Press Enter to continue or Ctrl+C to exit..."
    read
}

export support_release=("Ubuntu" "Debian")
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
        brew install curl unzip fish tmux ag eza ccat bat fd
    else
        sudo apt update -y
        sudo apt upgrade -y
        sudo apt install -y software-properties-common curl gnupg ca-certificates ninja-build unzip gettext gcc make gcc g++ cmake fish tmux luajit silversearcher-ag
    fi
}

install_package() {
    if [[ ${OS} == "Darwin" ]]; then
        brew install go fd the_silver_searcher node ripgrep shfmt atuin luajit
        brew install --HEAD neovim
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

setup_fish() {
    # Create fish config directory if it doesn't exist
    mkdir -p ~/.config/fish

    # Handle existing config.fish
    if [[ -L ~/.config/fish/config.fish ]]; then
        # Remove existing symlink
        rm ~/.config/fish/config.fish
    elif [[ -f ~/.config/fish/config.fish ]]; then
        # Backup existing regular file
        mv ~/.config/fish/config.fish ~/.config/fish/config.fish.bak
    fi

    # Create symlink to config.fish
    ln -s ${WORKDIR}/config.fish ~/.config/fish/config.fish

    # Install Fisher (plugin manager for fish) using fish shell
    if [[ ! -f ~/.config/fish/functions/fisher.fish ]]; then
        fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
    fi

    # Install useful fish plugins
    echo "Installing fish plugins..."
    fish -c "fisher install jethrokuan/z"
    fish -c "fisher install PatrickF1/fzf.fish"
    fish -c "fisher install edc/bass"
    fish -c "fisher install jhillyerd/plugin-git"
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

    # Setup for fish shell
    if [[ -d ~/.config/fish ]]; then
        # Add atuin integration to config.fish if not already present
        if ! grep -q "atuin init fish" ~/.config/fish/config.fish; then
            echo 'status --is-interactive; and atuin init fish | source' >>~/.config/fish/config.fish
        fi
    fi
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

    # Setup fish shell
    setup_fish
    # Setup tmux configuration
    setup_tmux
    # Setup atuin
    setup_atuin
    # Setup neovim configuration
    setup_neovim

    echo "============================================================"
    echo "                   Final Configuration                       "
    echo "============================================================"

    # Set fish as default shell
    printf "\nWould you like to set fish as your default shell? [y/N] "
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        if [[ -f /usr/local/bin/fish ]]; then
            chsh -s /usr/local/bin/fish
        elif [[ -f /usr/bin/fish ]]; then
            chsh -s /usr/bin/fish
        fi
        printf "\n✓ Fish shell has been set as your default shell.\n"
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
