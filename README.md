# 🗄️ Shared Database Infrastructure

A centralized MySQL database service designed to support multiple websites with proper isolation and security.

## **Features**

✅ **Multi-tenant**: Separate database and user per website  
✅ **Secure**: Isolated credentials and permissions  
✅ **Scalable**: Easy to add new websites  
✅ **Monitored**: Health checks and monitoring user  
✅ **Persistent**: Data survives container restarts  

## **Architecture**

```
shared-mysql:8001
├── alumbra_db (alumbra_user)
├── website2_db (website2_user)
└── website3_db (website3_user)
```

## **Quick Start**

### **1. Start Shared Database**
```bash
docker-compose up -d
```

### **2. Add a New Website**
```bash
./scripts/add-website.sh mywebsite
```

### **3. Connect from Your Application**
```yaml
# In your website's docker-compose.yml
services:
  your-app:
    environment:
      - DATABASE_HOST=shared-mysql
      - DATABASE_NAME=mywebsite_db
      - DATABASE_USERNAME=mywebsite_user
      - DATABASE_PASSWORD=mywebsite_secure_pass_2024
    networks:
      - shared
```

## **Configuration**

### **Database Settings**
- **Port**: 8001 (external) / 3306 (internal)
- **Root Password**: `shared_root_secure_2024`
- **Character Set**: `utf8mb4_unicode_ci`
- **Network**: `shared`

### **Default Databases**
- `alumbra_db` - Main Alumbra platform database

## **Scripts**

### **Add Website**
```bash
./scripts/add-website.sh <website_name> [password]
```

Creates a new database and user for a website with proper isolation.

## **Monitoring**

### **Health Check**
```bash
docker exec shared-mysql mysqladmin ping -h localhost
```

### **Database List**
```bash
docker exec shared-mysql mysql -u root -pshared_root_secure_2024 -e "SHOW DATABASES;"
```

### **User List**
```bash
docker exec shared-mysql mysql -u root -pshared_root_secure_2024 -e "SELECT User, Host FROM mysql.user;"
```

## **Backup & Restore**

### **Backup All Databases**
```bash
docker exec shared-mysql mysqldump -u root -pshared_root_secure_2024 --all-databases > backup_$(date +%Y%m%d).sql
```

### **Backup Single Website**
```bash
docker exec shared-mysql mysqldump -u root -pshared_root_secure_2024 website_db > website_backup.sql
```

### **Restore Database**
```bash
docker exec -i shared-mysql mysql -u root -pshared_root_secure_2024 website_db < website_backup.sql
```

## **Security**

- 🔒 **Root access**: Only accessible from containers in shared network
- 🔐 **Per-website users**: Cannot access other websites' data
- 🌐 **Network isolation**: Only accessible via Docker networks
- 📊 **Read-only monitoring**: Separate user for monitoring tools

## **Troubleshooting**

### **Connection Issues**
```bash
# Check if container is running
docker ps | grep shared-mysql

# Check logs
docker logs shared-mysql

# Test connection
docker exec shared-mysql mysql -u root -pshared_root_secure_2024 -e "SELECT 1;"
```

### **Performance Issues**
```bash
# Check running queries
docker exec shared-mysql mysql -u root -pshared_root_secure_2024 -e "SHOW PROCESSLIST;"

# Check database sizes
docker exec shared-mysql mysql -u root -pshared_root_secure_2024 -e "
SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables 
GROUP BY table_schema;"
```

## **Migration from Existing Setup**

See the main project's `MIGRATION_PLAN.md` for detailed migration instructions.

---

**Maintained by**: Your Organization  
**Docker Image**: mysql:8.0  
**Network**: shared