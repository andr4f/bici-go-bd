
SET NOCOUNT ON;
GO

/* ==========================
   PRIMARY KEYS
   ========================== */
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_pais')
ALTER TABLE dbo.pais ADD CONSTRAINT PK_pais PRIMARY KEY (id_pais);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_ciudad')
ALTER TABLE dbo.ciudad ADD CONSTRAINT PK_ciudad PRIMARY KEY (id_ciudad);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_punto_alquiler')
ALTER TABLE dbo.punto_alquiler ADD CONSTRAINT PK_punto_alquiler PRIMARY KEY (id_punto_alquiler);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_tipo_uso')
ALTER TABLE dbo.tipo_uso ADD CONSTRAINT PK_tipo_uso PRIMARY KEY (id_tipo_uso);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_tipo_asistencia')
ALTER TABLE dbo.tipo_asistencia ADD CONSTRAINT PK_tipo_asistencia PRIMARY KEY (id_tipo_asistencia);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_plan')
ALTER TABLE dbo.[plan] ADD CONSTRAINT PK_plan PRIMARY KEY (id_plan);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_etiqueta')
ALTER TABLE dbo.etiqueta ADD CONSTRAINT PK_etiqueta PRIMARY KEY (id_etiqueta);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_administrador')
ALTER TABLE dbo.administrador ADD CONSTRAINT PK_administrador PRIMARY KEY (id_admin);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_bicicleta')
ALTER TABLE dbo.bicicleta ADD CONSTRAINT PK_bicicleta PRIMARY KEY (id_bicicleta);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_clasificacion_uso_actual')
ALTER TABLE dbo.clasificacion_uso_actual ADD CONSTRAINT PK_clasificacion_uso_actual PRIMARY KEY (id_bicicleta);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_clasificacion_asistencia_actual')
ALTER TABLE dbo.clasificacion_asistencia_actual ADD CONSTRAINT PK_clasificacion_asistencia_actual PRIMARY KEY (id_bicicleta);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_estado_operativo_actual')
ALTER TABLE dbo.estado_operativo_actual ADD CONSTRAINT PK_estado_operativo_actual PRIMARY KEY (id_bicicleta);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_estado_fisico_actual')
ALTER TABLE dbo.estado_fisico_actual ADD CONSTRAINT PK_estado_fisico_actual PRIMARY KEY (id_bicicleta);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_bicicleta_etiqueta_actual')
ALTER TABLE dbo.bicicleta_etiqueta_actual ADD CONSTRAINT PK_bicicleta_etiqueta_actual PRIMARY KEY (id_bicicleta, id_etiqueta);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_ubicacion_actual')
ALTER TABLE dbo.ubicacion_actual ADD CONSTRAINT PK_ubicacion_actual PRIMARY KEY (id_bicicleta);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_tarifa_actual')
ALTER TABLE dbo.tarifa_actual ADD CONSTRAINT PK_tarifa_actual PRIMARY KEY (id_bicicleta, id_plan);
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_clasificacion_uso_hist')
ALTER TABLE dbo.clasificacion_uso_hist ADD CONSTRAINT PK_clasificacion_uso_hist PRIMARY KEY (id_hist);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_clasificacion_asistencia_hist')
ALTER TABLE dbo.clasificacion_asistencia_hist ADD CONSTRAINT PK_clasificacion_asistencia_hist PRIMARY KEY (id_hist);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_estado_operativo_hist')
ALTER TABLE dbo.estado_operativo_hist ADD CONSTRAINT PK_estado_operativo_hist PRIMARY KEY (id_hist);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_estado_fisico_hist')
ALTER TABLE dbo.estado_fisico_hist ADD CONSTRAINT PK_estado_fisico_hist PRIMARY KEY (id_hist);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_bicicleta_etiqueta_hist')
ALTER TABLE dbo.bicicleta_etiqueta_hist ADD CONSTRAINT PK_bicicleta_etiqueta_hist PRIMARY KEY (id_hist);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_ubicacion_hist')
ALTER TABLE dbo.ubicacion_hist ADD CONSTRAINT PK_ubicacion_hist PRIMARY KEY (id_hist);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'PK_tarifa_hist')
ALTER TABLE dbo.tarifa_hist ADD CONSTRAINT PK_tarifa_hist PRIMARY KEY (id_hist);
GO

/* ==========================
   UNIQUE CONSTRAINTS
   ========================== */
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UQ_pais_nombre')
ALTER TABLE dbo.pais ADD CONSTRAINT UQ_pais_nombre UNIQUE (nombre);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UQ_tipo_uso_nombre')
ALTER TABLE dbo.tipo_uso ADD CONSTRAINT UQ_tipo_uso_nombre UNIQUE (nombre_tipo_uso);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UQ_tipo_asistencia_nombre')
ALTER TABLE dbo.tipo_asistencia ADD CONSTRAINT UQ_tipo_asistencia_nombre UNIQUE (nombre_tipo_asistencia);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UQ_plan_nombre')
ALTER TABLE dbo.[plan] ADD CONSTRAINT UQ_plan_nombre UNIQUE (nombre);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UQ_etiqueta_nombre')
ALTER TABLE dbo.etiqueta ADD CONSTRAINT UQ_etiqueta_nombre UNIQUE (nombre);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UQ_administrador_email')
ALTER TABLE dbo.administrador ADD CONSTRAINT UQ_administrador_email UNIQUE (email);
GO
IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = 'UQ_bicicleta_codigo_unico')
ALTER TABLE dbo.bicicleta ADD CONSTRAINT UQ_bicicleta_codigo_unico UNIQUE (codigo_unico);
GO

/* ==========================
   FOREIGN KEYS
   ========================== */
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ciudad_pais')
ALTER TABLE dbo.ciudad
    ADD CONSTRAINT FK_ciudad_pais FOREIGN KEY (id_pais) REFERENCES dbo.pais(id_pais)
    ON UPDATE CASCADE ON DELETE NO ACTION;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_punto_alquiler_ciudad')
ALTER TABLE dbo.punto_alquiler
    ADD CONSTRAINT FK_punto_alquiler_ciudad FOREIGN KEY (id_ciudad) REFERENCES dbo.ciudad(id_ciudad)
    ON UPDATE CASCADE ON DELETE NO ACTION;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_bicicleta_administrador')
ALTER TABLE dbo.bicicleta
    ADD CONSTRAINT FK_bicicleta_administrador FOREIGN KEY (id_admin) REFERENCES dbo.administrador(id_admin)
    ON UPDATE CASCADE ON DELETE NO ACTION;
GO

-- Clasificación uso
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_clas_uso_actual_bicicleta')
ALTER TABLE dbo.clasificacion_uso_actual
    ADD CONSTRAINT FK_clas_uso_actual_bicicleta FOREIGN KEY (id_bicicleta) REFERENCES dbo.bicicleta(id_bicicleta)
    ON UPDATE CASCADE ON DELETE CASCADE;
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_clas_uso_actual_tipo')
ALTER TABLE dbo.clasificacion_uso_actual
    ADD CONSTRAINT FK_clas_uso_actual_tipo FOREIGN KEY (id_tipo_uso) REFERENCES dbo.tipo_uso(id_tipo_uso)
    ON UPDATE CASCADE ON DELETE NO ACTION;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_clas_uso_hist_bicicleta')
ALTER TABLE dbo.clasificacion_uso_hist
    ADD CONSTRAINT FK_clas_uso_hist_bicicleta FOREIGN KEY (id_bicicleta) REFERENCES dbo.bicicleta(id_bicicleta)
    ON UPDATE CASCADE ON DELETE CASCADE;
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_clas_uso_hist_tipo')
ALTER TABLE dbo.clasificacion_uso_hist
    ADD CONSTRAINT FK_clas_uso_hist_tipo FOREIGN KEY (id_tipo_uso) REFERENCES dbo.tipo_uso(id_tipo_uso)
    ON UPDATE CASCADE ON DELETE NO ACTION;
GO

-- Clasificación asistencia
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_clas_asist_actual_bicicleta')
ALTER TABLE dbo.clasificacion_asistencia_actual
    ADD CONSTRAINT FK_clas_asist_actual_bicicleta FOREIGN KEY (id_bicicleta) REFERENCES dbo.bicicleta(id_bicicleta)
    ON UPDATE CASCADE ON DELETE CASCADE;
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_clas_asist_actual_tipo')
ALTER TABLE dbo.clasificacion_asistencia_actual
    ADD CONSTRAINT FK_clas_asist_actual_tipo FOREIGN KEY (id_tipo_asistencia) REFERENCES dbo.tipo_asistencia(id_tipo_asistencia)
    ON UPDATE CASCADE ON DELETE NO ACTION;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_clas_asist_hist_bicicleta')
ALTER TABLE dbo.clasificacion_asistencia_hist
    ADD CONSTRAINT FK_clas_asist_hist_bicicleta FOREIGN KEY (id_bicicleta) REFERENCES dbo.bicicleta(id_bicicleta)
    ON UPDATE CASCADE ON DELETE CASCADE;
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_clas_asist_hist_tipo')
ALTER TABLE dbo.clasificacion_asistencia_hist
    ADD CONSTRAINT FK_clas_asist_hist_tipo FOREIGN KEY (id_tipo_asistencia) REFERENCES dbo.tipo_asistencia(id_tipo_asistencia)
    ON UPDATE CASCADE ON DELETE NO ACTION;
GO

-- Estados
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_estado_operativo_actual_bicicleta')
ALTER TABLE dbo.estado_operativo_actual
    ADD CONSTRAINT FK_estado_operativo_actual_bicicleta FOREIGN KEY (id_bicicleta) REFERENCES dbo.bicicleta(id_bicicleta)
    ON UPDATE CASCADE ON DELETE CASCADE;
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_estado_operativo_hist_bicicleta')
ALTER TABLE dbo.estado_operativo_hist
    ADD CONSTRAINT FK_estado_operativo_hist_bicicleta FOREIGN KEY (id_bicicleta) REFERENCES dbo.bicicleta(id_bicicleta)
    ON UPDATE CASCADE ON DELETE CASCADE;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_estado_fisico_actual_bicicleta')
ALTER TABLE dbo.estado_fisico_actual
    ADD CONSTRAINT FK_estado_fisico_actual_bicicleta FOREIGN KEY (id_bicicleta) REFERENCES dbo.bicicleta(id_bicicleta)
    ON UPDATE CASCADE ON DELETE CASCADE;
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_estado_fisico_hist_bicicleta')
ALTER TABLE dbo.estado_fisico_hist
    ADD CONSTRAINT FK_estado_fisico_hist_bicicleta FOREIGN KEY (id_bicicleta) REFERENCES dbo.bicicleta(id_bicicleta)
    ON UPDATE CASCADE ON DELETE CASCADE;
GO

-- Etiquetas
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_bici_etq_actual_bicicleta')
ALTER TABLE dbo.bicicleta_etiqueta_actual
    ADD CONSTRAINT FK_bici_etq_actual_bicicleta FOREIGN KEY (id_bicicleta) REFERENCES dbo.bicicleta(id_bicicleta)
    ON UPDATE CASCADE ON DELETE CASCADE;
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_bici_etq_actual_etiqueta')
ALTER TABLE dbo.bicicleta_etiqueta_actual
    ADD CONSTRAINT FK_bici_etq_actual_etiqueta FOREIGN KEY (id_etiqueta) REFERENCES dbo.etiqueta(id_etiqueta)
    ON UPDATE CASCADE ON DELETE NO ACTION;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_bici_etq_hist_bicicleta')
ALTER TABLE dbo.bicicleta_etiqueta_hist
    ADD CONSTRAINT FK_bici_etq_hist_bicicleta FOREIGN KEY (id_bicicleta) REFERENCES dbo.bicicleta(id_bicicleta)
    ON UPDATE CASCADE ON DELETE CASCADE;
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_bici_etq_hist_etiqueta')
ALTER TABLE dbo.bicicleta_etiqueta_hist
    ADD CONSTRAINT FK_bici_etq_hist_etiqueta FOREIGN KEY (id_etiqueta) REFERENCES dbo.etiqueta(id_etiqueta)
    ON UPDATE CASCADE ON DELETE NO ACTION;
GO

-- Ubicación
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ubic_actual_bicicleta')
ALTER TABLE dbo.ubicacion_actual
    ADD CONSTRAINT FK_ubic_actual_bicicleta FOREIGN KEY (id_bicicleta) REFERENCES dbo.bicicleta(id_bicicleta)
    ON UPDATE CASCADE ON DELETE CASCADE;
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ubic_actual_punto')
ALTER TABLE dbo.ubicacion_actual
    ADD CONSTRAINT FK_ubic_actual_punto FOREIGN KEY (id_punto_alquiler) REFERENCES dbo.punto_alquiler(id_punto_alquiler)
    ON UPDATE CASCADE ON DELETE NO ACTION;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ubic_hist_bicicleta')
ALTER TABLE dbo.ubicacion_hist
    ADD CONSTRAINT FK_ubic_hist_bicicleta FOREIGN KEY (id_bicicleta) REFERENCES dbo.bicicleta(id_bicicleta)
    ON UPDATE CASCADE ON DELETE CASCADE;
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_ubic_hist_punto')
ALTER TABLE dbo.ubicacion_hist
    ADD CONSTRAINT FK_ubic_hist_punto FOREIGN KEY (id_punto_alquiler) REFERENCES dbo.punto_alquiler(id_punto_alquiler)
    ON UPDATE CASCADE ON DELETE NO ACTION;
GO

-- Tarifas
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_tarifa_actual_bicicleta')
ALTER TABLE dbo.tarifa_actual
    ADD CONSTRAINT FK_tarifa_actual_bicicleta FOREIGN KEY (id_bicicleta) REFERENCES dbo.bicicleta(id_bicicleta)
    ON UPDATE CASCADE ON DELETE CASCADE;
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_tarifa_actual_plan')
ALTER TABLE dbo.tarifa_actual
    ADD CONSTRAINT FK_tarifa_actual_plan FOREIGN KEY (id_plan) REFERENCES dbo.[plan](id_plan)
    ON UPDATE CASCADE ON DELETE NO ACTION;
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_tarifa_hist_bicicleta')
ALTER TABLE dbo.tarifa_hist
    ADD CONSTRAINT FK_tarifa_hist_bicicleta FOREIGN KEY (id_bicicleta) REFERENCES dbo.bicicleta(id_bicicleta)
    ON UPDATE CASCADE ON DELETE CASCADE;
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_tarifa_hist_plan')
ALTER TABLE dbo.tarifa_hist
    ADD CONSTRAINT FK_tarifa_hist_plan FOREIGN KEY (id_plan) REFERENCES dbo.[plan](id_plan)
    ON UPDATE CASCADE ON DELETE NO ACTION;
GO

/* ==========================
   CHECK CONSTRAINTS
   ========================== */
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CHK_ciudad_latitud')
ALTER TABLE dbo.ciudad ADD CONSTRAINT CHK_ciudad_latitud CHECK (latitud BETWEEN -90 AND 90);
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CHK_ciudad_longitud')
ALTER TABLE dbo.ciudad ADD CONSTRAINT CHK_ciudad_longitud CHECK (longitud BETWEEN -180 AND 180);
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CHK_pais_moneda')
ALTER TABLE dbo.pais ADD CONSTRAINT CHK_pais_moneda CHECK (moneda_oficial LIKE '[A-Z][A-Z][A-Z]');
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CHK_admin_email')
ALTER TABLE dbo.administrador ADD CONSTRAINT CHK_admin_email CHECK (email LIKE '%@%._%');
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CHK_bici_anio')
ALTER TABLE dbo.bicicleta ADD CONSTRAINT CHK_bici_anio CHECK (anio_fabricacion BETWEEN 1990 AND YEAR(GETDATE()));
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CHK_bici_tamano')
ALTER TABLE dbo.bicicleta ADD CONSTRAINT CHK_bici_tamano CHECK (tamano_marco IN ('XS','S','M','L','XL','XXL'));
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CHK_estado_operativo_actual')
ALTER TABLE dbo.estado_operativo_actual ADD CONSTRAINT CHK_estado_operativo_actual CHECK (estado IN ('disponible','en_uso','mantenimiento','dañada','fuera_servicio'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CHK_estado_operativo_hist')
ALTER TABLE dbo.estado_operativo_hist ADD CONSTRAINT CHK_estado_operativo_hist CHECK (estado IN ('disponible','en_uso','mantenimiento','dañada','fuera_servicio'));
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CHK_estado_fisico_actual')
ALTER TABLE dbo.estado_fisico_actual ADD CONSTRAINT CHK_estado_fisico_actual CHECK (condicion IN ('excelente','buena','regular','mala','requiere_revision'));
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CHK_estado_fisico_hist')
ALTER TABLE dbo.estado_fisico_hist ADD CONSTRAINT CHK_estado_fisico_hist CHECK (condicion IN ('excelente','buena','regular','mala','requiere_revision'));
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CHK_tarifa_actual_moneda')
ALTER TABLE dbo.tarifa_actual ADD CONSTRAINT CHK_tarifa_actual_moneda CHECK (moneda LIKE '[A-Z][A-Z][A-Z]');
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CHK_tarifa_hist_moneda')
ALTER TABLE dbo.tarifa_hist ADD CONSTRAINT CHK_tarifa_hist_moneda CHECK (moneda LIKE '[A-Z][A-Z][A-Z]');
GO
