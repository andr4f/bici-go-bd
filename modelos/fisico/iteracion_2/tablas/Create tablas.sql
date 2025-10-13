-- ============================================
-- Script: 01_create_tables_sqlserver.sql
-- Fecha: 2025-10-13
-- Descripción: Creación de tablas (SQL Server)
-- ============================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- ==========================
-- CATÁLOGOS GEOGRÁFICOS
-- ==========================
IF OBJECT_ID('dbo.pais','U') IS NULL
CREATE TABLE dbo.pais (
    id_pais INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    moneda_oficial CHAR(3) NOT NULL
);
GO

IF OBJECT_ID('dbo.ciudad','U') IS NULL
CREATE TABLE dbo.ciudad (
    id_ciudad INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    latitud DECIMAL(9,6) NOT NULL,
    longitud DECIMAL(9,6) NOT NULL,
    id_pais INT NOT NULL
);
GO

IF OBJECT_ID('dbo.punto_alquiler','U') IS NULL
CREATE TABLE dbo.punto_alquiler (
    id_punto_alquiler INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    horario VARCHAR(100) NOT NULL,
    capacidad_maxima INT NOT NULL,
    id_ciudad INT NOT NULL
);
GO

-- ==========================
-- CATÁLOGOS DE NEGOCIO
-- ==========================
IF OBJECT_ID('dbo.tipo_uso','U') IS NULL
CREATE TABLE dbo.tipo_uso (
    id_tipo_uso INT IDENTITY(1,1) NOT NULL,
    nombre_tipo_uso VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NULL
);
GO

IF OBJECT_ID('dbo.tipo_asistencia','U') IS NULL
CREATE TABLE dbo.tipo_asistencia (
    id_tipo_asistencia INT IDENTITY(1,1) NOT NULL,
    nombre_tipo_asistencia VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NULL
);
GO

IF OBJECT_ID('dbo.[plan]','U') IS NULL
CREATE TABLE dbo.[plan] (
    id_plan INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NULL
);
GO

IF OBJECT_ID('dbo.etiqueta','U') IS NULL
CREATE TABLE dbo.etiqueta (
    id_etiqueta INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(50) NOT NULL,
    tipo_de_etiqueta VARCHAR(50) NOT NULL,
    descripcion VARCHAR(255) NULL
);
GO

-- ==========================
-- ADMINISTRADOR Y BICICLETA
-- ==========================
IF OBJECT_ID('dbo.administrador','U') IS NULL
CREATE TABLE dbo.administrador (
    id_admin INT IDENTITY(1,1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    fecha_registro DATETIME NOT NULL DEFAULT (GETDATE())
);
GO

IF OBJECT_ID('dbo.bicicleta','U') IS NULL
CREATE TABLE dbo.bicicleta (
    id_bicicleta INT IDENTITY(1,1) NOT NULL,
    codigo_unico VARCHAR(50) NOT NULL,
    marca_comercial VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    anio_fabricacion SMALLINT NOT NULL,
    tamano_marco VARCHAR(20) NOT NULL,
    fecha_registro DATE NOT NULL DEFAULT (CAST(GETDATE() AS DATE)),
    id_admin INT NOT NULL
);
GO

-- ==========================
-- CLASIFICACIONES
-- ==========================
IF OBJECT_ID('dbo.clasificacion_uso_actual','U') IS NULL
CREATE TABLE dbo.clasificacion_uso_actual (
    id_bicicleta INT NOT NULL,
    id_tipo_uso INT NOT NULL,
    actualizado_en DATETIME NOT NULL DEFAULT (GETDATE())
);
GO

IF OBJECT_ID('dbo.clasificacion_uso_hist','U') IS NULL
CREATE TABLE dbo.clasificacion_uso_hist (
    id_hist INT IDENTITY(1,1) NOT NULL,
    id_bicicleta INT NOT NULL,
    id_tipo_uso INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NULL,
    usuario VARCHAR(100) NULL
);
GO

IF OBJECT_ID('dbo.clasificacion_asistencia_actual','U') IS NULL
CREATE TABLE dbo.clasificacion_asistencia_actual (
    id_bicicleta INT NOT NULL,
    id_tipo_asistencia INT NOT NULL,
    actualizado_en DATETIME NOT NULL DEFAULT (GETDATE())
);
GO

IF OBJECT_ID('dbo.clasificacion_asistencia_hist','U') IS NULL
CREATE TABLE dbo.clasificacion_asistencia_hist (
    id_hist INT IDENTITY(1,1) NOT NULL,
    id_bicicleta INT NOT NULL,
    id_tipo_asistencia INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NULL,
    usuario VARCHAR(100) NULL
);
GO

-- ==========================
-- ESTADOS
-- ==========================
IF OBJECT_ID('dbo.estado_operativo_actual','U') IS NULL
CREATE TABLE dbo.estado_operativo_actual (
    id_bicicleta INT NOT NULL,
    estado VARCHAR(20) NOT NULL,
    desde DATETIME NOT NULL DEFAULT (GETDATE())
);
GO

IF OBJECT_ID('dbo.estado_operativo_hist','U') IS NULL
CREATE TABLE dbo.estado_operativo_hist (
    id_hist INT IDENTITY(1,1) NOT NULL,
    id_bicicleta INT NOT NULL,
    estado VARCHAR(20) NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NULL,
    usuario VARCHAR(100) NULL
);
GO

IF OBJECT_ID('dbo.estado_fisico_actual','U') IS NULL
CREATE TABLE dbo.estado_fisico_actual (
    id_bicicleta INT NOT NULL,
    condicion VARCHAR(20) NOT NULL,
    desde DATETIME NOT NULL DEFAULT (GETDATE())
);
GO

IF OBJECT_ID('dbo.estado_fisico_hist','U') IS NULL
CREATE TABLE dbo.estado_fisico_hist (
    id_hist INT IDENTITY(1,1) NOT NULL,
    id_bicicleta INT NOT NULL,
    condicion VARCHAR(20) NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NULL,
    usuario VARCHAR(100) NULL
);
GO

-- ==========================
-- ETIQUETAS EN BICICLETA
-- ==========================
IF OBJECT_ID('dbo.bicicleta_etiqueta_actual','U') IS NULL
CREATE TABLE dbo.bicicleta_etiqueta_actual (
    id_bicicleta INT NOT NULL,
    id_etiqueta INT NOT NULL,
    asignada_en DATETIME NOT NULL DEFAULT (GETDATE())
);
GO

IF OBJECT_ID('dbo.bicicleta_etiqueta_hist','U') IS NULL
CREATE TABLE dbo.bicicleta_etiqueta_hist (
    id_hist INT IDENTITY(1,1) NOT NULL,
    id_bicicleta INT NOT NULL,
    id_etiqueta INT NOT NULL,
    fecha_asignacion DATETIME NOT NULL,
    fecha_eliminacion DATETIME NULL,
    usuario VARCHAR(100) NULL,
    motivo VARCHAR(255) NULL
);
GO

-- ==========================
-- UBICACIÓN
-- ==========================
IF OBJECT_ID('dbo.ubicacion_actual','U') IS NULL
CREATE TABLE dbo.ubicacion_actual (
    id_bicicleta INT NOT NULL,
    id_punto_alquiler INT NOT NULL,
    desde DATETIME NOT NULL DEFAULT (GETDATE())
);
GO

IF OBJECT_ID('dbo.ubicacion_hist','U') IS NULL
CREATE TABLE dbo.ubicacion_hist (
    id_hist INT IDENTITY(1,1) NOT NULL,
    id_bicicleta INT NOT NULL,
    id_punto_alquiler INT NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NULL,
    usuario VARCHAR(100) NULL,
    motivo VARCHAR(255) NULL
);
GO

-- ==========================
-- TARIFAS
-- ==========================
IF OBJECT_ID('dbo.tarifa_actual','U') IS NULL
CREATE TABLE dbo.tarifa_actual (
    id_bicicleta INT NOT NULL,
    id_plan INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    moneda CHAR(3) NOT NULL
);
GO

IF OBJECT_ID('dbo.tarifa_hist','U') IS NULL
CREATE TABLE dbo.tarifa_hist (
    id_hist INT IDENTITY(1,1) NOT NULL,
    id_bicicleta INT NOT NULL,
    id_plan INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    moneda CHAR(3) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NULL,
    usuario VARCHAR(100) NULL,
    motivo VARCHAR(255) NULL
);
GO
