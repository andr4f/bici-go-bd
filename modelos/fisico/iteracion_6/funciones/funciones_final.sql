-- ============================================================================
-- PARTE 2: FUNCIONES ESENCIALES (12 FUNCIONES)
-- ============================================================================

-- FUNCIÓN 1: Calcular edad en años
CREATE OR ALTER FUNCTION FN_Edad_Bicicleta (@id_bicicleta INT)
RETURNS INT
AS
BEGIN
    DECLARE @edad INT;
    SELECT @edad = YEAR(GETDATE()) - anio_fabricacion FROM bicicleta WHERE id_bicicleta = @id_bicicleta;
    RETURN ISNULL(@edad, 0);
END;
GO

-- FUNCIÓN 2: Validar código único de bicicleta
CREATE OR ALTER FUNCTION FN_Validar_Codigo_Bicicleta (@codigo VARCHAR(50))
RETURNS BIT
AS
BEGIN
    IF @codigo LIKE '[A-Z][A-Z]E[0-9][0-9][0-9][0-9][A-Z][A-Z]C'
        RETURN 1;
    RETURN 0;
END;
GO

-- FUNCIÓN 3: Calcular costo total con descuento e IVA
CREATE OR ALTER FUNCTION FN_Calcular_Total_Reserva (
    @subtotal DECIMAL(10,2),
    @descuento DECIMAL(10,2) = 0,
    @porcentaje_iva DECIMAL(5,2) = 19
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @base DECIMAL(10,2) = @subtotal - @descuento;
    DECLARE @iva DECIMAL(10,2) = @base * (@porcentaje_iva / 100.0);
    RETURN @base + @iva;
END;
GO

-- FUNCIÓN 4: Obtener estado operativo de bicicleta
CREATE OR ALTER FUNCTION FN_Estado_Actual_Bicicleta (@id_bicicleta INT)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @estado VARCHAR(50);
    SELECT @estado = eo.nombre_estado
    FROM bicicleta b
    JOIN estado_operativo eo ON b.id_estado_operativo = eo.id_estado_operativo
    WHERE b.id_bicicleta = @id_bicicleta;
    RETURN ISNULL(@estado, 'Desconocido');
END;
GO

-- FUNCIÓN 5: Verificar si bicicleta está disponible
CREATE OR ALTER FUNCTION FN_Bicicleta_Disponible (@id_bicicleta INT)
RETURNS BIT
AS
BEGIN
    DECLARE @disponible BIT;
    SELECT @disponible = CASE
        WHEN eo.nombre_estado = 'disponible' THEN 1
        ELSE 0
    END
    FROM bicicleta b
    JOIN estado_operativo eo ON b.id_estado_operativo = eo.id_estado_operativo
    WHERE b.id_bicicleta = @id_bicicleta;
    RETURN ISNULL(@disponible, 0);
END;
GO

-- FUNCIÓN 6: Calcular porcentaje de mantenimiento (km/horas)
CREATE OR ALTER FUNCTION FN_Porcentaje_Mantenimiento (@id_bicicleta INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @porcentaje DECIMAL(5,2);
   
    SELECT @porcentaje = CAST(
        CASE
            WHEN pm.km_umbral > 0 AND ua.km_parcial > 0
            THEN (ua.km_parcial * 100.0 / pm.km_umbral)
            WHEN pm.horas_umbral > 0 AND ua.horas_parcial > 0
            THEN (ua.horas_parcial * 100.0 / pm.horas_umbral)
            ELSE 0
        END AS DECIMAL(5,2))
    FROM bicicleta b
    JOIN uso_acumulado ua ON b.id_bicicleta = ua.id_bicicleta
    JOIN parametro_mantenimiento pm ON b.id_parametro = pm.id_parametro
    WHERE b.id_bicicleta = @id_bicicleta;
   
    RETURN ISNULL(@porcentaje, 0);
END;
GO

-- FUNCIÓN 7: Validar calificación (1-5)
CREATE OR ALTER FUNCTION FN_Validar_Calificacion (@calificacion INT)
RETURNS BIT
AS
BEGIN
    IF @calificacion >= 1 AND @calificacion <= 5
        RETURN 1;
    RETURN 0;
END;
GO

-- FUNCIÓN 8: Nombre completo de persona
CREATE OR ALTER FUNCTION FN_Nombre_Completo (@id_persona INT)
RETURNS VARCHAR(200)
AS
BEGIN
    DECLARE @nombre_completo VARCHAR(200);
    SELECT @nombre_completo = CONCAT(nombre, ' ', apellido)
    FROM persona WHERE id_persona = @id_persona;
    RETURN ISNULL(@nombre_completo, 'Desconocido');
END;
GO

-- FUNCIÓN 9: Obtener tarifa vigente para plan
CREATE OR ALTER FUNCTION FN_Tarifa_Vigente (
    @id_plan INT,
    @id_pais INT,
    @id_tipo_uso INT,
    @id_tipo_asistencia INT,
    @fecha DATE
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @tarifa DECIMAL(10,2);
   
    SELECT @tarifa = tarifa_final
    FROM tarifa
    WHERE id_plan = @id_plan
    AND id_pais = @id_pais
    AND id_tipo_uso = @id_tipo_uso
    AND id_tipo_asistencia = @id_tipo_asistencia
    AND fecha_inicio <= @fecha
    AND (fecha_fin IS NULL OR fecha_fin >= @fecha);
   
    RETURN ISNULL(@tarifa, 0);
END;
GO

-- FUNCIÓN 10: Calcular horas entre dos fechas
CREATE OR ALTER FUNCTION FN_Horas_Entre_Fechas (
    @fecha_inicio DATETIME,
    @fecha_fin DATETIME
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN CAST(DATEDIFF(MINUTE, @fecha_inicio, @fecha_fin) AS DECIMAL(10,2)) / 60.0;
END;
GO

-- FUNCIÓN 11: Obtener tipo_persona
CREATE OR ALTER FUNCTION FN_Tipo_Persona (@id_persona INT)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @tipo VARCHAR(50);
    SELECT @tipo = tipo_persona FROM persona WHERE id_persona = @id_persona;
    RETURN ISNULL(@tipo, 'Desconocido');
END;
GO

-- FUNCIÓN 12: Validar descuento (verificar vigencia)
CREATE OR ALTER FUNCTION FN_Descuento_Vigente (@id_descuento INT)
RETURNS BIT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM descuento
        WHERE id_descuento = @id_descuento
        AND estado = 'activo'
        AND fecha_inicio_vigencia <= CAST(GETDATE() AS DATE)
        AND (fecha_fin_vigencia IS NULL OR fecha_fin_vigencia >= CAST(GETDATE() AS DATE))
    )
        RETURN 1;
    RETURN 0;
END;
GO
