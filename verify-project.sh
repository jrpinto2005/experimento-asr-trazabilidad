#!/bin/bash

# Script para verificar que todos los archivos del proyecto están presentes
# Ejecutar este script para validar que el proyecto está completo

echo "════════════════════════════════════════════════════════════"
echo "  Verificación de Integridad del Proyecto"
echo "════════════════════════════════════════════════════════════"
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

MISSING=0

# Función para verificar archivo
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
    else
        echo -e "${RED}✗${NC} $1 ${RED}(FALTANTE)${NC}"
        MISSING=$((MISSING + 1))
    fi
}

# Función para verificar directorio
check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1/"
    else
        echo -e "${RED}✗${NC} $1/ ${RED}(FALTANTE)${NC}"
        MISSING=$((MISSING + 1))
    fi
}

echo "📚 Verificando Documentación..."
check_file "README.md"
check_file "START_HERE.md"
check_file "QUICK_START.md"
check_file "ARQUITECTURA.md"
check_file "AWS_CONFIG.md"
check_file "ESTRUCTURA.md"
check_file "PROJECT_SUMMARY.md"
check_file ".gitignore"

echo ""
echo "🗄️ Verificando Base de Datos..."
check_dir "database"
check_file "database/01_create_tables.sql"
check_file "database/02_seed_data.sql"
check_file "database/03_query_logs.sql"

echo ""
echo "✅ Verificando Backend CON Validación..."
check_dir "backend-con-validacion"
check_file "backend-con-validacion/main.go"
check_file "backend-con-validacion/go.mod"
check_file "backend-con-validacion/go.sum"
check_file "backend-con-validacion/README.md"
check_file "backend-con-validacion/.env.example"

echo ""
echo "⚠️ Verificando Backend SIN Validación..."
check_dir "backend-sin-validacion"
check_file "backend-sin-validacion/main.go"
check_file "backend-sin-validacion/go.mod"
check_file "backend-sin-validacion/go.sum"
check_file "backend-sin-validacion/README.md"
check_file "backend-sin-validacion/.env.example"

echo ""
echo "🎨 Verificando Frontend..."
check_dir "frontend"
check_file "frontend/package.json"
check_file "frontend/README.md"
check_file "frontend/.gitignore"
check_file "frontend/.env.example"
check_dir "frontend/public"
check_file "frontend/public/index.html"
check_dir "frontend/src"
check_file "frontend/src/index.js"
check_file "frontend/src/App.js"
check_file "frontend/src/index.css"

echo ""
echo "🛠️ Verificando Scripts..."
check_file "deploy-helper.sh"
check_file "test-backend-validacion.sh"
check_file "test-backend-sin-validacion.sh"

echo ""
echo "════════════════════════════════════════════════════════════"

if [ $MISSING -eq 0 ]; then
    echo -e "${GREEN}✅ ¡Proyecto completo! Todos los archivos están presentes.${NC}"
    echo ""
    echo "📊 Estadísticas:"
    echo "  - Archivos de documentación: 8"
    echo "  - Scripts SQL: 3"
    echo "  - Archivos Backend 1: 5"
    echo "  - Archivos Backend 2: 5"
    echo "  - Archivos Frontend: 8+"
    echo "  - Scripts de ayuda: 3"
    echo ""
    echo "🚀 Siguiente paso: Leer START_HERE.md"
    echo "   cat START_HERE.md"
else
    echo -e "${RED}❌ Faltan $MISSING archivos${NC}"
    echo ""
    echo "Por favor, verifica que todos los archivos estén presentes."
fi

echo "════════════════════════════════════════════════════════════"
