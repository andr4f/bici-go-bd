sql-- ============================================
-- Script: 99_drop_all.sql
-- Versión: 1.0
-- Fecha: 2025-10-12
-- Autor: [Rafael Camargo]
-- Descripción: Elimina todas las tablas en orden correcto (rollback)
-- ADVERTENCIA: Este script elimina TODOS los datos
-- ============================================

-- Desactivar temporalmente las verificaciones de FK (solo para limpieza)
SET session_replication_role = 'replica';

-- Eliminar tablas en orden inverso de dependencias
DROP TABLE IF EXISTS estado_fisico CASCADE;
DROP TABLE IF EXISTS estado_operativo CASCADE;
DROP TABLE IF EXISTS bicicleta CASCADE;
DROP TABLE IF EXISTS tipo_asistencia CASCADE;
DROP TABLE IF EXISTS tipo_uso CASCADE;
DROP TABLE IF EXISTS administrador CASCADE;

-- Reactivar verificaciones de FK
SET session_replication_role = 'origin';

-- ============================================
-- FIN DEL SCRIPT
-- ============================================