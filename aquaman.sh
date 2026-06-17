#!/bin/bash
# ==============================================================================
#  Mi TV Stick — Android TV 9
# ==============================================================================

set -uo pipefail

# Obtener la ruta del script para enlazar el core e interactuar con directorios
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_SCRIPT="${SCRIPT_DIR}/core.sh"

# Importar el script core de funciones modulares
if [[ -f "$CORE_SCRIPT" ]]; then
    source "$CORE_SCRIPT"
else
    echo -e "\033[0;31m[ERR]\033[0m No se encuentra el archivo modular de dependencias: core.sh"
    exit 1
fi

# ==============================================================================
#  PRE-CHECKS & SETUP DE DIRECTORIOS
# ==============================================================================
section "PRE-CHECKS"
run_pre_checks

APK_DIR="${SCRIPT_DIR}/apks"
APK_PROJ="${APK_DIR}/proyectivity.apk"

if [[ ! -d "$APK_DIR" ]]; then
    info "Creando la carpeta '${APK_DIR}'..."
    mkdir -p "$APK_DIR"
fi

download_projectivy "$APK_PROJ"

# ==============================================================================
#  ELIMINACIÓN DE PAQUETES (BLOATWARE)
# ==============================================================================

section "1/8 · SPYWARE Y TELEMETRÍA"
remove_pkg "tv.alphonso.alphonso_eula"               "Alphonso — tracking de audiencia por micro (SPYWARE)"
remove_pkg "com.miui.tv.analytics"                   "Xiaomi analytics — telemetría de uso"
remove_pkg "com.google.android.feedback"             "Google feedback — envío de errores a Google"
remove_pkg "com.google.android.tv.bugreportsender"   "TV bug reporter — envío de logs a Google"
remove_pkg "com.xiaomi.mitv.updateservice"           "Xiaomi OTA updater — actualizaciones Xiaomi"

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

section "3/8 · LAUNCHER Y HOME GOOGLE TV"
remove_pkg "com.google.android.tvlauncher"        "Google TV Launcher (reemplazado por Projectivy)"
remove_pkg "com.google.android.tv"                "Android TV Home (base del launcher Google)"
remove_pkg "com.google.android.tvrecommendations" "Motor de recomendaciones TV (consume RAM y CPU)"
remove_pkg "com.google.android.backdrop"          "Screensaver Backdrop de Google"
remove_pkg "com.android.dreams.basic"             "Daydreams básico (screensaver Android)"

section "4/8 · GOOGLE ASSISTANT Y VOZ"
remove_pkg "com.google.android.katniss"        "Google Search app para Android TV / Assistant"
remove_pkg "com.google.android.speech.pumpkin" "Motor de reconocimiento de voz offline"
remove_pkg "com.google.android.marvin.talkback" "TalkBack (accesibilidad por voz para invidentes)"
remove_pkg "com.google.android.tts"            "Google Text-to-Speech (síntesis de voz)"

section "5/8 · SETUP INICIAL Y WIZARDS"
remove_pkg "com.google.android.onetimeinitializer" "Google one-time init (primer arranque)"
remove_pkg "com.android.onetimeinitializer"        "Android one-time init (primer arranque)"
remove_pkg "com.google.android.partnersetup"       "Google partner setup (configuración OEM)"
remove_pkg "com.google.android.tungsten.setupwraith" "Asistente de configuración Android TV"
remove_pkg "com.android.settings.intelligence"     "Inteligencia de ajustes (sugerencias de settings)"

section "6/8 · BACKUP, SYNC Y NUBE"
remove_pkg "com.google.android.backuptransport"       "Google Backup Transport"
remove_pkg "com.google.android.syncadapters.contacts" "Sync de contactos con Google"
remove_pkg "com.google.android.syncadapters.calendar" "Sync de calendario con Google"
remove_pkg "com.android.backupconfirm"                "UI confirmación de backup"
remove_pkg "com.android.wallpaperbackup"              "Backup de fondos de pantalla"
remove_pkg "com.android.sharedstoragebackup"          "Backup de almacenamiento compartido"

section "7/8 · CHROMECAST RECEIVER"
#remove_pkg "com.google.android.apps.mediashell" "Receptor Chromecast (Cast receiver)"

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
#  INSTALACIÓN DE LA CARPETA 'APKS'
# ==============================================================================
section "INSTALANDO APKs DE LA CARPETA 'apks'"
install_apks_from_folder "$APK_DIR"

# ==============================================================================
#  CONFIGURACIÓN DE PERMISOS PROJECTIVITY / TVQUICKACTIONS
# ==============================================================================
section "PERMISOS — PROJECTIVY LAUNCHER"
PROJ_PKG="com.spocky.projengmenu"
PROJ_SVC="${PROJ_PKG}/com.spocky.projengmenu.services.ProjectivyAccessibilityService"
PROJ_NLS="${PROJ_PKG}/com.spocky.projengmenu.services.notification.NotificationListener"

info "Permisos de almacenamiento y sistema..."
adb shell pm grant "$PROJ_PKG" android.permission.WRITE_EXTERNAL_STORAGE    2>/dev/null && ok "WRITE_EXTERNAL_STORAGE"     || warn "WRITE_EXTERNAL_STORAGE — saltado"
adb shell pm grant "$PROJ_PKG" android.permission.READ_EXTERNAL_STORAGE     2>/dev/null && ok "READ_EXTERNAL_STORAGE"      || warn "READ_EXTERNAL_STORAGE — saltado"
adb shell pm grant "$PROJ_PKG" android.permission.READ_PHONE_STATE          2>/dev/null && ok "READ_PHONE_STATE"           || warn "READ_PHONE_STATE — saltado"
adb shell pm grant "$PROJ_PKG" android.permission.READ_TV_LISTINGS          2>/dev/null && ok "READ_TV_LISTINGS"           || warn "READ_TV_LISTINGS — saltado"
adb shell pm grant "$PROJ_PKG" android.permission.PACKAGE_USAGE_STATS       2>/dev/null && ok "PACKAGE_USAGE_STATS"        || warn "PACKAGE_USAGE_STATS — saltado"

info "Configurando listener de notificaciones..."
adb shell settings put secure enabled_notification_listeners "$PROJ_NLS"
ok "Notification listener configurado"

info "Configurando servicio de accesibilidad..."
adb shell settings put secure accessibility_enabled 1
adb shell settings put secure enabled_accessibility_services "$PROJ_SVC"
ok "Accesibilidad activada para Projectivy"

info "Configurando appops para Projectivy..."
adb shell appops set "$PROJ_PKG" AUTO_START allow              && ok "AUTO_START: allow"          || warn "AUTO_START — comando no soportado"
adb shell appops set "$PROJ_PKG" SYSTEM_ALERT_WINDOW allow    && ok "SYSTEM_ALERT_WINDOW: allow" || warn "SYSTEM_ALERT_WINDOW — saltado"
adb shell appops set "$PROJ_PKG" READ_PHONE_STATE allow        2>/dev/null || true

info "Añadiendo Projectivy a whitelist de Doze..."
adb shell dumpsys deviceidle whitelist +"$PROJ_PKG" && ok "Añadido a whitelist Doze" || warn "No se pudo añadir a Doze whitelist"


section "PERMISOS — TV QUICK ACTIONS"

TVQA_PKG="dev.vodik7.tvquickactions.free"
TVQA_SVC="${TVQA_PKG}/dev.vodik7.tvquickactions.KeyAccessibilityService"

if adb shell pm list packages 2>/dev/null | grep -q "^package:${TVQA_PKG}$"; then
    section "PERMISOS — TV QUICK ACTIONS"

    info "Añadiendo TV Quick Actions al servicio de accesibilidad..."
    CURRENT_A11Y=$(adb shell settings get secure enabled_accessibility_services 2>/dev/null | tr -d '\r')
    if [[ "$CURRENT_A11Y" == "null" || -z "$CURRENT_A11Y" ]]; then
        adb shell settings put secure enabled_accessibility_services "$TVQA_SVC"
    else
        if [[ "$CURRENT_A11Y" != *"$TVQA_SVC"* ]]; then
            adb shell settings put secure enabled_accessibility_services "${CURRENT_A11Y}:${TVQA_SVC}"
        fi
    fi
    ok "TV Quick Actions añadido a enabled_accessibility_services"

    info "Configurando appops para TV Quick Actions..."
    adb shell appops set "$TVQA_PKG" AUTO_START allow           && ok "AUTO_START: allow"          || warn "AUTO_START — comando no soportado"
    adb shell appops set "$TVQA_PKG" SYSTEM_ALERT_WINDOW allow  && ok "SYSTEM_ALERT_WINDOW: allow" || warn "SYSTEM_ALERT_WINDOW — saltado"

    info "Añadiendo TV Quick Actions a whitelist de Doze..."
    adb shell dumpsys deviceidle whitelist +"$TVQA_PKG" && ok "Añadido a whitelist Doze" || warn "No se pudo añadir"
fi

# ── Establecer Home Principal ────────────────────────────────────────────────
section "LAUNCHER POR DEFECTO"
info "Estableciendo Projectivy como home activity..."
adb shell cmd package set-home-activity "${PROJ_PKG}/.ui.home.MainActivity"
ok "Projectivy configurado como launcher principal"

# ==============================================================================
#  OPTIMIZACIONES DE ENTORNOS Y RENDIMIENTO (SYS TWEAKS)
# ==============================================================================
section "OPTIMIZACIONES DE RENDIMIENTO"

info "Ajustando escalas de animación a 0.5x..."
adb shell settings put global animator_duration_scale 0.5
adb shell settings put global window_animation_scale 0.5
adb shell settings put global transition_animation_scale 0.5

info "Forzando renderizado por HW (SkiaGL)..."
adb shell setprop persist.debug.hwui.renderer skiagl
adb shell setprop persist.sys.ui.hw 1

info "Ajustando límites en ActivityManager y Doze..."
adb shell settings put global background_process_limit 4
adb shell settings put global activity_manager_constants \
    "max_cached_processes=6,background_settle_time=30000,fgservice_min_shown_time=2000,fgservice_timeout=20000"

info "Desactivando Play Protect y verificadores remotos..."
adb shell settings put global package_verifier_enable 0
adb shell settings put global verifier_verify_adb_installs 0

info "Desactivando captura y chequeo de portal cautivo..."
adb shell settings put global captive_portal_detection_enabled 0
adb shell settings put global captive_portal_server ""

info "Reduciendo I/O de logs a 64K..."
adb shell setprop persist.logd.size 64K
adb shell setprop persist.logd.filter ""

info "Inhabilitando telemetría de fallos y StrictMode..."
adb shell setprop persist.sys.strictmode.visual 0
adb shell setprop persist.sys.strictmode.disable 1
adb shell settings put global send_action_app_error 0
adb shell settings put global dropbox:data_app_crash 0 2>/dev/null || true
adb shell settings put global dropbox:data_app_anr 0 2>/dev/null || true

info "Estabilizando servicios esenciales (Bluetooth, Sync, Config)..."
adb shell settings put global bluetooth_disabled_profiles 0
adb shell settings put global auto_sync_for_nonsecure_accounts_enabled 0 2>/dev/null || true
adb shell settings put global device_config_sync_disabled_for_tests persistent
adb shell settings put global network_scorer_app ""
adb shell settings put global network_recommendations_enabled 0 2>/dev/null || true
adb shell settings put global gpu_debug_layers "" 2>/dev/null || true
adb shell setprop persist.debug.hwui.profile false

info "Aplicando optimizaciones específicas del SoC Amlogic..."
adb shell settings put global enable_dump_heap_traces 0 2>/dev/null || true
adb shell setprop persist.sys.dumpheap false 2>/dev/null || true
ok "Fase de optimizaciones de rendimiento completada"

# ==============================================================================
#  RESUMEN FINAL
# ==============================================================================
section "RESUMEN"

echo -e "  ${GREEN}✓ Desinstalados:        ${BOLD}${REMOVED}${NC}"
echo -e "  ${YELLOW}⚠ Deshabilitados:       ${BOLD}${DISABLED}${NC}"
echo -e "  ${BLUE}↷ Saltados:             ${BOLD}${SKIPPED}${NC}  (no instalados de origen)"
echo -e "  ${RED}✗ Fallidos bloat:       ${BOLD}${FAILED}${NC}"
echo -e "  ${GREEN}✓ APKs Instaladas:      ${BOLD}${INSTALLED_APKS}${NC}"
[[ $FAILED_APKS -gt 0 ]] && echo -e "  ${RED}✗ APKs Fallidas:        ${BOLD}${FAILED_APKS}${NC}"

echo -e "\n${BOLD}${CYAN}════ PASOS MANUALES RECOMENDADOS EN EL TV ════${NC}\n"
echo -e "  Ir a Ajustes → Opciones de desarrollador:"
echo -e "  1. ${BOLD}Tamaño buffer de registros${NC}   →  ${GREEN}1 MB${NC}"
echo -e "  2. ${BOLD}Procesos en segundo plano${NC}    →  ${GREEN}Máx. 1 proceso${NC}"
echo -e "  3. ${BOLD}Renderer HWUI${NC}                →  ${GREEN}skiagl${NC}"
echo -e "  4. Presiona el botón ${BOLD}Home${NC} y confirma Projectivy si es necesario.\n"

info "Reiniciando TV Stick en 3 segundos..."
sleep 3
adb reboot
ok "Completado. Reiniciando con entorno limpio."