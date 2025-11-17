-- ============================================================================
-- VISTAS FORMATEADAS CORRECTAMENTE CON GO
-- ============================================================================
-- Nota: GO cierra el batch, permitiendo que CREATE OR ALTER VIEW sea la 
-- primera instrucción del siguiente batch
-- ============================================================================

-- 1. Inventario completo de bicicletas con características
CREATE OR ALTER VIEW v_inventario_bicicletas AS
SELECT 
    b.id_bicicleta,
    b.codigo_unico,
    b.marca_comercial,
    b.modelo,
    b.anio_fabricacion,
    b.tamano_marco,

    tu.nombre AS tipo_uso,
    ta.nombre AS tipo_asistencia,
    eo.nombre_estado AS estado_operativo,
    ef.condicion AS estado_fisico,

    pa.nombre AS punto_alquiler,
    c.nombre AS ciudad,

    STRING_AGG(e.nombre, ', ') WITHIN GROUP (ORDER BY e.nombre) AS etiquetas,
    COUNT(DISTINCT cs.id_cobertura) AS seguros_activos,

    b.fecha_registro
FROM bicicleta b
JOIN tipo_uso tu ON b.id_tipo_uso = tu.id_tipo_uso
JOIN tipo_asistencia ta ON b.id_tipo_asistencia = ta.id_tipo_asistencia
JOIN estado_operativo eo ON b.id_estado_operativo = eo.id_estado_operativo
JOIN estado_fisico ef ON b.id_estado_fisico = ef.id_estado_fisico
JOIN punto_alquiler pa ON b.id_punto_alquiler = pa.id_punto_alquiler
JOIN ciudad c ON pa.id_ciudad = c.id_ciudad
LEFT JOIN bicicleta_etiqueta be ON b.id_bicicleta = be.id_bicicleta AND be.fecha_eliminacion IS NULL
LEFT JOIN etiqueta e ON be.id_etiqueta = e.id_etiqueta
LEFT JOIN cobertura_seguro cs ON b.id_bicicleta = cs.id_bicicleta AND cs.estado = 'activo'
GROUP BY 
    b.id_bicicleta, b.codigo_unico, b.marca_comercial, b.modelo,
    b.anio_fabricacion, b.tamano_marco, tu.nombre, ta.nombre,
    eo.nombre_estado, ef.condicion, pa.nombre, c.nombre, b.fecha_registro;
GO

SELECT * FROM v_inventario_bicicletas;
GO

---

-- 2. Calendario operativo de puntos de alquiler
CREATE OR ALTER VIEW v_horario_completo_punto AS
SELECT
    pa.id_punto_alquiler,
    pa.nombre AS punto,
    ddh.dia_semana,
    ddh.estado,
    ddh.hora_apertura,
    ddh.hora_cierre,
    (SELECT TOP 1 fecha_excepcion FROM excepcion_horario 
     WHERE id_punto_alquiler = pa.id_punto_alquiler ORDER BY fecha_excepcion DESC) AS fecha_excepcion,
    (SELECT TOP 1 tipo_excepcion FROM excepcion_horario 
     WHERE id_punto_alquiler = pa.id_punto_alquiler ORDER BY fecha_excepcion DESC) AS tipo_excepcion
FROM punto_alquiler pa
LEFT JOIN detalle_dia_horario ddh ON pa.id_punto_alquiler = ddh.id_punto_alquiler;
GO

SELECT * FROM v_horario_completo_punto;
GO

---

-- 3. Reservas Completas con desglose económico
CREATE OR ALTER VIEW v_reservas_completas AS
SELECT 
    r.id_reserva,
    r.fecha_reserva,
    c.id_cliente,
    p.nombre + ' ' + p.apellido AS cliente,
    r.estado,

    SUM(COALESCE(da.subtotal, 0)) AS subtotal_items,
    SUM(COALESCE(da.iva_total, 0)) AS iva_items,
    SUM(COALESCE(da.total_item, 0)) AS total_items,

    COALESCE(r.descuento_total, 0) AS descuento_total,
    COALESCE(r.total_general, 0) AS total_general,
    r.id_ruta,
    COALESCE(rt.nombre, 'Sin ruta') AS ruta,

    r.id_guia,
    COALESCE(g.numero_licencia, 'N/A') AS guia_licencia
FROM reserva r
JOIN cliente c ON r.id_cliente = c.id_cliente
LEFT JOIN persona p ON c.id_cliente = p.id_persona
LEFT JOIN detalle_alquiler da ON r.id_reserva = da.id_reserva
LEFT JOIN ruta_turistica rt ON r.id_ruta = rt.id_ruta
LEFT JOIN guia_turistico g ON r.id_guia = g.id_guia
GROUP BY 
    r.id_reserva, r.fecha_reserva, c.id_cliente, p.nombre, p.apellido,
    r.estado, r.descuento_total, r.total_general, r.id_ruta, rt.nombre,
    r.id_guia, g.numero_licencia;
GO

SELECT * FROM v_reservas_completas;
GO
CREATE OR ALTER VIEW v_guias_detalle AS
SELECT 
    g.id_guia,
    COALESCE(p.nombre + ' ' + p.apellido, 'Guía ' + CAST(g.id_guia AS VARCHAR(10))) AS guia,
    g.numero_licencia,
    g.estado,

    -- Idiomas (únicos)
    COALESCE(
        (SELECT STRING_AGG(x.nombre, ', ')
         FROM (
             SELECT DISTINCT i2.nombre
             FROM guia_idioma gi2
             JOIN idioma i2 ON gi2.id_idioma = i2.id_idioma
             WHERE gi2.id_guia = g.id_guia
               AND gi2.estado = 'activo'
         ) x),
        'Sin idiomas'
    ) AS idiomas,

    -- Rutas (únicas)
    COALESCE(
        (SELECT STRING_AGG(x.nombre, ', ')
         FROM (
             SELECT DISTINCT r2.nombre
             FROM guia_ruta gr2
             JOIN ruta_turistica r2 ON gr2.id_ruta = r2.id_ruta
             WHERE gr2.id_guia = g.id_guia
               AND gr2.estado IN ('activo', 'suspendido')
         ) x),
        'Sin rutas'
    ) AS rutas

FROM guia_turistico g
LEFT JOIN persona p ON g.id_guia = p.id_persona;
GO
SELECT * FROM v_guias_detalle;
GO

---

-- 5. Listado completo de tarifas con sus descripciones
CREATE OR ALTER VIEW v_tarifas_completas AS
SELECT 
    t.id_tarifa,
    t.tarifa_base,
    t.tarifa_final,
    p.nombre AS plan_nombre,
    p.tipo_duracion,
    p.politica_cancelacion,
    p.politica_reembolso,
    pa.nombre AS pais,
    pa.moneda_oficial,
    tu.nombre AS tipo_uso,
    ta.nombre AS tipo_asistencia,
    t.id_admin,
    COALESCE(per.nombre + ' ' + per.apellido, 'N/A') AS creado_por
FROM tarifa t
JOIN [plan] p ON t.id_plan = p.id_plan
JOIN pais pa ON t.id_pais = pa.id_pais
JOIN tipo_uso tu ON t.id_tipo_uso = tu.id_tipo_uso
JOIN tipo_asistencia ta ON t.id_tipo_asistencia = ta.id_tipo_asistencia
LEFT JOIN administrador a ON t.id_admin = a.id_admin
LEFT JOIN persona per ON a.id_admin = per.id_persona;
GO

SELECT * FROM v_tarifas_completas;
GO

---

-- 6. Métodos de pago usado en tarifas completas
CREATE OR ALTER VIEW v_metodos_pago_uso AS
SELECT
    mp.nombre AS metodo_pago,
    COUNT(r.id_reserva) AS total_reservas,
    SUM(COALESCE(r.total_general, 0)) AS total_facturado
FROM metodo_de_pago mp
LEFT JOIN reserva r ON mp.id_metodo_de_pago = r.id_metodo_de_pago
GROUP BY mp.nombre;
GO

SELECT * FROM v_metodos_pago_uso;
GO

---

-- 7. Rutas con calificación y popularidad
CREATE OR ALTER VIEW v_rutas_ranking AS
SELECT 
    rt.id_ruta,
    rt.nombre,
    rt.nivel_dificultad,
    rt.distancia_total,
    rt.duracion_estimada,
    rt.tipo_terreno,
    rt.estado,
    rt.total_resenas,
    rt.calificacion_promedio,
    COUNT(DISTINCT r.id_reserva) AS total_reservas,
    COUNT(DISTINCT r.id_cliente) AS clientes_unicos,
    COUNT(CASE WHEN r.fecha_reserva >= DATEADD(DAY, -30, GETDATE()) THEN 1 END) AS reservas_ultimo_mes,
    SUM(COALESCE(r.total_general, 0)) AS ingreso_total,
    AVG(COALESCE(r.total_general, 0)) AS ticket_promedio,
    COUNT(DISTINCT gr.id_guia) AS guias_disponibles
FROM ruta_turistica rt
LEFT JOIN reserva r ON rt.id_ruta = r.id_ruta
LEFT JOIN guia_ruta gr ON rt.id_ruta = gr.id_ruta AND gr.estado = 'activo'
GROUP BY 
    rt.id_ruta, rt.nombre, rt.nivel_dificultad, rt.distancia_total,
    rt.duracion_estimada, rt.tipo_terreno, rt.estado, 
    rt.total_resenas, rt.calificacion_promedio;
GO

SELECT * FROM v_rutas_ranking;
GO

---

-- 8. Rentabilidad por ruta
CREATE OR ALTER VIEW v_rutas_rentabilidad AS
SELECT
    rt.id_ruta,
    rt.nombre AS ruta,
    COUNT(r.id_reserva) AS total_reservas,
    SUM(COALESCE(r.total_general, 0)) AS ingresos_totales,
    AVG(COALESCE(r.total_general, 0)) AS ingreso_promedio_reserva
FROM ruta_turistica rt
LEFT JOIN reserva r ON rt.id_ruta = r.id_ruta
GROUP BY rt.id_ruta, rt.nombre;
GO

SELECT * FROM v_rutas_rentabilidad;
GO

---

-- 9. Clientes frecuentes (Clasificación)
CREATE OR ALTER VIEW v_clientes_frecuentes AS
SELECT
    c.id_cliente,
    p.nombre + ' ' + p.apellido AS cliente,
    COUNT(r.id_reserva) AS reservas_realizadas,
    SUM(COALESCE(r.total_general, 0)) AS total_gastado,
    CASE
        WHEN COUNT(r.id_reserva) >= 50 THEN 'PLATINUM'
        WHEN COUNT(r.id_reserva) >= 20 THEN 'GOLD'
        WHEN COUNT(r.id_reserva) >= 5 THEN 'SILVER'
        ELSE 'BRONZE'
    END AS categoria
FROM cliente c
JOIN persona p ON c.id_cliente = p.id_persona
LEFT JOIN reserva r ON c.id_cliente = r.id_cliente
GROUP BY c.id_cliente, p.nombre, p.apellido;
GO

SELECT * FROM v_clientes_frecuentes;
GO

---

-- 10. Guías con mayor ingreso generado
CREATE OR ALTER VIEW v_guias_ingresos AS
SELECT
    g.id_guia,
    per.nombre + ' ' + per.apellido AS guia,
    COUNT(r.id_reserva) AS reservas_guiadas,
    SUM(COALESCE(r.tarifa_guia, 0)) AS ingreso_por_guias
FROM guia_turistico g
JOIN persona per ON g.id_guia = per.id_persona
LEFT JOIN reserva r ON g.id_guia = r.id_guia
GROUP BY g.id_guia, per.nombre, per.apellido;
GO

SELECT * FROM v_guias_ingresos;
GO

---

-- 11. Disponibilidad de bicicletas por punto
CREATE OR ALTER VIEW v_disponibilidad_bicicletas AS
SELECT
    pa.nombre AS punto,
    COUNT(b.id_bicicleta) AS total,
    SUM(CASE WHEN eo.nombre_estado = 'disponible' THEN 1 ELSE 0 END) AS disponibles,
    SUM(CASE WHEN eo.nombre_estado = 'en alquiler' THEN 1 ELSE 0 END) AS en_alquiler,
    SUM(CASE WHEN eo.nombre_estado = 'en mantenimiento' THEN 1 ELSE 0 END) AS mantenimiento
FROM punto_alquiler pa
LEFT JOIN bicicleta b ON pa.id_punto_alquiler = b.id_punto_alquiler
LEFT JOIN estado_operativo eo ON b.id_estado_operativo = eo.id_estado_operativo
GROUP BY pa.nombre;
GO

SELECT * FROM v_disponibilidad_bicicletas;
GO

---

-- 12. Clientes con reservas activas hoy
CREATE OR ALTER VIEW v_reservas_hoy AS
SELECT
    r.id_reserva,
    c.id_cliente,
    p.nombre + ' ' + p.apellido AS cliente,
    r.fecha_inicio,
    r.fecha_fin,
    r.total_general
FROM reserva r
JOIN cliente c ON r.id_cliente = c.id_cliente
JOIN persona p ON c.id_cliente = p.id_persona
WHERE CAST(GETDATE() AS DATE) BETWEEN CAST(r.fecha_inicio AS DATE) AND CAST(r.fecha_fin AS DATE);
GO

SELECT * FROM v_reservas_hoy;
GO

---

-- 13. Países con su moneda y cantidad de tarifas asociadas
CREATE OR ALTER VIEW v_paises_tarifas AS
SELECT
    pa.id_pais,
    pa.nombre AS pais,
    pa.moneda_oficial,
    COUNT(t.id_tarifa) AS tarifas_asociadas
FROM pais pa
LEFT JOIN tarifa t ON pa.id_pais = t.id_pais
GROUP BY pa.id_pais, pa.nombre, pa.moneda_oficial;
GO

SELECT * FROM v_paises_tarifas;
GO

---

-- 14. Información completa de puntos de alquiler
CREATE OR ALTER VIEW v_puntos_detallados AS
SELECT
    pa.id_punto_alquiler,
    pa.nombre,
    pa.direccion,
    COALESCE(c.capacidad_total, 0) AS capacidad_total,
    COUNT(b.id_bicicleta) AS bicicletas_actuales
FROM punto_alquiler pa
LEFT JOIN capacidad c ON pa.id_punto_alquiler = c.id_punto_alquiler
LEFT JOIN bicicleta b ON pa.id_punto_alquiler = b.id_punto_alquiler
GROUP BY pa.id_punto_alquiler, pa.nombre, pa.direccion, c.capacidad_total;
GO

SELECT * FROM v_puntos_detallados;
GO

---

-- 15. Personas clasificadas por rol
CREATE OR ALTER VIEW v_personas_roles AS
SELECT
    p.id_persona,
    p.nombre,
    p.apellido,
    CASE 
        WHEN c.id_cliente IS NOT NULL THEN 'CLIENTE'
        WHEN g.id_guia IS NOT NULL THEN 'GUIA'
        WHEN a.id_admin IS NOT NULL THEN 'ADMINISTRADOR'
        ELSE 'DESCONOCIDO'
    END AS rol
FROM persona p
LEFT JOIN cliente c ON p.id_persona = c.id_cliente
LEFT JOIN guia_turistico g ON p.id_persona = g.id_guia
LEFT JOIN administrador a ON p.id_persona = a.id_admin;
GO

SELECT * FROM v_personas_roles;
GO

---

-- 16. Desglose detallado de facturación por período
CREATE OR ALTER VIEW v_facturacion_mensual AS
SELECT 
    YEAR(r.fecha_reserva) AS anio,
    MONTH(r.fecha_reserva) AS mes,
    DATENAME(MONTH, r.fecha_reserva) AS mes_nombre,
    COUNT(r.id_reserva) AS total_reservas,
    SUM(r.subtotal_general) AS subtotal_bruto,
    SUM(r.descuento_total) AS descuentos_aplicados,
    SUM(r.iva_total) AS iva_recaudado,
    SUM(r.total_general) AS facturacion_total,
    SUM(CASE WHEN r.id_ruta IS NOT NULL THEN r.total_general ELSE 0 END) AS ingreso_tours,
    SUM(CASE WHEN r.id_ruta IS NULL THEN r.total_general ELSE 0 END) AS ingreso_alquileres,
    AVG(r.total_general) AS ticket_promedio
FROM reserva r
WHERE r.estado IN ('confirmada', 'completada')
GROUP BY YEAR(r.fecha_reserva), MONTH(r.fecha_reserva), DATENAME(MONTH, r.fecha_reserva);
GO

SELECT * FROM v_facturacion_mensual;
GO

---

-- 17. Ocupación de puntos en tiempo real
CREATE OR ALTER VIEW v_ocupacion_puntos AS
SELECT 
    pa.id_punto_alquiler,
    pa.nombre AS punto,
    COALESCE(c.capacidad_total, 0) AS capacidad_total,
    COUNT(b.id_bicicleta) AS bicicletas_totales,
    SUM(CASE WHEN eo.nombre_estado = 'disponible' THEN 1 ELSE 0 END) AS disponibles,
    SUM(CASE WHEN eo.nombre_estado = 'en alquiler' THEN 1 ELSE 0 END) AS en_alquiler,
    SUM(CASE WHEN eo.nombre_estado = 'en mantenimiento' THEN 1 ELSE 0 END) AS mantenimiento,
    CAST((SUM(CASE WHEN eo.nombre_estado = 'en alquiler' THEN 1 ELSE 0 END) * 100.0 / 
          NULLIF(COUNT(b.id_bicicleta), 0)) AS DECIMAL(5,2)) AS porcentaje_ocupacion,
    COALESCE(c.capacidad_total, 0) - COUNT(b.id_bicicleta) AS espacios_libres,
    CASE 
        WHEN COUNT(b.id_bicicleta) >= c.capacidad_total THEN 'LLENO'
        WHEN COUNT(b.id_bicicleta) >= c.capacidad_total * 0.9 THEN 'CASI_LLENO'
        ELSE 'DISPONIBLE'
    END AS estado_capacidad
FROM punto_alquiler pa
LEFT JOIN capacidad c ON pa.id_punto_alquiler = c.id_punto_alquiler
LEFT JOIN bicicleta b ON pa.id_punto_alquiler = b.id_punto_alquiler
LEFT JOIN estado_operativo eo ON b.id_estado_operativo = eo.id_estado_operativo
GROUP BY pa.id_punto_alquiler, pa.nombre, c.capacidad_total;
GO

SELECT * FROM v_ocupacion_puntos;
GO

---

-- 18. Historial de alquileres por cliente
CREATE OR ALTER VIEW v_clientes_historial AS
SELECT 
    c.id_cliente,
    p.nombre + ' ' + p.apellido AS cliente,
    p.email,
    p.telefono,
    COUNT(DISTINCT r.id_reserva) AS total_reservas,
    COUNT(DISTINCT da.id_bicicleta) AS bicicletas_diferentes,
    COUNT(DISTINCT r.id_ruta) AS rutas_realizadas,
    MIN(r.fecha_reserva) AS primera_reserva,
    MAX(r.fecha_reserva) AS ultima_reserva,
    DATEDIFF(DAY, MAX(r.fecha_reserva), GETDATE()) AS dias_inactivo,
    SUM(COALESCE(r.total_general, 0)) AS gasto_total,
    AVG(COALESCE(r.total_general, 0)) AS gasto_promedio,
    (SELECT TOP 1 tu.nombre 
     FROM detalle_alquiler da2
     JOIN bicicleta b ON da2.id_bicicleta = b.id_bicicleta
     JOIN tipo_uso tu ON b.id_tipo_uso = tu.id_tipo_uso
     WHERE da2.id_reserva IN (SELECT id_reserva FROM reserva WHERE id_cliente = c.id_cliente)
     GROUP BY tu.nombre
     ORDER BY COUNT(*) DESC) AS tipo_uso_preferido
FROM cliente c
JOIN persona p ON c.id_cliente = p.id_persona
LEFT JOIN reserva r ON c.id_cliente = r.id_cliente
LEFT JOIN detalle_alquiler da ON r.id_reserva = da.id_reserva
GROUP BY c.id_cliente, p.nombre, p.apellido, p.email, p.telefono;
GO

SELECT * FROM v_clientes_historial;
GO

---

-- 19. Vista maestra: Todas las fotos con su contexto
CREATE OR ALTER VIEW v_galeria_completa AS
SELECT 
    f.id_fotografia,
    f.nombre_archivo,
    f.ruta_archivo,
    f.formato,
    f.ancho_px,
    f.alto_px,
    f.es_principal,
    f.orden,
    f.descripcion,
    f.estado,
    f.fecha_hora_carga,
    f.tipo_fotografia,
    CASE 
        WHEN f.tipo_fotografia = 'bicicleta' THEN 
            'Bicicleta: ' + COALESCE(b.codigo_unico, 'N/A')
        WHEN f.tipo_fotografia = 'punto_alquiler' THEN 
            'Punto: ' + COALESCE(pa.nombre, 'N/A')
        WHEN f.tipo_fotografia = 'ruta' THEN 
            'Ruta: ' + COALESCE(rt.nombre, 'N/A')
        WHEN f.tipo_fotografia = 'resenia' THEN 
            'Reseña de: ' + COALESCE(p.nombre, 'N/A')
        ELSE 'Sin contexto'
    END AS contexto,
    fb.tipo_vista AS vista_bicicleta,
    fp.tipo_vista AS vista_punto,
    fru.tipo_foto AS tipo_foto_ruta,
    fru.punto_interes,
    fru.temporada,
    fb.id_bicicleta,
    fp.id_punto_alquiler,
    fru.id_ruta,
    fres.id_resenia_ruta
FROM fotografia f
LEFT JOIN fotografia_bicicleta fb ON f.id_fotografia = fb.id_fotografia_bicicleta
LEFT JOIN bicicleta b ON fb.id_bicicleta = b.id_bicicleta
LEFT JOIN fotografia_punto fp ON f.id_fotografia = fp.id_fotografia_punto
LEFT JOIN punto_alquiler pa ON fp.id_punto_alquiler = pa.id_punto_alquiler
LEFT JOIN foto_ruta fru ON f.id_fotografia = fru.id_fotografia
LEFT JOIN ruta_turistica rt ON fru.id_ruta = rt.id_ruta
LEFT JOIN foto_resenia fres ON f.id_fotografia = fres.id_foto_resenia
LEFT JOIN resenia_ruta rr ON fres.id_resenia_ruta = rr.id_resenia_ruta
LEFT JOIN cliente cl ON rr.id_cliente = cl.id_cliente
LEFT JOIN persona p ON cl.id_cliente = p.id_persona;
GO

SELECT * FROM v_galeria_completa;
GO

---

-- 20. Bicicletas con estado de cobertura de seguros
CREATE OR ALTER VIEW v_seguros_bicicletas AS
SELECT 
    b.id_bicicleta,
    b.codigo_unico,
    b.marca_comercial,
    b.modelo,
    pa.nombre AS punto_actual,
    COUNT(cs.id_cobertura) AS total_coberturas,
    COALESCE(STRING_AGG(tc.nombre, ', ') WITHIN GROUP (ORDER BY tc.nombre), 'Sin cobertura') AS tipos_cobertura,
    COALESCE(SUM(cs.monto_maximo), 0) AS cobertura_total,
    MIN(cs.fecha_inicio_vigencia) AS vigencia_desde,
    MAX(cs.fecha_fin_vigencia) AS vigencia_hasta,
    CASE 
        WHEN COUNT(cs.id_cobertura) = 0 THEN 'SIN_SEGURO'
        WHEN MAX(cs.fecha_fin_vigencia) <= DATEADD(DAY, 30, GETDATE()) THEN 'PROXIMO_A_VENCER'
        ELSE 'VIGENTE'
    END AS estado_seguro,
    DATEDIFF(DAY, GETDATE(), MAX(cs.fecha_fin_vigencia)) AS dias_hasta_vencimiento
FROM bicicleta b
JOIN punto_alquiler pa ON b.id_punto_alquiler = pa.id_punto_alquiler
LEFT JOIN cobertura_seguro cs ON b.id_bicicleta = cs.id_bicicleta AND cs.estado = 'activo'
LEFT JOIN tipo_cobertura tc ON cs.id_tipo_cobertura = tc.id_tipo_cobertura
GROUP BY b.id_bicicleta, b.codigo_unico, b.marca_comercial, b.modelo, pa.nombre;
GO

SELECT * FROM v_seguros_bicicletas;
GO

---

-- 21. Disponibilidad granular por tipo de bicicleta
CREATE OR ALTER VIEW v_capacidad_detallada AS
SELECT 
    pa.id_punto_alquiler,
    pa.nombre AS punto,
    COALESCE(tu.nombre, 'N/A') AS tipo_uso,
    COALESCE(ta.nombre, 'N/A') AS tipo_asistencia,
    COALESCE(ct.capacidad_especifica, 0) AS capacidad_maxima,
    COUNT(b.id_bicicleta) AS bicicletas_totales,
    SUM(CASE WHEN eo.nombre_estado = 'disponible' THEN 1 ELSE 0 END) AS disponibles,
    SUM(CASE WHEN eo.nombre_estado = 'en alquiler' THEN 1 ELSE 0 END) AS alquiladas,
    SUM(CASE WHEN eo.nombre_estado = 'en mantenimiento' THEN 1 ELSE 0 END) AS mantenimiento,
    COALESCE(ct.capacidad_especifica, 0) - COUNT(b.id_bicicleta) AS espacios_libres,
    CAST(COALESCE(COUNT(b.id_bicicleta) * 100.0 / NULLIF(ct.capacidad_especifica, 0), 0) AS DECIMAL(5,2)) AS porcentaje_ocupacion,
    CASE 
        WHEN COALESCE(ct.capacidad_especifica, 0) = 0 THEN 'SIN_CAPACIDAD'
        WHEN COUNT(b.id_bicicleta) >= ct.capacidad_especifica THEN 'CAPACIDAD_MAXIMA'
        ELSE 'OPERATIVO'
    END AS estado
FROM punto_alquiler pa
LEFT JOIN capacidad_tipo ct ON pa.id_punto_alquiler = ct.id_punto_alquiler
LEFT JOIN tipo_uso tu ON ct.id_tipo_uso = tu.id_tipo_uso
LEFT JOIN tipo_asistencia ta ON ct.id_tipo_asistencia = ta.id_tipo_asistencia
LEFT JOIN bicicleta b ON pa.id_punto_alquiler = b.id_punto_alquiler
    AND b.id_tipo_uso = tu.id_tipo_uso
    AND b.id_tipo_asistencia = ta.id_tipo_asistencia
LEFT JOIN estado_operativo eo ON b.id_estado_operativo = eo.id_estado_operativo
GROUP BY pa.id_punto_alquiler, pa.nombre, tu.nombre, ta.nombre, ct.capacidad_especifica;
GO

SELECT * FROM v_capacidad_detallada;
GO

---

-- 22. Usuarios y aceptación de términos
CREATE OR ALTER VIEW v_aceptacion_terminos AS
SELECT 
    p.id_persona,
    p.nombre + ' ' + p.apellido AS persona,
    p.tipo_persona,
    p.email,
    p.fecha_aceptacion_terminos,
    COALESCE(tc.titulo, 'N/A') AS terminos_aceptados,
    COALESCE(tc.version, 0) AS version_aceptada,
    tc.fecha_inicio_vigencia AS vigencia_desde,
    tc.fecha_fin_vigencia AS vigencia_hasta,
    CASE 
        WHEN p.fecha_aceptacion_terminos IS NULL THEN 'NO_ACEPTADO'
        ELSE 'VIGENTE'
    END AS estado_aceptacion,
    DATEDIFF(DAY, COALESCE(p.fecha_aceptacion_terminos, GETDATE()), GETDATE()) AS dias_desde_aceptacion
FROM persona p
LEFT JOIN terminos_condiciones tc ON p.id_terminos_condiciones = tc.id_terminos_condiciones
WHERE p.estado = 'activo';
GO

SELECT * FROM v_aceptacion_terminos;
GO

---

-- 23. Jerarquía geográfica completa
CREATE OR ALTER VIEW v_ubicaciones_completas AS
SELECT 
    pa.id_punto_alquiler,
    pa.nombre AS punto,
    pa.direccion,
    pa.latitud AS lat_punto,
    pa.longitud AS lon_punto,
    c.id_ciudad,
    c.nombre AS ciudad,
    c.latitud AS lat_ciudad,
    c.longitud AS lon_ciudad,
    d.id_departamento,
    d.nombre AS departamento,
    p.id_pais,
    p.nombre AS pais,
    p.moneda_oficial,
    CONCAT(pa.latitud, ',', pa.longitud) AS coordenadas_punto,
    CONCAT('https://www.google.com/maps?q=', pa.latitud, ',', pa.longitud) AS url_maps,
    COALESCE(cap.capacidad_total, 0) AS capacidad_total,
    COUNT(b.id_bicicleta) AS bicicletas_actuales,
    pa.fecha_fin AS fecha_cierre,
    CASE 
        WHEN pa.fecha_fin IS NOT NULL AND pa.fecha_fin < GETDATE() THEN 'CERRADO'
        WHEN EXISTS (SELECT 1 FROM excepcion_horario 
                    WHERE id_punto_alquiler = pa.id_punto_alquiler 
                    AND fecha_excepcion = CAST(GETDATE() AS DATE)) THEN 'HORARIO_ESPECIAL'
        ELSE 'OPERATIVO'
    END AS estado_hoy
FROM punto_alquiler pa
JOIN ciudad c ON pa.id_ciudad = c.id_ciudad
JOIN departamento d ON c.id_departamento = d.id_departamento
JOIN pais p ON d.id_pais = p.id_pais
LEFT JOIN capacidad cap ON pa.id_punto_alquiler = cap.id_punto_alquiler
LEFT JOIN bicicleta b ON pa.id_punto_alquiler = b.id_punto_alquiler
GROUP BY 
    pa.id_punto_alquiler, pa.nombre, pa.direccion, pa.latitud, pa.longitud,
    c.id_ciudad, c.nombre, c.latitud, c.longitud,
    d.id_departamento, d.nombre,
    p.id_pais, p.nombre, p.moneda_oficial,
    cap.capacidad_total, pa.fecha_fin;
GO

SELECT * FROM v_ubicaciones_completas;
GO

---

PRINT '✓ Todas las 23 vistas han sido creadas exitosamente';
GO
