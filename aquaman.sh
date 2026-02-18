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
    "com.ejemplo.app1"
    "com.ejemplo.app2"
    "com.google.android.youtube.tv"
    "com.netflix.ninja"
)

echo "===== PRO ANDROID SCRIPT - Mi TV Stick ====="

for pkg in "${PACKAGES[@]}"; do
    echo "----------------------------------------"
    echo "[INFO] Processing package: $pkg"

    # Try uninstalling for user 0
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

echo "===== PROCESS COMPLETED ====="

# You can add extra adb commands below:
# adb install your_app.apk
# adb shell pm enable com.example.app
# etc.
