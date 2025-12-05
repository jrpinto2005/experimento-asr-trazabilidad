# Frontend - Sistema de Inventario

Frontend en React para el experimento de trazabilidad de operarios.

## Características

- ✅ Interfaz moderna y responsive
- ✅ Selector de backend (con/sin validación)
- ✅ Formulario para ingresar credenciales de operario
- ✅ Visualización de productos en cards
- ✅ Manejo de errores y estados de carga
- ✅ Prueba de consulta sin credenciales (solo en backend sin validación)

## Configuración

### Variables de Entorno

Crear archivo `.env.production`:

```env
REACT_APP_BACKEND_VALIDACION_URL=http://<IP_BACKEND1>:8080
REACT_APP_BACKEND_SIN_VALIDACION_URL=http://<IP_BACKEND2>:8080
```

Para desarrollo local (`.env.development`):

```env
REACT_APP_BACKEND_VALIDACION_URL=http://localhost:8080
REACT_APP_BACKEND_SIN_VALIDACION_URL=http://localhost:8081
```

## Instalación

```bash
# Instalar dependencias
npm install
```

## Ejecución

### Desarrollo
```bash
npm start
```

La aplicación estará disponible en `http://localhost:3000`

### Producción
```bash
# Compilar
npm run build

# El resultado estará en la carpeta build/
```

## Estructura

```
src/
├── App.js         # Componente principal
├── index.js       # Punto de entrada
├── index.css      # Estilos globales
└── ...
```

## Uso

1. Selecciona el backend a utilizar (CON o SIN validación)
2. Ingresa las credenciales del operario (nombre e ID)
3. Click en "Consultar Productos"
4. Los productos se mostrarán en cards

### Operarios de prueba

- ID: 1 - Juan Perez
- ID: 2 - Maria Garcia
- ID: 3 - Carlos Rodriguez
- ID: 4 - Ana Martinez
- ID: 5 - Luis Hernandez

## Características del Experimento

### Backend CON Validación
- Requiere nombre e ID válidos
- Valida contra la BD
- Rechaza consultas sin credenciales válidas

### Backend SIN Validación
- Permite consultas sin credenciales
- Incluye botón para probar sin credenciales
- Útil para comparar comportamiento

## Deploy en AWS EC2

Ver instrucciones detalladas en el README principal del proyecto.
