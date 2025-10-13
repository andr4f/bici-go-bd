-- ============================================
-- Script: 01_test_inserts.sql (SQL Server)
-- Versión: 1.0
-- Descripción: Datos de prueba para validar el esquema
-- ============================================

-- Insertar catálogos
INSERT INTO dbo.tipo_uso (nombre_tipo_uso, descripcion) VALUES
(N'Urbano',   N'Bicicletas para uso en ciudad'),
(N'Montaña',  N'Bicicletas para terrenos irregulares'),
(N'Carretera',N'Bicicletas para velocidad en pavimento');

INSERT INTO dbo.tipo_asistencia (nombre_tipo_asistencia, descripcion) VALUES
(N'Manual',    N'Sin asistencia eléctrica'),
(N'Eléctrica', N'Con motor eléctrico'),
(N'Híbrida',   N'Combinación de manual y eléctrica');

-- Insertar administradores
INSERT INTO dbo.administrador (nombre, apellido, email) VALUES
(N'Juan',  N'Pérez',     N'juan.perez@ejemplo.com'),
(N'María', N'González',  N'maria.gonzalez@ejemplo.com');

-- Insertar bicicletas
INSERT INTO dbo.bicicleta
  (id_admin, marca_comercial, modelo, anio_fabricacion, tamano_marco, id_tipo_uso, id_tipo_asistencia)
VALUES
(1, N'Trek',        N'FX 3',        2023, N'M', 1, 1),
(1, N'Giant',       N'Talon 2',     2022, N'L', 2, 1),
(2, N'Specialized', N'Turbo Vado',  2024, N'M', 1, 2);

-- Insertar estados operativos
INSERT INTO dbo.estado_operativo (id_bicicleta, estado) VALUES
(1, N'disponible'),
(2, N'disponible'),
(3, N'en_uso');

-- Insertar estados físicos
INSERT INTO dbo.estado_fisico (id_bicicleta, condicion) VALUES
(1, N'excelente'),
(2, N'buena'),
(3, N'excelente');