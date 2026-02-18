#!/bin/bash
set -x

# ==============================
# System Optimization Script by Coll147
# Xiaomi Mi TV Stick (1080p)
# ==============================

# Checks
if ! command -v adb &> /dev/null; then
    echo "[ERROR] adb is not installed or not in PATH."
    exit 1
fi

echo "[INFO] Checking connected device..."
if ! adb get-state 1>/dev/null 2>&1; then
    echo "[ERROR] No device connected or not authorized."
    exit 1
fi

# Packages to remove/disable
PACKAGES=(
    # -- Google packages
    "com.google.android.onetimeinitializer"
    "com.android.onetimeinitializer"
    "com.google.android.partnersetup"
    "com.google.android.tts"
    "com.google.android.feedback"
    "com.google.android.backuptransport"
    "com.google.android.syncadapters.contacts"
    "com.google.android.syncadapters.calendar"
    # -- Android
    "com.google.android.tvlauncher"
    "com.google.android.tv"
    "com.google.android.tvrecommendations"
    "com.google.android.tv.bugreportsender"
    "com.google.android.marvin.talkback"
    "com.android.htmlviewer"
    "com.android.printspooler"
    "com.android.wallpaperbackup"
    "com.android.backupconfirm"
    "com.android.sharedstoragebackup"
    "com.google.android.tungsten.setupwraith"
    "com.android.settings.intelligence"
    # -- Xiaomi Things
    "com.xiaomi.mitv.updateservice"
    "com.xiaomi.mitv.res"
    "com.xiaomi.android.tvsetup.partnercustomizer"
    "com.xiaomo.tv.milegal"
    "com.miui.tv.analytics"
    "com.mitv.dream"
    "com.mitv.milinkservice"
    "com.mitv.tvhome.michannel"
    "com.mitv.tvhome.atv"
    "com.mitv.download.service"
    "com.mitv.videoplayer"
    "mitv.service"
    "com.xm.webcontent"
    "tv.alphonso.alphonso_eula"
    "android.autoinstalls.config.xioami.mibox3"
    "android.autoinstalls.config.xiaomi.mibox3"
    # -- Preinstaled APPS
    "com.google.android.videos"
    "com.google.android.play.games"
    "com.google.android.youtube.tvmusic"
    "com.amazon.amazonvideo.livingroom"
    "com.netflix.ninja"
    "com.google.android.youtube.tv"
)

echo "=== PRO ANDROID SCRIPT - Mi TV Stick ==="

echo ">>> Removing / Nuking / Whatever the pkg list"

for pkg in "${PACKAGES[@]}"; do
    echo "----------------------------------------"
    echo "[INFO] Processing package: $pkg"

    # Try uninstalling
    if adb shell pm uninstall --user 0 "$pkg"; then
        echo "[OK] Successfully uninstalled: $pkg"
    else
        echo "[WARN] Uninstall failed. Trying to disable..."

        # Try disabling if uninstall fails
        if adb shell pm disable-user --user 0 "$pkg"; then
            echo "[OK] Successfully disabled: $pkg"
        else
            echo "[ERROR] Could not uninstall or disable: $pkg"
        fi
    fi
done


echo ">>> Miscelaneus Adjustments"

adb shell settings put global animator_duration_scale 0
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global debug.hwui.renderer skiagl
adb shell settings put global background_process_limit 1
adb shell settings put global activity_manager_constants max_cached_processes=8
adb shell settings put global activity_manager_constants background_settle_time=0
adb shell setprop persist.logd.size 1M
adb shell settings put global device_config_sync_disabled_for_tests persistent


echo ">>> Installing new launcher"

wget https://github.com/spocky/miproja1/releases/download/4.68/ProjectivyLauncher-4.68-c82-xda-release.apk
adb install -r ProjectivyLauncher-4.68-c82-xda-release.apk

adb shell pm grant com.spocky.projengmenu android.permission.WRITE_EXTERNAL_STORAGE
adb shell pm grant com.spocky.projengmenu android.permission.READ_EXTERNAL_STORAGE
adb shell pm grant com.spocky.projengmenu android.permission.READ_PHONE_STATE
adb shell pm grant com.spocky.projengmenu android.permission.READ_TV_LISTINGS

adb shell settings put secure enabled_notification_listeners com.spocky.projengmenu/com.spocky.projengmenu.services.notification.NotificationListener
adb shell settings put secure accessibility_enabled 1
adb shell settings put secure enabled_accessibility_services com.spocky.projengmenu/com.spocky.projengmenu.services.ProjectivyAccessibilityService
adb shell cmd package set-home-activity com.spocky.projengmenu/.ui.home.MainActivity


echo "=== Alllllllll Ready ==="
echo ">>> Rebooting the little thing :)"
adb reboot


echo "After this, you should go to developer options and change"
echo "buffer registry size: 1M"
echo "background processes: Any or 1"