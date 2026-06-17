#!/bin/bash
# ==============================================================================
#  Core
# ==============================================================================

set -uo pipefail

# ── Colores y Formato (Corregidos) ───────────────────────────────────────────
RED='\033[0;31m';  GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m';  BOLD='\033[1m'; NC='\033[0m'

# ── Contadores Globales ───────────────────────────────────────────────────────
REMOVED=0; DISABLED=0; SKIPPED=0; FAILED=0
INSTALLED_APKS=0; FAILED_APKS=0

# ── Helpers de Interfaz ───────────────────────────────────────────────────────
info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()      { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERR]${NC}   $*"; }
skip()    { echo -e "        ${NC}↷ Saltado: $*"; }
section() { echo -e "\n${BOLD}${CYAN}▓▓▒░  $* ░▒▓▓${NC}\n"; }

# ── Lógica de Eliminación de Paquetes ─────────────────────────────────────────
remove_pkg() {
    local pkg="$1"
    local desc="$2"

    if ! adb shell pm list packages 2>/dev/null | grep -q "^package:${pkg}$"; then
        skip "${pkg} (${desc}) — no encontrado"
        ((SKIPPED++))
        return 0
    fi

    printf "  ${YELLOW}→${NC} %-55s %s\n" "$pkg" "(${desc})"

    if adb shell pm uninstall --user 0 "$pkg" &>/dev/null; then
        ok "Desinstalado"
        ((REMOVED++))
    elif adb shell pm disable-user --user 0 "$pkg" &>/dev/null; then
        warn "Deshabilitado (uninstall no disponible)"
        ((DISABLED++))
    else
        error "No se pudo eliminar ni deshabilitar: $pkg"
        ((FAILED++))
    fi
}

# ── Descarga Inteligente de Projectivy Launcher (Anti-Rate-Limit) ─────────────
download_projectivy() {
    local target_file="$1"
    local repo="spocky/miproja1"
    
    # SALVAGUARDA: Si el archivo ya existe localmente, evita llamar a la API de GitHub
    if [[ -f "$target_file" && -s "$target_file" ]]; then
        ok "Projectivy Launcher ya se encuentra en 'apks/'. Saltando descarga."
        return 0
    fi
    
    info "Buscando la última versión de Projectivy Launcher (incluyendo betas)..."
    local download_url=""
    
    # Forzamos un User-Agent común para que GitHub no rechace la petición remota
    if command -v curl &>/dev/null; then
        download_url=$(curl -sSL -A "Mozilla/5.0 (X11; Linux x86_64)" "https://api.github.com/repos/${repo}/releases" | grep -oP '"browser_download_url":\s*"\K[^"]+\.apk' | head -n 1)
    elif command -v wget &>/dev/null; then
        download_url=$(wget -qO- --user-agent="Mozilla/5.0 (X11; Linux x86_64)" "https://api.github.com/repos/${repo}/releases" | grep -oP '"browser_download_url":\s*"\K[^"]+\.apk' | head -n 1)
    else
        error "Se requiere curl o wget para descargar Projectivy Launcher automáticamente."
        exit 1
    fi

    if [[ -z "$download_url" ]]; then
        error "No se pudo obtener la URL de descarga (Límite de la API de GitHub alcanzado o sin red)."
        warn "Para saltarte este bloqueo de GitHub de forma manual:"
        echo -e "  1. Descarga cualquier APK de Projectivy desde: https://github.com/spocky/ProjectivyLauncher/releases"
        echo -e "  2. Muévelo y renombralo exactamente como: ${BOLD}apks/proyectivity.apk${NC}"
        echo -e "  3. Vuelve a lanzar tu script. ¡Se lo saltará y funcionará directo!"
        exit 1
    fi

    local version_name=$(echo "$download_url" | grep -oP 'download/\K[^/]+')
    info "Última versión detectada: ${BOLD}${version_name}${NC}"
    info "Descargando APK en la carpeta de instalación..."

    if command -v curl &>/dev/null; then
        curl -L -A "Mozilla/5.0 (X11; Linux x86_64)" -o "$target_file" "$download_url"
    else
        wget --user-agent="Mozilla/5.0 (X11; Linux x86_64)" -O "$target_file" "$download_url"
    fi

    if [[ -f "$target_file" && -s "$target_file" ]]; then
        ok "Projectivy Launcher descargado y listo."
    else
        error "Fallo al escribir el archivo APK en el disco."
        exit 1
    fi
}

# ── Ejecución de Comprobaciones Previas (Pre-Checks) ─────────────────────────
run_pre_checks() {
    if ! command -v adb &>/dev/null; then
        error "adb no está instalado o no está en el PATH. Abortando."
        exit 1
    fi

    info "Comprobando dispositivo..."
    if ! adb get-state &>/dev/null; then
        error "No hay dispositivo conectado o no está autorizado."
        echo -e "\n  Pasos para conectar:\n  1. En el TV: Ajustes → Información → Compilación (7 veces) → Opciones de desarrollador\n  2. Activar: Depuración por ADB / Depuración por red\n  3. Ejecutar: adb connect <IP_DEL_TV>:5555"
        exit 1
    fi

    local device=$(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r')
    local android=$(adb shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
    ok "Dispositivo: ${BOLD}${device}${NC} — Android ${BOLD}${android}${NC}"
}

# ── Instalación por Lotes del Contenido de 'apks/' ───────────────────────────
install_apks_from_folder() {
    local apk_dir="$1"
    
    shopt -s nullglob
    local apk_files=("$apk_dir"/*.apk)
    shopt -u nullglob

    if [[ ${#apk_files[@]} -eq 0 ]]; then
        warn "No se encontraron archivos APK adicionales en la carpeta '${apk_dir}'."
    else
        for apk in "${apk_files[@]}"; do
            local filename=$(basename "$apk")
            info "Instalando: ${filename}..."
            
            if adb install -r "$apk" &>/dev/null; then
                ok "Instalado correctamente: ${filename}"
                ((INSTALLED_APKS++))
            else
                error "Fallo al instalar: ${filename}"
                ((FAILED_APKS++))
            fi
        done
    fi
}

# ── Permisos de Projectivy Launcher ──────────────────────────────────────────
configure_projectivy_permissions() {
    local pkg="com.spocky.projengmenu"
    local svc="${pkg}/com.spocky.projengmenu.services.ProjectivyAccessibilityService"
    local nls="${pkg}/com.spocky.projengmenu.services.notification.NotificationListener"

    info "Aplicando permisos a Projectivy Launcher..."
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
    ok "Projectivy configurado con éxito."
}

# ── Permisos de TV Quick Actions ──────────────────────────────────────────────
configure_tvquickactions_permissions() {
    local pkg="dev.vodik7.tvquickactions.free"
    local svc="${pkg}/dev.vodik7.tvquickactions.KeyAccessibilityService"

    if adb shell pm list packages 2>/dev/null | grep -q "^package:${pkg}$"; then
        info "Configurando permisos específicos para TV Quick Actions..."
        local current_a11y=$(adb shell settings get secure enabled_accessibility_services 2>/dev/null | tr -d '\r')
        
        if [[ "$current_a11y" == "null" || -z "$current_a11y" ]]; then
            adb shell settings put secure enabled_accessibility_services "$svc"
        elif [[ "$current_a11y" != *"$svc"* ]]; then
            adb shell settings put secure enabled_accessibility_services "${current_a11y}:${svc}"
        fi

        adb shell appops set "$pkg" AUTO_START allow 2>/dev/null || true
        adb shell appops set "$pkg" SYSTEM_ALERT_WINDOW allow 2>/dev/null || true
        adb shell dumpsys deviceidle whitelist +"$pkg" &>/dev/null || true
        ok "TV Quick Actions enlazado al sistema."
    fi
}

# ── Tweaks de Optimización Global Android TV ──────────────────────────────────
apply_performance_tweaks() {
    info "Reduciendo escalas de animación (0.5x)..."
    adb shell settings put global animator_duration_scale 0.5
    adb shell settings put global window_animation_scale 0.5
    adb shell settings put global transition_animation_scale 0.5

    info "Forzando renderizado HW SkiaGL..."
    adb shell setprop persist.debug.hwui.renderer skiagl
    adb shell setprop persist.sys.ui.hw 1

    info "Ajustando límites de procesos en background y Doze..."
    adb shell settings put global background_process_limit 4
    adb shell settings put global activity_manager_constants \
        "max_cached_processes=6,background_settle_time=30000,fgservice_min_shown_time=2000,fgservice_timeout=20000"

    info "Inhabilitando Play Protect (ADB installs)..."
    adb shell settings put global package_verifier_enable 0
    adb shell settings put global verifier_verify_adb_installs 0

    info "Silenciando capturas de telemetría y buffers de logs..."
    adb shell settings put global captive_portal_detection_enabled 0
    adb shell setprop persist.logd.size 64K
    adb shell setprop persist.sys.strictmode.disable 1
    
    adb shell settings put global send_action_app_error 0
    adb shell settings put global dropbox:data_app_crash 0 2>/dev/null || true
    adb shell settings put global dropbox:data_app_anr 0 2>/dev/null || true
    adb shell settings put global device_config_sync_disabled_for_tests persistent

    info "Aplicando parches de rendimiento para SoC MediaTek/Amlogic..."
    adb shell setprop persist.debug.hwui.profile false
    adb shell settings put global enable_dump_heap_traces 0 2>/dev/null || true
    adb shell setprop persist.sys.dumpheap false 2>/dev/null || true
    ok "Ajustes de entorno del sistema completados."
}