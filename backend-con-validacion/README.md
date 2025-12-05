# Backend CON Validación

Este backend implementa la validación de credenciales de operarios antes de permitir el acceso a los datos.

## Características

- ✅ Valida que los headers `X-Operario-Nombre` y `X-Operario-Id` estén presentes
- ✅ Verifica que el operario exista en la base de datos
- ✅ Registra todos los accesos en la tabla `logs_acceso`
- ✅ Responde con error 401 si las credenciales son inválidas o faltan

## Endpoints

### GET /productos
Obtiene la lista de productos del inventario.

**Headers requeridos:**
- `X-Operario-Nombre`: Nombre del operario
- `X-Operario-Id`: ID del operario

**Ejemplo:**
```bash
curl -X GET "http://localhost:8080/productos" \
  -H "X-Operario-Nombre: Juan Perez" \
  -H "X-Operario-Id: 1"
```

### GET /health
Health check del servicio.

## Variables de entorno

Crear archivo `.env`:
```
DB_HOST=tu-endpoint-rds.amazonaws.com
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=tu-password
DB_NAME=inventario
PORT=8080
```

## Ejecución local

```bash
# Instalar dependencias
go mod download

# Ejecutar
go run main.go
```

## Compilación

```bash
go build -o server main.go
./server
```
