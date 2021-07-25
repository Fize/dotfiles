#!/usr/bin/env bash

# nerd-fonts install
public::common::install_font() {
	local workspace=$(pwd)
	git clone https://github.com/ryanoasis/nerd-fonts.git
	cd nerd-fonts
	bash -c ./install.sh
	cd ${workspace}
}

private::zsh::plugin() {
	git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
}

private::zsh::config() {
	sed -i 's#plugins=(git)#plugins=(git zsh-autosuggestions)#' ~/.zshrc
	sed -i '/zsh-autosuggestions/aZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"' ~/.zshrc
	echo "export GOPROXY=https://goproxy.cn" >> ~/.zshrc
}

public::common::main() {
	# public::common::install_font
	private::zsh::plugin
	private::zsh::config
}

public::common::main "$@"
