#!/usr/bin/env bash
# Author: malzahar
# email: malzaharguo@gmail.com

export support_linux_release=("Ubuntu")
export WORKDIR=$(pwd)
export NODE_MAJOR=20

check_system() {
	local system=$(uname)
	if [[ ${system} != "Linux" && ${system} != "Darwin" ]]; then
		printf "unsupport this system %s\n" ${system}
		exit 0
	fi

	if [[ ${system} == "Linux" ]]; then
		if [[ -f /etc/issue ]]; then
			export OS=$(cat /etc/issue | cut -d" " -f1)
        else
            printf "unknown this Linux release\n"
            exit 0
		fi
	else
		export OS="Darwin"
	fi

	local sum=${!support_linux_release[@]}
	for i in ${support_linux_release[@]}; do
		if [[ ${i} == ${sum} ]]; then
			if [[ ${OS} == ${support_linux_release[i]} ]]; then
				printf "current system is %s\n" ${OS}
				break
			else
				printf "unsupport this system release %s\n" ${OS}
				exit 0
			fi
		fi

		if [[ ${OS} != ${support_linux_release[i]} ]]; then
			continue
		elif [[ ${support_linux_release[i]} == ${OS} ]]; then
			break
		fi
	done
}

install_core_package() {
	if [[ ${OS} == "Darwin" ]]; then
		brew install curl git unzip zsh
    else
        sudo apt update -y
		sudo apt upgrade -y
		sudo apt install -y software-properties-common curl gnupg ca-certificates ninja-build unzip gettext gcc make gcc g++ cmake git zsh
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	fi
}

check_omz() {
	if [[ ! -d ~/.oh-my-zsh ]]; then
        install_core_package
		exit 0
	fi
}

install_package() {
	if [[ ${OS} == "Darwin" ]]; then
		brew install golang fd-find the_silver_searcher node ripgrep shfmt exa
		brew install --HEAD neovim
    else
        sudo apt update -y
        curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
        echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
		sudo apt update -y
		sudo apt install -y tmux python3-dev python2-dev python3-pip autojump silversearcher-ag fd-find nodejs exa shfmt
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

# use lvim instead of custom nvim
install_lvim() {
    nvim --version | grep "NVIM v0.9."
    if [[ $(echo $?) == "0" ]];then
        LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh) 
        ln -s ${WORKDIR}/lvim-config.lua ~/.config/lvim/config.lua
    fi
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
    sed -i "s/{{HOME}}/$HOME/g" ~/.zshrc
}

main() {
	check_system
	check_omz
	install_package
    install_lvim
	install_zsh_plugin
	config
}

main "$@"
