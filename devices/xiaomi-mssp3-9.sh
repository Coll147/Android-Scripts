#!/bin/bash
# ==============================================================================
#  Xiaomi Mi TV (MSSP3) - Android 9
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

[[ ! -d "$APK_DIR" ]] && mkdir -p "$APK_DIR"
download_projectivy "$APK_PROJ"

# ==============================================================================
#  PACKAGES (unified list)
# ==============================================================================
section "PACKAGES"

# --- Spyware & telemetry (Xiaomi / Google) ---
remove_pkg "com.miui.tv.analytics"                 "Xiaomi Analytics - aggressive usage telemetry"
remove_pkg "com.xiaomi.statistic"                  "Xiaomi Statistics - background reports"
remove_pkg "com.google.android.feedback"           "Google Feedback - error reporting"
remove_pkg "com.google.android.tv.bugreportsender" "Google Bug Reporter - background logs"

# --- Xiaomi residential bloatware ---
remove_pkg "android.autoinstalls.config.xiaomi.amelie" "Auto-installer for Amelie board"
remove_pkg "com.xm.webcontent"                         "Xiaomi WebContent - ads and banners"
remove_pkg "com.xiaomo.tv.milegal"                     "Xiaomi legal contract"
remove_pkg "com.mitv.tvlock"                           "Xiaomi lock screen / hotel mode"
remove_pkg "com.mitv.tvhome.mitvplus"                  "Xiaomi Mi TV+ - FAST streaming (RAM hog)"
remove_pkg "com.mitv.tvhome.michannel"                 "Mi Channel - PatchWall redundant channels"
remove_pkg "com.xiaomi.mitv.updateservice"             "Xiaomi OTA service (prevents future patches)"
remove_pkg "com.xiaomi.mitv.tvmanager"                 "Mi TV Manager - useless cleaner (overlays)"
remove_pkg "com.mitv.dream"                            "Xiaomi screensaver/wallpapers"
remove_pkg "com.mitv.tvhome.atv"                       "Xiaomi PatchWall launcher"

# --- Multimedia & gallery (replaceable) ---
remove_pkg "com.xiaomi.mitv.mediaexplorer"           "Xiaomi Media Explorer - clunky file manager"
remove_pkg "com.xiaomi.mimusic2"                     "Mi Music - heavy native player"
remove_pkg "com.mitv.videoplayer"                    "Mi Video Player - basic player"
remove_pkg "com.mitv.gallery"                        "Mi Gallery - native photo viewer"

# --- Recommendations & assistant providers ---
remove_pkg "com.google.android.tvrecommendations"   "Google TV Recommendations - CPU hog"
remove_pkg "com.google.android.leanbacklauncher.recommendations" "Leanback suggestions module"
# remove_pkg "com.google.android.katniss"             # keep - Google Assistant voice search (optional)
remove_pkg "com.google.android.speech.pumpkin"       "Offline voice-to-text engine"
remove_pkg "com.google.android.marvin.talkback"      "TalkBack - screen reader"
remove_pkg "com.google.android.tts"                  "Google Text-to-Speech"

# --- Cloud processes & test checks ---
remove_pkg "com.google.android.backuptransport"      "Google Backup Cloud"
remove_pkg "com.google.android.syncadapters.calendar" "Google Calendar sync"
remove_pkg "com.google.android.syncadapters.contacts" "Google Contacts sync"
remove_pkg "com.android.providers.calendar"          "Local calendar storage"
remove_pkg "com.google.android.sss.authbridge"       "Obsolete Google OAuth bridge"
remove_pkg "com.android.cts.priv.ctsshim"            "CTS private shim (testing)"
remove_pkg "com.android.cts.ctsshim"                 "CTS public shim (testing)"
remove_pkg "com.google.android.tv.frameworkpackagestubs" "Empty compatibility stubs"

# --- Third-party replaceable apps / scrap ---
remove_pkg "com.google.android.videos"               "Google Play Movies"
remove_pkg "com.google.android.play.games"           "Google Play Games for TV"
remove_pkg "com.google.android.youtube.tv"           "YouTube (install SmartTube instead)"
remove_pkg "com.google.android.youtube.tvmusic"      "YouTube Music"
remove_pkg "com.amazon.amazonvideo.livingroom"       "Amazon Prime Video"
# remove_pkg "com.netflix.ninja"                      # keep - Netflix (HD compatibility)
remove_pkg "com.android.printspooler"                "Print service"
remove_pkg "com.android.htmlviewer"                  "HTML viewer"
remove_pkg "com.android.vpndialogs"                  "VPN dialogs"
remove_pkg "com.android.backupconfirm"               "Backup confirmation UI"
remove_pkg "com.android.sharedstoragebackup"         "Shared storage backup"
remove_pkg "com.android.wallpaperbackup"             "Wallpaper backup"
remove_pkg "com.android.providers.userdictionary"    "User dictionary"

# --- Critical components, MediaTek & Android core (DO NOT REMOVE) ---
# remove_pkg "mitv.service"                                 # Xiaomi TV core service
# remove_pkg "com.xiaomi.android.tvsetup.partnercustomizer" # initial partner setup
# remove_pkg "com.xiaomi.floatingframe"                     # frame rendering
# remove_pkg "com.xiaomi.mitv.res"                          # system resources
# remove_pkg "com.google.android.ext.services"              # extension services
# remove_pkg "com.google.android.ext.shared"                # shared libraries
# remove_pkg "com.google.android.apps.mediashell"           # Chromecast (breaks Cast)
# remove_pkg "com.android.tv.settings"                      # native settings
# remove_pkg "com.android.providers.media"                  # media indexer
# remove_pkg "com.google.android.onetimeinitializer"        # Google initial setup
# remove_pkg "com.android.externalstorage"                  # external storage (USB)
# remove_pkg "com.android.companiondevicemanager"           # companion device manager
# remove_pkg "com.android.providers.downloads"              # download manager
# remove_pkg "com.android.providers.tv"                     # TV channel database
# remove_pkg "com.google.android.backdrop"                  # Google Ambient Mode screensaver
# remove_pkg "com.android.defcontainer"                     # package container
# remove_pkg "com.android.vending"                          # Play Store
# remove_pkg "com.android.pacprocessor"                     # proxy processor
# remove_pkg "com.android.certinstaller"                    # certificate installer
# remove_pkg "com.android.statementservice"                 # app link verification
# remove_pkg "com.android.settings.intelligence"            # settings search
# remove_pkg "com.android.providers.settings"               # settings storage
# remove_pkg "com.android.se"                               # Secure Element
# remove_pkg "com.android.inputdevices"                     # peripheral drivers
# remove_pkg "com.google.android.tvlauncher"                # default launcher (may affect HDMI inputs)
# remove_pkg "com.google.android.leanbacklauncher"          # classic Leanback launcher
# remove_pkg "com.google.android.webview"                   # WebView
# remove_pkg "com.android.keychain"                         # credential store
# remove_pkg "com.google.android.boot.appsplashscreen"      # boot splash
# remove_pkg "com.google.android.packageinstaller"          # APK installer
# remove_pkg "com.google.android.gms"                       # Play Services
# remove_pkg "com.google.android.gsf"                       # Google Services Framework
# remove_pkg "com.google.android.partnersetup"              # partner setup
# remove_pkg "com.google.android.tv.remote.service"         # remote service
# remove_pkg "com.android.proxyhandler"                     # proxy handler
# remove_pkg "com.android.location.fused"                   # fused location
# remove_pkg "com.android.systemui"                         # system UI
# remove_pkg "com.android.shell"                            # shell (ADB)
# remove_pkg "com.android.bluetooth"                        # Bluetooth
# remove_pkg "com.android.providers.contacts"               # contacts storage
# remove_pkg "com.android.captiveportallogin"               # captive portal login
# remove_pkg "com.google.android.inputmethod.latin"         # keyboard (Gboard)
# remove_pkg "com.google.android.tungsten.setupwraith"      # initial setup assistant
# remove_pkg "android"                                      # Android core

# --- MediaTek / MStar board-specific (DO NOT REMOVE unless sure) ---
# remove_pkg "com.mediatek.twoworlds.test.fapi"             # MediaTek test API
# remove_pkg "com.mediatek.tvinput"                         # physical TV inputs (HDMI/AV)
# remove_pkg "com.mediatek.wwtv.setupwizard"                # channel tuning wizard
# remove_pkg "com.mediatek.androidbox"                      # decoder optimisation libs
# remove_pkg "mediatek.factorymenu.ui"                      # hidden factory menu
# remove_pkg "com.mediatek.tv.factory"                      # hardware calibration
# remove_pkg "com.mediatek.hotkey.dispatcher"               # remote hotkey dispatcher
# remove_pkg "com.mstar.netflixobserver"                    # Netflix HD compatibility monitor
# remove_pkg "com.mediatek.wwtv.tvcenter"                   # digital TV control center
# remove_pkg "com.mediatek.tvinputservice.arbitratorservice" # video input arbitrator
# remove_pkg "com.mediatek.network"                         # network hardware driver
# remove_pkg "com.mediatek.tv.agent"                        # hardware communication agent

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

echo -e "\n${BOLD}${CYAN}════ EXTRA TIP FOR HDMI INPUTS ════${NC}\n"
echo -e "  1. In Projectivy Launcher, go to: ${BOLD}Settings → Cards / Sections${NC}."
echo -e "  2. Enable the ${GREEN}\"Inputs\"${NC} section."
echo -e "  3. You can then switch to HDMI1, HDMI2, or DTV directly."
echo -e "     (The stock launcher is kept in the background to avoid black screens.)"

info "Rebooting Smart TV in 3 seconds..."
sleep 3
adb reboot
ok "Process finished. Device optimised."