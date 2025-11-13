-- =============================================
-- ÍNDICES DEL DOCUMENTO "TIEMPO DE EJECUCION INDICES"
-- Base de datos: BICI_GO
-- Autor: Rafael José Camargo Parrao
-- Fecha: 2025-11-12
-- =============================================

USE [BICI_GO];
GO

-- 1️⃣ Índice para búsquedas por ciudad en puntos de alquiler
CREATE INDEX idx_punto_alquiler_ciudad
ON dbo.punto_alquiler (id_ciudad);
GO

-- 2️⃣ Índice para consultas por punto y fecha en ubicaciones
CREATE INDEX idx_ubicacion_punto_fecha
ON dbo.ubicacion (id_punto_alquiler, fecha_fin);
GO

-- 3️⃣ Índice para acelerar búsquedas por plan y fecha en tarifas
CREATE INDEX idx_tarifa_plan_fecha
ON dbo.tarifa (id_plan, fecha_inicio);
GO

-- 4️⃣ Índice para historial de estados operativos de bicicletas
CREATE INDEX idx_hist_estado_operativo_bici_fecha
ON dbo.hist_estado_operativo (id_bicicleta, fecha_inicio);
GO

-- 5️⃣ Índice para excepciones de horario por punto y fecha
CREATE INDEX idx_excepcion_punto_fecha
ON dbo.excepcion_horario (id_punto_alquiler, fecha_excepcion);
GO
