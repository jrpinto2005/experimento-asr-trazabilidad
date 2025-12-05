# 📁 Estructura Completa del Proyecto

```
Trazabilidad/
│
├── 📄 README.md                          # Guía completa de despliegue
├── 📄 QUICK_START.md                     # Guía rápida de inicio
├── 📄 ARQUITECTURA.md                    # Diagramas y arquitectura del sistema
├── 📄 AWS_CONFIG.md                      # Configuraciones detalladas de AWS
├── 📄 .gitignore                         # Archivos a ignorar en Git
│
├── 🔧 test-backend-validacion.sh         # Script de pruebas Backend 1
├── 🔧 test-backend-sin-validacion.sh     # Script de pruebas Backend 2
│
├── 📂 database/                          # Scripts SQL para PostgreSQL
│   ├── 01_create_tables.sql             # Crear tablas (operarios, productos, logs_acceso)
│   ├── 02_seed_data.sql                 # Datos de ejemplo
│   └── 03_query_logs.sql                # Consultas útiles para logs
│
├── 📂 backend-con-validacion/            # Backend GO con validación ✅
│   ├── main.go                           # Código principal con middleware de validación
│   ├── go.mod                            # Dependencias Go
│   ├── go.sum                            # Checksums de dependencias
│   └── README.md                         # Documentación del backend
│
├── 📂 backend-sin-validacion/            # Backend GO sin validación ⚠️
│   ├── main.go                           # Código principal sin validación
│   ├── go.mod                            # Dependencias Go
│   ├── go.sum                            # Checksums de dependencias
│   └── README.md                         # Documentación del backend
│
└── 📂 frontend/                          # Frontend React
    ├── package.json                      # Dependencias Node.js
    ├── .gitignore                        # Ignorar node_modules y build
    ├── .env.example                      # Ejemplo de configuración
    ├── README.md                         # Documentación del frontend
    │
    ├── 📂 public/                        # Archivos públicos
    │   └── index.html                    # HTML base
    │
    └── 📂 src/                           # Código fuente React
        ├── index.js                      # Punto de entrada
        ├── App.js                        # Componente principal
        └── index.css                     # Estilos globales
```

## 📊 Resumen de Archivos

### Documentación (5 archivos)
- **README.md**: Guía completa paso a paso para todo el despliegue
- **QUICK_START.md**: Resumen ejecutivo y comandos rápidos
- **ARQUITECTURA.md**: Diagramas, flujos y explicación técnica
- **AWS_CONFIG.md**: Configuraciones detalladas de todos los servicios AWS
- **.gitignore**: Configuración de archivos a ignorar

### Base de Datos (3 scripts SQL)
- **01_create_tables.sql**: Crea las 3 tablas necesarias
- **02_seed_data.sql**: Inserta 5 operarios y 15 productos
- **03_query_logs.sql**: Queries útiles para analizar logs

### Backend CON Validación (4 archivos)
- **main.go**: ~200 líneas con middleware de validación completo
- **go.mod**: Dependencias (pq, cors)
- **go.sum**: Checksums
- **README.md**: Documentación específica

### Backend SIN Validación (4 archivos)
- **main.go**: ~180 líneas sin validación de credenciales
- **go.mod**: Dependencias (pq, cors)
- **go.sum**: Checksums
- **README.md**: Documentación específica

### Frontend React (8 archivos)
- **package.json**: Dependencias de React y axios
- **App.js**: ~250 líneas con toda la lógica de UI
- **index.js**: Punto de entrada React
- **index.css**: ~400 líneas de estilos modernos
- **index.html**: HTML base
- **.gitignore**: Ignorar node_modules
- **.env.example**: Ejemplo de configuración
- **README.md**: Documentación específica

### Scripts de Prueba (2 archivos)
- **test-backend-validacion.sh**: 6 casos de prueba automatizados
- **test-backend-sin-validacion.sh**: 4 casos de prueba automatizados

## 📈 Estadísticas del Proyecto

```
Total de archivos:     30+
Líneas de código Go:   ~800
Líneas de código JS:   ~350
Líneas de código CSS:  ~400
Líneas de SQL:         ~120
Líneas de docs:        ~1500

Total estimado:        ~3170+ líneas
```

## 🎯 Archivos por Prioridad de Lectura

### Para entender el proyecto:
1. `README.md` - Instrucciones completas
2. `ARQUITECTURA.md` - Entender el diseño
3. `QUICK_START.md` - Comandos rápidos

### Para configurar AWS:
1. `AWS_CONFIG.md` - Todas las configuraciones
2. `README.md` (Partes 1-4) - Pasos específicos

### Para entender el código:
1. `backend-con-validacion/main.go` - Ver la validación
2. `backend-sin-validacion/main.go` - Ver la diferencia
3. `frontend/src/App.js` - Ver la UI

### Para probar:
1. `database/01_create_tables.sql` - Crear BD
2. `database/02_seed_data.sql` - Insertar datos
3. `test-backend-validacion.sh` - Probar Backend 1
4. `test-backend-sin-validacion.sh` - Probar Backend 2

## 🔑 Archivos Clave del Experimento

### Backend CON Validación - main.go
```go
// Middleware que valida credenciales
func validarCredenciales(next http.HandlerFunc) http.HandlerFunc {
    // 1. Verifica headers
    // 2. Consulta BD para validar operario
    // 3. Registra en logs_acceso
    // 4. Permite o rechaza petición
}
```

### Backend SIN Validación - main.go
```go
// NO valida, solo consulta directamente
func getProductos(w http.ResponseWriter, r *http.Request) {
    // Consulta productos sin validar credenciales
    // Permite acceso anónimo
}
```

### Frontend - App.js
```javascript
// Componente que permite:
// - Seleccionar backend (con/sin validación)
// - Ingresar credenciales
// - Consultar productos
// - Mostrar resultados
```

## 📦 Dependencias del Proyecto

### Backend (Go)
```
github.com/lib/pq v1.10.9       # Driver PostgreSQL
github.com/rs/cors v1.10.1      # Middleware CORS
```

### Frontend (React)
```
react ^18.2.0                   # Framework UI
axios ^1.6.2                    # Cliente HTTP
react-scripts 5.0.1             # Scripts de build
```

### Infraestructura (AWS)
```
- 1x RDS PostgreSQL (db.t3.micro)
- 3x EC2 Ubuntu (t2.micro)
- 4x Security Groups
- 1x Key Pair
```

## 🚀 Flujo de Trabajo Recomendado

```
1. Leer README.md completo
   ↓
2. Crear RDS y ejecutar scripts SQL
   ↓
3. Desplegar Backend 1 (con validación)
   ↓
4. Desplegar Backend 2 (sin validación)
   ↓
5. Desplegar Frontend
   ↓
6. Ejecutar scripts de prueba
   ↓
7. Verificar logs en BD
   ↓
8. Analizar resultados (ARQUITECTURA.md)
   ↓
9. Documentar hallazgos
   ↓
10. Limpiar recursos AWS
```

## 📝 Checklist de Archivos Necesarios para Deploy

### En local:
- [ ] Todos los archivos del repositorio
- [ ] Key pair (.pem) de AWS
- [ ] Credenciales de AWS configuradas

### En Backend 1:
- [ ] main.go
- [ ] go.mod
- [ ] go.sum
- [ ] .env (creado en el servidor)

### En Backend 2:
- [ ] main.go
- [ ] go.mod
- [ ] go.sum
- [ ] .env (creado en el servidor)

### En Frontend:
- [ ] Todos los archivos de /frontend
- [ ] .env.production (creado en el servidor)
- [ ] build/ (generado con npm run build)

### En RDS:
- [ ] Scripts SQL ejecutados
- [ ] Datos de seed cargados
- [ ] Tablas verificadas

## 🔒 Archivos con Información Sensible (NO compartir)

❌ NO incluir en Git:
- `.env` (backends)
- `.env.production` (frontend)
- `*.pem` (key pairs)
- `*.ppk` (key pairs Windows)
- Credenciales de base de datos
- IPs públicas de EC2

✅ Usar en su lugar:
- `.env.example` (sin valores reales)
- Documentación con placeholders: `<TU_PASSWORD>`, `<IP_EC2>`

## 📚 Recursos Adicionales

### Documentación oficial:
- [AWS RDS PostgreSQL](https://docs.aws.amazon.com/rds/index.html)
- [AWS EC2](https://docs.aws.amazon.com/ec2/index.html)
- [Go PostgreSQL Driver](https://github.com/lib/pq)
- [React Documentation](https://react.dev/)
- [Nginx Documentation](https://nginx.org/en/docs/)

### Tutoriales relacionados:
- Despliegue de aplicaciones Go en EC2
- Configuración de RDS PostgreSQL
- Deploy de React en producción
- Systemd service files

---

Este proyecto está completo y listo para desplegar. Todos los archivos necesarios están creados y documentados.
