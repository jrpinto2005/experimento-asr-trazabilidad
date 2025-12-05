#!/bin/bash

# Script de prueba para el backend SIN validación
# Este script demuestra que NO requiere credenciales

BACKEND_URL="http://localhost:8081"

echo "======================================"
echo "Pruebas Backend SIN Validación"
echo "======================================"
echo ""

# Test 1: Health check
echo "Test 1: Health Check"
echo "---------------------"
curl -X GET "$BACKEND_URL/health"
echo -e "\n"

# Test 2: Consulta SIN credenciales (debe funcionar)
echo "Test 2: Consulta SIN credenciales (debe funcionar)"
echo "--------------------------------------------------"
curl -X GET "$BACKEND_URL/productos" \
  -w "\nHTTP Status: %{http_code}\n"
echo -e "\n"

# Test 3: Consulta CON credenciales (también funciona, pero no las valida)
echo "Test 3: Consulta CON credenciales (funciona, pero no las valida)"
echo "----------------------------------------------------------------"
curl -X GET "$BACKEND_URL/productos" \
  -H "X-Operario-Nombre: Juan Perez" \
  -H "X-Operario-Id: 1" \
  -w "\nHTTP Status: %{http_code}\n"
echo -e "\n"

# Test 4: Consulta con credenciales falsas (funciona igual)
echo "Test 4: Consulta con credenciales falsas (funciona igual)"
echo "---------------------------------------------------------"
curl -X GET "$BACKEND_URL/productos" \
  -H "X-Operario-Nombre: Usuario Inexistente" \
  -H "X-Operario-Id: 999999" \
  -w "\nHTTP Status: %{http_code}\n"
echo -e "\n"

echo "======================================"
echo "Pruebas completadas"
echo "⚠️  NOTA: Este backend NO valida credenciales"
echo "======================================"
