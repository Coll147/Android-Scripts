#!/bin/bash
# ==============================================================================
#  Mi TV - Android 9
# ==============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_SCRIPT="${SCRIPT_DIR}/resources/core.sh"

if [[ -f "$CORE_SCRIPT" ]]; then
    source "$CORE_SCRIPT"
else
    echo -e "\033[0;31m[ERR]\033[0m Falta el archivo modular core.sh"
    exit 1
fi

# ==============================================================================
#  PRE-CHECKS Y ENTORNO DE APKS
# ==============================================================================
section "PRE-CHECKS & SETUP"
run_pre_checks

APK_DIR="${SCRIPT_DIR}/apks"
APK_PROJ="${APK_DIR}/proyectivity.apk"

[[ ! -d "$APK_DIR" ]] && mkdir -p "$APK_DIR"
download_projectivy "$APK_PROJ"

# ==============================================================================
#   ELIMINACIÓN DE PAQUETES
# ==============================================================================

section "1/6 · SPYWARE Y TELEMETRÍA XIAOMI / GOOGLE"
remove_pkg "com.miui.tv.analytics"                 "Xiaomi Analytics — Telemetría agresiva de uso"
remove_pkg "com.xiaomi.statistic"                  "Xiaomi Statistics — Reportes en background"
remove_pkg "com.google.android.feedback"              "Google Feedback — Envío de errores"
remove_pkg "com.google.android.tv.bugreportsender"   "Google Bug Reporter — Logs en segundo plano"

section "2/6 · BLOATWARE RESIDENCIAL DE XIAOMI TV"
remove_pkg "android.autoinstalls.config.xiaomi.amelie" "Auto-instalador de Apps Basura para placa Amelie"
remove_pkg "com.xm.webcontent"                             "WebContent Xiaomi — Contenido web y banners de anuncios"
remove_pkg "com.xiaomo.tv.milegal"                         "Contrato Legal de Xiaomi TV"
remove_pkg "com.mitv.tvlock"                               "Bloqueo de interfaz / Modo hotel Xiaomi"
remove_pkg "com.mitv.tvhome.mitvplus"                      "Xiaomi Mi TV+ — Streaming FAST irrelevante (consume mucha RAM)"
remove_pkg "com.mitv.tvhome.michannel"                      "Mi Channel — Canales PatchWall redundantes en Home"
remove_pkg "com.xiaomi.mitv.updateservice"                  "Servicio OTA Xiaomi (Evita que parches futuros rompan cambios)"
remove_pkg "com.xiaomi.mitv.tvmanager"                      "Mi TV Manager — Limpiador chino inútil (genera overlays molestos)"
remove_pkg "com.mitv.dream"                                "Xiaomi wallpapers creo"
remove_pkg "com.mitv.tvhome.atv"                           "Xiaomi patchwall"

section "3/6 · MULTIMEDIA Y GALERÍA STOCK REEMPLAZABLES"
remove_pkg "com.xiaomi.mitv.mediaexplorer"                  "MediaExplorer — Gestor de archivos stock tosco"
remove_pkg "com.xiaomi.mimusic2"                           "Mi Music — Reproductor nativo pesado"
remove_pkg "com.mitv.videoplayer"                          "Mi Video Player — Reproductor básico de Xiaomi"
remove_pkg "com.mitv.gallery"                              "Galería de fotos nativa de Mi TV"

section "4/6 · RECOMENDACIONES Y PROVEEDORES ASISTENTES"
remove_pkg "com.google.android.tvrecommendations"          "Google TV Recommendations — Algoritmos devoradores de CPU"
remove_pkg "com.google.android.leanbacklauncher.recommendations" "Módulo antiguo de sugerencias Leanback"
#remove_pkg "com.google.android.katniss"                     "Google Assistant / Búsqueda por voz nativa (Opcional)"
remove_pkg "com.google.android.speech.pumpkin"              "Motor offline de conversión voz a texto"
remove_pkg "com.google.android.marvin.talkback"            "TalkBack — Accesibilidad guiada por voz"
remove_pkg "com.google.android.tts"                        "Text-To-Speech Google"

section "5/6 · PROCESOS EN NUBE Y COMPROBACIONES DE TEST"
remove_pkg "com.google.android.backuptransport"            "Google Backup Cloud"
remove_pkg "com.google.android.syncadapters.calendar"      "Sincronizador de Calendarios de Google"
remove_pkg "com.google.android.syncadapters.contacts"      "Sincronizador de Contactos de Google"
remove_pkg "com.android.providers.calendar"                "Almacén local del calendario"
remove_pkg "com.google.android.sss.authbridge"             "Google OAuth Bridge obsoleto"
remove_pkg "com.android.cts.priv.ctsshim"                  "CTS Test Privado Shim"
remove_pkg "com.android.cts.ctsshim"                       "CTS Test Public Shim"
remove_pkg "com.google.android.tv.frameworkpackagestubs" "Stubs vacíos de compatibilidad Android"

section "6/6 · APLICACIONES DE TERCEROS REEMPLAZABLES / SCRAP"
remove_pkg "com.google.android.videos"                     "Google Play Películas"
remove_pkg "com.google.android.play.games"                 "Google Play Games para TV"
remove_pkg "com.google.android.youtube.tv"                 "YouTube Oficial (Instalar SmartTube desde apks/)"
remove_pkg "com.google.android.youtube.tvmusic"            "YouTube Music Oficial"
remove_pkg "com.amazon.amazonvideo.livingroom"             "Amazon Prime Video"
#remove_pkg "com.netflix.ninja"                             "Netflix Nativo" If you dont use netflix delete it, but i think it meeses up the netflix hd thing, just in case
remove_pkg "com.android.printspooler"                      "Servicio de Impresión"
remove_pkg "com.android.htmlviewer"                        "Visor HTML"
remove_pkg "com.android.vpndialogs"                        "Diálogos de red VPN"
remove_pkg "com.android.backupconfirm"                     "UI Confirmar Backups"
remove_pkg "com.android.sharedstoragebackup"               "Backup Almacenamiento Compartido"
remove_pkg "com.android.wallpaperbackup"                   "Backup de Fondos de Pantalla"
remove_pkg "com.android.providers.userdictionary"          "Diccionario del teclado de usuario"

section "7/7 · COMPONENTES CRÍTICOS, MEDIATEK Y CORE ANDROID (eliminar bajo tu propio riesgo)"
#remove_pkg "mitv.service"                                 "Servicio Core esencial de Xiaomi TV"
#remove_pkg "com.xiaomi.android.tvsetup.partnercustomizer" "Configurador inicial de socios Xiaomi"
#remove_pkg "com.xiaomi.floatingframe"                     "Módulo de renderizado de frames en pantalla"
#remove_pkg "com.xiaomi.mitv.res"                          "Recursos gráficos base del sistema Xiaomi"
#remove_pkg "com.google.android.ext.services"              "Servicios de extensiones de Android"
#remove_pkg "com.google.android.ext.shared"                "Librerías compartidas críticas de Google"
#remove_pkg "com.google.android.apps.mediashell"           "Google Chromecast Built-in (Rompe el Cast si se borra)"
#remove_pkg "com.android.tv.settings"                      "Ajustes nativos de Android TV"
#remove_pkg "com.android.providers.media"                  "Indexador de archivos multimedia/almacenamiento"
#remove_pkg "com.google.android.onetimeinitializer"        "Inicializador de configuración de Google"
#remove_pkg "com.android.externalstorage"                  "Gestor de Almacenamiento Externo (USB/MicroSD)"
#remove_pkg "com.android.companiondevicemanager"           "Administrador de dispositivos vinculados"
#remove_pkg "com.android.providers.downloads"              "Gestor de descargas nativo del sistema"
#remove_pkg "com.android.providers.tv"                     "Base de datos de canales de TV/Live Channels"º
#remove_pkg "com.google.android.backdrop"                  "Salvapantallas oficial de Google (Ambient Mode)"
#remove_pkg "com.android.defcontainer"                     "Contenedor para instalación de paquetes"
#remove_pkg "com.android.vending"                          "Google Play Store"
#remove_pkg "com.android.pacprocessor"                     "Procesador de configuración Proxy automática"
#remove_pkg "com.android.certinstaller"                    "Instalador de Certificados de Seguridad"
#remove_pkg "com.android.statementservice"                 "Servicio de verificación de enlaces de apps"
#remove_pkg "com.android.settings.intelligence"            "Buscador inteligente en los Ajustes"
#remove_pkg "com.android.providers.settings"               "Almacén de configuraciones globales de Android"
#remove_pkg "com.android.se"                               "Secure Element - Soporte de seguridad por hardware"
#remove_pkg "com.android.inputdevices"                     "Drivers para mandos, teclados y periféricos"
#remove_pkg "com.google.android.tvlauncher"                "Launcher por defecto de Android TV" -> Quitarlo puede dar problemas con las entradas HDMI en projectivity
#remove_pkg "com.google.android.leanbacklauncher"          "Launcher clásico / Interfaz Leanback"
#remove_pkg "com.google.android.webview"                   "Motor Webview para renderizar contenido web en apps"
#remove_pkg "com.android.keychain"                         "Llavero de contraseñas y credenciales de Android"
#remove_pkg "com.google.android.boot.appsplashscreen"      "Pantallas de carga al arrancar el sistema"
#remove_pkg "com.google.android.packageinstaller"          "Instalador de aplicaciones nativo (.apks)"
#remove_pkg "com.google.android.gms"                       "Google Play Services (Servicio vital)"
#remove_pkg "com.google.android.gsf"                       "Google Services Framework (Estructura de Google)"
#remove_pkg "com.google.android.partnersetup"              "Configuración inicial de socios de Google"
#remove_pkg "com.google.android.tv.remote.service"         "Servicio de control remoto por móvil (Google Home/Android TV Remote)"
#remove_pkg "com.android.proxyhandler"                     "Gestor de proxies de red"
#remove_pkg "com.android.location.fused"                   "Servicio de localización integrada del sistema"
#remove_pkg "com.android.systemui"                         "Interfaz del sistema (Barras de volumen, menús de apagado)"
#remove_pkg "com.android.shell"                            "Línea de comandos de Android (Mantiene activo ADB)"
#remove_pkg "com.android.bluetooth"                        "Controlador y servicio de Bluetooth (Mando a distancia)"
#remove_pkg "com.android.providers.contacts"               "Base de datos del almacenamiento de contactos"
#remove_pkg "com.android.captiveportallogin"               "Login automático en redes Wi-Fi públicas de hoteles"
#remove_pkg "com.google.android.inputmethod.latin"         "Teclado Gboard en pantalla (Si lo borras no puedes escribir)"
#remove_pkg "com.google.android.tungsten.setupwraith"      "Asistente de configuración inicial de Android TV"
#remove_pkg "android"                                      "Núcleo del Sistema Operativo Android"

# --- PAQUETES PROPIOS DE LA PLACA MEDIATEK / MSTAR ---
#remove_pkg "com.mediatek.twoworlds.test.fapi"             "API de test de la arquitectura interna MediaTek"
#remove_pkg "com.mediatek.tvinput"                         "Módulo de entradas físicas de TV (HDMI, AV) de MediaTek"
#remove_pkg "com.mediatek.wwtv.setupwizard"                "Asistente de canales y sintonización de MediaTek"
#remove_pkg "com.mediatek.androidbox"                      "Librerías de MediaTek para optimización de decodificadores"
#remove_pkg "mediatek.factorymenu.ui"                      "Menú de fábrica oculto para ingenieros en MediaTek"
#remove_pkg "com.mediatek.tv.factory"                      "Ajustes de calibración de fábrica de hardware de vídeo"
#remove_pkg "com.mediatek.hotkey.dispatcher"               "Asignador de botones rápidos del mando físico"
#remove_pkg "com.mstar.netflixobserver"                    "Servicio de MStar para monitorizar compatibilidad Netflix HD"
#remove_pkg "com.mediatek.wwtv.tvcenter"                   "Centro de control de TV digital de MediaTek"
#remove_pkg "com.mediatek.tvinputservice.arbitratorservice" "Árbitro de señales y fuentes de entrada de vídeo"
#remove_pkg "com.mediatek.network"                         "Controlador de hardware de red e inyección de datos de MediaTek"
#remove_pkg "com.mediatek.tv.agent"                        "Agente de comunicación de hardware con Android"


# ==============================================================================
#  INSTALACIÓN, PERMISOS Y TWEAKS VIA CORE
# ==============================================================================
section "INSTALACIÓN DE CARPETA apks/"
install_apks_from_folder "$APK_DIR"

section "ASIGNACIÓN DE PERMISOS MODERNOS"
configure_projectivy_permissions
configure_tvquickactions_permissions

section "LAUNCHER PRINCIPAL INTERCEPTOR"
info "Enlazando Projectivy como interceptor predeterminado de la tecla Home..."
adb shell cmd package set-home-activity "com.spocky.projengmenu/.ui.home.MainActivity"
ok "Listo. El Launcher nativo no molestará pero seguirá dando servicio a los HDMIs."

section "APLICACIÓN TWEAKS RENDIMIENTO GLOBAL"
apply_performance_tweaks


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

echo -e "\n${BOLD}${CYAN}════ CONSEJO MANUAL ADICIONAL PARA ENTRADAS HDMI ════${NC}\n"
echo -e "  1. En Projectivy Launcher, ve a: ${BOLD}Ajustes de Projectivy → Tarjetas / Secciones${NC}."
echo -e "  2. Habilita la sección de ${GREEN}\"Entradas\" o \"Inputs\"${NC}."
echo -e "  3. Desde ahí podrás cambiar a HDMI1, HDMI2 o TDT de forma nativa e instantánea."
echo -e "     Gracias a que mantuvimos el Launcher original de fondo, la pantalla no se quedará en negro."

info "Reiniciando Smart TV en 3 segundos..."
sleep 3
adb reboot
ok "Proceso finalizado. Dispositivo optimizado."