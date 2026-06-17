#!/bin/bash
# ==============================================================================
#  Core functions for this potato scripts
# ==============================================================================

set -uo pipefail

# ── Colores y Formato ────────────────────────────────────────────────────────
RED='\033;31m';  GREEN='\033;32m'; YELLOW='\033[1;33m'
BLUE='\033;34m'; CYAN='\033;36m';  BOLD='\033[1m'; NC='\033[0m'

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

# ── Descarga de la última Beta de Projectivy Launcher ─────────────────────────
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
    info "Descargando APK en la carpeta de instalación..."

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