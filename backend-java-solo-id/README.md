# Backend Java - Solo ID (Experimento de Modificabilidad)

Este backend implementa una **variación del ASR original** para validar la **modificabilidad** del sistema. En lugar de validar nombre + ID del operario, **solo valida el ID**.

## Diferencias con los backends anteriores

| Backend | Lenguaje | Validación | Propósito |
|---------|----------|------------|-----------|
| backend-con-validacion | Go | Nombre + ID | Cumple ASR |
| backend-sin-validacion | Go | Ninguna | No cumple ASR |
| **backend-java-solo-id** | **Java** | **Solo ID** | **Modificabilidad** |

## Características

- ✅ **Framework**: Spring Boot 3.2.0
- ✅ **Java**: 17
- ✅ **Base de datos**: PostgreSQL
- ✅ **Validación**: Solo requiere `X-Operario-Id` header
- ✅ **Logging**: Registra todos los accesos en `logs_acceso`
- ✅ **CORS**: Habilitado para todos los orígenes

## Requisitos

- Java 17 o superior
- Maven 3.6+
- PostgreSQL (misma BD que los otros backends)

## Compilar y Ejecutar Localmente

```bash
# Configurar variables de entorno
export DB_HOST=3.236.8.149
export DB_PORT=5432
export DB_USER=admin
export DB_PASSWORD=TuPasswordSeguro123!
export DB_NAME=inventario
export PORT=8080

# Compilar
mvn clean package

# Ejecutar
java -jar target/backend-java-solo-id.jar
```

## Desplegar en AWS EC2

Ver la guía completa en `DEPLOY_JAVA.md`

## Endpoints

### GET /productos
Obtiene la lista de productos. **Requiere solo el ID del operario.**

**Headers requeridos:**
```
X-Operario-Id: 1
```

**Respuesta exitosa:**
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

**Respuesta error (sin ID):**
```json
{
  "error": "ID de operario requerido",
  "message": "Se requiere X-Operario-Id en los headers",
  "backend_type": "java-solo-id"
}
```

### GET /productos/health
Health check del servicio.

**Respuesta:**
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

## Pruebas

```bash
# Health check
curl http://localhost:8080/productos/health

# Consulta CON ID (debe funcionar)
curl -X GET "http://localhost:8080/productos" \
  -H "X-Operario-Id: 1"

# Consulta SIN ID (debe fallar)
curl -X GET "http://localhost:8080/productos"

# Consulta con ID inválido (debe fallar)
curl -X GET "http://localhost:8080/productos" \
  -H "X-Operario-Id: 999"
```

## Validación de Modificabilidad

Este backend demuestra que el sistema es **modificable**:

1. Se cambió el lenguaje de implementación (Go → Java)
2. Se modificó la lógica de validación (Nombre + ID → Solo ID)
3. Se mantiene la misma base de datos
4. Se mantiene el logging de accesos
5. **No se modificó ningún otro componente del sistema**

Esto valida que la arquitectura permite modificaciones sin afectar otros servicios.
