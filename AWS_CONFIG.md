# Configuraciones de Ejemplo para AWS

## 1. Security Group - Base de Datos (database-sg)

### Inbound Rules
| Type | Protocol | Port | Source | Description |
|------|----------|------|--------|-------------|
| SSH | TCP | 22 | Tu-IP/32 | SSH access |
| PostgreSQL | TCP | 5432 | 0.0.0.0/0 | Allow PostgreSQL from anywhere |

**Nota**: En producción, limitar PostgreSQL solo a las IPs de los backends.

### Outbound Rules
Permitir todas las salidas (default)

---

## 2. Security Group - Backend CON Validación (backend-validacion-sg)

### Inbound Rules
| Type | Protocol | Port | Source | Description |
|------|----------|------|--------|-------------|
| SSH | TCP | 22 | Tu-IP/32 | SSH access |
| Custom TCP | TCP | 8080 | 0.0.0.0/0 | Backend API |

### Outbound Rules
Permitir todas las salidas (default)

---

## 3. Security Group - Backend SIN Validación (backend-sin-validacion-sg)

### Inbound Rules
| Type | Protocol | Port | Source | Description |
|------|----------|------|--------|-------------|
| SSH | TCP | 22 | Tu-IP/32 | SSH access |
| Custom TCP | TCP | 8080 | 0.0.0.0/0 | Backend API |

### Outbound Rules
Permitir todas las salidas (default)

---

## 4. Security Group - Frontend (frontend-sg)

### Inbound Rules
| Type | Protocol | Port | Source | Description |
|------|----------|------|--------|-------------|
| SSH | TCP | 22 | Tu-IP/32 | SSH access |
| HTTP | TCP | 80 | 0.0.0.0/0 | Web access |
| HTTPS | TCP | 443 | 0.0.0.0/0 | Secure web access (opcional) |

### Outbound Rules
Permitir todas las salidas (default)

---

## 5. Configuración EC2 - Base de Datos PostgreSQL

```
Name: database-postgresql
AMI: Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
Instance type: t2.micro (1 vCPU, 1 GB RAM)

Key pair: Crear o usar existente
Network settings:
- VPC: Default
- Subnet: Default
- Auto-assign public IP: Enable
- Security group: database-sg

Storage: 8 GB gp2 (default)

User data (opcional para auto-instalación):
```

```bash
#!/bin/bash
apt update
apt upgrade -y
apt install postgresql postgresql-contrib -y

# Configurar PostgreSQL para aceptar conexiones remotas
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/14/main/postgresql.conf
echo "host    all             all             0.0.0.0/0               md5" >> /etc/postgresql/14/main/pg_hba.conf

systemctl restart postgresql

# Crear base de datos y usuario
sudo -u postgres psql << EOF
CREATE DATABASE inventario;
CREATE USER admin WITH PASSWORD 'TuPasswordSeguro123!';
GRANT ALL PRIVILEGES ON DATABASE inventario TO admin;
ALTER USER admin WITH SUPERUSER;
EOF
```

---

## 6. Configuración EC2 - Backend 1 (CON Validación)

```
Name: backend-con-validacion
AMI: Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
Instance type: t2.micro (1 vCPU, 1 GB RAM)

Key pair: Crear o usar existente
Network settings:
- VPC: Default
- Subnet: Default
- Auto-assign public IP: Enable
- Security group: backend-validacion-sg

Storage: 8 GB gp2 (default)

User data (opcional para auto-instalación):
```

```bash
#!/bin/bash
apt update
apt upgrade -y
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/ubuntu/.bashrc
```

**Nota**: Primero crea la instancia de base de datos antes de los backends.

---

## 7. Configuración EC2 - Backend 2 (SIN Validación)

```
Name: backend-sin-validacion
AMI: Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
Instance type: t2.micro (1 vCPU, 1 GB RAM)

Key pair: Usar el mismo que Backend 1
Network settings:
- VPC: Default
- Subnet: Default
- Auto-assign public IP: Enable
- Security group: backend-sin-validacion-sg

Storage: 8 GB gp2 (default)

User data: (mismo que Backend 1)
```

---

## 8. Configuración EC2 - Frontend

```
Name: frontend-inventario
AMI: Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
Instance type: t2.micro (1 vCPU, 1 GB RAM)

Key pair: Usar el mismo
Network settings:
- VPC: Default
- Subnet: Default
- Auto-assign public IP: Enable
- Security group: frontend-sg

Storage: 8 GB gp2 (default)

User data (opcional):
```

```bash
#!/bin/bash
apt update
apt upgrade -y
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs nginx
systemctl enable nginx
systemctl start nginx
```

---

## 9. Archivo .env - Backend CON Validación

Ubicación: `/home/ubuntu/backend-con-validacion/.env`

```env
DB_HOST=XX.XX.XX.XX
DB_PORT=5432
DB_USER=admin
DB_PASSWORD=TuPasswordSeguro123!
DB_NAME=inventario
PORT=8080
```

**Reemplazar `XX.XX.XX.XX` con la IP pública de la instancia de base de datos**

---

## 10. Archivo .env - Backend SIN Validación

Ubicación: `/home/ubuntu/backend-sin-validacion/.env`

```env
DB_HOST=XX.XX.XX.XX
DB_PORT=5432
DB_USER=admin
DB_PASSWORD=TuPasswordSeguro123!
DB_NAME=inventario
PORT=8080
```

**Reemplazar `XX.XX.XX.XX` con la IP pública de la instancia de base de datos**

---

## 11. Archivo .env.production - Frontend

Ubicación: `/home/ubuntu/frontend/.env.production`

```env
REACT_APP_BACKEND_VALIDACION_URL=http://XX.XX.XX.XX:8080
REACT_APP_BACKEND_SIN_VALIDACION_URL=http://YY.YY.YY.YY:8080
```

**Reemplazar**:
- `XX.XX.XX.XX` con la IP pública del Backend 1
- `YY.YY.YY.YY` con la IP pública del Backend 2

---

## 12. Systemd Service - Backend CON Validación

Ubicación: `/etc/systemd/system/backend-validacion.service`

```ini
[Unit]
Description=Backend Con Validacion - Sistema Inventario
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/backend-con-validacion
ExecStart=/home/ubuntu/backend-con-validacion/server
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
EnvironmentFile=/home/ubuntu/backend-con-validacion/.env

[Install]
WantedBy=multi-user.target
```

---

## 13. Systemd Service - Backend SIN Validación

Ubicación: `/etc/systemd/system/backend-sin-validacion.service`

```ini
[Unit]
Description=Backend Sin Validacion - Sistema Inventario
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/backend-sin-validacion
ExecStart=/home/ubuntu/backend-sin-validacion/server
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal
EnvironmentFile=/home/ubuntu/backend-sin-validacion/.env

[Install]
WantedBy=multi-user.target
```

---

## 14. Nginx Configuration - Frontend

Ubicación: `/etc/nginx/sites-available/default`

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm;

    server_name _;

    # Habilitar gzip
    gzip on;
    gzip_vary on;
    gzip_min_length 256;
    gzip_types text/plain text/css text/xml text/javascript 
               application/x-javascript application/xml+rss 
               application/json application/javascript;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache para assets estáticos
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

---

## 15. Comandos Útiles de Systemd

```bash
# Ver status del servicio
sudo systemctl status backend-validacion
sudo systemctl status backend-sin-validacion

# Ver logs en tiempo real
sudo journalctl -u backend-validacion -f
sudo journalctl -u backend-sin-validacion -f

# Reiniciar servicio
sudo systemctl restart backend-validacion
sudo systemctl restart backend-sin-validacion

# Detener servicio
sudo systemctl stop backend-validacion
sudo systemctl stop backend-sin-validacion

# Ver logs de las últimas 100 líneas
sudo journalctl -u backend-validacion -n 100
```

---

## 16. Comandos Útiles de PostgreSQL

```bash
# Conectar a la BD desde cualquier máquina
psql -h <IP_DATABASE> -U admin -d inventario

# Dentro de psql:
\dt                    # Listar tablas
\d operarios          # Describir tabla operarios
\d productos          # Describir tabla productos
\d logs_acceso        # Describir tabla logs_acceso

# Contar registros
SELECT COUNT(*) FROM operarios;
SELECT COUNT(*) FROM productos;
SELECT COUNT(*) FROM logs_acceso;

# Ver últimos logs
SELECT * FROM logs_acceso ORDER BY timestamp DESC LIMIT 10;
```

---

## 17. Costos Estimados AWS (Región us-east-1)

| Recurso | Tipo | Costo Aproximado/mes |
|---------|------|---------------------|
| EC2 Database | t2.micro | $8-10 |
| EC2 Backend 1 | t2.micro | $8-10 |
| EC2 Backend 2 | t2.micro | $8-10 |
| EC2 Frontend | t2.micro | $8-10 |
| Data Transfer | ~1GB/mes | $1-2 |
| **TOTAL** | | **~$33-42/mes** |

**Nota**: Con Free Tier de AWS (primeros 12 meses), las 4 instancias t2.micro pueden ser **GRATUITAS** (750 horas/mes cada una).

---

## 18. Checklist de Verificación

### ✅ Base de Datos
- [ ] EC2 creado y corriendo
- [ ] PostgreSQL instalado
- [ ] Configurado para aceptar conexiones remotas
- [ ] Security group configurado (puerto 5432)
- [ ] IP pública guardada
- [ ] Base de datos `inventario` creada
- [ ] Usuario `admin` creado con permisos
- [ ] Script 01_create_tables.sql ejecutado
- [ ] Script 02_seed_data.sql ejecutado
- [ ] Datos visibles con `SELECT * FROM productos;`

### ✅ Backend 1 (CON Validación)
- [ ] EC2 creado y corriendo
- [ ] Go instalado (`go version`)
- [ ] Código copiado a `/home/ubuntu/backend-con-validacion/`
- [ ] Archivo `.env` configurado
- [ ] `go mod tidy` ejecutado sin errores
- [ ] Compilación exitosa (`go build`)
- [ ] Systemd service creado y habilitado
- [ ] Servicio corriendo (`systemctl status`)
- [ ] Health check responde: `curl localhost:8080/health`

### ✅ Backend 2 (SIN Validación)
- [ ] EC2 creado y corriendo
- [ ] Go instalado
- [ ] Código copiado a `/home/ubuntu/backend-sin-validacion/`
- [ ] Archivo `.env` configurado
- [ ] `go mod tidy` ejecutado sin errores
- [ ] Compilación exitosa
- [ ] Systemd service creado y habilitado
- [ ] Servicio corriendo
- [ ] Health check responde

### ✅ Frontend
- [ ] EC2 creado y corriendo
- [ ] Node.js instalado (`node --version`)
- [ ] Nginx instalado y corriendo
- [ ] Código copiado a `/home/ubuntu/frontend/`
- [ ] Archivo `.env.production` con IPs correctas
- [ ] `npm install` ejecutado
- [ ] `npm run build` ejecutado sin errores
- [ ] Build copiado a `/var/www/html/`
- [ ] Nginx reiniciado
- [ ] Sitio accesible desde navegador

### ✅ Integración
- [ ] Frontend puede llamar a Backend 1
- [ ] Frontend puede llamar a Backend 2
- [ ] Backend 1 rechaza peticiones sin credenciales (401)
- [ ] Backend 2 permite peticiones sin credenciales (200)
- [ ] Logs se registran en la BD
- [ ] Datos visibles con `SELECT * FROM logs_acceso;`

---

## 19. Troubleshooting Común

### Error: "connection refused" desde backend a la base de datos
**Solución**: 
- Verificar Security Group de database-sg permite conexiones en puerto 5432
- Verificar que PostgreSQL esté configurado para escuchar en todas las interfaces (`listen_addresses = '*'`)
- Verificar IP correcta en archivo .env
- Probar conexión: `psql -h <IP_DATABASE> -U admin -d inventario`

### Error: "CORS policy" en el frontend
**Solución**: 
- Los backends ya incluyen CORS habilitado
- Verificar que las URLs en .env.production sean correctas (HTTP, no HTTPS)

### Error: "401 Unauthorized" en Backend 1
**Solución**: 
- Es el comportamiento esperado sin credenciales válidas
- Verificar que operario existe: `SELECT * FROM operarios WHERE id=1;`

### Frontend no carga
**Solución**:
- Verificar nginx: `sudo systemctl status nginx`
- Ver logs: `sudo tail -f /var/log/nginx/error.log`
- Verificar archivos en `/var/www/html/`

---

Estos archivos de configuración te permitirán desplegar el experimento completo en AWS.
