/* 1) ADMINISTRADOR */
IF OBJECT_ID('dbo.administrador','U') IS NULL
CREATE TABLE dbo.administrador (
    id_admin        INT IDENTITY(1,1) NOT NULL,
    nombre          VARCHAR(100)      NOT NULL,
    apellido        VARCHAR(100)      NOT NULL,
    email           VARCHAR(255)      NOT NULL,
    fecha_registro  DATE              NOT NULL CONSTRAINT DF_administrador_fecha DEFAULT (CAST(GETDATE() AS DATE)),
    CONSTRAINT PK_administrador PRIMARY KEY (id_admin),
    CONSTRAINT UQ_administrador_email UNIQUE (email)
);

/* 2) TIPO_USO */
IF OBJECT_ID('dbo.tipo_uso','U') IS NULL
CREATE TABLE dbo.tipo_uso (
    id_tipo_uso      INT IDENTITY(1,1) NOT NULL,
    nombre_tipo_uso  VARCHAR(30)       NOT NULL,
    descripcion      VARCHAR(100)      NULL,
    CONSTRAINT PK_tipo_uso PRIMARY KEY (id_tipo_uso),
    CONSTRAINT UQ_tipo_uso_nombre UNIQUE (nombre_tipo_uso)
);

/* 3) TIPO_ASISTENCIA */
IF OBJECT_ID('dbo.tipo_asistencia','U') IS NULL
CREATE TABLE dbo.tipo_asistencia (
    id_tipo_asistencia      INT IDENTITY(1,1) NOT NULL,
    nombre_tipo_asistencia  VARCHAR(30)       NOT NULL,
    descripcion             VARCHAR(100)      NULL,
    CONSTRAINT PK_tipo_asistencia PRIMARY KEY (id_tipo_asistencia),
    CONSTRAINT UQ_tipo_asistencia_nombre UNIQUE (nombre_tipo_asistencia)
);

/* 4) BICICLETA */
IF OBJECT_ID('dbo.bicicleta','U') IS NULL
CREATE TABLE dbo.bicicleta (
    id_bicicleta       INT IDENTITY(1,1) NOT NULL,
    id_admin           INT               NOT NULL,
    marca_comercial    VARCHAR(100)      NOT NULL,
    modelo             VARCHAR(100)      NOT NULL,
    anio_fabricacion   SMALLINT          NULL,
    tamanio_marco      VARCHAR(10)       NULL,
    id_tipo_uso        INT               NOT NULL,
    id_tipo_asistencia INT               NOT NULL,
    fecha_registro     DATE              NOT NULL CONSTRAINT DF_bicicleta_fecha DEFAULT (CAST(GETDATE() AS DATE)),
    CONSTRAINT PK_bicicleta PRIMARY KEY (id_bicicleta),
    CONSTRAINT FK_bici_admin
        FOREIGN KEY (id_admin) REFERENCES dbo.administrador(id_admin),
    CONSTRAINT FK_bici_tipo_uso
        FOREIGN KEY (id_tipo_uso) REFERENCES dbo.tipo_uso(id_tipo_uso),
    CONSTRAINT FK_bici_tipo_asistencia
        FOREIGN KEY (id_tipo_asistencia) REFERENCES dbo.tipo_asistencia(id_tipo_asistencia),
    CONSTRAINT CK_bici_anio CHECK (anio_fabricacion IS NULL OR anio_fabricacion BETWEEN 1900 AND YEAR(GETDATE())+1)
);

/* 5) ESTADO_OPERATIVO */
IF OBJECT_ID('dbo.estado_operativo','U') IS NULL
CREATE TABLE dbo.estado_operativo (
    id_estado_operativo INT IDENTITY(1,1) NOT NULL,
    id_bicicleta        INT               NOT NULL,
    estado              VARCHAR(30)       NOT NULL,
    fecha               DATE              NOT NULL CONSTRAINT DF_eop_fecha DEFAULT (CAST(GETDATE() AS DATE)),
    hora                TIME(0)           NOT NULL CONSTRAINT DF_eop_hora  DEFAULT (CONVERT(TIME(0), GETDATE())),
    vigente             BIT               NOT NULL CONSTRAINT DF_eop_vigente DEFAULT 1,
    CONSTRAINT PK_estado_operativo PRIMARY KEY (id_estado_operativo),
    CONSTRAINT FK_eop_bici
        FOREIGN KEY (id_bicicleta) REFERENCES dbo.bicicleta(id_bicicleta) ON DELETE CASCADE
);

/* 6) ESTADO_FISICO */
IF OBJECT_ID('dbo.estado_fisico','U') IS NULL
CREATE TABLE dbo.estado_fisico (
    id_estado_fisico INT IDENTITY(1,1) NOT NULL,
    id_bicicleta     INT               NOT NULL,
    condicion        VARCHAR(30)       NOT NULL,
    fecha            DATE              NOT NULL CONSTRAINT DF_efi_fecha DEFAULT (CAST(GETDATE() AS DATE)),
    hora             TIME(0)           NOT NULL CONSTRAINT DF_efi_hora  DEFAULT (CONVERT(TIME(0), GETDATE())),
    vigente          BIT               NOT NULL CONSTRAINT DF_efi_vigente DEFAULT 1,
    CONSTRAINT PK_estado_fisico PRIMARY KEY (id_estado_fisico),
    CONSTRAINT FK_efi_bici
        FOREIGN KEY (id_bicicleta) REFERENCES dbo.bicicleta(id_bicicleta) ON DELETE CASCADE
);

/* 7) ÍNDICES recomendados para FKs */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_bici_id_admin')
    CREATE INDEX IX_bici_id_admin           ON dbo.bicicleta(id_admin);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_bici_id_tipo_uso')
    CREATE INDEX IX_bici_id_tipo_uso        ON dbo.bicicleta(id_tipo_uso);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_bici_id_tipo_asistencia')
    CREATE INDEX IX_bici_id_tipo_asistencia ON dbo.bicicleta(id_tipo_asistencia);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_eop_id_bici')
    CREATE INDEX IX_eop_id_bici             ON dbo.estado_operativo(id_bicicleta);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='IX_efi_id_bici')
    CREATE INDEX IX_efi_id_bici             ON dbo.estado_fisico(id_bicicleta);

/* 8) Solo un “vigente” por bicicleta en cada historial */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_eop_vigente_por_bici')
    CREATE UNIQUE INDEX UX_eop_vigente_por_bici ON dbo.estado_operativo(id_bicicleta) WHERE vigente = 1;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name='UX_efi_vigente_por_bici')
    CREATE UNIQUE INDEX UX_efi_vigente_por_bici ON dbo.estado_fisico(id_bicicleta)  WHERE vigente = 1;
