-- ============================================================
-- SISTEMA BICI-GO - MODELO FÍSICO
-- Script 03: CREACIÓN DE ÍNDICES - SQL SERVER
-- VERSIÓN CORREGIDA: Usando tabla "plan" (no plan_alquiler)
-- ============================================================

-- NOTA: Este script usa "plan" en lugar de "plan_alquiler"
-- Ejecuta DESPUÉS de [37] (tablas + constraints)

-- ============================================================
-- FASE 1: ÍNDICES NONCLUSTERED EN CLAVES NATURALES (UNIQUE)
-- ============================================================

-- Índice 1: bicicleta.codigo_unico (clave natural)
CREATE NONCLUSTERED INDEX idx_unique_bicicleta_codigo 
    ON bicicleta(codigo_unico)
    WHERE codigo_unico IS NOT NULL;

-- Índice 2: administrador.email (clave natural)
CREATE NONCLUSTERED INDEX idx_unique_admin_email 
    ON administrador(email)
    WHERE email IS NOT NULL;

-- Índice 3: plan.nombre (clave natural) - CORREGIDO
CREATE NONCLUSTERED INDEX idx_unique_plan_nombre 
    ON [plan](nombre)
    WHERE nombre IS NOT NULL;

-- Índice 4: etiqueta.nombre (clave natural)
CREATE NONCLUSTERED INDEX idx_unique_etiqueta_nombre 
    ON etiqueta(nombre)
    WHERE nombre IS NOT NULL;

-- Índice 5: tipo_cobertura.nombre (clave natural)
CREATE NONCLUSTERED INDEX idx_unique_tipo_cobertura_nombre 
    ON tipo_cobertura(nombre)
    WHERE nombre IS NOT NULL;

-- ============================================================
-- FASE 2: ÍNDICES NONCLUSTERED EN FOREIGN KEYS (para JOINs)
-- ============================================================

-- Índice 6: ciudad.id_pais (JOIN ciudad + pais)
CREATE NONCLUSTERED INDEX idx_fk_ciudad_id_pais 
    ON ciudad(id_pais);

-- Índice 7: punto_alquiler.id_ciudad (JOIN punto_alquiler + ciudad)
CREATE NONCLUSTERED INDEX idx_fk_punto_alquiler_id_ciudad 
    ON punto_alquiler(id_ciudad);

-- Índice 8: imagen_bicicleta.id_bicicleta (obtener fotos)
CREATE NONCLUSTERED INDEX idx_fk_imagen_bicicleta_id_bicicleta 
    ON imagen_bicicleta(id_bicicleta);

-- Índice 9: condiciones_especiales.id_bicicleta (obtener restricciones)
CREATE NONCLUSTERED INDEX idx_fk_condiciones_especiales_id_bicicleta 
    ON condiciones_especiales(id_bicicleta);

-- Índice 10: bicicleta_etiqueta.id_bicicleta (obtener etiquetas)
CREATE NONCLUSTERED INDEX idx_fk_bicicleta_etiqueta_id_bicicleta 
    ON bicicleta_etiqueta(id_bicicleta);

-- Índice 11: bicicleta_etiqueta.id_etiqueta (búsqueda inversa)
CREATE NONCLUSTERED INDEX idx_fk_bicicleta_etiqueta_id_etiqueta 
    ON bicicleta_etiqueta(id_etiqueta);

-- Índice 12: ubicacion.id_punto_alquiler ("¿cuántas bicicletas en punto X?")
CREATE NONCLUSTERED INDEX idx_fk_ubicacion_id_punto_alquiler 
    ON ubicacion(id_punto_alquiler);

-- Índice 13: tarifa.id_plan (obtener tarifas por plan) - CORREGIDO
CREATE NONCLUSTERED INDEX idx_fk_tarifa_id_plan 
    ON tarifa(id_plan);

-- Índice 14: tarifa.id_bicicleta (obtener tarifas por bicicleta)
CREATE NONCLUSTERED INDEX idx_fk_tarifa_id_bicicleta 
    ON tarifa(id_bicicleta);

-- Índice 15: cobertura_seguro.id_bicicleta (obtener coberturas)
CREATE NONCLUSTERED INDEX idx_fk_cobertura_seguro_id_bicicleta 
    ON cobertura_seguro(id_bicicleta);

-- ============================================================
-- FASE 3: ÍNDICES EN FILTROS DE BÚSQUEDA FRECUENTES
-- ============================================================

-- Índice 16: tabla_espejo_estado_operativo.estado (solo vigentes)
CREATE NONCLUSTERED INDEX idx_estado_operativo_estado 
    ON tabla_espejo_estado_operativo(estado)
    WHERE fecha_fin IS NULL;

-- Índice 17: tabla_espejo_estado_fisico.condicion (solo vigentes)
CREATE NONCLUSTERED INDEX idx_estado_fisico_condicion 
    ON tabla_espejo_estado_fisico(condicion)
    WHERE fecha_fin IS NULL;

-- Índice 18: imagen_bicicleta.es_principal (solo principales)
CREATE NONCLUSTERED INDEX idx_imagen_bicicleta_es_principal 
    ON imagen_bicicleta(es_principal, id_bicicleta)
    WHERE es_principal = 1;

-- Índice 19: cobertura_seguro.estado (solo activas)
CREATE NONCLUSTERED INDEX idx_cobertura_seguro_estado 
    ON cobertura_seguro(estado)
    WHERE estado = 'activo';

-- ============================================================
-- FASE 4: ÍNDICES COMPUESTOS (MULTI-COLUMNA)
-- ============================================================

-- Índice 20: tabla_espejo_ubicacion(id_punto_alquiler, fecha_fin)
CREATE NONCLUSTERED INDEX idx_ubicacion_punto_fecha 
    ON tabla_espejo_ubicacion(id_punto_alquiler, fecha_fin);

-- Índice 21: tabla_espejo_tarifa(id_plan, fecha_fin) - CORREGIDO
CREATE NONCLUSTERED INDEX idx_tarifa_plan_fecha 
    ON tabla_espejo_tarifa(id_plan, fecha_fin)
    INCLUDE (valor, moneda);

-- Índice 22: imagen_bicicleta(id_bicicleta, orden_visualizacion)
CREATE NONCLUSTERED INDEX idx_imagen_bicicleta_orden 
    ON imagen_bicicleta(id_bicicleta, orden_visualizacion);

-- ============================================================
-- FASE 5: ÍNDICES ÚNICOS CONDICIONALES
-- ============================================================

-- Índice 23: Solo UN estado vigente por bicicleta
CREATE UNIQUE NONCLUSTERED INDEX idx_ux_estado_vigente_espejo
    ON tabla_espejo_estado_operativo(id_bicicleta)
    WHERE fecha_fin IS NULL;

-- Índice 24: Solo UNA condición vigente por bicicleta
CREATE UNIQUE NONCLUSTERED INDEX idx_ux_condicion_vigente_espejo
    ON tabla_espejo_estado_fisico(id_bicicleta)
    WHERE fecha_fin IS NULL;

-- Índice 25: Solo UNA ubicación vigente por bicicleta
CREATE UNIQUE NONCLUSTERED INDEX idx_ux_ubicacion_vigente_espejo
    ON tabla_espejo_ubicacion(id_bicicleta)
    WHERE fecha_fin IS NULL;

-- Índice 26: Solo UNA imagen principal por bicicleta
CREATE UNIQUE NONCLUSTERED INDEX idx_ux_imagen_principal
    ON imagen_bicicleta(id_bicicleta)
    WHERE es_principal = 1;

-- ============================================================
-- FASE 6: ACTUALIZAR ESTADÍSTICAS
-- ============================================================

UPDATE STATISTICS tabla_espejo_estado_operativo;
UPDATE STATISTICS tabla_espejo_estado_fisico;
UPDATE STATISTICS tabla_espejo_ubicacion;
UPDATE STATISTICS bicicleta;
UPDATE STATISTICS imagen_bicicleta;
UPDATE STATISTICS tarifa;
UPDATE STATISTICS cobertura_seguro;
UPDATE STATISTICS administrador;
UPDATE STATISTICS [plan];

-- ============================================================
-- VALIDACIÓN: LISTAR TODOS LOS ÍNDICES CREADOS
-- ============================================================

PRINT '========================================';
PRINT 'ÍNDICES CREADOS EXITOSAMENTE';
PRINT '========================================';

SELECT 
    OBJECT_NAME(i.object_id) AS 'Tabla',
    i.name AS 'Nombre Índice',
    i.type_desc AS 'Tipo',
    CASE WHEN i.is_unique = 1 THEN 'UNIQUE' ELSE 'NO UNIQUE' END AS 'Unicidad'
FROM sys.indexes i
WHERE OBJECTPROPERTY(i.object_id, 'IsUserTable') = 1
    AND i.index_id > 0
    AND OBJECT_NAME(i.object_id) IN (
        'bicicleta', 'administrador', 'imagen_bicicleta', 'tarifa',
        'tabla_espejo_estado_operativo', 'tabla_espejo_estado_fisico',
        'tabla_espejo_ubicacion', 'cobertura_seguro', 'plan',
        'ciudad', 'punto_alquiler', 'etiqueta', 'tipo_cobertura',
        'bicicleta_etiqueta', 'ubicacion', 'condiciones_especiales'
    )
ORDER BY OBJECT_NAME(i.object_id), i.name;

PRINT '';
PRINT '========================================';
PRINT 'TOTAL ÍNDICES: 26 (sin contar PK)';
PRINT '========================================';

-- ============================================================
-- FIN DEL SCRIPT: CREACIÓN DE ÍNDICES - CORREGIDO
-- Estado: LISTO PARA EJECUCIÓN
-- ============================================================