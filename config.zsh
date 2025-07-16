# Zsh configuration for dotfiles

# Environment variables
export HOMEBREW_NO_AUTO_UPDATE=true
export DOCKER_BUILDKIT=1
export GO111MODULE=on
export KUBE_EDITOR="nvim"
export PATH="$PATH:/usr/local/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/.atuin/bin"

# Aliases
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

# Load Oh My Zsh if available
if [[ -f ~/.oh-my-zsh/oh-my-zsh.sh ]]; then
    source ~/.oh-my-zsh/oh-my-zsh.sh
fi
