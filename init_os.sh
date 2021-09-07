#!/usr/bin/env bash
# Author: malzahar
# email: malzaharguo@gmail.com

export support_linux_release=("CentOS")
export WORKDIR=$(pwd)

public::common::check_system() {
	local system=$(uname)
	if [[ ${system} != "Linux" && ${system} != "Darwin" ]];then
		printf "unsupport this system %s\n" ${system}
		exit 0
	fi

	if [[ ${system} == "Linux" ]];then
		if [[ -f /etc/redhat-release ]];then
			export OS=$(cat /etc/redhat-release | cut -d" " -f1)
		else
			export OS=$(cat /etc/issue | cut -d" " -f1)
		fi
	else
		export OS="Darwin"
	fi

	local sum=${!support_linux_release[@]}
	for i in ${support_linux_release[@]};do
		if [[ ${i} == ${sum} ]];then
			if [[ ${OS} == ${support_linux_release[i]} ]];then
				printf "current system is %s\n" ${OS}
				break
			else
				printf "unsupport this system release %s\n" ${OS}
				exit 0
			fi
		fi

		if [[ ${OS} != ${support_linux_release[i]} ]];then
			continue
		elif [[ ${support_linux_release[i]} == ${OS} ]];then
			break
		fi
	done
}

public::common::check_omz() {
    if [[ ! -d ~/.oh-my-zsh ]];then
        echo "must install oh-my-zsh before"
        exit 0
    fi
}

public::common::install_package() {
	if [[ ${OS} == "Darwin" ]];then
		brew install zsh curl mosh tmux golang ag
    else
		dnf update -y
        dnf install -y epel-release
		dnf install -y neovim mosh tmux golang util-linux-user cmake make gcc-c++ python3-devel autojump-zsh ag
	fi
}

private::zsh::plugin() {
	git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
}

private::zsh::config() {
	sed -i 's#plugins=(git)#plugins=(git zsh-autosuggestions zsh-syntax-highlighting autojump)#' ~/.zshrc
	sed -i '/zsh-autosuggestions/aZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"' ~/.zshrc
	echo "export GOPROXY=https://goproxy.cn" >> ~/.zshrc
}

private::nvim::install() {
    curl -sL install-node.now.sh/lts | bash

    if [[ -f ~/.vimrc ]];then
        mv ~/.vimrc ~/.vimrc.bak
    fi

    if [[ -d ~/.vim ]];then
        mv ~/.vim ~/.vim-bak
    fi

    ln -s ${WORKDIR}/vimrc ~/.vimrc
    ln -s ${WORKDIR} ~/.vim

    vim +PlugInstall! +PlugClean!
}

private::tmux::install() {
    cd
    git clone https://github.com/gpakosz/.tmux.git
    ln -s -f .tmux/.tmux.conf
    cp .tmux/.tmux.conf.local .
    cd ${WORKDIR}
}

public::common::main() {
	public::common::check_system
	public::common::install_package
	private::zsh::plugin
	private::zsh::config
    private::nvim::install
}

public::common::main "$@"
