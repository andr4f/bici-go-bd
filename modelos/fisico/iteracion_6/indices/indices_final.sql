-- =====================================================
-- 🔴 ÍNDICES CRÍTICOS - PRIORIDAD MÁXIMA
-- =====================================================

-- ============ TABLA: persona ============
-- Búsquedas frecuentes por email y documento
CREATE NONCLUSTERED INDEX IX_persona_email 
ON persona(email)
INCLUDE (nombre, apellido, telefono, estado);

CREATE NONCLUSTERED INDEX IX_persona_documento 
ON persona(documento_numero, documento_tipo)
INCLUDE (nombre, apellido, email);

CREATE NONCLUSTERED INDEX IX_persona_usuario 
ON persona(usuario)
INCLUDE (nombre, apellido, email);

-- Filtrado por tipo y estado
CREATE NONCLUSTERED INDEX IX_persona_tipo_estado 
ON persona(tipo_persona, estado)
INCLUDE (nombre, apellido, email);

-- Foreign keys
CREATE NONCLUSTERED INDEX IX_persona_idioma 
ON persona(id_idioma);

CREATE NONCLUSTERED INDEX IX_persona_terminos 
ON persona(id_terminos_condiciones);


-- ============ TABLA: bicicleta ============
-- Búsqueda por código único (muy frecuente)
CREATE UNIQUE NONCLUSTERED INDEX IX_bicicleta_codigo_unico 
ON bicicleta(codigo_unico)
INCLUDE (marca_comercial, modelo, id_estado_operativo, id_punto_alquiler);

-- Consultas de disponibilidad (CRÍTICO para reservas)
CREATE NONCLUSTERED INDEX IX_bicicleta_estado_operativo 
ON bicicleta(id_estado_operativo, id_punto_alquiler)
INCLUDE (id_tipo_uso, id_tipo_asistencia, codigo_unico, marca_comercial);

-- Filtrado por punto de alquiler
CREATE NONCLUSTERED INDEX IX_bicicleta_punto 
ON bicicleta(id_punto_alquiler, id_estado_operativo)
INCLUDE (id_tipo_uso, id_tipo_asistencia);

-- Filtrado por tipo (búsqueda de clientes)
CREATE NONCLUSTERED INDEX IX_bicicleta_tipo_uso_asistencia 
ON bicicleta(id_tipo_uso, id_tipo_asistencia, id_estado_operativo)
INCLUDE (id_punto_alquiler, codigo_unico);

-- Estado físico para mantenimiento
CREATE NONCLUSTERED INDEX IX_bicicleta_estado_fisico 
ON bicicleta(id_estado_fisico)
INCLUDE (codigo_unico, id_punto_alquiler);


-- ============ TABLA: reserva ============
-- Consultas por cliente (historial)
CREATE NONCLUSTERED INDEX IX_reserva_cliente 
ON reserva(id_cliente, fecha_reserva DESC)
INCLUDE (estado, total_general, fecha_inicio, fecha_fin);

-- Búsqueda por fechas (reservas activas)
-- ❗QUITAMOS EL WHERE para evitar problemas con IN/OR en índice filtrado
CREATE NONCLUSTERED INDEX IX_reserva_fechas 
ON reserva(fecha_inicio, fecha_fin)
INCLUDE (id_cliente, estado, total_general);

-- Filtrado por estado
CREATE NONCLUSTERED INDEX IX_reserva_estado 
ON reserva(estado, fecha_reserva DESC)
INCLUDE (id_cliente, total_general);

-- Fecha de reserva (reportes financieros)
CREATE NONCLUSTERED INDEX IX_reserva_fecha_reserva 
ON reserva(fecha_reserva DESC)
INCLUDE (estado, total_general, subtotal_general, iva_total, descuento_total);

-- Reservas con ruta (este WHERE es simple y válido)
CREATE NONCLUSTERED INDEX IX_reserva_ruta 
ON reserva(id_ruta)
INCLUDE (id_cliente, fecha_reserva, total_general)
WHERE id_ruta IS NOT NULL;

-- Reservas con guía (también válido)
CREATE NONCLUSTERED INDEX IX_reserva_guia 
ON reserva(id_guia)
INCLUDE (id_ruta, fecha_reserva, tarifa_guia)
WHERE id_guia IS NOT NULL;

-- Método de pago
CREATE NONCLUSTERED INDEX IX_reserva_metodo_pago 
ON reserva(id_metodo_de_pago)
INCLUDE (total_general, estado);


-- ============ TABLA: detalle_alquiler ============
-- Por reserva (JOIN frecuente)
CREATE NONCLUSTERED INDEX IX_detalle_reserva 
ON detalle_alquiler(id_reserva)
INCLUDE (id_bicicleta, id_plan, tarifa_unitaria, total_item);

-- Por bicicleta (historial de uso)
CREATE NONCLUSTERED INDEX IX_detalle_bicicleta 
ON detalle_alquiler(id_bicicleta, fecha_inicio)
INCLUDE (id_reserva, fecha_fin);

-- Fechas de vigencia
CREATE NONCLUSTERED INDEX IX_detalle_fechas 
ON detalle_alquiler(fecha_inicio, fecha_fin)
INCLUDE (id_bicicleta, id_reserva);


-- ============ TABLA: punto_alquiler ============
-- Por ciudad (búsqueda geográfica)
CREATE NONCLUSTERED INDEX IX_punto_ciudad 
ON punto_alquiler(id_ciudad)
INCLUDE (nombre, direccion, latitud, longitud);

-- Estado operativo (vigencia)
-- ❗QUITAMOS GETDATE() DEL WHERE (no se permiten funciones no deterministas en índices filtrados)
CREATE NONCLUSTERED INDEX IX_punto_vigencia 
ON punto_alquiler(fecha_fin)
INCLUDE (nombre, id_ciudad);
-- Si quieres solo puntos “abiertos”, filtra en el SELECT, no en el índice


-- ============ TABLA: tarifa ============
-- Búsqueda por plan y país (CRÍTICO para cotizaciones)
CREATE NONCLUSTERED INDEX IX_tarifa_plan_pais 
ON tarifa(id_plan, id_pais, id_tipo_uso, id_tipo_asistencia)
INCLUDE (tarifa_base, tarifa_final, fecha_inicio, fecha_fin);

-- Vigencia de tarifas
-- ❗QUITAMOS GETDATE() DEL WHERE
CREATE NONCLUSTERED INDEX IX_tarifa_vigencia 
ON tarifa(fecha_inicio, fecha_fin)
INCLUDE (id_plan, tarifa_final);
-- Si quieres “vigentes a hoy”, filtra en las consultas

-- Por tipo de bicicleta
CREATE NONCLUSTERED INDEX IX_tarifa_tipo 
ON tarifa(id_tipo_uso, id_tipo_asistencia)
INCLUDE (id_plan, id_pais, tarifa_final);


-- =====================================================
-- 🟡 ÍNDICES DE ALTA PRIORIDAD
-- =====================================================

-- ============ TABLA: uso_acumulado ============
-- Para alertas de mantenimiento
CREATE NONCLUSTERED INDEX IX_uso_km_parcial 
ON uso_acumulado(km_parcial DESC)
INCLUDE (id_bicicleta, horas_parcial, fecha_ultimo_mantenimiento);

CREATE NONCLUSTERED INDEX IX_uso_horas_parcial 
ON uso_acumulado(horas_parcial DESC)
INCLUDE (id_bicicleta, km_parcial, fecha_ultimo_mantenimiento);

CREATE NONCLUSTERED INDEX IX_uso_ultimo_mantenimiento 
ON uso_acumulado(fecha_ultimo_mantenimiento)
INCLUDE (id_bicicleta, km_parcial, horas_parcial);


-- ============ TABLA: cobertura_seguro ============
-- Alertas de vencimiento
CREATE NONCLUSTERED INDEX IX_cobertura_vigencia 
ON cobertura_seguro(fecha_fin_vigencia, estado)
INCLUDE (id_bicicleta, id_tipo_cobertura, monto_maximo)
WHERE estado = 'activo';

CREATE NONCLUSTERED INDEX IX_cobertura_bicicleta 
ON cobertura_seguro(id_bicicleta, estado)
INCLUDE (fecha_inicio_vigencia, fecha_fin_vigencia, monto_maximo);


-- ============ TABLA: ruta_turistica ============
-- Búsqueda y ranking
CREATE NONCLUSTERED INDEX IX_ruta_estado 
ON ruta_turistica(estado)
INCLUDE (nombre, calificacion_promedio, total_resenas, nivel_dificultad);

CREATE NONCLUSTERED INDEX IX_ruta_calificacion 
ON ruta_turistica(calificacion_promedio DESC)
INCLUDE (nombre, total_resenas, estado)
WHERE estado = 'activo';

CREATE NONCLUSTERED INDEX IX_ruta_dificultad 
ON ruta_turistica(nivel_dificultad, estado)
INCLUDE (nombre, distancia_total, calificacion_promedio);


-- ============ TABLA: guia_turistico ============
CREATE NONCLUSTERED INDEX IX_guia_estado 
ON guia_turistico(estado)
INCLUDE (numero_licencia, tarifa_base);

CREATE NONCLUSTERED INDEX IX_guia_licencia 
ON guia_turistico(numero_licencia)
INCLUDE (estado, tarifa_base);


-- ============ TABLA: guia_ruta ============
CREATE NONCLUSTERED INDEX IX_guia_ruta_guia 
ON guia_ruta(id_guia, estado)
INCLUDE (id_ruta, veces_realizada);

CREATE NONCLUSTERED INDEX IX_guia_ruta_ruta 
ON guia_ruta(id_ruta, estado)
INCLUDE (id_guia, veces_realizada);


-- ============ TABLA: guia_idioma ============
CREATE NONCLUSTERED INDEX IX_guia_idioma_guia 
ON guia_idioma(id_guia, estado)
INCLUDE (id_idioma);

CREATE NONCLUSTERED INDEX IX_guia_idioma_idioma 
ON guia_idioma(id_idioma, estado)
INCLUDE (id_guia);


-- ============ TABLA: resenia_ruta ============
CREATE NONCLUSTERED INDEX IX_resenia_ruta 
ON resenia_ruta(id_ruta, estado)
INCLUDE (calificacion, fecha_publicacion, id_cliente);

CREATE NONCLUSTERED INDEX IX_resenia_cliente 
ON resenia_ruta(id_cliente)
INCLUDE (id_ruta, calificacion, fecha_publicacion);

CREATE NONCLUSTERED INDEX IX_resenia_reserva 
ON resenia_ruta(id_reserva)
INCLUDE (id_ruta, calificacion);


-- ============ TABLA: capacidad_tipo ============
CREATE NONCLUSTERED INDEX IX_capacidad_tipo_punto 
ON capacidad_tipo(id_punto_alquiler, id_tipo_uso, id_tipo_asistencia)
INCLUDE (capacidad_especifica);


-- ============ TABLA: horario_base / detalle_dia_horario ============
CREATE NONCLUSTERED INDEX IX_detalle_dia_punto 
ON detalle_dia_horario(id_punto_alquiler, dia_semana)
INCLUDE (estado, hora_apertura, hora_cierre);


-- ============ TABLA: excepcion_horario ============
CREATE NONCLUSTERED INDEX IX_excepcion_punto_fecha 
ON excepcion_horario(id_punto_alquiler, fecha_excepcion)
INCLUDE (tipo_excepcion, hora_apertura, hora_cierre);

-- ❗QUITAMOS GETDATE() DEL WHERE (no se permite en índice filtrado)
CREATE NONCLUSTERED INDEX IX_excepcion_fecha 
ON excepcion_horario(fecha_excepcion)
INCLUDE (id_punto_alquiler, tipo_excepcion);
-- Si quieres “desde hoy”, filtra en el SELECT


-- ============ TABLA: descuento ============
CREATE NONCLUSTERED INDEX IX_descuento_vigencia 
ON descuento(fecha_inicio_vigencia, fecha_fin_vigencia, estado)
INCLUDE (nombre, valor, tipo)
WHERE estado = 'activo';


-- ============ TABLA: reserva_descuento ============
CREATE NONCLUSTERED INDEX IX_reserva_descuento_reserva 
ON reserva_descuento(id_reserva)
INCLUDE (id_descuento, monto_descontado);

CREATE NONCLUSTERED INDEX IX_reserva_descuento_descuento 
ON reserva_descuento(id_descuento)
INCLUDE (id_reserva, monto_descontado);


-- =====================================================
-- 🟢 ÍNDICES DE PRIORIDAD MEDIA
-- =====================================================

-- ============ TABLA: fotografia ============
CREATE NONCLUSTERED INDEX IX_fotografia_tipo 
ON fotografia(tipo_fotografia, estado)
INCLUDE (ruta_archivo, es_principal, orden);

CREATE NONCLUSTERED INDEX IX_fotografia_estado 
ON fotografia(estado, fecha_hora_carga DESC)
INCLUDE (tipo_fotografia, ruta_archivo);


-- ============ TABLA: fotografia_bicicleta ============
CREATE NONCLUSTERED INDEX IX_foto_bici_bicicleta 
ON fotografia_bicicleta(id_bicicleta)
INCLUDE (tipo_vista);


-- ============ TABLA: fotografia_punto ============
CREATE NONCLUSTERED INDEX IX_foto_punto_punto 
ON fotografia_punto(id_punto_alquiler)
INCLUDE (tipo_vista);


-- ============ TABLA: foto_ruta ============
CREATE NONCLUSTERED INDEX IX_foto_ruta_ruta 
ON foto_ruta(id_ruta)
INCLUDE (tipo_foto, temporada);


-- ============ TABLA: foto_resenia ============
CREATE NONCLUSTERED INDEX IX_foto_resenia_resenia 
ON foto_resenia(id_resenia_ruta)
INCLUDE (orden);


-- ============ TABLA: bicicleta_etiqueta ============
CREATE NONCLUSTERED INDEX IX_bici_etiqueta_bicicleta 
ON bicicleta_etiqueta(id_bicicleta, fecha_eliminacion)
INCLUDE (id_etiqueta)
WHERE fecha_eliminacion IS NULL;

-- ============ TABLA: etiqueta ============
CREATE NONCLUSTERED INDEX IX_etiqueta_tipo 
ON etiqueta(tipo_de_etiqueta)
INCLUDE (nombre);


-- ============ TABLA: condiciones_especiales ============
CREATE NONCLUSTERED INDEX IX_condiciones_bicicleta 
ON condiciones_especiales(id_bicicleta, fecha_fin)
INCLUDE (tipo_condicion, valor_minimo, valor_maximo)
WHERE fecha_fin IS NULL;

CREATE NONCLUSTERED INDEX IX_condiciones_tipo 
ON condiciones_especiales(tipo_condicion)
INCLUDE (id_bicicleta)
WHERE fecha_fin IS NULL;

-- ============ TABLA: punto_servicio ============
CREATE NONCLUSTERED INDEX IX_punto_servicio_punto 
ON punto_servicio(id_punto_alquiler, estado)
INCLUDE (id_servicio);

CREATE NONCLUSTERED INDEX IX_punto_servicio_servicio 
ON punto_servicio(id_servicio, estado)
INCLUDE (id_punto_alquiler);


-- ============ TABLA: servicio ============
CREATE NONCLUSTERED INDEX IX_servicio_obligatorio 
ON servicio(es_obligatorio)
INCLUDE (nombre);


-- ============ TABLAS GEOGRÁFICAS ============
CREATE NONCLUSTERED INDEX IX_ciudad_departamento 
ON ciudad(id_departamento)
INCLUDE (nombre, latitud, longitud);

CREATE NONCLUSTERED INDEX IX_departamento_pais 
ON departamento(id_pais)
INCLUDE (nombre);


-- ============ TABLA: plan ============
CREATE NONCLUSTERED INDEX IX_plan_estado 
ON [plan](estado, tipo_duracion)
INCLUDE (nombre);


-- ============ TABLA: terminos_condiciones ============
CREATE NONCLUSTERED INDEX IX_terminos_actual 
ON terminos_condiciones(es_version_actual)
INCLUDE (titulo, version, fecha_inicio_vigencia)
WHERE es_version_actual = 1;


-- =====================================================
-- 🔵 ÍNDICES PARA TABLAS HISTORIAL (System Versioning)
-- =====================================================

-- ============ bicicleta_historial ============
CREATE NONCLUSTERED INDEX IX_hist_bicicleta_id 
ON bicicleta_historial(id_bicicleta, ValidFrom, ValidTo)
INCLUDE (id_estado_operativo, id_estado_fisico, id_punto_alquiler);

CREATE NONCLUSTERED INDEX IX_hist_bicicleta_validfrom 
ON bicicleta_historial(ValidFrom, ValidTo)
INCLUDE (id_bicicleta);


-- ============ reserva_historial ============
CREATE NONCLUSTERED INDEX IX_hist_reserva_id 
ON reserva_historial(id_reserva, ValidFrom, ValidTo)
INCLUDE (estado, total_general, id_cliente);

CREATE NONCLUSTERED INDEX IX_hist_reserva_validfrom 
ON reserva_historial(ValidFrom, ValidTo)
INCLUDE (id_reserva, estado);


-- ============ tarifa_historial ============
CREATE NONCLUSTERED INDEX IX_hist_tarifa_id 
ON tarifa_historial(id_tarifa, ValidFrom, ValidTo)
INCLUDE (tarifa_base, tarifa_final);

CREATE NONCLUSTERED INDEX IX_hist_tarifa_validfrom 
ON tarifa_historial(ValidFrom, ValidTo)
INCLUDE (id_tarifa);


-- ============ uso_acumulado_historial ============
CREATE NONCLUSTERED INDEX IX_hist_uso_id 
ON uso_acumulado_historial(id_bicicleta, ValidFrom, ValidTo)
INCLUDE (km_total, horas_total, km_parcial, horas_parcial);
