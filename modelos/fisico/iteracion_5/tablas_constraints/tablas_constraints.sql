CREATE TABLE persona (
    id_persona INT IDENTITY(1,1) PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    documento_tipo VARCHAR(20) NOT NULL,
    documento_numero VARCHAR(50) UNIQUE NOT NULL,
    tipo_persona VARCHAR(50) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',
    fecha_creacion DATETIME DEFAULT GETDATE(),

    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),

    CONSTRAINT CHK_persona_nombre_no_vacio 
    CHECK (LEN(TRIM(nombre)) > 0 AND nombre LIKE '%[A-Za-zÁÉÍÓÚáéíóúÑñ ]%'),

    CONSTRAINT CHK_persona_apellido_no_vacio
    CHECK (LEN(TRIM(apellido)) > 0 AND apellido LIKE '%[A-Za-zÁÉÍÓÚáéíóúÑñ ]%'),

    CONSTRAINT CHK_persona_email_formato 
    CHECK (email LIKE '%_@__%.__%' AND email NOT LIKE '%[ ]%'),

    CONSTRAINT CHK_persona_telefono_formato 
    CHECK (LEN(telefono) >= 7 AND telefono LIKE '%[0-9]%'),

    CONSTRAINT CHK_persona_documento_tipo 
    CHECK (documento_tipo IN ('CC', 'TI', 'CE', 'Pasaporte', 'NIT', 'RUT')),

    CONSTRAINT CHK_persona_documento_no_vacio 
    CHECK (LEN(TRIM(documento_numero)) > 0),

    CONSTRAINT CHK_persona_tipo 
    CHECK (tipo_persona IN ('cliente', 'contacto_punto', 'administrador', 'guia')),

    CONSTRAINT CHK_persona_estado
    CHECK (estado IN ('activo', 'inactivo', 'eliminado')),

    CONSTRAINT CHK_persona_fecha_no_futura 
    CHECK (fecha_creacion <= GETDATE())
    )
    WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.persona_historial));

CREATE TABLE cliente (
    id_cliente INT PRIMARY KEY IDENTITY(1,1),
    id_persona INT UNIQUE NOT NULL, 
    usuario VARCHAR(100) UNIQUE NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),

    CONSTRAINT FK_cliente_persona
    FOREIGN KEY (id_persona) REFERENCES persona(id_persona)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT CHK_cliente_usuario_no_vacio
    CHECK (LEN(TRIM(usuario)) >= 3 AND usuario NOT LIKE '%[ ]%'),

    CONSTRAINT CHK_cliente_contrasena_longitud
    CHECK (LEN(contrasena) >= 8)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.cliente_historial));

CREATE TABLE administrador (
    id_admin INT PRIMARY KEY IDENTITY(1,1),
    id_persona INT UNIQUE NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT GETDATE(),
    usuario VARCHAR(100) UNIQUE NOT NULL,
    rol_admin VARCHAR(50) NOT NULL,
    contrasena VARCHAR(255) NOT NULL,
    
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),

    CONSTRAINT FK_administrador_persona
    FOREIGN KEY (id_persona) REFERENCES persona(id_persona)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT CHK_admin_usuario_no_vacio
    CHECK (LEN(TRIM(usuario)) >= 3 AND usuario LIKE '%[A-Za-z0-9._-]%'),

    CONSTRAINT CHK_admin_rol
    CHECK (rol_admin IN ('superadmin', 'admin', 'gestor', 'moderador', 'soporte')),

    CONSTRAINT CHK_admin_contrasena_longitud
    CHECK (LEN(contrasena) >= 8),

    CONSTRAINT CHK_admin_fecha_no_futura
    CHECK (fecha_registro <= GETDATE())
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.administrador_historial));


CREATE TABLE parametro_mantenimiento (
    id_parametro INT PRIMARY KEY IDENTITY(1,1),
    km_umbral INT NOT NULL DEFAULT 500,
    horas_umbral INT NOT NULL DEFAULT 100,
    nombre VARCHAR(50) NOT NULL,
    porcentaje_alerta INT NOT NULL DEFAULT 80,
    fecha_inicio DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
    
    CONSTRAINT chk_km_umbral CHECK (km_umbral > 0),
    CONSTRAINT chk_horas_umbral CHECK (horas_umbral > 0),
    CONSTRAINT chk_porcentaje_alerta CHECK (porcentaje_alerta > 0 AND porcentaje_alerta <= 100),
    CONSTRAINT chk_fecha_coherencia_parametro CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    
    CONSTRAINT fk_parametro_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.parametro_mantenimiento_historial));




-- Tabla: pais
CREATE TABLE pais (
    id_pais INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    moneda_oficial CHAR(3) NOT NULL,
    
    CONSTRAINT chk_moneda_codigo CHECK (moneda_oficial LIKE '[A-Z][A-Z][A-Z]'),
    CONSTRAINT chk_nombre_no_vacio CHECK (LEN(nombre) > 0)
);

CREATE TABLE departamento (
    id_departamento INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    id_pais INT NOT NULL,
    
    CONSTRAINT chk_departamento_nombre_no_vacio CHECK (LEN(nombre) > 0),
    
    CONSTRAINT fk_departamento_pais FOREIGN KEY (id_pais) 
        REFERENCES pais(id_pais)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

-- Tabla: ciudad
CREATE TABLE ciudad (
    id_ciudad INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    latitud DECIMAL(9,6) NOT NULL,
    longitud DECIMAL(9,6) NOT NULL,
    id_departamento INT NOT NULL,
    
    CONSTRAINT chk_latitud CHECK (latitud >= -90 AND latitud <= 90),
    CONSTRAINT chk_longitud CHECK (longitud >= -180 AND longitud <= 180),
    
    CONSTRAINT fk_ciudad_pais FOREIGN KEY (id_departamento) 
        REFERENCES departamento(id_departamento) 
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

-- Tabla: punto_alquiler (CORREGIDA según lógico IT4)
CREATE TABLE punto_alquiler (
    id_punto_alquiler INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    direccion VARCHAR(255) NOT NULL,
    id_ciudad INT NOT NULL,
    latitud DECIMAL(9,6)  NULL,
    longitud DECIMAL(9,6) NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),

    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),

    CONSTRAINT chk_nombre_punto_no_vacio CHECK (LEN(nombre) > 0),
    CONSTRAINT chk_punto_latitud CHECK (latitud IS NULL OR (latitud >= -90 AND latitud <= 90)),
    CONSTRAINT chk_punto_longitud CHECK (longitud IS NULL OR (longitud >= -180 AND longitud <= 180)),

    
    CONSTRAINT fk_punto_ciudad FOREIGN KEY (id_ciudad) 
        REFERENCES ciudad(id_ciudad)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
        )
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.punto_alquiler_historial));

CREATE TABLE contacto_punto (
   id_contacto INT PRIMARY KEY IDENTITY(1,1),
   id_persona INT NOT NULL,
   id_punto_alquiler INT NOT NULL,
   cargo VARCHAR(100) NOT NULL,
   horario_disponible VARCHAR(255) NULL,

   CONSTRAINT FK_contacto_persona
   FOREIGN KEY (id_persona) REFERENCES persona(id_persona)
   ON DELETE CASCADE
   ON UPDATE CASCADE,

   CONSTRAINT FK_contacto_punto_alquiler
   FOREIGN KEY (id_punto_alquiler) REFERENCES punto_alquiler(id_punto_alquiler)
   ON DELETE CASCADE
   ON UPDATE CASCADE,

   CONSTRAINT CHK_contacto_cargo_no_vacio
   CHECK (LEN(TRIM(cargo)) > 0),

   CONSTRAINT CHK_contacto_horario_formato
   CHECK (horario_disponible IS NULL OR LEN(TRIM(horario_disponible)) > 0),

   CONSTRAINT UQ_contacto_persona_punto
   UNIQUE (id_persona, id_punto_alquiler)
);


CREATE TABLE horario_base (
    id_punto_alquiler INT PRIMARY KEY,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT fk_horario_punto FOREIGN KEY (id_punto_alquiler) 
        REFERENCES punto_alquiler(id_punto_alquiler)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
   
);

-- Tabla: detalle_dia_horario (NUEVA - Historia 14)
CREATE TABLE detalle_dia_horario (
    id_punto_alquiler INT NOT NULL,
    dia_semana SMALLINT NOT NULL,
    hora_apertura TIME NULL,
    hora_cierre TIME NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'abierto',
    
    PRIMARY KEY (id_punto_alquiler, dia_semana),
    
    CONSTRAINT chk_dia_semana CHECK (dia_semana >= 0 AND dia_semana <= 6),
    CONSTRAINT chk_estado_dia CHECK (estado IN ('abierto', 'cerrado', 'mantenimiento')),
    CONSTRAINT chk_horario_valido CHECK (
        (estado = 'cerrado' AND hora_apertura IS NULL AND hora_cierre IS NULL) OR
        (estado <> 'cerrado' AND hora_apertura IS NOT NULL AND hora_cierre IS NOT NULL AND hora_cierre > hora_apertura)
    ),
    
    CONSTRAINT fk_detalle_horario_base FOREIGN KEY (id_punto_alquiler) 
        REFERENCES horario_base(id_punto_alquiler)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
);

CREATE TABLE excepcion_horario (
    id_excepcion INT PRIMARY KEY IDENTITY(1,1),
    id_punto_alquiler INT NOT NULL,
    fecha_excepcion DATE NOT NULL,
    tipo_excepcion VARCHAR(50) NOT NULL,
    motivo VARCHAR(255) NULL,
    hora_apertura TIME NOT NULL,
    hora_cierre TIME NOT NULL,
    id_admin INT NOT NULL,
    
    CONSTRAINT chk_tipo_excepcion CHECK (
        tipo_excepcion IS NULL OR
        tipo_excepcion IN ('festivo', 'mantenimiento', 'evento especial', 'emergencia', 'otro')
    ),
    CONSTRAINT chk_fecha_excepcion_futura CHECK (fecha_excepcion >= CAST(GETDATE() AS DATE)),
    CONSTRAINT chk_excepcion_horario_valido CHECK (
        (hora_apertura IS NULL AND hora_cierre IS NULL) OR
        (hora_apertura IS NOT NULL AND hora_cierre IS NOT NULL AND hora_cierre > hora_apertura)
    ),
    
    CONSTRAINT fk_excepcion_punto FOREIGN KEY (id_punto_alquiler) 
        REFERENCES punto_alquiler(id_punto_alquiler)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,

    CONSTRAINT fk_excepcion_horario_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE capacidad (
    id_punto_alquiler INT PRIMARY KEY,
    capacidad_total INT NOT NULL,

    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
    
    CONSTRAINT chk_capacidad_total CHECK (capacidad_total > 0),
    
    CONSTRAINT fk_capacidad_punto FOREIGN KEY (id_punto_alquiler) 
        REFERENCES punto_alquiler(id_punto_alquiler)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    )
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.capacidad_historial));

CREATE TABLE estado_operativo (
    id_estado_operativo INT PRIMARY KEY IDENTITY(1,1),
    nombre_estado VARCHAR(20) NOT NULL UNIQUE,
    
    CONSTRAINT chk_estado_operativo_valores CHECK (
        nombre_estado IN ('disponible', 'en alquiler', 'en mantenimiento', 'fuera de servicio', 'reservada')
    ),
);


CREATE TABLE estado_fisico (
    id_estado_fisico INT PRIMARY KEY IDENTITY(1,1),
    condicion VARCHAR(20) NOT NULL UNIQUE,
    
    CONSTRAINT chk_estado_fisico_valores CHECK (
        condicion IN ('excelente', 'bueno', 'regular', 'requiere servicio', 'dañada')
    ),
);

CREATE TABLE tipo_uso (
    id_tipo_uso INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
    
    CONSTRAINT chk_tipo_uso_valores CHECK (
        nombre IN ('montaña', 'urbana', 'ruta', 'híbrida', 'BMX', 'carretera')
    ),
    CONSTRAINT chk_tipo_uso_nombre CHECK (LEN(nombre) > 0),
    CONSTRAINT chk_fecha_coherencia_tipo_uso CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    
    CONSTRAINT fk_tipo_uso_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.tipo_uso_historial));

CREATE TABLE tipo_asistencia (
    id_tipo_asistencia INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
    
    CONSTRAINT chk_tipo_asistencia_valores CHECK (
        nombre IN ('convencional', 'eléctrica')
    ),
    CONSTRAINT chk_tipo_asistencia_nombre CHECK (LEN(nombre) > 0),
    CONSTRAINT chk_fecha_coherencia_tipo_asistencia CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    
    CONSTRAINT fk_tipo_asistencia_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.tipo_asistencia_historial));

CREATE TABLE bicicleta (
    id_bicicleta INT PRIMARY KEY IDENTITY(1,1),
    codigo_unico VARCHAR(50) NOT NULL UNIQUE,
    marca_comercial VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    anio_fabricacion SMALLINT NOT NULL,
    tamano_marco VARCHAR(20) NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT GETDATE(),
    id_admin INT NOT NULL,
    id_tipo_uso INT NOT NULL,
    id_tipo_asistencia INT NOT NULL,
    id_estado_operativo INT NOT NULL,
    id_estado_fisico INT NOT NULL,
    id_parametro INT NOT NULL,
    id_punto_alquiler INT NOT NULL,
    
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
    
    CONSTRAINT chk_bicicleta_codigo CHECK (codigo_unico LIKE '[A-Z][A-Z][E][0-9][0-9][0-9][0-9][A-Z][A-Z][C]'),
    CONSTRAINT chk_bicicleta_anio CHECK (anio_fabricacion >= 2000 AND anio_fabricacion <= YEAR(GETDATE())),
    CONSTRAINT chk_bicicleta_marca_no_vacio CHECK (LEN(marca_comercial) > 0),
    CONSTRAINT chk_bicicleta_modelo_no_vacio CHECK (LEN(modelo) > 0),
    CONSTRAINT chk_tamano_marco CHECK (tamano_marco IN ('XS', 'S', 'M', 'L', 'XL', 'XXL')),
    
    CONSTRAINT fk_bicicleta_tipo_uso FOREIGN KEY (id_tipo_uso)
        REFERENCES tipo_uso(id_tipo_uso)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT fk_bicicleta_tipo_asistencia FOREIGN KEY (id_tipo_asistencia)
        REFERENCES tipo_asistencia(id_tipo_asistencia)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT fk_bicicleta_admin FOREIGN KEY (id_admin) 
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT fk_bicicleta_estado_operativo FOREIGN KEY (id_estado_operativo)  
        REFERENCES estado_operativo(id_estado_operativo)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    
    CONSTRAINT fk_bicicleta_estado_fisico FOREIGN KEY (id_estado_fisico) 
        REFERENCES estado_fisico(id_estado_fisico)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT fk_parametro_bicicleta FOREIGN KEY (id_parametro)
        REFERENCES parametro_mantenimiento(id_parametro)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT fk_punto_bicicleta FOREIGN KEY (id_punto_alquiler)
        REFERENCES punto_alquiler(id_punto_alquiler)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.bicicleta_historial));

CREATE TABLE capacidad_tipo (
    id_capacidad_tipo INT PRIMARY KEY IDENTITY(1,1),
    capacidad_especifica INT NOT NULL,
    id_punto_alquiler INT NOT NULL,
    id_tipo_uso INT NOT NULL,
    id_tipo_asistencia INT NOT NULL,
    
    CONSTRAINT uq_capacidad_tipo_combinacion UNIQUE (id_punto_alquiler, id_tipo_uso, id_tipo_asistencia),
    
    CONSTRAINT chk_capacidad_especifica CHECK (capacidad_especifica > 0),
    
    CONSTRAINT fk_capacidad_tipo_punto FOREIGN KEY (id_punto_alquiler) 
        REFERENCES capacidad(id_punto_alquiler)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,

    CONSTRAINT fk_capacidad_tipo_uso FOREIGN KEY (id_tipo_uso) 
        REFERENCES tipo_uso(id_tipo_uso)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT fk_capacidad_tipo_asistencia FOREIGN KEY (id_tipo_asistencia) 
        REFERENCES tipo_asistencia(id_tipo_asistencia)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE servicio (
    id_servicio INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL,
    es_obligatorio BIT NOT NULL DEFAULT 0,
    
    CONSTRAINT chk_servicio_nombre_no_vacio CHECK (LEN(nombre) > 0)
);

CREATE TABLE punto_servicio (
    id_punto_alquiler INT NOT NULL,
    id_servicio INT NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',
    descripcion_especifica VARCHAR(255) NULL,
    fecha_asignacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_actualizacion DATETIME NULL,
    id_admin INT NOT NULL,

    PRIMARY KEY (id_servicio, id_punto_alquiler),
    
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
    
    CONSTRAINT chk_estado_servicio CHECK (estado IN ('activo', 'inactivo', 'suspendido')),
    CONSTRAINT chk_fecha_coherencia_servicio CHECK (fecha_actualizacion IS NULL OR fecha_actualizacion >= fecha_asignacion),

    CONSTRAINT fk_punto_servicio_punto FOREIGN KEY (id_punto_alquiler) 
        REFERENCES punto_alquiler(id_punto_alquiler) 
        ON DELETE CASCADE
        ON UPDATE NO ACTION,

    CONSTRAINT fk_punto_servicio_servicio FOREIGN KEY (id_servicio) 
        REFERENCES servicio(id_servicio) 
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    
    CONSTRAINT fk_punto_servicio_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.punto_servicio_historial));


-- Tabla: plan

CREATE TABLE [plan] (
    id_plan INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    tipo_duracion VARCHAR(20) NOT NULL,
    descripcion TEXT NULL,
    beneficios TEXT NULL,
    politica_cancelacion TEXT NOT NULL,
    politica_reembolso TEXT NOT NULL,
    horas_cancelacion_gratis INT NOT NULL DEFAULT 24,
    porcentaje_reembolso DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
 
    CONSTRAINT CHK_plan_nombre_no_vacio 
    CHECK (LEN(TRIM(nombre)) > 0),

    CONSTRAINT CHK_plan_tipo_duracion
    CHECK (tipo_duracion IN ('hora', 'dia', 'semanal', 'mensual', 'anual')),

    CONSTRAINT CHK_plan_horas_cancelacion
    CHECK (horas_cancelacion_gratis > 0),

    CONSTRAINT CHK_plan_porcentaje_reembolso
    CHECK (porcentaje_reembolso BETWEEN 0 AND 100),

    CONSTRAINT CHK_plan_estado
    CHECK (estado IN ('activo', 'inactivo'))
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.plan_historial));

CREATE TABLE tarifa (
    id_tarifa INT PRIMARY KEY IDENTITY(1,1),
    id_plan INT NOT NULL,
    id_pais INT NOT NULL,
    id_tipo_uso INT NOT NULL,
    id_tipo_asistencia INT NOT NULL,
    tarifa_base DECIMAL(10,2) NOT NULL,
    tarifa_final DECIMAL(10,2) NOT NULL,
    fecha_inicio DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    fecha_fin DATE NULL,
    id_admin INT NOT NULL,
    
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
    
    CONSTRAINT FK_tarifa_plan FOREIGN KEY (id_plan) 
        REFERENCES [plan](id_plan)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT FK_tarifa_pais FOREIGN KEY (id_pais) 
        REFERENCES pais(id_pais)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT FK_tarifa_tipo_uso FOREIGN KEY (id_tipo_uso) 
        REFERENCES tipo_uso(id_tipo_uso)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT FK_tarifa_tipo_asistencia FOREIGN KEY (id_tipo_asistencia) 
        REFERENCES tipo_asistencia(id_tipo_asistencia)
        ON DELETE NO ACTION
        ON UPDATE CASCADE,
    CONSTRAINT FK_tarifa_admin FOREIGN KEY (id_admin) 
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    
    CONSTRAINT CHK_tarifa_base_positiva CHECK (tarifa_base > 0),
    CONSTRAINT CHK_tarifa_final_positiva CHECK (tarifa_final > 0),
    CONSTRAINT CHK_tarifa_final_mayor_base CHECK (tarifa_final >= tarifa_base),
    CONSTRAINT CHK_tarifa_vigencia CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    CONSTRAINT UQ_tarifa_combinacion UNIQUE (id_plan, id_pais, id_tipo_uso, id_tipo_asistencia, fecha_inicio)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.tarifa_historial));



CREATE TABLE tipo_cobertura (
    id_tipo_cobertura INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL,
    
    CONSTRAINT chk_tipo_cobertura_nombre_no_vacio CHECK (LEN(nombre) > 0)
);

CREATE TABLE cobertura_seguro (
    id_cobertura INT PRIMARY KEY IDENTITY(1,1),
    id_bicicleta INT NOT NULL,
    id_tipo_cobertura INT NOT NULL,
    monto_maximo DECIMAL(12,2) NULL,
    fecha_inicio_vigencia DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    fecha_fin_vigencia DATE NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',
    
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
    
    CONSTRAINT chk_monto_maximo CHECK (monto_maximo IS NULL OR monto_maximo > 0),
    CONSTRAINT chk_estado_cobertura CHECK (
        estado IN ('activo', 'vencido', 'cancelado', 'suspendido', 'en trámite')
    ),
    CONSTRAINT chk_fecha_coherencia_cobertura CHECK (fecha_fin_vigencia IS NULL OR fecha_fin_vigencia >= fecha_inicio_vigencia),
    
    CONSTRAINT fk_cobertura_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,

    CONSTRAINT fk_cobertura_tipo FOREIGN KEY (id_tipo_cobertura) 
        REFERENCES tipo_cobertura(id_tipo_cobertura)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.cobertura_seguro_historial));

-- Tabla: condiciones_especiales
CREATE TABLE condiciones_especiales (
    id_condicion INT PRIMARY KEY IDENTITY(1,1),
    id_bicicleta INT NOT NULL,
    tipo_condicion VARCHAR(50) NOT NULL,
    valor_minimo DECIMAL(10,2) NULL,
    valor_maximo DECIMAL(10,2) NULL,
    unidad_medida VARCHAR(20) NULL,
    descripcion VARCHAR(500) NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_fin DATETIME NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
   
    CONSTRAINT chk_condicion_tipo CHECK (
        tipo_condicion IN ('peso_maximo', 'altura_minima', 'altura_maxima', 'edad_minima', 'experiencia_minima', 'licencia_requerida', 'otro')
    ),
    CONSTRAINT chk_condicion_valores CHECK (
        valor_minimo IS NULL OR valor_maximo IS NULL OR valor_minimo <= valor_maximo
    ),
    CONSTRAINT chk_fecha_coherencia_condicion CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    
    CONSTRAINT fk_condicion_bicicleta FOREIGN KEY (id_bicicleta)
        REFERENCES bicicleta(id_bicicleta)
        ON DELETE CASCADE
        ON UPDATE NO ACTION
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.condiciones_especiales_historial));

CREATE TABLE restriccion_terreno (
    id_restriccion INT PRIMARY KEY IDENTITY(1,1),
    id_condicion INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    
    CONSTRAINT chk_restriccion_nombre_no_vacio CHECK (LEN(nombre) > 0),
    
    CONSTRAINT fk_restriccion_condicion FOREIGN KEY (id_condicion) 
        REFERENCES condiciones_especiales(id_condicion)
        ON DELETE CASCADE
        ON UPDATE NO ACTION
);

CREATE TABLE uso_acumulado (
    id_bicicleta INT PRIMARY KEY,
    km_total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    horas_total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    km_parcial DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    horas_parcial DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    fecha_ultimo_mantenimiento DATETIME NULL,
    id_admin INT NOT NULL,
    
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
    
    CONSTRAINT chk_km_total CHECK (km_total >= 0),
    CONSTRAINT chk_horas_total CHECK (horas_total >= 0),
    CONSTRAINT chk_km_parcial CHECK (km_parcial >= 0 AND km_parcial <= km_total),
    CONSTRAINT chk_horas_parcial CHECK (horas_parcial >= 0 AND horas_parcial <= horas_total),
    
    CONSTRAINT fk_uso_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta)
        ON DELETE NO ACTION 
        ON UPDATE NO ACTION,
    
    CONSTRAINT fk_uso_admin FOREIGN KEY (id_admin) 
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.uso_acumulado_historial));
CREATE TABLE etiqueta (
    id_etiqueta INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    tipo_de_etiqueta VARCHAR(50) NULL,
    descripcion VARCHAR(255) NULL,
    
    CONSTRAINT chk_etiqueta_tipo CHECK (
        tipo_de_etiqueta IS NULL OR 
        tipo_de_etiqueta IN ('característica', 'accesorio', 'accesibilidad', 'restricción', 'promoción', 'terreno')
    ),
    CONSTRAINT chk_etiqueta_nombre_no_vacio CHECK (LEN(nombre) > 0)
);
CREATE TABLE bicicleta_etiqueta (
    id_bicicleta INT NOT NULL,
    id_etiqueta INT NOT NULL,
    fecha_asignacion DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_eliminacion DATETIME NULL,
    id_admin INT NOT NULL,
    
    PRIMARY KEY (id_bicicleta, id_etiqueta),
    
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
    
    CONSTRAINT chk_fecha_coherencia_etiqueta CHECK (fecha_eliminacion IS NULL OR fecha_eliminacion >= fecha_asignacion),
    
    CONSTRAINT fk_bici_eti_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,

    CONSTRAINT fk_bici_eti_etiqueta FOREIGN KEY (id_etiqueta) 
        REFERENCES etiqueta(id_etiqueta)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    
    CONSTRAINT fk_bici_eti_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.bicicleta_etiqueta_historial));


CREATE TABLE fotografia (
    id_fotografia INT PRIMARY KEY IDENTITY(1,1),
    nombre_archivo VARCHAR(255) NOT NULL,
    ruta_archivo VARCHAR(500) NOT NULL UNIQUE,
    formato VARCHAR(20) NOT NULL,
    ancho_px INT NOT NULL,
    alto_px INT NOT NULL,
    es_principal BIT NOT NULL DEFAULT 0,
    orden INT NOT NULL DEFAULT 0,
    descripcion TEXT,
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',
    fecha_hora_carga DATETIME DEFAULT GETDATE(),
    
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
    
    CONSTRAINT ck_fotografia_formato CHECK (formato IN ('jpg', 'jpeg', 'png', 'webp', 'gif')),
    CONSTRAINT ck_fotografia_dimensiones CHECK (ancho_px > 0 AND alto_px > 0),
    CONSTRAINT ck_fotografia_estado CHECK (estado IN ('activo', 'inactivo', 'eliminada')),
    CONSTRAINT ck_fotografia_orden CHECK (orden >= 0)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.fotografia_historial));



CREATE TABLE fotografia_bicicleta (
    id_fotografia_bicicleta INT PRIMARY KEY IDENTITY(1,1),
    id_fotografia INT NOT NULL,
    id_bicicleta INT NOT NULL,
    tipo_vista VARCHAR(50) NOT NULL,
    
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
    
    CONSTRAINT fk_fotografia_bicicleta_fotografia FOREIGN KEY (id_fotografia) 
        REFERENCES fotografia(id_fotografia) 
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    
    CONSTRAINT fk_fotografia_bicicleta_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta) 
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    
    CONSTRAINT uk_fotografia_bicicleta UNIQUE (id_fotografia, id_bicicleta),
    
    CONSTRAINT ck_fotografia_bicicleta_tipo_vista CHECK (tipo_vista IN ('frontal', 'lateral', 'trasera', 'detalle', 'otro'))
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.fotografia_bicicleta_historial));


CREATE TABLE fotografia_punto (
    id_fotografia_punto INT PRIMARY KEY IDENTITY(1,1),
    id_fotografia INT NOT NULL,
    id_punto_alquiler INT NOT NULL,
    tipo_vista VARCHAR(50) NOT NULL,
    
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
    
    CONSTRAINT fk_fotografia_punto_fotografia FOREIGN KEY (id_fotografia) 
        REFERENCES fotografia(id_fotografia) 
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    
    CONSTRAINT fk_fotografia_punto_punto FOREIGN KEY (id_punto_alquiler) 
        REFERENCES punto_alquiler(id_punto_alquiler) 
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    
    CONSTRAINT uk_fotografia_punto UNIQUE (id_fotografia, id_punto_alquiler),
    
    CONSTRAINT ck_fotografia_punto_tipo_vista CHECK (tipo_vista IN ('entrada', 'salida', 'estacionamiento', 'general', 'otro'))
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.fotografia_punto_historial));

CREATE TABLE metodo_de_pago (
    id_metodo_de_pago INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) UNIQUE NOT NULL,
    descripcion TEXT NULL,
    tipo VARCHAR(50) NOT NULL,
    sub_tipo VARCHAR(100) NOT NULL,
    icono_url VARCHAR(255) NULL,
    orden_visualizacion SMALLINT NOT NULL DEFAULT 1,
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',
    
    -- Nombre: No vacío
    CONSTRAINT CHK_metodo_nombre_no_vacio
    CHECK (LEN(TRIM(nombre)) > 0),
    
    -- Tipo: Solo valores permitidos
    CONSTRAINT CHK_metodo_tipo
    CHECK (tipo IN ('electronico', 'fisico', 'digital')),
    
    -- Orden: Mayor a 0
    CONSTRAINT CHK_metodo_orden
    CHECK (orden_visualizacion > 0),
    
    -- Estado: Solo valores permitidos
    CONSTRAINT CHK_metodo_estado
    CHECK (estado IN ('activo', 'inactivo'))
);

CREATE TABLE descuento (
    id_descuento INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) UNIQUE NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',
    tipo VARCHAR(20) NOT NULL,
    fecha_inicio_vigencia DATE NOT NULL,
    fecha_fin_vigencia DATE NULL,

    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
    
    -- Nombre: No vacío
    CONSTRAINT CHK_descuento_nombre_no_vacio
    CHECK (LEN(TRIM(nombre)) > 0),
    
    -- Valor: Mayor a 0
    CONSTRAINT CHK_descuento_valor_positivo
    CHECK (valor > 0),
    
    -- Tipo: Solo valores permitidos
    CONSTRAINT CHK_descuento_tipo
    CHECK (tipo IN ('porcentaje', 'monto_fijo')),
    
    -- Estado: Solo valores permitidos
    CONSTRAINT CHK_descuento_estado
    CHECK (estado IN ('activo', 'inactivo', 'vencido')),
   
    -- Si es porcentaje, valor debe estar entre 0 y 100
    CONSTRAINT CHK_descuento_porcentaje_valido
    CHECK (tipo != 'porcentaje' OR (valor > 0 AND valor <= 100)),
    )
    WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.descuento_historial));



CREATE TABLE reserva (
    id_reserva INT PRIMARY KEY IDENTITY(1,1),
    id_cliente INT NOT NULL,
    id_metodo_de_pago INT NOT NULL,
    fecha_reserva DATETIME NOT NULL DEFAULT GETDATE(),
    
    subtotal_general DECIMAL(10,2) NOT NULL DEFAULT 0,
    descuento_total DECIMAL(10,2) NOT NULL DEFAULT 0,
    iva_total DECIMAL(10,2) NOT NULL DEFAULT 0,
    total_general DECIMAL(10,2) NOT NULL DEFAULT 0,
    
    estado VARCHAR(20) NOT NULL DEFAULT 'pendiente',
    
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),
    
    CONSTRAINT FK_reserva_cliente
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
    
    CONSTRAINT FK_reserva_metodo_pago
    FOREIGN KEY (id_metodo_de_pago) REFERENCES metodo_de_pago(id_metodo_de_pago)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
    
    CONSTRAINT CHK_reserva_subtotal CHECK (subtotal_general >= 0),
    CONSTRAINT CHK_reserva_descuento CHECK (descuento_total >= 0),
    CONSTRAINT CHK_reserva_iva CHECK (iva_total >= 0),
    CONSTRAINT CHK_reserva_total CHECK (total_general >= 0),
    CONSTRAINT CHK_reserva_estado CHECK (estado IN ('pendiente', 'confirmada', 'en_progreso', 'completada', 'cancelada')),
    CONSTRAINT CHK_reserva_fecha_no_futura CHECK (fecha_reserva <= GETDATE())
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.reserva_historial));

CREATE TABLE reserva_descuento (
    id_reserva_descuento INT PRIMARY KEY IDENTITY(1,1),
    id_reserva INT NOT NULL,
    id_descuento INT NULL,
    monto_descontado DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_reserva_descuento_reserva
    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva)
    ON DELETE CASCADE  -- Si se elimina la reserva, se eliminan sus descuentos
    ON UPDATE CASCADE,

    -- FK a descuento
    CONSTRAINT FK_reserva_descuento_descuento
    FOREIGN KEY (id_descuento) REFERENCES descuento(id_descuento)
    ON DELETE SET NULL  -- Si se elimina el descuento, id_descuento queda NULL (pero monto se conserva)
    ON UPDATE CASCADE,

    -- Monto descontado: Mayor a 0
    CONSTRAINT CHK_reserva_descuento_monto
    CHECK (monto_descontado > 0)
);


CREATE TABLE detalle_alquiler (
    id_detalle_alquiler INT PRIMARY KEY IDENTITY(1,1),
    id_reserva INT NOT NULL,
    id_bicicleta INT NOT NULL,
    id_plan INT NOT NULL,
    id_tarifa INT NULL,
    tarifa_unitaria DECIMAL(10,2) NOT NULL,
    cantidad_unidades INT NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    porcentaje_iva DECIMAL(5,2) NOT NULL,
    iva_total DECIMAL(10,2) NOT NULL,
    total_item DECIMAL(10,2) NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NOT NULL,

    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo),

    CONSTRAINT FK_detalle_reserva
    FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva)
    ON DELETE CASCADE
    ON UPDATE CASCADE,

    CONSTRAINT FK_detalle_bicicleta
    FOREIGN KEY (id_bicicleta) REFERENCES bicicleta(id_bicicleta)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,

    CONSTRAINT FK_detalle_plan
    FOREIGN KEY (id_plan) REFERENCES [plan](id_plan)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,

    CONSTRAINT FK_detalle_tarifa
    FOREIGN KEY (id_tarifa) REFERENCES tarifa(id_tarifa)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,

    CONSTRAINT CHK_detalle_tarifa_unitaria
    CHECK (tarifa_unitaria > 0),

    CONSTRAINT CHK_detalle_cantidad
    CHECK (cantidad_unidades > 0),

    CONSTRAINT CHK_detalle_subtotal
    CHECK (subtotal > 0),

    CONSTRAINT CHK_detalle_porcentaje_iva
    CHECK (porcentaje_iva >= 0 AND porcentaje_iva <= 100),

    CONSTRAINT CHK_detalle_iva_total
    CHECK (iva_total >= 0),

    CONSTRAINT CHK_detalle_total_item
    CHECK (total_item > 0),

    CONSTRAINT CHK_detalle_vigencia
    CHECK (fecha_fin > fecha_inicio)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.detalle_alquiler_historial));