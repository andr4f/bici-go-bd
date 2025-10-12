sql-- ============================================
-- Script: 03_create_indexes.sql
-- Versión: 1.0
-- Fecha: 2025-10-12
-- Autor: [Tu nombre]
-- Descripción: Definición de índices para optimizar consultas
-- ============================================

-- ============================================
-- ÍNDICES PARA BÚSQUEDAS FRECUENTES
-- ============================================

-- Buscar administrador por email (para login)
CREATE INDEX idx_administrador_email 
    ON administrador(email);

COMMENT ON INDEX idx_administrador_email IS 'Optimiza búsqueda de administrador por email en login';

-- Buscar bicicletas por administrador
CREATE INDEX idx_bicicleta_admin 
    ON bicicleta(id_admin);

COMMENT ON INDEX idx_bicicleta_admin IS 'Optimiza consultas de bicicletas por administrador';

-- Buscar bicicletas por tipo de uso
CREATE INDEX idx_bicicleta_tipo_uso 
    ON bicicleta(id_tipo_uso);

COMMENT ON INDEX idx_bicicleta_tipo_uso IS 'Optimiza filtros de bicicletas por tipo de uso';

-- Buscar bicicletas por marca y modelo (búsqueda compuesta)
CREATE INDEX idx_bicicleta_marca_modelo 
    ON bicicleta(marca_comercial, modelo);

COMMENT ON INDEX idx_bicicleta_marca_modelo IS 'Optimiza búsquedas por marca y modelo específico';

-- Estados operativos por bicicleta (ordenados por fecha desc)
CREATE INDEX idx_estado_operativo_bicicleta_fecha 
    ON estado_operativo(id_bicicleta, fecha DESC, hora DESC);

COMMENT ON INDEX idx_estado_operativo_bicicleta_fecha IS 'Optimiza consulta del estado operativo actual de cada bicicleta';

-- Estados físicos por bicicleta (ordenados por fecha desc)
CREATE INDEX idx_estado_fisico_bicicleta_fecha 
    ON estado_fisico(id_bicicleta, fecha DESC, hora DESC);

COMMENT ON INDEX idx_estado_fisico_bicicleta_fecha IS 'Optimiza consulta del estado físico actual de cada bicicleta';

-- Buscar bicicletas por fecha de registro
CREATE INDEX idx_bicicleta_fecha_registro 
    ON bicicleta(fecha_registro DESC);

COMMENT ON INDEX idx_bicicleta_fecha_registro IS 'Optimiza reportes de bicicletas registradas por periodo';

-- ============================================
-- FIN DEL SCRIPT
-- ============================================