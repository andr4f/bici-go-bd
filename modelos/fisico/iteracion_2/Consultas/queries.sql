-- =============================================================
-- Script: 04_sample_queries_sqlserver.sql
-- Generado: 2025-10-13 05:15:43
-- Descripción:
--   Colección de consultas SQL Server sobre el esquema de bicicletas.
--   Incluye consultas operativas, analíticas, de historial y QA de datos.
-- =============================================================

SET NOCOUNT ON;
GO

/* ============================================================
   0) Parámetros reutilizables
   ============================================================ */
DECLARE @codigo_unico VARCHAR(50) = 'B-0001';
DECLARE @ciudad_nombre VARCHAR(100) = 'Bogotá';
DECLARE @punto_nombre VARCHAR(100) = 'Punto Centro';
DECLARE @plan_nombre VARCHAR(50) = 'Básico';
DECLARE @etiqueta_nombre VARCHAR(50) = 'Eco';
DECLARE @desde DATETIME = DATEADD(DAY, -7, GETDATE());
DECLARE @hasta DATETIME = GETDATE();
GO

/* ============================================================
   1) Snapshot operativo: estado, uso, asistencia, ubicación y tarifa actuales
   ============================================================ */
SELECT
    b.id_bicicleta,
    b.codigo_unico,
    b.marca_comercial,
    b.modelo,
    eo.estado              AS estado_operativo,
    ef.condicion           AS estado_fisico,
    tu.nombre_tipo_uso     AS uso_actual,
    ta.nombre_tipo_asistencia AS asistencia_actual,
    p.nombre               AS punto_alquiler,
    t.valor                AS tarifa_valor,
    t.moneda               AS tarifa_moneda,
    pl.nombre              AS plan_nombre
FROM dbo.bicicleta b
JOIN dbo.estado_operativo_actual eo      ON eo.id_bicicleta = b.id_bicicleta
JOIN dbo.estado_fisico_actual ef         ON ef.id_bicicleta = b.id_bicicleta
JOIN dbo.clasificacion_uso_actual cua    ON cua.id_bicicleta = b.id_bicicleta
JOIN dbo.tipo_uso tu                     ON tu.id_tipo_uso = cua.id_tipo_uso
JOIN dbo.clasificacion_asistencia_actual caa ON caa.id_bicicleta = b.id_bicicleta
JOIN dbo.tipo_asistencia ta              ON ta.id_tipo_asistencia = caa.id_tipo_asistencia
JOIN dbo.ubicacion_actual ua             ON ua.id_bicicleta = b.id_bicicleta
JOIN dbo.punto_alquiler p                ON p.id_punto_alquiler = ua.id_punto_alquiler
JOIN dbo.tarifa_actual t                 ON t.id_bicicleta = b.id_bicicleta
JOIN dbo.[plan] pl                       ON pl.id_plan = t.id_plan
ORDER BY b.codigo_unico;
GO

/* ============================================================
   2) Bicicletas "disponibles" por punto de alquiler (ranking)
   ============================================================ */
SELECT TOP (20)
    pa.nombre AS punto_alquiler,
    c.nombre  AS ciudad,
    COUNT(*)  AS bicis_disponibles
FROM dbo.estado_operativo_actual eo
JOIN dbo.ubicacion_actual ua   ON ua.id_bicicleta = eo.id_bicicleta
JOIN dbo.punto_alquiler pa     ON pa.id_punto_alquiler = ua.id_punto_alquiler
JOIN dbo.ciudad c              ON c.id_ciudad = pa.id_ciudad
WHERE eo.estado = 'disponible'
GROUP BY pa.nombre, c.nombre
ORDER BY COUNT(*) DESC, pa.nombre;
GO

/* ============================================================
   3) Detalle de bicicletas por ciudad (filtrable por parámetro)
   ============================================================ */
SELECT
    b.codigo_unico,
    b.marca_comercial,
    b.modelo,
    c.nombre AS ciudad,
    pa.nombre AS punto_alquiler,
    eo.estado,
    ef.condicion
FROM dbo.bicicleta b
JOIN dbo.ubicacion_actual ua ON ua.id_bicicleta = b.id_bicicleta
JOIN dbo.punto_alquiler pa   ON pa.id_punto_alquiler = ua.id_punto_alquiler
JOIN dbo.ciudad c            ON c.id_ciudad = pa.id_ciudad
JOIN dbo.estado_operativo_actual eo ON eo.id_bicicleta = b.id_bicicleta
JOIN dbo.estado_fisico_actual ef    ON ef.id_bicicleta = b.id_bicicleta
WHERE c.nombre = @ciudad_nombre
ORDER BY b.codigo_unico;
GO

/* ============================================================
   4) Último cambio de estado operativo por bicicleta (historial)
   ============================================================ */
WITH ult AS (
    SELECT
        h.id_bicicleta,
        h.estado,
        h.fecha_inicio,
        ROW_NUMBER() OVER (PARTITION BY h.id_bicicleta ORDER BY h.fecha_inicio DESC, h.id_hist DESC) AS rn
    FROM dbo.estado_operativo_hist h
)
SELECT b.codigo_unico, u.estado, u.fecha_inicio
FROM ult u
JOIN dbo.bicicleta b ON b.id_bicicleta = u.id_bicicleta
WHERE u.rn = 1
ORDER BY u.fecha_inicio DESC;
GO

/* ============================================================
   5) Evolución de estados (conteo por día) en un rango
   ============================================================ */
SELECT
    CAST(h.fecha_inicio AS DATE) AS dia,
    h.estado,
    COUNT(*) AS cambios
FROM dbo.estado_operativo_hist h
WHERE h.fecha_inicio BETWEEN @desde AND @hasta
GROUP BY CAST(h.fecha_inicio AS DATE), h.estado
ORDER BY dia DESC, h.estado;
GO

/* ============================================================
   6) Bicicletas con una etiqueta específica (actual e historial)
   ============================================================ */
-- Actual
SELECT b.codigo_unico, e.nombre AS etiqueta, bea.asignada_en
FROM dbo.bicicleta_etiqueta_actual bea
JOIN dbo.bicicleta b ON b.id_bicicleta = bea.id_bicicleta
JOIN dbo.etiqueta e  ON e.id_etiqueta = bea.id_etiqueta
WHERE e.nombre = @etiqueta_nombre
ORDER BY b.codigo_unico;

-- Historial
SELECT b.codigo_unico, e.nombre AS etiqueta, beh.fecha_asignacion, beh.fecha_eliminacion
FROM dbo.bicicleta_etiqueta_hist beh
JOIN dbo.bicicleta b ON b.id_bicicleta = beh.id_bicicleta
JOIN dbo.etiqueta e  ON e.id_etiqueta = beh.id_etiqueta
WHERE e.nombre = @etiqueta_nombre
ORDER BY beh.fecha_asignacion DESC;
GO

/* ============================================================
   7) Lista de precios vigente por plan (desde tarifa_actual)
   ============================================================ */
SELECT
    pl.nombre AS plan,
    COUNT(*) AS bicis_en_plan,
    MIN(t.valor) AS precio_min,
    MAX(t.valor) AS precio_max,
    AVG(CAST(t.valor AS DECIMAL(18,2))) AS precio_promedio
FROM dbo.tarifa_actual t
JOIN dbo.[plan] pl ON pl.id_plan = t.id_plan
GROUP BY pl.nombre
ORDER BY pl.nombre;
GO

/* ============================================================
   8) Tarifas históricas: última tarifa conocida de cada bici/plan
   ============================================================ */
WITH ult AS (
    SELECT
        th.id_bicicleta, th.id_plan, th.valor, th.moneda, th.fecha_inicio,
        ROW_NUMBER() OVER (PARTITION BY th.id_bicicleta, th.id_plan ORDER BY th.fecha_inicio DESC, th.id_hist DESC) AS rn
    FROM dbo.tarifa_hist th
)
SELECT b.codigo_unico, p.nombre AS plan, u.valor, u.moneda, u.fecha_inicio
FROM ult u
JOIN dbo.bicicleta b ON b.id_bicicleta = u.id_bicicleta
JOIN dbo.[plan] p    ON p.id_plan = u.id_plan
WHERE u.rn = 1
ORDER BY p.nombre, b.codigo_unico;
GO

/* ============================================================
   9) Carga por administrador (número de bicicletas a su cargo)
   ============================================================ */
SELECT
    a.email,
    a.nombre + ' ' + a.apellido AS admin,
    COUNT(*) AS bicicletas_asignadas
FROM dbo.bicicleta b
JOIN dbo.administrador a ON a.id_admin = b.id_admin
GROUP BY a.email, a.nombre, a.apellido
ORDER BY COUNT(*) DESC, a.email;
GO

/* ============================================================
   10) Consistencia: detectar solapamientos en historiales por bici
       (ejemplo: estado_operativo_hist)
   ============================================================ */
WITH rng AS (
    SELECT
        h.id_bicicleta,
        h.fecha_inicio,
        ISNULL(h.fecha_fin, '9999-12-31') AS fecha_fin
    FROM dbo.estado_operativo_hist h
),
overlaps AS (
    SELECT
        r1.id_bicicleta,
        r1.fecha_inicio AS ini1, r1.fecha_fin AS fin1,
        r2.fecha_inicio AS ini2, r2.fecha_fin AS fin2
    FROM rng r1
    JOIN rng r2
      ON r1.id_bicicleta = r2.id_bicicleta
     AND r1.fecha_inicio < r2.fecha_fin
     AND r2.fecha_inicio < r1.fecha_fin
     AND NOT (r1.fecha_inicio = r2.fecha_inicio AND r1.fecha_fin = r2.fecha_fin)
)
SELECT b.codigo_unico, o.*
FROM overlaps o
JOIN dbo.bicicleta b ON b.id_bicicleta = o.id_bicicleta
ORDER BY b.codigo_unico, o.ini1;
GO

/* ============================================================
   11) Bicicletas disponibles en un punto específico (parámetro)
   ============================================================ */
SELECT b.codigo_unico, b.marca_comercial, b.modelo
FROM dbo.ubicacion_actual ua
JOIN dbo.punto_alquiler pa ON pa.id_punto_alquiler = ua.id_punto_alquiler
JOIN dbo.estado_operativo_actual eo ON eo.id_bicicleta = ua.id_bicicleta
JOIN dbo.bicicleta b ON b.id_bicicleta = ua.id_bicicleta
WHERE pa.nombre = @punto_nombre
  AND eo.estado = 'disponible'
ORDER BY b.codigo_unico;
GO

/* ============================================================
   12) Reporte para dashboard (por ciudad y uso)
   ============================================================ */
SELECT
    c.nombre AS ciudad,
    tu.nombre_tipo_uso AS uso,
    SUM(CASE WHEN eo.estado = 'disponible' THEN 1 ELSE 0 END) AS disponibles,
    SUM(CASE WHEN eo.estado = 'en_uso' THEN 1 ELSE 0 END)      AS en_uso,
    SUM(CASE WHEN eo.estado = 'mantenimiento' THEN 1 ELSE 0 END) AS mantenimiento,
    COUNT(*) AS total
FROM dbo.bicicleta b
JOIN dbo.clasificacion_uso_actual cua ON cua.id_bicicleta = b.id_bicicleta
JOIN dbo.tipo_uso tu                   ON tu.id_tipo_uso = cua.id_tipo_uso
JOIN dbo.ubicacion_actual ua           ON ua.id_bicicleta = b.id_bicicleta
JOIN dbo.punto_alquiler pa             ON pa.id_punto_alquiler = ua.id_punto_alquiler
JOIN dbo.ciudad c                      ON c.id_ciudad = pa.id_ciudad
JOIN dbo.estado_operativo_actual eo    ON eo.id_bicicleta = b.id_bicicleta
GROUP BY c.nombre, tu.nombre_tipo_uso
ORDER BY c.nombre, uso;
GO

/* ============================================================
   13) Query de auditoría: últimas modificaciones "actual"
   ============================================================ */
SELECT TOP (50)
    'uso_actual' AS entidad, b.codigo_unico, cua.actualizado_en AS timestamp_ref
FROM dbo.clasificacion_uso_actual cua
JOIN dbo.bicicleta b ON b.id_bicicleta = cua.id_bicicleta
UNION ALL
SELECT 'asistencia_actual', b.codigo_unico, caa.actualizado_en
FROM dbo.clasificacion_asistencia_actual caa
JOIN dbo.bicicleta b ON b.id_bicicleta = caa.id_bicicleta
UNION ALL
SELECT 'estado_operativo_actual', b.codigo_unico, eo.desde
FROM dbo.estado_operativo_actual eo
JOIN dbo.bicicleta b ON b.id_bicicleta = eo.id_bicicleta
UNION ALL
SELECT 'estado_fisico_actual', b.codigo_unico, ef.desde
FROM dbo.estado_fisico_actual ef
JOIN dbo.bicicleta b ON b.id_bicicleta = ef.id_bicicleta
UNION ALL
SELECT 'ubicacion_actual', b.codigo_unico, ua.desde
FROM dbo.ubicacion_actual ua
JOIN dbo.bicicleta b ON b.id_bicicleta = ua.id_bicicleta
ORDER BY timestamp_ref DESC;
GO

/* ============================================================
   14) Búsqueda por texto: bicicletas por marca/modelo/código
   ============================================================ */
DECLARE @q NVARCHAR(100) = '%2%'; -- ejemplo: contiene "2"
SELECT TOP (50)
    b.codigo_unico,
    b.marca_comercial,
    b.modelo,
    b.anio_fabricacion
FROM dbo.bicicleta b
WHERE b.codigo_unico LIKE @q
   OR b.marca_comercial LIKE @q
   OR b.modelo LIKE @q
ORDER BY b.codigo_unico;
GO

/* ============================================================
   15) Ver diferencias entre tarifa_actual y última tarifa_hist
   ============================================================ */
WITH last_hist AS (
    SELECT
        th.id_bicicleta, th.id_plan, th.valor, th.moneda,
        ROW_NUMBER() OVER (PARTITION BY th.id_bicicleta, th.id_plan ORDER BY th.fecha_inicio DESC, th.id_hist DESC) rn
    FROM dbo.tarifa_hist th
)
SELECT
    b.codigo_unico,
    p.nombre AS plan,
    ta.valor AS valor_actual,
    lh.valor AS ultimo_hist_valor,
    (ta.valor - lh.valor) AS delta
FROM dbo.tarifa_actual ta
JOIN dbo.bicicleta b ON b.id_bicicleta = ta.id_bicicleta
JOIN dbo.[plan] p    ON p.id_plan = ta.id_plan
LEFT JOIN last_hist lh ON lh.id_bicicleta = ta.id_bicicleta AND lh.id_plan = ta.id_plan AND lh.rn = 1
ORDER BY p.nombre, b.codigo_unico;
GO

/* ============================================================
   16) Integridad: vigentes duplicados en tablas *_actual
   ============================================================ */
-- Debe ser 1 por bicicleta (o 1 por llave compuesta)
SELECT 'clasificacion_uso_actual' AS tabla, b.codigo_unico, COUNT(*) AS filas
FROM dbo.clasificacion_uso_actual a
JOIN dbo.bicicleta b ON b.id_bicicleta = a.id_bicicleta
GROUP BY b.codigo_unico HAVING COUNT(*) <> 1
UNION ALL
SELECT 'clasificacion_asistencia_actual', b.codigo_unico, COUNT(*)
FROM dbo.clasificacion_asistencia_actual a
JOIN dbo.bicicleta b ON b.id_bicicleta = a.id_bicicleta
GROUP BY b.codigo_unico HAVING COUNT(*) <> 1
UNION ALL
SELECT 'estado_operativo_actual', b.codigo_unico, COUNT(*)
FROM dbo.estado_operativo_actual a
JOIN dbo.bicicleta b ON b.id_bicicleta = a.id_bicicleta
GROUP BY b.codigo_unico HAVING COUNT(*) <> 1
UNION ALL
SELECT 'estado_fisico_actual', b.codigo_unico, COUNT(*)
FROM dbo.estado_fisico_actual a
JOIN dbo.bicicleta b ON b.id_bicicleta = a.id_bicicleta
GROUP BY b.codigo_unico HAVING COUNT(*) <> 1
UNION ALL
SELECT 'ubicacion_actual', b.codigo_unico, COUNT(*)
FROM dbo.ubicacion_actual a
JOIN dbo.bicicleta b ON b.id_bicicleta = a.id_bicicleta
GROUP BY b.codigo_unico HAVING COUNT(*) <> 1;
GO

/* ============================================================
   17) Bicicletas por país/ciudad (encadenando pais -> ciudad -> punto)
   ============================================================ */
SELECT
    pa.nombre AS pais,
    c.nombre AS ciudad,
    COUNT(DISTINCT b.id_bicicleta) AS bicicletas
FROM dbo.bicicleta b
JOIN dbo.ubicacion_actual ua ON ua.id_bicicleta = b.id_bicicleta
JOIN dbo.punto_alquiler pto  ON pto.id_punto_alquiler = ua.id_punto_alquiler
JOIN dbo.ciudad c            ON c.id_ciudad = pto.id_ciudad
JOIN dbo.pais pa             ON pa.id_pais = c.id_pais
GROUP BY pa.nombre, c.nombre
ORDER BY pa.nombre, c.nombre;
GO

/* ============================================================
   18) Detalle por bicicleta (parámetro @codigo_unico)
   ============================================================ */
SELECT
    b.codigo_unico,
    b.marca_comercial,
    b.modelo,
    eo.estado,
    ef.condicion,
    tu.nombre_tipo_uso,
    ta.nombre_tipo_asistencia,
    p.nombre AS punto_alquiler,
    pl.nombre AS plan,
    t.valor  AS tarifa_valor,
    t.moneda AS tarifa_moneda
FROM dbo.bicicleta b
LEFT JOIN dbo.estado_operativo_actual eo ON eo.id_bicicleta = b.id_bicicleta
LEFT JOIN dbo.estado_fisico_actual ef    ON ef.id_bicicleta = b.id_bicicleta
LEFT JOIN dbo.clasificacion_uso_actual cua ON cua.id_bicicleta = b.id_bicicleta
LEFT JOIN dbo.tipo_uso tu                 ON tu.id_tipo_uso = cua.id_tipo_uso
LEFT JOIN dbo.clasificacion_asistencia_actual caa ON caa.id_bicicleta = b.id_bicicleta
LEFT JOIN dbo.tipo_asistencia ta          ON ta.id_tipo_asistencia = caa.id_tipo_asistencia
LEFT JOIN dbo.ubicacion_actual ua         ON ua.id_bicicleta = b.id_bicicleta
LEFT JOIN dbo.punto_alquiler p            ON p.id_punto_alquiler = ua.id_punto_alquiler
LEFT JOIN dbo.tarifa_actual t             ON t.id_bicicleta = b.id_bicicleta
LEFT JOIN dbo.[plan] pl                   ON pl.id_plan = t.id_plan
WHERE b.codigo_unico = @codigo_unico;
GO
