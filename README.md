cat > README.md << 'EOF'
# 🛡️ Sentinel - Sistema de Monitoreo y Alertas para Linux

**Sentinel** es una herramienta ligera en Bash que permite monitorear el estado de un sistema Linux, detectar anomalías y generar alertas automáticas para prevenir problemas críticos.

## 🚀 ¿Qué monitorea?

- Uso de CPU, RAM y Disco
- Intentos de acceso fallidos al sistema (seguridad)
- Envío de alertas por consola, log y correo electrónico

## 📁 Estructura

monitor.sh # Script principal
config.conf # Configuración de umbrales y alertas
logs/sentinel.log # Log de eventos detectados

## ⚙️ Cómo usar

1. Clonar el repositorio:

```bash
git clone https://github.com/Matiaslb14/05-Sentinel.git
cd 05-Sentinel

bash monitor.sh


