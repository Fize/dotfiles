#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

images=(
  "ubuntu:22.04"
  "debian:bookworm"
  "fedora:latest"
)

run_ubuntu_like() {
  local image="$1"
  docker run --rm \
    -v "$REPO_DIR":/workspace \
    -w /workspace \
    "$image" bash -lc '
      set -euo pipefail
      export DEBIAN_FRONTEND=noninteractive
      apt-get update -y
      apt-get install -y curl git sudo ca-certificates gnupg make gcc g++ cmake ninja-build gettext unzip
      # speed-up: ensure a dummy nvim to skip source build during test
      ln -sf /bin/true /usr/local/bin/nvim || true
      printf "\n" | SKIP_CHSH=1 ./install.sh
    '
}

run_fedora() {
  docker run --rm \
    -v "$REPO_DIR":/workspace \
    -w /workspace \
    fedora:latest bash -lc '
      set -euo pipefail
      dnf -y update
      dnf -y install curl git sudo which make gcc gcc-c++ cmake gettext-devel ninja-build unzip
      # speed-up: ensure a dummy nvim to skip source build during test
      ln -sf /bin/true /usr/local/bin/nvim || true
      printf "\n" | SKIP_CHSH=1 ./install.sh
    '
}

# --wezterm is an exclusive profile: it must install WezTerm's config and
# touch nothing else. The package install itself is skipped (no GUI in CI),
# so this only validates the profile wiring and the config deployment.
run_wezterm_profile() {
  local image="$1"
  local distro="$2"
  docker run --rm \
    -v "$REPO_DIR":/workspace \
    -w /workspace \
    "$image" bash -lc '
      set -euo pipefail
      if [[ "'"$distro"'" == "fedora" ]]; then
        dnf -y install curl git sudo which unzip
      else
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -y
        apt-get install -y curl git sudo ca-certificates unzip
      fi

      WEZTERM_SKIP_INSTALL=1 ./install.sh --wezterm

      # Config must be deployed as a symlink to the repo file.
      test -L "$HOME/.config/wezterm/wezterm.lua"
      test "$(readlink "$HOME/.config/wezterm/wezterm.lua")" = "/workspace/wezterm.lua"

      # Nothing from the full profile may be installed.
      test ! -e "$HOME/.oh-my-zsh"
      test ! -e "$HOME/.tmux.conf"
      test ! -e "$HOME/.config/nvim"
      test ! -e "$HOME/.p10k.zsh"
      test ! -e "$HOME/.config/ghostty/config"

      # Mixing the exclusive profile with full-install options must fail.
      if ./install.sh --wezterm --terminal-cmd /bin/zsh >/dev/null 2>&1; then
        echo "--wezterm should reject --terminal-cmd" >&2
        exit 1
      fi

      echo "wezterm profile OK"
    '
}

main() {
  echo "[INFO] Starting Docker integration tests"

  local pass=0
  local fail=0

  for img in "${images[@]}"; do
    echo "[INFO] Testing $img"
    if [[ "$img" == fedora:* || "$img" == fedora || "$img" == fedora:latest ]]; then
      if run_fedora; then ((pass++)); else ((fail++)); fi
    else
      if run_ubuntu_like "$img"; then ((pass++)); else ((fail++)); fi
    fi
  done

  echo "[INFO] Testing --wezterm profile on ubuntu:22.04"
  if run_wezterm_profile "ubuntu:22.04" ubuntu; then ((pass++)); else ((fail++)); fi

  echo "[INFO] Testing --wezterm profile on fedora:latest"
  if run_wezterm_profile "fedora:latest" fedora; then ((pass++)); else ((fail++)); fi

  echo "[INFO] Tests finished. PASS=$pass FAIL=$fail"
  if [[ $fail -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
