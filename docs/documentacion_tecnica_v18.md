# Muralito App — Documentación Técnica v18

**Versión:** 18
**Fecha:** 2026-09-27
**Estado:** MVP funcional avanzado — DT-Firma-Release y DT4, M4, E6 validados mediante ejecución física (`flutter run` + `flutter build apk --release` + `apksigner verify`).
**Sustituye a:** Documentación Técnica v17 (26/09/2026).
**Referencias documentales sincronizadas:** Flujos Funcionales v13, Mejoras v17, README.md, Handoff Técnico v007.

---

## 0. Control de versiones y cambios v17 → v18

**Documentos vigentes:**
- Documentación Técnica v18 (esta revisión)
- Flujos Funcionales v13 (26/09/2026)
- Mejoras v17 (26/09/2026)
- README.md (26/09/2026)
- Handoff Técnico v007 (27/09/2026)

**Cambios formales v17 → v18:**
- `DT-Firma-Release` (Keystore .jks + signingConfigs.release + key.properties): implementado, validado físicamente (APK release compilado, instalado en Infinix X6886, firma V2/V3 verificada con `apksigner verify`).
- `Firma-Release` cerrada. Backup externo del `.jks` confirmado. Contraseña final cambiada después de la sesión (la inicial se expuso durante el troubleshooting).
- AGP ajustado de 9.1.0 → 8.13.0 (compatibilidad con Flutter 3.47.0 + JDK 17 Temurin 17.0.20.1).
- JDK del proyecto: Temurin 17.0.20.1 (configurado vía `org.gradle.java.home` en `android/gradle.properties`).
- `key.properties`: encoding UTF-8 sin BOM, ruta del keystore relativa (`app/muralito-release-key.jks` desde `android/`).
- `Identidad Android`: confirmada (`com.muralitoapp.app`, `v15` → `v16` → `v17` → `v18` consistente).
- `Discrepancias resueltas`: AGP (9.1.0 → 8.13.0), key.properties encoding (BOM eliminado), ruta keystore (absoluta → relativa), Firma Release (v17 pendiente → v18 validado).
- `Hallazgo a auditar`: durante la validación física del APK release, se detectó un comportamiento reportado en el campo `título` con caracteres `ñ`/`Ñ` que **no coincide con la documentación** (que afirma que `nombreArchivoDesdeTitulo()` permite explícitamente `ñ`/`Ñ`). **No fue reproducido ni confirmado**. Queda pendiente auditoría controlada.

---

## 1. ESTADO ACTUAL

**Estado del proyecto:** MVP funcional avanzado (`Flutter 3.47.0`, `Dart 3.13.0`, `Android SDK 36`). `Supabase` (`PostgreSQL 15+`, `Auth`, `Storage`). `OpenStreetMap` (`flutter_map ^8.3.1`). **APK release compilado y validado físicamente** en dispositivo Android (Infinix X6886).

**Estado de la documentación (`v18`):** Sincronizada con código actual (`mapa_principal_page.dart`, `auth_page.dart`, `recuperar_password_page.dart`, `helpers.dart`, `pubspec.yaml`, `android/app/build.gradle.kts`) y con evidencia física (`flutter run`: `#1`–`#16 PASS`; `flutter build apk --release`: `√ Built`; `apksigner verify`: `Verified using v2/v3 scheme: true`, `Signer #1 certificate DN: CN=Muralito, OU=Muralito, O=Muralito, L=Quito, ST=Pichincha, C=EC`).

**Estado técnico (`archivo recibido` verificado en esta sesión):**

| Área | Estado | Evidencia / Nota |
|---|---|---|
| `DT-Firma-Release` (Keystore + signingConfigs) | ✅ **VALIDADO** (`CERRADO`) | `flutter build apk --release`: `√ Built build\app\outputs\flutter-apk\app-release.apk (53.3MB)`. `flutter build appbundle --release`: `√ Built build\app\outputs\bundle\release\app-release.aab (52.2MB)`. `apksigner verify`: `Verified using v2/v3 scheme: true`, `Signer #1 certificate DN: CN=Muralito, OU=Muralito, O=Muralito, L=Quito, ST=Pichincha, C=EC`. APK instalado en Infinix X6886 y probado físicamente (login, mapa, clustering, CRUD, GPS, Google Maps, Atribución OSM — todo funcional). |
| `DT4` (`email` — `autovalidate` + `Timer 3s`) | 🧪 **VALIDADO** (`CERRADO`) | `auth_page.dart` (`_emailFocusNode.addListener` + `_iniciarTimerErrorEmail`); `recuperar_password_page.dart` (mismo patrón). Ejecución física: `#1`–`#13 PASS`. `flutter analyze`: `No issues found!`. |
| `DT4` (`password` — `DT4-01`) | 🧪 **VALIDADO** (sin regresión) | `_passFocusNode.addListener`. Ejecución: `#6`, `#12 PASS`. |
| `M4` (`Cómo llegar` → `Google Maps`) | 🧪 **VALIDADO** (`CERRADO`) | `mapa_principal_page.dart`: `_abrirComoLlegar` (`URI` `https://www.google.com/maps/dir/?api=1`). Ejecución: `A`–`E PASS`. Probado físicamente en Infinix X6886. |
| `E6` (`Atribución OSM` — `visibilidad` mejorada, opcional) | 🧪 **VALIDADO** (`funcional` + `opcional`) | `fontSize 13`, `fontWeight w600`, `padding 8,4`, `fondo 0xDDF5F5F5`. Probado físicamente. |
| `M6` (`Centrar ubicación`) | 🧪 **VALIDADO PARCIAL** | `M6-01`...`05` y `07` (`PASS`). `M6-06` (`GPS` `apagado` + `sin última ubicación` `conocida`): **NO VERIFICADO** (hardware físico no aislado). |
| `Auth` (`M1` — `contraseña`; `M2` — `OTP`; `DT4-02` — `anti-enumeración`) | 🧪 **VALIDADO** | `auth_page.dart`: `checklist` (`_requisitosContrasena`), `DT4-01`, `DT4`. `recuperar_password_page.dart`: `M2`. `DT4-02`. Probado físicamente. |
| `Perfil` (`trigger` + `avatar`) | 🧪 **VALIDADO** | `public.perfiles`: `trigger` `on_auth_user_created`. `RLS`. `DT2` validado. |
| `CRUD` (`murales`) | 🧪 **VALIDADO** | `public.murales`: `RLS`. Inmutabilidad (`lat`/`lng`). Rollback (`DT1`). Sanitización (`nombreArchivoDesdeTitulo`). |
| `Map` (`flutter_map` + `OSM` + `clustering`) | 🧪 **VALIDADO** | `flutter_map ^8.3.1`. `TileLayer` (`openstreetmap.org`). `Clustering` (`30m`). `_AvisoUI` (`toasts` 3s). `Atribución` (`bottomLeft`, `clickable`). `M4` validado. Probado físicamente. |
| `Identidad Android` (`namespace`/`applicationId`) | 🧪 **VALIDADO** | `android/app/build.gradle.kts`: `namespace = "com.muralitoapp.app"`; `applicationId = "com.muralitoapp.app"`. `MainActivity.kt`: `package com.muralitoapp.app`. |
| `Storage` (`bucket murales` — políticas) | 🧪 **VALIDADO** (funcional) | `B1`, `SELECT`, `INSERT`, `DELETE`. Rollback (`DT1`/`DT2`). Sanitización. ❓ `Políticas SQL` (`CREATE POLICY`) `NO VERIFICADAS` (archivo .sql no disponible). |
| `M5` (`GPS` + `Pin` fijo) | 🧪 **VALIDADO** | `M5-01`...`11` (`PASS`). `Pin` fijo. `GPS` (`timeout` 10s, no bloqueante). |
| `M3` (`Onboarding` ubicación) | 🧪 **VALIDADO** | `4` pruebas manuales (`PASS`). Persistencia (`shared_preferences`). |
| `Sistema Avisos` (`_AvisoUI`) | 🧪 **VALIDADO** | Probado físicamente. |
| `Selector Foto` (`Cámara` / `Galería`) | 🧪 **VALIDADO** | Probado físicamente. |
| `Hallazgo a auditar` (títulos con `ñ`/`Ñ`) | ❓ **REPORTADO — NO REPRODUCIDO** | Durante validación física del APK release, se reportó un fallo al guardar un mural con título conteniendo `ñ`/`Ñ` ("pruebiññaañaña"), mientras que sin `ñ` no falló. **No fue reproducido de forma controlada**. Posibles causas a investigar (no asumir): codificación de `nombreArchivoDesdeTitulo()`, validación del formulario, codificación en Storage/Supabase, coincidencia con error de red. Requiere reproducción controlada antes de afirmar bug. |
| `M9` (`Leaked Passwords` — `HIBP`) | ⛔ **BLOQUEADO** | Requiere plan Supabase Pro. |
| `Tests automatizados` (`DT14` — `flutter test`) | ⏳ **PENDIENTE** | Cobertura funcional manual (`#1`–`#16`) disponible. |
| `Colores hardcodeados` (`Colors.deepPurple`) | ⏳ **PENDIENTE** (deuda estilo) | `~53` refs, `8` archivos. |
| `Firma Release` (`Keystore` `.jks`) | ✅ **CERRADO** | `Keystore` generado, `signingConfig` `release` configurado, APK/AAB compilados, firma verificada, backup externo confirmado. |
| `SMTP` (`Resend` — dominio propio — SPF/DKIM) | ⏳ **PENDIENTE** | |
| `M6-06` (`GPS` — `sin señal` `ni` `última` ubicación) | ❓ **NO VERIFICADO** | |
| `Data Safety` (`Play Store`) | ❓ **NO DOCUMENTADO** | Requisito Play Store; no inventado. |
| `Publicación` (`Data Safety` — `Google Play`) | ❓ **NO DOCUMENTADO** | `archivo recibido` no menciona. |

> ❓ **Nota técnica (`Supabase` — `SQL`/`Console`)**: `No se dispone` de acceso directo a la consola ni a los archivos .sql de Supabase. Las políticas RLS, triggers, políticas de Storage se respaldan por la documentación técnica y por las pruebas de integración funcionales, pero no por evidencia directa del archivo SQL en esta sesión.

---

## 2. FUNCIONALIDADES (`v18` actualizado)

### ✅ HECHO / IMPLEMENTADO (`archivo recibido` + `evidencia física`)

- **`DT-Firma-Release`** (`build.gradle.kts` + `key.properties` + `muralito-release-key.jks`):
  - `android/app/build.gradle.kts`: `import java.util.Properties`, `import java.io.File`, `import org.gradle.api.GradleException`. Bloque `signingConfigs { create("release") { keyAlias, keyPassword, storeFile, storePassword } }` cargado desde `rootProject.file("key.properties")`. `buildTypes { release { signingConfig = signingConfigs.getByName("release") } }`.
  - `android/key.properties`: `storePassword`, `keyPassword`, `keyAlias=muralito`, `storeFile=app/muralito-release-key.jks`. Encoding UTF-8 sin BOM.
  - `android/app/muralito-release-key.jks`: Keystore RSA 2048, validez 10000 días, alias `muralito`, `CN=Muralito, OU=Muralito, O=Muralito, L=Quito, ST=Pichincha, C=EC`.
  - `.gitignore`: `android/key.properties`, `*.jks` (protegidos).
  - `android/gradle.properties`: `org.gradle.java.home=C:/Program Files/Eclipse Adoptium/jdk-17.0.20.101-hotspot`.
  - `android/settings.gradle.kts`: `id("com.android.application") version "8.13.0" apply false` (AGP ajustado).
  - `android/gradle.properties`: `android.newDsl=true` (ajustado).

- **`DT4` (`email` — `autovalidate` reactivo + `Timer 3s`)**: `auth_page.dart` + `recuperar_password_page.dart` (`_emailFocusNode.addListener`, `_mostrarErrorEmail`, `onChanged`, `onTapOutside`, `_enviar`/`_enviarCodigo` `setState` + `_iniciarTimerErrorEmail()`); `Timer` (`_timerErrorEmail`, `Duration(seconds: 3)`); `dispose()`.
- **`DT4` (`password` — `DT4-01`)**: `auth_page.dart` (`_passFocusNode`); `recuperar_password_page.dart` (mismo).
- **`M4` (`Cómo llegar` — `Google Maps`)**: `mapa_principal_page.dart`: `_abrirComoLlegar` (`URI` `https://www.google.com/maps/dir/?api=1&destination=$lat,$lng`; `LaunchMode.externalApplication`).
- **`E6` (`Atribución OSM` — `visibilidad` mejorada, opcional)**: `fontSize 13`, `fontWeight w600`, `padding 8,4`, `fondo 0xDDF5F5F5`; `texto` `© Colaboradores de OpenStreetMap` (mantenido); `enlace` `https://www.openstreetmap.org/copyright` (mantenido).
- **`Mapa` (`flutter_map` + `OSM`)**: `FlutterMap`, `TileLayer` (`urlTemplate`: `https://tile.openstreetmap.org/{z}/{x}/{y}.png`, `userAgentPackageName`: `com.muralitoapp.app`), `MarkerLayer`.
- **`Clustering` (`30m`)**: `_radioClusterMetros` (`30`); `_agruparMuralesCercanos()`; `_centroDelGrupo()`; `_zoomHaciaGrupo()`; `_mostrarGrupoMurales()`.
- **`Pin` (`individual` / `cluster`)**: `_pinMural()`, `_pinCluster()`.
- **`Ficha` (`DraggableScrollableSheet`)**: `_mostrarDetalleMural()`; foto; título; `_filaAutor()` (`A3`); descripción; coordenadas; botones (`Editar`, `Eliminar`, `Cómo llegar`, `Cerrar`).
- **`CRUD` (`mural`)**: `_subirMural()`, `_editarMural()`, `_eliminarMural()`.
- **`Perfil` (`avatar` seguro)**: `_guardarPerfil()` (`DT2`).
- **`Auth` (`M1` — `contraseña` segura)**: `_validarContrasenaRegistro()`; `_requisitosContrasena()`.
- **`Auth` (`M2` — `OTP`)**: `RecuperarPasswordPage`: `_enviarCodigo()`, `_confirmarRecuperacion()`, `_iniciarCooldownReenvio()` (`60s`).
- **`Onboarding` (`M3`)**: `mostrarOnboardingUbicacionSiCorresponde()`.
- **`GPS` (`M5`/`M6`)**: `ubicacion_service.dart`: `obtenerUbicacion()`; `_centrarEnMiUbicacion()`.
- **`Notificaciones` (`_AvisoUI`)**: `_mostrarAviso()`; `_mostrarAvisoUbicacion()`.
- **`Selector` (`Cámara` / `Galería`)**: `_seleccionarOrigenFoto()`.
- **`Sanitización` (`Storage`)**: `helpers.dart`: `nombreArchivoDesdeTitulo()`. ❓ **Hallazgo a auditar**: comportamiento reportado con `ñ`/`Ñ` no coincide con la documentación; requiere reproducción controlada.
- **`Rollback` (`DT1`/`DT2`)**: `_subirMural()`, `_guardarPerfil()`.
- **`Restricción` (`B1`)**: `Storage` (listing restringido).
- **`Identidad` (`namespace`/`applicationId`)**: `com.muralitoapp.app`.

### 🧪 VALIDADO MEDIANTE PRUEBAS

- `DT4` (`auth`): `#1`–`#7 PASS`.
- `DT4` (`recuperación`): `#8`–`#13 PASS`.
- `M4` (`mapa`): `A`–`E PASS`. Probado en Infinix X6886.
- `E6` (`Atribución`): `D PASS`.
- `DT-Firma-Release`: APK release compilado e instalado en Infinix X6886. `apksigner verify`: `Verified using v2/v3 scheme: true`, `Signer #1 certificate DN: CN=Muralito, OU=Muralito, O=Muralito, L=Quito, ST=Pichincha, C=EC`.
- `Regresión` general: `#14`–`#16 PASS`; build limpio.

### ⏳ PENDIENTE (`v18` — no modificados en esta actualización)

- `M6-06` (`GPS` sin señal ni última ubicación): `NO VERIFICADO`.
- `Colores` (`Colors.deepPurple` — ~53 refs): `PENDIENTE`.
- `DT8` (`Storage` — `borrarFotoDeStorage` `uri.pathSegments.last`): `RIESGO`.
- `DT10` (`God-page` — `mapa_principal_page.dart`): `RIESGO`.
- `DT11`/`DT12` (`Repository`): `PENDIENTE`.
- `DT14` (`Tests` automatizados): `PENDIENTE`.
- `M9` (`Leaked Passwords`): `BLOQUEADO`.
- `SMTP` (`Resend` — dominio propio): `PENDIENTE`.
- `Data Safety` (`Play Store`): `NO DOCUMENTADO`.
- `M17` (`Borradores` offline): `PENDIENTE` (post-v1).
- `A4` (`Uploader` ≠ `Artista`): `PENDIENTE` (producto).
- `A1.4` (`Historial` fotos — `6` días): `PENDIENTE` (producto + Storage subrutas).
- Hallazgo a auditar: títulos con `ñ`/`Ñ` (reportado, no reproducido).

### ❓ NO VERIFICADO / REQUIERE VERIFICACIÓN

- `M6-06` (`GPS` — caso borde no aislado hardware).
- `Supabase` (`RLS` SQL — `CREATE POLICY`, `trigger`, `Storage policies` — archivo .sql no disponible).
- `Data Safety` (`Play Store` — requisito; no inventado).
- `IM` (`TextInputAction` `Next` — `DT4` `email`: funciona estándar; otros no probados).
- Hallazgo reportado: comportamiento de `nombreArchivoDesdeTitulo()` o validación con `ñ`/`Ñ`.

---

## 3. DEUDA TÉCNICA (`v18` actualizado)

### Confirmada y resuelta

| ID / Elemento | Estado anterior | Estado (`v18`) | Evidencia |
|---|---|---|---|
| `DT-Firma-Release` (Keystore + signingConfig) | ⏳ `PENDIENTE` (v17) | ✅ `VALIDADO` (`CERRADO`) | `flutter build apk --release`: `√ Built`. `apksigner verify`: firma V2/V3 válida. Probado en Infinix X6886. |
| `Firma Release` (bloqueante Play Store) | ⏳ `PENDIENTE` (v17) | ✅ `CERRADO` (v18) | Keystore generado, backup externo confirmado. |
| `DT4` (`email` — `autovalidate`) | ✅ `CERRADO` (v17) | ✅ `VALIDADO` (v18, sin regresión) | `#1`–`#5`, `#9`, `#10 PASS`. |
| `DT4` (`email` — `"Siguiente"`) | ✅ `CERRADO` (v17) | ✅ `VALIDADO` (v18) | `#1`, `#8 PASS`. |
| `DT4` (`Timer`) | ✅ `CERRADO` (v17) | ✅ `VALIDADO` (v18) | `#2`, `#5`, `#9`, `#10 PASS`. |
| `DT4` (`password` — `DT4-01` — regresión) | ✅ `CERRADO` (v17) | ✅ `VALIDADO` (v18) | `#6`, `#12 PASS`. |
| `M4` (`Cómo llegar` — `Google Maps`) | ✅ `CERRADO` (v17) | ✅ `VALIDADO` (v18) | `A`–`E PASS`; probado en Infinix X6886. |
| `Identidad Android` | ✅ `CERRADO` (v16/v17) | ✅ `VALIDADO` (v18) | `com.muralitoapp.app`. |
| `Atribución OSM` (`v16` — integración) | ✅ `CERRADO` (v16) | ✅ `VALIDADO` (v18) | `bottomLeft` funcional. |
| `E6` (`Atribución` — visibilidad mejorada) | ✅ `CERRADO` (v17) | ✅ `VALIDADO` (v18) | `D PASS`. |

### Confirmada pendiente (`v18` — no modificada)

- `M6-06`, `Colores`, `DT8`, `DT10`, `DT11`/`DT12`, `DT14`, `M9`, `M17`, `A4`, `A1.4`, `SMTP`, `Data Safety`.
- Hallazgo a auditar: títulos con `ñ`/`Ñ`.

---

## 4. RIESGOS (`v18` actualizado)

### `Supabase` (`PostgreSQL`, `Auth`, `Storage`, `RLS`)
- **Estado**: `NO MODIFICADO` (archivo recibido intacto).
- **`RLS`**: `VALIDADO` funcional. ❓ `SQL` `NO VERIFICADO`.
- **`Storage`**: `VALIDADO` funcional. ❓ `SQL` `NO VERIFICADO`.
- **`Auth`**: `VALIDADO`. `DT4` `VALIDADO`.

### `Auth` (`email` — `DT4`)
- **Mitigado**: `addListener` + `Timer` (`3s`) + `dispose()`.

### `Auth` (`password` — `DT4-01`)
- **Sin regresión**: `_passFocusNode` intacto.

### `Android` (`Identidad`, `Atribución`)
- **`namespace`/`applicationId`**: `VALIDADO`.
- **`Atribución` (`OSM`)**: `VALIDADO`.

### `Android` (`Release`)
- **`Keystore` (`.jks`)**: ✅ `CERRADO` (v18). Backup externo confirmado.

### `Rendimiento` (`mapa_principal_page.dart`)
- **`Clustering` (`O(n²)`)**: `RIESGO` (no resuelto).

### `Escalabilidad` / `Arquitectura`
- **`Repository` (`DT11`/`DT12`)**: `PENDIENTE`.
- **`Storage` (`DT8`)**: `RIESGO`.

### `Publicación` (`Play Store`)
- **`Data Safety`**: `NO DOCUMENTADO`.
- **`SMTP`**: `PENDIENTE`.

---

## 5. DISCREPANCIAS (`v18` actualizado)

### Resueltas

- **`AGP`** (`9.1.0` → `8.13.0`): `RESUELTA` (compatibilidad Flutter 3.47.0 + JDK 17).
- **`JDK del proyecto`** (JDK 25 → Temurin 17.0.20.1): `RESUELTA`.
- **`key.properties encoding`** (BOM eliminado): `RESUELTA`.
- **`ruta keystore`** (absoluta → relativa `app/muralito-release-key.jks`): `RESUELTA`.
- **`DT-Firma-Release`**: `RESUELTA`.
- **`Firma Release`**: `RESUELTA`.
- **`Identidad Android`**, **`DT4`**, **`M4`**, **`E6`**: consistentes.

### Persisten (`v18` — no resueltas en esta actualización)

- **`M6-06`**: `NO RESUELTO`.
- **`Colores`**: `NO RESUELTO`.
- **`DT10`**: `NO RESUELTO`.
- **`DT8`**: `NO RESUELTO`.
- **`DT11`/`DT12`**: `NO RESUELTO`.
- **`DT14`**: `NO RESUELTO`.
- **`M9`**: `NO RESUELTO`.
- **`SMTP`**: `NO RESUELTO`.
- **`Data Safety`**: `NO DOCUMENTADO`.
- **`Supabase SQL`**: `NO VERIFICADO`.
- **Hallazgo a auditar**: títulos con `ñ`/`Ñ` (reportado, no reproducido).

---

## 6. SIGUIENTE OBJETIVO (`v18` actualizado)

Según `Documentación Técnica v17`, §16; `Mejoras v17`, §7; `Handoff Técnico v007`, §16.

**Estado (`v18`)**:
- `DT-Firma-Release`: `CERRADO` (validado físicamente).
- `DT4`: `CERRADO`.
- `M4`: `CERRADO`.
- `E6`: `VALIDADO`.

**Candidatos vigentes (`Mejoras v17`, §7, §10)**:

> **`Data Safety (Play Store)`** — Requisito previo a publicación en Google Play. No documentado en archivo recibido ni en Mejoras v17. Necesita investigación (qué datos recopila Muralito: ubicación, fotos, perfil, email; cómo se almacenan; si se comparten con terceros; tiempo de retención).

> **`Colores hardcodeados`** (`~53` referencias, `8` archivos) — Estilo, no bloqueante.

> **`M17 (Borradores offline)`** — Mejora de producto detectada durante validación física (sugerencia del dev: si falla la subida, recuperar el borrador para no repetir título/descripción/foto/ubicación).

> **`Hallazgo a auditar`**: títulos con `ñ`/`Ñ` — reproducción controlada antes de afirmar bug.

**Recomendación (`Mejoras v17`, §10; `Handoff Técnico v007`, §16)**:
Priorizar **`Data Safety`** (requisito Play Store) antes de **`M17`** (mejora de producto) o **`Colores`** (estético). Firma Release ya no bloquea publicación.

---

## 7. AUDITORÍA PREVIA (`v18`)

### Deuda técnica activa (`v18` actualizado)

- [ ] **`M6-06`** — Pruebas controladas con GPS apagado + sin historial.
- [ ] **`Colores`** — Auditoría de uso real de `Colors.deepPurple` (grep en `lib/`); refactor gradual a `Theme.of(context).colorScheme`.
- [ ] **`DT8`** — Revisar `borrarFotoDeStorage` en `helpers.dart`; decidir ruta relativa o extracción de `pathSegments.last`.
- [ ] **`DT10`** — Medir tamaño real de `mapa_principal_page.dart` (líneas, funciones); planificar extracción.
- [ ] **`DT11`/`DT12`** — Definir capa Repository; extraer `supabase_client.dart` directo.
- [ ] **`DT14`** — Definir casos de prueba basados en evidencia manual `#1`–`#16`.
- [ ] **`M9`** — Evaluar migración a Supabase Pro si HIBP es prioridad.
- [ ] **`SMTP`** — Configurar dominio propio + SPF/DKIM.
- [ ] **`Data Safety`** — Documentar recopilación, almacenamiento, retención, compartición de datos.
- [ ] **`Hallazgo a auditar`** — Reproducir fallo con `ñ`/`Ñ` en condiciones controladas; revisar `helpers.dart::nombreArchivoDesdeTitulo`, `_subirMural()`, validación en `formulario_mural_modal.dart`.

### Firma Release (`v18` — `CERRADO`)

- [x] `android/app/muralito-release-key.jks` generado.
- [x] `android/key.properties` creado (UTF-8 sin BOM, ruta relativa).
- [x] `android/app/build.gradle.kts` con `signingConfigs.release` y `buildTypes.release.signingConfig` apuntando a `release`.
- [x] `.gitignore` actualizado (`android/key.properties`, `*.jks`).
- [x] `android/gradle.properties` con `org.gradle.java.home` apuntando a Temurin 17.
- [x] `android/settings.gradle.kts` con AGP 8.13.0.
- [x] `flutter build apk --release`: `√ Built build\app\outputs\flutter-apk\app-release.apk (53.3MB)`.
- [x] `flutter build appbundle --release`: `√ Built build\app\outputs\bundle\release\app-release.aab (52.2MB)`.
- [x] `apksigner verify --print-certs`: `Signer #1 certificate DN: CN=Muralito, OU=Muralito, O=Muralito, L=Quito, ST=Pichincha, C=EC`, `Verified using v2/v3 scheme: true`.
- [x] APK instalado y probado en Infinix X6886 (login, mapa, CRUD, GPS, Google Maps, Atribución OSM — todo funcional).
- [x] Backup externo del `.jks` confirmado.

### General (`Proyecto` — `v18` actualizado)

- [x] `DT4`: `VALIDADO`.
- [x] `M4`: `VALIDADO`.
- [x] `E6`: `VALIDADO`.
- [x] `DT-Firma-Release`: `VALIDADO`.
- [x] `M6-06`: `NO VERIFICADO`.
- [x] `Colores`: `PENDIENTE`.
- [x] `DT10`: `RIESGO`.
- [x] `Firma Release`: `CERRADO`.
- [x] `Documentación`: `v18` (este bloque) actualizado.

---

## CIERRE (`v18` — `Estado final`)

- **`DT-Firma-Release`**: `CERRADO` (`VALIDADO` físicamente: APK release compilado, instalado en Infinix X6886, firma V2/V3 verificada con `apksigner`).
- **`DT4`**: `CERRADO`.
- **`M4`**: `CERRADO`.
- **`E6`**: `ACTUALIZADO`.
- **`Archivo recibido` (`mapa_principal_page.dart`)**: `Modificado` (`M4`); resto intacto.
- **`Archivo recibido` (`auth_page.dart`, `recuperar_password_page.dart`)**: `Modificado` (`DT4`); resto intacto.
- **`Archivo recibido` (`android/app/build.gradle.kts`)**: `Modificado` (Firma Release); resto intacto.
- **`Archivo recibido` (`android/settings.gradle.kts`, `android/gradle.properties`)**: `Modificado` (AGP 8.13.0, JDK 17, newDsl true).
- **`Documentación` (`v18`)**: Este bloque (completo) para copiar/pegar.
- **`Siguiente` (recomendado)**: `Data Safety (Play Store)`.
- **`Siguiente` (alternativo)**: `M17 (Borradores offline)` o `Colores`.
- **`Hallazgo a auditar`**: títulos con `ñ`/`Ñ` (reportado, no reproducido).
