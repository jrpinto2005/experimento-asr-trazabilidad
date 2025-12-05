-- Script para consultar los logs de acceso
-- Ejecutar después de realizar pruebas

-- Ver todos los logs ordenados por fecha
SELECT 
    id,
    operario_id,
    operario_nombre,
    accion,
    timestamp,
    ip_address,
    detalles
FROM logs_acceso
ORDER BY timestamp DESC;

-- Contar accesos por operario
SELECT 
    operario_id,
    operario_nombre,
    COUNT(*) as total_accesos
FROM logs_acceso
GROUP BY operario_id, operario_nombre
ORDER BY total_accesos DESC;

-- Ver logs de las últimas 24 horas
SELECT 
    operario_id,
    operario_nombre,
    accion,
    timestamp,
    detalles
FROM logs_acceso
WHERE timestamp >= NOW() - INTERVAL '24 hours'
ORDER BY timestamp DESC;

-- Ver accesos sin validación vs con validación
SELECT 
    CASE 
        WHEN accion LIKE '%SIN_VALIDACION%' THEN 'Sin Validación'
        ELSE 'Con Validación'
    END as tipo_acceso,
    COUNT(*) as total
FROM logs_acceso
GROUP BY tipo_acceso;

-- Limpiar logs (si es necesario)
-- TRUNCATE TABLE logs_acceso;
