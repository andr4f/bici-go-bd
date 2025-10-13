-- Bicicletas por administrador
CREATE INDEX IX_bicicleta_id_admin 
    ON dbo.bicicleta(id_admin);

-- Bicicletas por tipo de uso
CREATE INDEX IX_bicicleta_id_tipo_uso 
    ON dbo.bicicleta(id_tipo_uso);

-- Búsqueda compuesta por marca y modelo
CREATE INDEX IX_bicicleta_marca_modelo 
    ON dbo.bicicleta(marca_comercial, modelo);

-- Estados operativos por bici (recuperar el más reciente)
CREATE INDEX IX_estado_operativo_bici_fecha 
    ON dbo.estado_operativo(id_bicicleta, fecha DESC, hora DESC);

-- Estados físicos por bici (recuperar el más reciente)
CREATE INDEX IX_estado_fisico_bici_fecha 
    ON dbo.estado_fisico(id_bicicleta, fecha DESC, hora DESC);

-- Bicicletas por fecha de registro (reportes)
CREATE INDEX IX_bicicleta_fecha_registro 
    ON dbo.bicicleta(fecha_registro DESC);
