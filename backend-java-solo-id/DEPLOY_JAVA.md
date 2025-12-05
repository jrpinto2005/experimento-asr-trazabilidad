# 🚀 Guía de Despliegue: Backend Java Solo ID en AWS EC2

Esta guía te ayudará a desplegar el backend Java que valida solo el ID del operario (experimento de modificabilidad).

---

## Prerrequisitos

- AWS Account con acceso a EC2
- Key pair (.pem) configurado
- Base de datos PostgreSQL ya desplegada (de los pasos anteriores)

---

## PASO 1: Crear Instancia EC2

### 1.1 En AWS Console

1. Ve a **EC2 > Launch Instance**
2. Configuración:
   - **Name**: `backend-java-solo-id`
   - **AMI**: Ubuntu Server 22.04 LTS
   - **Instance type**: t2.small (Java requiere más memoria que Go)
   - **Key pair**: Selecciona tu key pair existente
   - **Security group**: 
     - Crea nuevo: `backend-java-sg`
     - Allow SSH (22) desde tu IP
     - Allow Custom TCP (8080) desde 0.0.0.0/0
3. **Storage**: 15 GB (suficiente para Java + Maven)
4. **Launch instance**

### 1.2 Configurar Security Group

1. EC2 > Security Groups > `backend-java-sg`
2. Edit inbound rules:
   - SSH (22) desde tu IP
   - Custom TCP (8080) desde 0.0.0.0/0

---

## PASO 2: Instalar Java y Maven

### 2.1 Conectar al servidor

```bash
ssh -i "tu-key.pem" ubuntu@<IP_PUBLICA_EC2_JAVA>
```

### 2.2 Actualizar sistema

```bash
sudo apt update && sudo apt upgrade -y
```

### 2.3 Instalar Java 17

```bash
# Instalar OpenJDK 17
sudo apt install -y openjdk-17-jdk openjdk-17-jre

# Verificar instalación
java -version
javac -version

# Debe mostrar: openjdk version "17.x.x"
```

### 2.4 Instalar Maven

```bash
# Instalar Maven
sudo apt install -y maven

# Verificar instalación
mvn -version

# Debe mostrar: Apache Maven 3.x.x
```

### 2.5 Instalar Git

```bash
sudo apt install -y git
```

---

## PASO 3: Copiar y Compilar el Backend

### 3.1 Desde tu máquina local

```bash
# Copiar todo el directorio al servidor
scp -i "tu-key.pem" -r backend-java-solo-id ubuntu@<IP_PUBLICA_EC2_JAVA>:~/
```

### 3.2 En el servidor EC2

```bash
cd ~/backend-java-solo-id

# Crear archivo .env
cat > .env << EOF
DB_HOST=3.236.8.149
DB_PORT=5432
DB_USER=admin
DB_PASSWORD=TuPasswordSeguro123!
DB_NAME=inventario
PORT=8080
EOF

# Exportar variables de entorno
export $(cat .env | xargs)
```

### 3.3 Compilar el proyecto

```bash
# Compilar con Maven (primera vez tarda ~5 minutos)
mvn clean package -DskipTests

# Verificar que se creó el JAR
ls -lh target/backend-java-solo-id.jar
```

---

## PASO 4: Probar Manualmente

```bash
# Ejecutar el servidor
java -jar target/backend-java-solo-id.jar

# Deberías ver:
# 🚀 Backend Java SOLO ID iniciado
# 🔑 Validación: SOLO ID del operario (modificabilidad)
```

En otra terminal, probar:

```bash
# Health check
curl http://localhost:8080/productos/health

# Consulta con ID
curl -X GET "http://localhost:8080/productos" \
  -H "X-Operario-Id: 1"
```

Si funciona, detén el servidor (Ctrl+C) y continúa al paso 5.

---

## PASO 5: Configurar como Servicio Systemd

### 5.1 Crear archivo de servicio

```bash
sudo nano /etc/systemd/system/backend-java-solo-id.service
```

### 5.2 Contenido del archivo

```ini
[Unit]
Description=Backend Java Solo ID - Experimento Modificabilidad
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/backend-java-solo-id
Environment="DB_HOST=3.236.8.149"
Environment="DB_PORT=5432"
Environment="DB_USER=admin"
Environment="DB_PASSWORD=TuPasswordSeguro123!"
Environment="DB_NAME=inventario"
Environment="PORT=8080"
ExecStart=/usr/bin/java -jar /home/ubuntu/backend-java-solo-id/target/backend-java-solo-id.jar
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

Guarda con `Ctrl+O`, `Enter`, `Ctrl+X`.

### 5.3 Habilitar e iniciar el servicio

```bash
# Recargar systemd
sudo systemctl daemon-reload

# Habilitar servicio (auto-inicio)
sudo systemctl enable backend-java-solo-id

# Iniciar servicio
sudo systemctl start backend-java-solo-id

# Verificar estado
sudo systemctl status backend-java-solo-id

# Debe mostrar: Active: active (running)
```

### 5.4 Ver logs

```bash
# Ver logs en tiempo real
sudo journalctl -u backend-java-solo-id -f

# Ver últimas 50 líneas
sudo journalctl -u backend-java-solo-id -n 50

# Ver logs desde hoy
sudo journalctl -u backend-java-solo-id --since today
```

---

## PASO 6: Verificar desde Internet

### 6.1 Desde tu máquina local

```bash
# Health check
curl http://<IP_PUBLICA_EC2_JAVA>:8080/productos/health

# Consulta con ID válido
curl -X GET "http://<IP_PUBLICA_EC2_JAVA>:8080/productos" \
  -H "X-Operario-Id: 1"

# Consulta sin ID (debe fallar)
curl -X GET "http://<IP_PUBLICA_EC2_JAVA>:8080/productos"

# Consulta con ID inválido (debe fallar)
curl -X GET "http://<IP_PUBLICA_EC2_JAVA>:8080/productos" \
  -H "X-Operario-Id: 999"
```

### 6.2 Respuestas esperadas

**Health check:**
```json
{
  "status": "healthy",
  "backend": "java-solo-id",
  "validacion": "Solo ID del operario",
  "language": "Java Spring Boot",
  "database_status": "connected",
  "requires_auth": "ID only"
}
```

**Consulta exitosa (con ID válido):**
```json
{
  "productos": [...],
  "total": 15,
  "operario_id": 1,
  "operario_nombre": "Juan Perez",
  "backend_type": "java-solo-id",
  "validacion": "Solo ID del operario"
}
```

**Consulta sin ID:**
```json
{
  "error": "ID de operario requerido",
  "message": "Se requiere X-Operario-Id en los headers",
  "backend_type": "java-solo-id"
}
```

---

## PASO 7: Verificar Logs en la Base de Datos

```bash
# Conectar a la BD
psql -h 3.236.8.149 -U admin -d inventario

# Ver logs del backend Java
SELECT * FROM logs_acceso 
WHERE detalles LIKE '%Backend Java%' 
ORDER BY timestamp DESC 
LIMIT 10;

# Ver comparación entre backends
SELECT 
    detalles,
    COUNT(*) as accesos
FROM logs_acceso
GROUP BY detalles
ORDER BY accesos DESC;
```

---

## PASO 8: Actualizar Frontend (Opcional)

Si quieres agregar este backend al frontend, actualiza `frontend/src/App.js`:

```javascript
const BACKEND_OPTIONS = {
  validacion: {
    name: 'Backend CON Validación (Go)',
    url: 'http://<IP_BACKEND1>:8080'
  },
  sinValidacion: {
    name: 'Backend SIN Validación (Go)',
    url: 'http://<IP_BACKEND2>:8080'
  },
  javaSoloId: {
    name: 'Backend Java Solo ID (Modificabilidad)',
    url: 'http://<IP_JAVA>:8080'
  }
};
```

---

## PASO 9: Comandos Útiles

```bash
# Reiniciar servicio
sudo systemctl restart backend-java-solo-id

# Detener servicio
sudo systemctl stop backend-java-solo-id

# Ver status
sudo systemctl status backend-java-solo-id

# Ver logs
sudo journalctl -u backend-java-solo-id -f

# Recompilar después de cambios
cd ~/backend-java-solo-id
mvn clean package -DskipTests
sudo systemctl restart backend-java-solo-id
```

---

## Troubleshooting

### Error: "Port 8080 already in use"
```bash
# Ver qué proceso usa el puerto
sudo lsof -i :8080

# Matar proceso si es necesario
sudo kill -9 <PID>
```

### Error: "Could not connect to database"
```bash
# Verificar variables de entorno
sudo systemctl show backend-java-solo-id | grep Environment

# Verificar conectividad a BD
psql -h 3.236.8.149 -U admin -d inventario -c "SELECT 1;"
```

### Error: "OutOfMemoryError"
```bash
# Editar servicio para dar más memoria
sudo nano /etc/systemd/system/backend-java-solo-id.service

# Cambiar ExecStart a:
ExecStart=/usr/bin/java -Xmx512m -jar /home/ubuntu/backend-java-solo-id/target/backend-java-solo-id.jar

# Recargar y reiniciar
sudo systemctl daemon-reload
sudo systemctl restart backend-java-solo-id
```

---

## Resumen de IPs

| Componente | IP | Puerto |
|------------|-----|--------|
| Base de Datos | 3.236.8.149 | 5432 |
| Backend Go Validación | <IP_BACKEND1> | 8080 |
| Backend Go Sin Validación | <IP_BACKEND2> | 8080 |
| **Backend Java Solo ID** | **<IP_JAVA>** | **8080** |
| Frontend | <IP_FRONTEND> | 80 |

---

## ✅ Checklist de Despliegue

- [ ] Instancia EC2 creada (t2.small)
- [ ] Security Group configurado (puerto 8080)
- [ ] Java 17 instalado
- [ ] Maven instalado
- [ ] Código copiado al servidor
- [ ] Proyecto compilado exitosamente
- [ ] Variables de entorno configuradas
- [ ] Servicio systemd creado y habilitado
- [ ] Servicio corriendo (`systemctl status`)
- [ ] Health check funciona desde internet
- [ ] Consulta con ID funciona
- [ ] Consulta sin ID falla correctamente
- [ ] Logs registrados en base de datos

---

¡Backend Java Solo ID desplegado exitosamente! 🎉

Este backend valida la **modificabilidad** del sistema al demostrar que:
1. Se puede cambiar el lenguaje de implementación
2. Se puede modificar la lógica de validación
3. No se requiere modificar otros componentes
4. Se mantiene la compatibilidad con la base de datos existente
