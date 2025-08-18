#!/bin/bash
set -euo pipefail

# logs_folder => archives_folder
# Fill this section in order to add new instances of servers
declare -A INSTANCES=(
    ["/var/log/nginx/phpmyadmin_headers.log"]="/home/mina/Desktop/automatization_scripts/honeypot_internship/archives/login/phpmyadmin/replay_logs"
    ["/var/log/nginx/wordpress_headers.log"]="/home/mina/Desktop/automatization_scripts/honeypot_internship/archives/wordpress/vulnerable/replay_logs"
    ["/var/log/nginx/grafana_headers.log"]="/home/mina/Desktop/automatization_scripts/honeypot_internship/archives/login/grafana/replay_logs"
    #["folder where the http logs are currently stored (replay_logs/wpr.log for now)"]="folder where to store the archived http logs"
)

DATE=$(date +%F)        
YEAR=$(date +%Y)        
MONTH=$(date +%m) 
DAY=$(date +%d)      

for LOG_DIR in "${!INSTANCES[@]}"; 
do
    ARCHIVE_BASE="${INSTANCES[$LOG_DIR]}"
    ARCHIVE_DIR="$ARCHIVE_BASE/$YEAR/$MONTH/$DAY"
    mkdir -p "$ARCHIVE_DIR"

    for log_file in "$LOG_DIR"/*.log; 
    do
        [ -e "$log_file" ] || continue

        base_name=$(basename "$log_file" .log)

        cp "$log_file" "$ARCHIVE_DIR/${base_name}_${DATE}.log"
        gzip "$ARCHIVE_DIR/${base_name}_${DATE}.log"
        : > "$log_file"
    done
done
