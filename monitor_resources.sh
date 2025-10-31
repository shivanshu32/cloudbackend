#!/bin/bash

# CloudVoter Backend - Resource Monitor Script
# Monitors CPU and Memory usage and restarts the application if thresholds are exceeded
# This ensures the application never misses voting opportunities due to resource exhaustion

# Configuration
APP_NAME="cloudvoter-backend"
CPU_THRESHOLD=90
MEMORY_THRESHOLD=90
CHECK_INTERVAL=30  # Check every 30 seconds
LOG_FILE="./logs/resource-monitor.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to log with timestamp
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to get CPU usage
get_cpu_usage() {
    # Get CPU usage as a percentage (averaged over 1 second)
    top -bn2 -d 1 | grep "Cpu(s)" | tail -1 | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print int(100 - $1)}'
}

# Function to get Memory usage
get_memory_usage() {
    # Get memory usage as a percentage
    free | grep Mem | awk '{print int(($3/$2) * 100)}'
}

# Function to get PM2 process memory
get_pm2_memory() {
    # Get memory usage of the PM2 process in MB
    pm2 jlist | jq -r ".[] | select(.name==\"$APP_NAME\") | .monit.memory" | awk '{print int($1/1024/1024)}'
}

# Function to restart application
restart_app() {
    local reason=$1
    log_message "${RED}⚠️  ALERT: $reason - Restarting application${NC}"
    pm2 restart "$APP_NAME"
    
    if [ $? -eq 0 ]; then
        log_message "${GREEN}✓ Application restarted successfully${NC}"
        # Wait 60 seconds before checking again to allow app to stabilize
        sleep 60
    else
        log_message "${RED}✗ Failed to restart application${NC}"
    fi
}

# Create logs directory if it doesn't exist
mkdir -p ./logs

log_message "${GREEN}========================================${NC}"
log_message "${GREEN}CloudVoter Resource Monitor Started${NC}"
log_message "${GREEN}========================================${NC}"
log_message "CPU Threshold: ${CPU_THRESHOLD}%"
log_message "Memory Threshold: ${MEMORY_THRESHOLD}%"
log_message "Check Interval: ${CHECK_INTERVAL}s"
log_message ""

# Main monitoring loop
while true; do
    # Get current resource usage
    CPU_USAGE=$(get_cpu_usage)
    MEMORY_USAGE=$(get_memory_usage)
    PM2_MEMORY=$(get_pm2_memory)
    
    # Log current status (every 10 checks = 5 minutes)
    if [ $(($(date +%s) % 300)) -lt $CHECK_INTERVAL ]; then
        log_message "${GREEN}Status: CPU=${CPU_USAGE}%, Memory=${MEMORY_USAGE}%, PM2 Memory=${PM2_MEMORY}MB${NC}"
    fi
    
    # Check CPU threshold
    if [ "$CPU_USAGE" -ge "$CPU_THRESHOLD" ]; then
        restart_app "CPU usage is ${CPU_USAGE}% (threshold: ${CPU_THRESHOLD}%)"
        continue
    fi
    
    # Check Memory threshold
    if [ "$MEMORY_USAGE" -ge "$MEMORY_THRESHOLD" ]; then
        restart_app "Memory usage is ${MEMORY_USAGE}% (threshold: ${MEMORY_THRESHOLD}%)"
        continue
    fi
    
    # Check PM2 process memory (restart if over 800MB)
    if [ ! -z "$PM2_MEMORY" ] && [ "$PM2_MEMORY" -ge 800 ]; then
        restart_app "PM2 process memory is ${PM2_MEMORY}MB (threshold: 800MB)"
        continue
    fi
    
    # Wait before next check
    sleep $CHECK_INTERVAL
done
