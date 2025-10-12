/* =========================================================
   LIMPIEZA ORDENADA (si existen)
   ========================================================= */
IF OBJECT_ID('dbo.estado_fisico','U')     IS NOT NULL DROP TABLE dbo.estado_fisico;
IF OBJECT_ID('dbo.estado_operativo','U')  IS NOT NULL DROP TABLE dbo.estado_operativo;
IF OBJECT_ID('dbo.bicicleta','U')         IS NOT NULL DROP TABLE dbo.bicicleta;
IF OBJECT_ID('dbo.tipo_asistencia','U')   IS NOT NULL DROP TABLE dbo.tipo_asistencia;
IF OBJECT_ID('dbo.tipo_uso','U')          IS NOT NULL DROP TABLE dbo.tipo_uso;
IF OBJECT_ID('dbo.administrador','U')     IS NOT NULL DROP TABLE dbo.administrador;
GO

/* =========================================================
   1) ADMINISTRADOR
   ========================================================= */
CREATE TABLE dbo.administrador (
    id_admin        INT IDENTITY(1,1) NOT NULL,
    nombre          VARCHAR(100)      NOT NULL,
    apellido        VARCHAR(100)      NOT NULL,
    email           VARCHAR(255)      NOT NULL,
    fecha_registro  DATE              NOT NULL
        CONSTRAINT DF_administrador_fecha DEFAULT (CAST(GETDATE() AS date)),
    CONSTRAINT PK_administrador PRIMARY KEY CLUSTERED (id_admin),
    CONSTRAINT UQ_administrador_email UNIQUE (email)
);
GO

/* =========================================================
   2) TIPO_USO (catálogo)
   ========================================================= */
CREATE TABLE dbo.tipo_uso (
    id_tipo_uso      INT IDENTITY(1,1) NOT NULL,
    nombre_tipo_uso  VARCHAR(30)       NOT NULL,
    descripcion      VARCHAR(100)      NULL,
    CONSTRAINT PK_tipo_uso PRIMARY KEY CLUSTERED (id_tipo_uso),
    CONSTRAINT UQ_tipo_uso_nombre UNIQUE (nombre_tipo_uso)
);
GO

/* =========================================================
   3) TIPO_ASISTENCIA (catálogo)
   ========================================================= */
CREATE TABLE dbo.tipo_asistencia (
    id_tipo_asistencia      INT IDENTITY(1,1) NOT NULL,
    nombre_tipo_asistencia  VARCHAR(30)       NOT NULL,
    descripcion             VARCHAR(100)      NULL,
    CONSTRAINT PK_tipo_asistencia PRIMARY KEY CLUSTERED (id_tipo_asistencia),
    CONSTRAINT UQ_tipo_asistencia_nombre UNIQUE (nombre_tipo_asistencia)
);
GO

/* =========================================================
   4) BICICLETA
   ========================================================= */
CREATE TABLE dbo.bicicleta (
    id_bicicleta        INT IDENTITY(1,1) NOT NULL,
    id_admin            INT               NOT NULL,
    marca_comercial     VARCHAR(100)      NOT NULL,
    modelo              VARCHAR(100)      NOT NULL,
    anio_fabricacion    SMALLINT          NULL,
    tamanio_marco       VARCHAR(10)       NULL,
    id_tipo_uso         INT               NOT NULL,
    id_tipo_asistencia  INT               NOT NULL,
    fecha_registro      DATE              NOT NULL
        CONSTRAINT DF_bici_fecha DEFAULT (CAST(GETDATE() AS date)),
    CONSTRAINT PK_bicicleta PRIMARY KEY CLUSTERED (id_bicicleta),
    CONSTRAINT FK_bici_admin
        FOREIGN KEY (id_admin) REFERENCES dbo.administrador(id_admin),
    CONSTRAINT FK_bici_tipo_uso
        FOREIGN KEY (id_tipo_uso) REFERENCES dbo.tipo_uso(id_tipo_uso),
    CONSTRAINT FK_bici_tipo_asistencia
        FOREIGN KEY (id_tipo_asistencia) REFERENCES dbo.tipo_asistencia(id_tipo_asistencia),
    CONSTRAINT CK_bici_anio
        CHECK (anio_fabricacion IS NULL OR anio_fabricacion BETWEEN 1900 AND YEAR(GETDATE()) + 1)
);
GO

/* =========================================================
   5) ESTADO_OPERATIVO (histórico)
   ========================================================= */
CREATE TABLE dbo.estado_operativo (
    id_estado_operativo INT IDENTITY(1,1) NOT NULL,
    id_bicicleta        INT               NOT NULL,
    estado              VARCHAR(30)       NOT NULL,
    fecha               DATE              NOT NULL
        CONSTRAINT DF_eop_fecha DEFAULT (CAST(GETDATE() AS date)),
    hora                TIME(0)           NOT NULL
        CONSTRAINT DF_eop_hora  DEFAULT (CONVERT(time(0), GETDATE())),
    vigente             BIT               NOT NULL
        CONSTRAINT DF_eop_vigente DEFAULT (1),
    CONSTRAINT PK_estado_operativo PRIMARY KEY CLUSTERED (id_estado_operativo),
    CONSTRAINT FK_eop_bici
        FOREIGN KEY (id_bicicleta) REFERENCES dbo.bicicleta(id_bicicleta) ON DELETE CASCADE
);
GO

/* =========================================================
   6) ESTADO_FISICO (histórico)
   ========================================================= */
CREATE TABLE dbo.estado_fisico (
    id_estado_fisico INT IDENTITY(1,1) NOT NULL,
    id_bicicleta     INT               NOT NULL,
    condicion        VARCHAR(30)       NOT NULL,
    fecha            DATE              NOT NULL
        CONSTRAINT DF_efi_fecha DEFAULT (CAST(GETDATE() AS date)),
    hora             TIME(0)           NOT NULL
        CONSTRAINT DF_efi_hora  DEFAULT (CONVERT(time(0), GETDATE())),
    vigente          BIT               NOT NULL
        CONSTRAINT DF_efi_vigente DEFAULT (1),
    CONSTRAINT PK_estado_fisico PRIMARY KEY CLUSTERED (id_estado_fisico),
    CONSTRAINT FK_efi_bici
        FOREIGN KEY (id_bicicleta) REFERENCES dbo.bicicleta(id_bicicleta) ON DELETE CASCADE
);
GO

/* =========================================================
   7) ÍNDICES recomendados
   ========================================================= */
CREATE INDEX IX_bici_id_admin            ON dbo.bicicleta(id_admin);
CREATE INDEX IX_bici_id_tipo_uso         ON dbo.bicicleta(id_tipo_uso);
CREATE INDEX IX_bici_id_tipo_asistencia  ON dbo.bicicleta(id_tipo_asistencia);
CREATE INDEX IX_eop_id_bici              ON dbo.estado_operativo(id_bicicleta);
CREATE INDEX IX_efi_id_bici              ON dbo.estado_fisico(id_bicicleta);

/* Si quieres garantizar que solo exista 1 registro vigente por bicicleta
   en cada historial, activa estos índices únicos filtrados: */
CREATE UNIQUE INDEX UX_eop_vigente_por_bici ON dbo.estado_operativo(id_bicicleta) WHERE vigente = 1;
CREATE UNIQUE INDEX UX_efi_vigente_por_bici ON dbo.estado_fisico(id_bicicleta)  WHERE vigente = 1;
GO
