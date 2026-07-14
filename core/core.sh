#!/bin/bash
# ==============================================================================
#  Core functions for Android TV debloat scripts
# ==============================================================================

set -uo pipefail

# ── Colors and formatting ────────────────────────────────────────────────────
RED='\033[0;31m';  GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m';  BOLD='\033[1m'; NC='\033[0m'

# ── Global counters ──────────────────────────────────────────────────────────
REMOVED=0; DISABLED=0; SKIPPED=0; FAILED=0
INSTALLED_APKS=0; FAILED_APKS=0

# ── UI helpers ──────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()      { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERR]${NC}   $*"; }
skip()    { echo -e "        ${NC}↷ Skipped: $*"; }
section() { echo -e "\n${BOLD}${CYAN}▓▓▒░  $* ░▒▓▓${NC}\n"; }

# ── Package removal logic ──────────────────────────────────────────────────
remove_pkg() {
    local pkg="$1"
    local desc="${2:-}"

    if ! adb shell pm list packages 2>/dev/null | grep -q "^package:${pkg}$"; then
        skip "${pkg} (${desc}) — not found"
        ((SKIPPED++))
        return 0
    fi

    printf "  ${YELLOW}→${NC} %-55s %s\n" "$pkg" "(${desc})"

    if adb shell pm uninstall --user 0 "$pkg" &>/dev/null; then
        ok "Uninstalled"
        ((REMOVED++))
    elif adb shell pm disable-user --user 0 "$pkg" &>/dev/null; then
        warn "Disabled (uninstall not available)"
        ((DISABLED++))
    else
        error "Could not remove or disable: $pkg"
        ((FAILED++))
    fi
}

# ── Smart download of Projectivy Launcher (anti-rate-limit) ──────────────
download_projectivy() {
    local target_file="$1"
    local repo="spocky/miproja1"

    # If file already exists, skip download
    if [[ -f "$target_file" && -s "$target_file" ]]; then
        ok "Projectivy Launcher already present in 'apks/'. Skipping download."
        return 0
    fi

    info "Fetching latest Projectivy Launcher version (including betas)..."
    local download_url=""

    # Use a common User-Agent to avoid GitHub API rejection
    if command -v curl &>/dev/null; then
        download_url=$(curl -sSL -A "Mozilla/5.0 (X11; Linux x86_64)" "https://api.github.com/repos/${repo}/releases" | grep -oP '"browser_download_url":\s*"\K[^"]+\.apk' | head -n 1)
    elif command -v wget &>/dev/null; then
        download_url=$(wget -qO- --user-agent="Mozilla/5.0 (X11; Linux x86_64)" "https://api.github.com/repos/${repo}/releases" | grep -oP '"browser_download_url":\s*"\K[^"]+\.apk' | head -n 1)
    else
        error "curl or wget required to download Projectivy Launcher automatically."
        exit 1
    fi

    if [[ -z "$download_url" ]]; then
        error "Could not obtain download URL (GitHub API limit reached or no network)."
        warn "Manual fallback:"
        echo -e "  1. Download any Projectivy APK from: https://github.com/spocky/ProjectivyLauncher/releases"
        echo -e "  2. Place it in the 'apks/' folder and rename it to ${BOLD}proyectivity.apk${NC}"
        echo -e "  3. Rerun the script. It will skip the download."
        exit 1
    fi

    local version_name=$(echo "$download_url" | grep -oP 'download/\K[^/]+')
    info "Latest version detected: ${BOLD}${version_name}${NC}"
    info "Downloading APK..."

    if command -v curl &>/dev/null; then
        curl -L -A "Mozilla/5.0 (X11; Linux x86_64)" -o "$target_file" "$download_url"
    else
        wget --user-agent="Mozilla/5.0 (X11; Linux x86_64)" -O "$target_file" "$download_url"
    fi

    if [[ -f "$target_file" && -s "$target_file" ]]; then
        ok "Projectivy Launcher downloaded successfully."
    else
        error "Failed to write APK to disk."
        exit 1
    fi
}

# ── Pre‑checks ──────────────────────────────────────────────────────────────
run_pre_checks() {
    if ! command -v adb &>/dev/null; then
        error "adb not installed or not in PATH. Aborting."
        exit 1
    fi

    info "Checking device..."
    if ! adb get-state &>/dev/null; then
        error "No device connected or not authorized."
        echo -e "\n  Connection steps:\n  1. On TV: Settings → About → Build (7 taps) → Developer options\n  2. Enable: USB debugging / Network debugging\n  3. Run: adb connect <TV_IP>:5555"
        exit 1
    fi

    local device=$(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r')
    local android=$(adb shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
    ok "Device: ${BOLD}${device}${NC} — Android ${BOLD}${android}${NC}"
}

# ── Batch install of APKs from a folder ──────────────────────────────────
install_apks_from_folder() {
    local apk_dir="$1"

    shopt -s nullglob
    local apk_files=("$apk_dir"/*.apk)
    shopt -u nullglob

    if [[ ${#apk_files[@]} -eq 0 ]]; then
        warn "No additional APK files found in '${apk_dir}'."
    else
        for apk in "${apk_files[@]}"; do
            local filename=$(basename "$apk")
            info "Installing: ${filename}..."

            if adb install -r "$apk" &>/dev/null; then
                ok "Installed: ${filename}"
                ((INSTALLED_APKS++))
            else
                error "Failed to install: ${filename}"
                ((FAILED_APKS++))
            fi
        done
    fi
}

# ── Projectivy Launcher permissions ──────────────────────────────────────
configure_projectivy_permissions() {
    local pkg="com.spocky.projengmenu"
    local svc="${pkg}/com.spocky.projengmenu.services.ProjectivyAccessibilityService"
    local nls="${pkg}/com.spocky.projengmenu.services.notification.NotificationListener"

    info "Applying permissions to Projectivy Launcher..."
    adb shell pm grant "$pkg" android.permission.WRITE_EXTERNAL_STORAGE    2>/dev/null || true
    adb shell pm grant "$pkg" android.permission.READ_EXTERNAL_STORAGE     2>/dev/null || true
    adb shell pm grant "$pkg" android.permission.READ_PHONE_STATE          2>/dev/null || true
    adb shell pm grant "$pkg" android.permission.READ_TV_LISTINGS          2>/dev/null || true
    adb shell pm grant "$pkg" android.permission.PACKAGE_USAGE_STATS       2>/dev/null || true

    adb shell settings put secure enabled_notification_listeners "$nls"
    adb shell settings put secure accessibility_enabled 1
    adb shell settings put secure enabled_accessibility_services "$svc"

    adb shell appops set "$pkg" AUTO_START allow 2>/dev/null || true
    adb shell appops set "$pkg" SYSTEM_ALERT_WINDOW allow 2>/dev/null || true
    adb shell dumpsys deviceidle whitelist +"$pkg" &>/dev/null || true
    ok "Projectivy configured."
}

# ── tvQuickActions permissions ───────────────────────────────────────────
configure_tvquickactions_permissions() {
    local pkg="dev.vodik7.tvquickactions.free"
    local svc="${pkg}/dev.vodik7.tvquickactions.KeyAccessibilityService"

    if adb shell pm list packages 2>/dev/null | grep -q "^package:${pkg}$"; then
        info "Configuring tvQuickActions permissions..."
        local current_a11y=$(adb shell settings get secure enabled_accessibility_services 2>/dev/null | tr -d '\r')

        if [[ "$current_a11y" == "null" || -z "$current_a11y" ]]; then
            adb shell settings put secure enabled_accessibility_services "$svc"
        elif [[ "$current_a11y" != *"$svc"* ]]; then
            adb shell settings put secure enabled_accessibility_services "${current_a11y}:${svc}"
        fi

        adb shell appops set "$pkg" AUTO_START allow 2>/dev/null || true
        adb shell appops set "$pkg" SYSTEM_ALERT_WINDOW allow 2>/dev/null || true
        adb shell dumpsys deviceidle whitelist +"$pkg" &>/dev/null || true
        ok "tvQuickActions linked."
    fi
}