
--------------------------
--TRIGGERS DE INICIO
--------------------------
CREATE TRIGGER TR_persona_crear_roles
ON persona
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO cliente (id_cliente)
    SELECT i.id_persona
    FROM inserted AS i
    WHERE i.tipo_persona = 'cliente';

    INSERT INTO administrador (id_admin, rol_admin)
    SELECT i.id_persona, 'admin'
    FROM inserted AS i
    WHERE i.tipo_persona = 'administrador';

    INSERT INTO guia_turistico (id_guia, numero_licencia, tarifa_base)
    SELECT 
        i.id_persona,
        'LIC-' + RIGHT('00000' + CAST(i.id_persona AS VARCHAR(10)), 5),
        80000.00
    FROM inserted AS i
    WHERE i.tipo_persona = 'guia';

    -- Insertar con cargo por defecto y punto NULL
    INSERT INTO contacto_punto (id_contacto, id_punto_alquiler, cargo)
    SELECT i.id_persona, NULL, 'Pendiente de Asignación'
    FROM inserted AS i
    WHERE i.tipo_persona = 'contacto_punto';
    
END;
GO

DROP TRIGGER IF EXISTS trg_fotografia_auto_asignar;
GO

CREATE TRIGGER trg_fotografia_auto_asignar
ON fotografia
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Fotos de bicicleta
    INSERT INTO fotografia_bicicleta (id_fotografia_bicicleta, id_bicicleta, tipo_vista)
    SELECT
        i.id_fotografia,
        (SELECT TOP 1 id_bicicleta FROM bicicleta ORDER BY NEWID()),
        NULL
    FROM inserted i
    WHERE i.tipo_fotografia = 'bicicleta';

    -- Fotos de punto de alquiler
    INSERT INTO fotografia_punto (id_fotografia_punto, id_punto_alquiler, tipo_vista)
    SELECT
        i.id_fotografia,
        (SELECT TOP 1 id_punto_alquiler FROM punto_alquiler ORDER BY NEWID()),
        NULL
    FROM inserted i
    WHERE i.tipo_fotografia = 'punto_alquiler';

    -- Fotos de ruta: asignar id_ruta ya (rotativo 1-90)
    -- tipo_foto quedará NULL, se especificará después
    INSERT INTO foto_ruta (id_fotografia, id_ruta, tipo_foto)
    SELECT
        i.id_fotografia,
        1 + ((ROW_NUMBER() OVER (ORDER BY i.id_fotografia)) % 90),  -- Ruta rotativa 1-90
        NULL  -- Se rellena después con UPDATE
    FROM inserted i
    WHERE i.tipo_fotografia = 'ruta';

    -- Fotos de reseña: asignar id_resenia_ruta ya (rotativo de reseñas existentes)
    -- orden puede quedar en 0 por defecto
    INSERT INTO foto_resenia (id_foto_resenia, id_resenia_ruta, orden)
    SELECT
        i.id_fotografia,
        1 + ((ROW_NUMBER() OVER (ORDER BY i.id_fotografia)) % 
             (SELECT COUNT(*) FROM resenia_ruta)),  -- Reseña rotativa
        0  -- Orden por defecto
    FROM inserted i
    WHERE i.tipo_fotografia = 'resenia';

END;
GO



CREATE TRIGGER TR_bicicleta_crear_uso_acumulado
ON bicicleta
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Insertar registro de uso inicial para cada bicicleta nueva
    INSERT INTO uso_acumulado (
        id_bicicleta,
        km_total,
        horas_total,
        km_parcial,
        horas_parcial,
        fecha_ultimo_mantenimiento,
        id_admin
    )
    SELECT
        i.id_bicicleta,
        0.00 AS km_total,
        0.00 AS horas_total,
        0.00 AS km_parcial,
        0.00 AS horas_parcial,
        NULL AS fecha_ultimo_mantenimiento,
        i.id_admin      -- mismo admin que creó la bicicleta
    FROM inserted AS i
    WHERE NOT EXISTS (
        SELECT 1
        FROM uso_acumulado ua
        WHERE ua.id_bicicleta = i.id_bicicleta
    );
END;
GO

CREATE TRIGGER TR_detalle_alquiler_recalcular_reserva
ON detalle_alquiler
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------
    -- 1) Identificar reservas afectadas
    ------------------------------------------------
    ;WITH ResAfectadas AS (
        SELECT id_reserva FROM inserted
        UNION
        SELECT id_reserva FROM deleted
    )
    ------------------------------------------------
    -- 2) Recalcular subtotal e IVA por reserva
    ------------------------------------------------
    , Totales AS (
        SELECT
            da.id_reserva,
            SUM(da.subtotal)  AS subtotal,
            SUM(da.iva_total) AS iva
        FROM detalle_alquiler da
        JOIN ResAfectadas ra
          ON ra.id_reserva = da.id_reserva
        GROUP BY da.id_reserva
    )
    UPDATE r
    SET r.subtotal_general = ISNULL(t.subtotal, 0.00),
        r.iva_total        = ISNULL(t.iva, 0.00),
        r.total_general    = ISNULL(t.subtotal, 0.00)
                             - r.descuento_total
                             + ISNULL(t.iva, 0.00)
                             + ISNULL(r.tarifa_guia, 0.00)
    FROM reserva r
    JOIN ResAfectadas ra
      ON ra.id_reserva = r.id_reserva
    LEFT JOIN Totales t
      ON t.id_reserva = r.id_reserva;
END;
GO

IF OBJECT_ID('dbo.trg_reserva_validar_fechas', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_reserva_validar_fechas;
GO

CREATE TRIGGER trg_reserva_validar_fechas
ON reserva
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        -- Validar que fecha_inicio < fecha_fin
        IF EXISTS (SELECT 1 FROM inserted WHERE fecha_inicio >= fecha_fin)
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50001, 'Error: La fecha de inicio debe ser anterior a la fecha de fin', 1;
        END
       
        -- Validar que no sea en el pasado
        IF EXISTS (SELECT 1 FROM inserted WHERE fecha_inicio < CAST(GETDATE() AS DATE))
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50002, 'Error: No se pueden crear reservas en el pasado', 1;
        END
       
        -- Validar que cliente existe
        IF EXISTS (SELECT 1 FROM inserted i
                   WHERE NOT EXISTS (SELECT 1 FROM cliente c WHERE c.id_cliente = i.id_cliente))
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50003, 'Error: Cliente no existe', 1;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

PRINT '✅ TRIGGER 1: trg_reserva_validar_fechas creado (CORREGIDO)';
GO

-- ============================================================================
-- TRIGGER 2: Validar Cantidad Positiva en Detalle Alquiler (CORREGIDO)
-- ============================================================================
-- NO PUEDE ser INSTEAD OF porque detalle_alquiler es System-Versioned
IF OBJECT_ID('dbo.trg_detalle_alquiler_cantidad_positiva', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_detalle_alquiler_cantidad_positiva;
GO

CREATE TRIGGER trg_detalle_alquiler_cantidad_positiva
ON detalle_alquiler
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        -- Validar cantidad > 0
        IF EXISTS (SELECT 1 FROM inserted WHERE cantidad_unidades <= 0)
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50004, 'Error: La cantidad debe ser mayor a 0', 1;
        END
       
        -- Validar tarifa_unitaria > 0
        IF EXISTS (SELECT 1 FROM inserted WHERE tarifa_unitaria <= 0)
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50005, 'Error: La tarifa debe ser mayor a 0', 1;
        END
       
        -- Validar fechas
        IF EXISTS (SELECT 1 FROM inserted WHERE fecha_fin <= fecha_inicio)
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50006, 'Error: Fecha fin debe ser posterior a fecha inicio', 1;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

PRINT '✅ TRIGGER 2: trg_detalle_alquiler_cantidad_positiva creado (CORREGIDO)';
GO

-- ============================================================================
-- TRIGGER 3: Calcular IVA Automático en Detalle Alquiler
-- ============================================================================
-- Este SÍ funciona en System-Versioned Tables porque es AFTER
IF OBJECT_ID('dbo.trg_detalle_alquiler_calcular_iva', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_detalle_alquiler_calcular_iva;
GO

CREATE TRIGGER trg_detalle_alquiler_calcular_iva
ON detalle_alquiler
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
   
    -- Actualizar IVA basado en subtotal (19% en Colombia)
    UPDATE da
    SET iva_total = (da.subtotal * 0.19),
        porcentaje_iva = 19,
        total_item = da.subtotal + (da.subtotal * 0.19)
    FROM detalle_alquiler da
    INNER JOIN inserted i ON da.id_detalle_alquiler = i.id_detalle_alquiler
    WHERE da.iva_total = 0 OR da.iva_total IS NULL;
END;
GO

PRINT '✅ TRIGGER 3: trg_detalle_alquiler_calcular_iva creado';
GO

-- ============================================================================
-- TRIGGER 4: Validar Uso Acumulado No Supere Límites (CORREGIDO)
-- ============================================================================
-- NO PUEDE ser INSTEAD OF porque uso_acumulado es System-Versioned
IF OBJECT_ID('dbo.trg_uso_acumulado_validar_limites', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_uso_acumulado_validar_limites;
GO

CREATE TRIGGER trg_uso_acumulado_validar_limites
ON uso_acumulado
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        -- Validar km_parcial <= km_total
        IF EXISTS (SELECT 1 FROM inserted WHERE km_parcial > km_total)
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50007, 'Error: km_parcial no puede superar km_total', 1;
        END
       
        -- Validar horas_parcial <= horas_total
        IF EXISTS (SELECT 1 FROM inserted WHERE horas_parcial > horas_total)
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50008, 'Error: horas_parcial no puede superar horas_total', 1;
        END
       
        -- Validar valores no negativos
        IF EXISTS (SELECT 1 FROM inserted
                   WHERE km_total < 0 OR horas_total < 0 OR km_parcial < 0 OR horas_parcial < 0)
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50009, 'Error: Los valores no pueden ser negativos', 1;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

PRINT '✅ TRIGGER 4: trg_uso_acumulado_validar_limites creado (CORREGIDO)';
GO

-- ============================================================================
-- TRIGGER 5: Cambiar Estado Operativo si Bicicleta Está Dañada
-- ============================================================================
-- bicicleta NO es System-Versioned, AFTER funciona bien
IF OBJECT_ID('dbo.trg_bicicleta_estado_dañada_a_fuera_servicio', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_bicicleta_estado_dañada_a_fuera_servicio;
GO

CREATE TRIGGER trg_bicicleta_estado_dañada_a_fuera_servicio
ON bicicleta
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
   
    DECLARE @id_estado_fuera_servicio INT;
    SELECT @id_estado_fuera_servicio = id_estado_operativo
    FROM estado_operativo WHERE nombre_estado = 'fuera de servicio';
   
    -- Si estado físico cambió a 'dañada', cambiar a 'fuera de servicio'
    UPDATE b
    SET b.id_estado_operativo = @id_estado_fuera_servicio
    FROM bicicleta b
    INNER JOIN inserted i ON b.id_bicicleta = i.id_bicicleta
    INNER JOIN deleted d ON d.id_bicicleta = i.id_bicicleta
    INNER JOIN estado_fisico ef ON ef.id_estado_fisico = i.id_estado_fisico
    WHERE ef.condicion = 'dañada' AND d.id_estado_fisico <> i.id_estado_fisico;
END;
GO

PRINT '✅ TRIGGER 5: trg_bicicleta_estado_dañada_a_fuera_servicio creado';
GO

-- ============================================================================
-- TRIGGER 6: Validar Capacidad Total No Sea Excedida
-- ============================================================================
-- capacidad_tipo NO es System-Versioned
IF OBJECT_ID('dbo.trg_capacidad_tipo_validar_total', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_capacidad_tipo_validar_total;
GO

CREATE TRIGGER trg_capacidad_tipo_validar_total
ON capacidad_tipo
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
   
    DECLARE @capacidad_total INT;
    DECLARE @capacidad_suma INT;
    DECLARE @id_punto INT;
   
    DECLARE cap_cursor CURSOR FOR
    SELECT DISTINCT id_punto_alquiler FROM inserted;
   
    OPEN cap_cursor;
    FETCH NEXT FROM cap_cursor INTO @id_punto;
   
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @capacidad_total = capacidad_total
        FROM capacidad
        WHERE id_punto_alquiler = @id_punto;
       
        SELECT @capacidad_suma = ISNULL(SUM(capacidad_especifica), 0)
        FROM capacidad_tipo
        WHERE id_punto_alquiler = @id_punto;
       
        IF @capacidad_suma > @capacidad_total
        BEGIN
            CLOSE cap_cursor;
            DEALLOCATE cap_cursor;
            THROW 50010, 'Error: Suma de capacidades específicas supera total', 1;
        END
       
        FETCH NEXT FROM cap_cursor INTO @id_punto;
    END
   
    CLOSE cap_cursor;
    DEALLOCATE cap_cursor;
END;
GO

PRINT '✅ TRIGGER 6: trg_capacidad_tipo_validar_total creado';
GO

-- ============================================================================
-- TRIGGER 7: Validar Fecha Coherencia en Condiciones Especiales (CORREGIDO)
-- ============================================================================
-- NO PUEDE ser INSTEAD OF porque condiciones_especiales es System-Versioned
IF OBJECT_ID('dbo.trg_condiciones_especiales_validar_fechas', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_condiciones_especiales_validar_fechas;
GO

CREATE TRIGGER trg_condiciones_especiales_validar_fechas
ON condiciones_especiales
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        -- Validar que valor_minimo <= valor_maximo
        IF EXISTS (SELECT 1 FROM inserted
                   WHERE valor_minimo IS NOT NULL AND valor_maximo IS NOT NULL
                   AND valor_minimo > valor_maximo)
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50011, 'Error: valor_minimo no puede ser mayor a valor_maximo', 1;
        END
       
        -- Validar que fecha_inicio < fecha_fin
        IF EXISTS (SELECT 1 FROM inserted
                   WHERE fecha_inicio >= fecha_fin AND fecha_fin IS NOT NULL)
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50012, 'Error: fecha_inicio debe ser menor a fecha_fin', 1;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

PRINT '✅ TRIGGER 7: trg_condiciones_especiales_validar_fechas creado (CORREGIDO)';
GO

-- ============================================================================
-- TRIGGER 8: Validar Etiquetas No Incompatibles
-- ============================================================================
-- bicicleta_etiqueta NO es System-Versioned
IF OBJECT_ID('dbo.trg_bicicleta_etiqueta_incompatibilidades', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_bicicleta_etiqueta_incompatibilidades;
GO

CREATE TRIGGER trg_bicicleta_etiqueta_incompatibilidades
ON bicicleta_etiqueta
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
   
    DECLARE @id_bicicleta INT;
    DECLARE @nombre_etiqueta VARCHAR(50);
   
    DECLARE etiq_cursor CURSOR FOR
    SELECT DISTINCT i.id_bicicleta, e.nombre
    FROM inserted i
    INNER JOIN etiqueta e ON e.id_etiqueta = i.id_etiqueta;
   
    OPEN etiq_cursor;
    FETCH NEXT FROM etiq_cursor INTO @id_bicicleta, @nombre_etiqueta;
   
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @nombre_etiqueta = 'Apta para niños'
        BEGIN
            IF EXISTS (SELECT 1 FROM bicicleta_etiqueta be
                       INNER JOIN etiqueta e ON e.id_etiqueta = be.id_etiqueta
                       WHERE be.id_bicicleta = @id_bicicleta
                       AND e.nombre = 'No apta para niños'
                       AND be.fecha_eliminacion IS NULL)
            BEGIN
                CLOSE etiq_cursor;
                DEALLOCATE etiq_cursor;
                THROW 50013, 'Error: Etiqueta incompatible existe', 1;
            END
        END
       
        FETCH NEXT FROM etiq_cursor INTO @id_bicicleta, @nombre_etiqueta;
    END
   
    CLOSE etiq_cursor;
    DEALLOCATE etiq_cursor;
END;
GO

PRINT '✅ TRIGGER 8: trg_bicicleta_etiqueta_incompatibilidades creado';
GO
-- ============================================================================
-- TRIGGER 9 CORREGIDO: Calcular Vigencia de Cobertura Seguro
-- ============================================================================
-- PROBLEMA: cobertura_seguro ES System-Versioned Table
-- SOLUCIÓN: Usar AFTER INSERT con UPDATE adicional
-- ============================================================================

IF OBJECT_ID('dbo.trg_cobertura_seguro_calcular_vigencia', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_cobertura_seguro_calcular_vigencia;
GO

CREATE TRIGGER trg_cobertura_seguro_calcular_vigencia
ON cobertura_seguro
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        -- Obtener días de vigencia según tipo de cobertura
        UPDATE cs
        SET cs.fecha_fin_vigencia = DATEADD(DAY,
            CASE tc.nombre
                WHEN 'Básico' THEN 30
                WHEN 'Estándar' THEN 90
                WHEN 'Premium' THEN 365
                ELSE 30
            END,
            CAST(cs.fecha_inicio_vigencia AS DATETIME))
        FROM cobertura_seguro cs
        INNER JOIN inserted i ON cs.id_cobertura = i.id_cobertura
        INNER JOIN tipo_cobertura tc ON tc.id_tipo_cobertura = cs.id_tipo_cobertura
        WHERE cs.fecha_fin_vigencia IS NULL;
       
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

PRINT '✅ TRIGGER 9 CORREGIDO: trg_cobertura_seguro_calcular_vigencia creado';
GO

-- ============================================================================
-- TRIGGER 10: Validar Capacidad Especifica Positiva
-- ============================================================================
-- capacidad_tipo NO es System-Versioned
IF OBJECT_ID('dbo.trg_capacidad_tipo_validar_positiva', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_capacidad_tipo_validar_positiva;
GO

CREATE TRIGGER trg_capacidad_tipo_validar_positiva
ON capacidad_tipo
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        -- Validar capacidad_especifica > 0
        IF EXISTS (SELECT 1 FROM inserted WHERE capacidad_especifica <= 0)
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50014, 'Error: capacidad_especifica debe ser mayor a 0', 1;
        END
       
        -- Validar que los tipos existan
        IF EXISTS (SELECT 1 FROM inserted i
                   WHERE NOT EXISTS (SELECT 1 FROM tipo_uso tu WHERE tu.id_tipo_uso = i.id_tipo_uso))
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50015, 'Error: tipo_uso no existe', 1;
        END
       
        IF EXISTS (SELECT 1 FROM inserted i
                   WHERE NOT EXISTS (SELECT 1 FROM tipo_asistencia ta WHERE ta.id_tipo_asistencia = i.id_tipo_asistencia))
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50016, 'Error: tipo_asistencia no existe', 1;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

PRINT '✅ TRIGGER 10: trg_capacidad_tipo_validar_positiva creado';
GO

-- ============================================================================
-- TRIGGER 11: Actualizar Calificación Promedio de Ruta
-- ============================================================================
-- ruta_turistica NO es System-Versioned
IF OBJECT_ID('dbo.trg_resenia_ruta_actualizar_promedio', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_resenia_ruta_actualizar_promedio;
GO

CREATE TRIGGER trg_resenia_ruta_actualizar_promedio
ON resenia_ruta
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
   
    -- Recalcular calificación promedio y total
    UPDATE rt
    SET rt.calificacion_promedio = (
            SELECT CAST(AVG(CAST(rr.calificacion AS DECIMAL(3,2))) AS DECIMAL(3,2))
            FROM resenia_ruta rr
            WHERE rr.id_ruta = rt.id_ruta
            AND rr.calificacion IS NOT NULL
            AND rr.estado = 'activo'
        ),
        rt.total_resenas = (
            SELECT COUNT(*)
            FROM resenia_ruta rr
            WHERE rr.id_ruta = rt.id_ruta
            AND rr.estado = 'activo'
        )
    FROM ruta_turistica rt
    WHERE rt.id_ruta IN (SELECT DISTINCT id_ruta FROM inserted);
END;
GO

PRINT '✅ TRIGGER 11: trg_resenia_ruta_actualizar_promedio creado';
GO

-- ============================================================================
-- TRIGGER 12: Validar Rango de Calificación (CORREGIDO)
-- ============================================================================
-- NO PUEDE ser INSTEAD OF porque resenia_ruta es System-Versioned
IF OBJECT_ID('dbo.trg_resenia_ruta_validar_calificacion', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_resenia_ruta_validar_calificacion;
GO

CREATE TRIGGER trg_resenia_ruta_validar_calificacion
ON resenia_ruta
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        -- Validar calificación entre 1-5
        IF EXISTS (SELECT 1 FROM inserted
                   WHERE calificacion IS NOT NULL
                   AND (calificacion < 1 OR calificacion > 5))
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50017, 'Error: Calificación debe estar entre 1 y 5', 1;
        END
       
        -- Validar que reserva existe
        IF EXISTS (SELECT 1 FROM inserted i
                   WHERE NOT EXISTS (SELECT 1 FROM reserva r WHERE r.id_reserva = i.id_reserva))
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50018, 'Error: Reserva no existe', 1;
        END
       
        -- Validar que ruta existe
        IF EXISTS (SELECT 1 FROM inserted i
                   WHERE NOT EXISTS (SELECT 1 FROM ruta_turistica r WHERE r.id_ruta = i.id_ruta))
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50019, 'Error: Ruta no existe', 1;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

PRINT '✅ TRIGGER 12: trg_resenia_ruta_validar_calificacion creado (CORREGIDO)';
GO

-- ============================================================================
-- TRIGGER 13: Validar Coherencia de Horarios
-- ============================================================================
-- detalle_dia_horario NO es System-Versioned
IF OBJECT_ID('dbo.trg_detalle_dia_horario_validar_coherencia', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_detalle_dia_horario_validar_coherencia;
GO

CREATE TRIGGER trg_detalle_dia_horario_validar_coherencia
ON detalle_dia_horario
INSTEAD OF INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        -- Si está cerrado, no debe haber horarios
        IF EXISTS (SELECT 1 FROM inserted
                   WHERE estado = 'cerrado'
                   AND (hora_apertura IS NOT NULL OR hora_cierre IS NOT NULL))
        BEGIN
            THROW 50020, 'Error: Si está cerrado, no puede tener horarios', 1;
        END
       
        -- Si está abierto, debe tener horarios
        IF EXISTS (SELECT 1 FROM inserted
                   WHERE estado <> 'cerrado'
                   AND (hora_apertura IS NULL OR hora_cierre IS NULL))
        BEGIN
            THROW 50021, 'Error: Si está abierto, debe tener horarios', 1;
        END
       
        -- Validar que cierre > apertura
        IF EXISTS (SELECT 1 FROM inserted
                   WHERE hora_apertura IS NOT NULL
                   AND hora_cierre IS NOT NULL
                   AND hora_cierre <= hora_apertura)
        BEGIN
            THROW 50022, 'Error: Hora cierre debe ser mayor a apertura', 1;
        END
       
        -- Validar día_semana (0-6)
        IF EXISTS (SELECT 1 FROM inserted WHERE dia_semana < 0 OR dia_semana > 6)
        BEGIN
            THROW 50023, 'Error: Día semana debe estar entre 0 y 6', 1;
        END
       
        -- Insertar o actualizar
        IF EXISTS (SELECT 1 FROM deleted d
                   INNER JOIN inserted i ON d.id_punto_alquiler = i.id_punto_alquiler
                   AND d.dia_semana = i.dia_semana)
        BEGIN
            UPDATE ddh
            SET ddh.hora_apertura = i.hora_apertura,
                ddh.hora_cierre = i.hora_cierre,
                ddh.estado = i.estado
            FROM detalle_dia_horario ddh
            INNER JOIN inserted i ON ddh.id_punto_alquiler = i.id_punto_alquiler
                                AND ddh.dia_semana = i.dia_semana;
        END
        ELSE
        BEGIN
            INSERT INTO detalle_dia_horario
            (id_punto_alquiler, dia_semana, hora_apertura, hora_cierre, estado)
            SELECT id_punto_alquiler, dia_semana, hora_apertura, hora_cierre, estado
            FROM inserted;
        END
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

PRINT '✅ TRIGGER 13: trg_detalle_dia_horario_validar_coherencia creado';
GO

-- ============================================================================
-- TRIGGER 14: Incrementar Experiencia de Guía y Registrar Hitos
-- ============================================================================
-- guia_ruta NO es System-Versioned
IF OBJECT_ID('dbo.trg_guia_ruta_registrar_hitos', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_guia_ruta_registrar_hitos;
GO

CREATE TRIGGER trg_guia_ruta_registrar_hitos
ON guia_ruta
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
   
    DECLARE @veces_realizado INT;
    DECLARE @id_guia INT;
   
    DECLARE guia_cursor CURSOR FOR
    SELECT i.id_guia, i.veces_realizada
    FROM inserted i
    INNER JOIN deleted d ON d.id_guia_ruta = i.id_guia_ruta
    WHERE i.veces_realizada > d.veces_realizada;
   
    OPEN guia_cursor;
    FETCH NEXT FROM guia_cursor INTO @id_guia, @veces_realizado;
   
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Registrar hitos (cada 10, 25, 50, 100 rutas)
        IF @veces_realizado IN (10, 25, 50, 100)
        BEGIN
            PRINT CONCAT('✓ Hito: Guía ', @id_guia, ' completó ',
                        @veces_realizado, ' rutas');
        END
       
        FETCH NEXT FROM guia_cursor INTO @id_guia, @veces_realizado;
    END
   
    CLOSE guia_cursor;
    DEALLOCATE guia_cursor;
END;
GO

PRINT '✅ TRIGGER 14: trg_guia_ruta_registrar_hitos creado';
GO

-- ============================================================================
-- TRIGGER #1: TR_Calcular_Total_Reserva
-- ============================================================================

DROP TRIGGER IF EXISTS TR_Calcular_Total_Reserva;
GO
CREATE TRIGGER TR_Calcular_Total_Reserva
ON detalle_alquiler
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    ;WITH ResAfectadas AS (
        SELECT DISTINCT id_reserva FROM inserted
        UNION
        SELECT DISTINCT id_reserva FROM deleted
    )
    , Totales AS (
        SELECT da.id_reserva,
               SUM(da.subtotal) AS subtotal,
               SUM(da.iva_total) AS iva
        FROM detalle_alquiler da
        JOIN ResAfectadas ra ON ra.id_reserva = da.id_reserva
        GROUP BY da.id_reserva
    )
    UPDATE r
    SET r.subtotal_general = ISNULL(t.subtotal, 0.00),
        r.iva_total = ISNULL(t.iva, 0.00),
        r.total_general = ISNULL(t.subtotal, 0.00) - ISNULL(r.descuento_total, 0.00) + ISNULL(t.iva, 0.00) + ISNULL(r.tarifa_guia, 0.00)
    FROM reserva r
    JOIN ResAfectadas ra ON ra.id_reserva = r.id_reserva
    LEFT JOIN Totales t ON t.id_reserva = r.id_reserva;
END;
GO
PRINT '✓ TRIGGER #1: TR_Calcular_Total_Reserva';

-- ============================================================================
-- TRIGGER #2: TR_Actualizar_Calificacion_Promedio_Ruta
-- ============================================================================
DROP TRIGGER IF EXISTS TR_Actualizar_Calificacion_Promedio_Ruta;
GO
CREATE TRIGGER TR_Actualizar_Calificacion_Promedio_Ruta
ON resenia_ruta
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @rutas_afectadas TABLE (id_ruta INT);
   
    INSERT INTO @rutas_afectadas
    SELECT DISTINCT id_ruta FROM inserted
    UNION
    SELECT DISTINCT id_ruta FROM deleted;
   
    WITH PromediosRutas AS (
        SELECT r.id_ruta,
               -- CORREGIDO: CAST a DECIMAL(3,2) en lugar de INT
               ISNULL(CAST(ROUND(AVG(CAST(rr.calificacion AS DECIMAL(3,2))), 2) AS DECIMAL(3,2)), 0.00) AS promedio,
               COUNT(DISTINCT rr.id_resenia_ruta) AS total
        FROM ruta_turistica r
        LEFT JOIN resenia_ruta rr ON r.id_ruta = rr.id_ruta
            AND rr.estado = 'activo' AND rr.calificacion IS NOT NULL
        WHERE r.id_ruta IN (SELECT id_ruta FROM @rutas_afectadas)
        GROUP BY r.id_ruta
    )
    UPDATE r
    SET r.calificacion_promedio = pr.promedio
    FROM ruta_turistica r
    INNER JOIN PromediosRutas pr ON r.id_ruta = pr.id_ruta;
END;
GO
PRINT '✓ TRIGGER #2: TR_Actualizar_Calificacion_Promedio_Ruta [CORREGIDO - PRECISION]';

-- ============================================================================
-- TRIGGER #3: TR_Incrementar_Uso_Bicicleta - SIN CURSOR
-- ============================================================================

DROP TRIGGER IF EXISTS TR_Incrementar_Uso_Bicicleta;
GO
CREATE TRIGGER TR_Incrementar_Uso_Bicicleta
ON detalle_alquiler
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ua
    SET horas_parcial = ISNULL(horas_parcial, 0) + CAST(DATEDIFF(MINUTE, i.fecha_inicio, i.fecha_fin) AS DECIMAL(10,2)) / 60.0,
        horas_total = ISNULL(horas_total, 0) + CAST(DATEDIFF(MINUTE, i.fecha_inicio, i.fecha_fin) AS DECIMAL(10,2)) / 60.0
    FROM uso_acumulado ua
    INNER JOIN inserted i ON ua.id_bicicleta = i.id_bicicleta;
END;
GO
PRINT '✓ TRIGGER #3: TR_Incrementar_Uso_Bicicleta';

-- ============================================================================
-- TRIGGER #4: TR_Incrementar_Experiencia_Guia
-- ============================================================================

DROP TRIGGER IF EXISTS TR_Incrementar_Experiencia_Guia;
GO
CREATE TRIGGER TR_Incrementar_Experiencia_Guia
ON reserva
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(estado)
    BEGIN
        UPDATE gr
        SET gr.veces_realizada = gr.veces_realizada + 1
        FROM guia_ruta gr
        INNER JOIN inserted i ON gr.id_guia = i.id_guia
        INNER JOIN deleted d ON i.id_reserva = d.id_reserva
        WHERE d.estado = 'confirmada'
          AND i.estado = 'completada'
          AND i.id_ruta IS NOT NULL
          AND gr.id_ruta = i.id_ruta;
    END
END;
GO
PRINT '✓ TRIGGER #4: TR_Incrementar_Experiencia_Guia';

-- ============================================================================
-- TRIGGER #5: TR_Sincronizar_Disponibilidad_Bicicleta
-- ============================================================================
DROP TRIGGER IF EXISTS TR_Sincronizar_Disponibilidad_Bicicleta;
GO
CREATE TRIGGER TR_Sincronizar_Disponibilidad_Bicicleta
ON reserva
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(estado)
    BEGIN
        -- CORREGIDO: Búsqueda dinámica de estado "en alquiler"
        -- Cuando reserva se confirma: bicicleta a "en alquiler"
        UPDATE b
        SET b.id_estado_operativo = (
            SELECT id_estado_operativo FROM estado_operativo
            WHERE nombre_estado = 'en alquiler'
        )
        FROM bicicleta b
        INNER JOIN detalle_alquiler da ON da.id_bicicleta = b.id_bicicleta
        INNER JOIN inserted i ON da.id_reserva = i.id_reserva
        WHERE i.estado = 'confirmada'
          AND EXISTS (SELECT 1 FROM estado_operativo WHERE nombre_estado = 'en alquiler');
       
        -- CORREGIDO: Búsqueda dinámica de estado "disponible"
        -- Cuando reserva se completa: bicicleta a "disponible"
        UPDATE b
        SET b.id_estado_operativo = (
            SELECT id_estado_operativo FROM estado_operativo
            WHERE nombre_estado = 'disponible'
        )
        FROM bicicleta b
        INNER JOIN detalle_alquiler da ON da.id_bicicleta = b.id_bicicleta
        INNER JOIN inserted i ON da.id_reserva = i.id_reserva
        WHERE i.estado = 'completada'
          AND EXISTS (SELECT 1 FROM estado_operativo WHERE nombre_estado = 'disponible');
    END
END;
GO
PRINT '✓ TRIGGER #5: TR_Sincronizar_Disponibilidad_Bicicleta [CORREGIDO CRÍTICAMENTE - DINÁMICO]';

-- ============================================================================
-- TRIGGER #6: TR_Actualizar_Estado_Plan
-- ============================================================================

DROP TRIGGER IF EXISTS TR_Actualizar_Estado_Plan;
GO
CREATE TRIGGER TR_Actualizar_Estado_Plan
ON tarifa
AFTER UPDATE, INSERT
AS
BEGIN
    SET NOCOUNT ON;
   
    UPDATE p
    SET p.estado = CASE
        WHEN EXISTS (
            SELECT 1 FROM tarifa t
            WHERE t.id_plan = p.id_plan
            AND (t.fecha_fin IS NULL OR t.fecha_fin >= CAST(GETDATE() AS DATE))
        ) THEN 'activo'
        ELSE 'inactivo'
    END
    FROM [plan] p
    WHERE p.id_plan IN (SELECT DISTINCT id_plan FROM inserted);
END;
GO
PRINT '✓ TRIGGER #6: TR_Actualizar_Estado_Plan';

-- ============================================================================
-- TRIGGER #7: TR_Crear_Proxima_Tarifa
-- ============================================================================

DROP TRIGGER IF EXISTS TR_Crear_Proxima_Tarifa;
GO
CREATE TRIGGER TR_Crear_Proxima_Tarifa
ON tarifa
AFTER UPDATE, INSERT
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(fecha_fin)
    BEGIN
        INSERT INTO tarifa (id_plan, id_pais, id_tipo_uso, id_tipo_asistencia,
                            tarifa_base, tarifa_final, fecha_inicio, id_admin)
        SELECT
            i.id_plan, i.id_pais, i.id_tipo_uso, i.id_tipo_asistencia,
            i.tarifa_base, i.tarifa_final,
            DATEADD(DAY, 1, i.fecha_fin),
            i.id_admin
        FROM inserted i
        WHERE i.fecha_fin IS NOT NULL
        AND NOT EXISTS (
            SELECT 1 FROM tarifa t
            WHERE t.id_plan = i.id_plan
            AND t.id_pais = i.id_pais
            AND t.id_tipo_uso = i.id_tipo_uso
            AND t.id_tipo_asistencia = i.id_tipo_asistencia
            AND t.fecha_inicio = DATEADD(DAY, 1, i.fecha_fin)
        );
    END
END;
GO
PRINT '✓ TRIGGER #7: TR_Crear_Proxima_Tarifa';

-- ============================================================================
-- TRIGGER #8: TR_Aplicar_Descuento_Leal - SIN CURSOR
-- ============================================================================

DROP TRIGGER IF EXISTS TR_Aplicar_Descuento_Leal;
GO
CREATE TRIGGER TR_Aplicar_Descuento_Leal
ON reserva
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO reserva_descuento (id_reserva, id_descuento, monto_descontado)
    SELECT
        i.id_reserva,
        d.id_descuento,
        i.subtotal_general * (d.valor / 100.0)
    FROM inserted i
    CROSS JOIN descuento d
    WHERE d.nombre = 'cliente_leal'
      AND d.estado = 'activo'
      AND (SELECT COUNT(*) FROM reserva WHERE id_cliente = i.id_cliente AND estado = 'completada') >= 5
      AND NOT EXISTS (
        SELECT 1 FROM reserva_descuento WHERE id_reserva = i.id_reserva AND id_descuento = d.id_descuento
    );
   
    -- Recalcular totales
    UPDATE r
    SET r.descuento_total = (SELECT ISNULL(SUM(monto_descontado), 0) FROM reserva_descuento WHERE id_reserva = r.id_reserva),
        r.total_general = r.subtotal_general - ISNULL((SELECT SUM(monto_descontado) FROM reserva_descuento WHERE id_reserva = r.id_reserva), 0) + r.iva_total
    FROM reserva r
    WHERE r.id_reserva IN (SELECT DISTINCT id_reserva FROM inserted);
END;
GO
PRINT '✓ TRIGGER #8: TR_Aplicar_Descuento_Leal';

-- ============================================================================
-- TRIGGER #9: TR_Alerta_Mantenimiento_Preventivo - SIN CURSOR
-- ============================================================================

DROP TRIGGER IF EXISTS TR_Alerta_Mantenimiento_Preventivo;
GO
CREATE TRIGGER TR_Alerta_Mantenimiento_Preventivo
ON uso_acumulado
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @msg NVARCHAR(500);
   
    SELECT @msg = 'ALERTA: Bicicleta #' + CAST(i.id_bicicleta AS VARCHAR) +
                  ' ha alcanzado ' + CAST(CAST(i.horas_parcial AS INT) AS VARCHAR) +
                  ' horas (umbral: ' + CAST(pm.horas_umbral AS VARCHAR) + ')'
    FROM inserted i
    JOIN bicicleta b ON i.id_bicicleta = b.id_bicicleta
    JOIN parametro_mantenimiento pm ON b.id_parametro = pm.id_parametro
    WHERE i.horas_parcial >= (pm.horas_umbral * pm.porcentaje_alerta / 100);
   
    IF @msg IS NOT NULL
        PRINT @msg;
END;
GO
PRINT '✓ TRIGGER #9: TR_Alerta_Mantenimiento_Preventivo';

------------------------------
--TRIGGERS DE INICIO
------------------------------

-- ============================================================================
-- IMPLEMENTACIÓN DE 14 PROCEDIMIENTOS ALMACENADOS SIN AUDITORÍA CENTRALIZADA
-- ============================================================================
-- Base de Datos: bici_go
-- Versión: 2.0 (Sin tabla auditoria_cambios)
-- Fecha: Noviembre 16, 2025
-- ============================================================================


-- ============================================================================
-- PROCEDIMIENTO 1: Crear Reserva Completa
-- ============================================================================
IF OBJECT_ID('sp_crear_reserva_completa', 'P') IS NOT NULL
    DROP PROCEDURE sp_crear_reserva_completa;
GO

CREATE PROCEDURE sp_crear_reserva_completa
    @id_cliente INT,
    @id_metodo_de_pago INT,
    @fecha_inicio DATE,
    @fecha_fin DATE,
    @id_ruta INT = NULL,
    @id_guia INT = NULL,
    @id_reserva_output INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        BEGIN TRANSACTION;
       
        IF NOT EXISTS (SELECT 1 FROM cliente WHERE id_cliente = @id_cliente)
            THROW 50100, 'Cliente no existe', 1;
       
        IF @fecha_inicio >= @fecha_fin
            THROW 50101, 'Fecha inicio debe ser menor a fecha fin', 1;
       
        INSERT INTO reserva (
            id_cliente, id_metodo_de_pago, fecha_inicio, fecha_fin,
            id_ruta, id_guia, estado, subtotal_general, iva_total, total_general
        )
        VALUES (
            @id_cliente, @id_metodo_de_pago, @fecha_inicio, @fecha_fin,
            @id_ruta, @id_guia, 'pendiente', 0, 0, 0
        );
       
        SET @id_reserva_output = SCOPE_IDENTITY();
       
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

PRINT '✅ PROCEDIMIENTO 1: sp_crear_reserva_completa creado';
GO

-- Eliminar versión anterior si existe
IF OBJECT_ID('sp_calcular_tarifa_reserva', 'P') IS NOT NULL
    DROP PROCEDURE sp_calcular_tarifa_reserva;
GO


-- ============================================================================
-- PROCEDIMIENTO 2: Calcular Tarifa Total de Reserva
-- ============================================================================
CREATE PROCEDURE sp_calcular_tarifa_reserva
    @id_reserva INT,
    @tarifa_base      DECIMAL(12,2) OUTPUT,
    @iva_total        DECIMAL(12,2) OUTPUT,
    @descuento_total  DECIMAL(12,2) OUTPUT,
    @tarifa_guia      DECIMAL(12,2) OUTPUT,
    @total_final      DECIMAL(12,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM reserva WHERE id_reserva = @id_reserva)
            THROW 50102, 'Reserva no existe', 1;

        DECLARE 
            @subtotal  DECIMAL(12,2) = 0,
            @iva       DECIMAL(12,2) = 0,
            @descuento DECIMAL(12,2) = 0,
            @tarGuia   DECIMAL(12,2) = 0;

        -- 1) Totales desde detalle_alquiler
        SELECT
            @subtotal = ISNULL(SUM(subtotal), 0),
            @iva      = ISNULL(SUM(iva_total), 0)
        FROM detalle_alquiler
        WHERE id_reserva = @id_reserva;

        -- 2) Descuentos desde reserva_descuento
        SELECT
            @descuento = ISNULL(SUM(monto_descontado), 0)
        FROM reserva_descuento
        WHERE id_reserva = @id_reserva;

        -- 3) Tarifa guía desde reserva
        SELECT @tarGuia = ISNULL(tarifa_guia, 0)
        FROM reserva
        WHERE id_reserva = @id_reserva;

        -- 4) Asignar outputs (mismo criterio que el trigger)
        SET @tarifa_base      = @subtotal;
        SET @iva_total        = @iva;
        SET @descuento_total  = @descuento;
        SET @tarifa_guia      = @tarGuia;

        SET @total_final =
              @tarifa_base
            - @descuento_total
            + @iva_total
            + @tarifa_guia;

        IF @total_final < 0
            SET @total_final = 0;

        RETURN 0;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO


-- ============================================================================
-- PROCEDIMIENTO 3: Verificar Disponibilidad de Bicicletas
-- ============================================================================
IF OBJECT_ID('sp_verificar_disponibilidad_bicicletas', 'P') IS NOT NULL
    DROP PROCEDURE sp_verificar_disponibilidad_bicicletas;
GO

CREATE PROCEDURE sp_verificar_disponibilidad_bicicletas
    @id_punto_alquiler INT,
    @id_tipo_uso INT,
    @id_tipo_asistencia INT,
    @cantidad_requerida INT,
    @disponibles INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        DECLARE @estado_disponible INT;
       
        SELECT @estado_disponible = id_estado_operativo
        FROM estado_operativo
        WHERE nombre_estado = 'disponible';
       
        SELECT @disponibles = COUNT(*)
        FROM bicicleta
        WHERE id_punto_alquiler = @id_punto_alquiler
        AND id_tipo_uso = @id_tipo_uso
        AND id_tipo_asistencia = @id_tipo_asistencia
        AND id_estado_operativo = @estado_disponible;
       
        RETURN 0;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

PRINT '✅ PROCEDIMIENTO 3: sp_verificar_disponibilidad_bicicletas creado';
GO

-- ============================================================================
-- PROCEDIMIENTO 4: Registrar Mantenimiento de Bicicleta
-- ============================================================================
IF OBJECT_ID('sp_registrar_mantenimiento_bicicleta', 'P') IS NOT NULL
    DROP PROCEDURE sp_registrar_mantenimiento_bicicleta;
GO

CREATE PROCEDURE sp_registrar_mantenimiento_bicicleta
    @id_bicicleta INT,
    @tipo_mantenimiento VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        BEGIN TRANSACTION;
       
        IF NOT EXISTS (SELECT 1 FROM bicicleta WHERE id_bicicleta = @id_bicicleta)
            THROW 50103, 'Bicicleta no existe', 1;
       
        -- Resetear contadores
        UPDATE uso_acumulado
        SET km_parcial = 0,
            horas_parcial = 0,
            fecha_ultimo_mantenimiento = GETDATE()
        WHERE id_bicicleta = @id_bicicleta;
       
        -- Cambiar a estado disponible y excelente
        UPDATE bicicleta
        SET id_estado_operativo = (
                SELECT id_estado_operativo
                FROM estado_operativo
                WHERE nombre_estado = 'disponible'
            ),
            id_estado_fisico = (
                SELECT id_estado_fisico
                FROM estado_fisico
                WHERE condicion = 'excelente'
            )
        WHERE id_bicicleta = @id_bicicleta;
       
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

PRINT '✅ PROCEDIMIENTO 4: sp_registrar_mantenimiento_bicicleta creado';
GO

-- ============================================================================
-- PROCEDIMIENTO 5: Generar Reporte de Disponibilidad
-- ============================================================================
IF OBJECT_ID('sp_generar_reporte_disponibilidad', 'P') IS NOT NULL
    DROP PROCEDURE sp_generar_reporte_disponibilidad;
GO

CREATE PROCEDURE sp_generar_reporte_disponibilidad
    @id_punto_alquiler INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        SELECT
            pa.id_punto_alquiler,
            pa.nombre AS punto_nombre,
            tu.nombre AS tipo_uso,
            ta.nombre AS tipo_asistencia,
            eo.nombre_estado,
            COUNT(b.id_bicicleta) AS cantidad
        FROM punto_alquiler pa
        LEFT JOIN bicicleta b ON b.id_punto_alquiler = pa.id_punto_alquiler
        LEFT JOIN tipo_uso tu ON tu.id_tipo_uso = b.id_tipo_uso
        LEFT JOIN tipo_asistencia ta ON ta.id_tipo_asistencia = b.id_tipo_asistencia
        LEFT JOIN estado_operativo eo ON eo.id_estado_operativo = b.id_estado_operativo
        WHERE (@id_punto_alquiler IS NULL OR pa.id_punto_alquiler = @id_punto_alquiler)
        GROUP BY
            pa.id_punto_alquiler, pa.nombre, tu.nombre, ta.nombre, eo.nombre_estado
        ORDER BY pa.nombre;
       
        RETURN 0;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

PRINT '✅ PROCEDIMIENTO 5: sp_generar_reporte_disponibilidad creado';
GO

-- ============================================================================
-- PROCEDIMIENTO 6: Actualizar Calificación de Ruta
-- ============================================================================
IF OBJECT_ID('sp_actualizar_calificacion_ruta', 'P') IS NOT NULL
    DROP PROCEDURE sp_actualizar_calificacion_ruta;
GO

CREATE PROCEDURE sp_actualizar_calificacion_ruta
    @id_ruta INT,
    @calificacion_promedio DECIMAL(3,2) OUTPUT,
    @total_resenas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM ruta_turistica WHERE id_ruta = @id_ruta)
            THROW 50104, 'Ruta no existe', 1;
       
        SELECT @calificacion_promedio = AVG(CAST(calificacion AS DECIMAL(3,2))),
               @total_resenas = COUNT(*)
        FROM resenia_ruta
        WHERE id_ruta = @id_ruta
        AND calificacion IS NOT NULL
        AND estado = 'activo';
       
        IF @total_resenas IS NULL
        BEGIN
            SET @calificacion_promedio = NULL;
            SET @total_resenas = 0;
        END
       
        UPDATE ruta_turistica
        SET calificacion_promedio = @calificacion_promedio,
            total_resenas = @total_resenas
        WHERE id_ruta = @id_ruta;
       
        RETURN 0;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

PRINT '✅ PROCEDIMIENTO 6: sp_actualizar_calificacion_ruta creado';
GO

-- ============================================================================
-- PROCEDIMIENTO 7: Cancelar Reserva
-- ============================================================================
IF OBJECT_ID('sp_cancelar_reserva', 'P') IS NOT NULL
    DROP PROCEDURE sp_cancelar_reserva;
GO

CREATE PROCEDURE sp_cancelar_reserva
    @id_reserva INT,
    @razon_cancelacion VARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        BEGIN TRANSACTION;
       
        DECLARE @estado_actual VARCHAR(20);
       
        SELECT @estado_actual = estado FROM reserva WHERE id_reserva = @id_reserva;
       
        IF @estado_actual IS NULL
            THROW 50105, 'Reserva no existe', 1;
       
        IF @estado_actual = 'cancelada'
            THROW 50106, 'Reserva ya está cancelada', 1;
       
        UPDATE reserva
        SET estado = 'cancelada'
        WHERE id_reserva = @id_reserva;
       
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

PRINT '✅ PROCEDIMIENTO 7: sp_cancelar_reserva creado';
GO

-- ============================================================================
-- PROCEDIMIENTO 8: Agregar Detalle a Reserva
-- ============================================================================
IF OBJECT_ID('sp_agregar_detalle_reserva', 'P') IS NOT NULL
    DROP PROCEDURE sp_agregar_detalle_reserva;
GO

CREATE PROCEDURE sp_agregar_detalle_reserva
    @id_reserva INT,
    @id_bicicleta INT,
    @id_plan INT,
    @id_tarifa INT,
    @tarifa_unitaria DECIMAL(10,2),
    @cantidad INT,
    @fecha_inicio DATETIME,
    @fecha_fin DATETIME,
    @id_detalle_output INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        BEGIN TRANSACTION;
       
        DECLARE @subtotal DECIMAL(10,2);
        DECLARE @iva DECIMAL(10,2);
       
        IF NOT EXISTS (SELECT 1 FROM reserva WHERE id_reserva = @id_reserva)
            THROW 50107, 'Reserva no existe', 1;
       
        IF @cantidad <= 0
            THROW 50108, 'Cantidad debe ser mayor a 0', 1;
       
        IF @fecha_fin <= @fecha_inicio
            THROW 50109, 'Fecha fin debe ser posterior a inicio', 1;
       
        SET @subtotal = @tarifa_unitaria * @cantidad;
        SET @iva = @subtotal * 0.19;
       
        INSERT INTO detalle_alquiler
        (id_reserva, id_bicicleta, id_plan, id_tarifa, tarifa_unitaria,
         cantidad_unidades, subtotal, porcentaje_iva, iva_total,
         total_item, fecha_inicio, fecha_fin)
        VALUES
        (@id_reserva, @id_bicicleta, @id_plan, @id_tarifa, @tarifa_unitaria,
         @cantidad, @subtotal, 19, @iva, @subtotal + @iva,
         @fecha_inicio, @fecha_fin);
       
        SET @id_detalle_output = SCOPE_IDENTITY();
       
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

PRINT '✅ PROCEDIMIENTO 8: sp_agregar_detalle_reserva creado';
GO

-- ============================================================================
-- PROCEDIMIENTO 9: Validar Condiciones de Bicicleta
-- ============================================================================
IF OBJECT_ID('sp_validar_condiciones_bicicleta', 'P') IS NOT NULL
    DROP PROCEDURE sp_validar_condiciones_bicicleta;
GO

CREATE PROCEDURE sp_validar_condiciones_bicicleta
    @id_bicicleta INT,
    @es_valida BIT OUTPUT,
    @mensaje VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        SET @es_valida = 1;
        SET @mensaje = 'Validaciones completadas';
       
        IF NOT EXISTS (SELECT 1 FROM bicicleta WHERE id_bicicleta = @id_bicicleta)
        BEGIN
            SET @es_valida = 0;
            SET @mensaje = 'Bicicleta no existe';
            RETURN 1;
        END
       
        IF EXISTS (
            SELECT 1 FROM bicicleta b
            INNER JOIN estado_fisico ef ON ef.id_estado_fisico = b.id_estado_fisico
            WHERE b.id_bicicleta = @id_bicicleta
            AND ef.condicion = 'dañada'
        )
        BEGIN
            SET @es_valida = 0;
            SET @mensaje = 'Bicicleta dañada, no disponible';
            RETURN 0;
        END
       
        RETURN 0;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

PRINT '✅ PROCEDIMIENTO 9: sp_validar_condiciones_bicicleta creado';
GO

-- ============================================================================
-- PROCEDIMIENTO 10: Sincronizar Horarios Excepcionales
-- ============================================================================
IF OBJECT_ID('sp_sincronizar_horarios_excepcionales', 'P') IS NOT NULL
    DROP PROCEDURE sp_sincronizar_horarios_excepcionales;
GO

CREATE PROCEDURE sp_sincronizar_horarios_excepcionales
    @id_punto_alquiler INT,
    @sincronizadas INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        SET @sincronizadas = 0;
       
        UPDATE eh
        SET eh.hora_apertura = ddh.hora_apertura,
            eh.hora_cierre = ddh.hora_cierre
        FROM excepcion_horario eh
        INNER JOIN detalle_dia_horario ddh
            ON ddh.id_punto_alquiler = eh.id_punto_alquiler
        WHERE eh.id_punto_alquiler = @id_punto_alquiler
        AND eh.fecha_excepcion > CAST(GETDATE() AS DATE);
       
        SET @sincronizadas = @@ROWCOUNT;
       
        RETURN 0;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

PRINT '✅ PROCEDIMIENTO 10: sp_sincronizar_horarios_excepcionales creado';
GO

-- ============================================================================
-- PROCEDIMIENTO 11: Generar Reporte de Mantenimiento Preventivo
-- ============================================================================
IF OBJECT_ID('sp_reporte_mantenimiento_preventivo', 'P') IS NOT NULL
    DROP PROCEDURE sp_reporte_mantenimiento_preventivo;
GO

CREATE PROCEDURE sp_reporte_mantenimiento_preventivo
    @id_punto_alquiler INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        SELECT
            b.id_bicicleta,
            b.codigo_unico,
            b.marca_comercial,
            b.modelo,
            ua.km_total,
            ua.horas_total,
            ua.km_parcial,
            ua.horas_parcial,
            pm.km_umbral,
            pm.horas_umbral,
            CAST(ROUND(ua.km_parcial * 100.0 / NULLIF(pm.km_umbral, 0), 2)
                AS DECIMAL(5,2)) AS porcentaje_km,
            CAST(ROUND(ua.horas_parcial * 100.0 / NULLIF(pm.horas_umbral, 0), 2)
                AS DECIMAL(5,2)) AS porcentaje_horas,
            CASE
                WHEN (ua.km_parcial * 100.0 / NULLIF(pm.km_umbral, 0)) >= 100
                    THEN 'CRÍTICA'
                WHEN (ua.km_parcial * 100.0 / NULLIF(pm.km_umbral, 0)) >= 80
                    THEN 'ALERTA'
                ELSE 'OK'
            END AS estado
        FROM bicicleta b
        INNER JOIN uso_acumulado ua ON ua.id_bicicleta = b.id_bicicleta
        INNER JOIN parametro_mantenimiento pm ON pm.id_parametro = b.id_parametro
        WHERE (@id_punto_alquiler IS NULL OR b.id_punto_alquiler = @id_punto_alquiler)
        AND (ua.km_parcial * 100.0 / NULLIF(pm.km_umbral, 0) >= 75
             OR ua.horas_parcial * 100.0 / NULLIF(pm.horas_umbral, 0) >= 75)
        ORDER BY porcentaje_km DESC;
       
        RETURN 0;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

PRINT '✅ PROCEDIMIENTO 11: sp_reporte_mantenimiento_preventivo creado';
GO

-- ============================================================================
-- PROCEDIMIENTO 12: Cambiar Estado de Bicicleta
-- ============================================================================
IF OBJECT_ID('sp_cambiar_estado_bicicleta', 'P') IS NOT NULL
    DROP PROCEDURE sp_cambiar_estado_bicicleta;
GO

CREATE PROCEDURE sp_cambiar_estado_bicicleta
    @id_bicicleta INT,
    @nuevo_estado_operativo VARCHAR(20),
    @motivo VARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        BEGIN TRANSACTION;
       
        DECLARE @id_estado_operativo INT;
       
        SELECT @id_estado_operativo = id_estado_operativo
        FROM estado_operativo
        WHERE nombre_estado = @nuevo_estado_operativo;
       
        IF @id_estado_operativo IS NULL
            THROW 50110, 'Estado operativo inválido', 1;
       
        UPDATE bicicleta
        SET id_estado_operativo = @id_estado_operativo
        WHERE id_bicicleta = @id_bicicleta;
       
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

PRINT '✅ PROCEDIMIENTO 12: sp_cambiar_estado_bicicleta creado';
GO

-- ============================================================================
-- PROCEDIMIENTO 13: Validar Disponibilidad de Guía
-- ============================================================================
IF OBJECT_ID('sp_validar_disponibilidad_guia', 'P') IS NOT NULL
    DROP PROCEDURE sp_validar_disponibilidad_guia;
GO

CREATE PROCEDURE sp_validar_disponibilidad_guia
    @id_guia INT,
    @id_ruta INT,
    @fecha_solicitada DATE,
    @disponible BIT OUTPUT,
    @motivo VARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        SET @disponible = 1;
        SET @motivo = '';
       
        IF NOT EXISTS (SELECT 1 FROM guia_turistico WHERE id_guia = @id_guia)
        BEGIN
            SET @disponible = 0;
            SET @motivo = 'Guía no existe';
            RETURN 1;
        END
       
        IF NOT EXISTS (SELECT 1 FROM guia_ruta WHERE id_guia = @id_guia AND id_ruta = @id_ruta)
        BEGIN
            SET @disponible = 0;
            SET @motivo = 'Guía no asignado a esta ruta';
            RETURN 1;
        END
       
        RETURN 0;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

PRINT '✅ PROCEDIMIENTO 13: sp_validar_disponibilidad_guia creado';
GO

-- ============================================================================
-- PROCEDIMIENTO 14: Generar Recibo de Reserva
-- ============================================================================
IF OBJECT_ID('sp_generar_recibo_reserva', 'P') IS NOT NULL
    DROP PROCEDURE sp_generar_recibo_reserva;
GO

CREATE PROCEDURE sp_generar_recibo_reserva
    @id_reserva INT
AS
BEGIN
    SET NOCOUNT ON;
   
    BEGIN TRY
        SELECT
            r.id_reserva,
            r.fecha_reserva,
            r.fecha_inicio,
            r.fecha_fin,
            CONCAT(p.nombre, ' ', p.apellido) AS cliente_nombre,
            p.email,
            p.telefono,
            COUNT(da.id_detalle_alquiler) AS cantidad_detalles,
            ISNULL(SUM(da.subtotal), 0) AS subtotal,
            ISNULL(SUM(da.iva_total), 0) AS iva,
            ISNULL(SUM(da.total_item), 0) AS total,
            r.estado,
            mp.nombre AS metodo_pago
        FROM reserva r
        LEFT JOIN detalle_alquiler da ON da.id_reserva = r.id_reserva
        LEFT JOIN cliente c ON c.id_cliente = r.id_cliente
        LEFT JOIN persona p ON p.id_persona = c.id_cliente
        LEFT JOIN metodo_de_pago mp ON mp.id_metodo_de_pago = r.id_metodo_de_pago
        WHERE r.id_reserva = @id_reserva
        GROUP BY
            r.id_reserva, r.fecha_reserva, r.fecha_inicio, r.fecha_fin,
            p.nombre, p.apellido, p.email, p.telefono, r.estado, mp.nombre;
       
        RETURN 0;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO

PRINT '✅ PROCEDIMIENTO 14: sp_generar_recibo_reserva creado';
GO



