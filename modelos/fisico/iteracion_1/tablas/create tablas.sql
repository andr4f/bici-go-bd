CREATE TABLE dbo.administrador (
    id_admin INT IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    fecha_registro DATE NOT NULL DEFAULT (CAST(GETDATE() AS date))
);

CREATE TABLE dbo.tipo_uso (
    id_tipo_uso INT IDENTITY(1,1),
    nombre_tipo_uso VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200)
);

CREATE TABLE dbo.tipo_asistencia (
    id_tipo_asistencia INT IDENTITY(1,1),
    nombre_tipo_asistencia VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200)
);

CREATE TABLE dbo.bicicleta (
    id_bicicleta INT IDENTITY(1,1),
    id_admin INT NOT NULL,
    marca_comercial VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    anio_fabricacion INT NOT NULL,
    tamano_marco VARCHAR(20) NOT NULL,
    id_tipo_uso INT NOT NULL,
    id_tipo_asistencia INT NOT NULL,
    fecha_registro DATE NOT NULL DEFAULT (CAST(GETDATE() AS date))
);

CREATE TABLE dbo.estado_operativo (
    id_estado_operativo INT IDENTITY(1,1),
    id_bicicleta INT NOT NULL,
    estado VARCHAR(30) NOT NULL,
    fecha DATE NOT NULL DEFAULT (CAST(GETDATE() AS date)),
    hora TIME NOT NULL DEFAULT (CONVERT(time, GETDATE()))
);


CREATE TABLE dbo.estado_fisico (
    id_estado_fisico INT IDENTITY(1,1),
    id_bicicleta INT NOT NULL,
    condicion VARCHAR(50) NOT NULL,
    fecha DATE NOT NULL DEFAULT (CAST(GETDATE() AS date)),
    hora TIME NOT NULL DEFAULT (CONVERT(time, GETDATE()))
);
