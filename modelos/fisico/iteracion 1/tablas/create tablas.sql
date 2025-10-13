-- ============================================
-- Script: 01_create_tables.sql
-- Versión: 1.0
-- Fecha: 2025-10-12
-- Autor: [Rafael Camargo]
-- Descripción: Creación de tablas principales del sistema de bicicletas
-- Base de Datos: PostgreSQL
-- ============================================

-- ============================================
-- TABLA: administrador
-- Descripción: Gestiona los administradores del sistema
-- ============================================
CREATE TABLE IF NOT EXISTS administrador (
    id_admin SERIAL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE
);

COMMENT ON TABLE administrador IS 'Almacena información de los administradores del sistema';
COMMENT ON COLUMN administrador.email IS 'Email único del administrador para acceso al sistema';

-- ============================================
-- TABLA: tipo_uso
-- Descripción: Catálogo de tipos de uso de bicicletas
-- ============================================
CREATE TABLE IF NOT EXISTS tipo_uso (
    id_tipo_uso SERIAL,
    nombre_tipo_uso VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200)
);

COMMENT ON TABLE tipo_uso IS 'Catálogo de tipos de uso: urbano, montaña, carretera, etc.';

-- ============================================
-- TABLA: tipo_asistencia
-- Descripción: Catálogo de tipos de asistencia eléctrica
-- ============================================
CREATE TABLE IF NOT EXISTS tipo_asistencia (
    id_tipo_asistencia SERIAL,
    nombre_tipo_asistencia VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200)
);

COMMENT ON TABLE tipo_asistencia IS 'Catálogo de tipos de asistencia: eléctrica, manual, híbrida';

-- ============================================
-- TABLA: bicicleta
-- Descripción: Entidad principal que registra las bicicletas del sistema
-- ============================================
CREATE TABLE IF NOT EXISTS bicicleta (
    id_bicicleta SERIAL,
    id_admin INTEGER NOT NULL,
    marca_comercial VARCHAR(100) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    anio_fabricacion INTEGER NOT NULL,
    tamano_marco VARCHAR(20) NOT NULL,
    id_tipo_uso INTEGER NOT NULL,
    id_tipo_asistencia INTEGER NOT NULL,
    fecha_registro DATE NOT NULL DEFAULT CURRENT_DATE
);

COMMENT ON TABLE bicicleta IS 'Registro principal de bicicletas del sistema';
COMMENT ON COLUMN bicicleta.tamano_marco IS 'Tamaño del marco: XS, S, M, L, XL';
COMMENT ON COLUMN bicicleta.anio_fabricacion IS 'Año de fabricación de la bicicleta';

-- ============================================
-- TABLA: estado_operativo
-- Descripción: Registra el estado operativo histórico de cada bicicleta
-- ============================================
CREATE TABLE IF NOT EXISTS estado_operativo (
    id_estado_operativo SERIAL,
    id_bicicleta INTEGER NOT NULL,
    estado VARCHAR(30) NOT NULL,
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    hora TIME NOT NULL DEFAULT CURRENT_TIME
);

COMMENT ON TABLE estado_operativo IS 'Historial de estados operativos: disponible, en uso, mantenimiento, dañada';
COMMENT ON COLUMN estado_operativo.estado IS 'Estado actual: disponible, en_uso, mantenimiento, dañada, fuera_servicio';

-- ============================================
-- TABLA: estado_fisico
-- Descripción: Registra el estado físico histórico de cada bicicleta
-- ============================================
CREATE TABLE IF NOT EXISTS estado_fisico (
    id_estado_fisico SERIAL,
    id_bicicleta INTEGER NOT NULL,
    condicion VARCHAR(50) NOT NULL,
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    hora TIME NOT NULL DEFAULT CURRENT_TIME
);

COMMENT ON TABLE estado_fisico IS 'Historial de condiciones físicas de la bicicleta';
COMMENT ON COLUMN estado_fisico.condicion IS 'Condición física: excelente, buena, regular, mala, requiere_revision';

-- ============================================
-- FIN DEL SCRIPT
-- ============================================