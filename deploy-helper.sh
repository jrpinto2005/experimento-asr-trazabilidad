#!/bin/bash

# Script de a# Recopilar información
echo -e "${BLUE}📝 Por favor proporciona la siguiente información:${NC}"
echo ""

ask "1️⃣  IP pública de la Base de Datos (EC2):" IP_DATABASE
ask "2️⃣  Password de PostgreSQL (admin user):" DB_PASSWORD
ask "3️⃣  IP pública del Backend CON Validación:" IP_BACKEND1
ask "4️⃣  IP pública del Backend SIN Validación:" IP_BACKEND2
ask "5️⃣  IP pública del Frontend:" IP_FRONTEND
ask "6️⃣  Ruta al archivo .pem (ej: ~/Downloads/mi-key.pem):" KEY_PATHdesplegar el proyecto en AWS
# Este script genera comandos personalizados basados en tus IPs y configuraciones

echo "════════════════════════════════════════════════════════════"
echo "  Asistente de Despliegue - Experimento ASR Trazabilidad"
echo "════════════════════════════════════════════════════════════"
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para preguntar
ask() {
    local prompt="$1"
    local var_name="$2"
    echo -e "${YELLOW}${prompt}${NC}"
    read -r value
    eval "$var_name='$value'"
}

# Recopilar información
echo -e "${BLUE}📝 Por favor proporciona la siguiente información:${NC}"
echo ""

ask "1️⃣  Endpoint de RDS (ej: inventario-db.xxxxx.us-east-1.rds.amazonaws.com):" RDS_ENDPOINT
ask "2️⃣  Password de PostgreSQL:" DB_PASSWORD
ask "3️⃣  IP pública del Backend CON Validación:" IP_BACKEND1
ask "4️⃣  IP pública del Backend SIN Validación:" IP_BACKEND2
ask "5️⃣  IP pública del Frontend:" IP_FRONTEND
ask "6️⃣  Ruta al archivo .pem (ej: ~/Downloads/mi-key.pem):" KEY_PATH

echo ""
echo -e "${GREEN}✅ Información recopilada!${NC}"
echo ""

# Crear directorio de outputs
OUTPUT_DIR="deployment-commands"
mkdir -p "$OUTPUT_DIR"

# ═══════════════════════════════════════════════════════════════
# 1. Generar archivo .env para Backend 1
# ═══════════════════════════════════════════════════════════════
cat > "$OUTPUT_DIR/backend1-env.txt" << EOF
DB_HOST=$IP_DATABASE
DB_PORT=5432
DB_USER=admin
DB_PASSWORD=$DB_PASSWORD
DB_NAME=inventario
PORT=8080
EOF

echo -e "${GREEN}✓${NC} Archivo .env para Backend 1 creado: ${BLUE}$OUTPUT_DIR/backend1-env.txt${NC}"

# ═══════════════════════════════════════════════════════════════
# 2. Generar archivo .env para Backend 2
# ═══════════════════════════════════════════════════════════════
cat > "$OUTPUT_DIR/backend2-env.txt" << EOF
DB_HOST=$IP_DATABASE
DB_PORT=5432
DB_USER=admin
DB_PASSWORD=$DB_PASSWORD
DB_NAME=inventario
PORT=8080
EOF

echo -e "${GREEN}✓${NC} Archivo .env para Backend 2 creado: ${BLUE}$OUTPUT_DIR/backend2-env.txt${NC}"

# ═══════════════════════════════════════════════════════════════
# 3. Generar archivo .env.production para Frontend
# ═══════════════════════════════════════════════════════════════
cat > "$OUTPUT_DIR/frontend-env-production.txt" << EOF
REACT_APP_BACKEND_VALIDACION_URL=http://$IP_BACKEND1:8080
REACT_APP_BACKEND_SIN_VALIDACION_URL=http://$IP_BACKEND2:8080
EOF

echo -e "${GREEN}✓${NC} Archivo .env.production para Frontend creado: ${BLUE}$OUTPUT_DIR/frontend-env-production.txt${NC}"

# ═══════════════════════════════════════════════════════════════
# 4. Generar script de conexión SSH
# ═══════════════════════════════════════════════════════════════
cat > "$OUTPUT_DIR/ssh-commands.sh" << EOF
#!/bin/bash
# Comandos SSH para conectar a los servidores

# Base de Datos
alias ssh-database="ssh -i $KEY_PATH ubuntu@$IP_DATABASE"

# Backend 1 (CON Validación)
alias ssh-backend1="ssh -i $KEY_PATH ubuntu@$IP_BACKEND1"

# Backend 2 (SIN Validación)
alias ssh-backend2="ssh -i $KEY_PATH ubuntu@$IP_BACKEND2"

# Frontend
alias ssh-frontend="ssh -i $KEY_PATH ubuntu@$IP_FRONTEND"

echo "Aliases creados:"
echo "  ssh-database  -> Conectar a Base de Datos"
echo "  ssh-backend1  -> Conectar a Backend CON validación"
echo "  ssh-backend2  -> Conectar a Backend SIN validación"
echo "  ssh-frontend  -> Conectar a Frontend"
EOF

chmod +x "$OUTPUT_DIR/ssh-commands.sh"
echo -e "${GREEN}✓${NC} Script de SSH creado: ${BLUE}$OUTPUT_DIR/ssh-commands.sh${NC}"

# ═══════════════════════════════════════════════════════════════
# 5. Generar comandos SCP para copiar archivos
# ═══════════════════════════════════════════════════════════════
cat > "$OUTPUT_DIR/scp-commands.sh" << EOF
#!/bin/bash
# Comandos SCP para copiar archivos a los servidores

echo "════════════════════════════════════════════════════════════"
echo "Copiando archivos al Backend 1 (CON Validación)..."
echo "════════════════════════════════════════════════════════════"
scp -i $KEY_PATH -r backend-con-validacion/* ubuntu@$IP_BACKEND1:~/backend-con-validacion/
scp -i $KEY_PATH $OUTPUT_DIR/backend1-env.txt ubuntu@$IP_BACKEND1:~/backend-con-validacion/.env

echo ""
echo "════════════════════════════════════════════════════════════"
echo "Copiando archivos al Backend 2 (SIN Validación)..."
echo "════════════════════════════════════════════════════════════"
scp -i $KEY_PATH -r backend-sin-validacion/* ubuntu@$IP_BACKEND2:~/backend-sin-validacion/
scp -i $KEY_PATH $OUTPUT_DIR/backend2-env.txt ubuntu@$IP_BACKEND2:~/backend-sin-validacion/.env

echo ""
echo "════════════════════════════════════════════════════════════"
echo "Copiando archivos al Frontend..."
echo "════════════════════════════════════════════════════════════"
scp -i $KEY_PATH -r frontend/* ubuntu@$IP_FRONTEND:~/frontend/
scp -i $KEY_PATH $OUTPUT_DIR/frontend-env-production.txt ubuntu@$IP_FRONTEND:~/frontend/.env.production

echo ""
echo "✅ Todos los archivos copiados exitosamente!"
EOF

chmod +x "$OUTPUT_DIR/scp-commands.sh"
echo -e "${GREEN}✓${NC} Script de SCP creado: ${BLUE}$OUTPUT_DIR/scp-commands.sh${NC}"

# ═══════════════════════════════════════════════════════════════
# 6. Generar comando para inicializar BD
# ═══════════════════════════════════════════════════════════════
cat > "$OUTPUT_DIR/init-database.sh" << EOF
#!/bin/bash
# Inicializar la base de datos PostgreSQL

echo "════════════════════════════════════════════════════════════"
echo "Copiando scripts SQL al servidor de base de datos..."
echo "════════════════════════════════════════════════════════════"
scp -i $KEY_PATH database/*.sql ubuntu@$IP_DATABASE:~/

echo ""
echo "════════════════════════════════════════════════════════════"
echo "Ejecutando scripts SQL..."
echo "════════════════════════════════════════════════════════════"
ssh -i $KEY_PATH ubuntu@$IP_DATABASE << 'ENDSSH'
psql -h localhost -U admin -d inventario -f ~/01_create_tables.sql
psql -h localhost -U admin -d inventario -f ~/02_seed_data.sql
psql -h localhost -U admin -d inventario -c "SELECT COUNT(*) as total_operarios FROM operarios;"
psql -h localhost -U admin -d inventario -c "SELECT COUNT(*) as total_productos FROM productos;"
ENDSSH

echo ""
echo "✅ Base de datos inicializada!"
EOF

chmod +x "$OUTPUT_DIR/init-database.sh"
echo -e "${GREEN}✓${NC} Script de inicialización de BD creado: ${BLUE}$OUTPUT_DIR/init-database.sh${NC}"

# ═══════════════════════════════════════════════════════════════
# 7. Generar scripts de prueba personalizados
# ═══════════════════════════════════════════════════════════════
cat > "$OUTPUT_DIR/test-backends.sh" << EOF
#!/bin/bash
# Script de pruebas para ambos backends

echo "════════════════════════════════════════════════════════════"
echo "Probando Backend 1 (CON Validación)"
echo "════════════════════════════════════════════════════════════"

echo ""
echo "Test 1: Health Check"
curl -s http://$IP_BACKEND1:8080/health | jq

echo ""
echo "Test 2: Consulta CON credenciales válidas"
curl -s -X GET "http://$IP_BACKEND1:8080/productos" \\
  -H "X-Operario-Nombre: Juan Perez" \\
  -H "X-Operario-Id: 1" | jq

echo ""
echo "Test 3: Consulta SIN credenciales (debe fallar)"
curl -s -X GET "http://$IP_BACKEND1:8080/productos" | jq

echo ""
echo "════════════════════════════════════════════════════════════"
echo "Probando Backend 2 (SIN Validación)"
echo "════════════════════════════════════════════════════════════"

echo ""
echo "Test 1: Health Check"
curl -s http://$IP_BACKEND2:8080/health | jq

echo ""
echo "Test 2: Consulta SIN credenciales (debe funcionar)"
curl -s -X GET "http://$IP_BACKEND2:8080/productos" | jq

echo ""
echo "✅ Pruebas completadas!"
EOF

chmod +x "$OUTPUT_DIR/test-backends.sh"
echo -e "${GREEN}✓${NC} Script de pruebas creado: ${BLUE}$OUTPUT_DIR/test-backends.sh${NC}"

# ═══════════════════════════════════════════════════════════════
# 8. Generar resumen de URLs
# ═══════════════════════════════════════════════════════════════
cat > "$OUTPUT_DIR/URLS.txt" << EOF
════════════════════════════════════════════════════════════
  URLs del Sistema Desplegado
════════════════════════════════════════════════════════════

Frontend:
  🌐 http://$IP_FRONTEND

Backend CON Validación:
  🔒 http://$IP_BACKEND1:8080
  🔍 Health: http://$IP_BACKEND1:8080/health
  📦 Productos: http://$IP_BACKEND1:8080/productos

Backend SIN Validación:
  ⚠️  http://$IP_BACKEND2:8080
  🔍 Health: http://$IP_BACKEND2:8080/health
  📦 Productos: http://$IP_BACKEND2:8080/productos

Base de Datos (PostgreSQL en EC2):
  🗄️  Host: $IP_DATABASE
  🔌 Port: 5432
  📊 DB: inventario
  👤 User: admin

Conexión a la BD:
  psql -h $IP_DATABASE -U admin -d inventario

════════════════════════════════════════════════════════════
EOF

echo -e "${GREEN}✓${NC} Resumen de URLs creado: ${BLUE}$OUTPUT_DIR/URLS.txt${NC}"

# ═══════════════════════════════════════════════════════════════
# Resumen final
# ═══════════════════════════════════════════════════════════════
echo ""
echo "════════════════════════════════════════════════════════════"
echo -e "${GREEN}✅ Archivos de configuración generados exitosamente!${NC}"
echo "════════════════════════════════════════════════════════════"
echo ""
echo -e "${BLUE}📁 Directorio de salida:${NC} $OUTPUT_DIR/"
echo ""
echo -e "${YELLOW}📋 Archivos generados:${NC}"
echo "  1. backend1-env.txt          - Variables de entorno Backend 1"
echo "  2. backend2-env.txt          - Variables de entorno Backend 2"
echo "  3. frontend-env-production.txt - Variables de entorno Frontend"
echo "  4. ssh-commands.sh           - Comandos SSH para conectar"
echo "  5. scp-commands.sh           - Comandos para copiar archivos"
echo "  6. init-database.sh          - Inicializar base de datos"
echo "  7. test-backends.sh          - Probar ambos backends"
echo "  8. URLS.txt                  - Resumen de todas las URLs"
echo ""
echo -e "${YELLOW}🚀 Próximos pasos:${NC}"
echo ""
echo "1️⃣  Inicializar la base de datos:"
echo -e "   ${BLUE}./$OUTPUT_DIR/init-database.sh${NC}"
echo ""
echo "2️⃣  Copiar archivos a los servidores:"
echo -e "   ${BLUE}./$OUTPUT_DIR/scp-commands.sh${NC}"
echo ""
echo "3️⃣  Conectar vía SSH y configurar cada servidor:"
echo -e "   ${BLUE}source $OUTPUT_DIR/ssh-commands.sh${NC}"
echo -e "   ${BLUE}ssh-backend1${NC}"
echo ""
echo "4️⃣  Probar los backends:"
echo -e "   ${BLUE}./$OUTPUT_DIR/test-backends.sh${NC}"
echo ""
echo "5️⃣  Abrir el frontend en el navegador:"
echo -e "   ${BLUE}http://$IP_FRONTEND${NC}"
echo ""
echo "════════════════════════════════════════════════════════════"
echo -e "${GREEN}¡Listo para desplegar!${NC}"
echo "════════════════════════════════════════════════════════════"
