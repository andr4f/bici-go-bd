
-- VISTA: Bicicletas disponibles para alquiler 
CREATE OR ALTER VIEW v_bicicletas_disponibles AS
SELECT 
    b.id_bicicleta,
    b.codigo_unico AS codigo,
    b.marca_comercial AS marca,
    b.modelo,
    b.anio_fabricacion,
    b.tamano_marco AS tamaño
FROM bicicleta b
-- Excluir por el estado actual (FK en la tabla bicicleta)
INNER JOIN estado_operativo eo_actual
    ON b.id_estado_operativo = eo_actual.id_estado_operativo
WHERE eo_actual.nombre NOT IN ('en mantenimiento', 'en alquiler')
  -- Y asegurarnos de que no exista un registro vigente en el historial con esos estados
  AND NOT EXISTS (
      SELECT 1
      FROM hist_estado_operativo heo
      INNER JOIN estado_operativo eo_hist
          ON heo.id_estado_operativo = eo_hist.id_estado_operativo
      WHERE heo.id_bicicleta = b.id_bicicleta
        AND heo.fecha_fin IS NULL
        AND eo_hist.nombre IN ('en mantenimiento', 'en alquiler')
  );

select * from v_bicicletas_disponibles

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

select * from v_administradores

-- VISTA 3: Planes de alquiler disponibles
CREATE VIEW vw_planes_alquiler_disponibles AS
SELECT 
    p.id_plan,
    p.nombre AS nombre_plan,
    p.descripcion AS descripcion_plan,
    b.id_bicicleta,
    b.codigo_unico,
    b.marca_comercial,
    b.modelo,
    b.anio_fabricacion,
    b.tamano_marco,
    tu.nombre AS tipo_uso,
    ta.nombre AS tipo_asistencia,
    eo.nombre AS estado_operativo,
    ef.nombre AS estado_fisico,
    t.valor AS tarifa,
    t.moneda,
    t.fecha_inicio AS inicio_tarifa,
    t.fecha_fin AS fin_tarifa,
    ib.url_imagen AS imagen_referencia
FROM [plan] p
INNER JOIN tarifa t ON p.id_plan = t.id_plan
INNER JOIN bicicleta b ON t.id_bicicleta = b.id_bicicleta
INNER JOIN tipo_uso tu ON b.id_tipo_uso = tu.id_tipo_uso
INNER JOIN tipo_asistencia ta ON b.id_tipo_asistencia = ta.id_tipo_asistencia
INNER JOIN estado_operativo eo ON b.id_estado_operativo = eo.id_estado_operativo
INNER JOIN estado_fisico ef ON b.id_estado_fisico = ef.id_estado_fisico
LEFT JOIN imagen_bicicleta ib 
       ON b.id_bicicleta = ib.id_bicicleta AND ib.es_principal = 1
WHERE eo.nombre = 'disponible'
  AND (t.fecha_fin IS NULL OR t.fecha_fin >= CAST(GETDATE() AS DATE));

  select * from vw_planes_alquiler_disponibles

-- VISTA 4: Puntos de alquiler
CREATE OR ALTER VIEW vw_puntos_alquiler AS
SELECT 
    pa.id_punto_alquiler,
    pa.nombre,
    pa.direccion,
    c.nombre AS ciudad,
    d.nombre AS departamento
FROM punto_alquiler pa
INNER JOIN ciudad c on pa.id_ciudad = c.id_ciudad
INNER JOIN departamento d on c.id_departamento = d.id_departamento

select * from vw_puntos_alquiler


-- VISTA 5: Bicicletas con su ubicación actual
CREATE OR ALTER VIEW vw_bicicletas_ubicacion_actual AS
SELECT 
    b.id_bicicleta,
    b.codigo_unico,
    b.marca_comercial,
    b.modelo,
    pa.nombre AS punto_alquiler,
    pa.direccion,
    pa.latitud AS latitud_punto,
    pa.longitud AS longitud_punto,
    c.nombre AS ciudad,
    p.nombre AS pais
FROM bicicleta b
LEFT JOIN ubicacion u
    ON b.id_bicicleta = u.id_bicicleta
    AND u.fecha_fin IS NULL   -- Solo ubicación actual
LEFT JOIN punto_alquiler pa
    ON u.id_punto_alquiler = pa.id_punto_alquiler
LEFT JOIN ciudad c
    ON pa.id_ciudad = c.id_ciudad
LEFT JOIN departamento d
    ON c.id_departamento = d.id_departamento
LEFT JOIN pais p
    ON d.id_pais = p.id_pais;

select * from vw_bicicletas_ubicacion_actual

-- VISTA 6: Bicicletas con su estado operativo y físico actual
CREATE OR ALTER VIEW vw_bicicletas_estado_actual AS
SELECT 
    b.id_bicicleta,
    b.codigo_unico,
    b.marca_comercial,
    eo.nombre AS estado_operativo,
    ef.nombre AS estado_fisico,
    heo.fecha_inicio AS fecha_ultimo_cambio_estado
FROM bicicleta b
LEFT JOIN hist_estado_operativo heo 
    ON b.id_bicicleta = heo.id_bicicleta 
    AND heo.fecha_fin IS NULL
LEFT JOIN estado_operativo eo 
    ON heo.id_estado_operativo = eo.id_estado_operativo
LEFT JOIN hist_estado_fisico hef 
    ON b.id_bicicleta = hef.id_bicicleta 
    AND hef.fecha_fin IS NULL
LEFT JOIN estado_fisico ef 
    ON hef.id_estado_fisico = ef.id_estado_fisico;

select * from vw_bicicletas_estado_actual

-- VISTA 7: Bicicletas y información de cobertura de seguros
CREATE OR ALTER VIEW vw_bicicletas_cobertura_seguro AS
SELECT 
    b.id_bicicleta,
    b.codigo_unico,
    b.marca_comercial,
    b.modelo,
    b.anio_fabricacion,
    b.tamano_marco,
    b.fecha_registro,
    tc.nombre AS tipo_cobertura,
    tc.descripcion AS descripcion_cobertura,
    cs.monto_maximo,
    cs.estado AS estado_cobertura
FROM bicicleta b
LEFT JOIN cobertura_seguro cs 
    ON b.id_bicicleta = cs.id_bicicleta
LEFT JOIN tipo_cobertura tc 
    ON cs.id_tipo_cobertura = tc.id_tipo_cobertura;

select * from vw_bicicletas_cobertura_seguro

--VISTA 8: tarifas con vigencia e historicas
CREATE OR ALTER VIEW vw_tarifas_vigentes_e_hist AS
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
select * from vw_tarifas_vigentes_e_hist

--VISTA 9: tarifas con vigencia
CREATE OR ALTER VIEW vw_tarifas_vigentes AS
SELECT 
    p.nombre AS [plan],
    b.codigo_unico,
    b.marca_comercial,
    b.modelo,
    t.valor,
    t.moneda
FROM tarifa t
INNER JOIN [plan] p ON t.id_plan = p.id_plan
INNER JOIN bicicleta b ON t.id_bicicleta = b.id_bicicleta
WHERE 
    t.fecha_fin IS NULL OR t.fecha_fin >= CAST(GETDATE() AS DATE);

select * from vw_tarifas_vigentes

-- VISTA 10: Resumen de bicicletas por estado
CREATE OR ALTER VIEW vw_resumen_bicicletas_por_estado AS
SELECT 
    eo.nombre AS estado_operativo,
    COUNT(DISTINCT hso.id_bicicleta) AS cantidad_bicicletas,
    CAST(COUNT(DISTINCT hso.id_bicicleta) * 100.0 / 
        (SELECT COUNT(*) FROM bicicleta) AS DECIMAL(5,2)) AS porcentaje
FROM hist_estado_operativo hso
INNER JOIN estado_operativo eo 
    ON hso.id_estado_operativo = eo.id_estado_operativo
WHERE hso.fecha_fin IS NULL  -- estado vigente
GROUP BY eo.nombre;

select * from vw_resumen_bicicletas_por_estado

-- VISTA 11: Información de bicicletas con etiquetas
CREATE OR ALTER VIEW v_bicicletas_con_etiquetas AS
SELECT 
    b.id_bicicleta,
    b.codigo_unico,
    b.marca_comercial,
    b.modelo,
    STRING_AGG(e.nombre, ', ') WITHIN GROUP (ORDER BY e.nombre) AS etiquetas
FROM bicicleta AS b
LEFT JOIN bicicleta_etiqueta AS be 
    ON b.id_bicicleta = be.id_bicicleta
LEFT JOIN etiqueta AS e 
    ON be.id_etiqueta = e.id_etiqueta
GROUP BY 
    b.id_bicicleta, 
    b.codigo_unico, 
    b.marca_comercial, 
    b.modelo;


SELECT * FROM v_bicicletas_con_etiquetas

-- VISTA 12: Reporte de capacidad de puntos de alquiler
CREATE OR ALTER VIEW v_reporte_capacidad_puntos AS
SELECT 
    pa.nombre AS punto_alquiler,
    c.capacidad_total,
    COUNT(DISTINCT u.id_bicicleta) AS bicicletas_actuales,
    c.capacidad_total - COUNT(DISTINCT u.id_bicicleta) AS disponibilidad,
    CAST(
        COUNT(DISTINCT u.id_bicicleta) * 100.0 / NULLIF(c.capacidad_total, 0)
        AS DECIMAL(5,2)
    ) AS porcentaje_ocupacion
FROM punto_alquiler pa
INNER JOIN capacidad c 
    ON pa.id_punto_alquiler = c.id_punto_alquiler
LEFT JOIN ubicacion u 
    ON pa.id_punto_alquiler = u.id_punto_alquiler 
    AND u.fecha_fin IS NULL  -- bicicletas actualmente en ese punto
GROUP BY pa.nombre, c.capacidad_total;


SELECT * FROM v_reporte_capacidad_puntos

-- VISTA 13: Reporte de mantenimiento pendiente
CREATE OR ALTER VIEW v_bicicletas_mantenimiento_pendiente AS
SELECT 
    b.id_bicicleta,
    b.codigo_unico,
    b.marca_comercial,
    b.modelo,
    ua.km_total,
    ua.horas_total,
    ua.fecha_ultimo_mantenimiento,
    ISNULL(DATEDIFF(DAY, ua.fecha_ultimo_mantenimiento, GETDATE()), 9999) AS dias_sin_mantenimiento,
    CASE 
        WHEN ua.km_total > 5000 THEN 'URGENTE - Exceso km'
        WHEN ua.horas_total > 1000 THEN 'URGENTE - Exceso horas'
        WHEN ISNULL(DATEDIFF(DAY, ua.fecha_ultimo_mantenimiento, GETDATE()), 9999) > 90 THEN 'Mantenimiento programado'
        ELSE 'Sin riesgo'
    END AS prioridad
FROM bicicleta b
INNER JOIN uso_acumulado ua ON b.id_bicicleta = ua.id_bicicleta
WHERE ua.km_total > 4500 
   OR ua.horas_total > 900 
   OR ISNULL(DATEDIFF(DAY, ua.fecha_ultimo_mantenimiento, GETDATE()), 9999) > 85;


SELECT * FROM v_bicicletas_mantenimiento_pendiente


-- VISTA 14: Dashboard de bicicletas - Información consolidada
CREATE OR ALTER VIEW v_dashboard_bicicletas AS
SELECT 
    b.id_bicicleta,
    b.codigo_unico,
    b.marca_comercial,
    b.modelo,
    eo.nombre AS estado_operativo,
    ef.nombre AS estado_fisico,
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
LEFT JOIN estado_operativo eo 
    ON b.id_estado_operativo = eo.id_estado_operativo
LEFT JOIN estado_fisico ef 
    ON b.id_estado_fisico = ef.id_estado_fisico
LEFT JOIN ubicacion u 
    ON b.id_bicicleta = u.id_bicicleta AND u.fecha_fin IS NULL
LEFT JOIN punto_alquiler pa 
    ON u.id_punto_alquiler = pa.id_punto_alquiler
LEFT JOIN uso_acumulado ua 
    ON b.id_bicicleta = ua.id_bicicleta
LEFT JOIN cobertura_seguro cs 
    ON b.id_bicicleta = cs.id_bicicleta AND cs.estado = 'activo';



SELECT * FROM v_dashboard_bicicletas

-- VISTA 15: Historial de cambios de ubicación
CREATE OR ALTER VIEW v_historial_ubicacion_bicicleta AS
SELECT 
    b.codigo_unico,
    pa.nombre AS punto_alquiler,
    pa.direccion,
    u.fecha_inicio,
    u.fecha_fin,
    DATEDIFF(DAY, u.fecha_inicio, ISNULL(u.fecha_fin, GETDATE())) AS dias_en_ubicacion,
    a.nombre + ' ' + a.apellido AS administrador
FROM ubicacion u
INNER JOIN bicicleta b 
    ON u.id_bicicleta = b.id_bicicleta
INNER JOIN punto_alquiler pa 
    ON u.id_punto_alquiler = pa.id_punto_alquiler
LEFT JOIN administrador a 
    ON b.id_admin = a.id_admin;


SELECT * FROM v_historial_ubicacion_bicicleta

-- VISTA 16: Historial de cambios de estado operativo
CREATE OR ALTER VIEW v_historial_estado_operativo AS
SELECT 
    b.codigo_unico,
    eo.nombre AS estado,
    heo.fecha_inicio,
    heo.fecha_fin,
    DATEDIFF(DAY, heo.fecha_inicio, ISNULL(heo.fecha_fin, GETDATE())) AS dias_en_estado,
    a.nombre + ' ' + a.apellido AS administrador
FROM hist_estado_operativo heo
INNER JOIN bicicleta b 
    ON heo.id_bicicleta = b.id_bicicleta
INNER JOIN estado_operativo eo 
    ON heo.id_estado_operativo = eo.id_estado_operativo
LEFT JOIN administrador a 
    ON heo.id_admin = a.id_admin;



SELECT * FROM v_historial_estado_operativo


-- VISTA 17: Uso acumulado de bicicletas
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
FROM bicicleta AS b
LEFT JOIN uso_acumulado AS ua 
    ON b.id_bicicleta = ua.id_bicicleta;


SELECT * FROM v_uso_bicicletas


-- VISTA 18: Resumen de bicicletas por punto de alquiler
CREATE OR ALTER VIEW v_resumen_bicicletas_por_punto AS
SELECT 
    pa.nombre AS punto_alquiler,
    COUNT(DISTINCT b.id_bicicleta) AS cantidad_bicicletas,
    c.capacidad_total AS capacidad_maxima,
    CAST(
        COUNT(DISTINCT b.id_bicicleta) * 100.0 / 
        NULLIF(c.capacidad_total, 0)
        AS DECIMAL(5,2)
    ) AS porcentaje_ocupacion
FROM punto_alquiler pa
LEFT JOIN ubicacion u 
    ON pa.id_punto_alquiler = u.id_punto_alquiler 
    AND u.fecha_fin IS NULL
LEFT JOIN bicicleta b 
    ON u.id_bicicleta = b.id_bicicleta
LEFT JOIN capacidad c
    ON pa.id_punto_alquiler = c.id_punto_alquiler
GROUP BY pa.nombre, c.capacidad_total;



SELECT * FROM v_resumen_bicicletas_por_punto

-- VISTA 19: Resumen de bicicletas por condición física
CREATE OR ALTER VIEW v_resumen_bicicletas_por_condicion AS
SELECT 
    ef.nombre AS condicion,
    COUNT(DISTINCT b.id_bicicleta) AS cantidad_bicicletas,
    CAST(COUNT(DISTINCT b.id_bicicleta) * 100.0 /
        (SELECT COUNT(*) FROM bicicleta) AS DECIMAL(5,2)) AS porcentaje
FROM bicicleta b
LEFT JOIN hist_estado_fisico hef 
    ON b.id_bicicleta = hef.id_bicicleta 
    AND hef.fecha_fin IS NULL
LEFT JOIN estado_fisico ef 
    ON hef.id_estado_fisico = ef.id_estado_fisico
GROUP BY ef.nombre;



SELECT * FROM v_resumen_bicicletas_por_condicion