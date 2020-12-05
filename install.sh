#!/bin/bash
#
# install.sh
# Copyright (C) 2019 malzahar <malzaharguo@gmail.com>
#
#

if [[ $(uname) == "Darwin" ]];then
    brew install ctags
    brew install the_silver_searcher
else
    local release=$(cat /etc/issue | cut -d" " -f1)
    if [[ ${release} == "Ubuntu" || ${release} == "Ubuntu" || ${release} == "Ubuntu" ]];then
        sudo apt install -y ctags build-essential cmake python3-dev silversearcher-ag
    fi
    if [[ ${release} == "CentOS" || ${release} == "Redhat" ]];then
        sudo yum install -y python-devel epel-release
        sudo yum install -y the_silver_searcher cmake
    fi
fi

export WORKDIR=$(pwd)

# backup
if [[ -f ~/.vimrc ]];then
    mv ~/.vimrc ~/.vimrc.bak
fi

if [[ -d ~/.vim ]];then
    mv ~/.vim ~/.vim-bak
fi

if [[ -f ~/.tmux.conf ]];then
    mv ~/.tmux.conf ~/.tmux.conf-bak
fi


# add new
ln -s ${WORKDIR}/vimrc ~/.vimrc
ln -s ${WORKDIR} ~/.vim
ln -s ${WORKDIR}/tmux.conf ~/.tmux.conf

vim +PlugInstall! +PlugClean!
