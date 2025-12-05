# Backend SIN Validación

Este backend NO implementa validación de credenciales. Permite el acceso a los datos sin requerir autenticación.

## Características

- ⚠️ NO valida credenciales de operarios
- ⚠️ Permite consultas anónimas
- ℹ️ Si se envían headers con credenciales, se registran en logs (sin validar)
- ℹ️ Útil para comparar con el backend que sí valida

## Endpoints

### GET /productos
Obtiene la lista de productos del inventario.

**Headers opcionales:**
- `X-Operario-Nombre`: Nombre del operario (opcional, no se valida)
- `X-Operario-Id`: ID del operario (opcional, no se valida)

**Ejemplo sin credenciales:**
```bash
curl -X GET "http://localhost:8080/productos"
```

**Ejemplo con credenciales (no se validan):**
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

## ⚠️ ADVERTENCIA

Este backend es solo para propósitos de experimentación y comparación. 
NO debe usarse en producción ya que no implementa ninguna validación de seguridad.
