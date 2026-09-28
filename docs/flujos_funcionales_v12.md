# Muralito App — Flujos Funcionales Actuales

**Versión:** v12
**Fecha:** 26/09/2026
**Plataforma:** Android · Flutter · Supabase · OpenStreetMap
**Alcance:** Funcionalidades implementadas y probadas hasta la fecha. Los estados se mantienen estrictamente diferenciados entre implementado, validado y no verificado.
**Sustituye a:** Flujos_Funcionales_v11 (21/09/2026).

**Cambios principales respecto a v11:**
* Selección de origen de imagen en «Nuevo Mural» (sección 6): Incorporación de modal inferior que permite elegir entre captura inmediata mediante cámara nativa o selección de archivo preexistente en la galería del dispositivo.
* Sistema unificado de notificaciones (Toast superior en mapa, sección 17): Estandarización de avisos (éxito en verde, error en rojo, información y GPS con acciones en morado) en la cabecera del mapa, retirando los SnackBars flotantes que se desplazaban hacia el centro de la pantalla.
* Atribución visible de OpenStreetMap (sección 10): Integración de badge de atribución legal sin prefijos externos en la esquina inferior izquierda del mapa principal y de la pantalla de ajuste de pin, con enlace externo clicable hacia la licencia de OSM.
* Ajuste visual de controles flotantes (sección 10): Reposicionamiento ergonómico de los botones «Mi ubicación» y «Nuevo Mural» en el anclaje inferior derecho estándar.

## 1. Tipos de usuario

### 1.1 Espectador
Usuario sin sesión iniciada. Puede:
* Visualizar el mapa base OpenStreetMap y la atribución legal obligatoria.
* Visualizar los marcadores y clusters de murales.
* Consultar fichas de murales y la información del usuario que realizó la carga (A3 «Subido por»).
* Utilizar «Cómo llegar» mediante enlace externo a OpenStreetMap.
* Utilizar el control «Mi ubicación» para centrar el mapa (disparando el onboarding de ubicación M3 en su primer uso).
* Recibir avisos contextuales y estados de GPS mediante el banner superior del mapa.
No puede: registrar murales, editar murales, eliminar murales ni gestionar perfiles.

### 1.2 Usuario autenticado
Puede acceder a todas las capacidades del espectador y además:
* Registrar nuevos murales seleccionando origen de foto (cámara o galería) y ajustando el pin.
* Editar y eliminar sus propios murales.
* Gestionar su perfil (modificar apodo y actualizar avatar).
* Recuperar su contraseña mediante código OTP.

La autorización de las operaciones sobre datos se delega formalmente a PostgreSQL mediante Row Level Security (RLS). La edición de un mural no permite modificar las coordenadas geográficas publicadas.

## 2. Inicio de la aplicación

```plaintext
Abrir aplicación
       ↓
Cargar .env
       ↓
Inicializar Supabase
       ↓
MapaPrincipalPage
       ↓
Comprobar sesión (Supabase Auth)
       ↓
Sesión activa  ·  Sin sesión
       ↓
Cargar murales + perfiles (A3)
       ↓
Renderizar mapa OSM (con atribución legal y marcadores)
```

AuthGate actúa como passthrough directo al mapa. El mapa conmuta internamente entre modo espectador y sesión autenticada mediante su propio listener de onAuthStateChange. La visualización incluye la atribución «© Colaboradores de OpenStreetMap» en la esquina inferior izquierda.

## 3. Registro e inicio de sesión

### 3.1 Intentar registrar un mural sin sesión

```plaintext
Pulsar "Nuevo Mural" → ¿Hay sesión?
  ├─ Sí → Flujo de selección de foto (Sección 6)
  └─ No → Mostrar diálogo de autenticación requerida
            ├─ "Seguir explorando" → Permanece en el mapa
            ├─ "Iniciar sesión"    → AuthPage (modo login)
            └─ "Registrarse"       → AuthPage (modo registro)
```

Si el usuario completa la autenticación tras este diálogo, el flujo de «Nuevo Mural» se reanuda automáticamente sin requerir una segunda pulsación.

### 3.2 Registro

```plaintext
AuthPage → Correo + contraseña → Validación M1 → signUp → Confirmación por correo → Trigger on_auth_user_created → Perfil creado → Mapa
```

* Reglas de contraseña (M1): Mínimo 8 caracteres, al menos una mayúscula, una minúscula, un número y un carácter especial. Checklist visual reactivo en tiempo real.
* Comportamiento del campo de contraseña (DT4-01): El borde rojo y mensaje de error se limpian en cuanto el usuario presiona una tecla para corregir. Solo se visualiza el error al perder el foco del campo o al presionar el botón de envío. En modo login este comportamiento se omite para evitar validaciones innecesarias.
* Seguridad anti-enumeración (DT4-02): Si el correo ya existe, la aplicación presenta una confirmación genérica que no revela la existencia de la cuenta.

### 3.3 Inicio de sesión y cierre de sesión
* Login: Correo + contraseña → signInWithPassword → Sesión iniciada → Recarga de perfil y actualización de AppBar.
* Logout: Cierre de sesión → signOut → AppBar vuelve a «Modo espectador» → Disparo de banner superior informativo morado: «Sesión cerrada. Sigues viendo el mapa.». El mapa no se bloquea.

## 4. Recuperación de contraseña — M2

```plaintext
Recuperar contraseña → Ingresar correo → resetPasswordForEmail → Correo con código OTP (Resend) → verifyOTP(recovery) → Ingreso de nueva contraseña (Validación M1 y lógica DT4-01) → updateUser → Redirección al flujo principal
```

El reenvío del código OTP está restringido por un temporizador de cooldown de 60 segundos.
El campo de nueva contraseña implementa la lógica de DT4-01: no marca error visual mientras el usuario está escribiendo.

## 5. Onboarding de ubicación — M3
Diálogo explicativo presentado una única vez en la vida de la instalación, antes de invocar los servicios de geolocalización o solicitar los permisos nativos de Android.
* Disparadores: Se activa ante la primera acción de ubicación que el usuario ejecute:
  * Tocar «Nuevo Mural» (tras seleccionar la fotografía y antes de cargar el mapa de pin).
  * Tocar «Mi ubicación» desde el mapa principal.
* Persistencia: Almacenado de forma duradera mediante shared_preferences (clave onboarding_ubicacion_visto). Sobrevive al cierre forzado o reinicio del teléfono.
* Comportamiento: Tras pulsar «Entendido», la acción original continúa de forma inmediata y automática.

## 6. Alta de mural — M5 / DT1 / DT13 / Selección de Origen [ACTUALIZADO v12]
Requiere sesión activa. El flujo completo opera de forma secuencial:

```plaintext
Pulsar "Nuevo Mural"
       ↓
Comprobar sesión activa
       ↓
[NUEVO v12] Desplegar Modal: Selección de Origen
  ├─ "Tomar fotografía"   → ImagePicker (Cámara nativa)
  └─ "Elegir de la galería" → ImagePicker (Galería del sistema)
  (Si cancela o retrocede → Cierra modal y regresa al mapa)
       ↓
Foto obtenida con éxito
       ↓
Comprobar Onboarding de ubicación M3 (solo primera vez)
       ↓
Navegar a AjustarUbicacionPage
       ↓
Intento de GPS no bloqueante (timeout 10 s)
  ├─ Posición obtenida → Centra mapa en GPS actual
  ├─ Sin GPS actual pero con última conocida → Centra en fallback + aviso en tarjeta
  └─ GPS apagado o sin permisos → Botón de acción + ajuste manual
       ↓
Pin central fijo: Usuario desplaza el mapa para colocar el pin sobre el mural
       ↓
Pulsar "Usar esta ubicación"
       ↓
Desplegar FormularioMuralModal (Título, descripción, previsualización)
       ↓
Pulsar "Guardar mural"
       ↓
conDialogoCarga (spinner seguro DT13)
  ├─ Compresión JPEG (máx. 1200x1200, q=80, rotación y corrección EXIF)
  ├─ Subida a Storage (bucket 'murales', sanitización estricta de nombre)
  ├─ INSERT en public.murales
  └─ [Rollback DT1] Si el INSERT falla, se borra el archivo recién subido de Storage
       ↓
[NUEVO v12] Notificación en Banner Superior (Verde): "Mural guardado correctamente."
       ↓
Carga de murales recargada y mapa centrado en el punto del nuevo mural
```

## 7. Control «Mi ubicación» — M6 [ACTUALIZADO v12]
Ubicado en el mapa principal, reutiliza la lógica centralizada de ubicacion_service.dart:
* Pulsar botón «Mi ubicación»: Se activa spinner de progreso en el propio botón flotante para evitar pulsaciones múltiples. Si es el primer uso, antepone el diálogo M3.
* GPS activo y con permiso (M6-01): Obtiene coordenadas y centra el mapa con nivel de zoom 17. (VALIDADO).
* GPS apagado (M6-02): Emite banner superior morado: «El GPS está apagado. Actívalo para centrar el mapa.» con botón interactivo «Activar» que invoca Geolocator.openLocationSettings(). (VALIDADO).
* Permiso denegado (M6-03): Emite banner superior informativo morado indicando que se requiere permiso. (VALIDADO).
* Permiso bloqueado permanentemente (M6-04): Emite banner superior morado con botón «Ajustes» que invoca Geolocator.openAppSettings(). (VALIDADO).
* Última ubicación conocida (M6-05): Si no hay señal satelital inmediata pero existe registro previo, centra en dicha posición y notifica vía banner morado. (VALIDADO).
* Sin ubicación actual ni última conocida (M6-06): (NO VERIFICADO).

## 8. Confirmación de coordenadas e inmutabilidad
El punto geográfico asignado al mural corresponde exactamente al centro de la cámara (camera.center) confirmado en AjustarUbicacionPage.
Regla de inmutabilidad: Una vez guardado el mural, sus coordenadas geográficas no pueden editarse ni moverse desde la interfaz ni mediante peticiones de cliente. La pantalla de edición omite de forma estricta los campos latitud y longitud en el payload de actualización.

## 9. Subida de imágenes, persistencia y políticas de Storage
* Bucket: murales (almacenamiento plano en la raíz).
* Sanitización compartida: Tanto el alta como la edición procesan el título con nombreArchivoDesdeTitulo() en helpers.dart, eliminando barras y caracteres conflictivos.
* Políticas de Storage:
  * Listing anónimo restringido (B1): Solo usuarios autenticados pueden listar el contenido del bucket.
  * Acceso público directo: Permitido mediante URL pública estructurada.
  * Subida e inserción: Exclusiva para usuarios autenticados.
  * Eliminación: Exclusiva para el usuario propietario del archivo (owner = auth.uid()).
* Principio de persistencia y Rollback:
  * En altas: si la inserción en base de datos falla, se purga la imagen subida en Storage (DT1).
  * En ediciones: la imagen anterior solo se elimina tras constatar que el UPDATE en PostgreSQL devolvió éxito.

## 10. Mapa, clustering, atribución y controles [ACTUALIZADO v12]
* Motor: flutter_map ^8.3.1 con teselas de OpenStreetMap.
* Zoom: Rango delimitado entre nivel 6.0 y 18.0.
* Clustering: Agrupación geográfica automática a un radio de 30 metros.
* Pin individual: Icono morado con pincel blanco.
* Cluster: Círculo con conteo numérico que intensifica el tono morado según la densidad de murales.
* Interacción: Tocar un cluster acerca el mapa 2 niveles de zoom y despliega un menú modal con la lista de murales correspondientes.
* Atribución visible de OpenStreetMap [NUEVO v12]:
  * Ubicada en la esquina inferior izquierda del mapa.
  * Contenedor semitransparente con el texto: © Colaboradores de OpenStreetMap.
  * Al pulsar sobre el texto, abre la URL oficial <https://www.openstreetmap.org/copyright> en el navegador del dispositivo.
* Disposición de botones flotantes (FABs) [ACTUALIZADO v12]:
  * Situados en la esquina inferior derecha: botón circular de «Mi ubicación» sobre el botón extendido «Nuevo Mural».
  * Su posición no colisiona visualmente con el badge de atribución ubicado a la izquierda ni interfiere con los eventos táctiles.

## 11. Ficha de detalle de mural y «Subido por» (A3)
Al tocar un pin o elegir un elemento de la lista de cluster, se despliega una hoja modal inferior deslizable (DraggableScrollableSheet):
* Fotografía adaptable con dimensiones restringidas y control de fallos de red.
* Título, descripción y coordenadas geográficas formateadas.
* Bloque A3 («Subido por»): Muestra el avatar y apodo del usuario que subió el registro a la plataforma. Si el registro pertenece a fases tempranas sin identificador de autor, se le asigna de forma predeterminada «Muralista anónimo».
* Botón de navegación externa «Cómo llegar».
* Controles de «Editar» y «Eliminar» (visibles exclusivamente si el usuario conectado coincide con mural.userId).

## 12. Navegación externa: «Cómo llegar»
Al presionar «Cómo llegar», la aplicación genera un enlace web hacia OpenStreetMap con los parámetros de latitud y longitud correspondientes y lo abre en el navegador externo del sistema.
Si el sistema no puede procesar el intent, la pantalla despliega un banner superior de error indicando las coordenadas para consulta manual.
(Nota de producto: La redefinición de M4 para invocar la app nativa de Google Maps permanece registrada en el backlog pendiente de implementación).

## 13. Edición de mural propio [ACTUALIZADO v12]

```plaintext
Ficha de mural → Pulsar "Editar" → Validar autoría en UI y RLS → Modal EditarMuralModal
  ├─ Modificar título / descripción / rotación
  └─ Opcional: Reemplazar fotografía
       ↓
Pulsar "Guardar cambios"
  ├─ Caso sin cambio de foto: UPDATE inmediato en public.murales
  └─ Caso con foto nueva: Subida de nueva foto → UPDATE en base de datos → Borrado de foto antigua
       ↓
Feedback: Emisión de Banner Superior verde: "Mural [Título] actualizado correctamente."
```

En caso de error en la transacción o en la red, se emite un banner superior rojo con la descripción amigable del fallo y la imagen original se mantiene intacta.

## 14. Eliminación de mural propio [ACTUALIZADO v12]

```plaintext
Ficha de mural → Pulsar "Eliminar" → Diálogo de confirmación ("¿Seguro que quieres eliminar...?")
  ├─ Cancelar → Cierra diálogo sin efectos
  └─ Confirmar → DELETE en public.murales (Validado por RLS)
                   ↓
                 Limpieza de Storage (borrado best-effort de la fotografía)
                   ↓
                 Recarga de la lista de murales
                   ↓
                 Feedback: Banner Superior verde: "Mural [Título] eliminado correctamente."
```

## 15. Gestión de Perfil
Accesible desde la barra superior (AppBar) tocando el avatar/apodo:
* Permite actualizar el apodo y cargar o modificar la fotografía de avatar.
* Las fotos de avatar se comprimen a 400x400 px y se almacenan en el bucket murales.
* Aplica el principio de persistencia segura: el avatar anterior solo se purga de Storage tras confirmar el éxito del UPDATE en la tabla perfiles.
* Al completar la actualización, emite el banner superior verde confirmando el cambio.

## 16. Sistema Unificado de Notificaciones y Avisos en Mapa [NUEVO v12]
Se reemplazaron los SnackBars de Flutter en MapaPrincipalPage por un componente centralizado _AvisoUI renderizado en el Stack superior bajo la AppBar:
* Éxito (Verde): Confirmaciones de alta, edición y eliminación de murales o perfil.
* Error (Rojo): Fallos de red, permisos no concedidos de edición/borrado o caídas de servidor.
* Información / GPS (Morado): Alertas de estado de GPS o avisos de cierre de sesión. Incluye botones de acción contextuales en color ámbar (amberAccent) para abrir ajustes del sistema operativo.
* Ciclo de vida: Desaparición automática tras 3 segundos. No bloquea la visualización del mapa ni compite por espacio con los botones flotantes de la base.

## 17. Regresiones comprobadas en v12
Durante la sesión del 26/09/2026 se validaron las siguientes áreas tras las modificaciones de interfaz y selector de imágenes:
* Atribución OSM y gestos del mapa: Se confirmó que el contenedor de atribución no intercepta toques accidentales ni perjudica el arrastre del mapa, el zoom o la interacción con los marcadores.
* Posición de botones flotantes: Se verificó que los FABs descansan en la base sin solaparse con la atribución ni quedar suspendidos a media pantalla.
* Flujo de fotografía (Cámara / Galería): Las pruebas manuales demostraron que cancelar la selección en cualquiera de los dos orígenes devuelve el control de forma limpia al mapa, y que seleccionar una foto preexistente ejecuta la compresión y la geolocalización exactamente igual que una captura de cámara.
* Sistema de avisos: La transición de SnackBar a toast superior mantiene operativas las acciones de apertura de ajustes del sistema en fallos de GPS.

## 18. Funcionalidades implementadas y validadas
* Mapa interactivo OpenStreetMap con límites de zoom (6–18) y clustering (30 m).
* Atribución visible de OpenStreetMap con redirección funcional a copyright.
* Modo espectador sin bloqueo por autenticación.
* Sistema unificado de avisos y toasts en la cabecera del mapa principal.
* Registro de usuarios, login, confirmación por correo y cierre de sesión.
* Política de contraseña segura (M1) y checklist visual en tiempo real.
* Feedback visual de contraseña (DT4-01) corregido en registro y recuperación.
* Recuperación de contraseña mediante código OTP de 6 dígitos (M2).
* Alta de murales con selección de foto (cámara o galería).
* Fijación de pin con GPS no bloqueante y ajuste manual (M5 / M10).
* Inmutabilidad de coordenadas tras la publicación del mural.
* Edición y eliminación de murales propios con control de persistencia y Storage (DT1/DT2).
* Sanitización unificada de nombres de archivo de imagen para evitar subrutas en Storage.
* Gestión de perfil de usuario (apodo y avatar).
* Bloque de atribución «Subido por» (A3) en fichas de mural.
* Control de «Mi ubicación» en mapa principal (M6-01…05 y M6-07).
* Onboarding de ubicación (M3) persistido con shared_preferences.
* Restricción de listing anónimo en bucket murales (B1).
* Reglas de autorización delegadas a PostgreSQL mediante Row Level Security (DT3).
* Diálogos de carga protegidos contra cierres múltiples (DT13).
* Normalización de identidad Android (applicationId y namespace en com.muralitoapp.app).

## 19. Casos pendientes de verificación técnica
* M6-06 (Sin ubicación actual ni última ubicación conocida): Caso de borde no aislado en hardware físico. Continúa clasificado como NO VERIFICADO.

## 20. Fuera de alcance actual y backlog de producto
* M17 (Nuevo v12): Sistema de borradores locales y reintento de subida ante fallos de conexión (Post-v1).
* Firma de compilación Release: Configuración de Keystore propio en build.gradle.kts (bloqueante para Play Store).
* Autovalidate en campo de correo: Limpieza reactiva del error de validación en autenticación.
* M4 (redefinido): Modificar «Cómo llegar» para abrir la aplicación de Google Maps.
* A4: Distinción formal entre usuario uploader y artista/autor de la obra.
* A1.4: Galería de versiones e historial de fotografías con retención de 6 días.
* M9: Leaked Password Protection (bloqueado por suscripción Supabase Pro).
* Refactor arquitectónico (DT10–DT12): Desacoplamiento de mapa_principal_page.dart (pospuesto).

## 21. Control de versión
**Documento:** Flujos_Funcionales_v12
**Fecha:** 26/09/2026
**Sustituye a:** Flujos_Funcionales_v11

**Resumen de cambios:** Integración del flujo de selección de origen de imagen (Cámara o Galería) en el alta de murales; formalización del sistema unificado de notificaciones tipo toast superior en el mapa principal; documentación del flujo de atribución clicable de OpenStreetMap; ajuste ergonómico de controles flotantes; adición de M17 al inventario de producto fuera de alcance.

Queda formalmente actualizada la versión Flujos Funcionales v12.

Para completar la sincronización documental de la sesión, los siguientes pasos son:
* Actualizar Mejoras v16 (reflejando la atribución de OSM, la unificación de avisos y la galería como completadas, e incorporando M17 al backlog).
* Actualizar README.md con las novedades de la versión 16.