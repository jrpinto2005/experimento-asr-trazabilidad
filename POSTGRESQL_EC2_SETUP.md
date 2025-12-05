# 🗄️ Guía Rápida: PostgreSQL en EC2

Esta guía te ayuda a configurar PostgreSQL en una instancia EC2 para el experimento.

---

## ⚡ Configuración Rápida (5 minutos)

### 1️⃣ Crear Instancia EC2

```
Nombre: database-postgresql
AMI: Ubuntu 22.04 LTS
Tipo: t2.micro
Security Group: 
  - SSH (22) desde tu IP
  - PostgreSQL (5432) desde 0.0.0.0/0
```

### 2️⃣ Conectar e Instalar

```bash
# Conectar
ssh -i "tu-key.pem" ubuntu@<IP_DATABASE>

# Instalar PostgreSQL
sudo apt update && sudo apt install -y postgresql postgresql-contrib

# Verificar
sudo systemctl status postgresql
```

### 3️⃣ Configurar Acceso Remoto

```bash
# Editar postgresql.conf
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" \
  /etc/postgresql/14/main/postgresql.conf

# Editar pg_hba.conf
echo "host    all             all             0.0.0.0/0               md5" | \
  sudo tee -a /etc/postgresql/14/main/pg_hba.conf

# Reiniciar
sudo systemctl restart postgresql
```

### 4️⃣ Crear Base de Datos

```bash
# Entrar como usuario postgres
sudo -u postgres psql

# Ejecutar estos comandos en psql:
CREATE DATABASE inventario;
CREATE USER admin WITH PASSWORD 'TuPasswordSeguro123!';
GRANT ALL PRIVILEGES ON DATABASE inventario TO admin;
ALTER USER admin WITH SUPERUSER;
\q

# Salir
exit
```

### 5️⃣ Copiar y Ejecutar Scripts SQL

```bash
# Desde tu máquina local:
scp -i "tu-key.pem" database/*.sql ubuntu@<IP_DATABASE>:~/

# En el servidor de BD:
ssh -i "tu-key.pem" ubuntu@<IP_DATABASE>
psql -h localhost -U admin -d inventario -f ~/01_create_tables.sql
psql -h localhost -U admin -d inventario -f ~/02_seed_data.sql

# Verificar
psql -h localhost -U admin -d inventario -c "SELECT COUNT(*) FROM productos;"
psql -h localhost -U admin -d inventario -c "SELECT COUNT(*) FROM operarios;"
```

---

## ✅ Verificación

### Desde el servidor de BD:
```bash
# Conectar localmente
psql -h localhost -U admin -d inventario

# Ver tablas
\dt

# Ver datos
SELECT * FROM productos LIMIT 5;
SELECT * FROM operarios;
\q
```

### Desde tu máquina local:
```bash
# Conectar remotamente
psql -h <IP_DATABASE> -U admin -d inventario

# Si funciona, ¡está listo!
```

---

## 🔧 Troubleshooting

### Error: "connection refused"
```bash
# Verificar que PostgreSQL está corriendo
sudo systemctl status postgresql

# Verificar que está escuchando en todas las interfaces
sudo netstat -tulpn | grep 5432

# Debe mostrar: 0.0.0.0:5432
```

### Error: "password authentication failed"
```bash
# Recrear usuario
sudo -u postgres psql
DROP USER IF EXISTS admin;
CREATE USER admin WITH PASSWORD 'TuPasswordSeguro123!';
GRANT ALL PRIVILEGES ON DATABASE inventario TO admin;
ALTER USER admin WITH SUPERUSER;
\q
```

### Error: "could not connect to server"
- Verificar Security Group permite puerto 5432
- Verificar IP correcta
- Ping al servidor: `ping <IP_DATABASE>`

---

## 📝 Comandos Útiles

```bash
# Ver status de PostgreSQL
sudo systemctl status postgresql

# Reiniciar PostgreSQL
sudo systemctl restart postgresql

# Ver logs
sudo tail -f /var/log/postgresql/postgresql-14-main.log

# Conectar como postgres
sudo -u postgres psql

# Listar bases de datos
psql -h localhost -U admin -l

# Backup de la BD
pg_dump -h localhost -U admin inventario > backup.sql

# Restaurar backup
psql -h localhost -U admin inventario < backup.sql
```

---

## 🔐 Credenciales por Defecto

```
Host: <IP_DATABASE>
Port: 5432
Database: inventario
User: admin
Password: TuPasswordSeguro123!
```

**Importante**: Cambia la contraseña en producción!

---

## 📊 Configuración en Backends

En los archivos `.env` de los backends usa:

```env
DB_HOST=<IP_DATABASE>
DB_PORT=5432
DB_USER=admin
DB_PASSWORD=TuPasswordSeguro123!
DB_NAME=inventario
```

---

## 💰 Costos

- EC2 t2.micro: ~$8-10/mes
- Con Free Tier: **GRATIS** (primer año)
- Almacenamiento: 8GB incluidos

**Ventaja vs RDS**: 
- RDS db.t3.micro: $15-20/mes
- EC2 t2.micro: $8-10/mes o GRATIS con Free Tier
- **Ahorro**: $7-20/mes

---

## 🚀 Script de Instalación Automática

Para instalar automáticamente al crear la instancia, usa este User Data:

```bash
#!/bin/bash
apt update
apt upgrade -y
apt install -y postgresql postgresql-contrib

# Configurar acceso remoto
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" \
  /etc/postgresql/14/main/postgresql.conf
echo "host    all             all             0.0.0.0/0               md5" >> \
  /etc/postgresql/14/main/pg_hba.conf

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

¡PostgreSQL en EC2 configurado y listo! 🎉
