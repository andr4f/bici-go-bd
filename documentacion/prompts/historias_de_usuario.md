Actua como un Especificador de Requisitos de Almacenamiento de Datos cuyo propósito es desglosar una Historia de Usuario (HU) excesivamente general en un conjunto de sub-historias de usuario atómicas y enfocadas, que sirvan para especificar de manera precisa los requisitos de almacenamiento.
### Tarea de Entrada
A continuación, se presenta la Historia de Usuario general que requiere ser descompuesta:
Historia de Usuario General (INGRESAR AQUÍ LA HU GENERAL):
istoria de usuario 1
Título
Como administrador del portal BICI-GO, quiero almacenar los datos de una bicicleta para 
que esté disponible para alquiler.
Descripción
El administrador debe estar en capacidad de añadir nuevas bicicletas al inventario del 
portal. Se deben incluir todos los detalles clave de la bicicleta, como su tipo, estado de 
mantenimiento, accesorios, y la tarifa base de alquiler, para que los usuarios puedan 
encontrar la opción que mejor se adapte a su recorrido.
Criterios de aceptación
1. Cada bicicleta debe tener un identificador único que la distinga en el inventario.
2. Debe clasificarse por su tipo de uso o terreno (montaña, urbana, de ruta) y por su tipo de 
asistencia (convencional o eléctrica) para facilitar la búsqueda a los usuarios.
3. Debe ser posible ingresar datos específicos como la marca, el modelo, el año de 
fabricación y el tamaño del marco.
4. Se debe poder asignar un conjunto de etiquetas adicionales que describan aspectos o 
accesorios específicos de la bicicleta (ej. "incluye casco", "con candado", "apta para 
terrenos irregulares").
5. El estado de mantenimiento de la bicicleta debe ser registrable (ej. "excelente", "bueno", 
"requiere servicio"), permitiendo un seguimiento para garantizar la seguridad.
6. Debe poderse asociar cada bicicleta a un punto de alquiler específico, indicando su 
ubicación física.
7. El sistema debe permitir registrar la disponibilidad de la bicicleta en tiempo real (ej. 
"disponible", "en alquiler", "en mantenimiento").
8. Debe ser posible asignar una tarifa base de alquiler que pueda variar según el plan (por 
hora, por día, semanal, etc.).
9. Se debe poder subir una o varias fotos de alta calidad de la bicicleta para que los 
usuarios puedan ver su aspecto real.
10. El registro debe incluir un campo para las condiciones especiales de uso de la bicicleta, 
si las hay (ej. "solo para terrenos planos", "peso máximo permitido").
11. Debe ser llevar registro del kilometraje y de las horas de uso para el seguimiento del 
mantenimiento preventivo.
12. Debe permitir la asociación de la bicicleta con un seguro o plan de protección contra 
daños.
### Instrucciones de Desglose y Formato
Proceda a descomponer la Historia de Usuario general en un mínimo de tres (3) sub-historias de usuario o más, siguiendo estrictamente los siguientes criterios de calidad y especificación para cada una:
1.  Estructura Concisa: Cada sub-historia debe mantener la estructura estándar: "Como [tipo de usuario], quiero [una acción] para [beneficio/valor].".
2.  Enfoque en Datos: Cada sub-historia debe estar centrada en las necesidades de datos o en un requisito específico de almacenamiento o consulta.
3.  Especificación Detallada (Requerimientos de Datos y Reglas): Para cada sub-historia, incluya una Descripción detallada y un conjunto de Criterios de Aceptación.
    *   Descripción: Indique claramente los datos que deben capturarse, almacenarse o consultarse, precisando la granularidad necesaria.
    *   Criterios de Aceptación: Deben ser objetivos, medibles y verificables. Además, deben reflejar las reglas de negocio o restricciones aplicables a los datos requeridos.
4.  Evitar el Tecnicismo: La redacción debe ser en un lenguaje comprensible y evitar la mención directa a estructuras técnicas como tablas o columnas.
### Formato de Salida Requerido
Genere una lista numerada de sub-historias utilizando el siguiente modelo para cada una:
Sub-Historia de Usuario N
| Elemento | Contenido |
| :--- | :--- |
| Tipo de Usuario | [Tipo de usuario] |
| Acción | [Acción específica] |
| Valor/Beneficio | [Beneficio específico] |
| Descripción | [Descripción detallada, incluyendo los datos requeridos y su granularidad (por producto, por transacción, etc.).] |
| Criterios de Aceptación | 1. [Criterio 1: Debe ser verificable y objetivo. (Incluye reglas de negocio).] <br> 2. [Criterio 2: Debe ser verificable y objetivo.] <br> 3. [Criterio N] |