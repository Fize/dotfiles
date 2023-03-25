#!/usr/bin/env bash
# Author: malzahar
# email: malzaharguo@gmail.com

export support_linux_release=("CentOS" "Ubuntu" "Fedora")
export WORKDIR=$(pwd)

check_system() {
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

check_omz() {
	if [[ ! -d ~/.oh-my-zsh ]];then
	    echo "You must install oh-my-zsh first"
	    exit 0
	fi
}

install_go_on_ubuntu() {
	wget https://studygolang.com/dl/golang/go1.20.2.linux-amd64.tar.gz
	tar xvzf go1.20.2.linux-amd64.tar.gz
	sudo mv go /usr/local
	rm -f go1.20.2.linux-amd64.tar.gz
}

install_package() {
	if [[ ${OS} == "Darwin" ]];then
		brew install curl golang fd-find the_silver_searcher node ripgrep
		brew install --HEAD neovim
	elif [[ ${OS} == "CentOS" ]];then
		sudo yum update -y
		sudo yum install -y epel-release
		sudo yum install -y tmux golang util-linux-user cmake make gcc-c++ \
			python3-devel the_silver_searcher autojump-zsh neovim python3-neovim nodejs
		install_go_on_ubuntu
	elif [[ ${OS} == "Ubuntu" ]];then
		sudo apt-get install software-properties-common
		sudo add-apt-repository ppa:neovim-ppa/stable
		curl -fsSL https://deb.nodesource.com/setup_19.x | sudo -E bash -
		sudo apt update -y
		sudo apt upgrade -y
		sudo apt install -y make tmux cmake g++ python3-dev python-dev python-pip python3-pip \
			autojump silversearcher-ag fd-find nodejsa \
		sudo apt -y install neovim
	else
		sudo dnf update -y
		sudo dnf install -y the_silver_searcher tmux gcc-c++ make cmake \
			neovim python3-neovim nodejs golang
	fi
}

install_zsh_plugin() {
	git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
}

config() {
	sed -i 's#plugins=(git)#plugins=(git zsh-autosuggestions zsh-syntax-highlighting autojump)#' ~/.zshrc
	sed -i '/zsh-autosuggestions/aZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"' ~/.zshrc
	echo ". /usr/share/autojump/autojump.sh" >> ~/.zshrc
	echo "export GOPROXY=https://goproxy.cn" >> ~/.zshrc
	echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.zshrc
}

install_neovim_config() {
	if [[ -d ~/.vim ]];then
	    mv ~/.vim ~/.vim-bak
	fi
	mkdir ~/.config
	ln -s ${WORKDIR} ~/.config/nvim
	ln -s ${WORKDIR} ~/.vim
	nvim +PlugInstall! +PlugClean!
}

install_tmux() {
	cd
	git clone https://github.com/gpakosz/.tmux.git
	ln -s -f .tmux/.tmux.conf
	cp .tmux/.tmux.conf.local .
	cd ${WORKDIR}
}

main() {
	check_omz
	check_system
	install_package
	install_zsh_plugin
	config
	install_tmux
}

main "$@"
