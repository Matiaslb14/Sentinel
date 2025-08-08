#!/bin/bash

CONFIG_FILE="config.conf"
LOG_FILE="logs/sentinel.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Cargar configuración
source "$CONFIG_FILE"

# Crear log si no existe
mkdir -p logs
touch "$LOG_FILE"

log() {
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

check_cpu() {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
    cpu_usage=${cpu_usage%.*}
    if [ "$cpu_usage" -gt "$CPU_THRESHOLD" ]; then
        log "⚠️  CPU alta: $cpu_usage% (umbral: $CPU_THRESHOLD%)"
        send_alert "ALERTA: CPU alta" "Uso de CPU: $cpu_usage%"
    fi
}

check_ram() {
    ram_usage=$(free | awk '/Mem/ {printf("%.0f"), $3/$2 * 100}')
    if [ "$ram_usage" -gt "$RAM_THRESHOLD" ]; then
        log "⚠️  RAM alta: $ram_usage% (umbral: $RAM_THRESHOLD%)"
        send_alert "ALERTA: RAM alta" "Uso de RAM: $ram_usage%"
    fi
}

check_disk() {
    disk_usage=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
    if [ "$disk_usage" -gt "$DISK_THRESHOLD" ]; then
        log "⚠️  Disco lleno: $disk_usage% (umbral: $DISK_THRESHOLD%)"
        send_alert "ALERTA: Disco casi lleno" "Uso de disco: $disk_usage%"
    fi
}

send_alert() {
    subject="$1"
    message="$2"
    if [ "$ENABLE_EMAIL_ALERTS" = true ]; then
        echo "$message" | mail -s "$subject" "$EMAIL_TO"
    fi
}

# ========== EJECUCIÓN ==========
log "Iniciando monitoreo..."

check_cpu
check_ram
check_disk

log "Monitoreo finalizado."
