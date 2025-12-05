-- Script para crear las tablas de la base de datos
-- Base de datos: inventario

-- Tabla de operarios (usuarios que acceden al sistema)
CREATE TABLE IF NOT EXISTS operarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de productos (inventario)
CREATE TABLE IF NOT EXISTS productos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    stock_disponible INTEGER NOT NULL DEFAULT 0,
    precio DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de logs de acceso (para trazabilidad)
CREATE TABLE IF NOT EXISTS logs_acceso (
    id SERIAL PRIMARY KEY,
    operario_id INTEGER,
    operario_nombre VARCHAR(100),
    accion VARCHAR(50) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45),
    detalles TEXT
);

-- Índices para mejorar el rendimiento
CREATE INDEX idx_operarios_nombre ON operarios(nombre);
CREATE INDEX idx_productos_nombre ON productos(nombre);
CREATE INDEX idx_logs_timestamp ON logs_acceso(timestamp);
CREATE INDEX idx_logs_operario ON logs_acceso(operario_id);

-- Comentarios en las tablas
COMMENT ON TABLE operarios IS 'Usuarios autorizados para acceder al sistema de inventario';
COMMENT ON TABLE productos IS 'Inventario de productos en bodega';
COMMENT ON TABLE logs_acceso IS 'Registro de todos los accesos al sistema para trazabilidad';
