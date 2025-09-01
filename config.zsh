# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="dst"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    fzf
    docker
    kubectl
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
#[[ -s /root/.autojump/etc/profile.d/autojump.sh ]] && source /root/.autojump/etc/profile.d/autojump.sh
#autoload -U compinit && compinit -u
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# Environment variables
export HOMEBREW_NO_AUTO_UPDATE=true
export DOCKER_BUILDKIT=1
export GO111MODULE=on
export KUBE_EDITOR="nvim"
export GOPROXY=""
export GOSUMDB=""
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PATH:$HOME/.local/bin:$HOME/go/bin:$HOME/.atuin/bin:/usr/local/go/bin:$HOME/.cargo/bin:$HOME/.nvm/versions/node/v22.15.0/bin/:$PNPM_HOME:${KREW_ROOT:-$HOME/.krew}/bin"

# export DEEPSEEK_API_KEY=""
# export TENCENT_DEEPSEEK_API_KEY=""
# export GEMINI_API_KEY=

# Kimi
# export ANTHROPIC_BASE_URL=https://api.moonshot.cn/anthropic
# export ANTHROPIC_AUTH_TOKEN=
# export ANTHROPIC_SMALL_FAST_MODEL=kimi-k2-turbo-preview
# export ANTHROPIC_MODEL=kimi-k2-0711-preview

# GLM
# export ANTHROPIC_AUTH_TOKEN=
# export ANTHROPIC_BASE_URL=https://open.bigmodel.cn/api/anthropic
# export ANTHROPIC_MODEL="glm-4.5"
# export ANTHROPIC_SMALL_FAST_MODEL="glm-4.5-air"

# Deepseek
# export ANTHROPIC_AUTH_TOKEN=
# export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
# export API_TIMEOUT_MS=600000
# export ANTHROPIC_MODEL=deepseek-reasoner
# export ANTHROPIC_SMALL_FAST_MODEL=deepseek-chat

# Aliases
alias k="kubectl"
alias h="hexctl"
alias c="ccat"
alias ls="eza"
alias ll="eza -l"
alias ghcs="gh copilot suggest"
alias ghce="gh copilot explain"

# Atuin integration
if command -v atuin &> /dev/null; then
    eval "$(atuin init zsh)"
fi

FNM_PATH="/root/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/root/.local/share/fnm:$PATH"
  eval "`fnm env`"
fi
