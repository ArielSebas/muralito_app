# Handoff Técnico — Muralito App

**Rol:** Tech Lead Senior
**Fecha de corte:** 27/09/2026
**Plataforma:** Android / Flutter
**Versión de referencia documental:** Documentación Técnica v16, Flujos Funcionales v12, Mejoras v16, README.md
**Handoff previo:** Handoff Técnico (21/09/2026)

## 0. Regla Principal — Fuente de Verdad

Este informe contrasta el código fuente analizado (mapa_principal_page.dart, ajustar_ubicacion_page.dart, build.gradle.kts), los resultados de los comandos ejecutados en terminal (flutter analyze, flutter pub get) y las especificaciones consolidadas en la Documentación Técnica v16.

**Acceso a Supabase:** No se dispone de acceso directo a la consola ni a los archivos de migración .sql de Supabase. La estructura de tablas, triggers y políticas RLS se sustenta en la documentación técnica y en las pruebas de integración históricas registradas.

## 1. Clasificación Obligatoria de Estados

* ✅ **HECHO / IMPLEMENTADO:** Funcionalidad o configuración presente en el código.
* 🧪 **VALIDADO:** Confirmado mediante evidencia de prueba (análisis estático, pruebas funcionales o logs de terminal).
* 🔜 **SIGUIENTE OBJETIVO:** Tarea técnica priorizada pendiente de ejecución.
* ⏳ **PENDIENTE:** Trabajo aún no implementado.
* ⚠️ **PROBLEMA CONFIRMADO:** Falla comprobada mediante código o reproducción.
* ⚠️ **RIESGO / DEUDA TÉCNICA:** Limitación técnica, deuda de diseño o riesgo a escala.
* 💡 **RECOMENDACIÓN:** Sugerencia técnica sujeta a validación.
* ❓ **NO VERIFICADO:** Sin evidencia concluyente para clasificarlo como validado o descartado.

## 2. Control de Versiones de Documentación y Discrepancias

### 2.1 Documentos vigentes analizados

* Documentación Técnica v16 (26/09/2026).
* Flujos Funcionales v12 (26/09/2026).
* Mejoras v16 (26/09/2026).
* README.md (26/09/2026).
* Handoff Técnico (21/09/2026).

### 2.2 Discrepancia previa y estado de resolución

**Discrepancia del namespace de Android:**

* **Estado previo (v15 / Handoff 21/09/2026):** La documentación v15 afirmaba erróneamente que namespace y MainActivity.kt permanecían en com.example.muralito_app mientras que el código real ya utilizaba com.muralitoapp.app.
* **Verificación en código (Sesión 26/09/2026):** Se inspeccionó directamente android/app/build.gradle.kts, confirmando namespace = "com.muralitoapp.app" y applicationId = "com.muralitoapp.app".
* **Resolución:** La Documentación Técnica v16 (§5.1), Mejoras v16 (§1.1) y README.md fueron actualizados, quedando formalmente resuelta la discrepancia documental.

## 3. Resumen Ejecutivo

Muralito App es una aplicación móvil desarrollada en Flutter para Android cuyo propósito es el mapeo colaborativo y visualización de murales urbanos sobre OpenStreetMap, con backend en Supabase (PostgreSQL, Auth y Storage). El proyecto se encuentra en estado de MVP funcional avanzado, con sus flujos críticos (autenticación segura, CRUD de murales, carga por cámara/galería, clustering y visualización pública) operativos y verificados mediante pruebas manuales y estáticas. La siguiente fase de trabajo contempla resolver los problemas menores de interfaz en formularios de autenticación antes de abordar la preparación del empaquetado para Google Play.

* ✅ **Principales funcionalidades cerradas recientemente:** Integración de la atribución visible de OpenStreetMap, selector de imagen (cámara/galería) en «Nuevo Mural», unificación del sistema de avisos del mapa mediante toast superior y corrección de la identidad Android en Gradle.
* 🧪 **Principales funcionalidades validadas:** Atribución de OSM y enlaces externos, flujo de imagen desde cámara y galería, onboarding de ubicación M3, recuperación OTP M2, control de contraseñas M1/DT4-01 y RLS en base de datos.
* ⏳ **Pendientes relevantes:** Autovalidate reactivo en campo de correo, firma de compilación release con Keystore propio, configuración de remitente con dominio propio en Resend y M4 redefinido («Cómo llegar» hacia app nativa de Google Maps).
* ⚠️ **Riesgos/deuda técnica relevantes:** Concentración de responsabilidades en MapaPrincipalPage (DT10), algoritmo de clustering con complejidad O(n²), colores morados hardcodeados (~53 referencias) y función de borrado en Storage limitada a estructuras planas (DT8).
* 🔜 **Siguiente objetivo técnico:** Implementar la validación reactiva (autovalidate) en el campo de correo electrónico en auth_page.dart (y recuperar_password_page.dart).

## 4. Stack Tecnológico

| Capa / Módulo | Tecnología | Versión | Fuente de Verificación |
| :--- | :--- | :--- | :--- |
| Lenguaje | Dart | 3.13.0 | pubspec.yaml (environment sdk) |
| Framework | Flutter | 3.47.0 | Documentación Técnica v16 / README.md |
| Plataforma | Android | Platform SDK 36 | Documentación Técnica v16 / README.md |
| Backend | Supabase | PostgreSQL 15+ / Auth / Storage | Código cliente (supabase_flutter) |
| Cliente Supabase | supabase_flutter | ^2.17.2 | pubspec.yaml |
| Motor de Mapas | flutter_map | ^8.3.1 | pubspec.yaml / Código fuente |
| Teselas de Mapa | OpenStreetMap | Standard Carto Tiles | mapa_principal_page.dart / ajustar_ubicacion_page.dart |
| Cálculo Geográfico | latlong2 | ^0.10.1 | pubspec.yaml / Código fuente |
| Geolocalización | geolocator | ^14.0.3 | pubspec.yaml / ubicacion_service.dart |
| Selector de Imagen | image_picker | ^1.2.3 | pubspec.yaml / mapa_principal_page.dart |
| Compresión | flutter_image_compress | ^2.5.1 | pubspec.yaml / mapa_principal_page.dart |
| Persistencia Local | shared_preferences | ^2.5.4 | pubspec.yaml (utilizado en M3) |
| Navegación Web | url_launcher | ^6.3.1 | pubspec.yaml / Código fuente |
| Variables Entorno | flutter_dotenv | ^6.0.1 | pubspec.yaml |
| Proveedor SMTP | Resend | Puerto 465 (TLS) | Configuración documentada (smtp.resend.com) |
| Identidad Android | Gradle (Kotlin DSL) | com.muralitoapp.app | android/app/build.gradle.kts |

## 5. Funcionalidades Actuales y Validación

| Funcionalidad | Estado | Evidencia / Prueba | Observaciones |
| :--- | :--- | :--- | :--- |
| Inicio / AuthGate | 🧪 VALIDADO | flutter run / Código | AuthGate actúa como passthrough transparente. |
| Modo espectador | 🧪 VALIDADO | Prueba 006 | Navegación y consulta de fichas sin requerir sesión. |
| Atribución OpenStreetMap | 🧪 VALIDADO | Pruebas manuales (Sesión 26/09) | Widget en bottomLeft con apertura externa funcional. |
| Sistema de Avisos (Toast) | 🧪 VALIDADO | Inspección visual en UI | Sustituye SnackBars flotantes por banner superior. |
| Registro de usuarios | 🧪 VALIDADO | Prueba 005 / M1-01…09 | Flujo con confirmación de correo. |
| Login / Logout | 🧪 VALIDADO | Pruebas funcionales | Logout retorna al mapa en modo espectador con toast. |
| Contraseña segura (M1) | 🧪 VALIDADO | Pruebas M1-01…09 | Checklist reactivo (8+, mayús, minús, num, símb). |
| Borde rojo contraseña (DT4-01) | 🧪 VALIDADO | 8 pruebas manuales | Limpia al tipear; evalúa al perder foco o enviar. |
| Recuperación OTP (M2) | 🧪 VALIDADO | Pruebas M2-01…08 | Código de 6 dígitos vía Resend con cooldown de 60 s. |
| Perfil + Trigger inicial | 🧪 VALIDADO | Prueba 010 / Prueba #015 | Trigger on_auth_user_created en PostgreSQL. |
| Avatar de usuario (DT2) | 🧪 VALIDADO | Pruebas DT2-01…05 | Rollback en Storage si falla actualización en BD. |
| Alta: Selección de foto | 🧪 VALIDADO | 4 pruebas manuales (Sesión 26/09) | Selector modal (cámara nativa o galería). |
| Compresión y rotación EXIF | 🧪 VALIDADO | Prueba 004 | flutter_image_compress con autoCorrectionAngle: true. |
| Onboarding ubicación (M3) | 🧪 VALIDADO | 4 pruebas manuales | Diálogo explicativo único persistido en shared_preferences. |
| Alta: Pin en mapa (M5/M10) | 🧪 VALIDADO | Pruebas M5-01…11 | Pin central estático; timeout de GPS de 10 s y ajuste manual. |
| Inmutabilidad de coordenadas | 🧪 VALIDADO | Inspección de código | Payload de _editarMural omite latitud y longitud. |
| Centrar mi ubicación (M6) | 🧪 VALIDADO (Parcial) | M6-01…05 y M6-07 PASS | Estados de GPS y acciones interactivas en toast superior. |
| M6-06 (Sin GPS ni última pos) | ❓ NO VERIFICADO | Caso no aislado | No reproducido en dispositivo físico. |
| Clustering geográfico (30 m) | 🧪 VALIDADO | Pruebas 003 y 006 | Zoom de contexto y lista desplegable en modales. |
| Ficha y «Subido por» (A3) | 🧪 VALIDADO | Prueba 013 | Muestra autor y avatar; fallback a «Muralista anónimo». |
| «Cómo llegar» | 🧪 VALIDADO | Pruebas funcionales | Abre OpenStreetMap externo vía url_launcher. |
| Edición de mural propio | 🧪 VALIDADO | Pruebas 007, 008, 009 | Reemplazo seguro de foto; borrado tras UPDATE exitoso. |
| Eliminación de mural propio | 🧪 VALIDADO | Pruebas 007 y 012 | DELETE en BD con purga posterior en Storage. |
| Políticas RLS en BD (DT3) | 🧪 VALIDADO | Prueba #015 | Delegación de autorización a auth.uid() en PostgreSQL. |
| Restricción listing Storage (B1) | 🧪 VALIDADO | Prueba B1 (data: []) | Listing anónimo bloqueado; URLs públicas operativas. |
| Sanitización nombres Storage | 🧪 VALIDADO | Prueba con "/" en título | Helper nombreArchivoDesdeTitulo unificado. |
| Estados de carga (DT13) | 🧪 VALIDADO | Pruebas DT13 | conDialogoCarga con control de cierre único. |
| Autovalidate en correo | ⚠️ PROBLEMA CONFIRMADO | Comprobado en código | Error permanece fijo al escribir tras fallo de envío. |
| Firma compilación Release | ⚠️ RIESGO BLOQUEANTE | build.gradle.kts | Configurado con signingConfigs.getByName("debug"). |

## 6. Pruebas y Evidencia Técnica

### 6.1 Comandos de consola verificados (Sesión 26/09/2026)

**flutter analyze:**
Ejecución final tras implementar la atribución de OSM, selector de imagen y toasts:
```
Analyzing muralito_app...
No issues found!
```
Resultado: 🧪 VALIDADO.

**flutter pub get:**
Resolvió dependencias tras purgar la carpeta efímera bloqueada en Windows (ios/Flutter/ephemeral):
```
Got dependencies!
exit code 0
```
Resultado: 🧪 VALIDADO.

### 6.2 Pruebas manuales validadas

**Atribución de OpenStreetMap:**
* Presencia del texto sin prefijos externos en mapa_principal_page.dart y ajustar_ubicacion_page.dart.
* Apertura confirmada de https://www.openstreetmap.org/copyright en navegador externo.

**Selector de imagen en «Nuevo Mural»:**
* Prueba 1 (Cancelación de modal): PASS — El usuario descarta el menú y permanece en el mapa.
* Prueba 2 (Cámara nativa): PASS — Apertura de cámara, captura y paso al mapa de pin.
* Prueba 3 (Cancelación en galería): PASS — Regreso limpio sin bloqueos.
* Prueba 4 (Flujo completo desde galería): PASS — Selección de archivo existente, compresión y publicación exitosa.

**Sistema de avisos del mapa:**
* Notificación verde superior ante guardado y edición.
* Alertas moradas con botones interactivos («Activar» / «Ajustes») ante estados de GPS.

### 6.3 Pruebas pendientes

* M6-06: Comportamiento ante ausencia total de GPS actual y última ubicación conocida.
* DT14: Suite automatizada de pruebas unitarias y de widgets (flutter test).

## 7. Supabase — Estado Real Comprobado
*(Nota técnica: Datos basados en el cliente Dart y pruebas funcionales; el SQL exacto no ha sido inspeccionado directamente en consola).*

### 7.1 Tablas

**public.murales**
* id: bigint, Primary Key, identity.
* created_at: timestamptz, NOT NULL, default now().
* titulo: text, NOT NULL.
* descripcion: text, Nullable.
* foto_url: text, NOT NULL.
* latitud: double precision, NOT NULL.
* longitud: double precision, NOT NULL.
* user_id: uuid, Nullable (en registros legados); hace referencia lógica a auth.users(id).

**public.perfiles**
* id: uuid, Primary Key, referencia a auth.users(id) con ON DELETE CASCADE.
* apodo: text, NOT NULL.
* avatar_url: text, Nullable.
* created_at: timestamptz, NOT NULL.

### 7.2 Triggers y Funciones

* Trigger: on_auth_user_created en tabla auth.users.
* Función: public.manejar_nuevo_usuario().
* Momento: AFTER INSERT.
* Seguridad: SECURITY DEFINER, con search_path = public.
* Acción: Inserta automáticamente un registro en public.perfiles utilizando el prefijo del correo o "Muralista" por defecto.

### 7.3 Políticas Row Level Security (RLS)

**Tabla murales:**
* SELECT: Pública (anon y authenticated).
* INSERT: Restringida a autenticados (auth.uid() = user_id).
* UPDATE: Restringida al propietario (auth.uid() = user_id).
* DELETE: Restringida al propietario (auth.uid() = user_id).

**Tabla perfiles:**
* SELECT: Pública.
* INSERT: Restringida a auth.uid() = id.
* UPDATE: Restringida a auth.uid() = id.
* DELETE: Denegada para clientes (sin política de cliente).

## 8. Storage

* Bucket: murales (almacenamiento plano en la raíz para fotografías de murales y avatares).

**Políticas operativas:**
* SELECT (Listing): Restringido a usuarios autenticados (B1 validado).
* SELECT (Acceso directo): URLs públicas directas operativas para renderizado.
* INSERT: Exclusivo para usuarios autenticados.
* DELETE: Restringido al propietario del archivo (owner = auth.uid()).

**Rollback y persistencia (DT1 / DT2):**
* Alta: Si el INSERT en PostgreSQL falla tras subir el archivo binario, se ejecuta un borrado inmediato del archivo huérfano en Storage.
* Edición: La imagen previa solo se purga de Storage tras confirmar que el UPDATE en PostgreSQL devolvió éxito.

**Sanitización de rutas:** Ambos flujos consumen nombreArchivoDesdeTitulo() en helpers.dart para neutralizar barras (/) y caracteres que generen subcarpetas implícitas.

**Deuda técnica DT8:** borrarFotoDeStorage() toma uri.pathSegments.last. No falla con la estructura plana actual, pero deberá adaptarse si se implementan subcarpetas por usuario o mural.

## 9. Autenticación y Seguridad

**Seguridad implementada y validada:**
* Política M1 con checklist en tiempo real.
* DT4-01 con FocusNode y ocultamiento dinámico del borde rojo al escribir en contraseña.
* M2 con recuperación vía OTP de 6 dígitos mediante Resend (cooldown de 60 s).
* Respuestas genéricas anti-enumeración ante registros con correo preexistente (DT4-02).
* Autorización real blindada por RLS en PostgreSQL.
* Inmutabilidad de coordenadas geográficas en base de datos.

**Riesgos y pendientes:**
* Autovalidate en correo: Falta comportamiento reactivo al corregir correos erróneos.
* Firma release: Falta Keystore de producción en Gradle.
* Dominio Resend: Remitente onboarding@resend.dev requiere reemplazo por dominio con SPF/DKIM verificado antes de abrir a evaluadores externos.

**Bloqueos externos:**
* M9 (Leaked Password Protection): Bloqueado; exige suscripción a Supabase Pro.

## 10. Arquitectura del Código

```
lib/
├── main.dart                       # Inicialización de dependencias, Supabase y passthrough AuthGate
├── models/
│   ├── mural.dart                  # Modelo de datos de mural, parseo fromMap y cruce con autor
│   └── perfil.dart                 # Modelo de perfil de usuario (toMap sin uso, código muerto)
├── pages/
│   ├── auth_page.dart              # Formulario de login y registro con checklist M1 y DT4-01
│   ├── mapa_principal_page.dart    # God-page: mapa OSM, clustering, toasts superiores, FABs y modales
│   └── recuperar_password_page.dart# Flujo OTP de recuperación de contraseña con cooldown
├── services/
│   ├── supabase_client.dart        # Instancia singleton del cliente Supabase
│   └── ubicacion_service.dart      # Servicio centralizado para GPS y resolución de permisos
├── utils/
│   └── helpers.dart                # Sanitización de Storage, diálogos de carga y manejo de errores
└── widgets/
    ├── ajustar_ubicacion_page.dart # Mapa de pin fijo para ajuste manual o por GPS (alta)
    ├── dialogo_carga.dart          # Spinner modal protegido contra cierres múltiples (DT13)
    ├── editar_mural_modal.dart     # Formulario modal de edición (título, descripción, foto)
    ├── editar_perfil_modal.dart    # Modal de gestión de apodo y avatar
    ├── formulario_mural_modal.dart # Formulario modal de alta (título y descripción)
    └── onboarding_ubicacion_dialog.dart # Diálogo explicativo M3 persistido en SharedPreferences
```

### 10.1 Flujos principales

* Inicio (main.dart): Carga .env, restringe caché de imágenes (40 MB / 80 slots), inicializa Supabase y abre MapaPrincipalPage vía AuthGate.
* Ubicación (ubicacion_service.dart): Centraliza la llamada a geolocator. Retorna un objeto estructurado ResultadoUbicacion con estados explícitos (listo, gpsApagado, permisoDenegado, permisoBloqueado, sinSenal). Es consumido tanto por el alta (M5) como por el centrado del mapa principal (M6).

**Alta de Mural:**
```
_iniciarFlujoNuevoMural()
  ↓
_seleccionarOrigenFoto() [Cámara o Galería]
  ↓
mostrarOnboardingUbicacionSiCorresponde() [M3, solo primera vez]
  ↓
AjustarUbicacionPage [Pin fijo, GPS 10 s, ajuste manual]
  ↓
FormularioMuralModal [Título y descripción]
  ↓
_subirMural() [Compresión → Storage → INSERT PostgreSQL → Rollback ante fallo]
  ↓
_mostrarAviso('Mural guardado correctamente.', tipo: _TipoAviso.exito)
```

## 11. Deuda Técnica y Riesgos

### ⚠️ Problemas confirmados
**Autovalidate en campo de correo electrónico:** En auth_page.dart, al fallar la validación tras pulsar enviar, el mensaje y borde rojo quedan congelados mientras el usuario corrige el texto. Debe replicarse el patrón de FocusNode y estado desacoplado implementado en DT4-01.

### ⚠️ Riesgos técnicos
* **Concentración de responsabilidades en MapaPrincipalPage (DT10):** El archivo actúa como god-page acumulando mapa, clustering, consultas de base de datos, listeners de sesión y disparadores de UI.
* **Ausencia de capa Repository (DT11 / DT12):** Llamadas directas al cliente Supabase incrustadas en widgets de interfaz.
* **Escalabilidad del clustering O(n²):** _agruparMuralesCercanos() ejecuta un doble bucle anidado sobre la lista en memoria con removeWhere. Con сотenas de murales provocará caídas de frames en el renderizado inicial y paneo.
* **Colores hardcodeados:** ~53 llamadas directas a Colors.deepPurple distribuidas en 8 archivos, con omisión de Theme.of(context).colorScheme.
* **Manejo de subrutas en Storage (DT8):** borrarFotoDeStorage() asume rutas planas (uri.pathSegments.last).

### 💡 Recomendaciones
* Abordar de forma prioritaria la validación del campo de correo electrónico por su bajo esfuerzo y alto impacto en la percepción de calidad del usuario.
* Generar el Keystore de producción de Android antes de iniciar cualquier fase de empaquetado para distribución.
* No realizar refactorizaciones mayores sobre MapaPrincipalPage ni sobre el algoritmo de clustering hasta contar con métricas de rendimiento objetivas.

## 12. Rendimiento y Escalabilidad

* Estrategia técnica aprobada: Medir → Identificar → Cambiar mínimamente → Volver a medir → Comprobar regresiones.
* Riesgo potencial: Algoritmo de clustering O(n²) en memoria.
* Mitigaciones operativas vigentes:
  * Restricción de zoom entre niveles 6.0 y 18.0 para limitar la recarga de teselas de OpenStreetMap.
  * Compresión previa de fotografías a máx. 1200x1200 px con calidad 80 antes de la transferencia de red.
  * Límites estrictos en la memoria caché de imágenes en main.dart (40 MB máximo).

## 13. Matriz de Deuda Técnica

| ID | Estado | Evidencia | Prioridad Sugerida | Observación |
| :--- | :--- | :--- | :--- | :--- |
| DT1 | 🧪 VALIDADO | Código _subirMural | Cerrado | Rollback en creación de mural. |
| DT2 | 🧪 VALIDADO | Código _guardarPerfil | Cerrado | Rollback en avatar. |
| DT3 | 🧪 VALIDADO | Prueba #015 | Cerrado | Auditoría RLS perfiles. |
| DT4 / DT13 | 🧪 VALIDADO | Código conDialogoCarga | Cerrado | Errores en español y loading seguro. |
| DT4-01 | 🧪 VALIDADO | 8 pruebas manuales | Cerrado | Borde rojo en contraseña. |
| Storage Sanitización | 🧪 VALIDADO | Helper compartido en código | Cerrado | Evita subcarpetas implícitas. |
| Identidad Android | 🧪 VALIDADO | build.gradle.kts | Cerrado | com.muralitoapp.app unificado. |
| Atribución OSM | 🧪 VALIDADO | UI y enlace externo | Cerrado | Cumplimiento legal de tiles. |
| Avisos UI mapa | 🧪 VALIDADO | Toast superior en UI | Cerrado | Elimina SnackBars a media pantalla. |
| Autovalidate correo | ⚠️ PROBLEMA | Código auth_page.dart | Alta (Inmediata) | Mismo patrón de DT4-01. |
| Firma Release | ⚠️ RIESGO | build.gradle.kts | Alta (Pre-release) | Bloqueante para Google Play. |
| DT8 | ⚠️ RIESGO | borrarFotoDeStorage | Media | Riesgo ante futuras subcarpetas. |
| DT10 | ⚠️ RIESGO | Código MapaPrincipalPage | No inmediata | God-page concentrada. |
| DT11 / DT12 | ⚠️ RIESGO | Código general | No inmediata | Ausencia de repositorios. |
| Colores hardcodeados | ⚠️ RIESGO | 8 archivos (~53 llamadas) | Media | Migrar a Theme.of(context). |
| DT14–DT18 | ⏳ PENDIENTE | Ausencia de flutter test | Media | Testing automatizado y métricas. |
| M9 | ⏳ BLOQUEADO | Supabase HIBP | Bloqueado | Requiere plan Pro. |

## 14. Backlog de Producto

**Necesario para v1:**
* Autovalidate en campo de correo electrónico (UX).
* Configuración de dominio propio en Resend (requisito para evaluadores externos).
* Firma de compilación release con Keystore propio (requisito para Play Store).

**Conveniente para v1:**
* M4 redefinido (botón «Cómo llegar» invocando la aplicación de Google Maps en lugar de OpenStreetMap web).
* Centralización gradual de la paleta de colores en el tema (ColorScheme).

**Puede esperar (Post-v1):**
* M17 — Sistema de borradores y reintento de subida offline (almacenamiento local persistente).
* A4 — Distinción entre usuario uploader y artista de la pintura.
* A1.4 — Historial de versiones y galería de fotos con ventana de 6 días.
* M7, M8, M11–M16 y mejoras de perfil B2–B7.

## 15. Siguiente Objetivo Técnico

* **ID:** Autovalidate en campo «Correo electrónico» (Extensión del patrón DT4-01).
* **Estado actual:** ⚠️ PROBLEMA CONFIRMADO (Menor, UX).
* **Justificación técnica:** Es una tarea de alcance acotado y bajo riesgo que completa la experiencia fluida en los formularios de autenticación iniciada con DT4-01. Actualmente, el campo de correo retiene el borde rojo y mensaje de error al escribir tras un intento fallido de envío, generando inconsistencia con el campo de contraseña contiguo.
* **Archivos a intervenir:**
  * lib/pages/auth_page.dart.
  * lib/pages/recuperar_password_page.dart (revisión de consistencia).
* **Qué NO debe modificarse:**
  * La lógica de validación de formato de correo (RegExp / validate).
  * El llamado a supabase.auth.signInWithPassword o signUp.
  * La respuesta anti-enumeración de usuarios (DT4-02).
* **Riesgos y efectos secundarios:** Mínimos. Se debe asegurar que el error sí se despliegue si el usuario deselecciona el campo dejando un correo inválido o pulsa el botón de envío.
* **Pruebas necesarias tras implementar:**
  * Ejecución de flutter analyze (debe permanecer en No issues found!).
  * Escribir correo inválido, pulsar enviar (se muestra error en rojo).
  * Presionar una tecla para corregir (el error y borde rojo deben desaparecer inmediatamente al escribir).
  * Quitar el foco dejando el correo incompleto (el error debe volver a mostrarse).

## 16. Estrategia de Release

**Fase 1: Requisitos antes de incorporar evaluadores externos (Closed Alpha)**
* Configuración y validación de dominio remitente propio en Resend (SPF/DKIM) para permitir entregabilidad a correos externos.
* Corrección de UX en campo de correo electrónico.

**Fase 2: Requisitos obligatorios antes de Google Play Store**
* Creación y resguardo del Keystore de producción (.jks).
* Configuración de signingConfigs.release en android/app/build.gradle.kts mediante key.properties excluido de Git.
* Declaración de privacidad y ficha de Seguridad de los Datos (Data Safety) en Google Play Console.
* Generación y validación de App Bundle (.aab) en dispositivo limpio.

**Fase 3: Post-Lanzamiento (v1.1+)**
* Implementación de borradores locales ante fallos de conexión (M17).
* M4 redefinido (navegación con Google Maps nativo).

## 17. Archivos Críticos para el Handoff

**Imprescindibles**
* lib/main.dart
* lib/pages/mapa_principal_page.dart
* lib/pages/auth_page.dart
* lib/pages/recuperar_password_page.dart
* lib/services/supabase_client.dart
* lib/services/ubicacion_service.dart
* lib/utils/helpers.dart
* lib/models/mural.dart
* lib/models/perfil.dart
* lib/widgets/ajustar_ubicacion_page.dart
* lib/widgets/onboarding_ubicacion_dialog.dart
* android/app/build.gradle.kts
* android/app/src/main/kotlin/com/muralitoapp/app/MainActivity.kt
* pubspec.yaml
* AndroidManifest.xml
* .env.example

**Importantes (Modales y Diálogos)**
* lib/widgets/formulario_mural_modal.dart
* lib/widgets/editar_mural_modal.dart
* lib/widgets/editar_perfil_modal.dart
* lib/widgets/dialogo_carga.dart

**No compartir / Ignorar en repositorios**
* Archivo .env real (contiene secretos y credenciales).
* Archivos key.properties o certificados .jks.
* Directorios generados: build/, .dart_tool/, android/.gradle/, ios/Flutter/ephemeral/.

## 18. Estado Global del Proyecto

| Área | Estado | Evidencia | Observación |
| :--- | :--- | :--- | :--- |
| MVP | 🧪 VALIDADO | Pruebas funcionales e históricas | Flujos de usuario principales cerrados. |
| Auth | 🧪 VALIDADO | M1, M2, DT4-01 PASS | Autovalidate en correo pendiente. |
| Perfil | 🧪 VALIDADO | Trigger en BD y DT2 avatar PASS | toMap() en Perfil sin uso en código. |
| Murales | 🧪 VALIDADO | Pruebas CRUD 001–012 PASS | Cámara y galería operativas. |
| Ubicación | 🧪 VALIDADO (Parcial) | M5 y M6 (salvo M6-06) PASS | Onboarding M3 validado duradero. |
| Mapa | 🧪 VALIDADO | Clustering 30 m y OSM PASS | Atribución legal incorporada. |
| Storage | 🧪 VALIDADO | DT1, DT2 y B1 PASS | Helper unificado; riesgo DT8 latente. |
| Seguridad | 🧪 VALIDADO | RLS auditadas; anti-enumeración | M9 bloqueado por plan Supabase. |
| Testing | ⏳ PENDIENTE | Predominio de pruebas manuales | Suite automatizada pendiente. |
| Arquitectura | ⚠️ RIESGO / DEUDA | Lectura de código (MapaPrincipalPage) | No se refactorizará a gran escala ahora. |
| Rendimiento | ⚠️ RIESGO | Doble bucle en clustering O(n²) | Requiere medición formal previa. |
| Documentación | 🧪 VALIDADO | Versiones v16 / v12 / README sincronizados | Discrepancia de namespace resuelta. |
| Release | ⏳ PENDIENTE | signingConfig en debug | Pendiente Keystore y dominio Resend. |

## 19. Decisiones Técnicas Vigentes

* Modo espectador público: El mapa, clusters y fichas son públicos y no requieren autenticación.
* Autorización delegada a RLS: La seguridad de los datos depende estrictamente de las políticas de PostgreSQL (auth.uid()), nunca de la interfaz.
* Inmutabilidad de coordenadas: Una vez publicado un mural, sus coordenadas no se pueden modificar desde la app.
* Identidad del uploader (user_id): Identifica a quien toma la fotografía y sube el registro, no necesariamente al autor del arte urbano (A4 pendiente).
* Rollback de Storage: Nunca purgar una foto previa sin confirmar el éxito en PostgreSQL; si la inserción falla, purgar el archivo huérfano recién subido.
* Proveedor SMTP: Se utiliza Resend a través de puerto 465.
* Servicio unificado de ubicación: ubicacion_service.dart centraliza la resolución de estados de GPS para alta (M5) y centrado (M6).
* Storage B1: Separación estricta entre el listing del bucket (restringido a autenticados) y la lectura directa por URL pública.
* Identidad Android: namespace y applicationId están unificados en com.muralitoapp.app.
* Atribución OSM: Se mantiene mediante widget limpio en bottomLeft sin el prefijo flutter_map | .
* M4 Redefinido: Mantener OpenStreetMap como motor de mapas interno; modificar únicamente el enlace «Cómo llegar» para invocar Google Maps nativo.
* Borradores locales (M17): Diferido formalmente para etapas posteriores a la v1 para resguardar el alcance inicial.

## 20. Handoff Prompt

```
Actúa como Tech Lead Senior de Muralito App.
Muralito App es una aplicación móvil Android desarrollada con Flutter y Dart para el mapeo y visualización colaborativa de murales urbanos sobre OpenStreetMap, con backend en Supabase (PostgreSQL, Auth y Storage).
ESTADO ACTUAL: MVP funcional avanzado.
Funcionalidades validadas: Modo espectador, autenticación completa con política M1 y feedback reactivo DT4-01, recuperación OTP M2 vía Resend, perfiles automáticos con trigger en PostgreSQL, CRUD de murales propios con rollback en Storage, selección de fotografía desde cámara o galería, onboarding de ubicación persistido M3, pin y GPS no bloqueante M5, centrado del mapa M6 (salvo M6-06), atribución obligatoria de OpenStreetMap en pantalla, sistema unificado de avisos superiores (toasts) y políticas RLS verificadas.
CONFIGURACIÓN ANDROID: namespace y applicationId alineados en "com.muralitoapp.app" en build.gradle.kts y MainActivity.kt.
STACK TÉCNICO: Flutter 3.47.0, Dart 3.13.0, Android SDK Platform 36, Supabase Flutter ^2.17.2, flutter_map ^8.3.1, latlong2 ^0.10.1, geolocator ^14.0.3, image_picker ^1.2.3, flutter_image_compress ^2.5.1, url_launcher ^6.3.1, shared_preferences ^2.5.4, flutter_dotenv ^6.0.1.
ARQUITECTURA:
- lib/pages/mapa_principal_page.dart concentra múltiples responsabilidades (DT10).
- lib/services/ubicacion_service.dart centraliza la resolución de estados de geolocalización para M5 y M6.
- lib/utils/helpers.dart maneja la sanitización de Storage y diálogos seguros.
DEUDA TÉCNICA Y PENDIENTES INMEDIATOS:
1. PROBLEMA CONFIRMADO: Autovalidate en campo de correo electrónico en auth_page.dart (el borde rojo y error persisten al escribir tras un intento fallido de envío). Debe aplicarse la misma solución de FocusNode/estado usada en DT4-01.
2. RIESGOS: Firma de release en Gradle sigue en debug (bloqueante para Play Store); remitente onboarding@resend.dev requiere dominio propio antes de testers externos; algoritmo de clustering O(n²) en memoria; ~53 referencias a Colors.deepPurple hardcodeadas.
3. BLOQUEADO: M9 (Leaked Passwords) requiere suscripción Supabase Pro.
REGLAS DE TRABAJO OBLIGATORIAS:
1. Analizar primero el código y documentación disponible antes de proponer cambios.
2. No asumir que HECHO significa VALIDADO; exigir evidencia real de pruebas.
3. No inventar tablas, SQL, RLS, Storage, archivos ni arquitectura.
4. No modificar código sin aprobación explícita del usuario.
5. Antes de modificar: explicar problema, presentar evidencia, indicar archivos afectados, proponer solución mínima, explicar riesgos y esperar autorización.
6. No realizar refactorizaciones no relacionadas con la tarea en curso.
7. Ejecutar "flutter analyze" después de cualquier modificación (debe dar cero errores).
8. Informar exactamente qué pruebas se ejecutaron y sus resultados.
9. Mantener el archivo .env real y secretos fuera del control de versiones y del chat.
10. Metodología obligatoria: CÓDIGO → ANÁLISIS → PRUEBAS → DOCUMENTACIÓN.
```

## 21. Checklist Final de Validación

* [x] Código actual analizado (mapa_principal_page.dart, ajustar_ubicacion_page.dart, build.gradle.kts).
* [x] Documentación más reciente analizada (Documentación Técnica v16, Flujos v12, Mejoras v16, README.md).
* [x] Stack tecnológico y versiones documentados con sus fuentes.
* [x] Funcionalidades implementadas diferenciadas de las validadas.
* [x] Pruebas reales documentadas y separadas de casos pendientes.
* [x] Problemas confirmados separados de riesgos y deudas técnicas.
* [x] Supabase documentado con mención explícita a la ausencia de acceso directo al SQL.
* [x] Distinción entre URL pública directa y listing anónimo en Storage (B1).
* [x] Riesgo DT8 (subcarpetas de Storage) documentado como deuda y no como bug.
* [x] Arquitectura de lib/ y responsabilidad de ubicacion_service.dart detalladas.
* [x] Discrepancia previa de namespace documentada y formalmente resuelta.
* [x] Escenario M6-06 conservado como NO VERIFICADO.
* [x] M9 clasificado como BLOQUEADO por limitación del plan externo.
* [x] Siguiente objetivo técnico identificado y planificado (Autovalidate en campo de correo).
* [x] Archivo .env real excluido de cualquier reporte.
* [x] Handoff Prompt listo para copiar incluido al final del informe.