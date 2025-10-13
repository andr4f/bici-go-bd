-- ============================================
-- Script: 03_create_indexes_sqlserver_v3.sql
-- Fecha: 2025-10-13
-- Descripción: Índices idempotentes (sólo se crean si no existen) para SQL Server
-- ============================================
SET NOCOUNT ON;
GO

/* Nota:
   - Se omite crear índices únicos redundantes con UNIQUE constraints (p. ej. codigo_unico).
   - Cada CREATE INDEX está protegido con IF NOT EXISTS (sys.indexes).
*/

-- Ciudad / País
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ciudad_id_pais' AND object_id = OBJECT_ID('dbo.ciudad'))
    CREATE INDEX IX_ciudad_id_pais ON dbo.ciudad(id_pais);
GO

-- Punto de alquiler / Ciudad
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_punto_alquiler_id_ciudad' AND object_id = OBJECT_ID('dbo.punto_alquiler'))
    CREATE INDEX IX_punto_alquiler_id_ciudad ON dbo.punto_alquiler(id_ciudad);
GO

-- Bicicleta
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_bicicleta_id_admin' AND object_id = OBJECT_ID('dbo.bicicleta'))
    CREATE INDEX IX_bicicleta_id_admin ON dbo.bicicleta(id_admin);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_bicicleta_marca_modelo' AND object_id = OBJECT_ID('dbo.bicicleta'))
    CREATE INDEX IX_bicicleta_marca_modelo ON dbo.bicicleta(marca_comercial, modelo);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_bicicleta_anio' AND object_id = OBJECT_ID('dbo.bicicleta'))
    CREATE INDEX IX_bicicleta_anio ON dbo.bicicleta(anio_fabricacion);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_bicicleta_fecha_registro' AND object_id = OBJECT_ID('dbo.bicicleta'))
    CREATE INDEX IX_bicicleta_fecha_registro ON dbo.bicicleta(fecha_registro);
GO

-- Clasificación uso
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_clas_uso_actual_bici' AND object_id = OBJECT_ID('dbo.clasificacion_uso_actual'))
    CREATE INDEX IX_clas_uso_actual_bici ON dbo.clasificacion_uso_actual(id_bicicleta);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_clas_uso_actual_tipo' AND object_id = OBJECT_ID('dbo.clasificacion_uso_actual'))
    CREATE INDEX IX_clas_uso_actual_tipo ON dbo.clasificacion_uso_actual(id_tipo_uso);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_clas_uso_hist_bici_fecha' AND object_id = OBJECT_ID('dbo.clasificacion_uso_hist'))
    CREATE INDEX IX_clas_uso_hist_bici_fecha ON dbo.clasificacion_uso_hist(id_bicicleta, fecha_inicio DESC);
GO

-- Clasificación asistencia
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_clas_asist_actual_bici' AND object_id = OBJECT_ID('dbo.clasificacion_asistencia_actual'))
    CREATE INDEX IX_clas_asist_actual_bici ON dbo.clasificacion_asistencia_actual(id_bicicleta);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_clas_asist_actual_tipo' AND object_id = OBJECT_ID('dbo.clasificacion_asistencia_actual'))
    CREATE INDEX IX_clas_asist_actual_tipo ON dbo.clasificacion_asistencia_actual(id_tipo_asistencia);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_clas_asist_hist_bici_fecha' AND object_id = OBJECT_ID('dbo.clasificacion_asistencia_hist'))
    CREATE INDEX IX_clas_asist_hist_bici_fecha ON dbo.clasificacion_asistencia_hist(id_bicicleta, fecha_inicio DESC);
GO

-- Estados
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_estado_op_actual_bici' AND object_id = OBJECT_ID('dbo.estado_operativo_actual'))
    CREATE INDEX IX_estado_op_actual_bici ON dbo.estado_operativo_actual(id_bicicleta);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_estado_op_hist_bici_fecha' AND object_id = OBJECT_ID('dbo.estado_operativo_hist'))
    CREATE INDEX IX_estado_op_hist_bici_fecha ON dbo.estado_operativo_hist(id_bicicleta, fecha_inicio DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_estado_fis_actual_bici' AND object_id = OBJECT_ID('dbo.estado_fisico_actual'))
    CREATE INDEX IX_estado_fis_actual_bici ON dbo.estado_fisico_actual(id_bicicleta);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_estado_fis_hist_bici_fecha' AND object_id = OBJECT_ID('dbo.estado_fisico_hist'))
    CREATE INDEX IX_estado_fis_hist_bici_fecha ON dbo.estado_fisico_hist(id_bicicleta, fecha_inicio DESC);
GO

-- Etiquetas
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_bici_etq_actual_bici' AND object_id = OBJECT_ID('dbo.bicicleta_etiqueta_actual'))
    CREATE INDEX IX_bici_etq_actual_bici ON dbo.bicicleta_etiqueta_actual(id_bicicleta);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_bici_etq_actual_etq' AND object_id = OBJECT_ID('dbo.bicicleta_etiqueta_actual'))
    CREATE INDEX IX_bici_etq_actual_etq ON dbo.bicicleta_etiqueta_actual(id_etiqueta);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_bici_etq_hist_bici_fecha' AND object_id = OBJECT_ID('dbo.bicicleta_etiqueta_hist'))
    CREATE INDEX IX_bici_etq_hist_bici_fecha ON dbo.bicicleta_etiqueta_hist(id_bicicleta, fecha_asignacion DESC);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_bici_etq_hist_etq' AND object_id = OBJECT_ID('dbo.bicicleta_etiqueta_hist'))
    CREATE INDEX IX_bici_etq_hist_etq ON dbo.bicicleta_etiqueta_hist(id_etiqueta);
GO

-- Ubicación
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ubic_actual_bici' AND object_id = OBJECT_ID('dbo.ubicacion_actual'))
    CREATE INDEX IX_ubic_actual_bici ON dbo.ubicacion_actual(id_bicicleta);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ubic_actual_punto' AND object_id = OBJECT_ID('dbo.ubicacion_actual'))
    CREATE INDEX IX_ubic_actual_punto ON dbo.ubicacion_actual(id_punto_alquiler);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ubic_hist_bici_fecha' AND object_id = OBJECT_ID('dbo.ubicacion_hist'))
    CREATE INDEX IX_ubic_hist_bici_fecha ON dbo.ubicacion_hist(id_bicicleta, fecha_inicio DESC);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_ubic_hist_punto' AND object_id = OBJECT_ID('dbo.ubicacion_hist'))
    CREATE INDEX IX_ubic_hist_punto ON dbo.ubicacion_hist(id_punto_alquiler);
GO

-- Tarifas
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tarifa_actual_bici_plan' AND object_id = OBJECT_ID('dbo.tarifa_actual'))
    CREATE INDEX IX_tarifa_actual_bici_plan ON dbo.tarifa_actual(id_bicicleta, id_plan);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tarifa_hist_bici_plan_fecha' AND object_id = OBJECT_ID('dbo.tarifa_hist'))
    CREATE INDEX IX_tarifa_hist_bici_plan_fecha ON dbo.tarifa_hist(id_bicicleta, id_plan, fecha_inicio DESC);
GO

-- Administrador
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_admin_email' AND object_id = OBJECT_ID('dbo.administrador'))
    CREATE INDEX IX_admin_email ON dbo.administrador(email);
GO
