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

  echo "[INFO] Tests finished. PASS=$pass FAIL=$fail"
  if [[ $fail -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
