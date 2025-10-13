-- =============================================================
-- Script: 01_test_inserts_sqlserver.sql
-- Generado: 2025-10-13 04:44:33
-- Descripción: Datos de prueba para el esquema de Alquiler de Bicicletas (SQL Server)
--   - Orden de carga: catálogos -> admin/bicicletas -> tablas *_actual -> tablas *_hist
--   - Usa variables para obtener IDs por valores únicos (nombres/códigos)
-- =============================================================
SET NOCOUNT ON;

-- ==============================
-- 1) CATÁLOGOS GEOGRÁFICOS
-- ==============================
-- PAÍS
INSERT INTO dbo.pais (nombre, moneda_oficial) VALUES
('Colombia', 'COP'),
('Perú',     'PEN');

DECLARE @id_pais_co INT = (SELECT id_pais FROM dbo.pais WHERE nombre = 'Colombia');
DECLARE @id_pais_pe INT = (SELECT id_pais FROM dbo.pais WHERE nombre = 'Perú');

-- CIUDAD
INSERT INTO dbo.ciudad (nombre, latitud, longitud, id_pais) VALUES
('Santa Marta', 11.240000, -74.200000, @id_pais_co),
('Bogotá',       4.711000, -74.072100, @id_pais_co);

DECLARE @id_ciudad_sm INT = (SELECT id_ciudad FROM dbo.ciudad WHERE nombre = 'Santa Marta');
DECLARE @id_ciudad_bog INT = (SELECT id_ciudad FROM dbo.ciudad WHERE nombre = 'Bogotá');

-- PUNTO DE ALQUILER
INSERT INTO dbo.punto_alquiler (nombre, direccion, horario, capacidad_maxima, id_ciudad) VALUES
('Punto Prado',  'Cra 1 #23-45', 'L-D 06:00-22:00', 50, @id_ciudad_sm),
('Punto Centro', 'Cll 10 #5-15', 'L-D 06:00-22:00', 40, @id_ciudad_bog);

DECLARE @id_punto_prado  INT = (SELECT id_punto_alquiler FROM dbo.punto_alquiler WHERE nombre = 'Punto Prado');
DECLARE @id_punto_centro INT = (SELECT id_punto_alquiler FROM dbo.punto_alquiler WHERE nombre = 'Punto Centro');

-- ==============================
-- 2) CATÁLOGOS DE NEGOCIO
-- ==============================
-- TIPO_USO
INSERT INTO dbo.tipo_uso (nombre_tipo_uso, descripcion) VALUES
('Urbano',  'Uso en ciudad'),
('Montaña', 'Terrenos irregulares');

DECLARE @id_uso_urb INT = (SELECT id_tipo_uso FROM dbo.tipo_uso WHERE nombre_tipo_uso = 'Urbano');
DECLARE @id_uso_mon INT = (SELECT id_tipo_uso FROM dbo.tipo_uso WHERE nombre_tipo_uso = 'Montaña');

-- TIPO_ASISTENCIA
INSERT INTO dbo.tipo_asistencia (nombre_tipo_asistencia, descripcion) VALUES
('Manual',    'Sin asistencia eléctrica'),
('Eléctrica', 'Con motor eléctrico');

DECLARE @id_asist_man INT = (SELECT id_tipo_asistencia FROM dbo.tipo_asistencia WHERE nombre_tipo_asistencia = 'Manual');
DECLARE @id_asist_ele INT = (SELECT id_tipo_asistencia FROM dbo.tipo_asistencia WHERE nombre_tipo_asistencia = 'Eléctrica');

-- PLAN (tabla reservada: usar corchetes)
INSERT INTO dbo.[plan] (nombre, descripcion) VALUES
('Básico',  'Plan básico por tiempo'),
('Premium', 'Plan premium con beneficios');

DECLARE @id_plan_basico INT = (SELECT id_plan FROM dbo.[plan] WHERE nombre = 'Básico');
DECLARE @id_plan_premium INT = (SELECT id_plan FROM dbo.[plan] WHERE nombre = 'Premium');

-- ETIQUETA
INSERT INTO dbo.etiqueta (nombre, tipo_de_etiqueta, descripcion) VALUES
('Eco',     'ambiental', 'Etiqueta ecológica'),
('Ciudad',  'uso',       'Etiqueta urbana');

DECLARE @id_etq_eco INT = (SELECT id_etiqueta FROM dbo.etiqueta WHERE nombre = 'Eco');
DECLARE @id_etq_ciudad INT = (SELECT id_etiqueta FROM dbo.etiqueta WHERE nombre = 'Ciudad');

-- ==============================
-- 3) ADMINISTRADORES Y BICICLETAS
-- ==============================
-- ADMIN
INSERT INTO dbo.administrador (nombre, apellido, email) VALUES
('Juan',  'Pérez',    'juan.perez@demo.local'),
('María', 'González', 'maria.gonzalez@demo.local');

DECLARE @id_admin_juan INT = (SELECT id_admin FROM dbo.administrador WHERE email = 'juan.perez@demo.local');
DECLARE @id_admin_maria INT = (SELECT id_admin FROM dbo.administrador WHERE email = 'maria.gonzalez@demo.local');

-- BICICLETAS
INSERT INTO dbo.bicicleta (codigo_unico, marca_comercial, modelo, anio_fabricacion, tamano_marco, id_admin) VALUES
('B-0001', 'Trek',        'FX 3',      2023, 'M', @id_admin_juan),
('B-0002', 'Giant',       'Talon 2',   2022, 'L', @id_admin_juan),
('B-0003', 'Specialized', 'Sirrus 2.0',2024, 'S', @id_admin_maria);

DECLARE @id_b1 INT = (SELECT id_bicicleta FROM dbo.bicicleta WHERE codigo_unico = 'B-0001');
DECLARE @id_b2 INT = (SELECT id_bicicleta FROM dbo.bicicleta WHERE codigo_unico = 'B-0002');
DECLARE @id_b3 INT = (SELECT id_bicicleta FROM dbo.bicicleta WHERE codigo_unico = 'B-0003');

-- ==============================
-- 4) CLASIFICACIONES DE USO
-- ==============================
-- ACTUAL
INSERT INTO dbo.clasificacion_uso_actual (id_bicicleta, id_tipo_uso) VALUES
(@id_b1, @id_uso_urb),
(@id_b2, @id_uso_mon),
(@id_b3, @id_uso_urb);

-- HISTÓRICO
INSERT INTO dbo.clasificacion_uso_hist (id_bicicleta, id_tipo_uso, fecha_inicio, fecha_fin, usuario) VALUES
(@id_b1, @id_uso_urb, DATEADD(DAY,-10,GETDATE()), NULL, 'tester@demo'),
(@id_b2, @id_uso_mon, DATEADD(DAY,-8, GETDATE()), NULL, 'tester@demo'),
(@id_b3, @id_uso_urb, DATEADD(DAY,-5, GETDATE()), NULL, 'tester@demo');

-- ==============================
-- 5) CLASIFICACIONES DE ASISTENCIA
-- ==============================
-- ACTUAL
INSERT INTO dbo.clasificacion_asistencia_actual (id_bicicleta, id_tipo_asistencia) VALUES
(@id_b1, @id_asist_man),
(@id_b2, @id_asist_man),
(@id_b3, @id_asist_ele);

-- HISTÓRICO
INSERT INTO dbo.clasificacion_asistencia_hist (id_bicicleta, id_tipo_asistencia, fecha_inicio, fecha_fin, usuario) VALUES
(@id_b1, @id_asist_man, DATEADD(DAY,-10,GETDATE()), NULL, 'tester@demo'),
(@id_b2, @id_asist_man, DATEADD(DAY,-8, GETDATE()), NULL, 'tester@demo'),
(@id_b3, @id_asist_ele, DATEADD(DAY,-5, GETDATE()), NULL, 'tester@demo');

-- ==============================
-- 6) ESTADO OPERATIVO
-- ==============================
-- ACTUAL
INSERT INTO dbo.estado_operativo_actual (id_bicicleta, estado) VALUES
(@id_b1, 'disponible'),
(@id_b2, 'disponible'),
(@id_b3, 'mantenimiento');

-- HISTÓRICO
INSERT INTO dbo.estado_operativo_hist (id_bicicleta, estado, fecha_inicio, fecha_fin, usuario) VALUES
(@id_b1, 'disponible',   DATEADD(DAY,-2,GETDATE()), NULL, 'tester@demo'),
(@id_b2, 'disponible',   DATEADD(DAY,-1,GETDATE()), NULL, 'tester@demo'),
(@id_b3, 'mantenimiento',GETDATE(),                 NULL, 'tester@demo');

-- ==============================
-- 7) ESTADO FÍSICO
-- ==============================
-- ACTUAL
INSERT INTO dbo.estado_fisico_actual (id_bicicleta, condicion) VALUES
(@id_b1, 'excelente'),
(@id_b2, 'buena'),
(@id_b3, 'regular');

-- HISTÓRICO
INSERT INTO dbo.estado_fisico_hist (id_bicicleta, condicion, fecha_inicio, fecha_fin, usuario) VALUES
(@id_b1, 'excelente', DATEADD(DAY,-2,GETDATE()), NULL, 'tester@demo'),
(@id_b2, 'buena',     DATEADD(DAY,-1,GETDATE()), NULL, 'tester@demo'),
(@id_b3, 'regular',   GETDATE(),                 NULL, 'tester@demo');

-- ==============================
-- 8) ETIQUETAS EN BICICLETA
-- ==============================
-- ACTUAL
INSERT INTO dbo.bicicleta_etiqueta_actual (id_bicicleta, id_etiqueta) VALUES
(@id_b1, @id_etq_ciudad),
(@id_b3, @id_etq_eco);

-- HISTÓRICO
INSERT INTO dbo.bicicleta_etiqueta_hist (id_bicicleta, id_etiqueta, fecha_asignacion, fecha_eliminacion, usuario) VALUES
(@id_b1, @id_etq_ciudad, DATEADD(DAY,-1,GETDATE()), NULL, 'tester@demo'),
(@id_b3, @id_etq_eco,    GETDATE(),                 NULL, 'tester@demo');

-- ==============================
-- 9) UBICACIÓN
-- ==============================
-- ACTUAL
INSERT INTO dbo.ubicacion_actual (id_bicicleta, id_punto_alquiler) VALUES
(@id_b1, @id_punto_prado),
(@id_b2, @id_punto_centro),
(@id_b3, @id_punto_prado);

-- HISTÓRICO
INSERT INTO dbo.ubicacion_hist (id_bicicleta, id_punto_alquiler, fecha_inicio, fecha_fin, usuario, motivo) VALUES
(@id_b1, @id_punto_prado,  DATEADD(DAY,-2,GETDATE()), NULL, 'tester@demo','Alta demanda'),
(@id_b2, @id_punto_centro, DATEADD(DAY,-1,GETDATE()), NULL, 'tester@demo','Evento centro'),
(@id_b3, @id_punto_prado,  GETDATE(),                 NULL, 'tester@demo','Mantenimiento local');

-- ==============================
-- 10) TARIFAS
-- ==============================
-- ACTUAL
INSERT INTO dbo.tarifa_actual (id_bicicleta, id_plan, valor, moneda) VALUES
(@id_b1, @id_plan_basico,  5.50, 'COP'),
(@id_b2, @id_plan_basico,  4.00, 'COP'),
(@id_b3, @id_plan_premium, 9.99, 'COP');

-- HISTÓRICO
INSERT INTO dbo.tarifa_hist (id_bicicleta, id_plan, valor, moneda, fecha_inicio, fecha_fin, usuario, motivo) VALUES
(@id_b1, @id_plan_basico,  5.50, 'COP', CAST(DATEADD(DAY,-2,GETDATE()) AS DATE), NULL, 'tester@demo','Ajuste temporal'),
(@id_b2, @id_plan_basico,  4.00, 'COP', CAST(DATEADD(DAY,-1,GETDATE()) AS DATE), NULL, 'tester@demo','Promoción'),
(@id_b3, @id_plan_premium, 9.99, 'COP', CAST(GETDATE() AS DATE),               NULL, 'tester@demo','Lanzamiento');

-- ==============================
-- FIN DEL SCRIPT
-- ==============================
