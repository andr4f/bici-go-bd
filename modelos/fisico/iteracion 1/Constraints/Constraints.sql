-- ============================================
-- Script: 02_create_constraints.sql
-- Versión: 1.0
-- Fecha: 2025-10-12
-- Autor: [Rafael Camargo]
-- Descripción: Definición de llaves primarias, foráneas y restricciones
-- ============================================

-- ============================================
-- LLAVES PRIMARIAS (PRIMARY KEY)
-- ============================================

ALTER TABLE administrador 
    ADD CONSTRAINT pk_administrador PRIMARY KEY (id_admin);

ALTER TABLE tipo_uso 
    ADD CONSTRAINT pk_tipo_uso PRIMARY KEY (id_tipo_uso);

ALTER TABLE tipo_asistencia 
    ADD CONSTRAINT pk_tipo_asistencia PRIMARY KEY (id_tipo_asistencia);

ALTER TABLE bicicleta 
    ADD CONSTRAINT pk_bicicleta PRIMARY KEY (id_bicicleta);

ALTER TABLE estado_operativo 
    ADD CONSTRAINT pk_estado_operativo PRIMARY KEY (id_estado_operativo);

ALTER TABLE estado_fisico 
    ADD CONSTRAINT pk_estado_fisico PRIMARY KEY (id_estado_fisico);

-- ============================================
-- LLAVES FORÁNEAS (FOREIGN KEY)
-- ============================================

-- Bicicleta -> Administrador
ALTER TABLE bicicleta
    ADD CONSTRAINT fk_bicicleta_administrador 
    FOREIGN KEY (id_admin) 
    REFERENCES administrador(id_admin)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Bicicleta -> Tipo de Uso
ALTER TABLE bicicleta
    ADD CONSTRAINT fk_bicicleta_tipo_uso 
    FOREIGN KEY (id_tipo_uso) 
    REFERENCES tipo_uso(id_tipo_uso)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Bicicleta -> Tipo de Asistencia
ALTER TABLE bicicleta
    ADD CONSTRAINT fk_bicicleta_tipo_asistencia 
    FOREIGN KEY (id_tipo_asistencia) 
    REFERENCES tipo_asistencia(id_tipo_asistencia)
    ON DELETE RESTRICT
    ON UPDATE CASCADE;

-- Estado Operativo -> Bicicleta
ALTER TABLE estado_operativo
    ADD CONSTRAINT fk_estado_operativo_bicicleta 
    FOREIGN KEY (id_bicicleta) 
    REFERENCES bicicleta(id_bicicleta)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

-- Estado Físico -> Bicicleta
ALTER TABLE estado_fisico
    ADD CONSTRAINT fk_estado_fisico_bicicleta 
    FOREIGN KEY (id_bicicleta) 
    REFERENCES bicicleta(id_bicicleta)
    ON DELETE CASCADE
    ON UPDATE CASCADE;

-- ============================================
-- RESTRICCIONES DE UNICIDAD (UNIQUE)
-- ============================================

ALTER TABLE administrador
    ADD CONSTRAINT uk_administrador_email UNIQUE (email);

ALTER TABLE tipo_uso
    ADD CONSTRAINT uk_tipo_uso_nombre UNIQUE (nombre_tipo_uso);

ALTER TABLE tipo_asistencia
    ADD CONSTRAINT uk_tipo_asistencia_nombre UNIQUE (nombre_tipo_asistencia);

-- ============================================
-- RESTRICCIONES SEMÁNTICAS (CHECK)
-- ============================================

-- Administrador: validar formato de email
ALTER TABLE administrador
    ADD CONSTRAINT chk_administrador_email 
    CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$');

-- Bicicleta: año de fabricación válido
ALTER TABLE bicicleta
    ADD CONSTRAINT chk_bicicleta_anio 
    CHECK (anio_fabricacion >= 1990 AND anio_fabricacion <= EXTRACT(YEAR FROM CURRENT_DATE));

-- Bicicleta: tamaño de marco válido
ALTER TABLE bicicleta
    ADD CONSTRAINT chk_bicicleta_tamano_marco 
    CHECK (tamano_marco IN ('XS', 'S', 'M', 'L', 'XL', 'XXL'));

-- Estado Operativo: estados válidos
ALTER TABLE estado_operativo
    ADD CONSTRAINT chk_estado_operativo_estado 
    CHECK (estado IN ('disponible', 'en_uso', 'mantenimiento', 'dañada', 'fuera_servicio'));

-- Estado Físico: condiciones válidas
ALTER TABLE estado_fisico
    ADD CONSTRAINT chk_estado_fisico_condicion 
    CHECK (condicion IN ('excelente', 'buena', 'regular', 'mala', 'requiere_revision'));

-- ============================================
-- FIN DEL SCRIPT
-- ============================================