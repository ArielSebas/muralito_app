# 🎨 Muralito App

> **v18 — MVP funcional avanzado con APK/AAB release validados en Infinix X6886.** La barrera técnica de publicación (Firma Release) está cerrada. El siguiente foco es de cumplimiento editorial en Google Play (Data Safety) y de auditoría controlada del hallazgo `ñ`/`Ñ` reportado durante la validación física.

Aplicación móvil desarrollada con **Flutter para Android** orientada al mapeo colaborativo de arte urbano. Muralito permite registrar murales mediante una fotografía, obtener y ajustar su ubicación geográfica y almacenar la información en **Supabase**, para luego visualizarlos sobre un mapa **OpenStreetMap**.

El mapa es público mediante un **modo espectador**; la autenticación solo es requerida para registrar, editar o eliminar murales propios.

**Documentación de referencia vigente (27/09/2026):**

* **Documentación Técnica v18**
* **Mejoras v18**
* **Flujos Funcionales v14**
* **Handoff Técnico v007**

---

## 🆕 Novedades de esta versión (v18)

Resumen de cambios implementados y validados respecto a v16:

**Cerrado y validado en v18:**

* 🔐 **DT4 — Autovalidate reactivo en campo de correo electrónico + Timer 3 s** — Aplicado el mismo patrón de `FocusNode`/`Timer` ya usado en DT4-01. El error de validación se muestra al perder foco y se oculta automáticamente al cabo de 3 segundos en `auth_page.dart` y `recuperar_password_page.dart`. Validado con pruebas `#1`–`#13 PASS`.
* 🧭 **M4 redefinido — «Cómo llegar» hacia Google Maps nativo** — `_abrirComoLlegar()` ahora genera la URI `https://www.google.com/maps/dir/?api=1&destination=$lat,$lng` con `LaunchMode.externalApplication`. El mapa interno sigue siendo OpenStreetMap; solo cambia el destino de navegación. Validado con pruebas `A`–`E PASS` y probado en Infinix X6886.
* 🏷️ **E6 — Atribución de OpenStreetMap con visibilidad mejorada (opcional)** — `fontSize 13`, `fontWeight w600`, `padding 8,4` y fondo `0xDDF5F5F5`. Texto y enlace a `copyright` mantenidos. Funcional intacta (`D PASS`).
* 🔏 **DT-Firma-Release — Keystore + signingConfigs.release + APK/AAB firmados** — Keystore RSA 2048 (alias `muralito`, 10 000 días, CN=Muralito, OU=Muralito, O=Muralito, L=Quito, ST=Pichincha, C=EC). `signingConfigs.release` configurado desde `key.properties` (UTF-8 sin BOM). APK release (53.3 MB) y AAB release (52.2 MB) compilados; firma V2/V3 verificada con `apksigner verify`. Probado en Infinix X6886 (login, mapa, clustering, CRUD, GPS, Google Maps, Atribución OSM — todo funcional). Backup externo del `.jks` confirmado.
* ⚙️ **Ajustes técnicos** — AGP `9.1.0` → `8.13.0`; JDK del proyecto Temurin `17.0.20.1`; `android/gradle.properties` con `android.newDsl=true`; `key.properties` con ruta de keystore relativa.

**Pendientes nuevos / actualizados:**

* ❓ **Hallazgo `ñ`/`Ñ` (sanitización de título)** — Durante validación física del APK release, un título con `ñ`/`Ñ` ("pruebiññaañaña") no se pudo guardar; sin `ñ` no falló. NO REPRODUCIDO de forma controlada. Pendiente auditoría en `helpers.dart::nombreArchivoDesdeTitulo`, `_subirMural()` y validación en `formulario_mural_modal.dart`.
* ❓ **Data Safety (Play Store)** — Requisito editorial de Google Play Console. Muralito recopila ubicación GPS, fotografías, perfil y email; almacena en Supabase. Pendiente declarar en consola y documentar internamente.
* ❓ **Dominio propio en Resend** — Remitente actual `onboarding@resend.dev` requiere reemplazo por dominio con SPF/DKIM antes de evaluadores externos.

**Persistentes:**

* ⏳ **Colores hardcodeados** — ~53 referencias a `Colors.deepPurple` distribuidas en 8 archivos (deuda de estilo).
* ❓ **M6-06** — Caso de borde (sin GPS actual ni última ubicación conocida) continúa clasificado como no verificado en hardware físico.
* ⏳ **M17 — Borradores y reintento offline** — Backlog post-v1.
* ⛔ **M9 — Leaked Passwords** — Bloqueado; requiere plan Supabase Pro.

---

## 📱 Características actuales

* 🗺️ **Mapa interactivo con OpenStreetMap y modo espectador**, permitiendo explorar murales, marcadores y clusters sin registrar cuenta.
* ⚖️ **Atribución oficial de OpenStreetMap** visible y clicable en todas las pantallas de mapa, con visibilidad mejorada (E6).
* 🔔 **Notificaciones contextuales tipo Toast** en la cabecera del mapa, sin obstruir controles ni invadir la interacción táctil.
* 🔐 **Autenticación con correo y contraseña** mediante Supabase Auth, con confirmación de correo y login/logout dinámico.
* 🔑 **Contraseña segura durante el registro y recuperación (M1 / DT4-01)**:
  * Mínimo 8 caracteres, mayúscula, minúscula, número y carácter especial.
  * Checklist interactivo en tiempo real.
  * Limpieza inmediata del borde rojo al tipear; error visible solo al perder foco o enviar el formulario.
* 📧 **Autovalidate reactivo en campo de correo (DT4)** con `FocusNode`, `Timer` de 3 s y patrón `addListener` + `dispose` (auth y recuperación).
* 🔁 **Recuperación de contraseña mediante código OTP (M2)** con cooldown de 60 segundos vía SMTP Resend.
* 👤 **Perfil de usuario** (apodo y avatar) creado automáticamente mediante trigger en base de datos con políticas RLS auditadas.
* 🧑‍🎨 **Atribución «Subido por» (A3)** en fichas de mural, mostrando uploader y avatar (o «Muralista anónimo» en registros legados).
* 📷 **Registro de murales flexible**:
  * Elección entre cámara nativa o selección desde galería.
  * Compresión JPEG automática con rotación y corrección de metadatos EXIF.
  * Fijación de pin central con GPS no bloqueante y ajuste manual.
* 📍 **Inmutabilidad geográfica**: Las coordenadas se fijan exclusivamente al publicar; no son editables en modificaciones posteriores.
* 📍 **Control «Mi ubicación» (M6)** con gestión de permisos, alertas interactivas y fallback a última posición conocida (M6-01…05 y M6-07 PASS; M6-06 no verificado).
* 📍 **Onboarding de ubicación (M3)** presentado una única vez por instalación mediante `shared_preferences`.
* ✏️ **CRUD completo de murales propios** con transacciones seguras y rollback de imágenes en Storage ante fallos en PostgreSQL (DT1 / DT2).
* 🧹 **Sanitización estricta de nombres en Storage** (`nombreArchivoDesdeTitulo` con RegExp que acepta explícitamente `ñ`/`Ñ`; pendiente auditoría controlada del hallazgo reportado).
* 🧩 **Clustering geográfico a 30 metros** con zoom de contexto y lista desplegable de murales coincidentes.
* 🧭 **«Cómo llegar» (M4)** desde la ficha de mural hacia Google Maps nativo (sin reemplazar el mapa interno OpenStreetMap).
* 🔏 **Firma Release operativa** — APK y AAB firmados con keystore propio; firma V2/V3 verificable con `apksigner`.
* 📜 **Licencia MIT**.

---

## 🔧 Estado técnico actual

### ✅ Atribución de OpenStreetMap (v16 + E6)
Implementada mediante contenedor `Align(alignment: Alignment.bottomLeft)` en `mapa_principal_page.dart` y `ajustar_ubicacion_page.dart`, invocando `https://www.openstreetmap.org/copyright` en `LaunchMode.externalApplication`. Estilo opcional aplicado: `fontSize 13`, `w600`, `padding 8,4`, fondo `0xDDF5F5F5`.

### ✅ Selección de origen de imagen (v16)
Integrada en `_iniciarFlujoNuevoMural()` mediante `_seleccionarOrigenFoto()`, permitiendo seleccionar `ImageSource.camera` o `ImageSource.gallery` de forma segura.

### ✅ Sistema de avisos del mapa (v16)
Centralizado mediante el modelo `_AvisoUI` y la función `_mostrarAviso()`, brindando retroalimentación visual superior con auto-cierre a los 3 segundos.

### ✅ DT4 — Autovalidate en email (v18)
`_emailFocusNode.addListener` en `auth_page.dart` y `recuperar_password_page.dart`; `Timer(3s)` para auto-cierre del error; `dispose()` con cancelación. Validado con `#1`–`#13 PASS`.

### ✅ M4 — Cómo llegar (v17)
`_abrirComoLlegar()` en `mapa_principal_page.dart` genera URI hacia Google Maps nativo sin reemplazar el mapa interno. Validado con `A`–`E PASS` y prueba física en Infinix X6886.

### ✅ Firma Release (v18)
* `applicationId = "com.muralitoapp.app"`.
* `namespace = "com.muralitoapp.app"`.
* `signingConfigs.release` con credenciales desde `android/key.properties` (UTF-8 sin BOM, ruta relativa).
* Keystore RSA 2048, alias `muralito`, 10 000 días.
* APK release 53.3 MB y AAB release 52.2 MB firmados; firma V2/V3 verificada con `apksigner verify`.
* Backup externo del `.jks` confirmado.
* Ubicación Kotlin: `android/app/src/main/kotlin/com/muralitoapp/app/MainActivity.kt`.

### 🤖 Identidad Android confirmada
* `applicationId = "com.muralitoapp.app"`.
* `namespace = "com.muralitoapp.app"`.
* AGP `8.13.0`; JDK Temurin `17.0.20.1`.

---

## 📊 Matriz de estado del backlog

| Componente / Tarea | Estado | Observación |
| :--- | :--- | :--- |
| **Atribución OpenStreetMap** | 🧪 Validado | Cumple política de OSM; visibilidad mejorada (E6) operativa. |
| **Origen foto (Cámara / Galería)** | 🧪 Validado | 4 pruebas manuales PASS. |
| **Sistema de avisos (Toast mapa)** | 🧪 Validado | Banner superior; sustituye SnackBars. |
| **Identidad Android (`com.muralitoapp.app`)** | 🧪 Validado | `namespace` y `applicationId` alineados. |
| **M1 — Contraseña segura** | 🧪 Validado | Checklist en tiempo real. |
| **DT4-01 — Borde rojo contraseña** | 🧪 Validado | Registro y recuperación. |
| **DT4 — Autovalidate email + Timer** | 🧪 Validado | `#1`–`#13 PASS`; auth y recuperación. |
| **M2 — Recuperación OTP** | 🧪 Validado | Cooldown de 60 s. |
| **M4 — Cómo llegar → Google Maps** | 🧪 Validado | `A`–`E PASS`; probado en Infinix X6886. |
| **DT1 / DT2 — Rollback en Storage** | 🧪 Validado | Purgado automático si falla transacción. |
| **M5 / M10 — GPS y pin en alta** | 🧪 Validado | Timeout 10 s y ajuste manual. |
| **M3 — Onboarding de ubicación** | 🧪 Validado | Persistido con `shared_preferences`. |
| **B1 — Restricción de Storage** | 🧪 Validado | Listing anónimo denegado; URLs públicas operativas. |
| **M6 — Centrar mi ubicación** | 🧪 Validado parcial | M6-01…05 y M6-07 PASS; M6-06 continúa no verificado. |
| **DT-Firma-Release (Keystore + APK/AAB)** | 🧪 Validado | Firma V2/V3 verificada con `apksigner`; backup externo OK. |
| **Hallazgo `ñ`/`Ñ` (sanitización)** | ❓ Reportado — No reproducido | Pendiente auditoría controlada. |
| **Data Safety (Play Store)** | ❓ No documentado | Requisito editorial previo a publicación. |
| **Dominio propio en Resend** | ⏳ Pendiente | Antes de evaluadores externos. |
| **Colores hardcodeados** | ⏳ Pendiente | Deuda de estilo (~53 referencias directas). |
| **M17 — Borradores y reintento offline** | ⏳ Pendiente | Backlog post-v1. |
| **M9 — Leaked Passwords** | ⛔ Bloqueado | Requiere plan Supabase Pro. |

---

## 🛠️ Stack tecnológico

| Capa | Tecnología | Versión |
| :--- | :--- | :--- |
| **Framework** | Flutter | 3.47.0 |
| **Lenguaje** | Dart | 3.13.0 |
| **Plataforma** | Android | SDK Platform 36 |
| **AGP** | Android Gradle Plugin | 8.13.0 |
| **JDK** | Temurin | 17.0.20.1 |
| **Backend** | Supabase (PostgreSQL + Auth + Storage) | `supabase_flutter` ^2.17.2 |
| **Mapas** | `flutter_map` + OpenStreetMap | ^8.3.1 |
| **Coordenadas** | `latlong2` | ^0.10.1 |
| **Geolocalización** | `geolocator` | ^14.0.3 |
| **Imágenes** | `image_picker` + `flutter_image_compress` | ^1.2.3 / ^2.5.1 |
| **Navegación externa** | `url_launcher` | ^6.3.1 |
| **Persistencia local** | `shared_preferences` | ^2.5.4 |
| **Variables de entorno** | `flutter_dotenv` | ^6.0.1 |
| **SMTP** | Resend | Puerto 465 (TLS) |
| **Firma Release** | Keystore RSA 2048 + `signingConfigs.release` | alias `muralito`, 10 000 días |

---

## 📁 Estructura del proyecto

```text
muralito_app/
├── android/
│   ├── app/
│   │   ├── build.gradle.kts            # signingConfigs.release; namespace + applicationId com.muralitoapp.app
│   │   ├── muralito-release-key.jks    # Keystore RSA 2048 (alias muralito, 10 000 días)
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── kotlin/com/muralitoapp/app/MainActivity.kt
│   ├── key.properties                  # Credenciales del keystore (UTF-8 sin BOM; excluido de Git)
│   ├── settings.gradle.kts             # AGP 8.13.0
│   └── gradle.properties               # org.gradle.java.home = Temurin 17.0.20.1; android.newDsl=true
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── mural.dart
│   │   └── perfil.dart
│   ├── pages/
│   │   ├── auth_page.dart              # DT4: autovalidate reactivo + Timer 3s
│   │   ├── mapa_principal_page.dart    # M4: Cómo llegar → Google Maps nativo
│   │   └── recuperar_password_page.dart# DT4: autovalidate reactivo + Timer 3s
│   ├── services/
│   │   ├── supabase_client.dart
│   │   └── ubicacion_service.dart      # Centraliza resolución GPS para M5 y M6
│   ├── utils/
│   │   └── helpers.dart                # Sanitización Storage + manejo de errores (auditoría ñ/Ñ pendiente)
│   └── widgets/
│       ├── ajustar_ubicacion_page.dart
│       ├── dialogo_carga.dart
│       ├── editar_mural_modal.dart
│       ├── editar_perfil_modal.dart
│       ├── formulario_mural_modal.dart # Validación de título (auditoría ñ/Ñ pendiente)
│       └── onboarding_ubicacion_dialog.dart
├── .env.example
├── pubspec.yaml
└── README.md
```

---

# 🎯 Objetivo de producto

Consolidar una primera versión (v1) estable, segura, mantenible y probada en hardware real para su publicación en Google Play.

**Próximo objetivo técnico recomendado:** Data Safety (Play Store) — requisito editorial previo a publicación. La barrera técnica de compilación ya quedó superada con el cierre de Firma Release (v18).

Noviembre de 2026 se mantiene como referencia temporal orientativa, priorizando siempre la estabilidad funcional.

---

# 📜 Licencia

Distribuido bajo la licencia MIT. Ver `LICENSE`.

# 👨‍💻 Autor

**Ariel Sebastian Cuenca Paillacho**

Proyecto para el registro y visualización colaborativa de arte urbano.