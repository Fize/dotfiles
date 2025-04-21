if status is-interactive
    set -gx HOMEBREW_NO_AUTO_UPDATE true
    set -gx DOCKER_BUILDKIT 1
    set -gx GO111MODULE on
    set -gx PATH "$HOME/go/bin"
    set -gx KUBE_EDITOR "nvim"
    # [ -f /opt/homebrew/share/autojump/autojump.fish ]; and source /opt/homebrew/share/autojump/autojump.fish

    alias k="kubectl"
    alias h="hexctl"
    alias c="ccat"

    alias ghcs="gh copilot suggest"
    alias ghce="gh copilot explain"

    atuin init fish | source
end
