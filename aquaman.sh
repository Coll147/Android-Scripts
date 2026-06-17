#!/bin/bash
# ==============================================================================
#  Mi TV Stick - Android 9
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
#  ELIMINACIÓN DE PAQUETES (BLOATWARE COMPLETO PARA STICK)
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
remove_pkg "com.mitv.tvhome.atv"                           "Launcher Xiaomi ATV (home principal / PatchWall)"
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
#  INSTALACIÓN, PERMISOS Y TWEAKS VIA CORE
# ==============================================================================
section "INSTALANDO APKs DE LA CARPETA 'apks'"
install_apks_from_folder "$APK_DIR"

section "ASIGNACIÓN DE PERMISOS"
configure_projectivy_permissions
configure_tvquickactions_permissions

section "LAUNCHER POR DEFECTO"
info "Estableciendo Projectivy como home activity..."
adb shell cmd package set-home-activity "com.spocky.projengmenu/.ui.home.MainActivity"
ok "Projectivy configurado como launcher principal"

section "APLICACIÓN TWEAKS RENDIMIENTO GLOBAL"
apply_performance_tweaks

# ==============================================================================
#  RESUMEN FINAL
# ==============================================================================
section "RESUMEN"

echo -e "  ${GREEN}✓ Desinstalados:        ${BOLD}${REMOVED}${NC}"
echo -e "  ${YELLOW}⚠ Deshabilitados:       ${BOLD}${DISABLED}${NC}"
echo -e "  ${BLUE}↷ Saltados:             ${BOLD}${SKIPPED}${NC}  (no estaban instalados)"
echo -e "  ${RED}✗ Fallidos bloat:       ${BOLD}${FAILED}${NC}"
echo -e "  ${GREEN}✓ APKs Instaladas:      ${BOLD}${INSTALLED_APKS}${NC}"
[[ $FAILED_APKS -gt 0 ]] && echo -e "  ${RED}✗ APKs Fallidas:        ${BOLD}${FAILED_APKS}${NC}"

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