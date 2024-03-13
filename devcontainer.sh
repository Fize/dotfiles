#!/usr/bin/env bash
# Author: malzahar
# email: malzaharguo@gmail.com

export WORKDIR=$(pwd)

# use lvim instead of custom nvim
install_lvim() {
    bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh) 
    ln -s ${WORKDIR}/lvim-config.lua ~/.config/lvim/config.lua
    printf "\n"
    printf "LunarVim install success. Please add $HOME/.local/bin into your PATH to use command lvim.\n"
    printf "\n"
}

install_tmux() {
    cd
    git clone https://github.com/gpakosz/.tmux.git
    ln -s -f .tmux/.tmux.conf
    cp .tmux/.tmux.conf.local .
}

main() {
    install_lvim
    install_tmux
}

main "$@"
