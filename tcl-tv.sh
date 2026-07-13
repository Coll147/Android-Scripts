#!/bin/bash
# ==============================================================================
#  TCL TV - Android 11
# ==============================================================================
#
#  NOTA: algunos paquetes propietarios de TCL (esticker, guard, ttvs,
#  dashboard, messagebox, usercenter, suspension) no tienen documentación
#  pública clara sobre su función exacta. Se han clasificado según el
#  comportamiento típico observado en foros de Android TV, pero
#  se recomienda comprobar que el mando y el sistema siguen funcionando
#  con normalidad tras el primer reinicio.
#
#  POLÍTICA GOOGLE (revisión 2): se mantiene intacta la integración con
#  Google Assistant, Google Home y Play Store. Por eso, respecto a la
#  versión anterior del script, estos paquetes YA NO se eliminan:
#    - com.google.android.katniss              (motor de voz/búsqueda de Assistant)
#    - com.google.android.tv.assistant         (servicio de Google Assistant)
#    - com.google.android.tts                  (voz de respuesta de Assistant)
#    - com.google.android.apps.nbu.smartconnect.tv (setup rápido vía Google Home)
#    - com.tcl.micmanager                      (mic físico del mando, usado por Assistant)
# ==============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_SCRIPT="${SCRIPT_DIR}/resources/core.sh"

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
#  ELIMINACIÓN DE PAQUETES (NIVEL AGRESIVO)
# ==============================================================================

section "1/9 · SPYWARE Y TELEMETRÍA"
remove_pkg "com.google.android.feedback"  "Google feedback — envío de errores a Google"
remove_pkg "com.tcl.guard"                "TCL Safety Guard — gestor de permisos/apps/caché propio de TCL, consume CPU en 2º plano [ver nota: concede appops a tvQuickActions, sustituido manualmente]"
remove_pkg "com.tcl.waterfall.overseas"   "TCL Waterfall — recomendaciones de contenido y publicidad (versión internacional)"
remove_pkg "com.tcl.usercenter"           "TCL User Center — cuenta y telemetría de usuario TCL"

section "2/9 · BLOATWARE TCL"
remove_pkg "com.tcl.esticker"          "TCL eSticker — pegatinas/widgets decorativos en la interfaz"
remove_pkg "com.tcl.keyhelp"           "TCL Key Help — capa de ayuda de botones en pantalla (no afecta al mando físico)"
remove_pkg "com.tcl.factory.view"      "TCL Factory View — app de testing de fábrica"
remove_pkg "com.tcl.partnercustomizer" "TCL Partner Customizer — personalización OEM/operador"
remove_pkg "com.tcl.dashboard"         "TCL Dashboard — panel de widgets propietario"
remove_pkg "com.tcl.messagebox"        "TCL MessageBox — notificaciones y mensajes promocionales"
remove_pkg "com.tcl.ttvs"              "TCL TTVS — servicio propietario sin documentar [verifica el mando tras reiniciar]"
remove_pkg "com.tcl.settings"          "TCL Settings — submenú duplicado de ajustes TCL"
remove_pkg "com.tcl.suspension"        "TCL Suspension — gestión propietaria de suspensión/arranque rápido [puede afectar al standby]"
remove_pkg "android.autoinstalls.config.tcl.device" "Auto-instalador TCL — configuración de apps por defecto"

section "3/9 · LAUNCHER Y HOME GOOGLE TV"
remove_pkg "com.google.android.tvlauncher"        "Google TV Launcher (reemplazado por Projectivy)"
remove_pkg "com.google.android.backdrop"          "Screensaver Backdrop de Google"
remove_pkg "com.android.dreams.basic"             "Daydreams básico (screensaver Android)"
remove_pkg "com.google.android.tvrecommendations" "Motor de recomendaciones TV (consume RAM y CPU)"

section "4/9 · VOZ Y ACCESIBILIDAD (NO-GOOGLE)"
# com.google.android.katniss, com.google.android.tv.assistant y
# com.google.android.tts SE MANTIENEN INSTALADOS: son el motor de
# búsqueda/voz, el servicio y la voz de respuesta de Google Assistant.
# com.tcl.micmanager también se mantiene: gestiona el micrófono físico
# del mando, que es lo que activa Assistant al pulsar el botón de voz.
remove_pkg "com.tcl.smartalexa"                 "Integración TCL con Amazon Alexa (no es Google, se elimina sin afectar a Assistant)"
remove_pkg "com.google.android.marvin.talkback" "TalkBack — accesibilidad por voz para invidentes"
remove_pkg "com.tcl.hearaid"                    "TCL HearAid — asistencia auditiva"

section "5/9 · SETUP INICIAL Y WIZARDS"
remove_pkg "com.tcl.initsetup"                            "TCL Initial Setup Wizard"
remove_pkg "com.tcl.useragreement"                        "TCL User Agreement (aviso legal inicial)"
remove_pkg "com.tcl.copydatatotv"                         "TCL Copy Data to TV (transferencia de datos desde móvil)"
remove_pkg "com.tcl.autopair"                             "TCL Autopair — emparejamiento automático del mando [reemparejable a mano vía Ajustes]"
remove_pkg "com.google.android.onetimeinitializer"        "Google one-time init (primer arranque)"
remove_pkg "com.google.android.tungsten.setupwraith"      "Asistente de configuración Android TV"
remove_pkg "com.google.android.partnersetup"              "Google partner setup (configuración OEM)"
# com.google.android.apps.nbu.smartconnect.tv SE MANTIENE: es el servicio
# que usa la app Google Home para el emparejamiento/setup rápido del TV.
remove_pkg "com.android.settings.intelligence"            "Inteligencia de ajustes (sugerencias de settings)"

section "6/9 · BACKUP, SYNC Y NUBE"
remove_pkg "com.android.backupconfirm"                "UI confirmación de backup"
remove_pkg "com.android.wallpaperbackup"              "Backup de fondos de pantalla"
remove_pkg "com.android.sharedstoragebackup"          "Backup de almacenamiento compartido"
remove_pkg "com.google.android.syncadapters.calendar" "Sync de calendario con Google"

section "7/9 · CHROMECAST RECEIVER"
#remove_pkg "com.google.android.apps.mediashell" "Receptor Chromecast (Cast receiver)"

section "8/9 · STREAMING Y APPS PREINSTALADAS"
remove_pkg "com.amazon.amazonvideo.livingroom"  "Amazon Prime Video"
remove_pkg "com.netflix.ninja"                  "Netflix"
remove_pkg "au.com.stan.and"                    "Stan (streaming australiano)"
remove_pkg "tv.wuaki.apptv"                     "Wuaki TV / Rakuten TV"
remove_pkg "com.google.android.videos"          "Google Play Movies & TV"
remove_pkg "com.google.android.youtube.tv"      "YouTube para TV"
remove_pkg "com.google.android.youtube.tvmusic" "YouTube Music para TV"
remove_pkg "com.google.android.play.games"      "Google Play Games"
remove_pkg "com.tcl.videoplayer"                "TCL Video Player (reproductor propietario)"
remove_pkg "com.tcl.audioplayer"                "TCL Audio Player (reproductor propietario)"
remove_pkg "com.tcl.imageplayer"                "TCL Image Player (visor de fotos propietario)"
remove_pkg "com.tcl.ui_mediaCenter"             "TCL Media Center (centro multimedia propietario)"

section "9/9 · MISCELÁNEA Y RESTOS DEL SISTEMA"
remove_pkg "com.android.cts.priv.ctsshim"                 "CTS shim privado (solo para testing)"
remove_pkg "com.android.cts.ctsshim"                      "CTS shim (solo para testing)"
remove_pkg "com.android.htmlviewer"                       "Visor HTML básico"
remove_pkg "com.android.providers.calendar"               "Proveedor de calendario"
remove_pkg "com.android.providers.userdictionary"         "Diccionario de usuario"
remove_pkg "com.android.printspooler"                     "Cola de impresión (inútil en TV)"
remove_pkg "com.android.vpndialogs"                       "Diálogos VPN (rara vez necesario en TV)"
remove_pkg "com.google.android.sss.authbridge"            "Auth bridge Google (bridge OAuth obsoleto)"
remove_pkg "com.google.android.tv.frameworkpackagestubs"  "Framework stubs de compatibilidad"

# ==============================================================================
#  PAQUETES NECESARIOS — NO TOCAR (lista de referencia, no ejecuta nada)
# ==============================================================================
#
# Los siguientes paquetes son críticos para el sistema, la conectividad,
# el mando a distancia o las entradas físicas del TV. No se generan
# llamadas a remove_pkg para ellos; se listan solo como documentación.
#
# --- Núcleo del sistema Android ---
#   android                                            → sistema base, nunca tocar
#   com.android.systemui                               → interfaz de sistema (barra, diálogos)
#   com.android.shell                                  → shell del sistema (usado por adb)
#   com.google.android.gms                              → Google Play Services
#   com.google.android.gsf                              → Google Services Framework
#   com.android.vending                                 → Google Play Store
#   com.google.android.packageinstaller                 → instalador de APKs (necesario para meter Projectivy)
#   com.google.android.webview                          → WebView del sistema
#   com.google.android.permissioncontroller              → gestor de permisos
#   com.google.android.overlay.modules.permissioncontroller
#   com.google.android.overlay.modules.permissioncontroller.forframework
#   com.google.android.overlay.modules.ext.services
#   com.google.android.overlay.modules.modulemetadata.forframework
#   com.google.android.ext.services
#   com.google.android.ext.shared
#   com.google.android.modulemetadata
#   com.android.keychain
#   com.android.certinstaller
#   com.android.statementservice
#   com.android.providers.settings
#   com.android.providers.settings.auto_generated_rro_product__
#   com.android.providers.settings.auto_generated_rro_vendor__
#   com.android.providers.media
#   com.android.providers.media.module
#   com.android.providers.downloads
#   com.android.providers.contacts
#   com.android.providers.contacts.auto_generated_rro_product__
#   com.android.providers.tv                            → guía EPG / gestor de canales en directo
#   com.android.externalstorage                         → acceso a USB/almacenamiento externo
#   com.android.companiondevicemanager
#   com.android.localtransport
#   com.android.proxyhandler
#   com.android.pacprocessor
#   com.android.se                                      → Secure Element
#   com.android.inputdevices                            → gestión de entrada (mando, teclado)
#   com.android.location.fused
#   com.android.soundpicker
#   com.android.hotspot2.osulogin
#   com.android.captiveportallogin
#   com.android.dynsystem
#   com.google.android.inputmethod.latin                → teclado del sistema
#
# --- Red y conectividad (no tocar: rompe WiFi/Bluetooth/red) ---
#   com.android.bluetooth
#   com.android.bluetooth.auto_generated_rro_product__
#   com.android.bluetooth.auto_generated_rro_vendor__
#   com.android.networkstack.inprocess
#   com.android.networkstack.tethering.inprocess
#   com.android.networkstack.tethering.inprocess.rro
#   com.android.networkstack.tethering.rro
#   com.android.networkstack.permissionconfig
#   com.android.tethering.overlay
#   com.android.tethering.overlay.gsi
#   com.android.wifi.resources
#   com.android.wifi.resources.rro
#   com.tcl.wifi.resources.overlay
#   android.auto_generated_rro_product__
#   android.auto_generated_rro_vendor__
#
# --- Hardware y firmware específico de TCL (no tocar: rompe mando/entradas) ---
#   com.tcl.system.server         → proceso del sistema TCL
#   com.tcl.tcl_bt_rcu_service    → Bluetooth del mando a distancia (SIN ESTO EL MANDO DEJA DE FUNCIONAR)
#   com.tcl.tvinput               → entradas HDMI / sintonizador
#   com.tcl.providers.config      → configuración compartida entre servicios TCL
#   com.tcl.tv                    → servicio base "paraguas" de TCL TV
#   com.tcl.android.webview       → variante de WebView de TCL [función no confirmada, mejor no tocar]
#   com.android.tv.settings                 → ajustes nativos del TV (necesarios aunque uses Projectivy)
#   com.android.tv.settings.gms.resoverlay  → overlay de ajustes, no tocar
#   com.google.android.tv.remote.service    → gestión del mando (Android TV Remote Service)
#
# --- Integración Google Assistant / Home / Play Store (mantenida a petición) ---
#   com.google.android.katniss                    → motor de búsqueda/voz de Assistant
#   com.google.android.tv.assistant                → servicio de Google Assistant
#   com.google.android.tts                          → voz de respuesta de Assistant
#   com.google.android.apps.nbu.smartconnect.tv     → setup rápido vía app Google Home
#   com.tcl.micmanager                              → mic físico del mando, activa Assistant
#   com.android.vending                             → Play Store (ya listado arriba)
#
# ==============================================================================

# ==============================================================================
#  INSTALACIÓN, PERMISOS Y TWEAKS VIA CORE
# ==============================================================================
section "INSTALANDO APKs DE LA CARPETA 'apks'"
install_apks_from_folder "$APK_DIR"

section "ASIGNACIÓN DE PERMISOS"
configure_projectivy_permissions
configure_tvquickactions_permissions

info "Concediendo auto-inicio en 2º plano a tvQuickActions vía appops (Safety Guard ya no está instalado para hacerlo desde su UI)..."
adb shell appops set dev.vodik7.tvquickactions APP_AUTO_START allow
ok "Permiso APP_AUTO_START concedido a tvQuickActions"

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

echo -e "\n${GREEN}${BOLD}¡Listo! El TV se está reiniciando con la configuración optimizada.${NC}\n"