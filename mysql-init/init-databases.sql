-- Shared Database Initialization
-- This script creates databases and users for all websites

-- Create Alumbra database and user
CREATE DATABASE IF NOT EXISTS alumbra_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'alumbra_user'@'%' IDENTIFIED BY 'alumbra_password';
GRANT ALL PRIVILEGES ON alumbra_db.* TO 'alumbra_user'@'%';

-- Create ICTUS database and user
CREATE DATABASE IF NOT EXISTS ictus_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'ictus_user'@'%' IDENTIFIED BY 'ictus_password';
GRANT ALL PRIVILEGES ON ictus_db.* TO 'ictus_user'@'%';

-- Create a read-only monitoring user (optional)
CREATE USER IF NOT EXISTS 'db_monitor'@'%' IDENTIFIED BY 'monitor_readonly_2024';
GRANT SELECT ON *.* TO 'db_monitor'@'%';

-- Flush privileges to apply changes
FLUSH PRIVILEGES;

-- Log successful initialization
SELECT 'Shared database initialization completed successfully' AS status;