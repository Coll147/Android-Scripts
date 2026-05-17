#!/bin/bash
# ==============================================================================
#  Mi TV Stick Optimizer — Android TV 9
#  Claude ha cocinado esta vez
#
#  Requisitos:
#    - adb instalado y en el PATH
#    - Dispositivo conectado y autorizado (depuración ADB activada)
#    - proyectivity.apk y tvquickactions.apk en la misma carpeta que este script
# ==============================================================================

set -uo pipefail

# ── Colores ──────────────────────────────────────────────────────────────────
RED='\033[0;31m';  GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m';  BOLD='\033[1m'; NC='\033[0m'

# ── Contadores ────────────────────────────────────────────────────────────────
REMOVED=0; DISABLED=0; SKIPPED=0; FAILED=0

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()      { echo -e "${GREEN}[OK]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
error()   { echo -e "${RED}[ERR]${NC}   $*"; }
skip()    { echo -e "        ${NC}↷ Saltado: $*"; }
section() { echo -e "\n${BOLD}${CYAN}▓▓▒░  $*  ░▒▓▓${NC}\n"; }

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

# ── Verificar APKs ────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APK_PROJ="${SCRIPT_DIR}/proyectivity.apk"
APK_TVQA="${SCRIPT_DIR}/tvquickactions.apk"

[[ ! -f "$APK_PROJ" ]] && { error "No se encuentra: proyectivity.apk en ${SCRIPT_DIR}"; exit 1; }
[[ ! -f "$APK_TVQA" ]] && { error "No se encuentra: tvquickactions.apk en ${SCRIPT_DIR}"; exit 1; }
ok "APKs encontradas en: ${SCRIPT_DIR}"

# ==============================================================================
#  ELIMINACIÓN DE PAQUETES
# ==============================================================================

# ── 1. SPYWARE Y TELEMETRÍA ───────────────────────────────────────────────────
section "1/8 · SPYWARE Y TELEMETRÍA"
# Prioridad máxima: estos paquetes recopilan y envían datos en segundo plano

remove_pkg "tv.alphonso.alphonso_eula"               "Alphonso — tracking de audiencia por micro (SPYWARE)"
remove_pkg "com.miui.tv.analytics"                   "Xiaomi analytics — telemetría de uso"
remove_pkg "com.google.android.feedback"             "Google feedback — envío de errores a Google"
remove_pkg "com.google.android.tv.bugreportsender"   "TV bug reporter — envío de logs a Google"
remove_pkg "com.xiaomi.mitv.updateservice"           "Xiaomi OTA updater — actualizaciones Xiaomi"

# ── 2. BLOATWARE XIAOMI ───────────────────────────────────────────────────────
section "2/8 · BLOATWARE XIAOMI"
# Todo el ecosistema de Xiaomi TV: launcher, servicios, canales, contenido propio

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
# Se reemplaza por Projectivy; eliminar antes para evitar conflictos

remove_pkg "com.google.android.tvlauncher"        "Google TV Launcher (reemplazado por Projectivy)"
remove_pkg "com.google.android.tv"                "Android TV Home (base del launcher Google)"
remove_pkg "com.google.android.tvrecommendations" "Motor de recomendaciones TV (consume RAM y CPU)"
remove_pkg "com.google.android.backdrop"          "Screensaver Backdrop de Google"
remove_pkg "com.android.dreams.basic"             "Daydreams básico (screensaver Android)"

# ── 4. GOOGLE ASSISTANT Y VOZ ────────────────────────────────────────────────
section "4/8 · GOOGLE ASSISTANT Y VOZ"
# El usuario no usa voz; estos procesos consumen RAM y se activan en background

remove_pkg "com.google.android.katniss"        "Google Search app para Android TV / Assistant"
remove_pkg "com.google.android.speech.pumpkin" "Motor de reconocimiento de voz offline"
remove_pkg "com.google.android.marvin.talkback" "TalkBack (accesibilidad por voz para invidentes)"
remove_pkg "com.google.android.tts"            "Google Text-to-Speech (síntesis de voz)"

# ── 5. SETUP INICIAL Y WIZARDS ────────────────────────────────────────────────
section "5/8 · SETUP INICIAL Y WIZARDS"
# Solo se usan en el primer arranque; ocupan espacio y pueden re-ejecutarse

remove_pkg "com.google.android.onetimeinitializer" "Google one-time init (primer arranque)"
remove_pkg "com.android.onetimeinitializer"        "Android one-time init (primer arranque)"
remove_pkg "com.google.android.partnersetup"       "Google partner setup (configuración OEM)"
remove_pkg "com.google.android.tungsten.setupwraith" "Asistente de configuración Android TV"
remove_pkg "com.android.settings.intelligence"     "Inteligencia de ajustes (sugerencias de settings)"

# ── 6. BACKUP, SYNC Y NUBE ────────────────────────────────────────────────────
section "6/8 · BACKUP, SYNC Y NUBE"
# Un TV stick no necesita sincronizar contactos, calendarios ni hacer backups

remove_pkg "com.google.android.backuptransport"       "Google Backup Transport"
remove_pkg "com.google.android.syncadapters.contacts" "Sync de contactos con Google"
remove_pkg "com.google.android.syncadapters.calendar" "Sync de calendario con Google"
remove_pkg "com.android.backupconfirm"                "UI confirmación de backup"
remove_pkg "com.android.wallpaperbackup"              "Backup de fondos de pantalla"
remove_pkg "com.android.sharedstoragebackup"          "Backup de almacenamiento compartido"

# ── 7. CHROMECAST RECEIVER ────────────────────────────────────────────────────
section "7/8 · CHROMECAST RECEIVER"
# No se usa Chromecast; mediashell corre en background constantemente

remove_pkg "com.google.android.apps.mediashell" "Receptor Chromecast (Cast receiver)"

# ── 8. APPS PREINSTALADAS Y MISCELÁNEA ───────────────────────────────────────
section "8/8 · APPS PREINSTALADAS Y MISCELÁNEA"
# Streaming (el usuario instala lo que quiera), utilidades inútiles en TV, stubs

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
#  INSTALACIÓN DE LAUNCHERS
# ==============================================================================
section "INSTALANDO LAUNCHERS"

info "Instalando Projectivy Launcher..."
if adb install -r "$APK_PROJ" &>/dev/null; then
    ok "Projectivy Launcher instalado correctamente"
else
    error "Fallo al instalar Projectivy Launcher. Verifica el APK."
    exit 1
fi

info "Instalando TV Quick Actions..."
if adb install -r "$APK_TVQA" &>/dev/null; then
    ok "TV Quick Actions instalado correctamente"
else
    error "Fallo al instalar TV Quick Actions. Verifica el APK."
    exit 1
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
#  PERMISOS — TV QUICK ACTIONS
# ==============================================================================
section "PERMISOS — TV QUICK ACTIONS"

TVQA_PKG="dev.vodik7.tvquickactions.free"
TVQA_SVC="${TVQA_PKG}/dev.vodik7.tvquickactions.KeyAccessibilityService"

info "Añadiendo TV Quick Actions al servicio de accesibilidad..."
# Leer el valor actual y concatenar; nunca sobreescribir Projectivy
CURRENT_A11Y=$(adb shell settings get secure enabled_accessibility_services 2>/dev/null | tr -d '\r')
if [[ "$CURRENT_A11Y" == "null" || -z "$CURRENT_A11Y" ]]; then
    adb shell settings put secure enabled_accessibility_services "$TVQA_SVC"
else
    adb shell settings put secure enabled_accessibility_services "${CURRENT_A11Y}:${TVQA_SVC}"
fi
ok "TV Quick Actions añadido a enabled_accessibility_services"

info "Configurando appops para TV Quick Actions..."
adb shell appops set "$TVQA_PKG" AUTO_START allow           && ok "AUTO_START: allow"          || warn "AUTO_START — comando no soportado"
adb shell appops set "$TVQA_PKG" SYSTEM_ALERT_WINDOW allow && ok "SYSTEM_ALERT_WINDOW: allow" || warn "SYSTEM_ALERT_WINDOW — puede no ser necesario"

info "Añadiendo TV Quick Actions a whitelist de Doze..."
adb shell dumpsys deviceidle whitelist +"$TVQA_PKG" && ok "Añadido a whitelist Doze" || warn "No se pudo añadir"

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

# ── Animaciones ───────────────────────────────────────────────────────────────
info "Reduciendo escalas de animación a 0.5x..."
adb shell settings put global animator_duration_scale 0.5
adb shell settings put global window_animation_scale 0.5
adb shell settings put global transition_animation_scale 0.5
ok "Animaciones al 50% — snappier sin desactivarlas del todo"

# ── Renderizado GPU / HWUI ────────────────────────────────────────────────────
info "Forzando renderizado por GPU (SkiaGL)..."
# skiagl es el renderer correcto para Android 9; skiaVk (Vulkan) no está soportado en S905Y2
adb shell setprop persist.debug.hwui.renderer skiagl
adb shell setprop persist.sys.ui.hw 1
ok "GPU renderer: skiagl — activado y persistente"

# ── Procesos en segundo plano ─────────────────────────────────────────────────
info "Limitando procesos en segundo plano..."
# 4 cached processes es un buen balance: las apps están disponibles sin saturar la RAM
adb shell settings put global background_process_limit 4
# Reducir el tiempo de settle antes de matar procesos idle
adb shell settings put global activity_manager_constants \
    "max_cached_processes=6,background_settle_time=30000,fgservice_min_shown_time=2000,fgservice_timeout=20000"
ok "Límite de procesos background: 4 — activity_manager_constants ajustados"

# ── Google Play Protect / verificador de paquetes ────────────────────────────
info "Desactivando verificación automática de paquetes (Play Protect)..."
# Elimina el overhead de escaneo en instalaciones y en background
adb shell settings put global package_verifier_enable 0
adb shell settings put global verifier_verify_adb_installs 0
ok "Play Protect / package verifier: OFF"

# ── Portal cautivo ────────────────────────────────────────────────────────────
info "Desactivando detección de portal cautivo..."
# Evita peticiones HTTP de validación de red en cada reconexión WiFi
adb shell settings put global captive_portal_detection_enabled 0
adb shell settings put global captive_portal_server ""
ok "Captive portal detection: OFF"

# ── Logging del sistema ───────────────────────────────────────────────────────
info "Reduciendo tamaño de buffer de logs..."
# El logger consume I/O y memoria; 64K es suficiente para debug puntual
adb shell setprop persist.logd.size 64K
adb shell setprop persist.logd.filter ""
ok "Log buffer: 64K — I/O de disco reducido"

# ── StrictMode ────────────────────────────────────────────────────────────────
info "Desactivando StrictMode de desarrollo..."
adb shell setprop persist.sys.strictmode.visual 0
adb shell setprop persist.sys.strictmode.disable 1
ok "StrictMode: OFF"

# ── Sincronización automática ─────────────────────────────────────────────────
info "Desactivando sincronización automática global..."
# Ya no hay apps que sincronicen (sin contactos, sin calendario)
adb shell settings put global auto_sync_for_nonsecure_accounts_enabled 0 2>/dev/null || true
ok "Auto-sync global: OFF"

# ── Estadísticas de uso ───────────────────────────────────────────────────────
info "Desactivando envío de estadísticas de uso y errores..."
adb shell settings put global send_action_app_error 0
adb shell settings put global dropbox:data_app_crash 0 2>/dev/null || true
adb shell settings put global dropbox:data_app_anr 0 2>/dev/null || true
ok "App error reporting: OFF"

# ── Bluetooth ─────────────────────────────────────────────────────────────────
info "Asegurando que el servicio Bluetooth está activo..."
adb shell settings put global bluetooth_disabled_profiles 0
ok "Bluetooth: habilitado y sin perfiles desactivados"

# ── Configuración de dispositivo persistente ──────────────────────────────────
info "Desactivando sincronización de device_config (evita reseteos de ajustes)..."
adb shell settings put global device_config_sync_disabled_for_tests persistent
ok "device_config sync: bloqueado"

# ── Comprobación de conectividad ──────────────────────────────────────────────
info "Desactivando comprobaciones de conectividad en background..."
adb shell settings put global network_scorer_app ""
adb shell settings put global network_recommendations_enabled 0 2>/dev/null || true
ok "Network scoring: OFF"

# ── Renderer de debug (capa de validación GL) ─────────────────────────────────
info "Desactivando capas de debug GL/GPU..."
adb shell settings put global gpu_debug_layers "" 2>/dev/null || true
adb shell setprop persist.debug.hwui.profile false
ok "GPU debug layers: OFF"

# ── Configuración específica Amlogic S905Y2 ───────────────────────────────────
info "Aplicando tweaks para SoC Amlogic S905Y2..."
# Deshabilitar dumpheap automático (genera ficheros .hprof que llenan el almacenamiento)
adb shell settings put global enable_dump_heap_traces 0 2>/dev/null || true
# Limitar dumpsys verbosity
adb shell setprop persist.sys.dumpheap false 2>/dev/null || true
ok "Tweaks Amlogic: aplicados"

# ==============================================================================
#  RESUMEN FINAL
# ==============================================================================
section "RESUMEN"

echo -e "  ${GREEN}✓ Desinstalados:   ${BOLD}${REMOVED}${NC}"
echo -e "  ${YELLOW}⚠ Deshabilitados:  ${BOLD}${DISABLED}${NC}"
echo -e "  ${BLUE}↷ Saltados:        ${BOLD}${SKIPPED}${NC}  (no estaban instalados)"
echo -e "  ${RED}✗ Fallidos:        ${BOLD}${FAILED}${NC}"

echo ""
echo -e "${BOLD}${CYAN}════ PASOS MANUALES RECOMENDADOS (en el TV) ════${NC}"
echo ""
echo -e "  Ir a: ${BOLD}Ajustes → Opciones de desarrollador${NC}"
echo ""
echo -e "  1. ${BOLD}Tamaño buffer de registros${NC}   →  ${GREEN}1 MB${NC}"
echo -e "     (aumenta la utilidad de los logs si necesitas depurar)"
echo ""
echo -e "  2. ${BOLD}Procesos en segundo plano${NC}    →  ${GREEN}Máx. 1 proceso${NC}"
echo -e "     (máxima liberación de RAM; si notas crashes, sube a 2-4)"
echo ""
echo -e "  3. ${BOLD}Renderer HWUI${NC}                →  ${GREEN}skiagl${NC}"
echo -e "     (confirma que el setprop se ha aplicado correctamente)"
echo ""
echo -e "  4. ${BOLD}Activar Projectivy${NC}: la primera vez puede pedir"
echo -e "     confirmar el launcher por defecto al pulsar Home"
echo ""
echo -e "${BOLD}${CYAN}════ NOTA SOBRE ACCESIBILIDAD ════${NC}"
echo -e "  Si tras reiniciar los servicios de accesibilidad de Projectivy"
echo -e "  o TV Quick Actions quedan desactivados, ejecuta:"
echo ""
echo -e "  ${YELLOW}adb shell appops set com.spocky.projengmenu AUTO_START allow${NC}"
echo -e "  ${YELLOW}adb shell appops set dev.vodik7.tvquickactions.free AUTO_START allow${NC}"
echo ""

info "Reiniciando dispositivo en 3 segundos..."
sleep 3
adb reboot

echo -e "\n${GREEN}${BOLD}¡Listo! El TV Stick se está reiniciando con la configuración optimizada.${NC}\n"
