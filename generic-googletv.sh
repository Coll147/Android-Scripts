#!/bin/bash

# ==============================
# System Optimization Script by Coll147
# Android TV 14 / Google TV
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
    "com.google.android.apps.tv.launcherx"
    "com.disney.disneyplus"
    "com.movistarplus.androidtv"
    "com.google.android.apps.tv.launcherx"
    "com.google.android.feedback"
    "com.google.android.syncadapters.calendar"
    "com.android.adservices.api"

)

echo "=== PRO ANDROID TV SCRIPT - Google TV 14 ==="

echo ">>> Removing / Disabling unnecessary packages"

for pkg in "${PACKAGES[@]}"; do
    echo "----------------------------------------"
    echo "[INFO] Processing package: $pkg"

    if adb shell pm uninstall --user 0 "$pkg"; then
        echo "[OK] Successfully uninstalled: $pkg"
    else
        echo "[WARN] Uninstall failed. Trying to disable..."
        if adb shell pm disable-user --user 0 "$pkg"; then
            echo "[OK] Successfully disabled: $pkg"
        else
            echo "[ERROR] Could not uninstall or disable: $pkg"
        fi
    fi
done

echo ">>> Performance & Animation tweaks"

adb shell settings put global animator_duration_scale 1
adb shell settings put global window_animation_scale 1
adb shell settings put global transition_animation_scale 1
adb shell settings put global background_process_limit 1
adb shell settings put global activity_manager_constants max_cached_processes=8,background_settle_time=0
adb shell setprop persist.logd.size 1M

# Developer options / debug tweaks
adb shell settings put global device_config_sync_disabled_for_tests persistent

echo ">>> Installing custom launcher"

wget -O ProjectivyLauncher.apk https://github.com/spocky/miproja1/releases/download/4.68/ProjectivyLauncher-4.68-c82-xda-release.apk
adb install -r ProjectivyLauncher.apk

# Grant only TV-relevant permissions
adb shell pm grant com.spocky.projengmenu com.android.providers.tv.permission.READ_EPG_DATA
adb shell pm grant com.spocky.projengmenu com.android.providers.tv.permission.WRITE_EPG_DATA

# Accessibility & Notification access
adb shell settings put secure enabled_notification_listeners com.spocky.projengmenu/com.spocky.projengmenu.services.notification.NotificationListener
adb shell settings put secure accessibility_enabled 1
adb shell settings put secure enabled_accessibility_services com.spocky.projengmenu/com.spocky.projengmenu.services.ProjectivyAccessibilityService

# Set custom launcher as home
adb shell cmd package set-home-activity com.spocky.projengmenu/.ui.home.MainActivity

echo "=== All Done ==="
echo ">>> Rebooting device..."
adb reboot
