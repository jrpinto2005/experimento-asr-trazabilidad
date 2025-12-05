# 📐 Arquitectura del Experimento ASR

## Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────────┐
│                      FRONTEND (React)                        │
│                    EC2: frontend-inventario                  │
│                         Puerto: 80                           │
│                                                              │
│  ┌────────────────────────┐  ┌────────────────────────┐    │
│  │ Backend CON Validación │  │ Backend SIN Validación │    │
│  │      Selector          │  │      Selector          │    │
│  └────────────────────────┘  └────────────────────────┘    │
│                                                              │
│  ┌──────────────────────────────────────────────────┐      │
│  │       Formulario Credenciales Operario           │      │
│  │  - Nombre                                         │      │
│  │  - ID                                             │      │
│  └──────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
                           │
                           │ HTTP Request
                           │ Headers: X-Operario-Nombre, X-Operario-Id
                           ▼
        ┌──────────────────────────────────────────┐
        │                                          │
        ▼                                          ▼
┌───────────────────┐                    ┌───────────────────┐
│   BACKEND 1       │                    │   BACKEND 2       │
│  CON Validación   │                    │  SIN Validación   │
│                   │                    │                   │
│ EC2: backend-con- │                    │ EC2: backend-sin- │
│     validacion    │                    │     validacion    │
│ Puerto: 8080      │                    │ Puerto: 8080      │
│                   │                    │                   │
│ ┌───────────────┐ │                    │ ┌───────────────┐ │
│ │ Middleware    │ │                    │ │   NO Valida   │ │
│ │ Validación:   │ │                    │ │  Credenciales │ │
│ │               │ │                    │ │               │ │
│ │ 1. Verifica   │ │                    │ │  Acceso       │ │
│ │    headers    │ │                    │ │  directo      │ │
│ │ 2. Consulta   │ │                    │ │               │ │
│ │    BD         │ │                    │ └───────────────┘ │
│ │ 3. Registra   │ │                    │                   │
│ │    en logs    │ │                    │                   │
│ └───────────────┘ │                    │                   │
└───────────────────┘                    └───────────────────┘
        │                                          │
        │ SQL Query                                │ SQL Query
        │                                          │
        └──────────────┬───────────────────────────┘
                       ▼
        ┌──────────────────────────────────────────┐
        │      BASE DE DATOS PostgreSQL             │
        │      AWS RDS: inventario-db               │
        │            Puerto: 5432                   │
        │                                           │
        │  ┌────────────────────────────────────┐  │
        │  │  Tabla: operarios                  │  │
        │  │  - id, nombre                      │  │
        │  └────────────────────────────────────┘  │
        │                                           │
        │  ┌────────────────────────────────────┐  │
        │  │  Tabla: productos                  │  │
        │  │  - id, nombre, stock, precio       │  │
        │  └────────────────────────────────────┘  │
        │                                           │
        │  ┌────────────────────────────────────┐  │
        │  │  Tabla: logs_acceso                │  │
        │  │  - operario_id, operario_nombre    │  │
        │  │  - accion, timestamp, ip, detalles │  │
        │  └────────────────────────────────────┘  │
        └──────────────────────────────────────────┘
```

## Flujo de Datos - Backend CON Validación ✅

```
1. Frontend envía request
   ↓
   Headers: X-Operario-Nombre, X-Operario-Id
   ↓
2. Backend recibe request
   ↓
3. Middleware validación
   ├─ Verifica headers presentes?
   │  ├─ NO → 401 Unauthorized ❌
   │  └─ SI → Continúa
   │
   ├─ Consulta BD: operario existe?
   │  ├─ NO → 401 Unauthorized ❌
   │  └─ SI → Continúa
   │
   └─ Registra en logs_acceso ✅
      ↓
4. Consulta productos
   ↓
5. Retorna JSON al frontend
```

## Flujo de Datos - Backend SIN Validación ⚠️

```
1. Frontend envía request
   ↓
   Headers: X-Operario-Nombre, X-Operario-Id (OPCIONALES)
   ↓
2. Backend recibe request
   ↓
3. NO valida credenciales ⚠️
   ├─ Si hay headers → Los registra (sin validar)
   └─ Si no hay headers → Permite igual
   ↓
4. Consulta productos directamente
   ↓
5. Retorna JSON al frontend
```

## Comparación de Experimentos

| Aspecto | Backend CON Validación | Backend SIN Validación |
|---------|------------------------|------------------------|
| Requiere credenciales | ✅ SI | ❌ NO |
| Valida contra BD | ✅ SI | ❌ NO |
| Rechaza sin credenciales | ✅ SI (401) | ❌ NO (200) |
| Trazabilidad 100% | ✅ SI | ❌ NO |
| Cumple ASR | ✅ SI | ❌ NO |

## Casos de Uso del Experimento

### Caso 1: Usuario con credenciales válidas
```
Frontend → [Juan Perez, ID:1] → Backend 1 ✅ → BD → Productos
                                              ↓
                                          logs_acceso
```

### Caso 2: Usuario sin credenciales
```
Frontend → [Sin headers] → Backend 1 ❌ → 401 Unauthorized
                                        
Frontend → [Sin headers] → Backend 2 ✅ → BD → Productos
                                             ↓
                                         ⚠️ Sin trazabilidad
```

### Caso 3: Usuario con credenciales inválidas
```
Frontend → [Falso, ID:999] → Backend 1 ❌ → BD (no existe) → 401

Frontend → [Falso, ID:999] → Backend 2 ✅ → BD → Productos
                                               ↓
                                            ⚠️ Registra datos falsos
```

## Infraestructura AWS

```
┌─────────────────────────────────────────────────────┐
│                    AWS Region                        │
│                                                      │
│  ┌────────────────────────────────────────────┐    │
│  │              Default VPC                    │    │
│  │                                             │    │
│  │  ┌──────────────┐  ┌──────────────┐       │    │
│  │  │   EC2        │  │   EC2        │       │    │
│  │  │  Backend 1   │  │  Backend 2   │       │    │
│  │  │  :8080       │  │  :8080       │       │    │
│  │  └──────────────┘  └──────────────┘       │    │
│  │                                             │    │
│  │  ┌──────────────┐                          │    │
│  │  │   EC2        │                          │    │
│  │  │  Frontend    │                          │    │
│  │  │  :80         │                          │    │
│  │  └──────────────┘                          │    │
│  │                                             │    │
│  │          │                                  │    │
│  │          ▼                                  │    │
│  │  ┌──────────────┐                          │    │
│  │  │     RDS      │                          │    │
│  │  │  PostgreSQL  │                          │    │
│  │  │  :5432       │                          │    │
│  │  └──────────────┘                          │    │
│  └────────────────────────────────────────────┘    │
│                                                      │
│  Security Groups:                                   │
│  - inventario-sg (RDS)                              │
│  - backend-validacion-sg (EC2)                      │
│  - backend-sin-validacion-sg (EC2)                  │
│  - frontend-sg (EC2)                                │
└─────────────────────────────────────────────────────┘
```

## Métricas de Cumplimiento del ASR

### Backend CON Validación ✅
- **Trazabilidad**: 100% ✅
- **Validación**: 100% ✅
- **Logs completos**: 100% ✅

### Backend SIN Validación ❌
- **Trazabilidad**: ~50% (solo si envían headers) ⚠️
- **Validación**: 0% ❌
- **Logs completos**: Parcial ⚠️

## Conclusión del Experimento

El experimento demuestra que:

1. ✅ **Backend CON Validación** cumple completamente el ASR ya que:
   - Exige credenciales válidas en el 100% de las peticiones
   - Valida contra la base de datos
   - Registra todos los accesos con trazabilidad completa

2. ❌ **Backend SIN Validación** NO cumple el ASR porque:
   - Permite accesos anónimos
   - No garantiza trazabilidad del 100%
   - Los datos en logs pueden ser falsos o estar ausentes

**Recomendación**: Implementar validación obligatoria de credenciales para cumplir con el ASR de trazabilidad del 100%.
