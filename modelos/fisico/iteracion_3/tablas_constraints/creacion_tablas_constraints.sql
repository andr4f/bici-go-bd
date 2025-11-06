-- ============================================================
-- SISTEMA BICI-GO - MODELO FÍSICO
-- Script 01: CREACIÓN DE TABLAS BASE - SQL SERVER COMPATIBLE
-- Diseñador Físico Senior: Implementación de Tablas Principales
-- Fecha: Noviembre 2, 2025
-- SGBD: SQL Server 2016+ (T-SQL)
-- Enfoque: Tablas Limpias + Tablas Espejo (Historial)
-- ============================================================

-- CORRECCIONES SQL SERVER:
-- 1. Eliminadas "ON DELETE RESTRICT" (SQL Server no lo soporta)
-- 2. Eliminadas "ON UPDATE RESTRICT" (SQL Server no lo soporta)
-- 3. Cambio: "ON DELETE NO ACTION" (equivalente a RESTRICT)
-- 4. Eliminadas UNIQUE filtradas en CREATE TABLE (usar índices después)
-- 5. Las UNIQUE filtradas se crearán en script de índices (03_indexes.sql)

-- ============================================================
-- FASE 1: TABLAS CATALOGO (SIN HISTORIAL)
-- ============================================================

-- Tabla: pais
CREATE TABLE pais (
    id_pais INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    moneda_oficial CHAR(3) NOT NULL,
    
    CONSTRAINT chk_moneda_codigo CHECK (moneda_oficial LIKE '[A-Z][A-Z][A-Z]'),
    CONSTRAINT chk_nombre_no_vacio CHECK (LEN(nombre) > 0)
);

-- Tabla: ciudad
CREATE TABLE ciudad (
    id_ciudad INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    latitud DECIMAL(9,6) NOT NULL,
    longitud DECIMAL(9,6) NOT NULL,
    id_pais INT NOT NULL,
    
    CONSTRAINT chk_latitud CHECK (latitud >= -90 AND latitud <= 90),
    CONSTRAINT chk_longitud CHECK (longitud >= -180 AND longitud <= 180),
    
    CONSTRAINT fk_ciudad_pais FOREIGN KEY (id_pais) 
        REFERENCES pais(id_pais) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Tabla: punto_alquiler
CREATE TABLE punto_alquiler (
    id_punto_alquiler INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    horario VARCHAR(100) NULL,
    capacidad_maxima INT NOT NULL,
    id_ciudad INT NOT NULL,
    
    CONSTRAINT chk_capacidad CHECK (capacidad_maxima > 0),
    CONSTRAINT chk_nombre_punto_no_vacio CHECK (LEN(nombre) > 0),
    
    CONSTRAINT fk_punto_ciudad FOREIGN KEY (id_ciudad) 
        REFERENCES ciudad(id_ciudad) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Tabla: plan
CREATE TABLE [plan] (
    id_plan INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL,
    
    CONSTRAINT chk_plan_nombre_no_vacio CHECK (LEN(nombre) > 0)
);

-- Tabla: etiqueta
CREATE TABLE etiqueta (
    id_etiqueta INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    tipo_de_etiqueta VARCHAR(50) NULL,
    descripcion VARCHAR(255) NULL,
    
    CONSTRAINT chk_etiqueta_tipo CHECK (
        tipo_de_etiqueta IS NULL OR 
        tipo_de_etiqueta IN ('característica', 'accesibilidad', 'restricción', 'promoción')
    ),
    CONSTRAINT chk_etiqueta_nombre_no_vacio CHECK (LEN(nombre) > 0)
);

-- Tabla: tipo_cobertura
CREATE TABLE tipo_cobertura (
    id_tipo_cobertura INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NULL,
    
    CONSTRAINT chk_tipo_cobertura_nombre_no_vacio CHECK (LEN(nombre) > 0)
);

-- ============================================================
-- FASE 2: TABLAS TRANSACCIONALES PRINCIPALES (LIMPIAS)
-- ============================================================

-- Tabla: administrador
CREATE TABLE administrador (
    id_admin INT PRIMARY KEY IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_admin_nombre_no_vacio CHECK (LEN(nombre) > 0),
    CONSTRAINT chk_admin_email_formato CHECK (email LIKE '%@%'),
    CONSTRAINT chk_admin_apellido_no_vacio CHECK (LEN(apellido) > 0)
);

-- Tabla: bicicleta (LIMPIA)
CREATE TABLE bicicleta (
    id_bicicleta INT PRIMARY KEY IDENTITY(1,1),
    codigo_unico VARCHAR(50) NOT NULL UNIQUE,
    marca_comercial VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    anio_fabricacion SMALLINT NOT NULL,
    tamano_marco VARCHAR(20) NOT NULL,
    fecha_creacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_bicicleta_codigo CHECK (codigo_unico LIKE '[A-Z][A-Z][E][0-9][0-9][0-9][0-9][A-Z][A-Z][C]'),
    CONSTRAINT chk_bicicleta_anio CHECK (anio_fabricacion >= 1900 AND anio_fabricacion <= YEAR(GETDATE())),
    CONSTRAINT chk_bicicleta_marca_no_vacio CHECK (LEN(marca_comercial) > 0),
    CONSTRAINT chk_bicicleta_modelo_no_vacio CHECK (LEN(modelo) > 0),
    CONSTRAINT chk_tamano_marco CHECK (tamano_marco IN ('XS', 'S', 'M', 'L', 'XL', 'XXL'))
);

-- Tabla: uso_acumulado (LIMPIA)
CREATE TABLE uso_acumulado (
    id_bicicleta INT PRIMARY KEY,
    km_total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    horas_total DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    km_parcial DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    horas_parcial DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    fecha_ultimo_mantenimiento DATETIME NULL,
    fecha_ultima_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_km_total CHECK (km_total >= 0),
    CONSTRAINT chk_horas_total CHECK (horas_total >= 0),
    CONSTRAINT chk_km_parcial CHECK (km_parcial >= 0 AND km_parcial <= km_total),
    CONSTRAINT chk_horas_parcial CHECK (horas_parcial >= 0 AND horas_parcial <= horas_total),
    CONSTRAINT chk_mantenimiento_fecha CHECK (
        fecha_ultimo_mantenimiento IS NULL OR 
        fecha_ultimo_mantenimiento <= fecha_ultima_actualizacion
    ),
    
    CONSTRAINT fk_uso_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Tabla: parametro_mantenimiento
CREATE TABLE parametro_mantenimiento (
    id_parametro INT PRIMARY KEY IDENTITY(1,1),
    km_umbral INT NOT NULL DEFAULT 500,
    horas_umbral INT NOT NULL DEFAULT 100,
    porcentaje_alerta INT NOT NULL DEFAULT 80,
    
    CONSTRAINT chk_km_umbral CHECK (km_umbral > 0 AND km_umbral <= 5000),
    CONSTRAINT chk_horas_umbral CHECK (horas_umbral > 0 AND horas_umbral <= 1000),
    CONSTRAINT chk_porcentaje_alerta CHECK (porcentaje_alerta > 0 AND porcentaje_alerta <= 100)
);

-- Tabla: imagen_bicicleta (LIMPIA)
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
    fecha_carga DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_url_imagen CHECK (url_imagen LIKE 'http://%' OR url_imagen LIKE 'https://%'),
    CONSTRAINT chk_formato CHECK (formato IN ('JPG', 'JPEG', 'PNG', 'WEBP', 'GIF')),
    CONSTRAINT chk_resolucion_ancho CHECK (resolucion_ancho >= 800 AND resolucion_ancho <= 4096),
    CONSTRAINT chk_resolucion_alto CHECK (resolucion_alto >= 600 AND resolucion_alto <= 4096),
    CONSTRAINT chk_tamano_kb CHECK (tamano_kb > 0 AND tamano_kb <= 5120),
    
    CONSTRAINT fk_imagen_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta) ON DELETE CASCADE ON UPDATE NO ACTION
);

-- Tabla: condiciones_especiales (LIMPIA)
CREATE TABLE condiciones_especiales (
    id_condicion INT PRIMARY KEY IDENTITY(1,1),
    id_bicicleta INT NOT NULL,
    descripcion_condiciones VARCHAR(500) NULL,
    peso_maximo_kg DECIMAL(5,2) NULL,
    altura_minima_cm SMALLINT NULL,
    altura_maxima_cm SMALLINT NULL,
    
    CONSTRAINT chk_peso_maximo CHECK (peso_maximo_kg IS NULL OR (peso_maximo_kg > 0 AND peso_maximo_kg <= 200)),
    CONSTRAINT chk_altura_minima CHECK (altura_minima_cm IS NULL OR (altura_minima_cm >= 100 AND altura_minima_cm <= 220)),
    CONSTRAINT chk_altura_maxima CHECK (altura_maxima_cm IS NULL OR (altura_maxima_cm >= 100 AND altura_maxima_cm <= 220)),
    CONSTRAINT chk_altura_minima_max CHECK (
        altura_minima_cm IS NULL OR altura_maxima_cm IS NULL OR
        altura_minima_cm < altura_maxima_cm
    ),
    
    CONSTRAINT fk_condiciones_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta) ON DELETE CASCADE ON UPDATE NO ACTION
);

-- Tabla: restriccion_terreno (LIMPIA)
CREATE TABLE restriccion_terreno (
    id_restriccion INT PRIMARY KEY IDENTITY(1,1),
    id_condicion INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255) NULL,
    
    CONSTRAINT chk_restriccion_nombre_no_vacio CHECK (LEN(nombre) > 0),
    
    CONSTRAINT fk_restriccion_condicion FOREIGN KEY (id_condicion) 
        REFERENCES condiciones_especiales(id_condicion) ON DELETE CASCADE ON UPDATE NO ACTION
);

-- ============================================================
-- FASE 3: TABLAS M:N (MUCHOS A MUCHOS) SIN HISTORIAL VIGENCIA
-- ============================================================

-- Tabla: bicicleta_etiqueta (LIMPIA)
CREATE TABLE bicicleta_etiqueta (
    id_bicicleta INT NOT NULL,
    id_etiqueta INT NOT NULL,
    fecha_asignacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id_bicicleta, id_etiqueta),
    
    CONSTRAINT fk_bici_eti_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_bici_eti_etiqueta FOREIGN KEY (id_etiqueta) 
        REFERENCES etiqueta(id_etiqueta) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Tabla: ubicacion (LIMPIA)
CREATE TABLE ubicacion (
    id_bicicleta INT NOT NULL,
    id_punto_alquiler INT NOT NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (id_bicicleta, fecha_inicio),
    
    CONSTRAINT fk_ubicacion_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_ubicacion_punto FOREIGN KEY (id_punto_alquiler) 
        REFERENCES punto_alquiler(id_punto_alquiler) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Tabla: tarifa (LIMPIA)
CREATE TABLE tarifa (
    id_plan INT NOT NULL,
    id_bicicleta INT NOT NULL,
    fecha_inicio DATE NOT NULL DEFAULT CAST(CURRENT_TIMESTAMP AS DATE),
    valor DECIMAL(10,2) NOT NULL,
    moneda CHAR(3) NOT NULL,
    
    PRIMARY KEY (id_plan, id_bicicleta, fecha_inicio),
    
    CONSTRAINT chk_tarifa_valor CHECK (valor > 0),
    CONSTRAINT chk_tarifa_moneda CHECK (moneda LIKE '[A-Z][A-Z][A-Z]'),
    
    CONSTRAINT fk_tarifa_plan FOREIGN KEY (id_plan) 
        REFERENCES [plan] (id_plan) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_tarifa_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Tabla principal: cobertura_seguro (LIMPIA)
CREATE TABLE cobertura_seguro (
    id_cobertura INT PRIMARY KEY IDENTITY(1,1),
    id_bicicleta INT NOT NULL,
    id_tipo_cobertura INT NOT NULL,
    monto_maximo DECIMAL(12,2) NULL,
    fecha_inicio_vigencia DATE NOT NULL DEFAULT CAST(CURRENT_TIMESTAMP AS DATE),
    fecha_fin_vigencia DATE NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',
    
    CONSTRAINT chk_monto_maximo CHECK (monto_maximo IS NULL OR monto_maximo > 0),
    CONSTRAINT chk_estado_cobertura_prin CHECK (
        estado IN ('activo', 'vencido', 'cancelado', 'suspendido', 'en trámite')
    ),
    CONSTRAINT chk_fecha_cobertura_prin CHECK (fecha_fin_vigencia IS NULL OR fecha_fin_vigencia >= fecha_inicio_vigencia),
    
    CONSTRAINT fk_cobertura_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_cobertura_tipo FOREIGN KEY (id_tipo_cobertura) 
        REFERENCES tipo_cobertura(id_tipo_cobertura) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- ============================================================
-- FASE 4: TABLAS ESPEJO (HISTORIAL + AUDITORÍA)
-- ============================================================

-- Tabla Espejo: tabla_espejo_estado_operativo
CREATE TABLE tabla_espejo_estado_operativo (
    id_bicicleta INT NOT NULL,
    estado VARCHAR(20) NOT NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    
    PRIMARY KEY (id_bicicleta, fecha_inicio),
    
    CONSTRAINT chk_estado_operativo CHECK (
        estado IN ('disponible', 'en alquiler', 'en mantenimiento', 'fuera de servicio', 'reservada')
    ),
    CONSTRAINT chk_fecha_estado CHECK (fecha_fin IS NULL OR fecha_fin > fecha_inicio),
    
    CONSTRAINT fk_espejo_estado_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_espejo_estado_admin FOREIGN KEY (id_admin) 
        REFERENCES administrador(id_admin) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Tabla Espejo: tabla_espejo_estado_fisico
CREATE TABLE tabla_espejo_estado_fisico (
    id_bicicleta INT NOT NULL,
    condicion VARCHAR(20) NOT NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    
    PRIMARY KEY (id_bicicleta, fecha_inicio),
    
    CONSTRAINT chk_estado_fisico CHECK (
        condicion IN ('excelente', 'bueno', 'regular', 'requiere servicio', 'dañada')
    ),
    CONSTRAINT chk_fecha_condicion CHECK (fecha_fin IS NULL OR fecha_fin > fecha_inicio),
    
    CONSTRAINT fk_espejo_condicion_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_espejo_condicion_admin FOREIGN KEY (id_admin) 
        REFERENCES administrador(id_admin) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Tabla Espejo: tabla_espejo_tipo_uso
CREATE TABLE tabla_espejo_tipo_uso (
    id_tipo_uso INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    id_bicicleta INT NOT NULL,
    nombre_tipo_uso VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    
    CONSTRAINT chk_tipo_uso CHECK (
        nombre_tipo_uso IN ('montaña', 'urbana', 'ruta', 'híbrida', 'BMX', 'carretera')
    ),
    CONSTRAINT chk_fecha_tipo_uso CHECK (fecha_fin IS NULL OR fecha_fin > fecha_inicio),
    
    CONSTRAINT fk_espejo_tipo_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_espejo_tipo_admin FOREIGN KEY (id_admin) 
        REFERENCES administrador(id_admin) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Tabla Espejo: tabla_espejo_tipo_asistencia
CREATE TABLE tabla_espejo_tipo_asistencia (
    id_tipo_asistencia INT NOT NULL PRIMARY KEY IDENTITY(1,1),
    id_bicicleta INT NOT NULL,
    nombre_tipo_asistencia VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    
    CONSTRAINT chk_tipo_asistencia CHECK (
        nombre_tipo_asistencia IN ('convencional', 'eléctrica', 'asistida por pedaleo')
    ),
    CONSTRAINT chk_fecha_tipo_asistencia CHECK (fecha_fin IS NULL OR fecha_fin > fecha_inicio),
    
    CONSTRAINT fk_espejo_asistencia_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_espejo_asistencia_admin FOREIGN KEY (id_admin) 
        REFERENCES administrador(id_admin) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Tabla Espejo: tabla_espejo_ubicacion
CREATE TABLE tabla_espejo_ubicacion (
    id_bicicleta INT NOT NULL,
    id_punto_alquiler INT NOT NULL,
    fecha_inicio DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin DATETIME NULL,
    id_admin INT NOT NULL,
    
    PRIMARY KEY (id_bicicleta, fecha_inicio),
    
    CONSTRAINT chk_fecha_ubicacion CHECK (fecha_fin IS NULL OR fecha_fin > fecha_inicio),
    
    CONSTRAINT fk_espejo_ubicacion_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_espejo_ubicacion_punto FOREIGN KEY (id_punto_alquiler) 
        REFERENCES punto_alquiler(id_punto_alquiler) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_espejo_ubicacion_admin FOREIGN KEY (id_admin) 
        REFERENCES administrador(id_admin) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Tabla Espejo: tabla_espejo_tarifa
CREATE TABLE tabla_espejo_tarifa (
    id_plan INT NOT NULL,
    id_bicicleta INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    moneda CHAR(3) NOT NULL,
    fecha_fin DATE NULL,
    id_admin INT NOT NULL,
    
    PRIMARY KEY (id_plan, id_bicicleta, fecha_inicio),
    
    CONSTRAINT chk_fecha_tarifa CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    
    CONSTRAINT fk_espejo_tarifa_plan FOREIGN KEY (id_plan) 
        REFERENCES [plan](id_plan) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_espejo_tarifa_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_espejo_tarifa_admin FOREIGN KEY (id_admin) 
        REFERENCES administrador(id_admin) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE tabla_espejo_bicicleta_etiqueta (
    id_bicicleta INT NOT NULL,
    id_etiqueta INT NOT NULL,
    fecha_asignacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_eliminacion DATETIME NULL,
    id_admin INT NOT NULL,
    
    PRIMARY KEY (id_bicicleta, id_etiqueta, fecha_asignacion),
    
    CONSTRAINT chk_fecha_etiqueta CHECK (fecha_eliminacion IS NULL OR fecha_eliminacion > fecha_asignacion),
    
    -- CORREGIDA: ON DELETE NO ACTION (estaba CASCADE)
    CONSTRAINT fk_espejo_etiqueta_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_espejo_etiqueta_etiqueta FOREIGN KEY (id_etiqueta) 
        REFERENCES etiqueta(id_etiqueta) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_espejo_etiqueta_admin FOREIGN KEY (id_admin) 
        REFERENCES administrador(id_admin) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE tabla_espejo_condiciones_especiales (
    id_condicion INT NOT NULL,
    id_bicicleta INT NOT NULL,
    descripcion_condiciones VARCHAR(500) NULL,
    peso_maximo_kg DECIMAL(5,2) NULL,
    altura_minima_cm SMALLINT NULL,
    altura_maxima_cm SMALLINT NULL,
    fecha_inicio_vigencia DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin_vigencia DATETIME NULL,
    id_admin INT NOT NULL,
    
    PRIMARY KEY (id_condicion, fecha_inicio_vigencia),
    
    CONSTRAINT chk_fecha_condiciones CHECK (fecha_fin_vigencia IS NULL OR fecha_fin_vigencia > fecha_inicio_vigencia),
    
    -- CORREGIDA: ON DELETE NO ACTION (estaba CASCADE)
    CONSTRAINT fk_espejo_condiciones_original FOREIGN KEY (id_condicion) 
        REFERENCES condiciones_especiales(id_condicion) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_espejo_condiciones_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_espejo_condiciones_admin FOREIGN KEY (id_admin) 
        REFERENCES administrador(id_admin) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Tabla Espejo: tabla_espejo_bicicleta
CREATE TABLE tabla_espejo_bicicleta (
    id_bicicleta INT NOT NULL,
    marca_comercial VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    anio_fabricacion SMALLINT NOT NULL,
    tamano_marco VARCHAR(20) NOT NULL,
    fecha_inicio_vigencia DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin_vigencia DATETIME NULL,
    id_admin INT NOT NULL,
    
    PRIMARY KEY (id_bicicleta, fecha_inicio_vigencia),
    
    CONSTRAINT chk_fecha_bicicleta CHECK (fecha_fin_vigencia IS NULL OR fecha_fin_vigencia > fecha_inicio_vigencia),
    
    CONSTRAINT fk_espejo_bicicleta_original FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_espejo_bicicleta_admin FOREIGN KEY (id_admin) 
        REFERENCES administrador(id_admin) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE tabla_espejo_uso_acumulado (
    id_bicicleta INT NOT NULL,
    km_total DECIMAL(10,2) NOT NULL,
    horas_total DECIMAL(10,2) NOT NULL,
    km_parcial DECIMAL(10,2) NOT NULL,
    horas_parcial DECIMAL(10,2) NOT NULL,
    fecha_ultimo_mantenimiento DATETIME NULL,
    fecha_inicio_vigencia DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_fin_vigencia DATETIME NULL,
    id_admin INT NOT NULL,
    
    PRIMARY KEY (id_bicicleta, fecha_inicio_vigencia),
    
    CONSTRAINT chk_fecha_uso CHECK (fecha_fin_vigencia IS NULL OR fecha_fin_vigencia > fecha_inicio_vigencia),
    
    -- CORREGIDA: ON DELETE NO ACTION (estaba CASCADE)
    CONSTRAINT fk_espejo_uso_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_espejo_uso_admin FOREIGN KEY (id_admin) 
        REFERENCES administrador(id_admin) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Tabla Espejo: tabla_espejo_cobertura_seguro
CREATE TABLE tabla_espejo_cobertura_seguro (
    id_cobertura INT NOT NULL,
    id_bicicleta INT NOT NULL,
    id_tipo_cobertura INT NOT NULL,
    monto_maximo DECIMAL(12,2) NULL,
    fecha_inicio_vigencia DATE NOT NULL,
    fecha_fin_vigencia DATE NULL,
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',
    id_admin INT NOT NULL,
    
    PRIMARY KEY (id_cobertura),
    
    CONSTRAINT chk_estado_cobertura CHECK (
        estado IN ('activo', 'vencido', 'cancelado', 'suspendido', 'en trámite')
    ),
    CONSTRAINT chk_fecha_cobertura CHECK (fecha_fin_vigencia IS NULL OR fecha_fin_vigencia >= fecha_inicio_vigencia),
    
    CONSTRAINT fk_espejo_cobertura_original FOREIGN KEY (id_cobertura) 
        REFERENCES cobertura_seguro(id_cobertura) ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_espejo_cobertura_bicicleta FOREIGN KEY (id_bicicleta) 
        REFERENCES bicicleta(id_bicicleta) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_espejo_cobertura_tipo FOREIGN KEY (id_tipo_cobertura) 
        REFERENCES tipo_cobertura(id_tipo_cobertura) ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_espejo_cobertura_admin FOREIGN KEY (id_admin) 
        REFERENCES administrador(id_admin) ON DELETE NO ACTION ON UPDATE NO ACTION
);


-- ============================================================
-- VALIDACIÓN POST-CREACIÓN
-- ============================================================

-- Verificar que todas las tablas se crearon
SELECT 'Tablas creadas exitosamente' AS Estado;
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' ORDER BY TABLE_NAME;

-- ============================================================
-- FIN DEL SCRIPT: CREACIÓN DE TABLAS - SQL SERVER COMPATIBLE
-- Estado: LISTO PARA EJECUCIÓN
-- Próximo Script: 03_indexes.sql (índices de performance)
-- ============================================================