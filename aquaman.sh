#!/bin/bash
# ==============================================================================
#  Mi TV Stick Optimizer — Android TV 9
#
#  Requisitos:
#    - adb instalado y en el PATH
#    - curl o wget instalados (para descargar el APK de Projectivy)
#    - Dispositivo conectado y autorizado (depuración ADB activada)
# ==============================================================================

set -uo pipefail

# ── Colores ──────────────────────────────────────────────────────────────────
RED='\033;31m';  GREEN='\033;32m'; YELLOW='\033[1;33m'
BLUE='\033;34m'; CYAN='\033;36m';  BOLD='\033[1m'; NC='\033[0m'

# ── Contadores ────────────────────────────────────────────────────────────────
REMOVED=0; DISABLED=0; SKIPPED=0; FAILED=0
INSTALLED_APKS=0; FAILED_APKS=0

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()      { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERR]${NC}   $*"; }
skip()    { echo -e "        ${NC}↷ Saltado: $*"; }
section() { echo -e "\n${BOLD}${CYAN}▓▓▒░  $* ░▒▓▓${NC}\n"; }

# ── Función principal de eliminación ─────────────────────────────────────────
remove_pkg() {
    local pkg="$1"
    local desc="$2"

    # ¿Existe el paquete?
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

# ── Descargar última versión (Beta/Pre-release) de Projectivy ─────────────────
download_projectivy() {
    local target_file="$1"
    local repo="spocky/ProjectivyLauncher"
    
    info "Buscando la última versión de Projectivy Launcher (incluyendo betas)..."
    
    local download_url=""
    
    if command -v curl &>/dev/null; then
        download_url=$(curl -s "https://api.github.com/repos/${repo}/releases" | grep -oP '"browser_download_url":\s*"\K[^"]+\.apk' | head -n 1)
    elif command -v wget &>/dev/null; then
        download_url=$(wget -qO- "https://api.github.com/repos/${repo}/releases" | grep -oP '"browser_download_url":\s*"\K[^"]+\.apk' | head -n 1)
    else
        error "Se requiere curl o wget para descargar Projectivy Launcher automáticamente."
        exit 1
    fi

    if [[ -z "$download_url" ]]; then
        error "No se pudo encontrar ninguna URL de descarga en el repositorio de GitHub."
        exit 1
    fi

    local version_name=$(echo "$download_url" | grep -oP 'download/\K[^/]+')
    info "Última versión detectada: ${BOLD}${version_name}${NC}"
    info "Descargando APK desde: $download_url"

    if command -v curl &>/dev/null; then
        curl -L -o "$target_file" "$download_url"
    else
        wget -O "$target_file" "$download_url"
    fi

    if [[ -f "$target_file" && -s "$target_file" ]]; then
        ok "Projectivy Launcher listo para instalar."
    else
        error "Fallo al descargar el archivo APK de Projectivy."
        exit 1
    fi
}

# ==============================================================================
#  PRE-CHECKS
# ==============================================================================
section "PRE-CHECKS"

if ! command -v adb &>/dev/null; then
    error "adb no está instalado o no está en el PATH. Abortando."
    exit 1
fi

info "Comprobando dispositivo..."
if ! adb get-state &>/dev/null; then
    error "No hay dispositivo conectado o no está autorizado."
    echo ""
    echo "  Pasos para conectar:"
    echo "  1. En el TV: Ajustes → Información → Compilación (7 veces) → Opciones de desarrollador"
    echo "  2. Activar: Depuración por ADB / Depuración por red"
    echo "  3. Ejecutar: adb connect <IP_DEL_TV>:5555"
    exit 1
fi

DEVICE=$(adb shell getprop ro.product.model 2>/dev/null | tr -d '\r')
ANDROID=$(adb shell getprop ro.build.version.release 2>/dev/null | tr -d '\r')
ok "Dispositivo: ${BOLD}${DEVICE}${NC} — Android ${BOLD}${ANDROID}${NC}"

# ── Configuración de Directorios y Descarga ───────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APK_DIR="${SCRIPT_DIR}/apks"
APK_PROJ="${APK_DIR}/proyectivity.apk"

# Asegurar que la carpeta 'apks' existe
if [[ ! -d "$APK_DIR" ]]; then
    info "Creando la carpeta '${APK_DIR}'..."
    mkdir -p "$APK_DIR"
fi

# Descargar Projectivy directamente dentro de la carpeta 'apks'
download_projectivy "$APK_PROJ"

# ==============================================================================
#  ELIMINACIÓN DE PAQUETES
# ==============================================================================

# ── 1. SPYWARE Y TELEMETRÍA ───────────────────────────────────────────────────
section "1/8 · SPYWARE Y TELEMETRÍA"
remove_pkg "tv.alphonso.alphonso_eula"               "Alphonso — tracking de audiencia por micro (SPYWARE)"
remove_pkg "com.miui.tv.analytics"                   "Xiaomi analytics — telemetría de uso"
remove_pkg "com.google.android.feedback"             "Google feedback — envío de errores a Google"
remove_pkg "com.google.android.tv.bugreportsender"   "TV bug reporter — envío de logs a Google"
remove_pkg "com.xiaomi.mitv.updateservice"           "Xiaomi OTA updater — actualizaciones Xiaomi"

# ── 2. BLOATWARE XIAOMI ───────────────────────────────────────────────────────
section "2/8 · BLOATWARE XIAOMI"
remove_pkg "mitv.service"                                  "Servicio principal Xiaomi TV"
remove_pkg "com.xiaomi.android.tvsetup.partnercustomizer"  "Xiaomi partner customizer (personalización OEM)"
remove_pkg "com.xiaomi.mitv.res"                           "Recursos adicionales Xiaomi TV"
remove_pkg "com.xiaomo.tv.milegal"                         "Aviso legal Xiaomi (pop-up inicial)"
remove_pkg "com.mitv.tvhome.atv"                           "Launcher Xiaomi ATV (home principal)"
remove_pkg "com.mitv.tvhome.michannel"                     "Canales Xiaomi en pantalla de inicio"
remove_pkg "com.mitv.milinkservice"                        "MiLink — screen mirroring Xiaomi"
remove_pkg "com.mitv.download.service"                     "Descargador de contenido Xiaomi"
remove_pkg "com.mitv.videoplayer"                          "Reproductor de vídeo Xiaomi"
remove_pkg "com.xm.webcontent"                             "Contenido web Xiaomi (anuncios y noticias)"
remove_pkg "com.mitv.dream"                                "Screensaver Xiaomi"
remove_pkg "android.autoinstalls.config.xioami.mibox3"     "Auto-instalador Xiaomi (typo en nombre)"
remove_pkg "android.autoinstalls.config.xiaomi.mibox3"     "Auto-instalador Xiaomi Mi Box 3"

# ── 3. LAUNCHER Y HOME GOOGLE TV ─────────────────────────────────────────────
section "3/8 · LAUNCHER Y HOME GOOGLE TV"
remove_pkg "com.google.android.tvlauncher"        "Google TV Launcher (reemplazado por Projectivy)"
remove_pkg "com.google.android.tv"                "Android TV Home (base del launcher Google)"
remove_pkg "com.google.android.tvrecommendations" "Motor de recomendaciones TV (consume RAM y CPU)"
remove_pkg "com.google.android.backdrop"          "Screensaver Backdrop de Google"
remove_pkg "com.android.dreams.basic"             "Daydreams básico (screensaver Android)"

# ── 4. GOOGLE ASSISTANT Y VOZ ────────────────────────────────────────────────
section "4/8 · GOOGLE ASSISTANT Y VOZ"
remove_pkg "com.google.android.katniss"        "Google Search app para Android TV / Assistant"
remove_pkg "com.google.android.speech.pumpkin" "Motor de reconocimiento de voz offline"
remove_pkg "com.google.android.marvin.talkback" "TalkBack (accesibilidad por voz para invidentes)"
remove_pkg "com.google.android.tts"            "Google Text-to-Speech (síntesis de voz)"

# ── 5. SETUP INICIAL Y WIZARDS ────────────────────────────────────────────────
section "5/8 · SETUP INICIAL Y WIZARDS"
remove_pkg "com.google.android.onetimeinitializer" "Google one-time init (primer arranque)"
remove_pkg "com.android.onetimeinitializer"        "Android one-time init (primer arranque)"
remove_pkg "com.google.android.partnersetup"       "Google partner setup (configuración OEM)"
remove_pkg "com.google.android.tungsten.setupwraith" "Asistente de configuración Android TV"
remove_pkg "com.android.settings.intelligence"     "Inteligencia de ajustes (sugerencias de settings)"

# ── 6. BACKUP, SYNC Y NUBE ────────────────────────────────────────────────────
section "6/8 · BACKUP, SYNC Y NUBE"
remove_pkg "com.google.android.backuptransport"       "Google Backup Transport"
remove_pkg "com.google.android.syncadapters.contacts" "Sync de contactos con Google"
remove_pkg "com.google.android.syncadapters.calendar" "Sync de calendario con Google"
remove_pkg "com.android.backupconfirm"                "UI confirmación de backup"
remove_pkg "com.android.wallpaperbackup"              "Backup de fondos de pantalla"
remove_pkg "com.android.sharedstoragebackup"          "Backup de almacenamiento compartido"

# ── 7. CHROMECAST RECEIVER ────────────────────────────────────────────────────
section "7/8 · CHROMECAST RECEIVER"
#remove_pkg "com.google.android.apps.mediashell" "Receptor Chromecast (Cast receiver)"

# ── 8. APPS PREINSTALADAS Y MISCELÁNEA ───────────────────────────────────────
section "8/8 · APPS PREINSTALADAS Y MISCELÁNEA"
remove_pkg "com.google.android.videos"              "Play Movies & TV"
remove_pkg "com.google.android.play.games"          "Google Play Games"
remove_pkg "com.google.android.youtube.tv"          "YouTube para TV"
remove_pkg "com.google.android.youtube.tvmusic"     "YouTube Music para TV"
remove_pkg "com.amazon.amazonvideo.livingroom"      "Amazon Prime Video"
remove_pkg "com.netflix.ninja"                      "Netflix"
remove_pkg "com.android.printspooler"               "Cola de impresión (inútil en TV)"
remove_pkg "com.android.htmlviewer"                 "Visor HTML básico"
remove_pkg "com.android.providers.calendar"         "Proveedor de calendario"
remove_pkg "com.android.providers.userdictionary"   "Diccionario de usuario"
remove_pkg "com.android.cts.priv.ctsshim"           "CTS shim privado (solo para testing)"
remove_pkg "com.android.cts.ctsshim"                "CTS shim (solo para testing)"
remove_pkg "com.google.android.sss.authbridge"      "Auth bridge Google (bridge OAuth obsoleto)"
remove_pkg "com.google.android.tv.frameworkpackagestubs" "Framework stubs de compatibilidad"
remove_pkg "com.android.vpndialogs"                 "Diálogos VPN (rara vez necesario en TV)"

# ==============================================================================
#  INSTALACIÓN AUTOMÁTICA DE LA CARPETA 'APKS'
# ==============================================================================
section "INSTALANDO APKs DE LA CARPETA 'apks'"

# Comprobar si hay archivos .apk en el directorio
shopt -s nullglob
apk_files=("$APK_DIR"/*.apk)
shopt -u nullglob

if [[ ${#apk_files[@]} -eq 0 ]]; then
    warn "No se encontraron archivos APK adicionales en la carpeta '${APK_DIR}'."
else
    for apk in "${apk_files[@]}"; do
        filename=$(basename "$apk")
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

# ==============================================================================
#  PERMISOS — PROJECTIVY LAUNCHER
# ==============================================================================
section "PERMISOS — PROJECTIVY LAUNCHER"

PROJ_PKG="com.spocky.projengmenu"
PROJ_SVC="${PROJ_PKG}/com.spocky.projengmenu.services.ProjectivyAccessibilityService"
PROJ_NLS="${PROJ_PKG}/com.spocky.projengmenu.services.notification.NotificationListener"

info "Permisos de almacenamiento y sistema..."
adb shell pm grant "$PROJ_PKG" android.permission.WRITE_EXTERNAL_STORAGE    2>/dev/null && ok "WRITE_EXTERNAL_STORAGE"     || warn "WRITE_EXTERNAL_STORAGE — puede no ser necesario"
adb shell pm grant "$PROJ_PKG" android.permission.READ_EXTERNAL_STORAGE     2>/dev/null && ok "READ_EXTERNAL_STORAGE"      || warn "READ_EXTERNAL_STORAGE — puede no ser necesario"
adb shell pm grant "$PROJ_PKG" android.permission.READ_PHONE_STATE          2>/dev/null && ok "READ_PHONE_STATE"           || warn "READ_PHONE_STATE — puede no ser necesario"
adb shell pm grant "$PROJ_PKG" android.permission.READ_TV_LISTINGS          2>/dev/null && ok "READ_TV_LISTINGS"           || warn "READ_TV_LISTINGS — puede no ser necesario"
adb shell pm grant "$PROJ_PKG" android.permission.PACKAGE_USAGE_STATS       2>/dev/null && ok "PACKAGE_USAGE_STATS"        || warn "PACKAGE_USAGE_STATS — puede no ser necesario"

info "Configurando listener de notificaciones..."
adb shell settings put secure enabled_notification_listeners "$PROJ_NLS"
ok "Notification listener configurado"

info "Configurando servicio de accesibilidad..."
adb shell settings put secure accessibility_enabled 1
adb shell settings put secure enabled_accessibility_services "$PROJ_SVC"
ok "Accesibilidad activada para Projectivy"

info "Configurando appops (AUTO_START, overlay, appops de lectura)..."
adb shell appops set "$PROJ_PKG" AUTO_START allow              && ok "AUTO_START: allow"          || warn "AUTO_START — comando no soportado"
adb shell appops set "$PROJ_PKG" SYSTEM_ALERT_WINDOW allow    && ok "SYSTEM_ALERT_WINDOW: allow" || warn "SYSTEM_ALERT_WINDOW — puede no ser necesario"
adb shell appops set "$PROJ_PKG" READ_PHONE_STATE allow        2>/dev/null || true

info "Añadiendo Projectivy a whitelist de Doze..."
adb shell dumpsys deviceidle whitelist +"$PROJ_PKG" && ok "Añadido a whitelist Doze" || warn "No se pudo añadir a Doze whitelist"

# ==============================================================================
#  PERMISOS — TV QUICK ACTIONS (Solo si se detecta su instalación)
# ==============================================================================
TVQA_PKG="dev.vodik7.tvquickactions.free"
TVQA_SVC="${TVQA_PKG}/dev.vodik7.tvquickactions.KeyAccessibilityService"

if adb shell pm list packages 2>/dev/null | grep -q "^package:${TVQA_PKG}$"; then
    section "PERMISOS — TV QUICK ACTIONS"

    info "Añadiendo TV Quick Actions al servicio de accesibilidad..."
    CURRENT_A11Y=$(adb shell settings get secure enabled_accessibility_services 2>/dev/null | tr -d '\r')
    if [[ "$CURRENT_A11Y" == "null" || -z "$CURRENT_A11Y" ]]; then
        adb shell settings put secure enabled_accessibility_services "$TVQA_SVC"
    else
        # Evitar duplicar si ya estaba en la cadena de accesibilidad
        if [[ "$CURRENT_A11Y" != *"$TVQA_SVC"* ]]; then
            adb shell settings put secure enabled_accessibility_services "${CURRENT_A11Y}:${TVQA_SVC}"
        fi
    fi
    ok "TV Quick Actions añadido a enabled_accessibility_services"

    info "Configurando appops para TV Quick Actions..."
    adb shell appops set "$TVQA_PKG" AUTO_START allow           && ok "AUTO_START: allow"          || warn "AUTO_START — comando no soportado"
    adb shell appops set "$TVQA_PKG" SYSTEM_ALERT_WINDOW allow  && ok "SYSTEM_ALERT_WINDOW: allow" || warn "SYSTEM_ALERT_WINDOW — puede no ser necesario"

    info "Añadiendo TV Quick Actions a whitelist de Doze..."
    adb shell dumpsys deviceidle whitelist +"$TVQA_PKG" && ok "Añadido a whitelist Doze" || warn "No se pudo añadir"
fi

# ==============================================================================
#  ESTABLECER PROJECTIVY COMO LAUNCHER POR DEFECTO
# ==============================================================================
section "LAUNCHER POR DEFECTO"

info "Estableciendo Projectivy como home activity..."
adb shell cmd package set-home-activity "${PROJ_PKG}/.ui.home.MainActivity"
ok "Projectivy configurado como launcher principal"

# ==============================================================================
#  OPTIMIZACIONES DE RENDIMIENTO
# ==============================================================================
section "OPTIMIZACIONES DE RENDIMIENTO"

info "Reduciendo escalas de animación a 0.5x..."
adb shell settings put global animator_duration_scale 0.5
adb shell settings put global window_animation_scale 0.5
adb shell settings put global transition_animation_scale 0.5
ok "Animaciones al 50%"

info "Forzando renderizado por GPU (SkiaGL)..."
adb shell setprop persist.debug.hwui.renderer skiagl
adb shell setprop persist.sys.ui.hw 1
ok "GPU renderer: skiagl"

info "Limitando procesos en segundo plano..."
adb shell settings put global background_process_limit 4
adb shell settings put global activity_manager_constants \
    "max_cached_processes=6,background_settle_time=30000,fgservice_min_shown_time=2000,fgservice_timeout=20000"
ok "Límite de procesos ajustados"

info "Desactivando verificación automática de paquetes (Play Protect)..."
adb shell settings put global package_verifier_enable 0
adb shell settings put global verifier_verify_adb_installs 0
ok "Play Protect: OFF"

info "Desactivando detección de portal cautivo..."
adb shell settings put global captive_portal_detection_enabled 0
adb shell settings put global captive_portal_server ""
ok "Captive portal detection: OFF"

info "Reduciendo tamaño de buffer de logs..."
adb shell setprop persist.logd.size 64K
adb shell setprop persist.logd.filter ""
ok "Log buffer: 64K"

info "Desactivando StrictMode de desarrollo..."
adb shell setprop persist.sys.strictmode.visual 0
adb shell setprop persist.sys.strictmode.disable 1
ok "StrictMode: OFF"

info "Desactivando sincronización automática global..."
adb shell settings put global auto_sync_for_nonsecure_accounts_enabled 0 2>/dev/null || true
ok "Auto-sync global: OFF"

info "Desactivando envío de estadísticas de uso y errores..."
adb shell settings put global send_action_app_error 0
adb shell settings put global dropbox:data_app_crash 0 2>/dev/null || true
adb shell settings put global dropbox:data_app_anr 0 2>/dev/null || true
ok "App error reporting: OFF"

info "Asegurando que el servicio Bluetooth está activo..."
adb shell settings put global bluetooth_disabled_profiles 0
ok "Bluetooth: habilitado"

info "Desactivando sincronización de device_config..."
adb shell settings put global device_config_sync_disabled_for_tests persistent
ok "device_config sync: bloqueado"

info "Desactivando comprobaciones de conectividad en background..."
adb shell settings put global network_scorer_app ""
adb shell settings put global network_recommendations_enabled 0 2>/dev/null || true
ok "Network scoring: OFF"

info "Desactivando capas de debug GL/GPU..."
adb shell settings put global gpu_debug_layers "" 2>/dev/null || true
adb shell setprop persist.debug.hwui.profile false
ok "GPU debug layers: OFF"

info "Aplicando tweaks para SoC Amlogic S905Y2..."
adb shell settings put global enable_dump_heap_traces 0 2>/dev/null || true
adb shell setprop persist.sys.dumpheap false 2>/dev/null || true
ok "Tweaks Amlogic: aplicados"

# ==============================================================================
#  RESUMEN FINAL
# ==============================================================================
section "RESUMEN"

echo -e "  ${GREEN}✓ Desinstalados:        ${BOLD}${REMOVED}${NC}"
echo -e "  ${YELLOW}⚠ Deshabilitados:       ${BOLD}${DISABLED}${NC}"
echo -e "  ${BLUE}↷ Saltados:             ${BOLD}${SKIPPED}${NC}  (no estaban instalados)"
echo -e "  ${RED}✗ Fallidos bloat:       ${BOLD}${FAILED}${NC}"
echo -e "  ${GREEN}✓ APKs Instaladas:      ${BOLD}${INSTALLED_APKS}${NC}"
if [[ $FAILED_APKS -gt 0 ]]; then
echo -e "  ${RED}✗ APKs Fallidas:        ${BOLD}${FAILED_APKS}${NC}"
fi

echo ""
echo -e "${BOLD}${CYAN}════ PASOS MANUALES RECOMENDADOS (en el TV) ════${NC}"
echo ""
echo -e "  Ir a: ${BOLD}Ajustes → Opciones de desarrollador${NC}"
echo ""
echo -e "  1. ${BOLD}Tamaño buffer de registros${NC}   →  ${GREEN}1 MB${NC}"
echo ""
echo -e "  2. ${BOLD}Procesos en segundo plano${NC}    →  ${GREEN}Máx. 1 proceso${NC}"
echo ""
echo -e "  3. ${BOLD}Renderer HWUI${NC}                →  ${GREEN}skiagl${NC}"
echo ""
echo -e "  4. ${BOLD}Activar Projectivy${NC}: confirma el launcher por defecto si lo pide al pulsar Home"
echo ""

info "Reiniciando dispositivo en 3 segundos..."
sleep 3
adb reboot

echo -e "\n${GREEN}${BOLD}¡Listo! El TV Stick se está reiniciando con la configuración optimizada.${NC}\n"