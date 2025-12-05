-- Script para insertar datos de ejemplo
-- Ejecutar después de 01_create_tables.sql

-- Insertar operarios de ejemplo
INSERT INTO operarios (nombre) VALUES
    ('Juan Perez'),
    ('Maria Garcia'),
    ('Carlos Rodriguez'),
    ('Ana Martinez'),
    ('Luis Hernandez');

-- Insertar productos de ejemplo
INSERT INTO productos (nombre, stock_disponible, precio) VALUES
    ('Laptop Dell XPS 15', 25, 1299.99),
    ('Mouse Logitech MX Master', 150, 99.99),
    ('Teclado Mecánico Corsair', 80, 149.99),
    ('Monitor Samsung 27"', 45, 349.99),
    ('Webcam Logitech C920', 200, 79.99),
    ('Auriculares Sony WH-1000XM4', 60, 349.99),
    ('SSD Samsung 1TB', 300, 129.99),
    ('RAM DDR4 16GB', 500, 89.99),
    ('Hub USB-C', 120, 49.99),
    ('Cable HDMI 2.1', 400, 19.99),
    ('Adaptador USB-C a HDMI', 250, 29.99),
    ('Mouse Pad XXL', 180, 24.99),
    ('Soporte para Laptop', 95, 39.99),
    ('Lámpara LED Escritorio', 75, 34.99),
    ('Cámara Web 4K', 40, 149.99);

-- Verificar que los datos se insertaron correctamente
SELECT 'Operarios insertados:' as mensaje, COUNT(*) as total FROM operarios;
SELECT 'Productos insertados:' as mensaje, COUNT(*) as total FROM productos;

-- Mostrar algunos datos de ejemplo
SELECT 'Lista de operarios:' as mensaje;
SELECT * FROM operarios LIMIT 5;

SELECT 'Lista de productos (primeros 10):' as mensaje;
SELECT id, nombre, stock_disponible, precio FROM productos LIMIT 10;
