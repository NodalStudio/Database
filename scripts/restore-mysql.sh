#!/bin/bash

# MySQL Restore Script
# Restores the latest backup from S3 and imports it to MySQL

set -e  # Exit on any error

# Configuration
MYSQL_HOST="localhost"
MYSQL_PORT="8001"
MYSQL_USER="root"
MYSQL_PASSWORD="shared_root_secure_2024"
BACKUP_DIR="/srv/services/database/backups"
S3_BUCKET="nodalstudio-backup"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to download latest backup from S3
download_latest_backup() {
    echo "Downloading latest backup from S3..."
    
    # Get the latest backup file from S3
    LATEST_BACKUP=$(aws s3 ls "s3://$S3_BUCKET/database-backups/" --recursive | sort | tail -n 1 | awk '{print $4}')
    
    if [ -z "$LATEST_BACKUP" ]; then
        echo "No backup found in S3"
        exit 1
    fi
    
    echo "Latest backup found: $LATEST_BACKUP"
    
    # Download the latest backup
    aws s3 cp "s3://$S3_BUCKET/$LATEST_BACKUP" "$BACKUP_DIR/"
    
    # Extract filename from path
    BACKUP_FILE="$BACKUP_DIR/$(basename $LATEST_BACKUP)"
    
    echo "Using backup file: $BACKUP_FILE"
}

# Function to restore database
restore_database() {
    echo "Starting database restore..."
    
    # Decompress the backup file
    DECOMPRESSED_FILE="${BACKUP_FILE%.gz}"
    gunzip -c "$BACKUP_FILE" > "$DECOMPRESSED_FILE"
    
    # Stop any existing connections (optional)
    echo "Importing database..."
    
    mysql \
        --host="$MYSQL_HOST" \
        --port="$MYSQL_PORT" \
        --user="$MYSQL_USER" \
        --password="$MYSQL_PASSWORD" \
        < "$DECOMPRESSED_FILE"
    
    # Clean up decompressed file
    rm "$DECOMPRESSED_FILE"
    
    echo "Database restore completed successfully"
    echo "Restored from: $BACKUP_FILE"
}

# Function to verify restore
verify_restore() {
    echo "Verifying database restore..."
    
    # Check if we can connect and show databases
    mysql \
        --host="$MYSQL_HOST" \
        --port="$MYSQL_PORT" \
        --user="$MYSQL_USER" \
        --password="$MYSQL_PASSWORD" \
        -e "SHOW DATABASES;"
    
    echo "Database verification completed"
}

# Main execution
echo "=== MySQL Database Restore ==="
download_latest_backup
restore_database
verify_restore
echo "=== Restore Process Completed ==="