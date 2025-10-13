
SET NOCOUNT ON;
GO


BEGIN TRY
    BEGIN TRAN;

    -- ============ Tablas hijas (históricos) ============
    IF OBJECT_ID('dbo.tarifa_hist','U') IS NOT NULL               DROP TABLE dbo.tarifa_hist;
    IF OBJECT_ID('dbo.ubicacion_hist','U') IS NOT NULL            DROP TABLE dbo.ubicacion_hist;
    IF OBJECT_ID('dbo.bicicleta_etiqueta_hist','U') IS NOT NULL   DROP TABLE dbo.bicicleta_etiqueta_hist;
    IF OBJECT_ID('dbo.estado_fisico_hist','U') IS NOT NULL        DROP TABLE dbo.estado_fisico_hist;
    IF OBJECT_ID('dbo.estado_operativo_hist','U') IS NOT NULL     DROP TABLE dbo.estado_operativo_hist;
    IF OBJECT_ID('dbo.clasificacion_asistencia_hist','U') IS NOT NULL DROP TABLE dbo.clasificacion_asistencia_hist;
    IF OBJECT_ID('dbo.clasificacion_uso_hist','U') IS NOT NULL    DROP TABLE dbo.clasificacion_uso_hist;

    -- ============ Tablas hijas (actuales) ============
    IF OBJECT_ID('dbo.tarifa_actual','U') IS NOT NULL             DROP TABLE dbo.tarifa_actual;
    IF OBJECT_ID('dbo.ubicacion_actual','U') IS NOT NULL          DROP TABLE dbo.ubicacion_actual;
    IF OBJECT_ID('dbo.bicicleta_etiqueta_actual','U') IS NOT NULL DROP TABLE dbo.bicicleta_etiqueta_actual;
    IF OBJECT_ID('dbo.estado_fisico_actual','U') IS NOT NULL      DROP TABLE dbo.estado_fisico_actual;
    IF OBJECT_ID('dbo.estado_operativo_actual','U') IS NOT NULL   DROP TABLE dbo.estado_operativo_actual;
    IF OBJECT_ID('dbo.clasificacion_asistencia_actual','U') IS NOT NULL DROP TABLE dbo.clasificacion_asistencia_actual;
    IF OBJECT_ID('dbo.clasificacion_uso_actual','U') IS NOT NULL  DROP TABLE dbo.clasificacion_uso_actual;

    -- ============ Intermedias / maestras con FKs entrantes ============
    IF OBJECT_ID('dbo.bicicleta','U') IS NOT NULL                 DROP TABLE dbo.bicicleta;
    IF OBJECT_ID('dbo.administrador','U') IS NOT NULL             DROP TABLE dbo.administrador;
    IF OBJECT_ID('dbo.etiqueta','U') IS NOT NULL                  DROP TABLE dbo.etiqueta;
    IF OBJECT_ID('dbo.[plan]','U') IS NOT NULL                    DROP TABLE dbo.[plan];
    IF OBJECT_ID('dbo.tipo_asistencia','U') IS NOT NULL           DROP TABLE dbo.tipo_asistencia;
    IF OBJECT_ID('dbo.tipo_uso','U') IS NOT NULL                  DROP TABLE dbo.tipo_uso;
    IF OBJECT_ID('dbo.punto_alquiler','U') IS NOT NULL            DROP TABLE dbo.punto_alquiler;
    IF OBJECT_ID('dbo.ciudad','U') IS NOT NULL                    DROP TABLE dbo.ciudad;
    IF OBJECT_ID('dbo.pais','U') IS NOT NULL                      DROP TABLE dbo.pais;

    COMMIT;
    PRINT 'Rollback de tablas completado.';

END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    DECLARE @errmsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @eline INT = ERROR_LINE();
    RAISERROR('Error en 99_rollback_sqlserver.sql: %s (línea %d)', 16, 1, @errmsg, @eline);
END CATCH

/* ============================================
   Opción: re-habilitar constraints
-----------------------------------------------
--EXEC sp_msforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL';
============================================ */
