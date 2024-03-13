#!/usr/bin/env bash
# Author: malzahar
# email: malzaharguo@gmail.com

export WORKDIR=$(pwd)
export NODE_MAJOR=20

install_omz() {
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

# use lvim instead of custom nvim
install_lvim() {
    bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh) 
    ln -s ${WORKDIR}/lvim-config.lua ~/.config/lvim/config.lua
    printf "\n"
    printf "LunarVim install success. Please add $HOME/.local/bin into your PATH to use command lvim.\n"
    printf "\n"
}

install_zsh_plugin() {
	git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
}

config() {
    if [[ -f ~/.zshrc ]]; then
        mv ~/.zshrc ~/.zshrc.bak
    fi
    cp zshrc ~/.zshrc
    sed -i "s#{{HOME}}#$HOME#" ~/.zshrc
}

install_tmux() {
    cd
    git clone https://github.com/gpakosz/.tmux.git
    ln -s -f .tmux/.tmux.conf
    cp .tmux/.tmux.conf.local .
}

main() {
    instsall_lvim
    install_tmux
    install_omz	
	install_zsh_plugin
	config
}

main "$@"
