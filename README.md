# 🛡️ Sentinel — Monitoring & Alert System for Linux

Sentinel is a lightweight Bash tool designed to monitor the status of a Linux system, detect anomalies, and generate automatic alerts to prevent critical issues.

🚀 What it Monitors

CPU, RAM, and Disk Usage

Failed login attempts (security monitoring)

Alerts sent via console, log file, and email

📁 Project Structure

monitor.sh      # Main script

config.conf     # Thresholds and alert configuration

logs/sentinel.log # Log file with detected events

⚙️ How to Use

Clone the repository:

git clone https://github.com/Matiaslb14/05-Sentinel.git

cd 05-Sentinel

Run the monitor:

bash monitor.sh
