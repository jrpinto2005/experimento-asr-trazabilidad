# 🎯 INICIO AQUÍ - Experimento ASR Trazabilidad

<div align="center">

## 🏢 Sistema de Inventario con Trazabilidad de Operarios

**Proyecto completo para validar un ASR (Architecture Significant Requirement)**

[![Estado](https://img.shields.io/badge/Estado-Completo-success)]()
[![AWS](https://img.shields.io/badge/AWS-Ready-orange)]()
[![Go](https://img.shields.io/badge/Go-1.21-blue)]()
[![React](https://img.shields.io/badge/React-18.2-blue)]()
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-blue)]()

</div>

---

## 📖 ¿Qué es este proyecto?

Este proyecto implementa un **experimento completo** para validar el siguiente requisito arquitectónico:

> ### 🎯 ASR
> "Yo como gerente de bodega dado que el sistema está operando con normalidad quiero poder saber el **100% de las veces** que un operario lee la base de datos el **nombre y el id del operario**"

---

## 🏗️ Arquitectura del Experimento

```
┌─────────────────────────────────────────────────────────┐
│                    FRONTEND (React)                      │
│           http://[IP-FRONTEND]                          │
│   Permite seleccionar backend y probar trazabilidad     │
└─────────────────────────────────────────────────────────┘
                          │
        ┌─────────────────┴─────────────────┐
        │                                    │
        ▼                                    ▼
┌──────────────────┐              ┌──────────────────┐
│   BACKEND 1      │              │   BACKEND 2      │
│ ✅ CON Validación│              │ ⚠️ SIN Validación│
│                  │              │                  │
│ - Valida creds   │              │ - No valida      │
│ - Registra logs  │              │ - Acceso libre   │
│ - Cumple ASR ✅  │              │ - NO cumple ❌   │
└──────────────────┘              └──────────────────┘
        │                                    │
        └─────────────────┬─────────────────┘
                          ▼
              ┌───────────────────────┐
              │  PostgreSQL (RDS)     │
              │  - operarios          │
              │  - productos          │
              │  - logs_acceso        │
              └───────────────────────┘
```

---

## 📦 ¿Qué incluye este proyecto?

<table>
<tr>
<td width="50%">

### 🗄️ Base de Datos
- ✅ Scripts SQL completos
- ✅ Tablas: operarios, productos, logs
- ✅ Datos de ejemplo listos

### 🔧 Backend CON Validación
- ✅ Servidor Go
- ✅ Valida credenciales
- ✅ Registra TODOS los accesos
- ✅ **Cumple el ASR**

### ⚠️ Backend SIN Validación
- ✅ Servidor Go
- ⚠️ No valida credenciales
- ⚠️ Permite acceso anónimo
- ❌ **NO cumple el ASR**

</td>
<td width="50%">

### 🎨 Frontend
- ✅ Interfaz React moderna
- ✅ Selector de backend
- ✅ Formulario de credenciales
- ✅ Visualización de productos

### 📚 Documentación
- ✅ Guía completa de despliegue
- ✅ Configuraciones AWS
- ✅ Diagramas de arquitectura
- ✅ Troubleshooting

### 🛠️ Scripts
- ✅ Pruebas automatizadas
- ✅ Asistente de despliegue
- ✅ Comandos listos

</td>
</tr>
</table>

---

## 🚀 Inicio Rápido (3 pasos)

### Paso 1: Usa el Asistente de Despliegue
```bash
./deploy-helper.sh
```
Este script te guiará paso a paso y generará todos los archivos de configuración necesarios.

### Paso 2: Sigue las Instrucciones Generadas
El asistente creará una carpeta `deployment-commands/` con todos los scripts personalizados.

### Paso 3: ¡Prueba el Experimento!
Abre el frontend en tu navegador y compara los dos backends.

---

## 📂 Estructura del Proyecto

```
Trazabilidad/
│
├── 📖 START_HERE.md                 ← ¡ESTÁS AQUÍ!
├── 📄 README.md                      ← Guía completa de despliegue
├── ⚡ QUICK_START.md                ← Comandos rápidos
├── 🏗️ ARQUITECTURA.md               ← Diagramas y diseño
├── ☁️ AWS_CONFIG.md                 ← Configuraciones AWS
├── 📊 PROJECT_SUMMARY.md            ← Resumen ejecutivo
│
├── 🤖 deploy-helper.sh              ← Asistente automático
├── 🧪 test-backend-validacion.sh    ← Pruebas Backend 1
├── 🧪 test-backend-sin-validacion.sh ← Pruebas Backend 2
│
├── 🗄️ database/                     ← Scripts SQL
│   ├── 01_create_tables.sql
│   ├── 02_seed_data.sql
│   └── 03_query_logs.sql
│
├── ✅ backend-con-validacion/       ← Backend que CUMPLE el ASR
│   ├── main.go
│   ├── go.mod
│   └── README.md
│
├── ⚠️ backend-sin-validacion/       ← Backend que NO cumple el ASR
│   ├── main.go
│   ├── go.mod
│   └── README.md
│
└── 🎨 frontend/                     ← React UI
    ├── package.json
    ├── public/
    └── src/
```

---

## 🎯 ¿Por Dónde Empezar?

### 👨‍💻 Si eres Desarrollador:
1. Lee [`README.md`](README.md) - Guía completa
2. Explora [`backend-con-validacion/main.go`](backend-con-validacion/main.go) - Ver implementación
3. Compara con [`backend-sin-validacion/main.go`](backend-sin-validacion/main.go)

### 🔧 Si vas a Desplegar:
1. Ejecuta `./deploy-helper.sh` - Asistente automático
2. Lee [`AWS_CONFIG.md`](AWS_CONFIG.md) - Configuraciones detalladas
3. Usa [`QUICK_START.md`](QUICK_START.md) - Comandos rápidos

### 🏗️ Si eres Arquitecto:
1. Lee [`ARQUITECTURA.md`](ARQUITECTURA.md) - Diseño del sistema
2. Lee [`PROJECT_SUMMARY.md`](PROJECT_SUMMARY.md) - Resumen ejecutivo
3. Revisa los diagramas de flujo

### 👔 Si eres Gerente/Stakeholder:
1. Lee [`PROJECT_SUMMARY.md`](PROJECT_SUMMARY.md) - Resumen general
2. Revisa la sección de resultados en [`ARQUITECTURA.md`](ARQUITECTURA.md)
3. Verifica los costos en [`AWS_CONFIG.md`](AWS_CONFIG.md)

---

## 🧪 ¿Qué Validará Este Experimento?

<table>
<tr>
<th>Aspecto</th>
<th>Backend CON Validación ✅</th>
<th>Backend SIN Validación ❌</th>
</tr>
<tr>
<td><strong>Requiere credenciales</strong></td>
<td>✅ Sí (obligatorio)</td>
<td>❌ No (opcional)</td>
</tr>
<tr>
<td><strong>Valida contra BD</strong></td>
<td>✅ Sí (100%)</td>
<td>❌ No</td>
</tr>
<tr>
<td><strong>Rechaza sin creds</strong></td>
<td>✅ Sí (401)</td>
<td>❌ No (200 OK)</td>
</tr>
<tr>
<td><strong>Trazabilidad</strong></td>
<td>✅ 100%</td>
<td>⚠️ Parcial o nula</td>
</tr>
<tr>
<td><strong>Cumple ASR</strong></td>
<td>✅ <strong>SÍ</strong></td>
<td>❌ <strong>NO</strong></td>
</tr>
</table>

---

## 💻 Tecnologías Utilizadas

<div align="center">

![Go](https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white)
![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)

</div>

---

## 📊 Datos de Prueba Incluidos

El proyecto incluye datos de ejemplo listos para usar:

### 👥 Operarios (5)
- ID: 1 - Juan Perez
- ID: 2 - Maria Garcia
- ID: 3 - Carlos Rodriguez
- ID: 4 - Ana Martinez
- ID: 5 - Luis Hernandez

### 📦 Productos (15)
- Laptop Dell XPS 15 - $1,299.99
- Mouse Logitech MX Master - $99.99
- Teclado Mecánico Corsair - $149.99
- Monitor Samsung 27" - $349.99
- _... y 11 productos más_

---

## ✅ Checklist Rápido

### Antes de empezar:
- [ ] Tengo cuenta de AWS
- [ ] Tengo credenciales configuradas
- [ ] He leído START_HERE.md (este archivo)
- [ ] Tengo Go, Node.js y PostgreSQL client instalados localmente (opcional)

### Para desplegar:
- [ ] Ejecuté `./deploy-helper.sh`
- [ ] Creé la infraestructura en AWS
- [ ] Inicialicé la base de datos
- [ ] Desplegué los 3 servidores
- [ ] Ejecuté las pruebas

### Para validar:
- [ ] Frontend funciona en el navegador
- [ ] Backend 1 rechaza sin credenciales
- [ ] Backend 2 permite sin credenciales
- [ ] Los logs se registran en la BD
- [ ] Puedo consultar productos con credenciales válidas

---

## 💰 Costos Estimados

| Componente | Tipo | Costo/mes |
|------------|------|-----------|
| RDS PostgreSQL | db.t3.micro | $15-20 |
| 3x EC2 | t2.micro | $24-30 |
| Data Transfer | ~1GB | $1-2 |
| **TOTAL** | | **~$40-52** |

💡 **Con AWS Free Tier**: Muchos servicios son **GRATIS** los primeros 12 meses.

---

## 🎓 Lo que Aprenderás

✅ Validación de requisitos arquitectónicos (ASR)  
✅ Implementación de trazabilidad y auditoría  
✅ Desarrollo de backend en Go  
✅ Desarrollo de frontend en React  
✅ Despliegue en AWS (RDS, EC2)  
✅ Configuración de bases de datos PostgreSQL  
✅ Testing y comparación de arquitecturas  
✅ Documentación técnica profesional  

---

## 🤝 Soporte

### ¿Tienes preguntas?

1. **Revisa la documentación**:
   - [`README.md`](README.md) - Guía completa
   - [`QUICK_START.md`](QUICK_START.md) - Inicio rápido
   - [`AWS_CONFIG.md`](AWS_CONFIG.md) - Troubleshooting

2. **Verifica los logs**:
   ```bash
   sudo journalctl -u backend-validacion -f
   sudo journalctl -u backend-sin-validacion -f
   ```

3. **Ejecuta las pruebas**:
   ```bash
   ./test-backend-validacion.sh
   ./test-backend-sin-validacion.sh
   ```

---

## 🎉 ¡Listo para Comenzar!

Este proyecto está **100% completo y listo para usar**. 

### Siguiente Paso:

```bash
# Opción 1: Usar el asistente (RECOMENDADO)
./deploy-helper.sh

# Opción 2: Leer la guía completa
cat README.md

# Opción 3: Inicio rápido
cat QUICK_START.md
```

---

<div align="center">

### 🚀 ¡Éxito con tu experimento! 🚀

**¿Listo para validar tu ASR?**

[📖 Leer Guía Completa](README.md) | [⚡ Inicio Rápido](QUICK_START.md) | [🏗️ Ver Arquitectura](ARQUITECTURA.md)

---

_Proyecto creado para Uniandes - ArquiSof_  
_Diciembre 2025_

</div>
