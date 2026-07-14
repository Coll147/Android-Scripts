#!/bin/bash
# ==============================================================================
#  Xiaomi Mi TV Stick - Android 9
# ==============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_SCRIPT="${SCRIPT_DIR}/../core/core.sh"

if [[ -f "$CORE_SCRIPT" ]]; then
    source "$CORE_SCRIPT"
else
    echo -e "\033[0;31m[ERR]\033[0m core.sh not found at ${CORE_SCRIPT}"
    exit 1
fi

# ==============================================================================
#  PRE-CHECKS & SETUP
# ==============================================================================
section "PRE-CHECKS & SETUP"
run_pre_checks

APK_DIR="${SCRIPT_DIR}/../apks"
APK_PROJ="${APK_DIR}/proyectivity.apk"

if [[ ! -d "$APK_DIR" ]]; then
    info "Creating folder '${APK_DIR}'..."
    mkdir -p "$APK_DIR"
fi

download_projectivy "$APK_PROJ"

# ==============================================================================
#  PACKAGES
# ==============================================================================
section "PACKAGES"

# --- Spyware & telemetry ---
remove_pkg "tv.alphonso.alphonso_eula"               "Alphonso - audience tracking via mic (SPYWARE)"
remove_pkg "com.miui.tv.analytics"                   "Xiaomi analytics - usage telemetry"
remove_pkg "com.google.android.feedback"             "Google feedback - error reporting"
remove_pkg "com.google.android.tv.bugreportsender"   "TV bug reporter - logs to Google"
remove_pkg "com.xiaomi.mitv.updateservice"           "Xiaomi OTA updater"

# --- Xiaomi bloatware ---
remove_pkg "mitv.service"                                  "Xiaomi TV main service"
remove_pkg "com.xiaomi.android.tvsetup.partnercustomizer"  "Xiaomi partner customizer"
remove_pkg "com.xiaomi.mitv.res"                           "Xiaomi additional resources"
remove_pkg "com.xiaomo.tv.milegal"                         "Xiaomi legal notice (pop-up)"
remove_pkg "com.mitv.tvhome.atv"                           "Xiaomi ATV launcher (PatchWall)"
remove_pkg "com.mitv.tvhome.michannel"                     "Xiaomi home screen channels"
remove_pkg "com.mitv.milinkservice"                        "MiLink - screen mirroring"
remove_pkg "com.mitv.download.service"                     "Xiaomi downloader"
remove_pkg "com.mitv.videoplayer"                          "Xiaomi video player"
remove_pkg "com.xm.webcontent"                             "Xiaomi web content (ads/news)"
remove_pkg "com.mitv.dream"                                "Xiaomi screensaver"
remove_pkg "android.autoinstalls.config.xioami.mibox3"     "Auto-installer (typo in name)"
remove_pkg "android.autoinstalls.config.xiaomi.mibox3"     "Auto-installer Mi Box 3"

# --- Google TV Launcher & screensavers ---
remove_pkg "com.google.android.tvlauncher"         "Google TV Launcher (replaced by Projectivy)"
remove_pkg "com.google.android.tv"                 "Android TV Home (Google launcher base)"
remove_pkg "com.google.android.tvrecommendations"  "TV recommendations engine (RAM/CPU hog)"
remove_pkg "com.google.android.backdrop"           "Google Backdrop screensaver"
remove_pkg "com.android.dreams.basic"              "Basic Daydreams screensaver"

# --- Google Assistant & voice ---
remove_pkg "com.google.android.katniss"            "Google Search / Assistant for TV"
remove_pkg "com.google.android.speech.pumpkin"     "Offline voice recognition"
remove_pkg "com.google.android.marvin.talkback"    "TalkBack - screen reader"
remove_pkg "com.google.android.tts"                "Google Text-to-Speech"

# --- Setup wizards ---
remove_pkg "com.google.android.onetimeinitializer" "Google one-time init"
remove_pkg "com.android.onetimeinitializer"        "Android one-time init"
remove_pkg "com.google.android.partnersetup"       "Google partner setup"
remove_pkg "com.google.android.tungsten.setupwraith" "Android TV setup assistant"
remove_pkg "com.android.settings.intelligence"     "Settings intelligence"

# --- Backup, sync, cloud ---
remove_pkg "com.google.android.backuptransport"       "Google Backup Transport"
remove_pkg "com.google.android.syncadapters.contacts" "Google Contacts sync"
remove_pkg "com.google.android.syncadapters.calendar" "Google Calendar sync"
remove_pkg "com.android.backupconfirm"                "Backup confirmation UI"
remove_pkg "com.android.wallpaperbackup"              "Wallpaper backup"
remove_pkg "com.android.sharedstoragebackup"          "Shared storage backup"

# --- Chromecast receiver (keep by default) ---
# remove_pkg "com.google.android.apps.mediashell"   # keep - Chromecast receiver

# --- Preinstalled streaming & miscellaneous ---
remove_pkg "com.google.android.videos"              "Play Movies & TV"
remove_pkg "com.google.android.play.games"          "Google Play Games"
remove_pkg "com.google.android.youtube.tv"          "YouTube for TV"
remove_pkg "com.google.android.youtube.tvmusic"     "YouTube Music for TV"
remove_pkg "com.amazon.amazonvideo.livingroom"      "Amazon Prime Video"
remove_pkg "com.netflix.ninja"                      "Netflix"
remove_pkg "com.android.printspooler"               "Print spooler"
remove_pkg "com.android.htmlviewer"                 "Basic HTML viewer"
remove_pkg "com.android.providers.calendar"         "Calendar provider"
remove_pkg "com.android.providers.userdictionary"   "User dictionary"
remove_pkg "com.android.cts.priv.ctsshim"           "CTS private shim (testing)"
remove_pkg "com.android.cts.ctsshim"                "CTS shim (testing)"
remove_pkg "com.google.android.sss.authbridge"      "Google OAuth bridge"
remove_pkg "com.google.android.tv.frameworkpackagestubs" "Compatibility stubs"
remove_pkg "com.android.vpndialogs"                 "VPN dialogs"

# ==============================================================================
#  INSTALL APKs
# ==============================================================================
section "INSTALLING APKs FROM 'apks' FOLDER"
install_apks_from_folder "$APK_DIR"

# ==============================================================================
#  PERMISSIONS
# ==============================================================================
section "ASSIGNING PERMISSIONS"
configure_projectivy_permissions
configure_tvquickactions_permissions

# ==============================================================================
#  SET DEFAULT LAUNCHER
# ==============================================================================
section "DEFAULT LAUNCHER"
info "Setting Projectivy as home activity..."
adb shell cmd package set-home-activity "com.spocky.projengmenu/.ui.home.MainActivity"
ok "Projectivy set as default launcher"

# ==============================================================================
#  PERFORMANCE TWEAKS (device-specific)
# ==============================================================================
section "APPLYING GLOBAL PERFORMANCE TWEAKS"
apply_performance_tweaks() {
    info "Reducing animation scales (1x)..."
    adb shell settings put global animator_duration_scale 1
    adb shell settings put global window_animation_scale 1
    adb shell settings put global transition_animation_scale 1

    info "Forcing HW SkiaGL renderer..."
    adb shell setprop persist.debug.hwui.renderer skiagl
    adb shell setprop persist.sys.ui.hw 1

    info "Adjusting background process limits and Doze..."
    adb shell settings put global background_process_limit 4
    adb shell settings put global activity_manager_constants \
        "max_cached_processes=6,background_settle_time=30000,fgservice_min_shown_time=2000,fgservice_timeout=20000"

    info "Disabling Play Protect..."
    adb shell settings put global package_verifier_enable 0
    adb shell settings put global verifier_verify_adb_installs 0

    info "Silencing telemetry and log buffers..."
    adb shell settings put global captive_portal_detection_enabled 0
    adb shell setprop persist.logd.size 64K
    adb shell setprop persist.sys.strictmode.disable 1

    adb shell settings put global send_action_app_error 0
    adb shell settings put global dropbox:data_app_crash 0 2>/dev/null || true
    adb shell settings put global dropbox:data_app_anr 0 2>/dev/null || true
    adb shell settings put global device_config_sync_disabled_for_tests persistent

    info "Applying MediaTek/Amlogic performance patches..."
    adb shell setprop persist.debug.hwui.profile false
    adb shell settings put global enable_dump_heap_traces 0 2>/dev/null || true
    adb shell setprop persist.sys.dumpheap false 2>/dev/null || true
    ok "System tweaks applied."
}
apply_performance_tweaks

# ==============================================================================
#  FINAL SUMMARY
# ==============================================================================
section "SUMMARY"
echo -e "  ${GREEN}✓ Uninstalled:        ${BOLD}${REMOVED}${NC}"
echo -e "  ${YELLOW}⚠ Disabled:           ${BOLD}${DISABLED}${NC}"
echo -e "  ${BLUE}↷ Skipped:             ${BOLD}${SKIPPED}${NC}  (not installed)"
echo -e "  ${RED}✗ Failed bloat:        ${BOLD}${FAILED}${NC}"
echo -e "  ${GREEN}✓ APKs installed:      ${BOLD}${INSTALLED_APKS}${NC}"
[[ $FAILED_APKS -gt 0 ]] && echo -e "  ${RED}✗ APKs failed:         ${BOLD}${FAILED_APKS}${NC}"

echo ""
echo -e "${BOLD}${CYAN}════ MANUAL STEPS RECOMMENDED (on TV) ════${NC}"
echo ""
echo -e "  Go to: ${BOLD}Settings → Developer options${NC}"
echo ""
echo -e "  1. ${BOLD}Logger buffer size${NC}   →  ${GREEN}1 MB${NC}"
echo ""
echo -e "  2. ${BOLD}Background processes${NC} →  ${GREEN}At most 1 process${NC}"
echo ""
echo -e "  3. ${BOLD}HWUI renderer${NC}        →  ${GREEN}skiagl${NC}"
echo ""
echo -e "  4. ${BOLD}Activate Projectivy${NC}: confirm default launcher when pressing Home"
echo ""

info "Rebooting device in 3 seconds..."
sleep 3
adb reboot

echo -e "\n${GREEN}${BOLD}Done! TV Stick is rebooting with optimised settings.${NC}\n"