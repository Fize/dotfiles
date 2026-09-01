#!/usr/bin/env bash
#
# Idempotent pi agent initializer.
# Installs the pi CLI, its extensions, and default settings.
# Supported: macOS (Homebrew), Linux (nvm).
# Re-running this script is safe — it skips anything already installed.

set -euo pipefail

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------
WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PI_PACKAGE="@earendil-works/pi-coding-agent"
PI_DIR="${HOME}/.pi/agent"
# Default values merged into ~/.pi/agent/settings.json.
# Only missing keys are added — existing values (and pi-managed keys such as
# "packages" / "lastChangelogVersion") are never overwritten.
PI_SETTINGS_FILE="${WORKDIR}/pi-settings.json"
# Custom providers merged into ~/.pi/agent/models.json.
# Same structure as pi's own models.json: { "providers": { ... } }.
PI_MODELS_FILE="${WORKDIR}/pi-models.json"
PI_EXTENSIONS=(
    "npm:pi-subagents"
    "npm:pi-web-access"
    "npm:@juicesharp/rpiv-ask-user-question"
    "npm:@juicesharp/rpiv-todo"
    "npm:@narumitw/pi-plan-mode"
    "npm:@narumitw/pi-btw"
    "npm:@narumitw/pi-lsp"
    "npm:@narumitw/pi-usage"
    "npm:pi-simplify"
    "npm:pi-add-dir"
    "npm:pi-autoresearch"
    "npm:@plannotator/pi-extension"
)

# ------------------------------------------------------------
# Logging
# ------------------------------------------------------------
LOG_FILE="${HOME}/.pi_init.log"
log_ts() { date +'%F %T'; }
log_info()  { printf '[%s] INFO:  %s\n' "$(log_ts)" "$*" | tee -a "$LOG_FILE"; }
log_warn()  { printf '[%s] WARN:  %s\n' "$(log_ts)" "$*" | tee -a "$LOG_FILE"; }
log_error() { printf '[%s] ERROR: %s\n' "$(log_ts)" "$*" | tee -a "$LOG_FILE"; }

# ------------------------------------------------------------
# Global variables
# ------------------------------------------------------------
OS=""

# ------------------------------------------------------------
# System detection
# ------------------------------------------------------------
check_system() {
    log_info "Checking system type..."
    local system
    system="$(uname)"

    case "$system" in
        Darwin) OS="Darwin" ;;
        Linux)  OS="Linux" ;;
        *)
            log_error "Unsupported system: $system"
            return 1
            ;;
    esac

    log_info "Detected: $OS"
}

# ------------------------------------------------------------
# Node.js (macOS: brew / Linux: nvm)
# ------------------------------------------------------------
ensure_node() {
    if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
        log_info "Node.js already installed: $(node --version)"
        return 0
    fi

    log_info "Installing Node.js..."
    if [[ "$OS" == "Darwin" ]]; then
        if ! command -v brew >/dev/null 2>&1; then
            log_error "Homebrew is required on macOS: https://brew.sh"
            return 1
        fi
        brew install node || { log_error "brew install node failed"; return 1; }
    else
        export NVM_DIR="${HOME}/.nvm"

        if [[ ! -d "$NVM_DIR" ]]; then
            log_info "Installing nvm..."
            curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
        else
            log_info "nvm already installed"
        fi

        # shellcheck disable=SC1091
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

        nvm install --lts || { log_error "nvm install --lts failed"; return 1; }
    fi

    log_info "Node.js installed: $(node --version)"
}

# ------------------------------------------------------------
# pi CLI
# ------------------------------------------------------------
install_pi() {
    if command -v pi >/dev/null 2>&1; then
        log_info "pi already installed: $(pi --version 2>&1 | head -1)"
        return 0
    fi

    log_info "Installing pi CLI..."
    npm install -g "$PI_PACKAGE" || { log_error "npm install -g $PI_PACKAGE failed"; return 1; }
    log_info "pi installed: $(pi --version 2>&1 | head -1)"
}

# ------------------------------------------------------------
# Default settings (merge-only, never overwrites existing keys)
# pi-settings.json  -> ~/.pi/agent/settings.json
# pi-models.json    -> ~/.pi/agent/models.json
# Both mirror the structure of pi's own config files.
# ------------------------------------------------------------
apply_settings() {
    local settings_file="${PI_DIR}/settings.json"

    if [[ ! -f "$PI_SETTINGS_FILE" ]]; then
        log_warn "Config file not found: $PI_SETTINGS_FILE, skipping"
        return 0
    fi

    mkdir -p "$PI_DIR"
    [[ -f "$settings_file" ]] || printf '{}\n' > "$settings_file"

    log_info "Applying settings from $PI_SETTINGS_FILE..."

    local merged added
    merged="$(mktemp)"
    added="$(PI_SETTINGS_FILE="$PI_SETTINGS_FILE" PI_MERGED="$merged" node -e '
        const fs = require("fs");
        const settings = JSON.parse(fs.readFileSync(0, "utf8"));
        const defaults = JSON.parse(fs.readFileSync(process.env.PI_SETTINGS_FILE, "utf8"));
        const added = [];
        for (const [key, value] of Object.entries(defaults)) {
            if (!(key in settings)) {
                settings[key] = value;
                added.push(key);
            }
        }
        fs.writeFileSync(process.env.PI_MERGED, JSON.stringify(settings, null, 2) + "\n");
        process.stdout.write(added.join(" "));
    ' < "$settings_file" 2>/dev/null)" || { rm -f "$merged"; log_error "failed to merge settings (invalid JSON in $settings_file or $PI_SETTINGS_FILE)"; return 1; }

    if [[ -z "$added" ]]; then
        rm -f "$merged"
        log_info "Settings already present"
        return 0
    fi

    cp "$settings_file" "${settings_file}.bak.$(date +%Y%m%d%H%M%S)"
    mv "$merged" "$settings_file"
    log_info "Settings added: $added"
}

# ------------------------------------------------------------
# Custom providers (merge-only, keyed by provider id and model id)
# ------------------------------------------------------------
apply_providers() {
    local models_file="${PI_DIR}/models.json"

    if [[ ! -f "$PI_MODELS_FILE" ]]; then
        log_warn "Config file not found: $PI_MODELS_FILE, skipping"
        return 0
    fi

    mkdir -p "$PI_DIR"
    [[ -f "$models_file" ]] || printf '{}\n' > "$models_file"

    log_info "Applying providers from $PI_MODELS_FILE..."

    local merged added
    merged="$(mktemp)"
    added="$(PI_MODELS_FILE="$PI_MODELS_FILE" PI_MERGED="$merged" node -e '
        const fs = require("fs");
        const models = JSON.parse(fs.readFileSync(0, "utf8"));
        const config = JSON.parse(fs.readFileSync(process.env.PI_MODELS_FILE, "utf8"));
        models.providers ??= {};
        const added = [];
        for (const [id, definition] of Object.entries(config.providers ?? {})) {
            const existing = models.providers[id];
            if (!existing) {
                models.providers[id] = definition;
                added.push(id);
                continue;
            }
            const known = new Set((existing.models ?? []).map((model) => model.id));
            const newModels = (definition.models ?? []).filter((model) => !known.has(model.id));
            if (newModels.length > 0) {
                existing.models = [...(existing.models ?? []), ...newModels];
                added.push(id + "(+" + newModels.map((model) => model.id).join(",") + ")");
            }
        }
        fs.writeFileSync(process.env.PI_MERGED, JSON.stringify(models, null, 2) + "\n");
        process.stdout.write(added.join(" "));
    ' < "$models_file" 2>/dev/null)" || { rm -f "$merged"; log_error "failed to merge providers (invalid JSON in $models_file or $PI_MODELS_FILE)"; return 1; }

    if [[ -z "$added" ]]; then
        rm -f "$merged"
        log_info "Providers already present"
        return 0
    fi

    cp "$models_file" "${models_file}.bak.$(date +%Y%m%d%H%M%S)"
    mv "$merged" "$models_file"
    log_info "Providers added: $added"
}

# ------------------------------------------------------------
# pi extensions
# ------------------------------------------------------------
install_extensions() {
    log_info "Installing pi extensions..."

    local installed
    installed="$(pi list 2>/dev/null || true)"

    for ext in "${PI_EXTENSIONS[@]}"; do
        if printf '%s\n' "$installed" | grep -qF "  $ext"; then
            log_info "Already installed (pi): $ext"
        else
            log_info "Installing (pi): $ext"
            pi install "$ext" || log_warn "pi install failed: $ext"
        fi
    done
}

# ------------------------------------------------------------
# Main
# ------------------------------------------------------------
main() {
    log_info "========== Starting pi Setup =========="

    check_system || exit 1
    ensure_node || exit 1
    install_pi || exit 1
    apply_settings || exit 1
    apply_providers || exit 1
    install_extensions

    log_info "========== Done =========="
    log_info "pi setup complete. Log file: $LOG_FILE"
}

main "$@"
