#!/bin/bash
set -euo pipefail

# 
BASE_CAPTURE_DIR="/home/mina/Desktop/automatization_scripts/honeypot_internship/archives"
INTERFACE="enp2s0"
HOST_IP="140.105.50.55" 

# Port number => archive folder
# Fill this section in order to add new instances of servers
declare -A INSTANCES=(
    [8080]="$BASE_CAPTURE_DIR/login/phpmyadmin/replay_logs"
    [8081]="$BASE_CAPTURE_DIR/wordpress/vulnerable/replay_logs"
    [8082]="$BASE_CAPTURE_DIR/login/grafana/replay_logs"
    #[port number on which the replay is listening]="folder where to store the archived logs"
)

DATE=$(date +%F)
YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%d)

for PORT in "${!INSTANCES[@]}"; do
    CAPTURE_DIR="${INSTANCES[$PORT]}"
    ARCHIVE_DIR="$CAPTURE_DIR/$YEAR/$MONTH/$DAY"
    mkdir -p "$ARCHIVE_DIR"

    CURRENT_CAPTURE="$CAPTURE_DIR/current_capture.pcap"

    # Stop current capture
    if pgrep -f "tcpdump.*$CURRENT_CAPTURE" > /dev/null; then
        pkill -f "tcpdump.*$CURRENT_CAPTURE"
    fi

    # Archive
    if [ -f "$CURRENT_CAPTURE" ]; then
        mv "$CURRENT_CAPTURE" "$ARCHIVE_DIR/tcpdump_${PORT}_$DATE.pcap"
        gzip "$ARCHIVE_DIR/capture_${PORT}_$DATE.pcap"
    fi

    # Run a new capture 
    nohup sudo tcpdump -i "$INTERFACE" "host $HOST_IP and port $PORT" -w "$CURRENT_CAPTURE" > /dev/null 2>&1 &
done
