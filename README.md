# 🎨 Muralito App

Aplicación móvil desarrollada con **Flutter para Android** orientada al mapeo colaborativo de arte urbano. Muralito permite registrar murales mediante una fotografía, obtener y ajustar su ubicación geográfica y almacenar la información en **Supabase**, para luego visualizarlos sobre un mapa **OpenStreetMap**.

El mapa es público mediante un **modo espectador**; la autenticación solo es requerida para registrar, editar o eliminar murales propios.

**Documentación de referencia vigente (26/09/2026):**

* **Documentación Técnica v16**
* **Mejoras v16**
* **Flujos Funcionales v12**
* **Handoff Técnico (Sesión 26/09/2026)**

---

## 🆕 Novedades de esta versión (v16)

Resumen de cambios implementados y validados respecto a la versión anterior:

**Cerrado y validado en v16:**

* 🗺️ **Atribución visible de OpenStreetMap** — Integración del widget de atribución legal («© Colaboradores de OpenStreetMap») en la esquina inferior izquierda de `mapa_principal_page.dart` y `ajustar_ubicacion_page.dart`[cite: 1, 2]. Cumple formalmente la política de uso de teselas de `tile.openstreetmap.org` y enlaza directamente a su página de copyright vía `url_launcher`[cite: 1, 2, 8]. Se descartó el prefijo redundante `flutter_map | ` para mayor limpieza de interfaz[cite: 1].
* 📷 **Origen de fotografía en «Nuevo Mural» (Cámara o Galería)** — Modal inferior al tocar «Nuevo Mural» que permite capturar fotografía con la cámara nativa o seleccionar un archivo preexistente de la galería del teléfono[cite: 1]. Validado con 4 pruebas manuales completas (cancelación de modal, cámara, cancelación en galería y guardado desde galería).
* 🔔 **Sistema unificado de notificaciones (Toast superior en mapa)** — Estandarización de avisos en `mapa_principal_page.dart` mediante un banner superior tipo toast integrado en el `Stack` (éxito en verde, error en rojo, información y GPS en morado con botones de acción interactivos)[cite: 1]. Se eliminan los `SnackBar` flotantes de Flutter que quedaban suspendidos en el centro de la pantalla[cite: 1, 6, 7].
* 📐 **Reposicionamiento de controles flotantes (FABs)** — Retiro del margen inferior excesivo; los botones «Mi ubicación» y «Nuevo Mural» vuelven a su anclaje inferior derecho estándar de Material Design sin colisionar con la atribución ubicada a la izquierda[cite: 1, 7].
* 🤖 **Identidad Android alineada** — Rectificación documental: se constató en código real (`build.gradle.kts` y `MainActivity.kt`) que `namespace` y `applicationId` están debidamente alineados en `com.muralitoapp.app`[cite: 3, 11].

**Detectado / Pendientes de resolver:**

* ⚠️ **Firma de release** — `android/app/build.gradle.kts` sigue configurado con `signingConfigs.getByName("debug")`, bloqueante para publicar en Google Play[cite: 3, 12].
* ⚠️ **Autovalidate en campo de correo electrónico** — El campo de email retiene el borde rojo y mensaje de error al escribir tras un intento fallido de envío (mismo caso resuelto en contraseña con DT4-01)[cite: 8, 12].
* ⚠️ **Colores hardcodeados** — ~53 referencias a `Colors.deepPurple` distribuidas en 8 archivos[cite: 11, 12].
* ❓ **M6-06** — Caso de borde (sin GPS actual ni última ubicación conocida) continúa clasificado como no verificado en hardware físico[cite: 11, 12].
* ⏳ **Dominio propio en Resend** — Requerido antes de incorporar evaluadores externos[cite: 11, 12].

---

## 📱 Características actuales

* 🗺️ **Mapa interactivo con OpenStreetMap y modo espectador**, permitiendo explorar murales, marcadores y clusters sin registrar cuenta[cite: 12].
* ⚖️ **Atribución oficial de OpenStreetMap** visible y clicable en todas las pantallas de mapa[cite: 1, 2].
* 🔔 **Notificaciones contextuales tipo Toast** en la cabecera del mapa, sin obstruir controles ni invadir la interacción táctil[cite: 1].
* 🔐 **Autenticación con correo y contraseña** mediante Supabase Auth, con confirmación de correo y login/logout dinámico[cite: 12].
* 🔑 **Contraseña segura durante el registro y recuperación (M1 / DT4-01)**:
  * Mínimo 8 caracteres, mayúscula, minúscula, número y carácter especial[cite: 12].
  * Checklist interactivo en tiempo real[cite: 12].
  * Limpieza inmediata del borde rojo al tipear; error visible solo al perder foco o enviar el formulario[cite: 12].
* 🔁 **Recuperación de contraseña mediante código OTP (M2)** con cooldown de 60 segundos vía SMTP Resend[cite: 12].
* 👤 **Perfil de usuario** (apodo y avatar) creado automáticamente mediante trigger en base de datos con políticas RLS auditadas[cite: 12].
* 🧑‍🎨 **Atribución «Subido por» (A3)** en fichas de mural, mostrando uploader y avatar (o «Muralista anónimo» en registros legados)[cite: 12].
* 📷 **Registro de murales flexible**:
  * Elección entre cámara nativa o selección desde galería[cite: 1].
  * Compresión JPEG automática con rotación y corrección de metadatos EXIF[cite: 1, 12].
  * Fijación de pin central con GPS no bloqueante y ajuste manual[cite: 12].
* 📍 **Inmutabilidad geográfica**: Las coordenadas se fijan exclusivamente al publicar; no son editables en modificaciones posteriores[cite: 12].
* 📍 **Control «Mi ubicación» (M6)** con gestión de permisos, alertas interactivas y fallback a última posición conocida[cite: 1, 12].
* 📍 **Onboarding de ubicación (M3)** presentado una única vez por instalación mediante `shared_preferences`[cite: 12].
* ✏️ **CRUD completo de murales propios** con transacciones seguras y rollback de imágenes en Storage ante fallos en PostgreSQL (DT1 / DT2)[cite: 12].
* 🧹 **Sanitización estricta de nombres en Storage**, evitando subcarpetas involuntarias en altas y ediciones[cite: 12].
* 🧩 **Clustering geográfico a 30 metros** con zoom de contexto y lista desplegable de murales coincidentes[cite: 12].
* 🧭 **«Cómo llegar»** desde la ficha de mural hacia OpenStreetMap externo[cite: 12].
* 📜 **Licencia MIT**[cite: 12].

---

## 🔧 Estado técnico actual

### ✅ Atribución de OpenStreetMap (v16)
Implementada mediante contenedor `Align(alignment: Alignment.bottomLeft)` en `mapa_principal_page.dart` y `ajustar_ubicacion_page.dart`, invocando `https://www.openstreetmap.org/copyright` en `LaunchMode.externalApplication`[cite: 1, 2].

### ✅ Selección de origen de imagen (v16)
Integrada en `_iniciarFlujoNuevoMural()` mediante `_seleccionarOrigenFoto()`, permitiendo seleccionar `ImageSource.camera` o `ImageSource.gallery` de forma segura[cite: 1].

### ✅ Sistema de avisos del mapa (v16)
Centralizado mediante el modelo `_AvisoUI` y la función `_mostrarAviso()`, brindando retroalimentación visual superior con auto-cierre a los 3 segundos[cite: 1].

### 🤖 Identidad Android confirmada
* `applicationId = "com.muralitoapp.app"`[cite: 3].
* `namespace = "com.muralitoapp.app"`[cite: 3].
* Ubicación Kotlin: `android/app/src/main/kotlin/com/muralitoapp/app/MainActivity.kt`[cite: 11].

---

## 📊 Matriz de estado del backlog

| Componente / Tarea | Estado | Observación |
| :--- | :--- | :--- |
| **Atribución OpenStreetMap** | 🧪 Validado | Cumple política de OSM; enlaces externos funcionales[cite: 1, 2, 8]. |
| **Origen foto (Cámara / Galería)** | 🧪 Validado | 4 pruebas manuales PASS[cite: 1]. |
| **Sistema de avisos (Toast mapa)** | 🧪 Validado | Banner superior; sustituye SnackBars a media pantalla[cite: 1, 6, 7]. |
| **Identidad Android (`com.muralitoapp.app`)**| 🧪 Validado | `namespace` y `applicationId` alineados[cite: 3, 11]. |
| **M1 — Contraseña segura** | 🧪 Validado | Checklist en tiempo real[cite: 12]. |
| **DT4-01 — Borde rojo contraseña** | 🧪 Validado | Registro y recuperación[cite: 12]. |
| **M2 — Recuperación OTP** | 🧪 Validado | Cooldown de 60 s[cite: 12]. |
| **DT1 / DT2 — Rollback en Storage** | 🧪 Validado | Purgado automático si falla transacción[cite: 12]. |
| **M5 / M10 — GPS y pin en alta** | 🧪 Validado | Timeout 10 s y ajuste manual[cite: 12]. |
| **M3 — Onboarding de ubicación** | 🧪 Validado | Persistido con `shared_preferences`[cite: 12]. |
| **B1 — Restricción de Storage** | 🧪 Validado | Listing anónimo denegado; URLs públicas operativas[cite: 12]. |
| **M6 — Centrar mi ubicación** | 🧪 Validado parcial | M6-01…05 y M6-07 PASS; M6-06 continúa no verificado[cite: 12]. |
| **Autovalidate en campo de correo** | ⏳ Pendiente | Problema de UX confirmado en autenticación[cite: 11, 12]. |
| **M4 redefinido («Cómo llegar»)** | ⏳ Pendiente | Invocación de Google Maps en app nativa[cite: 12]. |
| **Firma de release** | ⏳ Pendiente | Bloqueante para Google Play (Keystore propio)[cite: 11, 12]. |
| **Colores hardcodeados** | ⏳ Pendiente | Deuda de estilo (~53 referencias directas)[cite: 11, 12]. |
| **M17 — Borradores y reintento offline** | ⏳ Pendiente | Backlog post-v1. |
| **M9 — Leaked Passwords** | ⛔ Bloqueado | Requiere plan Supabase Pro[cite: 12]. |

---

## 🛠️ Stack tecnológico

| Capa | Tecnología | Versión |
| :--- | :--- | :--- |
| **Framework** | Flutter | 3.47.0[cite: 11, 12] |
| **Lenguaje** | Dart | 3.13.0[cite: 11, 12] |
| **Plataforma** | Android | SDK Platform 36[cite: 11, 12] |
| **Backend** | Supabase (PostgreSQL + Auth + Storage) | `supabase_flutter` ^2.17.2[cite: 11, 12] |
| **Mapas** | `flutter_map` + OpenStreetMap | ^8.3.1[cite: 11, 12] |
| **Coordenadas** | `latlong2` | ^0.10.1[cite: 11, 12] |
| **Geolocalización** | `geolocator` | ^14.0.3[cite: 11, 12] |
| **Imágenes** | `image_picker` + `flutter_image_compress` | ^1.2.3 / ^2.5.1[cite: 11, 12] |
| **Navegación externa** | `url_launcher` | ^6.3.1[cite: 11, 12] |
| **Persistencia local** | `shared_preferences` | ^2.5.4[cite: 11, 12] |
| **Variables de entorno**| `flutter_dotenv` | ^6.0.1[cite: 11, 12] |

---

## 📁 Estructura del proyecto

```text
muralito_app/
├── android/
│   ├── app/
│   │   ├── build.gradle.kts (applicationId & namespace: com.muralitoapp.app)
│   │   └── src/main/
│   │       ├── AndroidManifest.xml
│   │       └── kotlin/com/muralitoapp/app/MainActivity.kt
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── mural.dart
│   │   └── perfil.dart
│   ├── pages/
│   │   ├── auth_page.dart
│   │   ├── mapa_principal_page.dart
│   │   └── recuperar_password_page.dart
│   ├── services/
│   │   ├── supabase_client.dart
│   │   └── ubicacion_service.dart
│   ├── utils/
│   │   └── helpers.dart
│   └── widgets/
│       ├── ajustar_ubicacion_page.dart
│       ├── dialogo_carga.dart
│       ├── editar_mural_modal.dart
│       ├── editar_perfil_modal.dart
│       ├── formulario_mural_modal.dart
│       └── onboarding_ubicacion_dialog.dart
├── .env.example
├── pubspec.yaml
└── README.md
```

# 🎯 Objetivo de producto

Consolidar una primera versión (v1) estable, segura, mantenible y probada en hardware real para su publicación en Google Play. Noviembre de 2026 se mantiene como referencia temporal orientativa, priorizando siempre la estabilidad funcional.

---

# 📜 Licencia

Distribuido bajo la licencia MIT. Ver `LICENSE`.

# 👨‍💻 Autor

**Ariel Sebastian Cuenca Paillacho**

Proyecto para el registro y visualización colaborativa de arte urbano.
