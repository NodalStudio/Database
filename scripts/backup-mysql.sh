#!/bin/bash

# MySQL Backup Script using mysqldump
# Creates local backups of MySQL databases

# To schedule this script to run daily at 12:00 AM:
# echo "0 0 * * * /srv/services/database/scripts/backup-mysql.sh >> /srv/services/database/logs/backup.log 2>&1" | crontab -

set -e  # Exit on any error

# Configuration
MYSQL_HOST="localhost"
MYSQL_PORT="8001"
MYSQL_USER="root"
MYSQL_PASSWORD="shared_root_secure_2024"
BACKUP_DIR="/srv/services/database/backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to backup alumbra database
backup_database() {
    echo "Starting backup of alumbra database..."
    
    BACKUP_FILE="$BACKUP_DIR/$DATE.sql"
    
    mysqldump \
        --host="$MYSQL_HOST" \
        --port="$MYSQL_PORT" \
        --user="$MYSQL_USER" \
        --password="$MYSQL_PASSWORD" \
        --databases alumbra \
        --routines \
        --triggers \
        --single-transaction \
        --flush-logs \
        > "$BACKUP_FILE"
    
    # Compress the backup
    gzip "$BACKUP_FILE"

    # Upload to S3
    aws s3 cp "$BACKUP_FILE.gz" "s3://nodalstudio-backup/database-backups/$DATE.gz"
    
    echo "Backup completed: ${BACKUP_FILE}.gz"
    echo "Backup size: $(du -h ${BACKUP_FILE}.gz | cut -f1)"
}

# Function to clean old backups (keep last 7 days)
cleanup_old_backups() {
    echo "Cleaning up backups older than 7 days..."
    find "$BACKUP_DIR" -name "*.sql.gz" -mtime +7 -delete
    echo "Cleanup completed"
}

backup_database
cleanup_old_backups

echo "Backup script completed successfully"