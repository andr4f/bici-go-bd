-- Tabla: administrador
CREATE TABLE administrador (
    id_admin INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    fecha_registro DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT chk_admin_nombre_no_vacio CHECK (LEN(nombre) > 0),
    CONSTRAINT chk_admin_email_formato CHECK (email LIKE '%@%'),
    CONSTRAINT chk_admin_apellido_no_vacio CHECK (LEN(apellido) > 0)
);

CREATE TABLE parametro_mantenimiento (
    id_parametro INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    km_umbral INT NOT NULL DEFAULT 500,
    horas_umbral INT NOT NULL DEFAULT 100,
    nombre VARCHAR(50) NOT NULL,
    porcentaje_alerta INT NOT NULL DEFAULT 80,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT chk_km_umbral CHECK (km_umbral > 0),
    CONSTRAINT chk_horas_umbral CHECK (horas_umbral > 0),
    CONSTRAINT chk_porcentaje_alerta CHECK (porcentaje_alerta > 0 AND porcentaje_alerta <= 100),
);

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

-- Tabla: punto_alquiler (CORREGIDA seg�n l�gico IT4)
CREATE TABLE punto_alquiler (
    id_punto_alquiler INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    direccion VARCHAR(255) NOT NULL,
    id_ciudad INT NOT NULL,
    latitud DECIMAL(9,6)  NULL,
    longitud DECIMAL(9,6) NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT chk_nombre_punto_no_vacio CHECK (LEN(nombre) > 0),
    CONSTRAINT chk_punto_latitud CHECK (latitud IS NULL OR (latitud >= -90 AND latitud <= 90)),
    CONSTRAINT chk_punto_longitud CHECK (longitud IS NULL OR (longitud >= -180 AND longitud <= 180)),

    
    CONSTRAINT fk_punto_ciudad FOREIGN KEY (id_ciudad) 
        REFERENCES ciudad(id_ciudad)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
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
    
    CONSTRAINT chk_capacidad_total CHECK (capacidad_total > 0),
    
    CONSTRAINT fk_capacidad_punto FOREIGN KEY (id_punto_alquiler) 
        REFERENCES punto_alquiler(id_punto_alquiler)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
);

CREATE TABLE estado_operativo (
    id_estado_operativo INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL,
    
    CONSTRAINT chk_estado_operativo_valores CHECK (
        nombre IN ('disponible', 'en alquiler', 'en mantenimiento', 'fuera de servicio', 'reservada')
    )
);

CREATE TABLE estado_fisico (
    id_estado_fisico INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL,
    
    CONSTRAINT chk_estado_fisico_valores CHECK (
        nombre IN ('excelente', 'bueno', 'regular', 'requiere servicio', 'da�ada')
    )
);

CREATE TABLE tipo_uso (
    id_tipo_uso INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL,
    
    CONSTRAINT chk_tipo_uso_valores CHECK (
        nombre IN ('monta�a', 'urbana', 'ruta', 'h�brida', 'BMX', 'carretera')
    ),
    CONSTRAINT chk_tipo_uso_nombre CHECK (LEN(nombre) > 0)

);

CREATE TABLE tipo_asistencia (
    id_tipo_asistencia INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL,

    
    CONSTRAINT chk_tipo_asistencia_valores CHECK (
        nombre IN ('convencional', 'el�ctrica')
    ),
    CONSTRAINT chk_tipo_asistencia_nombre CHECK (LEN(nombre) > 0)
);

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
        ON UPDATE NO ACTION
);

CREATE TABLE ubicacion (
    id_bicicleta INT NOT NULL,
    id_punto_alquiler INT NOT NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_fin DATETIME NULL,
    
    PRIMARY KEY (id_bicicleta, fecha_inicio),
    
    CONSTRAINT chk_ubicacion_vigencia CHECK (fecha_fin IS NULL OR fecha_fin > fecha_inicio),
    
    CONSTRAINT fk_ubicacion_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,

    CONSTRAINT fk_ubicacion_punto FOREIGN KEY (id_punto_alquiler) 
        REFERENCES punto_alquiler(id_punto_alquiler)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);



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
    fecha_activacion DATETIME NOT NULL DEFAULT GETDATE(),

    PRIMARY KEY (id_servicio, id_punto_alquiler),
    
    CONSTRAINT chk_estado_servicio CHECK (estado IN ('activo', 'inactivo', 'suspendido')),

    CONSTRAINT fk_punto_servicio_punto FOREIGN KEY (id_punto_alquiler) 
        REFERENCES punto_alquiler(id_punto_alquiler) 
        ON DELETE CASCADE
        ON UPDATE NO ACTION,

    CONSTRAINT fk_punto_servicio_servicio FOREIGN KEY (id_servicio) 
        REFERENCES servicio(id_servicio) 
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);


-- Tabla: plan
CREATE TABLE [plan] (
    id_plan INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL,
    
    CONSTRAINT chk_plan_nombre_no_vacio CHECK (LEN(nombre) > 0)
);

CREATE TABLE tarifa (
    id_plan INT NOT NULL,                   
    id_bicicleta INT NOT NULL,
    fecha_inicio DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE), 
    valor DECIMAL(10,2) NOT NULL,
    moneda CHAR(3) NOT NULL,
    fecha_fin DATE NULL,
    id_admin INT NULL,
    
    PRIMARY KEY (id_plan, id_bicicleta),
    
    CONSTRAINT chk_tarifa_valor CHECK (valor > 0),
    CONSTRAINT chk_tarifa_moneda CHECK (moneda LIKE '[A-Z][A-Z][A-Z]'),
    CONSTRAINT chk_tarifa_vigencia CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    
    CONSTRAINT fk_tarifa_plan FOREIGN KEY (id_plan) 
        REFERENCES [plan] (id_plan)
        ON DELETE NO ACTION  
        ON UPDATE NO ACTION,

    CONSTRAINT fk_tarifa_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
        
    CONSTRAINT fk_tarifa_admin FOREIGN KEY (id_admin) 
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

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
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',
    
    CONSTRAINT chk_monto_maximo CHECK (monto_maximo IS NULL OR monto_maximo > 0),
    CONSTRAINT chk_estado_cobertura_prin CHECK (
        estado IN ('activo', 'vencido', 'cancelado', 'suspendido', 'en tr�mite')
    ),
  
    
    CONSTRAINT fk_cobertura_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,

    CONSTRAINT fk_cobertura_tipo FOREIGN KEY (id_tipo_cobertura) 
        REFERENCES tipo_cobertura(id_tipo_cobertura)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
);

-- Tabla: condiciones_especiales
CREATE TABLE condiciones_especiales (
    id_condicion INT PRIMARY KEY IDENTITY(1,1),
    id_bicicleta INT NOT NULL,
    tipo_condicion VARCHAR(50) NOT NULL,  -- 'peso', 'altura', 'edad', 'experiencia', etc.
    valor_minimo DECIMAL(10,2) NULL,
    valor_maximo DECIMAL(10,2) NULL,
    unidad_medida VARCHAR(20) NULL,  -- 'kg', 'cm', 'a�os', etc.
    descripcion VARCHAR(500) NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),
   
    CONSTRAINT chk_condicion_tipo CHECK (
        tipo_condicion IN ('peso_maximo', 'altura_minima', 'altura_maxima', 'edad_minima', 'experiencia_minima', 'licencia_requerida', 'otro')
    ),
    CONSTRAINT chk_condicion_valores CHECK (
        valor_minimo IS NULL OR valor_maximo IS NULL OR valor_minimo <= valor_maximo
    ),
    
    CONSTRAINT fk_condicion_bicicleta FOREIGN KEY (id_bicicleta)
        REFERENCES bicicleta(id_bicicleta)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
);

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
);

CREATE TABLE etiqueta (
    id_etiqueta INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    tipo_de_etiqueta VARCHAR(50) NULL,
    descripcion VARCHAR(255) NULL,
    
    CONSTRAINT chk_etiqueta_tipo CHECK (
        tipo_de_etiqueta IS NULL OR 
        tipo_de_etiqueta IN ('caracter�stica', 'accesorio', 'accesibilidad', 'restricci�n', 'promoci�n', 'terreno')
    ),
    CONSTRAINT chk_etiqueta_nombre_no_vacio CHECK (LEN(nombre) > 0)
);

CREATE TABLE bicicleta_etiqueta (
    id_bicicleta INT NOT NULL,
    id_etiqueta INT NOT NULL,
    fecha_asignacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id_bicicleta, id_etiqueta),
    
    CONSTRAINT fk_bici_eti_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,

    CONSTRAINT fk_bici_eti_etiqueta FOREIGN KEY (id_etiqueta) 
        REFERENCES etiqueta(id_etiqueta)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE imagen_bicicleta (
    id_imagen INT PRIMARY KEY IDENTITY(1,1),
    id_bicicleta INT NOT NULL,
    url_imagen VARCHAR(500) NOT NULL,
    formato VARCHAR(10) NOT NULL,
    resolucion_ancho INT NOT NULL,
    resolucion_alto INT NOT NULL,
    tamano_kb INT NOT NULL,
    es_principal BIT NOT NULL DEFAULT 0,
    orden_visualizacion SMALLINT NOT NULL DEFAULT 1,
    fecha_carga DATETIME NOT NULL DEFAULT GETDATE(),
    
    -- Validaciones b�sicas
    CONSTRAINT chk_url_imagen CHECK (url_imagen LIKE 'http://%' OR url_imagen LIKE 'https://%'),
    CONSTRAINT chk_formato CHECK (formato IN ('JPG', 'JPEG', 'PNG', 'WEBP', 'GIF', 'AVIF')),
    CONSTRAINT chk_resolucion_ancho CHECK (resolucion_ancho >= 200 AND resolucion_ancho <= 8192),  -- ? M�s flexible
    CONSTRAINT chk_resolucion_alto CHECK (resolucion_alto >= 200 AND resolucion_alto <= 8192),
    CONSTRAINT chk_tamano_kb CHECK (tamano_kb > 0 AND tamano_kb <= 15000),  -- ? 15MB m�ximo
    CONSTRAINT chk_orden_visualizacion CHECK (orden_visualizacion >= 1 AND orden_visualizacion <= 100),
    
    -- FK
    CONSTRAINT fk_imagen_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
);


--CREAR TABLAS ESPEJO HISTORIAL

CREATE TABLE hist_parametro_mantenimiento (
    id_hist_parametro INT PRIMARY KEY IDENTITY(1,1),  
    id_parametro INT NOT NULL,  
    km_umbral INT NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    horas_umbral INT NOT NULL,
    porcentaje_alerta INT NOT NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN ('creacion', 'modificacion', 'eliminacion')),
    motivo VARCHAR(255) NULL,
   
    CONSTRAINT fk_hist_parametro_principal FOREIGN KEY (id_parametro)
        REFERENCES parametro_mantenimiento(id_parametro)
        ON DELETE CASCADE 
        ON UPDATE NO ACTION,

    CONSTRAINT fk_hist_parametro_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE hist_estado_operativo (
    id_hist_estado_operativo INT PRIMARY KEY IDENTITY(1,1),
    id_bicicleta INT NOT NULL,
    id_estado_operativo INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN ('asignacion', 'modificacion', 'desasignacion')),
   
   CONSTRAINT fk_hist_estado_operativo_principal FOREIGN KEY (id_bicicleta)
    REFERENCES bicicleta(id_bicicleta)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    CONSTRAINT fk_hist_estado_operativo_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE hist_estado_fisico (
    id_hist_estado_fisico INT PRIMARY KEY IDENTITY(1,1),
    id_bicicleta INT NOT NULL,
    id_estado_fisico INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN ('asignacion', 'modificacion', 'desasignacion')),
   
   CONSTRAINT fk_hist_estado_fisico_principal FOREIGN KEY (id_bicicleta)
    REFERENCES bicicleta(id_bicicleta)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    CONSTRAINT fk_hist_estado_fisico_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE hist_detalle_dia_horario (
    id_hist_horario INT PRIMARY KEY IDENTITY(1,1),
    id_punto_alquiler INT NOT NULL,
    dia_semana SMALLINT NOT NULL,
    hora_apertura TIME NULL,
    hora_cierre TIME NULL,
    estado VARCHAR(20) NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN ('asignacion', 'modificacion', 'desasignacion')),
   
   CONSTRAINT fk_hist_detalle_horario_principal FOREIGN KEY (id_punto_alquiler, dia_semana)  
    REFERENCES detalle_dia_horario(id_punto_alquiler, dia_semana)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    CONSTRAINT fk_hist_detalle_horario_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE hist_capacidad (
    id_hist_capacidad INT PRIMARY KEY IDENTITY(1,1),
    id_punto_alquiler INT NOT NULL,
    capacidad_total INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN ('asignacion', 'modificacion', 'desasignacion')),

   CONSTRAINT fk_hist_capacidad_principal FOREIGN KEY (id_punto_alquiler)
    REFERENCES capacidad(id_punto_alquiler)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    CONSTRAINT fk_hist_capacidad_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE hist_punto_servicio (
    id_hist_punto_servicio INT PRIMARY KEY IDENTITY(1,1),
    id_punto_alquiler INT NOT NULL,
    id_servicio INT NOT NULL,
    estado VARCHAR(20) NOT NULL,
    descripcion_especifica VARCHAR(255) NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT GETDATE(),  
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN ('creacion', 'modificacion', 'eliminacion')),

    CONSTRAINT fk_hist_punto_servicio_principal FOREIGN KEY (id_servicio, id_punto_alquiler) 
        REFERENCES punto_servicio(id_servicio, id_punto_alquiler)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
        
    CONSTRAINT fk_hist_punto_servicio_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE hist_tarifa (
    id_hist_tarifa INT PRIMARY KEY IDENTITY(1,1),
    id_plan INT NOT NULL,
    id_bicicleta INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    moneda CHAR(3) NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN ('asignacion', 'modificacion', 'desasignacion')),

   CONSTRAINT fk_hist_tarifa_principal FOREIGN KEY (id_plan, id_bicicleta)  -- ? FK compuesta
    REFERENCES tarifa(id_plan, id_bicicleta)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    CONSTRAINT fk_hist_tarifa_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE hist_cobertura_seguro (
    id_hist_cobertura INT PRIMARY KEY IDENTITY(1,1),
    id_cobertura INT NOT NULL,
    id_bicicleta INT NOT NULL,
    id_tipo_cobertura INT NOT NULL,
    monto_maximo DECIMAL(12,2) NULL,
    estado VARCHAR(20) NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN ('asignacion', 'modificacion', 'desasignacion')),
   
     CONSTRAINT fk_hist_cobertura_principal FOREIGN KEY (id_cobertura)
        REFERENCES cobertura_seguro(id_cobertura)
        ON DELETE CASCADE 
        ON UPDATE NO ACTION,

    CONSTRAINT fk_hist_cobertura_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE hist_condiciones_especiales (
    id_hist_condicion INT PRIMARY KEY IDENTITY(1,1),
    id_condicion INT NOT NULL,
    id_bicicleta INT NOT NULL,
    tipo_condicion VARCHAR(50) NOT NULL,
    valor_minimo DECIMAL(10,2) NULL,
    valor_maximo DECIMAL(10,2) NULL,
    unidad_medida VARCHAR(20) NULL,
    descripcion VARCHAR(500) NULL,
    estado VARCHAR(20) NOT NULL,
    fecha_inicio_vigencia DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_fin_vigencia DATETIME NULL,
    id_admin INT NOT NULL,
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN ('asignacion', 'modificacion', 'desasignacion')),
   
    CONSTRAINT fk_hist_condicion_principal FOREIGN KEY (id_condicion)
        REFERENCES condiciones_especiales(id_condicion)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
        
    CONSTRAINT fk_hist_condicion_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE hist_restriccion_terreno (
    id_hist_restriccion INT PRIMARY KEY IDENTITY(1,1),
    id_restriccion INT NOT NULL,
    id_condicion INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN ('asignacion', 'modificacion', 'desasignacion')),
   
    CONSTRAINT fk_hist_restriccion_condicion FOREIGN KEY (id_condicion)
        REFERENCES condiciones_especiales(id_condicion)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    CONSTRAINT fk_hist_restriccion_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE hist_bicicleta_etiqueta (
    id_hist_asignacion INT PRIMARY KEY IDENTITY(1,1),
    id_bicicleta INT NOT NULL,
    id_etiqueta INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN ('asignacion', 'modificacion', 'desasignacion')),
   
    CONSTRAINT fk_hist_bici_eti_principal FOREIGN KEY (id_bicicleta, id_etiqueta)
        REFERENCES bicicleta_etiqueta(id_bicicleta, id_etiqueta)
        ON DELETE CASCADE 
        ON UPDATE NO ACTION,

    CONSTRAINT fk_hist_bici_eti_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE hist_imagen_bicicleta (
    id_hist_imagen INT PRIMARY KEY IDENTITY(1,1),
    id_imagen INT NOT NULL,
    id_bicicleta INT NOT NULL,
    url_imagen VARCHAR(500) NOT NULL,
    formato VARCHAR(10) NOT NULL,
    resolucion_ancho INT NOT NULL,
    resolucion_alto INT NOT NULL,
    tamano_kb INT NOT NULL,
    es_principal BIT NOT NULL,
    orden_visualizacion SMALLINT NOT NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN ('asignacion', 'modificacion', 'desasignacion')),
   
    CONSTRAINT fk_hist_imagen_principal FOREIGN KEY (id_imagen)
        REFERENCES imagen_bicicleta(id_imagen)
        ON DELETE CASCADE  
        ON UPDATE NO ACTION,

    CONSTRAINT fk_hist_imagen_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);



CREATE TABLE hist_tipo_uso_bicicleta (
    id_hist_tipo_uso INT PRIMARY KEY IDENTITY(1,1),
    id_bicicleta INT NOT NULL,
    id_tipo_uso INT NOT NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN ('asignacion', 'modificacion', 'desasignacion')),
   
    CONSTRAINT fk_hist_tipo_uso_bicicleta FOREIGN KEY (id_bicicleta)
        REFERENCES bicicleta(id_bicicleta)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,

    CONSTRAINT fk_hist_tipo_uso_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE hist_tipo_asistencia_bicicleta (
    id_hist_tipo_asistencia INT PRIMARY KEY IDENTITY(1,1),
    id_bicicleta INT NOT NULL,
    id_tipo_asistencia INT NOT NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN ('asignacion', 'modificacion', 'desasignacion')),
   
    CONSTRAINT fk_hist_tipo_asistencia_bicicleta FOREIGN KEY (id_bicicleta)
        REFERENCES bicicleta(id_bicicleta)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,

    CONSTRAINT fk_hist_tipo_asistencia_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE hist_capacidad_tipo (
    id_hist_capacidad_tipo INT PRIMARY KEY IDENTITY(1,1),
    id_capacidad_tipo INT NOT NULL,
    capacidad_especifica INT NOT NULL,
    id_punto_alquiler INT NOT NULL,
    id_tipo_uso INT NOT NULL,
    id_tipo_asistencia INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
   
    CONSTRAINT fk_hist_capacidad_tipo_punto FOREIGN KEY (id_punto_alquiler)
        REFERENCES capacidad(id_punto_alquiler)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT fk_hist_capacidad_tipo_uso FOREIGN KEY (id_tipo_uso)
        REFERENCES tipo_uso(id_tipo_uso)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT fk_hist_capacidad_tipo_asistencia FOREIGN KEY (id_tipo_asistencia)
        REFERENCES tipo_asistencia(id_tipo_asistencia)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT fk_hist_capacidad_tipo_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE hist_bicicleta (
    id_hist_bicicleta INT PRIMARY KEY IDENTITY(1,1),
    id_bicicleta INT NOT NULL,
    codigo_unico VARCHAR(50) NOT NULL,
    marca_comercial VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    anio_fabricacion SMALLINT NOT NULL,
    tamano_marco VARCHAR(20) NOT NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN ('creacion', 'modificacion', 'eliminacion')),
   
    CONSTRAINT fk_hist_bicicleta_principal FOREIGN KEY (id_bicicleta)
        REFERENCES bicicleta(id_bicicleta)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
        
    CONSTRAINT fk_hist_bicicleta_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE hist_punto_alquiler (
    id_hist_punto INT PRIMARY KEY IDENTITY(1,1),
    id_punto_alquiler INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    id_ciudad INT NOT NULL,
    latitud DECIMAL(9,6) NULL,
    longitud DECIMAL(9,6) NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN ('creacion', 'modificacion', 'eliminacion')),
   
    CONSTRAINT fk_hist_punto_principal FOREIGN KEY (id_punto_alquiler)
        REFERENCES punto_alquiler(id_punto_alquiler)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
        
    CONSTRAINT fk_hist_punto_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE hist_uso_acumulado (
    id_hist_uso INT PRIMARY KEY IDENTITY(1,1),
    id_bicicleta INT NOT NULL,
    km_total DECIMAL(10,2) NOT NULL,
    horas_total DECIMAL(10,2) NOT NULL,
    km_parcial DECIMAL(10,2) NOT NULL,
    horas_parcial DECIMAL(10,2) NOT NULL,
    fecha_ultimo_mantenimiento DATETIME NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN ('actualizacion', 'reset_parcial', 'mantenimiento')),
    motivo VARCHAR(255) NULL,
   
    CONSTRAINT fk_hist_uso_principal FOREIGN KEY (id_bicicleta)
        REFERENCES uso_acumulado(id_bicicleta)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
        
    CONSTRAINT fk_hist_uso_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE hist_excepcion_horario (
    id_hist_excepcion INT PRIMARY KEY IDENTITY(1,1),
    id_excepcion INT NOT NULL,
    id_punto_alquiler INT NOT NULL,
    fecha_excepcion DATE NOT NULL,
    tipo_excepcion VARCHAR(50) NOT NULL,
    motivo VARCHAR(255) NULL,
    hora_apertura TIME NOT NULL,
    hora_cierre TIME NOT NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN ('creacion', 'modificacion', 'eliminacion')),
   
    CONSTRAINT fk_hist_excepcion_principal FOREIGN KEY (id_excepcion)
        REFERENCES excepcion_horario(id_excepcion)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
        
    CONSTRAINT fk_hist_excepcion_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE hist_horario_base (
    id_hist_horario_base INT PRIMARY KEY IDENTITY(1,1),
    id_punto_alquiler INT NOT NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT GETDATE(),
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    tipo_cambio VARCHAR(50) NOT NULL CHECK (tipo_cambio IN ('creacion', 'modificacion', 'eliminacion')),
    motivo VARCHAR(255) NULL,
   
    CONSTRAINT fk_hist_horario_base_principal FOREIGN KEY (id_punto_alquiler)
        REFERENCES horario_base(id_punto_alquiler)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
        
    CONSTRAINT fk_hist_horario_base_admin FOREIGN KEY (id_admin)
        REFERENCES administrador(id_admin)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);