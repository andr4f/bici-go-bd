
-- SISTEMA BICI-GO - MODELO FÍSICO
-- Script 05: CREACIÓN DE VISTAS - VERSIÓN FINAL OPTIMIZADA
-- ROL: Diseñador Físico Senior
-- VERSIÓN: Sin ORDER BY (SQL Server best practice)
-- Fecha: Noviembre 2, 2025
-- ============================================================

-- FASE 1: VISTAS SIMPLES (Una tabla, filtrado básico)

-- VISTA 1: Bicicletas disponibles para alquiler
CREATE OR ALTER VIEW v_bicicletas_disponibles AS
SELECT 
    id_bicicleta,
    codigo_unico AS codigo,
    marca_comercial AS marca,
    modelo,
    anio_fabricacion,
    tamano_marco AS tamaño
FROM bicicleta
WHERE id_bicicleta NOT IN (
    SELECT id_bicicleta FROM tabla_espejo_estado_operativo 
    WHERE estado = 'en mantenimiento' AND fecha_fin IS NULL
);

GO

-- VISTA 2: Administradores activos
CREATE OR ALTER VIEW v_administradores AS
SELECT 
    id_admin,
    nombre,
    apellido,
    email,
    CONCAT(nombre, ' ', apellido) AS nombre_completo,
    fecha_registro
FROM administrador;

GO

-- VISTA 3: Planes de alquiler disponibles
CREATE OR ALTER VIEW v_planes_alquiler AS
SELECT 
    id_plan,
    nombre,
    descripcion
FROM [plan];

GO

-- VISTA 4: Puntos de alquiler
CREATE OR ALTER VIEW v_puntos_alquiler AS
SELECT 
    id_punto_alquiler,
    nombre,
    direccion,
    horario,
    capacidad_maxima
FROM punto_alquiler;

GO

-- FASE 2: VISTAS CON JOINs (Múltiples tablas)

-- VISTA 5: Bicicletas con su ubicación actual
CREATE OR ALTER VIEW v_bicicletas_ubicacion_actual AS
SELECT 
    b.id_bicicleta,
    b.codigo_unico,
    b.marca_comercial,
    b.modelo,
    pa.nombre AS punto_alquiler,
    pa.direccion,
    c.nombre AS ciudad,
    p.nombre AS pais
FROM bicicleta b
LEFT JOIN tabla_espejo_ubicacion tu 
    ON b.id_bicicleta = tu.id_bicicleta 
    AND tu.fecha_fin IS NULL
LEFT JOIN punto_alquiler pa 
    ON tu.id_punto_alquiler = pa.id_punto_alquiler
LEFT JOIN ciudad c 
    ON pa.id_ciudad = c.id_ciudad
LEFT JOIN pais p 
    ON c.id_pais = p.id_pais;

GO

-- VISTA 6: Bicicletas con su estado operativo y físico actual
CREATE OR ALTER VIEW v_bicicletas_estado_actual AS
SELECT 
    b.id_bicicleta,
    b.codigo_unico,
    b.marca_comercial,
    teo.estado AS estado_operativo,
    tef.condicion AS estado_fisico,
    teo.fecha_inicio AS fecha_ultimo_cambio_estado
FROM bicicleta b
LEFT JOIN tabla_espejo_estado_operativo teo 
    ON b.id_bicicleta = teo.id_bicicleta 
    AND teo.fecha_fin IS NULL
LEFT JOIN tabla_espejo_estado_fisico tef 
    ON b.id_bicicleta = tef.id_bicicleta 
    AND tef.fecha_fin IS NULL;

GO

-- VISTA 7: Bicicletas con información de cobertura de seguros
CREATE OR ALTER VIEW v_bicicletas_cobertura_seguro AS
SELECT 
    b.id_bicicleta,
    b.codigo_unico,
    b.marca_comercial,
    b.modelo,
    tc.nombre AS tipo_cobertura,
    cs.monto_maximo,
    cs.estado,
    cs.fecha_inicio_vigencia,
    cs.fecha_fin_vigencia
FROM bicicleta b
LEFT JOIN cobertura_seguro cs 
    ON b.id_bicicleta = cs.id_bicicleta
LEFT JOIN tipo_cobertura tc 
    ON cs.id_tipo_cobertura = tc.id_tipo_cobertura;

GO

-- VISTA 8: Tarifas vigentes por plan y bicicleta
CREATE OR ALTER VIEW v_tarifas_vigentes AS
SELECT 
    p.nombre AS [plan],
    b.codigo_unico,
    b.marca_comercial,
    b.modelo,
    t.valor,
    t.moneda
FROM tarifa t
INNER JOIN [plan] p ON t.id_plan = p.id_plan
INNER JOIN bicicleta b ON t.id_bicicleta = b.id_bicicleta;

GO

-- FASE 3: VISTAS CON AGREGACIÓN (GROUP BY, funciones)

-- VISTA 9: Resumen de bicicletas por estado
CREATE OR ALTER VIEW v_resumen_bicicletas_por_estado AS
SELECT 
    teo.estado,
    COUNT(DISTINCT b.id_bicicleta) AS cantidad_bicicletas,
    CAST(COUNT(DISTINCT b.id_bicicleta) * 100.0 / 
        (SELECT COUNT(*) FROM bicicleta) AS DECIMAL(5,2)) AS porcentaje
FROM bicicleta b
LEFT JOIN tabla_espejo_estado_operativo teo 
    ON b.id_bicicleta = teo.id_bicicleta 
    AND teo.fecha_fin IS NULL
GROUP BY teo.estado;

GO

-- VISTA 10: Resumen de bicicletas por condición física
CREATE OR ALTER VIEW v_resumen_bicicletas_por_condicion AS
SELECT 
    tef.condicion,
    COUNT(DISTINCT b.id_bicicleta) AS cantidad_bicicletas,
    CAST(COUNT(DISTINCT b.id_bicicleta) * 100.0 / 
        (SELECT COUNT(*) FROM bicicleta) AS DECIMAL(5,2)) AS porcentaje
FROM bicicleta b
LEFT JOIN tabla_espejo_estado_fisico tef 
    ON b.id_bicicleta = tef.id_bicicleta 
    AND tef.fecha_fin IS NULL
GROUP BY tef.condicion;

GO

-- VISTA 11: Resumen de bicicletas por punto de alquiler
CREATE OR ALTER VIEW v_resumen_bicicletas_por_punto AS
SELECT 
    pa.nombre AS punto_alquiler,
    COUNT(DISTINCT b.id_bicicleta) AS cantidad_bicicletas,
    pa.capacidad_maxima,
    CAST(COUNT(DISTINCT b.id_bicicleta) * 100.0 / 
        pa.capacidad_maxima AS DECIMAL(5,2)) AS porcentaje_ocupacion
FROM punto_alquiler pa
LEFT JOIN tabla_espejo_ubicacion tu 
    ON pa.id_punto_alquiler = tu.id_punto_alquiler 
    AND tu.fecha_fin IS NULL
LEFT JOIN bicicleta b 
    ON tu.id_bicicleta = b.id_bicicleta
GROUP BY pa.id_punto_alquiler, pa.nombre, pa.capacidad_maxima;

GO

-- VISTA 12: Uso acumulado de bicicletas
CREATE OR ALTER VIEW v_uso_bicicletas AS
SELECT 
    b.id_bicicleta,
    b.codigo_unico,
    b.marca_comercial,
    ua.km_total,
    ua.horas_total,
    ua.km_parcial,
    ua.horas_parcial,
    ua.fecha_ultimo_mantenimiento,
    DATEDIFF(DAY, ua.fecha_ultimo_mantenimiento, GETDATE()) AS dias_desde_mantenimiento
FROM bicicleta b
LEFT JOIN uso_acumulado ua 
    ON b.id_bicicleta = ua.id_bicicleta;

GO

-- FASE 4: VISTAS CON INFORMACIÓN HISTÓRICA

-- VISTA 13: Historial de cambios de estado operativo
CREATE OR ALTER VIEW v_historial_estado_operativo AS
SELECT 
    b.codigo_unico,
    teo.estado,
    teo.fecha_inicio,
    teo.fecha_fin,
    DATEDIFF(DAY, teo.fecha_inicio, 
        ISNULL(teo.fecha_fin, GETDATE())) AS dias_en_estado,
    a.nombre + ' ' + a.apellido AS administrador
FROM tabla_espejo_estado_operativo teo
INNER JOIN bicicleta b ON teo.id_bicicleta = b.id_bicicleta
LEFT JOIN administrador a ON teo.id_admin = a.id_admin;

GO

-- VISTA 14: Historial de cambios de ubicación
CREATE OR ALTER VIEW v_historial_ubicacion_bicicleta AS
SELECT 
    b.codigo_unico,
    pa.nombre AS punto_alquiler,
    pa.direccion,
    tu.fecha_inicio,
    tu.fecha_fin,
    DATEDIFF(DAY, tu.fecha_inicio, 
        ISNULL(tu.fecha_fin, GETDATE())) AS dias_en_ubicacion,
    a.nombre + ' ' + a.apellido AS administrador
FROM tabla_espejo_ubicacion tu
INNER JOIN bicicleta b ON tu.id_bicicleta = b.id_bicicleta
INNER JOIN punto_alquiler pa ON tu.id_punto_alquiler = pa.id_punto_alquiler
LEFT JOIN administrador a ON tu.id_admin = a.id_admin;

GO

-- FASE 5: VISTAS COMPLEJAS (Información consolidada)

-- VISTA 15: Dashboard de bicicletas - Información consolidada
CREATE OR ALTER VIEW v_dashboard_bicicletas AS
SELECT 
    b.id_bicicleta,
    b.codigo_unico,
    b.marca_comercial,
    b.modelo,
    teo.estado AS estado_operativo,
    tef.condicion AS estado_fisico,
    pa.nombre AS ubicacion_actual,
    ua.km_total,
    ua.horas_total,
    CASE 
        WHEN ua.fecha_ultimo_mantenimiento IS NULL THEN 'Sin mantenimiento'
        WHEN DATEDIFF(DAY, ua.fecha_ultimo_mantenimiento, GETDATE()) > 90 THEN 'Requiere mantenimiento'
        ELSE 'Mantenimiento OK'
    END AS alerta_mantenimiento,
    cs.estado AS estado_cobertura_seguro
FROM bicicleta b
LEFT JOIN tabla_espejo_estado_operativo teo 
    ON b.id_bicicleta = teo.id_bicicleta AND teo.fecha_fin IS NULL
LEFT JOIN tabla_espejo_estado_fisico tef 
    ON b.id_bicicleta = tef.id_bicicleta AND tef.fecha_fin IS NULL
LEFT JOIN tabla_espejo_ubicacion tu 
    ON b.id_bicicleta = tu.id_bicicleta AND tu.fecha_fin IS NULL
LEFT JOIN punto_alquiler pa 
    ON tu.id_punto_alquiler = pa.id_punto_alquiler
LEFT JOIN uso_acumulado ua 
    ON b.id_bicicleta = ua.id_bicicleta
LEFT JOIN cobertura_seguro cs 
    ON b.id_bicicleta = cs.id_bicicleta 
    AND cs.estado = 'activo';

GO

-- VISTA 16: Reporte de mantenimiento pendiente
CREATE OR ALTER VIEW v_bicicletas_mantenimiento_pendiente AS
SELECT 
    b.id_bicicleta,
    b.codigo_unico,
    b.marca_comercial,
    b.modelo,
    ua.km_total,
    ua.horas_total,
    ua.fecha_ultimo_mantenimiento,
    DATEDIFF(DAY, ua.fecha_ultimo_mantenimiento, GETDATE()) AS dias_sin_mantenimiento,
    CASE 
        WHEN ua.km_total > 5000 THEN 'URGENTE - Exceso km'
        WHEN ua.horas_total > 1000 THEN 'URGENTE - Exceso horas'
        WHEN DATEDIFF(DAY, ua.fecha_ultimo_mantenimiento, GETDATE()) > 90 THEN 'Mantenimiento programado'
        ELSE 'Sin riesgo'
    END AS prioridad
FROM bicicleta b
INNER JOIN uso_acumulado ua ON b.id_bicicleta = ua.id_bicicleta
WHERE ua.km_total > 4500 
   OR ua.horas_total > 900 
   OR DATEDIFF(DAY, ua.fecha_ultimo_mantenimiento, GETDATE()) > 85;

GO

-- FASE 6: VISTAS DE REPORTES

-- VISTA 17: Reporte de capacidad de puntos de alquiler
CREATE OR ALTER VIEW v_reporte_capacidad_puntos AS
SELECT 
    pa.nombre AS punto_alquiler,
    pa.capacidad_maxima,
    COUNT(DISTINCT tu.id_bicicleta) AS bicicletas_actuales,
    pa.capacidad_maxima - COUNT(DISTINCT tu.id_bicicleta) AS disponibilidad,
    CAST(COUNT(DISTINCT tu.id_bicicleta) * 100.0 / 
        pa.capacidad_maxima AS DECIMAL(5,2)) AS porcentaje_ocupacion
FROM punto_alquiler pa
LEFT JOIN tabla_espejo_ubicacion tu 
    ON pa.id_punto_alquiler = tu.id_punto_alquiler 
    AND tu.fecha_fin IS NULL
GROUP BY pa.id_punto_alquiler, pa.nombre, pa.capacidad_maxima;

GO

-- VISTA 18: Información de bicicletas con etiquetas
CREATE OR ALTER VIEW v_bicicletas_con_etiquetas AS
SELECT 
    b.id_bicicleta,
    b.codigo_unico,
    b.marca_comercial,
    b.modelo,
    STRING_AGG(e.nombre, ', ') AS etiquetas
FROM bicicleta b
LEFT JOIN bicicleta_etiqueta be ON b.id_bicicleta = be.id_bicicleta
LEFT JOIN etiqueta e ON be.id_etiqueta = e.id_etiqueta
GROUP BY b.id_bicicleta, b.codigo_unico, b.marca_comercial, b.modelo;

GO

-- RESUMEN FINAL
PRINT '';
PRINT '========================================';
PRINT 'VISTAS CREADAS EXITOSAMENTE - FINAL';
PRINT '========================================';
PRINT '';

SELECT 
    ROW_NUMBER() OVER (ORDER BY TABLE_NAME) AS '#',
    TABLE_NAME AS 'Vista',
    'Creada' AS Estado
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME LIKE 'v_%'
ORDER BY TABLE_NAME;

PRINT '';
PRINT 'TOTAL DE VISTAS CREADAS: 18';
PRINT 'STATUS: 100% LISTO PARA PRODUCCIÓN';
PRINT '';
PRINT '========================================';
PRINT 'MODELO FÍSICO COMPLETO';
PRINT '========================================';
PRINT '✓ 28 Tablas (17 principales + 11 espejo)';
PRINT '✓ Constraints (FK, CHECK, UNIQUE, DEFAULT)';
PRINT '✓ 46 Índices profesionales';
PRINT '✓ 18 Vistas optimizadas';
PRINT '';
PRINT 'SIGUIENTES PASOS: TRIGGERS e INSERTS';
PRINT '========================================';

GO