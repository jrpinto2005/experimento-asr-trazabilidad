#!/bin/bash

# Script de prueba para el backend CON validación
# Este script prueba diferentes escenarios de acceso

BACKEND_URL="http://localhost:8080"

echo "======================================"
echo "Pruebas Backend CON Validación"
echo "======================================"
echo ""

# Test 1: Health check
echo "Test 1: Health Check"
echo "---------------------"
curl -X GET "$BACKEND_URL/health"
echo -e "\n"

# Test 2: Consulta CON credenciales válidas
echo "Test 2: Consulta CON credenciales válidas (Juan Perez, ID=1)"
echo "-------------------------------------------------------------"
curl -X GET "$BACKEND_URL/productos" \
  -H "X-Operario-Nombre: Juan Perez" \
  -H "X-Operario-Id: 1" \
  -w "\nHTTP Status: %{http_code}\n"
echo -e "\n"

# Test 3: Consulta SIN credenciales (debe fallar)
echo "Test 3: Consulta SIN credenciales (debe fallar)"
echo "-----------------------------------------------"
curl -X GET "$BACKEND_URL/productos" \
  -w "\nHTTP Status: %{http_code}\n"
echo -e "\n"

# Test 4: Consulta con credenciales inválidas (debe fallar)
echo "Test 4: Consulta con credenciales inválidas (debe fallar)"
echo "---------------------------------------------------------"
curl -X GET "$BACKEND_URL/productos" \
  -H "X-Operario-Nombre: Usuario Falso" \
  -H "X-Operario-Id: 999" \
  -w "\nHTTP Status: %{http_code}\n"
echo -e "\n"

# Test 5: Consulta con solo nombre (debe fallar)
echo "Test 5: Consulta con solo nombre (debe fallar)"
echo "----------------------------------------------"
curl -X GET "$BACKEND_URL/productos" \
  -H "X-Operario-Nombre: Juan Perez" \
  -w "\nHTTP Status: %{http_code}\n"
echo -e "\n"

# Test 6: Consulta con otro operario válido
echo "Test 6: Consulta con otro operario válido (Maria Garcia, ID=2)"
echo "--------------------------------------------------------------"
curl -X GET "$BACKEND_URL/productos" \
  -H "X-Operario-Nombre: Maria Garcia" \
  -H "X-Operario-Id: 2" \
  -w "\nHTTP Status: %{http_code}\n"
echo -e "\n"

echo "======================================"
echo "Pruebas completadas"
echo "======================================"
