#!/bin/bash

# Add Website to Shared Database
# Usage: ./add-website.sh <website_name> [password]

if [ $# -lt 1 ]; then
    echo "Usage: $0 <website_name> [password]"
    echo "Example: $0 mywebsite"
    echo "Example: $0 mywebsite custom_password"
    exit 1
fi

WEBSITE_NAME=$1
DB_NAME="${WEBSITE_NAME}_db"
DB_USER="${WEBSITE_NAME}_user"
DB_PASS=${2:-"${WEBSITE_NAME}_password"}

echo "🔧 Adding new website to shared database"
echo "   Website: $WEBSITE_NAME"
echo "   Database: $DB_NAME"
echo "   User: $DB_USER"
echo

# Check if shared MySQL is running
if ! docker ps | grep -q "mysql"; then
    echo "❌ MySQL is not running. Please start it first:"
    echo "   cd /srv/services/database && docker-compose up -d"
    exit 1
fi

# Create database and user
echo "📝 Creating database and user..."
docker exec mysql mysql -u root -pshared_root_secure_2024 << EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
SELECT 'Database created successfully' AS status;
EOF

if [ $? -eq 0 ]; then
    echo "✅ Website database created successfully!"
    echo
    echo "📋 Database Configuration:"
    echo "   Host: mysql"
    echo "   Port: 3306"
    echo "   Database: $DB_NAME"
    echo "   Username: $DB_USER"
    echo "   Password: $DB_PASS"
    echo
    echo "🔗 Use this in your docker-compose.yml:"
    echo "   DATABASE_HOST=shared-mysql"
    echo "   DATABASE_NAME=$DB_NAME"
    echo "   DATABASE_USERNAME=$DB_USER"
    echo "   DATABASE_PASSWORD=$DB_PASS"
else
    echo "❌ Failed to create database. Check the error above."
    exit 1
fi