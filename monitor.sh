#!/bin/bash
set -euo pipefail

CONFIG_FILE="config.conf"
LOG_DIR="logs"
LOG_FILE="$LOG_DIR/sentinel.log"

# ===== Helpers =====
now() { date "+%Y-%m-%d %H:%M:%S"; }

log() {
  printf "[%s] %s\n" "$(now)" "$1" | tee -a "$LOG_FILE"
}

send_alert() {
  local subject="$1"
  local message="$2"

  # Siempre loguea la alerta
  log "ALERTA → $subject | $message"

  # Si hay correo habilitado y mail instalado, envía
  if [[ "${ENABLE_EMAIL_ALERTS:-false}" == "true" ]] && command -v mail >/dev/null 2>&1; then
    echo "$message" | mail -s "$subject" "$EMAIL_TO" || log "⚠ No se pudo enviar correo (mail falló)."
  fi
}

# ===== Preparación =====
if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck source=/dev/null
  source "$CONFIG_FILE"
else
  echo "No existe $CONFIG_FILE. Crea uno con los umbrales. Ejemplo:"
  cat <<'EOF'
CPU_THRESHOLD=80
RAM_THRESHOLD=80
DISK_THRESHOLD=90

ENABLE_EMAIL_ALERTS=false
EMAIL_TO=tu@correo.com
EOF
  exit 1
fi

mkdir -p "$LOG_DIR"
touch "$LOG_FILE"

# ===== Checks =====
check_cpu() {
  local idle cpu_usage
  idle=$(LC_ALL=C top -bn1 | awk -F',' '/Cpu\(s\)/{for(i=1;i<=NF;i++) if ($i ~ /id/) {gsub(/[^0-9.]/,"",$i); print $i; exit}}')
  cpu_usage=$(awk -v i="${idle:-0}" 'BEGIN{printf("%.0f", 100 - i)}')
  if (( cpu_usage > CPU_THRESHOLD )); then
    send_alert "CPU alta" "Uso de CPU: ${cpu_usage}% (umbral: ${CPU_THRESHOLD}%)"
  else
    log "CPU ok: ${cpu_usage}%"
  fi
}

check_ram() {
  local ram_usage
  ram_usage=$(free | awk '/Mem:/ {printf("%.0f", $3/$2*100)}')
  if (( ram_usage > RAM_THRESHOLD )); then
    send_alert "RAM alta" "Uso de RAM: ${ram_usage}% (umbral: ${RAM_THRESHOLD}%)"
  else
    log "RAM ok: ${ram_usage}%"
  fi
}

check_disk() {
  local disk_usage
  disk_usage=$(df -P / | awk 'END{gsub(/%/,"",$5); print $5}')
  if (( disk_usage > DISK_THRESHOLD )); then
    send_alert "Disco casi lleno" "Uso de disco: ${disk_usage}% (umbral: ${DISK_THRESHOLD}%)"
  else
    log "Disco ok: ${disk_usage}%"
  fi
}

# ===== Run =====
log "Iniciando monitoreo…"
check_cpu
check_ram
check_disk
log "Monitoreo finalizado."

