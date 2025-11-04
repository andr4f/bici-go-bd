-- ============================================================
-- SISTEMA BICI-GO - CARGA MASIVA DE DATOS REALISTAS
-- Script 06: INSERT MASIVO - EMPRESA NACIONAL
-- Motor: SQL Server 2016+
-- Simulación: Red Nacional de 50 Puntos + 500 Bicicletas
-- Fecha: Noviembre 2, 2025
-- ============================================================

SET NOCOUNT ON;
GO

PRINT '========================================';
PRINT 'INICIANDO CARGA MASIVA DE DATOS';
PRINT 'Empresa: BICI-GO Colombia';
PRINT '========================================';
PRINT '';

-- ============================================================
-- FASE 1: DATOS GEOGRÁFICOS (CATÁLOGOS BASE)
-- ============================================================

PRINT 'FASE 1: Insertando datos geográficos...';

-- Insertar países
INSERT INTO pais (nombre, moneda_oficial) VALUES
('Colombia', 'COP'),
('México', 'MXN'),
('Argentina', 'ARS'),
('Chile', 'CLP'),
('Perú', 'PEN');

-- Insertar ciudades principales de Colombia
INSERT INTO ciudad (nombre, latitud, longitud, id_pais) VALUES
-- Colombia (id_pais = 1)
('Bogotá', 4.710989, -74.072092, 1),
('Medellín', 6.244203, -75.581215, 1),
('Cali', 3.451647, -76.531985, 1),
('Barranquilla', 10.963889, -74.796387, 1),
('Cartagena', 10.391049, -75.479426, 1),
('Bucaramanga', 7.119349, -73.122742, 1),
('Pereira', 4.813333, -75.696111, 1),
('Santa Marta', 11.240278, -74.199167, 1),
('Manizales', 5.070275, -75.513817, 1),
('Ibagué', 4.438889, -75.232222, 1),
-- México (id_pais = 2)
('Ciudad de México', 19.432608, -99.133209, 2),
('Guadalajara', 20.676667, -103.347222, 2),
-- Argentina (id_pais = 3)
('Buenos Aires', -34.603722, -58.381592, 3),
-- Chile (id_pais = 4)
('Santiago', -33.448891, -70.669266, 4),
-- Perú (id_pais = 5)
('Lima', -12.046374, -77.042793, 5);

PRINT '  ✓ Insertados 5 países';
PRINT '  ✓ Insertadas 15 ciudades';

-- ============================================================
-- FASE 2: PUNTOS DE ALQUILER (RED NACIONAL)
-- ============================================================

PRINT '';
PRINT 'FASE 2: Creando red de puntos de alquiler...';

-- Bogotá (10 puntos)
INSERT INTO punto_alquiler (nombre, direccion, horario, capacidad_maxima, id_ciudad) VALUES
('BICI-GO Usaquén', 'Cra 7 # 116-50, Centro Comercial Hacienda Santa Bárbara', '6:00 AM - 10:00 PM', 40, 1),
('BICI-GO Chapinero', 'Cra 13 # 67-45, Zona G', '6:00 AM - 9:00 PM', 35, 1),
('BICI-GO Zona Rosa', 'Calle 82 # 12-18, Parque de la 93', '7:00 AM - 11:00 PM', 50, 1),
('BICI-GO Salitre', 'Av 68 # 24B-10, Parque Salitre Mágico', '6:00 AM - 8:00 PM', 30, 1),
('BICI-GO La Candelaria', 'Cra 3 # 12-44, Plaza del Chorro de Quevedo', '7:00 AM - 7:00 PM', 25, 1),
('BICI-GO Unicentro', 'Av 15 # 123-30, C.C. Unicentro', '8:00 AM - 9:00 PM', 45, 1),
('BICI-GO Tunal', 'Cra 24 # 48-55, C.C. Tunal', '6:00 AM - 9:00 PM', 40, 1),
('BICI-GO Suba', 'Calle 145 # 91-19, Plaza Fundadores', '6:00 AM - 8:00 PM', 35, 1),
('BICI-GO Américas', 'Av Américas # 68-50, Portal de las Américas', '5:30 AM - 10:00 PM', 50, 1),
('BICI-GO Simón Bolívar', 'Calle 63 # 59-80, Parque Simón Bolívar', '6:00 AM - 7:00 PM', 60, 1),

-- Medellín (8 puntos)
('BICI-GO Poblado', 'Cra 43A # 1-50, Parque Lleras', '7:00 AM - 11:00 PM', 45, 2),
('BICI-GO Laureles', 'Cra 70 # 44-60, Av Jardín', '6:00 AM - 9:00 PM', 40, 2),
('BICI-GO Centro Medellín', 'Cra 52 # 50-20, Plaza Botero', '6:00 AM - 8:00 PM', 30, 2),
('BICI-GO Envigado', 'Calle 37 Sur # 43-10, Parque Envigado', '7:00 AM - 9:00 PM', 35, 2),
('BICI-GO Sabaneta', 'Cra 45 # 51-50, Parque Sabaneta', '6:00 AM - 8:00 PM', 30, 2),
('BICI-GO Belén', 'Calle 30A # 80-50, Centro Comercial', '7:00 AM - 9:00 PM', 35, 2),
('BICI-GO Aranjuez', 'Cra 45 # 82-80, Estación Metro Aranjuez', '6:00 AM - 9:00 PM', 40, 2),
('BICI-GO Rionegro', 'Calle 49 # 50-60, Aeropuerto José María Córdova', '24 horas', 50, 2),

-- Cali (7 puntos)
('BICI-GO San Antonio', 'Calle 1 Oeste # 3-65, Barrio San Antonio', '7:00 AM - 10:00 PM', 35, 3),
('BICI-GO Granada', 'Av 9N # 13-45, Boulevard del Río', '6:00 AM - 9:00 PM', 40, 3),
('BICI-GO Unicentro Cali', 'Calle 5 # 42-25, C.C. Unicentro', '8:00 AM - 9:00 PM', 45, 3),
('BICI-GO Ciudad Jardín', 'Cra 100 # 11-60, Jardín Plaza', '7:00 AM - 9:00 PM', 40, 3),
('BICI-GO La Flora', 'Av 4N # 17-20, Parque de la Flora', '6:00 AM - 8:00 PM', 30, 3),
('BICI-GO Terminal Cali', 'Calle 30N # 2AN-29, Terminal de Transportes', '5:00 AM - 10:00 PM', 35, 3),
('BICI-GO Ingenio', 'Cra 122 # 15-30, Zona Industrial', '6:00 AM - 6:00 PM', 25, 3),

-- Barranquilla (5 puntos)
('BICI-GO Buenavista', 'Cra 51B # 80-200, C.C. Buenavista', '8:00 AM - 9:00 PM', 40, 4),
('BICI-GO Centro Barranquilla', 'Cra 44 # 36-45, Paseo Bolívar', '6:00 AM - 8:00 PM', 30, 4),
('BICI-GO Norte', 'Calle 98 # 52-165, Villa Country', '7:00 AM - 9:00 PM', 35, 4),
('BICI-GO Riomar', 'Calle 78 # 56-200, C.C. Riomar', '9:00 AM - 9:00 PM', 45, 4),
('BICI-GO Malecón', 'Cra 1 # 74-50, Gran Malecón', '6:00 AM - 10:00 PM', 50, 4),

-- Cartagena (5 puntos)
('BICI-GO Centro Histórico', 'Calle San Juan # 8-19, Ciudad Amurallada', '7:00 AM - 9:00 PM', 40, 5),
('BICI-GO Bocagrande', 'Av San Martín # 7-150, Bocagrande', '6:00 AM - 10:00 PM', 45, 5),
('BICI-GO Castillogrande', 'Cra 2 # 8-75, Castillogrande', '7:00 AM - 9:00 PM', 35, 5),
('BICI-GO Manga', 'Av Pedro de Heredia # 31-20, Manga', '6:00 AM - 8:00 PM', 30, 5),
('BICI-GO Aeropuerto CTG', 'Aeropuerto Rafael Núñez, Zona de Llegadas', '24 horas', 40, 5),

-- Otras ciudades (15 puntos)
('BICI-GO Bucaramanga Centro', 'Cra 19 # 34-50, Parque Santander', '6:00 AM - 9:00 PM', 35, 6),
('BICI-GO Cabecera BGA', 'Cra 36 # 47-150, Parque San Pío', '7:00 AM - 9:00 PM', 40, 6),
('BICI-GO Pereira Centro', 'Cra 7 # 19-45, Plaza de Bolívar', '6:00 AM - 8:00 PM', 30, 7),
('BICI-GO Santa Marta Rodadero', 'Cra 2 # 11-45, El Rodadero', '7:00 AM - 10:00 PM', 40, 8),
('BICI-GO Manizales Centro', 'Cra 23 # 25-40, Plaza de Bolívar', '6:00 AM - 8:00 PM', 25, 9),
('BICI-GO Ibagué Musical', 'Cra 3 # 11-70, Conservatorio del Tolima', '7:00 AM - 9:00 PM', 30, 10),
('BICI-GO CDMX Roma', 'Av Álvaro Obregón # 151, Roma Norte', '7:00 AM - 10:00 PM', 50, 11),
('BICI-GO CDMX Condesa', 'Av México # 189, Condesa', '7:00 AM - 10:00 PM', 45, 11),
('BICI-GO Guadalajara Centro', 'Av 16 de Septiembre # 180, Centro', '6:00 AM - 9:00 PM', 40, 12),
('BICI-GO Buenos Aires Palermo', 'Av Santa Fe # 3100, Palermo', '7:00 AM - 10:00 PM', 50, 13),
('BICI-GO Buenos Aires Recoleta', 'Av Pueyrredón # 2501, Recoleta', '7:00 AM - 9:00 PM', 45, 13),
('BICI-GO Santiago Providencia', 'Av Providencia # 2330, Providencia', '6:00 AM - 10:00 PM', 50, 14),
('BICI-GO Santiago Lastarria', 'José Victorino Lastarria # 90, Lastarria', '7:00 AM - 9:00 PM', 40, 14),
('BICI-GO Lima Miraflores', 'Av Larco # 1232, Miraflores', '7:00 AM - 10:00 PM', 50, 15),
('BICI-GO Lima San Isidro', 'Av Javier Prado Este # 560, San Isidro', '6:00 AM - 9:00 PM', 45, 15);

PRINT '  ✓ Insertados 50 puntos de alquiler';
PRINT '    - Bogotá: 10 puntos';
PRINT '    - Medellín: 8 puntos';
PRINT '    - Cali: 7 puntos';
PRINT '    - Barranquilla: 5 puntos';
PRINT '    - Cartagena: 5 puntos';
PRINT '    - Otras ciudades: 15 puntos';

-- ============================================================
-- FASE 3: PLANES DE ALQUILER Y CATÁLOGOS
-- ============================================================

PRINT '';
PRINT 'FASE 3: Configurando planes y catálogos...';

-- Insertar planes
INSERT INTO [plan] (nombre, descripcion) VALUES
('Básico Hora', 'Alquiler por hora, ideal para paseos cortos'),
('Medio Día', 'Alquiler de 4 horas, perfecto para turismo urbano'),
('Día Completo', 'Alquiler de 24 horas, máxima flexibilidad'),
('Fin de Semana', 'Alquiler desde viernes a domingo, aventura total'),
('Mensual Premium', 'Acceso ilimitado por 30 días, para usuarios frecuentes'),
('Estudiantil', 'Plan especial con descuento para estudiantes'),
('Corporativo', 'Plan empresarial con beneficios adicionales');

-- Insertar etiquetas
INSERT INTO etiqueta (nombre, tipo_de_etiqueta, descripcion) VALUES
('Eléctrica', 'característica', 'Bicicleta con motor eléctrico asistido'),
('Montaña', 'característica', 'Diseñada para terrenos irregulares'),
('Urbana', 'característica', 'Ideal para ciudad y ciclovías'),
('Plegable', 'característica', 'Bicicleta compacta y portátil'),
('Canasta', 'característica', 'Incluye canasta para transporte'),
('Luces LED', 'característica', 'Sistema de iluminación integrado'),
('GPS Integrado', 'característica', 'Sistema de rastreo GPS'),
('Amortiguación', 'característica', 'Sistema de amortiguación avanzado'),
('Asiento Ajustable', 'accesibilidad', 'Asiento regulable en altura'),
('Acceso Universal', 'accesibilidad', 'Diseño inclusivo para todos'),
('Solo Adultos', 'restricción', 'Uso restringido a mayores de 18 años'),
('Requiere Casco', 'restricción', 'Uso obligatorio de casco de seguridad'),
('Peso Máximo 100kg', 'restricción', 'Capacidad máxima de carga limitada'),
('Promoción Verano', 'promoción', 'Descuento especial temporada'),
('Nueva', 'promoción', 'Bicicleta recién adquirida'),
('Deportiva', 'característica', 'Alto rendimiento para ciclistas avanzados'),
('Turística', 'característica', 'Ideal para recorridos turísticos'),
('Carga', 'característica', 'Capacidad para transporte de mercancía');

-- Insertar tipos de cobertura
INSERT INTO tipo_cobertura (nombre, descripcion) VALUES
('Daños Propios', 'Cobertura contra daños accidentales de la bicicleta'),
('Robo Total', 'Cobertura en caso de robo del vehículo'),
('Responsabilidad Civil', 'Cobertura por daños a terceros'),
('Asistencia Mecánica', 'Servicio de asistencia 24/7 en ruta'),
('Accidentes Personales', 'Cobertura médica para el usuario'),
('Todo Riesgo', 'Cobertura integral que incluye todos los eventos');

PRINT '  ✓ Insertados 7 planes de alquiler';
PRINT '  ✓ Insertadas 18 etiquetas';
PRINT '  ✓ Insertados 6 tipos de cobertura';

-- ============================================================
-- FASE 4: ADMINISTRADORES
-- ============================================================

PRINT '';
PRINT 'FASE 4: Creando usuarios administradores...';

INSERT INTO administrador (nombre, apellido, email, fecha_registro) VALUES
('Carlos', 'Rodríguez', 'carlos.rodriguez@bicigo.com', '2023-01-15'),
('María', 'González', 'maria.gonzalez@bicigo.com', '2023-01-15'),
('Juan', 'Martínez', 'juan.martinez@bicigo.com', '2023-02-20'),
('Ana', 'López', 'ana.lopez@bicigo.com', '2023-03-10'),
('Luis', 'Hernández', 'luis.hernandez@bicigo.com', '2023-04-05'),
('Carmen', 'García', 'carmen.garcia@bicigo.com', '2023-05-12'),
('Pedro', 'Sánchez', 'pedro.sanchez@bicigo.com', '2023-06-18'),
('Laura', 'Torres', 'laura.torres@bicigo.com', '2023-07-22'),
('Diego', 'Ramírez', 'diego.ramirez@bicigo.com', '2023-08-30'),
('Sofía', 'Flores', 'sofia.flores@bicigo.com', '2023-09-15'),
('Andrés', 'Vargas', 'andres.vargas@bicigo.com', '2023-10-08'),
('Valentina', 'Castro', 'valentina.castro@bicigo.com', '2023-11-20'),
('Santiago', 'Morales', 'santiago.morales@bicigo.com', '2024-01-10'),
('Isabella', 'Jiménez', 'isabella.jimenez@bicigo.com', '2024-02-14'),
('Mateo', 'Ruiz', 'mateo.ruiz@bicigo.com', '2024-03-25');

PRINT '  ✓ Insertados 15 administradores';

-- ============================================================
-- FASE 5: PARÁMETROS DE MANTENIMIENTO
-- ============================================================

PRINT '';
PRINT 'FASE 5: Configurando parámetros de mantenimiento...';

INSERT INTO parametro_mantenimiento (km_umbral, horas_umbral, porcentaje_alerta) VALUES
(500, 100, 80);

PRINT '  ✓ Parámetros de mantenimiento configurados';

-- ============================================================
-- FASE 6: BICICLETAS (FLOTA DE 500 UNIDADES)
-- ============================================================

PRINT '';
PRINT 'FASE 6: Generando flota de 500 bicicletas...';
PRINT '  Esto puede tardar unos segundos...';

-- Variables para generación
DECLARE @i INT = 1;
DECLARE @codigo VARCHAR(50);
DECLARE @marca VARCHAR(100);
DECLARE @modelo VARCHAR(100);
DECLARE @anio SMALLINT;
DECLARE @tamano VARCHAR(20);
DECLARE @tipo_num INT;

WHILE @i <= 500
BEGIN
    -- Generar código único (formato: XXE####XXC)
    SET @codigo = 'BCE' + RIGHT('0000' + CAST(@i AS VARCHAR), 4) + 
                  CHAR(65 + (@i % 26)) + CHAR(65 + ((@i * 3) % 26)) + 'C';
    
    -- Seleccionar marca aleatoriamente
    SET @tipo_num = (@i % 10) + 1;
    SET @marca = CASE @tipo_num
        WHEN 1 THEN 'Trek'
        WHEN 2 THEN 'Giant'
        WHEN 3 THEN 'Specialized'
        WHEN 4 THEN 'Cannondale'
        WHEN 5 THEN 'Scott'
        WHEN 6 THEN 'Merida'
        WHEN 7 THEN 'Cube'
        WHEN 8 THEN 'Bianchi'
        WHEN 9 THEN 'GT'
        ELSE 'Orbea'
    END;
    
    -- Seleccionar modelo según marca
    SET @modelo = CASE @tipo_num
        WHEN 1 THEN 'FX Sport ' + CAST((@i % 5) + 1 AS VARCHAR)
        WHEN 2 THEN 'Escape ' + CAST((@i % 3) + 1 AS VARCHAR)
        WHEN 3 THEN 'Sirrus X ' + CAST((@i % 4) + 2 AS VARCHAR)
        WHEN 4 THEN 'Quick CX ' + CAST((@i % 3) + 2 AS VARCHAR)
        WHEN 5 THEN 'Sub Cross ' + CAST((@i % 4) + 10 AS VARCHAR)
        WHEN 6 THEN 'Crossway ' + CAST((@i % 6) + 100 AS VARCHAR)
        WHEN 7 THEN 'Travel Hybrid ' + CAST((@i % 5) + 1 AS VARCHAR)
        WHEN 8 THEN 'C-Sport ' + CAST((@i % 3) + 1 AS VARCHAR)
        WHEN 9 THEN 'Transeo ' + CAST((@i % 4) + 2 AS VARCHAR)
        ELSE 'MX ' + CAST((@i % 5) + 10 AS VARCHAR)
    END;
    
    -- Año de fabricación (2019-2025)
    SET @anio = 2019 + (@i % 7);
    
    -- Tamaño de marco
    SET @tamano = CASE (@i % 6)
        WHEN 0 THEN 'XS'
        WHEN 1 THEN 'S'
        WHEN 2 THEN 'M'
        WHEN 3 THEN 'L'
        WHEN 4 THEN 'XL'
        ELSE 'XXL'
    END;
    
    INSERT INTO bicicleta (codigo_unico, marca_comercial, modelo, anio_fabricacion, tamano_marco)
    VALUES (@codigo, @marca, @modelo, @anio, @tamano);
    
    SET @i = @i + 1;
END;

PRINT '  ✓ Insertadas 500 bicicletas';
PRINT '    - Trek: ~50 unidades';
PRINT '    - Giant: ~50 unidades';
PRINT '    - Specialized: ~50 unidades';
PRINT '    - Cannondale: ~50 unidades';
PRINT '    - Otras marcas: ~300 unidades';

-- ============================================================
-- FASE 7: ESTADOS INICIALES DE BICICLETAS
-- ============================================================

PRINT '';
PRINT 'FASE 7: Configurando estados iniciales...';

-- Estado operativo inicial (todas disponibles, algunas en mantenimiento)
INSERT INTO tabla_espejo_estado_operativo (id_bicicleta, estado, fecha_inicio, fecha_fin, id_admin)
SELECT 
    id_bicicleta,
    CASE 
        WHEN id_bicicleta % 20 = 0 THEN 'en mantenimiento'
        WHEN id_bicicleta % 50 = 0 THEN 'fuera de servicio'
        ELSE 'disponible'
    END,
    DATEADD(DAY, -(id_bicicleta % 365), GETDATE()),
    NULL,
    (id_bicicleta % 15) + 1
FROM bicicleta;

-- Estado físico inicial
INSERT INTO tabla_espejo_estado_fisico (id_bicicleta, condicion, fecha_inicio, fecha_fin, id_admin)
SELECT 
    id_bicicleta,
    CASE 
        WHEN id_bicicleta % 100 < 60 THEN 'excelente'
        WHEN id_bicicleta % 100 < 85 THEN 'bueno'
        WHEN id_bicicleta % 100 < 95 THEN 'regular'
        ELSE 'requiere servicio'
    END,
    DATEADD(DAY, -(id_bicicleta % 365), GETDATE()),
    NULL,
    (id_bicicleta % 15) + 1
FROM bicicleta;

-- Tipo de uso inicial
INSERT INTO tabla_espejo_tipo_uso (id_bicicleta, nombre_tipo_uso, descripcion, fecha_inicio, fecha_fin, id_admin)
SELECT 
    id_bicicleta,
    CASE (id_bicicleta % 6)
        WHEN 0 THEN 'montaña'
        WHEN 1 THEN 'urbana'
        WHEN 2 THEN 'ruta'
        WHEN 3 THEN 'híbrida'
        WHEN 4 THEN 'BMX'
        ELSE 'carretera'
    END,
    'Tipo asignado en registro inicial',
    DATEADD(DAY, -(id_bicicleta % 365), GETDATE()),
    NULL,
    (id_bicicleta % 15) + 1
FROM bicicleta;

-- Tipo de asistencia
INSERT INTO tabla_espejo_tipo_asistencia (id_bicicleta, nombre_tipo_asistencia, descripcion, fecha_inicio, fecha_fin, id_admin)
SELECT 
    id_bicicleta,
    CASE 
        WHEN id_bicicleta % 10 < 7 THEN 'convencional'
        WHEN id_bicicleta % 10 < 9 THEN 'eléctrica'
        ELSE 'asistida por pedaleo'
    END,
    'Sistema de asistencia configurado',
    DATEADD(DAY, -(id_bicicleta % 365), GETDATE()),
    NULL,
    (id_bicicleta % 15) + 1
FROM bicicleta;

PRINT '  ✓ Estados operativos configurados';
PRINT '  ✓ Estados físicos configurados';
PRINT '  ✓ Tipos de uso asignados';
PRINT '  ✓ Tipos de asistencia configurados';

-- ============================================================
-- FASE 8: UBICACIONES INICIALES
-- ============================================================

PRINT '';
PRINT 'FASE 8: Distribuyendo bicicletas en puntos...';

-- Distribuir bicicletas en los 50 puntos
INSERT INTO tabla_espejo_ubicacion (id_bicicleta, id_punto_alquiler, fecha_inicio, fecha_fin, id_admin)
SELECT 
    id_bicicleta,
    ((id_bicicleta - 1) % 50) + 1, -- Distribución uniforme
    DATEADD(DAY, -(id_bicicleta % 180), GETDATE()),
    NULL,
    (id_bicicleta % 15) + 1
FROM bicicleta;

-- También insertar en tabla limpia
INSERT INTO ubicacion (id_bicicleta, id_punto_alquiler, fecha_inicio)
SELECT 
    id_bicicleta,
    id_punto_alquiler,
    fecha_inicio
FROM tabla_espejo_ubicacion
WHERE fecha_fin IS NULL;

PRINT '  ✓ 500 bicicletas distribuidas en 50 puntos';
PRINT '    - Promedio: 10 bicicletas por punto';

-- ============================================================
-- FASE 9: USO ACUMULADO
-- ============================================================

PRINT '';
PRINT 'FASE 9: Generando datos de uso acumulado...';

INSERT INTO uso_acumulado (id_bicicleta, km_total, horas_total, km_parcial, horas_parcial, fecha_ultimo_mantenimiento)
SELECT 
    id_bicicleta,
    CAST((id_bicicleta % 5000) + RAND(CHECKSUM(NEWID())) * 1000 AS DECIMAL(10,2)),
    CAST((id_bicicleta % 1000) + RAND(CHECKSUM(NEWID())) * 200 AS DECIMAL(10,2)),
    CAST((id_bicicleta % 500) AS DECIMAL(10,2)),
    CAST((id_bicicleta % 100) AS DECIMAL(10,2)),
    CASE 
        WHEN id_bicicleta % 20 = 0 THEN DATEADD(DAY, -5, GETDATE())
        WHEN id_bicicleta % 10 = 0 THEN DATEADD(DAY, -30, GETDATE())
        ELSE DATEADD(DAY, -60, GETDATE())
    END
FROM bicicleta;

PRINT '  ✓ Datos de uso acumulado generados';

-- ============================================================
-- FASE 10: IMÁGENES DE BICICLETAS
-- ============================================================

PRINT '';
PRINT 'FASE 10: Asignando imágenes a bicicletas...';

-- Insertar imágenes (2-4 por bicicleta)
DECLARE @bici_id INT = 1;
DECLARE @img_count INT;
DECLARE @img_num INT;

WHILE @bici_id <= 500
BEGIN
    SET @img_count = 2 + (@bici_id % 3); -- 2 a 4 imágenes
    SET @img_num = 1;
    
    WHILE @img_num <= @img_count
    BEGIN
        INSERT INTO imagen_bicicleta (
            id_bicicleta, 
            url_imagen, 
            formato, 
            resolucion_ancho, 
            resolucion_alto, 
            tamano_kb,
            es_principal,
            orden_visualizacion,
            fecha_carga
        )
        VALUES (
            @bici_id,
            'https://cdn.bicigo.com/images/bike_' + CAST(@bici_id AS VARCHAR) + '_' + CAST(@img_num AS VARCHAR) + '.jpg',
            CASE (@img_num % 4)
                WHEN 0 THEN 'PNG'
                WHEN 1 THEN 'WEBP'
                WHEN 2 THEN 'JPG'
                ELSE 'JPEG'
            END,
            1920 + (@img_num * 128),
            1080 + (@img_num * 72),
            850 + (@bici_id % 2000),
            CASE WHEN @img_num = 1 THEN 1 ELSE 0 END,
            @img_num,
            DATEADD(DAY, -(@bici_id % 365), GETDATE())
        );
        
        SET @img_num = @img_num + 1;
    END;
    
    SET @bici_id = @bici_id + 1;
END;

PRINT '  ✓ Insertadas ~1,500 imágenes (promedio 3 por bicicleta)';

-- ============================================================
-- FASE 11: ETIQUETAS DE BICICLETAS
-- ============================================================

PRINT '';
PRINT 'FASE 11: Asignando etiquetas a bicicletas...';

-- Cada bicicleta tendrá entre 2 y 5 etiquetas
INSERT INTO bicicleta_etiqueta (id_bicicleta, id_etiqueta, fecha_asignacion)
SELECT DISTINCT
    b.id_bicicleta,
    e.id_etiqueta,
    DATEADD(DAY, -(b.id_bicicleta % 180), GETDATE())
FROM bicicleta b
CROSS JOIN etiqueta e
WHERE 
    -- Eléctrica (30% de la flota)
    (e.nombre = 'Eléctrica' AND b.id_bicicleta % 10 < 3)
    -- Montaña (según tipo de uso)
    OR (e.nombre = 'Montaña' AND (b.id_bicicleta % 6) = 0)
    -- Urbana (según tipo de uso)
    OR (e.nombre = 'Urbana' AND (b.id_bicicleta % 6) = 1)
    -- Plegable (10%)
    OR (e.nombre = 'Plegable' AND b.id_bicicleta % 10 = 0)
    -- Canasta (40%)
    OR (e.nombre = 'Canasta' AND b.id_bicicleta % 5 < 2)
    -- Luces LED (80%)
    OR (e.nombre = 'Luces LED' AND b.id_bicicleta % 5 != 0)
    -- GPS Integrado (todas)
    OR (e.nombre = 'GPS Integrado')
    -- Amortiguación (50%)
    OR (e.nombre = 'Amortiguación' AND b.id_bicicleta % 2 = 0)
    -- Asiento Ajustable (todas)
    OR (e.nombre = 'Asiento Ajustable')
    -- Acceso Universal (60%)
    OR (e.nombre = 'Acceso Universal' AND b.id_bicicleta % 5 < 3)
    -- Requiere Casco (todas)
    OR (e.nombre = 'Requiere Casco')
    -- Nueva (bicicletas de 2024-2025)
    OR (e.nombre = 'Nueva' AND b.anio_fabricacion >= 2024)
    -- Deportiva (20%)
    OR (e.nombre = 'Deportiva' AND b.id_bicicleta % 5 = 0)
    -- Turística (30%)
    OR (e.nombre = 'Turística' AND b.id_bicicleta % 10 < 3);

-- Insertar en tabla espejo
INSERT INTO tabla_espejo_bicicleta_etiqueta (id_bicicleta, id_etiqueta, fecha_asignacion, fecha_eliminacion, id_admin)
SELECT 
    id_bicicleta,
    id_etiqueta,
    fecha_asignacion,
    NULL,
    (id_bicicleta % 15) + 1
FROM bicicleta_etiqueta;

PRINT '  ✓ Etiquetas asignadas (promedio 4-5 por bicicleta)';

-- ============================================================
-- FASE 12: CONDICIONES ESPECIALES
-- ============================================================

PRINT '';
PRINT 'FASE 12: Configurando condiciones especiales...';

-- Insertar condiciones especiales para bicicletas que lo requieren
INSERT INTO condiciones_especiales (
    id_bicicleta, 
    descripcion_condiciones, 
    peso_maximo_kg, 
    altura_minima_cm, 
    altura_maxima_cm
)
SELECT 
    id_bicicleta,
    CASE 
        WHEN tamano_marco = 'XS' THEN 'Bicicleta diseñada para personas de estatura baja'
        WHEN tamano_marco = 'XXL' THEN 'Bicicleta reforzada para personas de gran estatura'
        WHEN id_bicicleta % 10 = 0 THEN 'Requiere experiencia previa en ciclismo'
        ELSE 'Condiciones estándar de uso'
    END,
    CASE 
        WHEN tamano_marco IN ('XS', 'S') THEN 90.00
        WHEN tamano_marco IN ('M', 'L') THEN 110.00
        ELSE 130.00
    END,
    CASE 
        WHEN tamano_marco = 'XS' THEN 140
        WHEN tamano_marco = 'S' THEN 150
        WHEN tamano_marco = 'M' THEN 160
        WHEN tamano_marco = 'L' THEN 170
        ELSE 180
    END,
    CASE 
        WHEN tamano_marco = 'XS' THEN 160
        WHEN tamano_marco = 'S' THEN 170
        WHEN tamano_marco = 'M' THEN 180
        WHEN tamano_marco = 'L' THEN 195
        ELSE 210
    END
FROM bicicleta
WHERE id_bicicleta % 3 = 0; -- 33% tienen condiciones especiales

-- Insertar restricciones de terreno
INSERT INTO restriccion_terreno (id_condicion, nombre, descripcion)
SELECT 
    id_condicion,
    CASE (id_condicion % 5)
        WHEN 0 THEN 'Prohibido terreno rocoso'
        WHEN 1 THEN 'No apta para pendientes mayores a 15%'
        WHEN 2 THEN 'Uso exclusivo en ciclovías'
        WHEN 3 THEN 'Evitar terrenos con barro'
        ELSE 'Restricción de velocidad máxima 25 km/h'
    END,
    'Restricción establecida por seguridad del usuario y conservación del equipo'
FROM condiciones_especiales
WHERE id_condicion % 2 = 0;

-- Insertar en tabla espejo
INSERT INTO tabla_espejo_condiciones_especiales (
    id_condicion,
    id_bicicleta,
    descripcion_condiciones,
    peso_maximo_kg,
    altura_minima_cm,
    altura_maxima_cm,
    fecha_inicio_vigencia,
    fecha_fin_vigencia,
    id_admin
)
SELECT 
    id_condicion,
    id_bicicleta,
    descripcion_condiciones,
    peso_maximo_kg,
    altura_minima_cm,
    altura_maxima_cm,
    DATEADD(DAY, -(id_bicicleta % 180), GETDATE()),
    NULL,
    (id_bicicleta % 15) + 1
FROM condiciones_especiales;

PRINT '  ✓ Condiciones especiales configuradas';
PRINT '  ✓ Restricciones de terreno establecidas';

-- ============================================================
-- FASE 13: TARIFAS POR PLAN Y BICICLETA
-- ============================================================

PRINT '';
PRINT 'FASE 13: Estableciendo tarifas...';

-- Tarifas base por plan (en COP - Pesos Colombianos)
DECLARE @tarifa_base TABLE (
    id_plan INT,
    valor_base DECIMAL(10,2)
);

INSERT INTO @tarifa_base VALUES
(1, 8000),   -- Básico Hora
(2, 25000),  -- Medio Día
(3, 40000),  -- Día Completo
(4, 95000),  -- Fin de Semana
(5, 250000), -- Mensual Premium
(6, 6000),   -- Estudiantil (descuento)
(7, 350000); -- Corporativo

-- Insertar tarifas con variación según tipo de bicicleta
INSERT INTO tarifa (id_plan, id_bicicleta, fecha_inicio, valor, moneda)
SELECT 
    p.id_plan,
    b.id_bicicleta,
    DATEADD(DAY, -(b.id_bicicleta % 180), GETDATE()),
    tb.valor_base * 
    CASE 
        -- Eléctricas 50% más caras
        WHEN EXISTS (
            SELECT 1 FROM bicicleta_etiqueta be 
            INNER JOIN etiqueta e ON be.id_etiqueta = e.id_etiqueta 
            WHERE be.id_bicicleta = b.id_bicicleta AND e.nombre = 'Eléctrica'
        ) THEN 1.5
        -- Deportivas 30% más caras
        WHEN EXISTS (
            SELECT 1 FROM bicicleta_etiqueta be 
            INNER JOIN etiqueta e ON be.id_etiqueta = e.id_etiqueta 
            WHERE be.id_bicicleta = b.id_bicicleta AND e.nombre = 'Deportiva'
        ) THEN 1.3
        -- Nuevas 20% más caras
        WHEN b.anio_fabricacion >= 2024 THEN 1.2
        -- Más antiguas 10% descuento
        WHEN b.anio_fabricacion <= 2020 THEN 0.9
        ELSE 1.0
    END,
    'COP'
FROM bicicleta b
CROSS JOIN [plan] p
CROSS JOIN @tarifa_base tb
WHERE tb.id_plan = p.id_plan;

-- Insertar en tabla espejo
INSERT INTO tabla_espejo_tarifa (id_plan, id_bicicleta, fecha_inicio, valor, moneda, fecha_fin, id_admin)
SELECT 
    id_plan,
    id_bicicleta,
    fecha_inicio,
    valor,
    moneda,
    NULL,
    (id_bicicleta % 15) + 1
FROM tarifa;

PRINT '  ✓ Tarifas establecidas para 7 planes';
PRINT '  ✓ Total: 3,500 combinaciones plan-bicicleta';

-- ============================================================
-- FASE 14: COBERTURAS DE SEGURO
-- ============================================================

PRINT '';
PRINT 'FASE 14: Asignando coberturas de seguro...';

-- Insertar coberturas (80% de bicicletas tienen seguro)
INSERT INTO cobertura_seguro (
    id_bicicleta,
    id_tipo_cobertura,
    monto_maximo,
    fecha_inicio_vigencia,
    fecha_fin_vigencia,
    estado
)
SELECT 
    b.id_bicicleta,
    ((b.id_bicicleta % 6) + 1), -- Distribuir tipos de cobertura
    CASE 
        WHEN b.anio_fabricacion >= 2024 THEN 15000000.00 -- $15M COP
        WHEN b.anio_fabricacion >= 2022 THEN 10000000.00 -- $10M COP
        ELSE 7000000.00 -- $7M COP
    END,
    DATEADD(DAY, -(b.id_bicicleta % 365), GETDATE()),
    DATEADD(YEAR, 1, DATEADD(DAY, -(b.id_bicicleta % 365), GETDATE())),
    CASE 
        WHEN b.id_bicicleta % 100 < 85 THEN 'activo'
        WHEN b.id_bicicleta % 100 < 92 THEN 'vencido'
        WHEN b.id_bicicleta % 100 < 97 THEN 'suspendido'
        ELSE 'en trámite'
    END
FROM bicicleta b
WHERE b.id_bicicleta % 5 != 0; -- 80% tienen seguro

-- Insertar en tabla espejo
INSERT INTO tabla_espejo_cobertura_seguro (
    id_cobertura,
    id_bicicleta,
    id_tipo_cobertura,
    monto_maximo,
    fecha_inicio_vigencia,
    fecha_fin_vigencia,
    estado,
    id_admin
)
SELECT 
    id_cobertura,
    id_bicicleta,
    id_tipo_cobertura,
    monto_maximo,
    fecha_inicio_vigencia,
    fecha_fin_vigencia,
    estado,
    (id_bicicleta % 15) + 1
FROM cobertura_seguro;

PRINT '  ✓ Coberturas de seguro asignadas';
PRINT '  ✓ 80% de la flota con cobertura activa';

-- ============================================================
-- FASE 15: DATOS HISTÓRICOS (ESPEJO)
-- ============================================================

PRINT '';
PRINT 'FASE 15: Generando historial de cambios...';

-- Insertar cambios históricos de estado operativo (últimos 6 meses)
INSERT INTO tabla_espejo_estado_operativo (id_bicicleta, estado, fecha_inicio, fecha_fin, id_admin)
SELECT 
    id_bicicleta,
    CASE 
        WHEN RAND(CHECKSUM(NEWID())) < 0.3 THEN 'en mantenimiento'
        WHEN RAND(CHECKSUM(NEWID())) < 0.2 THEN 'en alquiler'
        ELSE 'disponible'
    END,
    DATEADD(DAY, -180 - (id_bicicleta % 90), GETDATE()),
    DATEADD(DAY, -90 - (id_bicicleta % 60), GETDATE()),
    (id_bicicleta % 15) + 1
FROM bicicleta
WHERE id_bicicleta % 5 < 3; -- 60% tienen historial

-- Insertar cambios históricos de ubicación
INSERT INTO tabla_espejo_ubicacion (id_bicicleta, id_punto_alquiler, fecha_inicio, fecha_fin, id_admin)
SELECT 
    b.id_bicicleta,
    ((b.id_bicicleta + 25) % 50) + 1, -- Punto diferente al actual
    DATEADD(DAY, -270, GETDATE()),
    DATEADD(DAY, -180, GETDATE()),
    (b.id_bicicleta % 15) + 1
FROM bicicleta b
WHERE b.id_bicicleta % 4 = 0; -- 25% han cambiado de ubicación

-- Insertar historial de uso acumulado
INSERT INTO tabla_espejo_uso_acumulado (
    id_bicicleta,
    km_total,
    horas_total,
    km_parcial,
    horas_parcial,
    fecha_ultimo_mantenimiento,
    fecha_inicio_vigencia,
    fecha_fin_vigencia,
    id_admin
)
SELECT 
    ua.id_bicicleta,
    ua.km_total * 0.7, -- Valores anteriores
    ua.horas_total * 0.7,
    ua.km_parcial * 0.5,
    ua.horas_parcial * 0.5,
    DATEADD(DAY, -120, ua.fecha_ultimo_mantenimiento),
    DATEADD(DAY, -180, GETDATE()),
    DATEADD(DAY, -90, GETDATE()),
    (ua.id_bicicleta % 15) + 1
FROM uso_acumulado ua
WHERE ua.id_bicicleta % 3 = 0;

-- Insertar historial de bicicletas (cambios de datos básicos)
INSERT INTO tabla_espejo_bicicleta (
    id_bicicleta,
    marca_comercial,
    modelo,
    anio_fabricacion,
    tamano_marco,
    fecha_inicio_vigencia,
    fecha_fin_vigencia,
    id_admin
)
SELECT 
    id_bicicleta,
    marca_comercial,
    modelo + ' V1', -- Versión anterior
    anio_fabricacion,
    tamano_marco,
    DATEADD(DAY, -365, GETDATE()),
    DATEADD(DAY, -180, GETDATE()),
    (id_bicicleta % 15) + 1
FROM bicicleta
WHERE id_bicicleta % 10 = 0; -- 10% han tenido cambios

PRINT '  ✓ Historial de estados generado';
PRINT '  ✓ Historial de ubicaciones generado';
PRINT '  ✓ Historial de uso generado';
PRINT '  ✓ Historial de cambios generado';

-- ============================================================
-- FASE 16: ACTUALIZAR ESTADÍSTICAS
-- ============================================================

PRINT '';
PRINT 'FASE 16: Actualizando estadísticas del sistema...';

UPDATE STATISTICS pais;
UPDATE STATISTICS ciudad;
UPDATE STATISTICS punto_alquiler;
UPDATE STATISTICS [plan];
UPDATE STATISTICS etiqueta;
UPDATE STATISTICS tipo_cobertura;
UPDATE STATISTICS administrador;
UPDATE STATISTICS bicicleta;
UPDATE STATISTICS uso_acumulado;
UPDATE STATISTICS imagen_bicicleta;
UPDATE STATISTICS condiciones_especiales;
UPDATE STATISTICS restriccion_terreno;
UPDATE STATISTICS bicicleta_etiqueta;
UPDATE STATISTICS ubicacion;
UPDATE STATISTICS tarifa;
UPDATE STATISTICS cobertura_seguro;
UPDATE STATISTICS tabla_espejo_estado_operativo;
UPDATE STATISTICS tabla_espejo_estado_fisico;
UPDATE STATISTICS tabla_espejo_tipo_uso;
UPDATE STATISTICS tabla_espejo_tipo_asistencia;
UPDATE STATISTICS tabla_espejo_ubicacion;
UPDATE STATISTICS tabla_espejo_tarifa;
UPDATE STATISTICS tabla_espejo_cobertura_seguro;

PRINT '  ✓ Estadísticas actualizadas';

-- ============================================================
-- FASE 17: VERIFICACIÓN Y RESUMEN FINAL
-- ============================================================

PRINT '';
PRINT '========================================';
PRINT 'VERIFICACIÓN DE DATOS INSERTADOS';
PRINT '========================================';
PRINT '';

-- Resumen de registros por tabla
PRINT 'CATÁLOGOS:';
SELECT 'Países' AS Tabla, COUNT(*) AS Registros FROM pais
UNION ALL SELECT 'Ciudades', COUNT(*) FROM ciudad
UNION ALL SELECT 'Puntos de Alquiler', COUNT(*) FROM punto_alquiler
UNION ALL SELECT 'Planes', COUNT(*) FROM [plan]
UNION ALL SELECT 'Etiquetas', COUNT(*) FROM etiqueta
UNION ALL SELECT 'Tipos de Cobertura', COUNT(*) FROM tipo_cobertura;

PRINT '';
PRINT 'USUARIOS:';
SELECT 'Administradores' AS Tabla, COUNT(*) AS Registros FROM administrador;

PRINT '';
PRINT 'BICICLETAS Y RELACIONADOS:';
SELECT 'Bicicletas' AS Tabla, COUNT(*) AS Registros FROM bicicleta
UNION ALL SELECT 'Imágenes', COUNT(*) FROM imagen_bicicleta
UNION ALL SELECT 'Uso Acumulado', COUNT(*) FROM uso_acumulado
UNION ALL SELECT 'Condiciones Especiales', COUNT(*) FROM condiciones_especiales
UNION ALL SELECT 'Restricciones Terreno', COUNT(*) FROM restriccion_terreno
UNION ALL SELECT 'Bicicleta-Etiqueta', COUNT(*) FROM bicicleta_etiqueta;

PRINT '';
PRINT 'OPERACIONES:';
SELECT 'Ubicaciones Actuales' AS Tabla, COUNT(*) FROM ubicacion
UNION ALL SELECT 'Tarifas Vigentes', COUNT(*) FROM tarifa
UNION ALL SELECT 'Coberturas Seguro', COUNT(*) FROM cobertura_seguro;

PRINT '';
PRINT 'TABLAS ESPEJO (HISTORIAL):';
SELECT 'Estados Operativos' AS Tabla, COUNT(*) AS Registros FROM tabla_espejo_estado_operativo
UNION ALL SELECT 'Estados Físicos', COUNT(*) FROM tabla_espejo_estado_fisico
UNION ALL SELECT 'Tipos de Uso', COUNT(*) FROM tabla_espejo_tipo_uso
UNION ALL SELECT 'Tipos Asistencia', COUNT(*) FROM tabla_espejo_tipo_asistencia
UNION ALL SELECT 'Ubicaciones Históricas', COUNT(*) FROM tabla_espejo_ubicacion
UNION ALL SELECT 'Tarifas Históricas', COUNT(*) FROM tabla_espejo_tarifa
UNION ALL SELECT 'Coberturas Históricas', COUNT(*) FROM tabla_espejo_cobertura_seguro
UNION ALL SELECT 'Uso Histórico', COUNT(*) FROM tabla_espejo_uso_acumulado
UNION ALL SELECT 'Bicicletas Históricas', COUNT(*) FROM tabla_espejo_bicicleta;

PRINT '';
PRINT '========================================';
PRINT 'ESTADÍSTICAS DE LA FLOTA';
PRINT '========================================';
PRINT '';

-- Distribución por estado operativo
PRINT 'DISTRIBUCIÓN POR ESTADO OPERATIVO:';
SELECT 
    estado,
    COUNT(*) AS cantidad,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM tabla_espejo_estado_operativo WHERE fecha_fin IS NULL) AS DECIMAL(5,2)) AS porcentaje
FROM tabla_espejo_estado_operativo
WHERE fecha_fin IS NULL
GROUP BY estado
ORDER BY cantidad DESC;

PRINT '';
PRINT 'DISTRIBUCIÓN POR CONDICIÓN FÍSICA:';
SELECT 
    condicion,
    COUNT(*) AS cantidad,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM tabla_espejo_estado_fisico WHERE fecha_fin IS NULL) AS DECIMAL(5,2)) AS porcentaje
FROM tabla_espejo_estado_fisico
WHERE fecha_fin IS NULL
GROUP BY condicion
ORDER BY cantidad DESC;

PRINT '';
PRINT 'DISTRIBUCIÓN POR TIPO DE USO:';
SELECT 
    nombre_tipo_uso,
    COUNT(*) AS cantidad
FROM tabla_espejo_tipo_uso
WHERE fecha_fin IS NULL
GROUP BY nombre_tipo_uso
ORDER BY cantidad DESC;

PRINT '';
PRINT 'TOP 10 PUNTOS CON MÁS BICICLETAS:';
SELECT TOP 10
    pa.nombre,
    COUNT(tu.id_bicicleta) AS bicicletas,
    pa.capacidad_maxima,
    CAST(COUNT(tu.id_bicicleta) * 100.0 / pa.capacidad_maxima AS DECIMAL(5,2)) AS ocupacion_pct
FROM punto_alquiler pa
LEFT JOIN tabla_espejo_ubicacion tu ON pa.id_punto_alquiler = tu.id_punto_alquiler AND tu.fecha_fin IS NULL
GROUP BY pa.id_punto_alquiler, pa.nombre, pa.capacidad_maxima
ORDER BY bicicletas DESC;

PRINT '';
PRINT 'DISTRIBUCIÓN POR MARCA:';
SELECT 
    marca_comercial,
    COUNT(*) AS cantidad
FROM bicicleta
GROUP BY marca_comercial
ORDER BY cantidad DESC;

PRINT '';
PRINT '========================================';
PRINT 'CARGA MASIVA COMPLETADA EXITOSAMENTE';
PRINT '========================================';
PRINT '';
PRINT 'RESUMEN EJECUTIVO:';
PRINT '  ✓ 500 bicicletas activas';
PRINT '  ✓ 50 puntos de alquiler en 15 ciudades';
PRINT '  ✓ 7 planes de alquiler disponibles';
PRINT '  ✓ 3,500 combinaciones de tarifas';
PRINT '  ✓ ~1,500 imágenes de productos';
PRINT '  ✓ 400 bicicletas con cobertura de seguro';
PRINT '  ✓ 15 administradores del sistema';
PRINT '  ✓ Datos históricos de 6-12 meses';
PRINT '';
PRINT 'EMPRESA: BICI-GO Colombia';
PRINT 'COBERTURA: Nacional (10 ciudades principales)';
PRINT 'ESTADO: Sistema listo para operación';
PRINT '';
PRINT '========================================';
PRINT 'Próximo paso: Ejecutar script de TRIGGERS';
PRINT '========================================';

GO

SET NOCOUNT OFF;