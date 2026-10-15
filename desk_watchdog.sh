#!/bin/bash
# Watchdog for the desk process.
# Restarts the desk if its log file hasn't been updated in 5 minutes.

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG="$PROJECT_DIR/logs/desk.log"
WATCHDOG_LOG="$PROJECT_DIR/logs/desk_watchdog.log"
STALE_SECONDS=300  # 5 minutes

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" >> "$WATCHDOG_LOG"
}

if [ ! -f "$LOG" ]; then
    log "WARN: desk.log not found, skipping check"
    exit 0
fi

# Get seconds since last modification
if [[ "$OSTYPE" == "darwin"* ]]; then
    LAST_MOD=$(stat -f %m "$LOG")
else
    LAST_MOD=$(stat -c %Y "$LOG")
fi
NOW=$(date +%s)
AGE=$((NOW - LAST_MOD))

if [ "$AGE" -gt "$STALE_SECONDS" ]; then
    log "RESTART: desk.log is ${AGE}s stale (threshold: ${STALE_SECONDS}s), restarting desk"
    launchctl kickstart -k "gui/$(id -u)/com.polymarket.botdesk" >> "$WATCHDOG_LOG" 2>&1
    log "Restart command sent"
else
    log "OK: desk.log updated ${AGE}s ago"
fi
