#!/usr/bin/env bash
# Author: malzahar
# email: malzaharguo@gmail.com

export support_linux_release=("Ubuntu" "Debian" "Deepin" "Fedora")

public::common::check_system() {
	local system=$(uname)
	if [[ ${system} != "Linux" && ${system} != "Darwin" ]];then
		printf "unsupport this system %s\n" ${system}
		exit 1
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
				exit 1
			fi
		fi

		if [[ ${OS} != ${support_linux_release[i]} ]];then
			continue
		elif [[ ${support_linux_release[i]} == ${OS} ]];then
			break
		fi
	done
}

public::common::install_package() {
	if [[ ${OS} == "Darwin" ]];then
		brew install zsh curl mosh
	elif [[ ${OS} == "Fedora" ]];then
		sudo dnf update -y
		sudo dnf install -y vim zsh mosh tmux golang util-linux-user cmake make gcc-c++ python3-devel
	else
		sudo apt update
		sudo apt list --upgradable
		sudo apt upgrade -y
		sudo apt install zsh curl mosh tmux -y
	fi
}

private::zsh::install() {
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

public::common::main() {
	public::common::check_system
	public::common::install_package
	private::zsh::install
}

public::common::main "$@"
