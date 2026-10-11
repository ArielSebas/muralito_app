# Handoff Técnico — Muralito App

**Rol:** Tech Lead Senior
**Fecha de corte:** 27/09/2026
**Plataforma:** Android / Flutter
**Versión de referencia documental:** Documentación Técnica v18, Flujos Funcionales v15, Mejoras v18, README.md, Handoff Técnico v006
**Handoff previo:** Handoff Técnico v005 (21/09/2026)

## 0. Regla Principal — Fuente de Verdad

Este informe contrasta el código fuente analizado (mapa_principal_page.dart, auth_page.dart, recuperar_password_page.dart, helpers.dart, ajustar_ubicacion_page.dart, build.gradle.kts, settings.gradle.kts, gradle.properties, key.properties) con los resultados de los comandos ejecutados en terminal (`flutter analyze`, `flutter run`, `flutter build apk --release`, `flutter build appbundle --release`, `apksigner verify`) y las especificaciones consolidadas en la Documentación Técnica v18 y los Flujos Funcionales v15.

**Acceso a Supabase:** No se dispone de acceso directo a la consola ni a los archivos de migración .sql de Supabase. La estructura de tablas, triggers y políticas RLS se sustenta en la documentación técnica y en las pruebas de integración funcionales registradas, no en evidencia directa de archivo SQL en esta sesión.

**Nota de transición v006 → v007:** El Handoff v006 no se conserva íntegro. El presente informe (v007) recupera el estado verificable al 27/09/2026 y se apoya en el v005 (21/09/2026) como antecedente formal. No se reconstruye el contenido del v006.

## 1. Clasificación Obligatoria de Estados

* ✅ **HECHO / IMPLEMENTADO:** Funcionalidad o configuración presente en el código.
* 🧪 **VALIDADO:** Confirmado mediante evidencia de prueba (análisis estático, pruebas funcionales o logs de terminal).
* 🔜 **SIGUIENTE OBJETIVO:** Tarea técnica priorizada pendiente de ejecución.
* ⏳ **PENDIENTE:** Trabajo aún no implementado.
* ⚠️ **PROBLEMA CONFIRMADO:** Falla comprobada mediante código o reproducción.
* ⚠️ **RIESGO / DEUDA TÉCNICA:** Limitación técnica, deuda de diseño o riesgo a escala.
* 💡 **RECOMENDACIÓN:** Sugerencia técnica sujeta a validación.
* ❓ **NO VERIFICADO:** Sin evidencia concluyente para clasificarlo como validado o descartado.
* ❓ **NO DOCUMENTADO:** Requisito externo (p. ej., Play Store) que no aparece ni en el archivo recibido ni en la documentación vigente.

## 2. Control de Versiones de Documentación y Discrepancias

### 2.1 Documentos vigentes analizados

* Documentación Técnica v18 (27/09/2026).
* Flujos Funcionales v15 (27/09/2026).
* Mejoras v18 (27/09/2026).
* README.md (26/09/2026).
* Handoff Técnico v005 (21/09/2026).
* Handoff Técnico v006 (no íntegro; usado solo como antecedente).

### 2.2 Discrepancias previas y estado de resolución

**Identidad Android (resuelta en v005/v16):**
* La documentación v15 afirmaba erróneamente que namespace y MainActivity.kt permanecían en com.example.muralito_app mientras que el código real ya utilizaba com.muralitoapp.app.
* Verificación: `android/app/build.gradle.kts` confirma `namespace = "com.muralitoapp.app"` y `applicationId = "com.muralitoapp.app"`.
* Resolución: documentada en v005 §2.2 y mantenida en v18.

**AGP y JDK (resuelta en v18):**
* Previo: `AGP 9.1.0` incompatible con `Flutter 3.47.0` + `JDK 17`.
* Resolución: AGP ajustado a `8.13.0`; `org.gradle.java.home` apunta a Temurin 17.0.20.1 (`C:/Program Files/Eclipse Adoptium/jdk-17.0.20.101-hotspot`).
* Evidencia: `flutter build apk --release`: `√ Built build\app\outputs\flutter-apk\app-release.apk (53.3MB)`.

**`key.properties` (resuelta en v18):**
* Encoding: UTF-8 sin BOM.
* Ruta del keystore: relativa (`app/muralito-release-key.jks` desde `android/`).

**Firma Release (resuelta en v18):**
* Previo: `release` → `signingConfigs.getByName("debug")` (v005 §11, v006, v17).
* Resolución: `signingConfigs.release` configurado con credenciales desde `key.properties`; keystore RSA 2048, validez 10 000 días, alias `muralito`; CN=Muralito, OU=Muralito, O=Muralito, L=Quito, ST=Pichincha, C=EC.
* Validación: APK release instalado en Infinix X6886; firma V2/V3 verificada con `apksigner verify`.

**Discrepancia nueva — hallazgo `ñ`/`Ñ` (abierta):**
* Reporte: durante validación física del APK release, un título con `ñ`/`Ñ` ("pruebiññaañaña") no se pudo guardar; sin `ñ` no falló.
* Estado: ❓ REPORTADO — NO REPRODUCIDO. Pendiente auditoría controlada.
* Documentado en: Documentación Técnica v18 §0, §1; Flujos Funcionales v15 §19.

## 3. Resumen Ejecutivo

Muralito App es una aplicación móvil desarrollada en Flutter para Android cuyo propósito es el mapeo colaborativo y visualización de murales urbanos sobre OpenStreetMap, con backend en Supabase (PostgreSQL, Auth y Storage). El proyecto se encuentra en estado de MVP funcional avanzado con APK release firmado y validado en dispositivo físico (Infinix X6886), por lo que la barrera técnica de publicación ha quedado superada. El siguiente foco es de cumplimiento editorial en Google Play (Data Safety) y de robustez de producto (M17 — borradores offline).

* ✅ **Cierres recientes relevantes:** DT4 (autovalidate reactivo del email + Timer 3s) en `auth_page.dart` y `recuperar_password_page.dart`; M4 (Cómo llegar → Google Maps nativo); E6 (Atribución OSM con visibilidad mejorada, opcional); DT-Firma-Release (Keystore, signingConfig, APK/AAB release, `apksigner verify`).
* 🧪 **Funcionalidades validadas en físico (Infinix X6886):** Login, mapa, clustering, CRUD, GPS, navegación a Google Maps y atribución OSM.
* ⏳ **Pendientes relevantes:** Data Safety (requisito editorial de Google Play), M17 (borradores offline ante fallo de red), configuración de remitente con dominio propio en Resend (SPF/DKIM), auditoría controlada del hallazgo `ñ`/`Ñ`.
* ⚠️ **Riesgos/deuda técnica relevantes:** Concentración de responsabilidades en `mapa_principal_page.dart` (DT10), algoritmo de clustering con complejidad O(n²), colores morados hardcodeados (~53 referencias en 8 archivos), función de borrado en Storage limitada a estructuras planas (DT8), ausencia de capa Repository (DT11/DT12), falta de suite automatizada `flutter test` (DT14).
* 🔜 **Siguiente objetivo técnico recomendado:** Data Safety (Play Store) — requisito editorial previo a publicación. Alternativa de producto: M17 (borradores offline).

## 4. Stack Tecnológico

| Capa / Módulo | Tecnología | Versión | Fuente de Verificación |
| :--- | :--- | :--- | :--- |
| Lenguaje | Dart | 3.13.0 | `pubspec.yaml` (environment sdk) |
| Framework | Flutter | 3.47.0 | Documentación Técnica v18 / README.md |
| Plataforma | Android | Platform SDK 36 | Documentación Técnica v18 / README.md |
| Android Gradle Plugin | AGP | 8.13.0 | `android/settings.gradle.kts` |
| JDK del proyecto | Temurin | 17.0.20.1 | `android/gradle.properties` (`org.gradle.java.home`) |
| Backend | Supabase | PostgreSQL 15+ / Auth / Storage | Código cliente (`supabase_flutter`) |
| Cliente Supabase | supabase_flutter | ^2.17.2 | `pubspec.yaml` |
| Motor de Mapas | flutter_map | ^8.3.1 | `pubspec.yaml` / Código fuente |
| Teselas de Mapa | OpenStreetMap | Standard tiles (`openstreetmap.org`) | `mapa_principal_page.dart` / `ajustar_ubicacion_page.dart` |
| Cálculo Geográfico | latlong2 | ^0.10.1 | `pubspec.yaml` / Código fuente |
| Geolocalización | geolocator | ^14.0.3 | `pubspec.yaml` / `ubicacion_service.dart` |
| Selector de Imagen | image_picker | ^1.2.3 | `pubspec.yaml` / `mapa_principal_page.dart` |
| Compresión | flutter_image_compress | ^2.5.1 | `pubspec.yaml` / `mapa_principal_page.dart` |
| Persistencia Local | shared_preferences | ^2.5.4 | `pubspec.yaml` (utilizado en M3) |
| Navegación Web | url_launcher | ^6.3.1 | `pubspec.yaml` / Código fuente |
| Variables Entorno | flutter_dotenv | ^6.0.1 | `pubspec.yaml` |
| Proveedor SMTP | Resend | Puerto 465 (TLS) | Configuración documentada (`smtp.resend.com`) |
| Identidad Android | Gradle (Kotlin DSL) | com.muralitoapp.app | `android/app/build.gradle.kts` |
| Firma Release | Keystore + signingConfig.release | RSA 2048, alias `muralito` | `android/app/muralito-release-key.jks` + `android/key.properties` |

## 5. Funcionalidades Actuales y Validación

| Funcionalidad | Estado | Evidencia / Prueba | Observaciones |
| :--- | :--- | :--- | :--- |
| Inicio / AuthGate | 🧪 VALIDADO | `flutter run` / Código | AuthGate actúa como passthrough transparente. |
| Modo espectador | 🧪 VALIDADO | Pruebas manuales históricas | Navegación y consulta de fichas sin requerir sesión. |
| Atribución OpenStreetMap | 🧪 VALIDADO | E6 — pruebas físicas | Widget en `bottomLeft` con apertura externa funcional (`© Colaboradores de OpenStreetMap`; click → `https://www.openstreetmap.org/copyright`). |
| Sistema de Avisos (Toast) | 🧪 VALIDADO | Inspección visual en UI | Sustituye SnackBars flotantes por banner superior (`_AvisoUI` con `exito`/`error`/`info` + acción GPS). |
| Registro de usuarios | 🧪 VALIDADO | DT4 / M1-01…09 | Flujo con confirmación de correo; DT4 aplicado. |
| Login / Logout | 🧪 VALIDADO | DT4 / pruebas funcionales | Logout retorna al mapa en modo espectador con toast. |
| Contraseña segura (M1) | 🧪 VALIDADO | Pruebas M1-01…09 | Checklist reactivo (8+, mayús, minús, num, símb). |
| Borde rojo contraseña (DT4-01) | 🧪 VALIDADO | 8 pruebas manuales | Limpia al tipear; evalúa al perder foco o enviar. |
| DT4 email (autovalidate + Timer 3s) | ✅ HECHO / 🧪 VALIDADO | `#1`–`#13 PASS` | `auth_page.dart` + `recuperar_password_page.dart` (`addListener`, `Timer(3s)`, `dispose`). |
| Recuperación OTP (M2) | 🧪 VALIDADO | Pruebas M2-01…08 + DT4 | Código de 6 dígitos vía Resend con cooldown de 60 s; email con autovalidate. |
| Perfil + Trigger inicial | 🧪 VALIDADO | Prueba 010 / Prueba #015 | Trigger `on_auth_user_created` en PostgreSQL; función `manejar_nuevo_usuario`. |
| Avatar de usuario (DT2) | 🧪 VALIDADO | Pruebas DT2-01…05 | Rollback en Storage si falla actualización en BD. |
| Alta: Selección de foto | 🧪 VALIDADO | 4 pruebas manuales (Sesión 26/09) | Selector modal (cámara nativa o galería). |
| Compresión y rotación EXIF | 🧪 VALIDADO | Prueba 004 | `flutter_image_compress` con `autoCorrectionAngle: true`. |
| Onboarding ubicación (M3) | 🧪 VALIDADO | 4 pruebas manuales | Diálogo explicativo único persistido en `shared_preferences`. |
| Alta: Pin en mapa (M5) | 🧪 VALIDADO | Pruebas M5-01…11 | Pin central estático; timeout de GPS de 10 s y ajuste manual. |
| Inmutabilidad de coordenadas | 🧪 VALIDADO | Inspección de código | Payload de `_editarMural` omite latitud y longitud. |
| Centrar mi ubicación (M6) | 🧪 VALIDADO (Parcial) | M6-01…05 y M6-07 PASS | Estados de GPS y acciones interactivas en toast superior. |
| M6-06 (Sin GPS ni última pos) | ❓ NO VERIFICADO | Caso no aislado | No reproducido en dispositivo físico. |
| Clustering geográfico (30 m) | 🧪 VALIDADO | Pruebas 003 y 006 | Zoom de contexto y lista desplegable en modales. |
| Ficha y «Subido por» (A3) | 🧪 VALIDADO | Prueba 013 | Muestra autor y avatar; fallback a «Muralista anónimo». |
| «Cómo llegar» (M4) | ✅ HECHO / 🧪 VALIDADO | A–E PASS + prueba física Infinix X6886 | `_abrirComoLlegar` → `https://www.google.com/maps/dir/?api=1&destination=$lat,$lng` con `LaunchMode.externalApplication`. |
| Edición de mural propio | 🧪 VALIDADO | Pruebas 007, 008, 009 | Reemplazo seguro de foto; borrado tras UPDATE exitoso. |
| Eliminación de mural propio | 🧪 VALIDADO | Pruebas 007 y 012 | DELETE en BD con purga posterior en Storage. |
| Políticas RLS en BD (DT3) | 🧪 VALIDADO (funcional) | Prueba #015 | Delegación de autorización a `auth.uid()` en PostgreSQL. ❓ SQL (`CREATE POLICY`) no inspeccionado en esta sesión. |
| Restricción listing Storage (B1) | 🧪 VALIDADO | Prueba B1 (`data: []`) | Listing anónimo bloqueado; URLs públicas operativas. |
| Sanitización nombres Storage | 🧪 VALIDADO (con hallazgo) | Prueba con "/" en título | Helper `nombreArchivoDesdeTitulo` unificado. ❓ Hallazgo `ñ`/`Ñ` reportado, no reproducido. |
| Estados de carga (DT13) | 🧪 VALIDADO | Pruebas DT13 | `conDialogoCarga` con control de cierre único. |
| Firma compilación Release | ✅ HECHO / 🧪 VALIDADO | `apksigner verify` + Infinix X6886 | `signingConfigs.release` con keystore propio; firma V2/V3 verificada. APK y AAB firmados. |
| `Data Safety` (Play Store) | ❓ NO DOCUMENTADO | Requisito editorial Play Console | No figura en archivo recibido ni en Mejoras v18. |
| `M17` Borradores offline | ⏳ PENDIENTE | Mejoras v18 §20 | Sugerencia detectada durante validación física. |
| `M9` Leaked Passwords (HIBP) | ❓ BLOQUEADO | Plan Supabase Pro requerido | No implementado. |

## 6. Pruebas y Evidencia Técnica

### 6.1 Comandos de consola verificados (Sesión 27/09/2026)

**flutter analyze:**
```
Analyzing muralito_app...
No issues found!
```
Resultado: 🧪 VALIDADO.

**flutter pub get:**
Resolvió dependencias sin bloqueos reportados.
```
Got dependencies!
exit code 0
```
Resultado: 🧪 VALIDADO.

**flutter build apk --release:**
```
√ Built build\app\outputs\flutter-apk\app-release.apk (53.3MB)
```
Resultado: 🧪 VALIDADO.

**flutter build appbundle --release:**
```
√ Built build\app\outputs\bundle\release\app-release.aab (52.2MB)
```
Resultado: 🧪 VALIDADO.

**apksigner verify --print-certs (APK release):**
```
Verified using v2 scheme (APK Signature Scheme v2): true
Verified using v3 scheme (APK Signature Scheme v3): true
Signer #1 certificate DN: CN=Muralito, OU=Muralito, O=Muralito, L=Quito, ST=Pichincha, C=EC
```
Resultado: 🧪 VALIDADO.

### 6.2 Pruebas manuales validadas

**DT4 (auth — `#1`–`#13`):**
* `#1` `Siguiente` visible — PASS.
* `#2` Timer 3s — PASS.
* `#3` escribir limpia error — PASS.
* `#4` vacío + botón bloquea + Timer — PASS.
* `#5` Timer tras vacío — PASS.
* `#6` password DT4-01 sin regresión — PASS.
* `#7` login funcional — PASS.
* `#8` recuperación `Siguiente` paso 1 — PASS.
* `#9` Timer 3s — PASS.
* `#10` vacío + Enviar código bloquea + Timer — PASS.
* `#11`–`#13` OTP + nueva contraseña + checklist — PASS.

**M4 (`A`–`E`):**
* `A` botón `Cómo llegar` existe — PASS.
* `B` mapa OSM funciona — PASS.
* `C` Google Maps abre — PASS.
* `D` Atribución intacta — PASS.
* `E` regresión clustering/ficha/FAB/Avisos/Auth — PASS.

**E6 (Atribución OSM):**
* `D PASS` funcional; estilo opcional aplicado (`fontSize 13`, `w600`, `padding 8,4`, `fondo 0xDDF5F5F5`); click a `copyright` operativo.

**DT-Firma-Release (físico Infinix X6886):**
* Instalación de APK release: OK.
* Login, mapa, clustering, CRUD, GPS, Google Maps, Atribución OSM: todos funcionales.
* Firma V2/V3 verificada con `apksigner`.

**Regresión general:**
* `#14`–`#16` PASS; build limpio posterior a Firma Release.

### 6.3 Pruebas pendientes

* M6-06: Comportamiento ante ausencia total de GPS actual y última ubicación conocida.
* DT14: Suite automatizada de pruebas unitarias y de widgets (`flutter test`).
* Hallazgo `ñ`/`Ñ`: reproducción controlada antes de afirmar bug.

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
* user_id: uuid, Nullable (en registros legados); hace referencia lógica a `auth.users(id)`.

**public.perfiles**
* id: uuid, Primary Key, referencia a `auth.users(id)` con ON DELETE CASCADE.
* apodo: text, NOT NULL.
* avatar_url: text, Nullable.
* created_at: timestamptz, NOT NULL.

### 7.2 Triggers y Funciones

* Trigger: `on_auth_user_created` en tabla `auth.users`.
* Función: `public.manejar_nuevo_usuario()`.
* Momento: AFTER INSERT.
* Seguridad: SECURITY DEFINER, con `search_path = public`.
* Acción: Inserta automáticamente un registro en `public.perfiles` utilizando el prefijo del correo o "Muralista" por defecto.

### 7.3 Políticas Row Level Security (RLS)

**Tabla murales:**
* SELECT: Pública (anon y authenticated).
* INSERT: Restringida a autenticados (`auth.uid() = user_id`).
* UPDATE: Restringida al propietario (`auth.uid() = user_id`); payload omite `lat`/`lng`.
* DELETE: Restringida al propietario (`auth.uid() = user_id`).

**Tabla perfiles:**
* SELECT: Pública.
* INSERT: Restringida a `auth.uid() = id`.
* UPDATE: Restringida a `auth.uid() = id`.
* DELETE: Denegada para clientes (sin política de cliente).

❓ Las sentencias `CREATE POLICY` exactas no han sido inspeccionadas en esta sesión (archivo .sql no disponible).

## 8. Storage

* Bucket: `murales` (almacenamiento plano en la raíz para fotografías de murales y avatares).
* Keystore y `key.properties`: externos al bucket; firmados en compilación release; backup externo confirmado.

**Políticas operativas:**
* SELECT (Listing): Restringido a usuarios autenticados (B1 validado).
* SELECT (Acceso directo): URLs públicas directas operativas para renderizado.
* INSERT: Exclusivo para usuarios autenticados.
* DELETE: Restringido al propietario del archivo (`owner = auth.uid()`).

**Rollback y persistencia (DT1 / DT2):**
* Alta: Si el INSERT en PostgreSQL falla tras subir el archivo binario, se ejecuta un borrado inmediato del archivo huérfano en Storage.
* Edición: La imagen previa solo se purga de Storage tras confirmar que el UPDATE en PostgreSQL devolvió éxito.

**Sanitización de rutas:** Ambos flujos consumen `nombreArchivoDesdeTitulo()` en `helpers.dart` para neutralizar barras (`/`) y caracteres que generen subcarpetas implícitas. El RegExp documentado acepta explícitamente `ñ`/`Ñ` (`[^a-zA-Z0-9áéíóúÁÉÍÓÚñÑ_-]` → `_`).

**Hallazgo `ñ`/`Ñ`:** durante validación física del APK release se reportó un fallo al guardar un mural con título conteniendo `ñ`/`Ñ` ("pruebiññaañaña"), mientras que sin `ñ` no falló. ❓ NO REPRODUCIDO. Posibles causas a investigar (no asumir): codificación real de `nombreArchivoDesdeTitulo()`, validación del formulario en `formulario_mural_modal.dart`, codificación en Storage/Supabase, coincidencia con error de red. Requiere reproducción controlada antes de afirmar bug.

**Deuda técnica DT8:** `borrarFotoDeStorage()` toma `uri.pathSegments.last`. No falla con la estructura plana actual, pero deberá adaptarse si se implementan subcarpetas por usuario o mural.

## 9. Autenticación y Seguridad

**Seguridad implementada y validada:**
* Política M1 con checklist en tiempo real.
* DT4-01 con `FocusNode` y ocultamiento dinámico del borde rojo al escribir en contraseña.
* DT4 con autovalidate reactivo + Timer 3s en email (auth + recertación).
* M2 con recuperación vía OTP de 6 dígitos mediante Resend (cooldown de 60 s).
* Respuestas genéricas anti-enumeración ante registros con correo preexistente (DT4-02).
* Autorización real blindada por RLS en PostgreSQL.
* Inmutabilidad de coordenadas geográficas en base de datos.

**Firma Release y APK/AAB firmados:**
* `signingConfigs.release` operativo; APK/AAB compilados; firma V2/V3 verificada; backup externo del `.jks` confirmado; contraseña final cambiada tras la sesión (la inicial se expuso durante troubleshooting).

**Riesgos y pendientes:**
* `Data Safety` (Play Store): ❓ NO DOCUMENTADO.
* Dominio Resend: remitente `onboarding@resend.dev` requiere reemplazo por dominio con SPF/DKIM verificado antes de abrir a evaluadores externos.

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
│   ├── auth_page.dart              # Login y registro con checklist M1, DT4-01 y DT4
│   ├── mapa_principal_page.dart    # God-page: mapa OSM, clustering, toasts superiores, FABs y modales
│   └── recuperar_password_page.dart# Flujo OTP de recuperación de contraseña con DT4
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

```
android/
├── app/
│   ├── build.gradle.kts            # signingConfigs.release; namespace + applicationId com.muralitoapp.app
│   ├── muralito-release-key.jks    # Keystore RSA 2048 (alias muralito, 10 000 días)
│   └── src/main/kotlin/com/muralitoapp/app/MainActivity.kt
├── key.properties                  # Credenciales del keystore (UTF-8 sin BOM; excluido de Git)
├── settings.gradle.kts             # AGP 8.13.0
└── gradle.properties               # org.gradle.java.home = Temurin 17.0.20.1; android.newDsl=true
```

### 10.1 Flujos principales

* Inicio (`main.dart`): Carga `.env`, restringe caché de imágenes (40 MB / 80 slots), inicializa Supabase y abre `MapaPrincipalPage` vía `AuthGate`.
* Ubicación (`ubicacion_service.dart`): Centraliza la llamada a `geolocator`. Retorna un objeto estructurado `ResultadoUbicacion` con estados explícitos (`listo`, `gpsApagado`, `permisoDenegado`, `permisoBloqueado`, `sinSenal`). Es consumido tanto por el alta (M5) como por el centrado del mapa principal (M6).
* DT4 email (auth + recertación): `_emailFocusNode.addListener` (`_alCambiarFocoEmail`); `onChanged` limpia; `onTapOutside` muestra error; `Timer(3s)` oculta error; `dispose` cancela Timer, remueve listener y dispone el nodo.
* DT4-01 password: `_passFocusNode.addListener`; `_requisitosContrasena` operativo; `_ocultarErrorPasswordAlEscribir` activo.
* M4 (Cómo llegar): `_abrirComoLlegar(lat, lng)` → `https://www.google.com/maps/dir/?api=1&destination=$lat,$lng` con `LaunchMode.externalApplication`. Manejo de error con `_mostrarAviso(...)` tipo `error`.
* E6 (Atribución): `Align(bottomLeft)` + `InkWell` a `copyright`; `fontSize 13`, `w600`, `padding 8,4`, fondo `0xDDF5F5F5`. Sin prefijo `flutter_map |`.
* Firma Release: Gradlee lee `key.properties`; carga credenciales del `.jks`; firma con `signingConfigs.release`. Verificable con `apksigner verify --print-certs`.

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
_subirMural() [Compresión → nombreArchivoDesdeTitulo → Storage → INSERT PostgreSQL → Rollback ante fallo]
  ↓
_mostrarAviso('Mural guardado correctamente.', tipo: _TipoAviso.exito)
```

## 11. Deuda Técnica y Riesgos

### ⚠️ Problemas confirmados
* **Hallazgo `ñ`/`Ñ`:** ❓ Reportado durante validación física del APK release (título "pruebiññaañaña" no se pudo guardar; sin `ñ` no falló). NO REPRODUCIDO. Requiere auditoría controlada: revisar `helpers.dart::nombreArchivoDesdeTitulo`, `_subirMural()` y validación en `formulario_mural_modal.dart`.

### ⚠️ Riesgos técnicos
* **Concentración de responsabilidades en `MapaPrincipalPage` (DT10):** El archivo actúa como god-page acumulando mapa, clustering, consultas de base de datos, listeners de sesión y disparadores de UI.
* **Ausencia de capa Repository (DT11 / DT12):** Llamadas directas al cliente Supabase incrustadas en widgets de interfaz.
* **Escalabilidad del clustering O(n²):** `_agruparMuralesCercanos()` ejecuta un doble bucle anidado sobre la lista en memoria con `removeWhere`. Con cientos de murales provocará caídas de frames en el renderizado inicial y paneo.
* **Colores hardcodeados:** ~53 llamadas directas a `Colors.deepPurple` distribuidas en 8 archivos, con omisión de `Theme.of(context).colorScheme`.
* **Manejo de subrutas en Storage (DT8):** `borrarFotoDeStorage()` asume rutas planas (`uri.pathSegments.last`).

### 💡 Recomendaciones
* Abordar de forma prioritaria la auditoría del hallazgo `ñ`/`Ñ` (reproducción controlada) por su bajo esfuerzo y alto impacto en la confianza del modelo de sanitización.
* Completar `Data Safety` antes de cualquier subida a Google Play (requisito editorial de la consola).
* No realizar refactorizaciones mayores sobre `MapaPrincipalPage` ni sobre el algoritmo de clustering hasta contar con métricas de rendimiento objetivas.

## 12. Rendimiento y Escalabilidad

* Estrategia técnica aprobada: Medir → Identificar → Cambiar mínimamente → Volver a medir → Comprobar regresiones.
* Riesgo potencial: Algoritmo de clustering O(n²) en memoria.
* Mitigaciones operativas vigentes:
  * Restricción de zoom entre niveles 6.0 y 18.0 para limitar la recarga de teselas de OpenStreetMap.
  * Compresión previa de fotografías a máx. 1200x1200 px con calidad 80 antes de la transferencia de red.
  * Límites estrictos en la memoria caché de imágenes en `main.dart` (40 MB máximo).

## 13. Matriz de Deuda Técnica

| ID | Estado | Evidencia | Prioridad Sugerida | Observación |
| :--- | :--- | :--- | :--- | :--- |
| DT1 | 🧪 VALIDADO | Código `_subirMural` | Cerrado | Rollback en creación de mural. |
| DT2 | 🧪 VALIDADO | Código `_guardarPerfil` | Cerrado | Rollback en avatar. |
| DT3 | 🧪 VALIDADO | Prueba #015 | Cerrado | Auditoría RLS perfiles. |
| DT4 / DT13 | 🧪 VALIDADO | Código `conDialogoCarga` | Cerrado | Errores en español y loading seguro. |
| DT4 (email autovalidate + Timer) | 🧪 VALIDADO | `#1`–`#13 PASS` | Cerrado | `auth_page.dart` + `recuperar_password_page.dart`. |
| DT4-01 | 🧪 VALIDADO | 8 pruebas manuales | Cerrado | Borde rojo en contraseña. |
| Storage Sanitización | 🧪 VALIDADO (con hallazgo) | Helper compartido | Cerrado parcial | Hallazgo `ñ`/`Ñ` pendiente. |
| Identidad Android | 🧪 VALIDADO | `build.gradle.kts` | Cerrado | `com.muralitoapp.app` unificado. |
| Atribución OSM | 🧪 VALIDADO | UI y enlace externo | Cerrado | Cumplimiento legal de tiles. |
| Avisos UI mapa | 🧪 VALIDADO | Toast superior en UI | Cerrado | `_AvisoUI` operativo. |
| M4 (Cómo llegar) | 🧪 VALIDADO | A–E PASS + físico | Cerrado | URI Google Maps nativo. |
| E6 (Atribución visibilidad) | 🧪 VALIDADO | D PASS | Cerrado | `fontSize 13`, `w600`, `padding 8,4`, fondo `0xDDF5F5F5`. |
| DT-Firma-Release | 🧪 VALIDADO | `apksigner verify` + Infinix X6886 | Cerrado | Keystore + signingConfig + APK/AAB firmados. |
| Hallazgo `ñ`/`Ñ` | ❓ Reportado — NO REPRODUCIDO | Validación física APK release | Alta (auditoría controlada) | Revisar `nombreArchivoDesdeTitulo`, `_subirMural`, `formulario_mural_modal`. |
| `Data Safety` (Play Store) | ❓ NO DOCUMENTADO | Requisito editorial Google Play | Alta (previo a publicación) | Investigar recopilación, almacenamiento, retención y compartición. |
| M17 (Borradores offline) | ⏳ PENDIENTE | Mejoras v18 §20 | Media (producto) | Persistencia local + reintento. |
| Firma Release | ✅ CERRADO | v18 | Cerrado | Backup externo confirmado. |
| DT8 | ⚠️ RIESGO | `borrarFotoDeStorage` | Media | Riesgo ante futuras subcarpetas. |
| DT10 | ⚠️ RIESGO | Código `MapaPrincipalPage` | No inmediata | God-page concentrada. |
| DT11 / DT12 | ⚠️ RIESGO | Código general | No inmediata | Ausencia de repositorios. |
| Colores hardcodeados | ⚠️ RIESGO | 8 archivos (~53 llamadas) | Media | Migrar a `Theme.of(context).colorScheme`. |
| DT14–DT18 | ⏳ PENDIENTE | Ausencia de `flutter test` | Media | Testing automatizado y métricas. |
| M9 | ⏳ BLOQUEADO | Supabase HIBP | Bloqueado | Requiere plan Pro. |
| M6-06 | ❓ NO VERIFICADO | Hardware físico no aislado | Media | GPS apagado + sin historial. |
| SMTP (dominio propio) | ⏳ PENDIENTE | `onboarding@resend.dev` actual | Alta (previo a evaluadores) | Configurar SPF/DKIM. |

## 14. Backlog de Producto

**Necesario para v1 (previo a publicación):**
* `Data Safety` (Play Store) — requisito editorial.
* Auditoría controlada del hallazgo `ñ`/`Ñ` — confianza en sanitización.

**Necesario para v1 (previo a evaluadores externos):**
* Configuración de dominio propio en Resend (SPF/DKIM).

**Conveniente para v1:**
* M17 — Sistema de borradores y reintento de subida offline.
* Centralización gradual de la paleta de colores en el tema (`ColorScheme`).

**Puede esperar (Post-v1):**
* A4 — Distinción entre usuario uploader y artista de la pintura.
* A1.4 — Historial de versiones y galería de fotos con ventana de 6 días.
* M7, M8, M11–M16 y mejoras de perfil B2–B7.

## 15. Siguiente Objetivo Técnico

* **ID recomendado:** `Data Safety` (Play Store).
* **Estado actual:** ❓ NO DOCUMENTADO (requisito editorial Google Play).
* **Justificación técnica:** Una vez cerrada la Firma Release (v18), la barrera técnica para publicación ha quedado superada. El siguiente bloqueo real es de cumplimiento: la consola de Google Play exige una ficha de seguridad de datos (qué datos se recopilan, cómo se almacenan, si se comparten con terceros, tiempo de retención). Muralito recopila: ubicación GPS (M5, F6), fotografías (Murales + Avatares), perfil (apodo, avatar), email (Auth). Estos datos se almacenan en Supabase (PostgreSQL + Storage) y se comparten únicamente con servicios de fondo (Supabase, OSM tiles). Sin la ficha completada, la subida a Google Play será rechazada.
* **Archivos a intervenir:**
  * Consola Google Play (formulario `Data Safety`).
  * Documentación interna (Mejoras v18, Documentación Técnica v18) — sección nueva "Privacidad y datos".
* **Qué NO debe modificarse:**
  * No cambiar el comportamiento de `Auth` ni las políticas RLS existentes.
  * No introducir SDKs de terceros que recopilen datos adicionales sin documentarlos.
* **Auditoría previa necesaria:**
  * Listar cada dato recopilado y su flujo (entrada → procesamiento → almacenamiento → retención → borrado).
  * Confirmar que `MapaPrincipalPage` y `auth_page.dart` no hacen `analytics` ni `tracking` de terceros.
  * Verificar URLs externas que carga la app (OSM tiles, Google Maps) y declararlas en la ficha.
* **Pruebas necesarias tras implementar:**
  * Cruzar la ficha declarada con el código real (auditoría estática de imports y llamadas de red).
  * Validar que el formulario enviado coincide con el comportamiento observable de la app.
* **Riesgos y efectos secundarios:** Mínimos si la auditoría previa es correcta. Riesgo medio si se declaran datos que la app no recopila realmente (rechazo de Play) o si se omiten datos reales (suspensión posterior).

**Objetivo alternativo (producto):**
* M17 — Borradores offline + reintento. Detectado durante validación física: si falla la subida, recuperar el borrador (título/descripción/foto/ubicación/rotación) para no repetir trabajo.

## 16. Estrategia de Release

**Fase 1: Requisitos antes de incorporar evaluadores externos (Closed Alpha)**
* Configuración y validación de dominio remitente propio en Resend (SPF/DKIM) para permitir entregabilidad a correos externos.
* Auditoría controlada del hallazgo `ñ`/`Ñ`.

**Fase 2: Requisitos obligatorios antes de Google Play Store**
* ~~Creación y resguardo del Keystore de producción (.jks).~~ ✅ CERRADO (v18).
* ~~Configuración de `signingConfigs.release` en `android/app/build.gradle.kts`.~~ ✅ CERRADO (v18).
* ~~Generación y validación de App Bundle (.aab).~~ ✅ CERRADO (v18; 52.2 MB).
* `Data Safety`: declaración de privacidad y ficha de Seguridad de los Datos en Google Play Console.
* Reproducción controlada del hallazgo `ñ`/`Ñ` y, si se confirma bug, fix en `nombreArchivoDesdeTitulo` o validación del formulario.

**Fase 3: Post-Lanzamiento (v1.1+)**
* Implementación de borradores locales ante fallos de conexión (M17).
* M17 redefine el flujo de alta; podría combinarse con mejoras de UX en `FormularioMuralModal`.

## 17. Archivos Críticos para el Handoff

**Imprescindibles**
* `lib/main.dart`
* `lib/pages/mapa_principal_page.dart`
* `lib/pages/auth_page.dart`
* `lib/pages/recuperar_password_page.dart`
* `lib/services/supabase_client.dart`
* `lib/services/ubicacion_service.dart`
* `lib/utils/helpers.dart`
* `lib/models/mural.dart`
* `lib/models/perfil.dart`
* `lib/widgets/ajustar_ubicacion_page.dart`
* `lib/widgets/onboarding_ubicacion_dialog.dart`
* `android/app/build.gradle.kts`
* `android/settings.gradle.kts`
* `android/gradle.properties`
* `android/app/src/main/kotlin/com/muralitoapp/app/MainActivity.kt`
* `pubspec.yaml`
* `AndroidManifest.xml`
* `.env.example`

**Importantes (Modales y Diálogos)**
* `lib/widgets/formulario_mural_modal.dart`
* `lib/widgets/editar_mural_modal.dart`
* `lib/widgets/editar_perfil_modal.dart`
* `lib/widgets/dialogo_carga.dart`

**No compartir / Ignorar en repositorios**
* Archivo `.env` real (contiene secretos y credenciales).
* Archivos `key.properties` o certificados `.jks`.
* Directorios generados: `build/`, `.dart_tool/`, `android/.gradle/`, `ios/Flutter/ephemeral/`.

## 18. Estado Global del Proyecto

| Área | Estado | Evidencia | Observación |
| :--- | :--- | :--- | :--- |
| MVP | 🧪 VALIDADO | Pruebas funcionales + APK release físico | Flujos de usuario principales cerrados. |
| Auth | 🧪 VALIDADO | M1, M2, DT4-01, DT4 PASS | Email con autovalidate y Timer 3s. |
| Perfil | 🧪 VALIDADO | Trigger en BD y DT2 avatar PASS | `toMap()` en Perfil sin uso en código. |
| Murales | 🧪 VALIDADO | Pruebas CRUD 001–012 PASS | Cámara y galería operativas. Hallazgo `ñ`/`Ñ` pendiente. |
| Ubicación | 🧪 VALIDADO (Parcial) | M5 y M6 (salvo M6-06) PASS | Onboarding M3 validado duradero. |
| Mapa | 🧪 VALIDADO | Clustering 30 m y OSM PASS | Atribución legal (E6) operativa. |
| Storage | 🧪 VALIDADO | DT1, DT2 y B1 PASS | Helper unificado; riesgo DT8 latente. |
| Seguridad | 🧪 VALIDADO | RLS auditadas; anti-enumeración | M9 bloqueado por plan Supabase. |
| Firma Release | ✅ CERRADO | `apksigner verify` + Infinix X6886 | APK y AAB firmados; backup externo OK. |
| Testing | ⏳ PENDIENTE | Predominio de pruebas manuales | Suite automatizada pendiente. |
| Arquitectura | ⚠️ RIESGO / DEUDA | Lectura de código (`MapaPrincipalPage`) | No se refactorizará a gran escala ahora. |
| Rendimiento | ⚠️ RIESGO | Doble bucle en clustering O(n²) | Requiere medición formal previa. |
| Documentación | 🧪 VALIDADO | Versiones v18 / v15 / Mejoras v18 / README sincronizados | Discrepancias `AGP`, `key.properties`, `Firma`, `Identidad` resueltas. |
| Hallazgo `ñ`/`Ñ` | ❓ REPORTADO — NO REPRODUCIDO | Validación física APK release | Pendiente auditoría controlada. |
| Release (Data Safety) | ❓ NO DOCUMENTADO | Requisito Google Play Console | Pendiente previo a publicación. |
| Release (SMTP) | ⏳ PENDIENTE | `onboarding@resend.dev` actual | Pendiente dominio propio con SPF/DKIM. |

## 19. Decisiones Técnicas Vigentes

* Modo espectador público: El mapa, clusters y fichas son públicos y no requieren autenticación.
* Autorización delegada a RLS: La seguridad de los datos depende estrictamente de las políticas de PostgreSQL (`auth.uid()`), nunca de la interfaz.
* Inmutabilidad de coordenadas: Una vez publicado un mural, sus coordenadas no se pueden modificar desde la app.
* Identidad del uploader (`user_id`): Identifica a quien toma la fotografía y sube el registro, no necesariamente al autor del arte urbano (A4 pendiente).
* Rollback de Storage: Nunca purgar una foto previa sin confirmar el éxito en PostgreSQL; si la inserción falla, purgar el archivo huérfano recién subido.
* Proveedor SMTP: Se utiliza Resend a través de puerto 465.
* Servicio unificado de ubicación: `ubicacion_service.dart` centraliza la resolución de estados de GPS para alta (M5) y centrado (M6).
* Storage B1: Separación estricta entre el listing del bucket (restringido a autenticados) y la lectura directa por URL pública.
* Identidad Android: `namespace` y `applicationId` están unificados en `com.muralitoapp.app`.
* Atribución OSM: Se mantiene mediante widget limpio en `bottomLeft` sin el prefijo `flutter_map | `; visibilidad mejorada (E6).
* M4 Redefinido: Mantener OpenStreetMap como motor de mapas interno; el enlace «Cómo llegar» invoca Google Maps nativo.
* Firma Release (v18): `signingConfigs.release` con credenciales desde `key.properties`; keystore externo respaldado; APK/AAB firmados verificables con `apksigner`.
* Borradores locales (M17): Diferido formalmente para etapas posteriores a la v1 para resguardar el alcance inicial.
* Hallazgo `ñ`/`Ñ`: No se afirma como bug hasta reproducción controlada; pendiente de auditoría.

## 20. Handoff Prompt

```
Actúa como Tech Lead Senior de Muralito App.
Muralito App es una aplicación móvil Android desarrollada con Flutter y Dart para el mapeo y visualización colaborativa de murales urbanos sobre OpenStreetMap, con backend en Supabase (PostgreSQL, Auth y Storage).
ESTADO ACTUAL: MVP funcional avanzado con APK/AAB release validados en dispositivo físico (Infinix X6886). Firma Release cerrada.
Funcionalidades validadas: Modo espectador, autenticación completa con política M1, DT4-01 y DT4 (autovalidate reactivo + Timer 3s), recuperación OTP M2 vía Resend con autovalidate en email, perfiles automáticos con trigger en PostgreSQL, CRUD de murales propios con rollback en Storage, selección de fotografía desde cámara o galería, onboarding de ubicación persistido M3, pin y GPS no bloqueante M5, centrado del mapa M6 (salvo M6-06), atribución obligatoria de OpenStreetMap en pantalla con visibilidad mejorada (E6), sistema unificado de avisos superiores (toasts) y políticas RLS verificadas.
CONFIGURACIÓN ANDROID: namespace y applicationId alineados en "com.muralitoapp.app" en build.gradle.kts y MainActivity.kt. AGP 8.13.0. JDK Temurin 17.0.20.1.
FIRMA RELEASE: signingConfigs.release operativo con keystore muralito (RSA 2048, alias muralito, 10 000 días). APK 53.3 MB y AAB 52.2 MB compilados y firmados. Firma V2/V3 verificada con apksigner. Backup externo del .jks confirmado.
STACK TÉCNICO: Flutter 3.47.0, Dart 3.13.0, Android SDK Platform 36, Supabase Flutter ^2.17.2, flutter_map ^8.3.1, latlong2 ^0.10.1, geolocator ^14.0.3, image_picker ^1.2.3, flutter_image_compress ^2.5.1, url_launcher ^6.3.1, shared_preferences ^2.5.4, flutter_dotenv ^6.0.1.
ARQUITECTURA:
- lib/pages/mapa_principal_page.dart concentra múltiples responsabilidades (DT10).
- lib/services/ubicacion_service.dart centraliza la resolución de estados de geolocalización para M5 y M6.
- lib/utils/helpers.dart maneja la sanitización de Storage y diálogos seguros.
- android/app/build.gradle.kts aplica signingConfigs.release desde key.properties (excluido de Git).
DEUDA TÉCNICA Y PENDIENTES INMEDIATOS:
1. HALLAZGO A AUDITAR: Durante validación física del APK release, un título con ñ/Ñ ("pruebiññaañaña") no se pudo guardar, mientras que sin ñ no falló. Reportado, NO reproducido de forma controlada. Revisar nombreArchivoDesdeTitulo en helpers.dart, _subirMural() y validación en formulario_mural_modal.dart antes de afirmar bug.
2. DATA SAFETY (PLAY STORE): Requisito editorial de Google Play Console. Recopilación: ubicación GPS (M5/M6), fotografías (murales+avatares), perfil (apodo, avatar), email (Auth). Almacenamiento: Supabase (PostgreSQL + Storage). Compartición: ninguna explícita; URLs externas (OSM tiles, Google Maps) deben declararse. Pendiente declarar en consola y documentar internamente.
3. RIESGOS: Remitente onboarding@resend.dev requiere dominio propio antes de testers externos (SPF/DKIM); algoritmo de clustering O(n²) en memoria; ~53 referencias a Colors.deepPurple hardcodeadas; ausencia de capa Repository (DT11/DT12); falta de suite automatizada flutter test (DT14); borrarFotoDeStorage limitado a rutas planas (DT8).
4. BLOQUEADO: M9 (Leaked Passwords) requiere suscripción Supabase Pro.
REGLAS DE TRABAJO OBLIGATORIAS:
1. Analizar primero el código y documentación disponible antes de proponer cambios.
2. No asumir que HECHO significa VALIDADO; exigir evidencia real de pruebas.
3. No inventar tablas, SQL, RLS, Storage, archivos ni arquitectura.
4. No modificar código sin aprobación explícita del usuario.
5. Antes de modificar: explicar problema, presentar evidencia, indicar archivos afectados, proponer solución mínima, explicar riesgos y esperar autorización.
6. No realizar refactorizaciones no relacionadas con la tarea en curso.
7. Ejecutar "flutter analyze" después de cualquier modificación (debe dar cero errores).
8. Informar exactamente qué pruebas se ejecutaron y sus resultados.
9. Mantener el archivo .env real, key.properties y secretos fuera del control de versiones y del chat.
10. Metodología obligatoria: CÓDIGO → ANÁLISIS → PRUEBAS → DOCUMENTACIÓN.
```

## 21. Checklist Final de Validación

* [x] Código actual analizado (mapa_principal_page.dart, auth_page.dart, recuperar_password_page.dart, helpers.dart, ajustar_ubicacion_page.dart, build.gradle.kts, settings.gradle.kts, gradle.properties).
* [x] Documentación más reciente analizada (Documentación Técnica v18, Flujos Funcionales v15, Mejoras v18, README.md, Handoff v005).
* [x] Stack tecnológico y versiones documentados con sus fuentes.
* [x] Funcionalidades implementadas diferenciadas de las validadas.
* [x] Pruebas reales documentadas y separadas de casos pendientes.
* [x] Problemas confirmados separados de riesgos y deudas técnicas.
* [x] Supabase documentado con mención explícita a la ausencia de acceso directo al SQL.
* [x] Distinción entre URL pública directa y listing anónimo en Storage (B1).
* [x] Riesgo DT8 (subcarpetas de Storage) documentado como deuda y no como bug.
* [x] Arquitectura de `lib/` y responsabilidad de `ubicacion_service.dart` detalladas.
* [x] Discrepancias previas (namespace, AGP, JDK, key.properties, Firma Release) marcadas como cerradas.
* [x] Discrepancia nueva (hallazgo `ñ`/`Ñ`) documentada como REPORTADA — NO REPRODUCIDA.
* [x] Escenario M6-06 conservado como NO VERIFICADO.
* [x] M9 clasificado como BLOQUEADO por limitación del plan externo.
* [x] Firma Release marcada como CERRADO con evidencia física (`apksigner verify`, Infinix X6886).
* [x] `Data Safety` clasificado como NO DOCUMENTADO y propuesto como siguiente objetivo técnico.
* [x] Siguiente objetivo técnico identificado y planificado (`Data Safety`).
* [x] Archivo `.env` real, `key.properties` y `.jks` excluidos de cualquier reporte.
* [x] Handoff Prompt listo para copiar incluido al final del informe.