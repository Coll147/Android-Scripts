#!/bin/bash
# ==============================================================================
#  TCL TV - Android 11
# ==============================================================================
#  NOTE: Some TCL proprietary packages lack clear public documentation.
#  They have been classified based on typical Android TV behaviour.
#  Always verify remote and system work after first reboot.
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
section "PRE-CHECKS"
run_pre_checks

APK_DIR="${SCRIPT_DIR}/../apks"
APK_PROJ="${APK_DIR}/proyectivity.apk"

if [[ ! -d "$APK_DIR" ]]; then
    info "Creating folder '${APK_DIR}'..."
    mkdir -p "$APK_DIR"
fi

download_projectivy "$APK_PROJ"

# ==============================================================================
#  PACKAGES (unified list)
#  - Lines with 'remove_pkg' will be uninstalled.
#  - Lines with '# remove_pkg' are kept (commented out).
# ==============================================================================
section "PACKAGES"

# --- Spyware / telemetry ---
remove_pkg "com.google.android.feedback"           "Google feedback - error reporting"
remove_pkg "com.tcl.guard"                         "TCL Safety Guard - permission/app/cache manager [replaced by appops]"
remove_pkg "com.tcl.waterfall.overseas"            "TCL Waterfall - content recommendations & ads"
remove_pkg "com.tcl.usercenter"                    "TCL User Center - account & telemetry"

# --- TCL bloatware ---
remove_pkg "com.tcl.esticker"                      "TCL eSticker - decorative stickers/widgets"
remove_pkg "com.tcl.keyhelp"                       "TCL Key Help - on-screen button help"
remove_pkg "com.tcl.factory.view"                  "TCL Factory View - factory testing"
remove_pkg "com.tcl.partnercustomizer"             "TCL Partner Customizer - OEM/carrier customisation"
remove_pkg "com.tcl.dashboard"                     "TCL Dashboard - proprietary widget panel"
remove_pkg "com.tcl.messagebox"                    "TCL MessageBox - promotional notifications"
remove_pkg "com.tcl.ttvs"                          "TCL TTVS - undocumented service [check remote after reboot]"
# remove_pkg "com.tcl.settings"                    # keep - TCL settings submenu
remove_pkg "com.tcl.suspension"                    "TCL Suspension - standby/quick-start management"
remove_pkg "android.autoinstalls.config.tcl.device" "TCL auto-installer - default app config"

# --- Google TV Launcher & screensavers ---
remove_pkg "com.google.android.tvlauncher"         "Google TV Launcher (replaced by Projectivy)"
remove_pkg "com.google.android.backdrop"           "Google Backdrop screensaver"
remove_pkg "com.android.dreams.basic"              "Basic Daydreams screensaver"
remove_pkg "com.google.android.tvrecommendations"  "TV recommendations engine (RAM/CPU hog)"

# --- Voice & accessibility ---
# remove_pkg "com.google.android.katniss"          # keep - Assistant voice search engine
# remove_pkg "com.google.android.tv.assistant"     # keep - Google Assistant service
# remove_pkg "com.google.android.tts"              # keep - Assistant text-to-speech
# remove_pkg "com.tcl.micmanager"                  # keep - physical mic for Assistant
remove_pkg "com.tcl.smartalexa"                    "TCL Alexa integration (not Google)"
remove_pkg "com.google.android.marvin.talkback"    "TalkBack - screen reader"
remove_pkg "com.tcl.hearaid"                       "TCL HearAid - hearing assistance"

# --- Initial setup wizards ---
remove_pkg "com.tcl.initsetup"                     "TCL Initial Setup Wizard"
remove_pkg "com.tcl.useragreement"                 "TCL User Agreement (legal notice)"
remove_pkg "com.tcl.copydatatotv"                  "TCL Copy Data to TV (mobile transfer)"
remove_pkg "com.tcl.autopair"                      "TCL Autopair - remote pairing [can re-pair manually]"
remove_pkg "com.google.android.onetimeinitializer" "Google one-time init (first boot)"
remove_pkg "com.google.android.tungsten.setupwraith" "Android TV setup assistant"
remove_pkg "com.google.android.partnersetup"       "Google partner setup (OEM config)"
# remove_pkg "com.google.android.apps.nbu.smartconnect.tv" # keep - quick setup via Google Home
remove_pkg "com.android.settings.intelligence"     "Settings intelligence (suggestions)"

# --- Backup, sync, cloud ---
remove_pkg "com.android.backupconfirm"             "Backup confirmation UI"
remove_pkg "com.android.wallpaperbackup"           "Wallpaper backup"
remove_pkg "com.android.sharedstoragebackup"       "Shared storage backup"
remove_pkg "com.google.android.syncadapters.calendar" "Google Calendar sync"

# --- Chromecast receiver ---
# remove_pkg "com.google.android.apps.mediashell"  # keep - Chromecast receiver

# --- Preinstalled streaming apps ---
remove_pkg "com.amazon.amazonvideo.livingroom"     "Amazon Prime Video"
remove_pkg "com.netflix.ninja"                     "Netflix"
remove_pkg "au.com.stan.and"                       "Stan (Australian streaming)"
remove_pkg "tv.wuaki.apptv"                        "Wuaki TV / Rakuten TV"
remove_pkg "com.google.android.videos"             "Google Play Movies & TV"
remove_pkg "com.google.android.youtube.tv"         "YouTube for TV"
remove_pkg "com.google.android.youtube.tvmusic"    "YouTube Music for TV"
remove_pkg "com.google.android.play.games"         "Google Play Games"
remove_pkg "com.tcl.videoplayer"                   "TCL Video Player"
remove_pkg "com.tcl.audioplayer"                   "TCL Audio Player"
remove_pkg "com.tcl.imageplayer"                   "TCL Image Player"
remove_pkg "com.tcl.ui_mediaCenter"                "TCL Media Center"

# --- Miscellaneous system leftovers ---
remove_pkg "com.android.cts.priv.ctsshim"          "CTS private shim (testing only)"
remove_pkg "com.android.cts.ctsshim"               "CTS shim (testing only)"
remove_pkg "com.android.htmlviewer"                "Basic HTML viewer"
remove_pkg "com.android.providers.calendar"        "Calendar provider"
remove_pkg "com.android.providers.userdictionary"  "User dictionary"
remove_pkg "com.android.printspooler"              "Print spooler (useless on TV)"
remove_pkg "com.android.vpndialogs"                "VPN dialogs (rarely needed)"
remove_pkg "com.google.android.sss.authbridge"     "Google OAuth bridge (obsolete)"
remove_pkg "com.google.android.tv.frameworkpackagestubs" "Compatibility stubs"

# --- Android core (DO NOT REMOVE) ---
# remove_pkg "android"                                             # system base
# remove_pkg "com.android.systemui"                                # system UI
# remove_pkg "com.android.shell"                                   # shell (used by adb)
# remove_pkg "com.google.android.gms"                              # Google Play Services
# remove_pkg "com.google.android.gsf"                              # Google Services Framework
# remove_pkg "com.android.vending"                                 # Play Store
# remove_pkg "com.google.android.packageinstaller"                 # APK installer
# remove_pkg "com.google.android.webview"                          # WebView
# remove_pkg "com.google.android.permissioncontroller"             # permission manager
# remove_pkg "com.google.android.overlay.modules.permissioncontroller"
# remove_pkg "com.google.android.overlay.modules.permissioncontroller.forframework"
# remove_pkg "com.google.android.overlay.modules.ext.services"
# remove_pkg "com.google.android.overlay.modules.modulemetadata.forframework"
# remove_pkg "com.google.android.ext.services"
# remove_pkg "com.google.android.ext.shared"
# remove_pkg "com.google.android.modulemetadata"
# remove_pkg "com.android.keychain"
# remove_pkg "com.android.certinstaller"
# remove_pkg "com.android.statementservice"
# remove_pkg "com.android.providers.settings"
# remove_pkg "com.android.providers.settings.auto_generated_rro_product__"
# remove_pkg "com.android.providers.settings.auto_generated_rro_vendor__"
# remove_pkg "com.android.providers.media"
# remove_pkg "com.android.providers.media.module"
# remove_pkg "com.android.providers.downloads"
# remove_pkg "com.android.providers.contacts"
# remove_pkg "com.android.providers.contacts.auto_generated_rro_product__"
# remove_pkg "com.android.providers.tv"                            # EPG / live channels
# remove_pkg "com.android.externalstorage"                         # USB/external storage
# remove_pkg "com.android.companiondevicemanager"
# remove_pkg "com.android.localtransport"
# remove_pkg "com.android.proxyhandler"
# remove_pkg "com.android.pacprocessor"
# remove_pkg "com.android.se"                                      # Secure Element
# remove_pkg "com.android.inputdevices"                            # input management
# remove_pkg "com.android.location.fused"
# remove_pkg "com.android.soundpicker"
# remove_pkg "com.android.hotspot2.osulogin"
# remove_pkg "com.android.captiveportallogin"
# remove_pkg "com.android.dynsystem"
# remove_pkg "com.google.android.inputmethod.latin"                # keyboard

# --- Network & connectivity (DO NOT REMOVE) ---
# remove_pkg "com.android.bluetooth"
# remove_pkg "com.android.bluetooth.auto_generated_rro_product__"
# remove_pkg "com.android.bluetooth.auto_generated_rro_vendor__"
# remove_pkg "com.android.networkstack.inprocess"
# remove_pkg "com.android.networkstack.tethering.inprocess"
# remove_pkg "com.android.networkstack.tethering.inprocess.rro"
# remove_pkg "com.android.networkstack.tethering.rro"
# remove_pkg "com.android.networkstack.permissionconfig"
# remove_pkg "com.android.tethering.overlay"
# remove_pkg "com.android.tethering.overlay.gsi"
# remove_pkg "com.android.wifi.resources"
# remove_pkg "com.android.wifi.resources.rro"
# remove_pkg "com.tcl.wifi.resources.overlay"
# remove_pkg "android.auto_generated_rro_product__"
# remove_pkg "android.auto_generated_rro_vendor__"

# --- TCL hardware/firmware (DO NOT REMOVE) ---
# remove_pkg "com.tcl.system.server"                               # TCL system process
# remove_pkg "com.tcl.tcl_bt_rcu_service"                          # Bluetooth remote (breaks remote)
# remove_pkg "com.tcl.tvinput"                                     # HDMI / tuner inputs
# remove_pkg "com.tcl.providers.config"                            # shared config
# remove_pkg "com.tcl.tv"                                          # umbrella TCL TV service
# remove_pkg "com.tcl.android.webview"                             # TCL WebView variant
# remove_pkg "com.android.tv.settings"                             # native TV settings
# remove_pkg "com.android.tv.settings.gms.resoverlay"              # settings overlay
# remove_pkg "com.google.android.tv.remote.service"                # remote service

# --- Google Assistant / Home / Play Store (kept) ---
# remove_pkg "com.google.android.katniss"                          # keep - voice search
# remove_pkg "com.google.android.tv.assistant"                     # keep - Assistant
# remove_pkg "com.google.android.tts"                              # keep - TTS
# remove_pkg "com.google.android.apps.nbu.smartconnect.tv"         # keep - Google Home setup
# remove_pkg "com.tcl.micmanager"                                  # keep - mic
# remove_pkg "com.android.vending"                                 # keep - Play Store

# ==============================================================================
#  INSTALL APKs FROM FOLDER
# ==============================================================================
section "INSTALLING APKs FROM 'apks' FOLDER"
install_apks_from_folder "$APK_DIR"

# ==============================================================================
#  PERMISSIONS
# ==============================================================================
section "ASSIGNING PERMISSIONS"
configure_projectivy_permissions
configure_tvquickactions_permissions

# Extra for tvQuickActions auto-start (since TCL Guard is removed)
info "Granting APP_AUTO_START to tvQuickActions via appops..."
adb shell appops set dev.vodik7.tvquickactions APP_AUTO_START allow
ok "APP_AUTO_START granted"

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

    info "Disabling Play Protect (ADB installs)..."
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

echo -e "\n${GREEN}${BOLD}Done! TV is rebooting with optimized settings.${NC}\n"