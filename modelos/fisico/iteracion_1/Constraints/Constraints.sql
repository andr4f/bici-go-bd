
ALTER TABLE dbo.administrador 
  ADD CONSTRAINT PK_administrador PRIMARY KEY (id_admin);
GO

ALTER TABLE dbo.tipo_uso 
  ADD CONSTRAINT PK_tipo_uso PRIMARY KEY (id_tipo_uso);
GO

ALTER TABLE dbo.tipo_asistencia 
  ADD CONSTRAINT PK_tipo_asistencia PRIMARY KEY (id_tipo_asistencia);
GO

ALTER TABLE dbo.bicicleta 
  ADD CONSTRAINT PK_bicicleta PRIMARY KEY (id_bicicleta);
GO

ALTER TABLE dbo.estado_operativo 
  ADD CONSTRAINT PK_estado_operativo PRIMARY KEY (id_estado_operativo);
GO

ALTER TABLE dbo.estado_fisico 
  ADD CONSTRAINT PK_estado_fisico PRIMARY KEY (id_estado_fisico);
GO

ALTER TABLE dbo.bicicleta
  ADD CONSTRAINT FK_bicicleta_administrador
  FOREIGN KEY (id_admin)
  REFERENCES dbo.administrador(id_admin)
  ON DELETE NO ACTION
  ON UPDATE CASCADE;
GO

ALTER TABLE dbo.bicicleta
  ADD CONSTRAINT FK_bicicleta_tipo_uso
  FOREIGN KEY (id_tipo_uso)
  REFERENCES dbo.tipo_uso(id_tipo_uso)
  ON DELETE NO ACTION
  ON UPDATE CASCADE;
GO

ALTER TABLE dbo.bicicleta
  ADD CONSTRAINT FK_bicicleta_tipo_asistencia
  FOREIGN KEY (id_tipo_asistencia)
  REFERENCES dbo.tipo_asistencia(id_tipo_asistencia)
  ON DELETE NO ACTION
  ON UPDATE CASCADE;
GO

ALTER TABLE dbo.estado_operativo
  ADD CONSTRAINT FK_estado_operativo_bicicleta
  FOREIGN KEY (id_bicicleta)
  REFERENCES dbo.bicicleta(id_bicicleta)
  ON DELETE CASCADE
  ON UPDATE CASCADE;
GO

ALTER TABLE dbo.estado_fisico
  ADD CONSTRAINT FK_estado_fisico_bicicleta
  FOREIGN KEY (id_bicicleta)
  REFERENCES dbo.bicicleta(id_bicicleta)
  ON DELETE CASCADE
  ON UPDATE CASCADE;
GO

ALTER TABLE dbo.administrador
  ADD CONSTRAINT UQ_administrador_email UNIQUE (email);
GO

ALTER TABLE dbo.tipo_uso
  ADD CONSTRAINT UQ_tipo_uso_nombre UNIQUE (nombre_tipo_uso);
GO

ALTER TABLE dbo.tipo_asistencia
  ADD CONSTRAINT UQ_tipo_asistencia_nombre UNIQUE (nombre_tipo_asistencia);
GO


ALTER TABLE dbo.administrador
  ADD CONSTRAINT CK_administrador_email
  CHECK (email LIKE '%_@_%._%'); 
GO

ALTER TABLE dbo.bicicleta
  ADD CONSTRAINT CK_bicicleta_anio
  CHECK (anio_fabricacion BETWEEN 1990 AND YEAR(GETDATE()));
GO

ALTER TABLE dbo.bicicleta
  ADD CONSTRAINT CK_bicicleta_tamano_marco
  CHECK (tamano_marco IN ('XS','S','M','L','XL','XXL'));
GO

ALTER TABLE dbo.estado_operativo
  ADD CONSTRAINT CK_estado_operativo_estado
  CHECK (estado IN ('disponible','en_uso','mantenimiento','danada','fuera_servicio'));
GO

ALTER TABLE dbo.estado_fisico
  ADD CONSTRAINT CK_estado_fisico_condicion
  CHECK (condicion IN ('excelente','buena','regular','mala','requiere_revision'));
GO