# 🚀 Guía Rápida de Despliegue - Resumen

## ⚡ Orden de Ejecución

### 1️⃣ Base de Datos (PRIMERO)
```bash
# Crear RDS PostgreSQL en AWS
# Endpoint: inventario-db.xxxxx.us-east-1.rds.amazonaws.com
# Ejecutar scripts SQL en orden:
psql -h <ENDPOINT> -U postgres -d inventario
\i database/01_create_tables.sql
\i database/02_seed_data.sql
```

### 2️⃣ Backend CON Validación
```bash
# EC2 Instance: backend-con-validacion
# Puerto: 8080

# En el servidor:
cd ~/backend-con-validacion
# Crear .env con credenciales de BD
go mod tidy
go build -o server main.go
./server
```

### 3️⃣ Backend SIN Validación
```bash
# EC2 Instance: backend-sin-validacion
# Puerto: 8080

# En el servidor:
cd ~/backend-sin-validacion
# Crear .env con credenciales de BD
go mod tidy
go build -o server main.go
./server
```

### 4️⃣ Frontend
```bash
# EC2 Instance: frontend-inventario
# Puerto: 80

# En el servidor:
cd ~/frontend
# Crear .env.production con URLs de backends
npm install
npm run build
sudo cp -r build/* /var/www/html/
sudo systemctl restart nginx
```

## 🔑 Credenciales para Pruebas

| ID | Nombre |
|----|--------|
| 1 | Juan Perez |
| 2 | Maria Garcia |
| 3 | Carlos Rodriguez |
| 4 | Ana Martinez |
| 5 | Luis Hernandez |

## 📊 Verificar el Experimento

### Prueba 1: Backend CON Validación ✅
```bash
# Debe FUNCIONAR
curl -X GET "http://<IP_BACKEND1>:8080/productos" \
  -H "X-Operario-Nombre: Juan Perez" \
  -H "X-Operario-Id: 1"

# Debe FALLAR (401)
curl -X GET "http://<IP_BACKEND1>:8080/productos"
```

### Prueba 2: Backend SIN Validación ⚠️
```bash
# Debe FUNCIONAR (sin credenciales)
curl -X GET "http://<IP_BACKEND2>:8080/productos"

# También FUNCIONA (con credenciales no validadas)
curl -X GET "http://<IP_BACKEND2>:8080/productos" \
  -H "X-Operario-Nombre: Usuario Falso" \
  -H "X-Operario-Id: 999"
```

## 📝 Ver Logs de Trazabilidad

```bash
# Conectar a la BD
psql -h <ENDPOINT> -U postgres -d inventario

# Ver logs
SELECT * FROM logs_acceso ORDER BY timestamp DESC LIMIT 20;

# Contar accesos por operario
SELECT operario_nombre, COUNT(*) 
FROM logs_acceso 
GROUP BY operario_nombre;
```

## 🌐 URLs del Sistema

- Frontend: `http://<IP_FRONTEND>`
- Backend 1 (CON validación): `http://<IP_BACKEND1>:8080`
- Backend 2 (SIN validación): `http://<IP_BACKEND2>:8080`
- Base de Datos: `<ENDPOINT_RDS>:5432`

## 🎯 Objetivo del Experimento

**ASR**: "Yo como gerente de bodega dado que el sistema está operando con normalidad quiero poder saber el 100% de las veces que un operario lee la base de datos el nombre y el id del operario"

### Resultados Esperados:

- ✅ **Backend CON Validación**: Cumple el ASR
  - Rechaza peticiones sin credenciales
  - Valida credenciales contra la BD
  - Registra TODOS los accesos en logs
  
- ❌ **Backend SIN Validación**: NO cumple el ASR
  - Permite acceso sin credenciales
  - No puede garantizar trazabilidad del 100%

## 🧪 Scripts de Prueba Automatizados

```bash
# Hacer ejecutables
chmod +x test-backend-validacion.sh
chmod +x test-backend-sin-validacion.sh

# Ejecutar pruebas
./test-backend-validacion.sh
./test-backend-sin-validacion.sh
```

## 🛑 Limpieza de Recursos AWS

```bash
# Cuando termines el experimento:
# 1. Terminar instancias EC2 (3 instancias)
# 2. Eliminar instancia RDS
# 3. Eliminar Security Groups
# 4. Eliminar Key Pairs (si no los necesitas)
```

## 📞 Troubleshooting Rápido

| Problema | Solución |
|----------|----------|
| Backend no conecta a BD | Verificar Security Group de RDS |
| Frontend muestra CORS error | Verificar URLs en .env.production |
| 401 Unauthorized | Verificar credenciales válidas |
| No hay datos | Ejecutar 02_seed_data.sql |

---

Para instrucciones detalladas, ver **README.md** principal.
