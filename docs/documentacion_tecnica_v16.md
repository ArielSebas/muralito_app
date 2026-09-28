# Muralito App — Documentación Técnica

**Versión:** 16  
**Fecha:** 26/09/2026  
**Estado:** MVP funcional — desarrollo activo  
**Sustituye a:** Documentación Técnica v15 (21/09/2026). Histórico de versiones anteriores conservado.  

**Últimas funcionalidades implementadas:**
* Atribución visible de OpenStreetMap: Integración de atribución legal limpia («© Colaboradores de OpenStreetMap») en el mapa principal y en la pantalla de ajuste, enlazando directamente a [https://www.openstreetmap.org/copyright](https://www.openstreetmap.org/copyright) mediante url_launcher. 
* Sistema unificado de notificaciones (Toast superior en mapa): Estandarización de avisos en mapa_principal_page.dart (éxito en verde, error en rojo, información y GPS con acciones en morado) ubicados en el Stack superior, eliminando los SnackBars flotantes que se desfasaban verticalmente hacia el centro del mapa. 
* Origen de fotografía en «Nuevo Mural» (Cámara o Galería): Modal inferior interactivo que permite elegir entre captura inmediata mediante cámara nativa o selección de archivo preexistente desde la galería del dispositivo. 

**Últimas funcionalidades validadas:**
* Atribución OSM: Verificación de no colisión táctil/visual, renderizado correcto y apertura funcional del enlace externo en navegador del sistema. 
* Avisos UI en mapa: Validación visual y temporal (3 segundos, no bloqueo de gestos, botones flotantes anclados a su posición inferior estándar). 
* Cámara / Galería en alta de mural: 4 pruebas manuales confirmadas en dispositivo físico (cancelación de modal, captura por cámara, cancelación en galería y flujo completo de subida desde galería). 

**Correcciones documentales y técnicas cerradas en esta versión:**
* Identidad Android alineada: Se constató en código real (android/app/build.gradle.kts y MainActivity.kt) que namespace y applicationId están alineados en com.muralitoapp.app. Se rectifica formalmente la discrepancia documental de la v15. 
* Reposicionamiento de controles: Retiro del padding inferior excesivo en los botones flotantes («Mi ubicación» y «Nuevo Mural»), manteniéndolos en su posición estándar sin solapar la atribución. 

**Hallazgos pendientes sin resolver:**
* Firma de release en android/app/build.gradle.kts sigue configurada con signingConfigs.getByName("debug"). 
* Campo de correo electrónico en autenticación retiene el error visual de validación al escribir tras un intento fallido (mismo patrón que DT4-01). 
* Colores hardcodeados en 8 archivos (~53 referencias a Colors.deepPurple). 
* Escenario M6-06 (sin GPS actual ni última ubicación conocida) continúa sin verificar. 
* Remitente onboarding@resend.dev en Resend pendiente de reemplazo por dominio propio antes de admitir evaluadores externos. 

**Siguiente trabajo:** A definir con el propietario del proyecto entre los candidatos vigentes: autovalidate del campo de correo (UX), M4 redefinido («Cómo llegar» hacia app de Google Maps), o firma de release para producción. 

**Objetivo de producto:** Preparar una primera versión suficientemente estable, usable, segura y probada para una futura publicación en Google Play. Noviembre de 2026 se mantiene como objetivo orientativo, no como fecha límite. 

**Funcionalidad bloqueada:** M9 — Leaked Password Protection (requiere plan Supabase Pro). 

## 1. Descripción del proyecto
Muralito App es una aplicación móvil desarrollada con Flutter para Android orientada a registrar, visualizar y consultar murales urbanos mediante un mapa interactivo sobre OpenStreetMap, con backend en Supabase (PostgreSQL, Auth y Storage). 

**Cada mural registrado incluye:** 
* Fotografía (comprimida; editable posteriormente por su propietario). 
* Título y descripción. 
* Coordenadas GPS confirmadas en el mapa durante el alta. Tras publicar, la ubicación es inmutable. 
* Usuario que realizó la carga (apodo y avatar) mediante la atribución A3 «Subido por» (no representa necesariamente al artista de la pintura; ver A4). 
* Fecha de creación. 

**Modos de uso:**
* **Modo espectador:** Consulta pública del mapa, clusters y fichas informativas sin requerir inicio de sesión. Permite centrar en «Mi ubicación» y usar «Cómo llegar». 
* **Modo autenticado:** Registro, inicio/cierre de sesión, recuperación de contraseña por OTP, CRUD completo de murales propios, selección de foto (cámara o galería) y personalización del perfil. 

## 2. Estado actual del proyecto (26/09/2026)

| Área | Estado | Evidencia / Nota |
|---|---|---|
| Mapa OSM + clustering 30 m + zoom 6–18 | VALIDADO | Pruebas 003, 006 históricas. |
| Atribución visible OpenStreetMap | VALIDADO | Implementada en mapa principal y ajuste; enlaces probados. |
| Sistema de avisos (Toast superior en mapa) | VALIDADO | Banner unificado en Stack superior sin colisiones con FABs. |
| CRUD murales + foto + DT1 rollback | VALIDADO | Pruebas 001, 004, 007–009, 012. |
| Origen de foto (Cámara / Galería) | VALIDADO | 4 pruebas manuales PASS (cancelación, cámara y galería). |
| Auth + M1 + M2 OTP + Resend | VALIDADO | Pruebas 005, M1-01…09, M2-01…08. |
| DT4-01 — Borde rojo contraseña | VALIDADO | Registro y recuperación; error se oculta al tipear. |
| Sanitización de Storage | VALIDADO | Helper estricto nombreArchivoDesdeTitulo en alta y edición. |
| Perfil + trigger + DT2 avatar | VALIDADO | Pruebas 010, DT2-01…05, #015. |
| A3 Subido por | VALIDADO | Prueba 013. |
| RLS murales / RLS perfiles (DT3) | VALIDADO | Políticas delegadas a PostgreSQL (auth.uid()). |
| DT4 errores + DT13 loading | VALIDADO | conDialogoCarga y errores amigables en español. |
| M5 GPS + pin en alta | VALIDADO | Pruebas M5-01…11. |
| B1 Restricción de listing Storage | VALIDADO | Listing anónimo restringido; URLs públicas operativas. |
| M6 Centrar mapa en mi ubicación | VALIDACIÓN PARCIAL | M6-01…05 y M6-07 PASS; M6-06 continúa NO VERIFICADO. |
| Identidad Android (applicationId + namespace) | VALIDADO | com.muralitoapp.app alineado y verificado en build.gradle.kts. |
| M3 — Onboarding de ubicación | VALIDADO | 4 pruebas manuales confirmadas vía shared_preferences. |
| Firma de release | PENDIENTE | Sigue con signingConfigs.getByName("debug"). |
| Autovalidate campo correo | PROBLEMA CONFIRMADO | Error persiste al escribir hasta el próximo reintento de envío. |
| Colores hardcodeados | RIESGO / DEUDA | ~53 referencias a Colors.deepPurple en 8 archivos. |
| M9 Leaked Password Protection | BLOQUEADO | Requiere plan Supabase Pro. |
| SMTP dominio propio Resend | PENDIENTE | Requerido antes de incorporar evaluadores externos. |
| Tests automatizados (DT14) | PENDIENTE | Cobertura respaldada en pruebas funcionales manuales. |

## 3. Tecnologías y dependencias
* **Framework:** Flutter 3.47.0, Dart 3.13.0. 
* **Android SDK:** Platform 36. 
* **Backend:** Supabase (PostgreSQL 15+, Supabase Auth, Supabase Storage). 
* **Mapas:** flutter_map ^8.3.1, latlong2 ^0.10.1, OpenStreetMap. 

Dependencias en pubspec.yaml:
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  supabase_flutter: ^2.17.2
  flutter_map: ^8.3.1
  latlong2: ^0.10.1
  geolocator: ^14.0.3
  image_picker: ^1.2.3
  flutter_image_compress: ^2.5.1
  flutter_dotenv: ^6.0.1
  url_launcher: ^6.3.1
  shared_preferences: ^2.5.4
```
No se agregaron dependencias adicionales en esta versión. url_launcher y image_picker ya formaban parte del stack y absorbieron los nuevos requerimientos funcionales. 

## 4. Variables de entorno
El proyecto emplea flutter_dotenv: 
* El archivo .env se encuentra declarado como asset en pubspec.yaml y estrictamente excluido del repositorio en .gitignore. 
* Claves requeridas: SUPABASE_URL y SUPABASE_ANON_KEY. 
* Se mantiene .env.example en la raíz como plantilla de configuración. 

## 5. Configuración Android e Identidad

### 5.1 applicationId y namespace (Alineación confirmada)
**Estado:** VALIDADO.

En android/app/build.gradle.kts: 
```kotlin
android {
    namespace = "com.muralitoapp.app"
    ...
    defaultConfig {
        applicationId = "com.muralitoapp.app"
    }
}
```
En android/app/src/main/kotlin/com/muralitoapp/app/MainActivity.kt: 
```kotlin
package com.muralitoapp.app
```
Se rectifica formalmente la discrepancia de la v15: ambos parámetros sí están unificados y normalizados bajo com.muralitoapp.app. 

### 5.2 User-Agent y Atribución OpenStreetMap
* **User-Agent:** Los TileLayer en mapa_principal_page.dart y ajustar_ubicacion_page.dart configuran userAgentPackageName: 'com.muralitoapp.app'. 
* **Atribución obligatoria (CERRADA en v16):**
La directriz de uso de tiles de tile.openstreetmap.org exige mostrar el texto de atribución visible y clicable. 
Implementación: Se integró un contenedor Align(alignment: Alignment.bottomLeft) con InkWell que renderiza: 
© Colaboradores de OpenStreetMap
Al pulsarlo, invoca [https://www.openstreetmap.org/copyright](https://www.openstreetmap.org/copyright) en LaunchMode.externalApplication. 
Se prescindió del widget por defecto SimpleAttributionWidget de flutter_map para omitir el prefijo no normativo flutter_map | . 

### 5.3 Firma de compilación Release
**Estado:** PENDIENTE / RIESGO BLOQUEANTE DE PLAY STORE. 

android/app/build.gradle.kts conserva: 
```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
    }
}
```
Debe generarse un Keystore de producción (.jks) y configurar variables de entorno para compilar artefactos aptos para Google Play. 

## 6. Estructura de lib/
```plaintext
lib/
├── main.dart
├── models/
│   ├── mural.dart
│   └── perfil.dart
├── pages/
│   ├── auth_page.dart
│   ├── mapa_principal_page.dart
│   └── recuperar_password_page.dart
├── services/
│   ├── supabase_client.dart
│   └── ubicacion_service.dart
├── utils/
│   └── helpers.dart
└── widgets/
    ├── ajustar_ubicacion_page.dart
    ├── dialogo_carga.dart
    ├── editar_mural_modal.dart
    ├── editar_perfil_modal.dart
    ├── formulario_mural_modal.dart
    └── onboarding_ubicacion_dialog.dart
```
**Notas de arquitectura:**
* mapa_principal_page.dart incorpora el modelo interno _AvisoUI y centraliza la emisión de notificaciones superiores (_mostrarAviso), además del diálogo selector de origen de foto (_seleccionarOrigenFoto). 
* Sigue pendiente a mediano plazo la descomposición de mapa_principal_page.dart (DT10), que mantiene acopladas la lógica de presentación, clustering, llamadas directas a Supabase y control de estado local. 

## 7. Modelos de datos
* **Mural (lib/models/mural.dart):** Propiedades: id, titulo, descripcion, fotoUrl, latitud, longitud, createdAt, userId, autorApodo, autorAvatarUrl. toMap() excluye datos derivados del autor. 
* **Perfil (lib/models/perfil.dart):** Propiedades: id, apodo, avatarUrl, createdAt. Contiene el método toMap() no utilizado en el flujo actual (código muerto menor). 

## 8. Persistencia y Políticas RLS

### 8.1 Tabla public.murales
**Columnas:** id (bigint PK), created_at (timestamptz), titulo (text), descripcion (text, nullable), foto_url (text), latitud (double precision), longitud (double precision), user_id (uuid, nullable en filas legadas). 
**Políticas RLS:**
* SELECT: Pública (anon, authenticated). 
* INSERT: Autenticada con auth.uid() = user_id. 
* UPDATE: Propietario (auth.uid() = user_id). La app no incluye latitud ni longitud en las actualizaciones, garantizando coordenadas inmutables. 
* DELETE: Propietario (auth.uid() = user_id). 

### 8.2 Tabla public.perfiles y Trigger
Creada y vinculada a auth.users mediante trigger on_auth_user_created (manejar_nuevo_usuario()) en modo SECURITY DEFINER. 
**Políticas RLS:**
* SELECT: Pública. 
* INSERT / UPDATE: Exclusiva de auth.uid() = id. 
* DELETE: Denegada para clientes. 

## 9. Supabase Storage y Sanitización
* **Bucket:** murales (almacenamiento plano en la raíz para fotografías de murales y avatares). 
* **Políticas de Storage:**
  * Listing: Restringido a usuarios autenticados (B1). 
  * URLs públicas directas: Permitidas para lectura pública. 
  * Subida (INSERT): Usuarios autenticados. 
  * Eliminación (DELETE): Exclusiva del propietario (owner = auth.uid()). 
* **Principio de persistencia con Rollback (DT1/DT2):** Si la inserción en PostgreSQL falla tras subir el archivo, el objeto se borra inmediatamente de Storage. En ediciones, el archivo antiguo solo se elimina tras verificar que el UPDATE en base de datos retornó éxito. 
* **Sanitización compartida:** Ambos flujos (alta y edición) consumen nombreArchivoDesdeTitulo() en lib/utils/helpers.dart, garantizando nombres sin secuencias que originen subrutas implícitas. 
* **Riesgo DT8:** borrarFotoDeStorage() toma uri.pathSegments.last. Funciona correctamente en estructura plana; requerirá refactor si a futuro se definen subcarpetas. 

## 10. Flujo de Autenticación y UX
* **Políticas de contraseña (M1):** 8+ caracteres, mayúscula, minúscula, número y símbolo. Checklist visual reactivo en registro y recuperación. 
* **Comportamiento visual (DT4-01):** El borde rojo de error se limpia en cuanto el usuario presiona una tecla para corregir, y solo se evalúa al perder el foco o pulsar el botón de envío. 
* **Recuperación (M2):** Envío de código OTP de 6 dígitos mediante Resend con cooldown de 60 s. 
* **Seguridad (DT4-02):** Respuestas genéricas ante cuentas ya registradas para impedir enumeración de correos. 
* **Deuda técnica activa:** El campo "Correo electrónico" carece del mismo mecanismo de limpieza reactiva de DT4-01 y retiene el mensaje de error fijo al escribir tras un intento fallido de envío. 

## 11. Registro de Mural y Selección de Fotografía (v16)
El flujo de alta en _iniciarFlujoNuevoMural() opera de la siguiente manera: 
* **Comprobación de sesión:** Si es espectador, despliega diálogo solicitando login o registro. 
* **Selección de origen (NUEVO v16):** Despliega _seleccionarOrigenFoto(). El usuario elige entre «Tomar fotografía» (ImageSource.camera) o «Elegir de la galería» (ImageSource.gallery). Si cancela, el flujo finaliza limpiamente. 
* **Captura y Onboarding M3:** Al obtener la imagen, se comprueba si debe mostrarse el diálogo de onboarding de ubicación (una única vez por instalación) antes de activar los servicios de geolocalización. 
* **Fijación de coordenadas (M5):** Abre AjustarUbicacionPage con pin central estático sobre el mapa. Intenta GPS no bloqueante (timeout 10 s); si no hay señal, permite arrastrar el mapa manualmente o adoptar la última ubicación conocida. 
* **Formulario y subida:** Formulario modal de título y descripción. Compresión de imagen a JPEG (máx. 1200x1200, calidad 80, autocorrección de ángulo). Subida a Storage y posterior INSERT en murales. 
* **Feedback:** Emisión del toast superior verde «Mural guardado correctamente» y recentrado automático del mapa en el punto del nuevo mural. 

## 12. Sistema Unificado de Avisos en Mapa (v16)
Se reemplazaron los SnackBar convencionales en MapaPrincipalPage por un banner tipo toast situado en el Stack superior bajo la AppBar: 
* **Modelo _AvisoUI:**
  * _TipoAviso.exito: Fondo verde (Colors.green[700]), ícono de confirmación. 
  * _TipoAviso.error: Fondo rojo (Colors.red[700]), ícono de alerta. 
  * _TipoAviso.info: Fondo morado (Colors.deepPurple[700]), ícono de información. 
* **Comportamiento:** Se oculta automáticamente tras 3 segundos. Si incluye acción interactiva (ej. avisos de GPS «Activar» o «Ajustes»), renderiza un botón en texto resaltado (Colors.amberAccent) que ejecuta la acción nativa de geolocator. 
* **Ventaja UX:** No colisiona ni empuja los botones flotantes inferiores («Nuevo Mural» y «Mi ubicación»), manteniendo la vista del mapa despejada. 

## 13. M6 — Centrar mapa en mi ubicación
Reutiliza ubicacion_service.dart: 
* M6-01 (GPS activo): Centra la cámara con zoom 17. (VALIDADO). 
* M6-02 (GPS apagado): Muestra toast superior con acción para abrir ajustes de ubicación. (VALIDADO). 
* M6-03 (Permiso denegado): Muestra toast superior informativo. (VALIDADO). 
* M6-04 (Permiso bloqueado permanentemente): Muestra toast superior con acción directa hacia ajustes de la app. (VALIDADO). 
* M6-05 (Última ubicación conocida): Centra en el último registro y emite toast morado. (VALIDADO). 
* M6-06 (Sin ubicación actual ni última conocida): NO VERIFICADO (caso de borde no aislado en hardware físico). 
* M6-07 (Regresión): Pruebas de navegación sin conflicto. (VALIDADO). 

## 14. Historial de Pruebas y Evidencia
**Evidencia de esta versión (v16 — 26/09/2026)**
* **Atribución OpenStreetMap:**
  * Verificación estática con flutter analyze: Limpio (No issues found!). 
  * Apertura exitosa de [https://www.openstreetmap.org/copyright](https://www.openstreetmap.org/copyright) en navegador externo desde ambas pantallas. 
  * Eliminación del prefijo redundante flutter_map | . 
* **Sistema de Avisos UI:**
  * Validación visual: Notificaciones de guardado, actualización, borrado y avisos de GPS desplegadas en la cabecera sin alterar la posición de los FABs. 
* **Origen de imagen en Nuevo Mural:**
  * Prueba 1 (Cancelación del menú modal): PASS.
  * Prueba 2 (Cámara activa y captura normal): PASS.
  * Prueba 3 (Cancelación dentro de la galería): PASS.
  * Prueba 4 (Flujo completo con imagen seleccionada de galería): PASS.

## 15. Backlog y Deuda Técnica

| Código / ID | Descripción | Estado |
|---|---|---|
| Atribución OSM | Requisito legal de política de tiles de OSM | VALIDADO (v16) |
| Origen de foto | Soporte de cámara y galería en alta de mural | VALIDADO (v16) |
| Avisos UI mapa | Toast superior unificado en mapa principal | VALIDADO (v16) |
| Firma de release | Keystore y signingConfig para producción en Android | PENDIENTE (Bloqueante) |
| Autovalidate correo | Replicar solución reactiva de DT4-01 en campo de email | PENDIENTE (UX) |
| M4 (redefinido) | Botón «Cómo llegar» abriendo Google Maps nativo | PENDIENTE (Producto) |
| Colores hardcodeados | Sustitución de Colors.deepPurple por Theme.of(context) | PENDIENTE (Estilo) |
| M17 (nuevo) | Borradores locales y reintento de subida offline | PENDIENTE (Post-v1) |
| A4 | Distinción entre usuario uploader y artista de la obra | PENDIENTE (Producto) |
| A1.4 | Historial de fotos con galería de versiones (ventana 6 días) | PENDIENTE (Producto) |
| DT5–DT9 | Auditoría de bajo nivel (paths, AuthGate, fromMap) | POSPUESTO |
| DT10–DT12 | Desacoplamiento de mapa_principal_page.dart y Repositories | NO AHORA |
| DT14–DT18 | Tests unitarios, logging estructurado, clustering a escala | PENDIENTE |
| M9 | Leaked Password Protection | BLOQUEADO (Requiere Pro) |

## 16. Decisiones Técnicas Vigentes
* **Atribución OSM obligatoria:** Se mantiene mediante widget independiente en bottomLeft sin prefijos de librería externa. 
* **Identidad de aplicación:** namespace y applicationId están alineados en com.muralitoapp.app. 
* **Inmutabilidad de coordenadas:** Una vez publicado el mural, no se permite editar su posición geográfica. 
* **Persistencia y Rollback:** No se elimina ninguna foto previa sin confirmar el éxito en PostgreSQL; si el INSERT falla, se borra el archivo huérfano de Storage. 
* **Onboarding de ubicación (M3):** Se muestra una única vez por instalación mediante shared_preferences. 
* **M4 Redefinido:** Mantener OpenStreetMap como motor de mapas interno de la app; modificar únicamente el enlace de «Cómo llegar» para invocar Google Maps nativo. 
* **Borradores locales (M17):** Se difiere para versiones posteriores a la v1 para no sobrecargar el alcance del lanzamiento inicial.

## 17. Control de Versión
**Documento:** Documentación Técnica v16  
**Fecha:** 26/09/2026  
**Sustituye a:** Documentación Técnica v15   
**Resumen de cambios:** Incorporación de la atribución visible de OpenStreetMap; unificación del sistema de avisos UI en el mapa principal; inclusión de galería en el alta de murales; formalización de la alineación de namespace y applicationId en com.muralitoapp.app; adición de M17 al backlog post-v1; actualización de tablas de pruebas y dependencias.   
**Licencia:** MIT.