-- 1) Catálogo: listar tipos de uso y asistencia
SELECT * FROM dbo.tipo_uso ORDER BY nombre_tipo_uso;
SELECT * FROM dbo.tipo_asistencia ORDER BY nombre_tipo_asistencia;

-- 2) Listar todas las bicicletas con su info básica y catálogos
SELECT b.id_bicicleta, b.marca_comercial, b.modelo, b.anio_fabricacion, b.tamano_marco,
       tu.nombre_tipo_uso, ta.nombre_tipo_asistencia,
       a.nombre + ' ' + a.apellido AS admin_registro, b.fecha_registro
FROM dbo.bicicleta b
JOIN dbo.tipo_uso tu           ON tu.id_tipo_uso = b.id_tipo_uso
JOIN dbo.tipo_asistencia ta    ON ta.id_tipo_asistencia = b.id_tipo_asistencia
JOIN dbo.administrador a       ON a.id_admin = b.id_admin
ORDER BY b.id_bicicleta;

-- 3) Buscar bicicletas por marca y modelo (parcial, case-insensitive según collation)
DECLARE @marca VARCHAR(100) = 'trek', @modelo VARCHAR(100) = 'fx';
SELECT id_bicicleta, marca_comercial, modelo, anio_fabricacion, tamano_marco
FROM dbo.bicicleta
WHERE marca_comercial LIKE '%' + @marca + '%'
  AND modelo          LIKE '%' + @modelo + '%'
ORDER BY id_bicicleta;

-- 4) Filtrar bicicletas por tipo de uso + tipo de asistencia
DECLARE @uso VARCHAR(50) = 'Urbano', @asist VARCHAR(50) = 'Manual';
SELECT b.id_bicicleta, b.marca_comercial, b.modelo
FROM dbo.bicicleta b
JOIN dbo.tipo_uso tu        ON tu.id_tipo_uso = b.id_tipo_uso
JOIN dbo.tipo_asistencia ta ON ta.id_tipo_asistencia = b.id_tipo_asistencia
WHERE tu.nombre_tipo_uso = @uso
  AND ta.nombre_tipo_asistencia = @asist
ORDER BY b.id_bicicleta;

-- 5) Último estado operativo y físico por bicicleta (según fecha/hora)
;WITH ult_op AS (
  SELECT eo.id_bicicleta, eo.estado,
         ROW_NUMBER() OVER (PARTITION BY eo.id_bicicleta ORDER BY eo.fecha DESC, eo.hora DESC) AS rn
  FROM dbo.estado_operativo eo
),
ult_fis AS (
  SELECT ef.id_bicicleta, ef.condicion,
         ROW_NUMBER() OVER (PARTITION BY ef.id_bicicleta ORDER BY ef.fecha DESC, ef.hora DESC) AS rn
  FROM dbo.estado_fisico ef
)
SELECT b.id_bicicleta, b.marca_comercial, b.modelo,
       uo.estado  AS estado_operativo_actual,
       uf.condicion AS condicion_fisica_actual
FROM dbo.bicicleta b
LEFT JOIN ult_op uo ON uo.id_bicicleta = b.id_bicicleta AND uo.rn = 1
LEFT JOIN ult_fis uf ON uf.id_bicicleta = b.id_bicicleta AND uf.rn = 1
ORDER BY b.id_bicicleta;

-- 6) Bicicletas actualmente DISPONIBLES (según último estado operativo)
;WITH ult_op AS (
  SELECT eo.id_bicicleta, eo.estado,
         ROW_NUMBER() OVER (PARTITION BY eo.id_bicicleta ORDER BY eo.fecha DESC, eo.hora DESC) AS rn
  FROM dbo.estado_operativo eo
)
SELECT b.id_bicicleta, b.marca_comercial, b.modelo
FROM dbo.bicicleta b
JOIN ult_op uo ON uo.id_bicicleta = b.id_bicicleta AND uo.rn = 1
WHERE uo.estado = 'disponible'
ORDER BY b.id_bicicleta;

-- 7) Conteo de bicicletas por estado operativo ACTUAL
;WITH ult_op AS (
  SELECT eo.id_bicicleta, eo.estado,
         ROW_NUMBER() OVER (PARTITION BY eo.id_bicicleta ORDER BY eo.fecha DESC, eo.hora DESC) AS rn
  FROM dbo.estado_operativo eo
)
SELECT uo.estado, COUNT(*) AS cantidad
FROM ult_op uo
WHERE uo.rn = 1
GROUP BY uo.estado
ORDER BY cantidad DESC;

-- 8) Historial de estados (operativo y físico) para una bicicleta
DECLARE @idBici INT = 1;
SELECT 'OPERATIVO' AS tipo, fecha, hora, estado AS valor
FROM dbo.estado_operativo
WHERE id_bicicleta = @idBici
UNION ALL
SELECT 'FISICO', fecha, hora, condicion
FROM dbo.estado_fisico
WHERE id_bicicleta = @idBici
ORDER BY fecha DESC, hora DESC;

-- 9) Bicicletas con condición física vigente 'requiere_revision' (según último físico)
;WITH ult_fis AS (
  SELECT ef.id_bicicleta, ef.condicion,
         ROW_NUMBER() OVER (PARTITION BY ef.id_bicicleta ORDER BY ef.fecha DESC, ef.hora DESC) AS rn
  FROM dbo.estado_fisico ef
)
SELECT b.id_bicicleta, b.marca_comercial, b.modelo
FROM dbo.bicicleta b
JOIN ult_fis uf ON uf.id_bicicleta = b.id_bicicleta AND uf.rn = 1
WHERE uf.condicion = 'requiere_revision'
ORDER BY b.id_bicicleta;

-- 10) Reporte: bicicletas registradas por periodo (rango de fechas)
DECLARE @desde DATE = '2025-01-01', @hasta DATE = '2025-12-31';
SELECT COUNT(*) AS total, MIN(fecha_registro) AS primer_registro, MAX(fecha_registro) AS ultimo_registro
FROM dbo.bicicleta
WHERE fecha_registro BETWEEN @desde AND @hasta;

-- 11) Bicicletas por administrador (con últimos estados)
;WITH ult_op AS (
  SELECT eo.id_bicicleta, eo.estado,
         ROW_NUMBER() OVER (PARTITION BY eo.id_bicicleta ORDER BY eo.fecha DESC, eo.hora DESC) AS rn
  FROM dbo.estado_operativo eo
),
ult_fis AS (
  SELECT ef.id_bicicleta, ef.condicion,
         ROW_NUMBER() OVER (PARTITION BY ef.id_bicicleta ORDER BY ef.fecha DESC, ef.hora DESC) AS rn
  FROM dbo.estado_fisico ef
)
SELECT a.id_admin, a.nombre + ' ' + a.apellido AS admin,
       b.id_bicicleta, b.marca_comercial, b.modelo,
       uo.estado AS estado_operativo, uf.condicion AS estado_fisico
FROM dbo.administrador a
JOIN dbo.bicicleta b ON b.id_admin = a.id_admin
LEFT JOIN ult_op uo ON uo.id_bicicleta = b.id_bicicleta AND uo.rn = 1
LEFT JOIN ult_fis uf ON uf.id_bicicleta = b.id_bicicleta AND uf.rn = 1
ORDER BY a.id_admin, b.id_bicicleta;