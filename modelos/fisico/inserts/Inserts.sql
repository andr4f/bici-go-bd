sql-- ============================================
-- Script: 01_test_inserts.sql
-- Versión: 1.0
-- Descripción: Datos de prueba para validar el esquema
-- ============================================

-- Insertar catálogos
INSERT INTO tipo_uso (nombre_tipo_uso, descripcion) VALUES
('Urbano', 'Bicicletas para uso en ciudad'),
('Montaña', 'Bicicletas para terrenos irregulares'),
('Carretera', 'Bicicletas para velocidad en pavimento');

INSERT INTO tipo_asistencia (nombre_tipo_asistencia, descripcion) VALUES
('Manual', 'Sin asistencia eléctrica'),
('Eléctrica', 'Con motor eléctrico'),
('Híbrida', 'Combinación de manual y eléctrica');

-- Insertar administrador
INSERT INTO administrador (nombre, apellido, email) VALUES
('Juan', 'Pérez', 'juan.perez@ejemplo.com'),
('María', 'González', 'maria.gonzalez@ejemplo.com');

-- Insertar bicicletas
INSERT INTO bicicleta (id_admin, marca_comercial, modelo, anio_fabricacion, tamano_marco, id_tipo_uso, id_tipo_asistencia) VALUES
(1, 'Trek', 'FX 3', 2023, 'M', 1, 1),
(1, 'Giant', 'Talon 2', 2022, 'L', 2, 1),
(2, 'Specialized', 'Turbo Vado', 2024, 'M', 1, 2);

-- Insertar estados
INSERT INTO estado_operativo (id_bicicleta, estado) VALUES
(1, 'disponible'),
(2, 'disponible'),
(3, 'en_uso');

INSERT INTO estado_fisico (id_bicicleta, condicion) VALUES
(1, 'excelente'),
(2, 'buena'),
(3, 'excelente');