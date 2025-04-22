if status is-interactive
    set -gx HOMEBREW_NO_AUTO_UPDATE true
    set -gx DOCKER_BUILDKIT 1
    set -gx GO111MODULE on
    set -gx KUBE_EDITOR "nvim"
    set -gx PATH "$PATH:/usr/local/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/.atuin/bin"

    alias k="kubectl"
    alias h="hexctl"
    alias c="ccat"

    alias ls="eza"

    alias ghcs="gh copilot suggest"
    alias ghce="gh copilot explain"

    atuin init fish | source
end
