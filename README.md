# Experimento ASR - Sistema de Inventario con Trazabilidad

Este proyecto implementa un experimento para validar el ASR:
> "Yo como gerente de bodega dado que el sistema está operando con normalidad quiero poder saber el 100% de las veces que un operario lee la base de datos el nombre y el id del operario"

## Estructura del Proyecto

```
├── frontend/              # React frontend (compartido)
├── backend-con-validacion/    # Backend GO con validación de credenciales
├── backend-sin-validacion/    # Backend GO sin validación de credenciales
├── database/              # Scripts SQL para PostgreSQL
└── README.md
```

## Arquitectura del Experimento

- **Base de Datos**: PostgreSQL en AWS RDS
- **Frontend**: React en EC2 (compartido para ambos experimentos)
- **Backend 1**: Go en EC2 - Valida credenciales del operario
- **Backend 2**: Go en EC2 - No valida credenciales del operario

---

## PARTE 1: Configuración de la Base de Datos PostgreSQL en EC2

### 1.1 Crear instancia EC2 para la Base de Datos

1. Ve a **EC2 > Launch Instance**
2. Configuración:
   - **Name**: `database-postgresql`
   - **AMI**: Ubuntu Server 22.04 LTS
   - **Instance type**: t2.micro (suficiente para este experimento)
   - **Key pair**: Crea o selecciona un key pair existente
   - **Security group**: 
     - Crea nuevo: `database-sg`
     - Allow SSH (22) desde tu IP
     - Allow PostgreSQL (5432) desde 0.0.0.0/0 (o solo desde las IPs de los backends para mayor seguridad)
3. **Launch instance**

### 1.2 Conectar e Instalar PostgreSQL

```bash
# Conectar vía SSH
ssh -i "tu-key.pem" ubuntu@<IP_PUBLICA_DATABASE>

# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar PostgreSQL
sudo apt install postgresql postgresql-contrib -y

# Verificar instalación
sudo systemctl status postgresql
```

### 1.3 Configurar PostgreSQL para Aceptar Conexiones Remotas

```bash
# Editar postgresql.conf
sudo nano /etc/postgresql/14/main/postgresql.conf

# Buscar la línea #listen_addresses = 'localhost' y cambiarla a:
listen_addresses = '*'

# Editar pg_hba.conf para permitir conexiones remotas
sudo nano /etc/postgresql/14/main/pg_hba.conf

# Agregar al final del archivo:
host    all             all             0.0.0.0/0               md5

# Reiniciar PostgreSQL
sudo systemctl restart postgresql
```

### 1.4 Crear la Base de Datos y Usuario

```bash
# Cambiar al usuario postgres
sudo -i -u postgres

# Entrar a psql
psql

# Dentro de psql, ejecutar:
CREATE DATABASE inventario;
CREATE USER admin WITH PASSWORD 'TuPasswordSeguro123!';
GRANT ALL PRIVILEGES ON DATABASE inventario TO admin;
\q

# Salir del usuario postgres
exit
```

### 1.5 Inicializar la Base de Datos

```bash
# Copiar los scripts SQL al servidor (desde tu máquina local)
scp -i "tu-key.pem" database/*.sql ubuntu@<IP_PUBLICA_DATABASE>:~/

# En el servidor de la BD, ejecutar los scripts
psql -h localhost -U admin -d inventario -f ~/01_create_tables.sql
psql -h localhost -U admin -d inventario -f ~/02_seed_data.sql

# Verificar que los datos se cargaron
psql -h localhost -U admin -d inventario -c "SELECT COUNT(*) FROM productos;"
psql -h localhost -U admin -d inventario -c "SELECT COUNT(*) FROM operarios;"
```

### 1.6 Obtener la IP de la Base de Datos

```bash
# La IP pública de tu instancia EC2 de base de datos será:
# <IP_PUBLICA_DATABASE>

# Esta IP la usarás en los archivos .env de los backends como DB_HOST
```

---

## PARTE 2: Desplegar Backend 1 (CON Validación) en EC2

### 2.1 Crear instancia EC2 para Backend 1

1. Ve a **EC2 > Launch Instance**
2. Configuración:
   - **Name**: `backend-con-validacion`
   - **AMI**: Ubuntu Server 22.04 LTS
   - **Instance type**: t2.micro
   - **Key pair**: Crea o selecciona un key pair existente
   - **Security group**: 
     - Crea nuevo: `backend-validacion-sg`
     - Allow SSH (22) desde tu IP
     - Allow HTTP (8080) desde 0.0.0.0/0
3. **Launch instance**

### 2.2 Configurar Security Group

1. Edita `backend-validacion-sg`
2. Agrega regla inbound:
   - **Type**: Custom TCP
   - **Port**: 8080
   - **Source**: 0.0.0.0/0

### 2.3 Conectar y configurar el servidor

```bash
# Conectar vía SSH
ssh -i "tu-key.pem" ubuntu@<IP_PUBLICA_EC2>

# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Go
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

# Verificar instalación
go version

# Instalar Git
sudo apt install git -y

# Clonar o copiar el código del backend
mkdir -p ~/backend-con-validacion
cd ~/backend-con-validacion
```

### 2.4 Copiar código del backend

Desde tu máquina local, copia los archivos:

```bash
# Copiar archivos al servidor
scp -i "tu-key.pem" -r backend-con-validacion/* ubuntu@<IP_PUBLICA_EC2>:~/backend-con-validacion/
```

### 2.5 Configurar variables de entorno

```bash
# En el servidor EC2
cd ~/backend-con-validacion

# Crear archivo .env
cat > .env << EOF
DB_HOST=<IP_PUBLICA_DATABASE>
DB_PORT=5432
DB_USER=admin
DB_PASSWORD=TuPasswordSeguro123!
DB_NAME=inventario
PORT=8080
EOF
```

### 2.6 Compilar y ejecutar

```bash
# Inicializar módulo Go
go mod init backend-con-validacion
go mod tidy

# Compilar
go build -o server main.go

# Ejecutar (para pruebas)
./server

# Para ejecutar en background con systemd:
sudo nano /etc/systemd/system/backend-validacion.service
```

Contenido del service file:

```ini
[Unit]
Description=Backend Con Validacion
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/backend-con-validacion
ExecStart=/home/ubuntu/backend-con-validacion/server
Restart=on-failure
EnvironmentFile=/home/ubuntu/backend-con-validacion/.env

[Install]
WantedBy=multi-user.target
```

```bash
# Habilitar y iniciar el servicio
sudo systemctl daemon-reload
sudo systemctl enable backend-validacion
sudo systemctl start backend-validacion
sudo systemctl status backend-validacion
```

### 2.7 Verificar funcionamiento

```bash
# Prueba con credenciales válidas (debe funcionar)
curl -X GET "http://<IP_PUBLICA_EC2>:8080/productos" \
  -H "X-Operario-Nombre: Juan Perez" \
  -H "X-Operario-Id: 1"

# Prueba sin credenciales (debe fallar)
curl -X GET "http://<IP_PUBLICA_EC2>:8080/productos"
```

---

## PARTE 3: Desplegar Backend 2 (SIN Validación) en EC2

### 3.1 Crear instancia EC2 para Backend 2

Repetir los pasos 2.1-2.2 pero con:
- **Name**: `backend-sin-validacion`
- **Security group**: `backend-sin-validacion-sg`

### 3.2 Configurar el servidor

```bash
# Conectar vía SSH
ssh -i "tu-key.pem" ubuntu@<IP_PUBLICA_EC2_BACKEND2>

# Repetir pasos 2.3 de instalación de Go

# Crear directorio
mkdir -p ~/backend-sin-validacion
cd ~/backend-sin-validacion
```

### 3.3 Copiar código

```bash
# Desde tu máquina local
scp -i "tu-key.pem" -r backend-sin-validacion/* ubuntu@<IP_PUBLICA_EC2_BACKEND2>:~/backend-sin-validacion/
```

### 3.4 Configurar y ejecutar

```bash
# En el servidor EC2
cd ~/backend-sin-validacion

# Crear .env
cat > .env << EOF
DB_HOST=<IP_PUBLICA_DATABASE>
DB_PORT=5432
DB_USER=admin
DB_PASSWORD=TuPasswordSeguro123!
DB_NAME=inventario
PORT=8080
EOF

# Compilar
go mod init backend-sin-validacion
go mod tidy
go build -o server main.go

# Crear service (similar al anterior pero con nombres diferentes)
sudo nano /etc/systemd/system/backend-sin-validacion.service
```

Contenido del service file:

```ini
[Unit]
Description=Backend Sin Validacion
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/backend-sin-validacion
ExecStart=/home/ubuntu/backend-sin-validacion/server
Restart=on-failure
EnvironmentFile=/home/ubuntu/backend-sin-validacion/.env

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable backend-sin-validacion
sudo systemctl start backend-sin-validacion
sudo systemctl status backend-sin-validacion
```

### 3.5 Verificar funcionamiento

```bash
# Prueba sin credenciales (debe funcionar en este backend)
curl -X GET "http://<IP_PUBLICA_EC2_BACKEND2>:8080/productos"

# Prueba con credenciales (también debe funcionar)
curl -X GET "http://<IP_PUBLICA_EC2_BACKEND2>:8080/productos" \
  -H "X-Operario-Nombre: Juan Perez" \
  -H "X-Operario-Id: 1"
```

---

## PARTE 4: Desplegar Frontend en EC2

### 4.1 Crear instancia EC2 para Frontend

1. Ve a **EC2 > Launch Instance**
2. Configuración:
   - **Name**: `frontend-inventario`
   - **AMI**: Ubuntu Server 22.04 LTS
   - **Instance type**: t2.micro
   - **Key pair**: Usa el mismo o crea uno nuevo
   - **Security group**: 
     - Crea nuevo: `frontend-sg`
     - Allow SSH (22) desde tu IP
     - Allow HTTP (80) desde 0.0.0.0/0
     - Allow HTTPS (443) desde 0.0.0.0/0 (opcional)
3. **Launch instance**

### 4.2 Conectar y configurar

```bash
# Conectar vía SSH
ssh -i "tu-key.pem" ubuntu@<IP_PUBLICA_FRONTEND>

# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Node.js y npm
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Verificar instalación
node --version
npm --version

# Instalar nginx para servir la aplicación
sudo apt install nginx -y
```

### 4.3 Copiar y compilar el frontend

```bash
# Crear directorio
mkdir -p ~/frontend
cd ~/frontend
```

Desde tu máquina local:

```bash
# Copiar archivos
scp -i "tu-key.pem" -r frontend/* ubuntu@<IP_PUBLICA_FRONTEND>:~/frontend/
```

En el servidor:

```bash
cd ~/frontend

# Crear archivo de configuración para las URLs de los backends
cat > .env.production << EOF
REACT_APP_BACKEND_VALIDACION_URL=http://<IP_BACKEND1>:8080
REACT_APP_BACKEND_SIN_VALIDACION_URL=http://<IP_BACKEND2>:8080
EOF

# Instalar dependencias
npm install

# Compilar para producción
npm run build
```

### 4.4 Configurar Nginx

```bash
# Copiar build a directorio de nginx
sudo rm -rf /var/www/html/*
sudo cp -r build/* /var/www/html/

# Configurar nginx
sudo nano /etc/nginx/sites-available/default
```

Contenido del archivo:

```nginx
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm;

    server_name _;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

```bash
# Reiniciar nginx
sudo systemctl restart nginx
sudo systemctl status nginx
```

### 4.5 Verificar funcionamiento

Abre tu navegador y ve a: `http://<IP_PUBLICA_FRONTEND>`

---

## PARTE 5: Ejecutar el Experimento

### Configuración Experimento 1: CON Validación

1. En el frontend, selecciona "Backend CON Validación"
2. Ingresa nombre e ID del operario
3. Consulta productos
4. Verifica en los logs del backend que se registró el acceso

### Configuración Experimento 2: SIN Validación

1. En el frontend, selecciona "Backend SIN Validación"
2. Intenta consultar sin ingresar credenciales
3. La consulta debe funcionar sin necesidad de credenciales

### Monitoreo y Logs

```bash
# Ver logs del backend con validación
ssh ubuntu@<IP_BACKEND1>
sudo journalctl -u backend-validacion -f

# Ver logs del backend sin validación
ssh ubuntu@<IP_BACKEND2>
sudo journalctl -u backend-sin-validacion -f
```

---

## Resumen de URLs

| Componente | URL |
|------------|-----|
| Frontend | `http://<IP_FRONTEND>` |
| Backend CON Validación | `http://<IP_BACKEND1>:8080` |
| Backend SIN Validación | `http://<IP_BACKEND2>:8080` |
| Base de Datos | `<IP_PUBLICA_DATABASE>:5432` |

---

## Limpieza de Recursos AWS

Para evitar cargos innecesarios, cuando termines el experimento:

1. Termina las 4 instancias EC2 (Frontend, Backend 1, Backend 2, Database)
2. Elimina los Security Groups creados
3. Elimina los snapshots si los creaste

---

## Troubleshooting

### Backend no se conecta a la BD
- Verifica el Security Group de RDS permite conexiones desde las IPs de EC2
- Verifica las credenciales en el archivo .env
- Prueba la conexión: `psql -h <ENDPOINT> -U postgres -d inventario`

### Frontend no carga
- Verifica que nginx esté corriendo: `sudo systemctl status nginx`
- Revisa logs: `sudo tail -f /var/log/nginx/error.log`

### CORS errors
- Los backends ya incluyen configuración CORS
- Verifica que las URLs en el frontend sean correctas

---

## Contacto y Soporte

Para preguntas sobre este experimento, contacta al equipo de arquitectura de software.
