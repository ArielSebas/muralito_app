# Muralito App — Backlog Priorizado

**Versión:** 18 (post-DT-Firma-Release — cierre de la barrera técnica de publicación)
**Fecha:** 2026-09-27
**Actualiza:** Mejoras_v17 (27/09/2026).
**Estado actual:** MVP funcional avanzado — APK/AAB release validados en Infinix X6886; firma V2/V3 verificada con `apksigner verify`. DT4 (autovalidate reactivo + Timer 3s), M4 (Cómo llegar → Google Maps nativo) y E6 (Atribución OSM — visibilidad mejorada, opcional) cerrados. Hallazgo reportado con `ñ`/`Ñ` en títulos (no reproducido, pendiente auditoría controlada).

**Referencia documental sincronizada:** Documentación Técnica v18 (27/09/2026), Flujos Funcionales v15 (27/09/2026), README.md, Handoff Técnico v007 (27/09/2026).

---

## Cambios formales v17 → v18

- **`DT-Firma-Release`** (Keystore + signingConfigs.release + key.properties): **IMPLEMENTADO, CERRADO Y VALIDADO**. Keystore RSA 2048 generado (alias `muralito`, validez 10 000 días, CN=Muralito, OU=Muralito, O=Muralito, L=Quito, ST=Pichincha, C=EC). APK release (53.3 MB) y AAB release (52.2 MB) compilados; firma V2/V3 verificada con `apksigner verify`. APK instalado y probado en Infinix X6886 (login, mapa, clustering, CRUD, GPS, Google Maps, Atribución OSM — todo funcional).
- **`Firma Release`** cerrada como bloqueante de Play Store. Backup externo del `.jks` confirmado. Contraseña final cambiada después de la sesión (la inicial se expuso durante el troubleshooting).
- **AGP ajustado**: `9.1.0` → `8.13.0` (compatibilidad Flutter 3.47.0 + JDK 17).
- **JDK del proyecto**: Temurin `17.0.20.1` (`org.gradle.java.home` en `android/gradle.properties`).
- **`key.properties`**: UTF-8 sin BOM; ruta del keystore relativa (`app/muralito-release-key.jks` desde `android/`).
- **Identidad Android**: confirmada (`com.muralitoapp.app`, versiones `v15` → `v16` → `v17` → `v18` consistente).
- **Discrepancias resueltas**: AGP (9.1.0 → 8.13.0), `key.properties` (BOM eliminado), ruta keystore (absoluta → relativa), Firma Release (pendiente → validado).
- **Hallazgo a auditar**: durante la validación física del APK release se detectó un comportamiento reportado en el campo `título` con caracteres `ñ`/`Ñ` que **no coincide con la documentación** (que afirma que `nombreArchivoDesdeTitulo()` permite explícitamente `ñ`/`Ñ`). **NO FUE REPRODUCIDO NI CONFIRMADO**. Queda pendiente auditoría controlada.
- **Próximo objetivo técnico recomendado**: `Data Safety` (Play Store) — requisito editorial previo a publicación. La barrera técnica de compilación ya no bloquea; el siguiente bloqueo es de cumplimiento.

---

## Últimas funcionalidades implementadas (v18 — evidencia física `#1`–`#16 PASS` + `apksigner verify`)

- **`DT-Firma-Release`** (`Firma Release`):
  - `android/app/build.gradle.kts`: `import java.util.Properties`, `import java.io.File`, `import org.gradle.api.GradleException`. Bloque `signingConfigs { create("release") { keyAlias, keyPassword, storeFile, storePassword } }` cargado desde `rootProject.file("key.properties")`. `buildTypes { release { signingConfig = signingConfigs.getByName("release") } }`.
  - `android/key.properties`: `storePassword`, `keyPassword`, `keyAlias=muralito`, `storeFile=app/muralito-release-key.jks`. Encoding UTF-8 sin BOM.
  - `android/app/muralito-release-key.jks`: Keystore RSA 2048, validez 10 000 días, alias `muralito`, CN=Muralito, OU=Muralito, O=Muralito, L=Quito, ST=Pichincha, C=EC.
  - `.gitignore`: `android/key.properties`, `*.jks` (protegidos).
  - `android/gradle.properties`: `org.gradle.java.home=C:/Program Files/Eclipse Adoptium/jdk-17.0.20.101-hotspot`.
  - `android/settings.gradle.kts`: `id("com.android.application") version "8.13.0" apply false` (AGP ajustado).
  - `android/gradle.properties`: `android.newDsl=true` (ajustado).
  - **Estado**: `VALIDADO` (`CERRADO`). `flutter build apk --release`: `√ Built build\app\outputs\flutter-apk\app-release.apk (53.3MB)`. `flutter build appbundle --release`: `√ Built build\app\outputs\bundle\release\app-release.aab (52.2MB)`. `apksigner verify --print-certs`: `Signer #1 certificate DN: CN=Muralito, OU=Muralito, O=Muralito, L=Quito, ST=Pichincha, C=EC`, `Verified using v2/v3 scheme: true`.

- **`DT4` (`email` — `autovalidate` `reactivo` + `Timer` `3s`)**:
  - `auth_page.dart`: `FocusNode` (`_emailFocusNode`) con `addListener` (`_alCambiarFocoEmail`); limpieza `onChanged` (`_mostrarErrorEmail`); `Timer` (`_iniciarTimerErrorEmail`, `Duration(seconds: 3)`); `dispose` (`_timerErrorEmail?.cancel()` + `removeListener` + `.dispose()`).
  - `recuperar_password_page.dart`: mismo patrón (`_emailFocusNode` `addListener`, `_mostrarErrorEmail`, `_iniciarTimerErrorEmail`, `dispose`).
  - **Estado**: `VALIDADO` (`CERRADO`). `#1` (`Siguiente` visible — `PASS`); `#2` (`Timer` 3s — `PASS`); `#3` (`escribir` limpia — `PASS`); `#4` (`vacío` + `botón` bloquea + `Timer` — `PASS`); `#5` (`Timer` tras vacío — `PASS`); `#8` (recuperación `Siguiente` — `PASS`); `#9` (`Timer` 3s — `PASS`); `#10` (bloqueo + `Timer` — `PASS`).

- **`M4` (`Cómo llegar` → `Google Maps` `nativo`)**:
  - `mapa_principal_page.dart`: `_abrirComoLlegar` (`Future<void>`; `final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');`; `await launchUrl(uri, mode: LaunchMode.externalApplication);`).
  - **Restricción** (v17 §16; Documentación Técnica v18 §5): `OpenStreetMap` (`mapa` interno — `flutter_map` `TileLayer` `openstreetmap.org`) NO SE REEMPLAZA; Atribución (`bottomLeft` — `© Colaboradores`) INTACTA.
  - **Estado**: `VALIDADO` (`CERRADO`). `A` (`botón` existe — `PASS`); `B` (`mapa` OSM funciona — `PASS`); `C` (`Google Maps` abre — `PASS`); `D` (Atribución intacta — `PASS`); `E` (regresión `clustering`/`ficha`/`FAB`/`Avisos`/`Auth` — `PASS`).

- **`E6` (`Atribución OSM` — `visibilidad` mejorada, opcional)**:
  - `mapa_principal_page.dart`: `fontSize: 13` (anterior: 11); `fontWeight: FontWeight.w600` (anterior: normal); `padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4)` (anterior: 6, 3); `fondo: Color(0xDDF5F5F5)` (anterior: 0xCCFFFFFF).
  - **Restricción** (v17 §5.2; Documentación Técnica v18 §5.2): `Texto` (`© Colaboradores de OpenStreetMap`) MANTENIDO; `Enlace` (`copyright`) MANTENIDO; sin prefijo (`flutter_map | ` DESCARTADO).
  - **Estado**: `VALIDADO` (funcional intacto + opcional aplicado). `D PASS` (`texto`/`click` mantenido); funcional (`mapa` `clustering` intacto).

---

## Últimas correcciones y tareas cerradas (v18)

- **`DT-Firma-Release`** (Firma Release): `Implementada` (`signingConfigs.release` + `key.properties` + `muralito-release-key.jks` + AGP 8.13.0 + JDK Temurin 17) + `Validada` (`apksigner verify` V2/V3 + APK/AAB compilados + probado en Infinix X6886). Backup externo del `.jks` confirmado.
- **`DT4`** (`email` — `autovalidate` reactivo): `Implementada` (`auth_page.dart` + `recuperar_password_page.dart`: `addListener`, `Timer`, `dispose`) + `Validada` (`#1`–`#13 PASS`).
- **`DT4`** (`Timer`) (`3s`): `Implementado` (`_iniciarTimerErrorEmail`) + `Validado` (`#2`, `#5`, `#9`, `#10 PASS`).
- **`M4`** (`Cómo llegar`) (`Google Maps` nativo): `Implementado` (`_abrirComoLlegar` URI actualizado) + `Validado` (`A`–`E PASS`).
- **`M4`** (`restricción` mapa intacto): `Confirmada` (`OpenStreetMap` como motor interno; `TileLayer` `openstreetmap.org`; `clustering` 30m; Atribución `bottomLeft`).
- **`E6`** (Atribución — visibilidad opcional): `Actualizada` (`fontSize` 13, `w600`, `padding` 8,4, `fondo` 0xDDF5F5F5) — funcional `VALIDADO` (`D PASS`).
- **`Identidad`** (`namespace`/`applicationId`): `Confirmada` (`com.muralitoapp.app` alineado — v15 §16).

---

## Hallazgos pendientes sin resolver (v18 — `no modificados`)

- **Hallazgo `ñ`/`Ñ`** (títulos): ❓ REPORTADO — NO REPRODUCIDO. Durante validación física del APK release, un título con `ñ`/`Ñ` ("pruebiññaañaña") no se pudo guardar; sin `ñ` no falló. La documentación afirma que `nombreArchivoDesdeTitulo()` permite explícitamente `ñ`/`Ñ` (`RegExp` `[^a-zA-Z0-9áéíóúÁÉÍÓÚñÑ_-]` → `_`). No se reproduce de forma controlada. Posibles causas (no asumir): codificación real del helper, validación del formulario, codificación en Storage/Supabase, coincidencia con error de red. **Requiere auditoría controlada antes de afirmar bug.**
- **`M6-06`** (`GPS` sin señal ni última ubicación conocida): `NO VERIFICADO` (hardware físico no aislado — Documentación Técnica v18 §7; Flujos Funcionales v15 §19).
- **`Remitente SMTP`** (`Resend`): `onboarding@resend.dev` — `PENDIENTE` (dominio propio con SPF/DKIM antes de evaluadores externos).
- **`Colores hardcodeados`** (`Colors.deepPurple`): ~53 referencias, 8 archivos — `PENDIENTE` (estilo — `mapa_principal_page.dart`: FAB, Avisos, pin; `auth_page.dart`: Icon; Documentación Técnica v18 §3).
- **`DT10`** (`God-page` — `mapa_principal_page.dart`): `RIESGO` (concentración mapa/`clustering`/`auth`/`Supabase`/UI) — M4 (`URI` independiente) NO AUMENTA; DT4 (`email`) NO AUMENTA.
- **`Data Safety`** (Play Store): ❓ NO DOCUMENTADO. Requisito editorial previo a publicación; investigar recopilación (ubicación, fotos, perfil, email), almacenamiento, retención y compartición de datos.

---

## 1. Hecho — no reabrir (v18 `VALIDADO` — `archivo recibido` intacto funcional)

| ID / Componente | Qué se implementó / validó | Evidencia (`archivo recibido` + física) |
|---|---|---|
| `DT-Firma-Release` (Firma Release) | Keystore RSA 2048 (`muralito`, 10 000 días) + `signingConfigs.release` + `key.properties` (UTF-8 sin BOM) + AGP 8.13.0 + JDK Temurin 17 | `flutter build apk --release` `√ Built`; `flutter build appbundle --release` `√ Built`; `apksigner verify`: `Verified using v2/v3 scheme: true`; APK instalado y probado en Infinix X6886 |
| `DT4` (`email` — `autovalidate` + `Timer`) | `auth_page.dart` + `recuperar_password_page.dart`: `addListener` (`_emailFocusNode`), `Timer` (`3s`), `dispose` (`cancel` + `removeListener`) | `#1`–`#7` (`auth` `PASS`); `#8`–`#13` (recuperación `PASS`) |
| `DT4` (`password` — `DT4-01` — regresión) | Mitigada: `_passFocusNode` `addListener` intacto; `checklist` `_requisitosContrasena` operativo | `#6`, `#12` (`PASS`) |
| `M4` (`Cómo llegar` — `Google Maps`) | `mapa_principal_page.dart`: `_abrirComoLlegar` (URI: `google.com/maps/dir/?api=1`) — `VALIDADO` (`A`–`E PASS`) | `archivo recibido`: URI actualizado; `mapa` OSM intacto; Atribución intacta |
| `E6` (Atribución — visibilidad opcional mejorada) | `mapa_principal_page.dart`: `fontSize` 13, `w600`, `padding` 8,4, `fondo` 0xDDF5F5F5 — funcional `VALIDADO` (`D PASS`) | `archivo recibido`: `texto` `© Colaboradores` mantenido; `click` `copyright` mantenido |
| `Identidad Android` (`namespace`/`applicationId`) | `com.muralitoapp.app` (`build.gradle.kts` + `MainActivity.kt`) | v15 §16 |
| `Atribución OSM` (v16 — integración + opcional) | `bottomLeft` (`Align`), `texto` `© Colaboradores`, `click` (`copyright`), sin prefijo (`flutter_map`) | v15 §16; `archivo recibido`: intacto + opcional actualizado |
| `Flujos Funcionales` (v13 → v15) | Actualizado: DT4 (autovalidate reactivo + Timer), M4 (Google Maps), E6 (visibilidad opcional); Firma Release (v18); resto (`mapa`, `clustering`, FAB, Avisos, Ficha, CRUD, Perfil) intacto | `archivo recibido`: `mapa_principal_page.dart` funcional `PASS` `E` (`clustering`/`ficha`/`FAB`/`Avisos`/`Auth`) |
| `Regresiones` (v12/v16 funcionales + DT4/M4/v17 + Firma Release v18) | `PASS` (`#1`–`#16`): DT4 (email autovalidate + Timer 3s + Siguiente visible); password DT4-01 (sin regresión); `mapa` (OSM intacto + clustering); FAB (Mi ubicación + Nuevo Mural); Avisos (Toast superior 3s); Ficha (A3 intacto + Cómo llegar Google Maps); Auth (Login/Registro funcional); Firma Release (APK/AAB + `apksigner verify`); Build (`No issues found!`) | `archivo recibido`: `mapa_principal_page.dart` (URI M4 + estilo E6); `auth_page.dart` (DT4); `recuperar_password_page.dart` (DT4); `flutter analyze`: `PASS` |

Estas funcionalidades **no deben reabrirse** salvo evidencia de regresión técnica (`archivo recibido` funcional `PASS` `E`) o cambios regulatorios (Atribución OSM política tiles intacta).

---

## 2. Cierres formales (v18 — `archivo recibido` actualizado DT4/M4/E6 + Firma Release)

### 2.1 `DT-Firma-Release` (Firma Release — Keystore + signingConfig.release + APK/AAB release)
**Estado**: `VALIDADO` (`CERRADO`).
**Implementación** (`archivo recibido` — sesión Firma Release v18):
- `android/app/build.gradle.kts`: `import java.util.Properties`, `import java.io.File`, `import org.gradle.api.GradleException`. Bloque `signingConfigs { create("release") { keyAlias, keyPassword, storeFile, storePassword } }` cargado desde `rootProject.file("key.properties")`. `buildTypes { release { signingConfig = signingConfigs.getByName("release") } }`.
- `android/key.properties`: `storePassword`, `keyPassword`, `keyAlias=muralito`, `storeFile=app/muralito-release-key.jks`. Encoding UTF-8 sin BOM.
- `android/app/muralito-release-key.jks`: Keystore RSA 2048, validez 10 000 días, alias `muralito`, CN=Muralito, OU=Muralito, O=Muralito, L=Quito, ST=Pichincha, C=EC.
- `android/gradle.properties`: `org.gradle.java.home=C:/Program Files/Eclipse Adoptium/jdk-17.0.20.101-hotspot`.
- `android/settings.gradle.kts`: `id("com.android.application") version "8.13.0" apply false` (AGP ajustado).
- `android/gradle.properties`: `android.newDsl=true` (ajustado).
- `.gitignore`: `android/key.properties`, `*.jks` (protegidos).
**Validación** (`evidencia física` + comandos):
- `flutter build apk --release`: `√ Built build\app\outputs\flutter-apk\app-release.apk (53.3MB)`.
- `flutter build appbundle --release`: `√ Built build\app\outputs\bundle\release\app-release.aab (52.2MB)`.
- `apksigner verify --print-certs`: `Signer #1 certificate DN: CN=Muralito, OU=Muralito, O=Muralito, L=Quito, ST=Pichincha, C=EC`, `Verified using v2/v3 scheme: true`.
- APK release instalado en Infinix X6886 y probado físicamente (login, mapa, clustering, CRUD, GPS, Google Maps, Atribución OSM — todo funcional).
- Backup externo del `.jks` confirmado; contraseña final cambiada tras la sesión (la inicial se expuso durante troubleshooting).
**Restricción** (v18; Handoff Técnico v007 §19): `No modificar` el keystore sin actualizar el backup externo; `no compartir` `key.properties` ni `.jks` por chat ni por repositorio.

### 2.2 `DT4` (`email` — `autovalidate` reactivo + `Timer 3s`)
**Estado**: `VALIDADO` (`CERRADO` como pendiente; funcional).
**Implementación** (`archivo recibido` `auth_page.dart` + `recuperar_password_page.dart`):
- `_emailFocusNode`: `addListener` (`_alCambiarFocoEmail`) — captura transición `Next`.
- `TextFormField` (`email`): `keyboardType` `emailAddress`; `autovalidateMode` `disabled`; `onChanged`: limpia; `onTapOutside`: muestra error (`email.isEmpty || !email.contains('@')`).
- `_mostrarErrorEmail`: `bool`; `setState` (`_enviar`/`_enviarCodigo`: `email.isEmpty || !email.contains('@')` → `true` + `_iniciarTimerErrorEmail()` si `true`).
- `_timerErrorEmail`: `Timer?` (`_timerErrorEmail?.cancel()` previo en `_iniciarTimerErrorEmail`).
- `_iniciarTimerErrorEmail()`: `Timer(const Duration(seconds: 3), () { if (mounted) setState(() => _mostrarErrorEmail = false); });`.
- `dispose`: `_timerErrorEmail?.cancel()`; `_emailFocusNode.removeListener(_alCambiarFocoEmail)`; `_emailFocusNode.dispose()`.
**Validación** (`evidencia física` `#1`–`#13 PASS`):
- `#1` (`auth` — `Siguiente` visible — `PASS`).
- `#2` (`auth` — `Timer` 3s — `PASS`).
- `#3` (`auth` — escribir limpia — `PASS`).
- `#4` (`auth` — vacío + botón bloquea + `Timer` — `PASS`).
- `#5` (`auth` — `Timer` tras vacío — `PASS`).
- `#8` (recuperación — `Siguiente` paso 1 — `PASS`).
- `#9` (recuperación — `Timer` 3s — `PASS`).
- `#10` (recuperación — vacío + `Enviar código` bloquea + `Timer` — `PASS`).
**Restricción** (v16 §10; v16 §4): `No modificar` validación formato email (`RegExp`); `no modificar` llamada `Supabase` (`signUp`/`signIn`/`resetPasswordForEmail`); `no modificar` respuesta anti-enumeración (`DT4-02`).

### 2.3 `M4` (`Cómo llegar` — `Google Maps` nativo)
**Estado**: `VALIDADO` (`CERRADO` como pendiente; funcional).
**Implementación** (`archivo recibido` `mapa_principal_page.dart`):
- Función `_abrirComoLlegar(double lat, double lng)`: `Future<void>`.
- URI: `https://www.google.com/maps/dir/?api=1&destination=$lat,$lng` (anterior: `https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=18/$lat/$lng`).
- `LaunchMode`: `LaunchMode.externalApplication`.
- Manejo error: `if (!mounted) return;` (mantenido); `if (!ok) { _mostrarAviso('No se pudo abrir Google Maps. Coordenadas: ...', tipo: _TipoAviso.error); }`.
**Restricción** (v16 §16; v16 §5; Flujos Funcionales v15 §12):
- `Mantener` `OpenStreetMap` (`flutter_map`, `TileLayer`, `clustering`, Atribución) como motor interno (NO reemplazado).
- Atribución (`bottomLeft`) intacta: `texto` (`© Colaboradores`), `click` (`copyright`), `fondo`, `padding`, `font` (opcional mejorado E6), sin prefijo (`flutter_map | ` descartado).
**Validación** (`A`–`E PASS` físico):
- `A`: Botón `"Cómo llegar"` (`FilledButton.icon` `purple` — `archivo recibido`) existe — `PASS`.
- `B`: Mapa (`flutter_map` OSM — `TileLayer` intacto + `clustering` 30m funcional) — `PASS`.
- `C`: Google Maps (URI `google.com/maps` — abre app nativa o navegador fallback) — `PASS`.
- `D`: Atribución (`bottomLeft`: texto mantenido; click `copyright` funciona; opcional mejorado visible) — `PASS`.
- `E`: Regresión (mapa interactivo intacto; clustering funcional; FAB (`Nuevo Mural`/`Mi ubicación`) anclado; Avisos (`_AvisoUI`) operativo; Ficha (`DraggableScrollableSheet`) funcional; Auth (`AppBar` avatar/apodo dinámico) intacto) — `PASS`.

### 2.4 `E6` (`Atribución OSM` — visibilidad opcional mejorada)
**Estado**: `VALIDADO` (funcional intacto + opcional mejorado — `archivo recibido` `mapa_principal_page.dart`).
**Implementación** (`archivo recibido`):
- Alineación: `Align(alignment: Alignment.bottomLeft)` (mantenida).
- Fondo: `ColoredBox(color: Color(0xDDF5F5F5))` (opcional: anterior 0xCCFFFFFF).
- Contenido: `InkWell` (`onTap`: `https://www.openstreetmap.org/copyright` — mantenido).
- Texto: `Text('© Colaboradores de OpenStreetMap', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87))` (opcional: anterior `fontSize: 11`, `fontWeight: normal`, `color: black87`).
- Padding: `Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), ...)` (opcional: anterior `horizontal: 6`, `vertical: 3`).
- Restricción: sin prefijo (`flutter_map | ` descartado) — mantenido.
**Estado**: Opcional (funcional cumple política OSM — v16 §5.2; `archivo recibido` funcional `PASS` `D`). `No requiere` prueba física adicional (`D PASS` confirma funcional); visibilidad mejorada opcional (`archivo recibido` actualizado).

### 2.5 `Identidad Android` (`namespace`/`applicationId`)
**Estado**: `VALIDADO` (v15 discrepancia resuelta formalmente — v15 §16).
**Evidencia** (`archivo recibido` — referencia v16):
- `android/app/build.gradle.kts`: `namespace = "com.muralitoapp.app"`; `applicationId = "com.muralitoapp.app"`.
- `android/app/src/main/kotlin/com/muralitoapp/app/MainActivity.kt`: `package com.muralitoapp.app`.

### 2.6 `Atribución OSM` (v16 — integración)
**Estado**: `VALIDADO` (`archivo recibido` `mapa_principal_page.dart` — `bottomLeft` funcional `PASS` `D`).
**Restricción** (v16 §16; Documentación Técnica v18 §5.2): No prefijo (`flutter_map | ` descartado); texto `© Colaboradores`; enlace `copyright` (`LaunchMode.externalApplication`); visibilidad (`bottomLeft` — funcional).

---

## 3. Alta de mural (v18 — `archivo recibido` `mapa_principal_page.dart` intacto + v16 actualizado + DT4 independiente)

### 3.1 `Producto` — `A4` (`Diferencia Uploader ≠ Artista`) — `PENDIENTE` (v16 §3; Documentación Técnica v18 §20)
- **Estado**: `PENDIENTE` (`archivo recibido`: `_filaAutor()` (`A3`) muestra apodo avatar (`perfil` upload); no hay campo artista; no hay mecanismo reclamo autoría).
- **Restricción** (v18 — `archivo recibido` intacto): `No modificar` `A3` (`Subido por`) para responder `A4`; `A4` requiere nuevo campo `PostgreSQL` (`artista`) + UI (`ficha` + `perfil`).

### 3.2 `A1.4` (`Historial fotos` — ventana 6 días) — `PENDIENTE` (v16 §3; Documentación Técnica v18 §20)
- **Estado**: `PENDIENTE` (`archivo recibido`: `Storage` plano; Rollback (`DT1`/`DT2`) funciona; subcarpetas romperían `borrarFotoDeStorage` — `DT8` RIESGO).
- **Restricción**: `No implementar` `A1.4` sin resolver `DT8` (subcarpetas); `archivo recibido`: `nombreArchivoDesdeTitulo` (plano) funcional.

### 3.3 `M17` (`Borradores locales` + reintento offline) — `PENDIENTE` (post-v1)
- **Estado**: `PENDIENTE` (`archivo recibido`: no hay persistencia local duradera (`getApplicationDocumentsDirectory`) para borradores; `image_picker` caché volátil).
- **Restricción**: `No implementar` en `v1`; `archivo recibido`: `_iniciarFlujoNuevoMural()` (`XFile`) funciona online.

### 3.4 Hallazgo `ñ`/`Ñ` (sanitización de título) — `❓ REPORTADO — NO REPRODUCIDO`
- **Estado**: ❓ Pendiente auditoría controlada. Reporte: durante validación física del APK release, un título con `ñ`/`Ñ` ("pruebiññaañaña") no se pudo guardar; sin `ñ` no falló. La documentación afirma que `nombreArchivoDesdeTitulo()` permite explícitamente `ñ`/`Ñ`.
- **Archivos a revisar (no asumir)**: `lib/utils/helpers.dart` (`nombreArchivoDesdeTitulo`), `lib/pages/mapa_principal_page.dart` (`_subirMural`), `lib/widgets/formulario_mural_modal.dart` (validación de título), codificación en `Storage`/`Supabase`, coincidencia con error de red.
- **Restricción**: `No afirmar bug` hasta reproducción controlada. `No modificar` `nombreArchivoDesdeTitulo` mientras el comportamiento no esté confirmado.

---

## 4. Cuentas (v18 — `archivo recibido` `auth_page.dart` actualizado DT4 + M2 intacto)

### 4.1 `Registro` (`auth_page.dart`)
**Estado**: `VALIDADO` (`archivo recibido` actualizado DT4 — `#1`–`#7 PASS`).
**Restricciones**: `No modificar` `M1` (`contraseña` segura — `_validarContrasenaRegistro` intacto); `No modificar` respuesta anti-enumeración (`DT4-02`).

### 4.2 `Login` (`auth_page.dart`)
**Estado**: `VALIDADO` (`archivo recibido` actualizado DT4 — email autovalidate funciona; password DT4-01 funciona; `#7 PASS`).

### 4.3 `Recuperación` (`recuperar_password_page.dart`)
**Estado**: `VALIDADO` (`archivo recibido` actualizado DT4 — `#8`–`#13 PASS`).
**Restricciones**: `No modificar` `M2` (`OTP` 6 dígitos, `Resend`, cooldown 60s — `_iniciarCooldownReenvio` intacto).

### 4.4 `M9` (`Leaked Passwords` — HIBP) — `BLOQUEADO` (v16 §4; Documentación Técnica v18)
**Estado**: `BLOQUEADO` (`archivo recibido`: no implementado; Supabase Pro requerido).
**Restricción**: `No intentar` implementar sin plan `Pro`.

---

## 5. Mejoras (v18 — `archivo recibido` `mapa_principal_page.dart` actualizado M4 + E6; DT4 independiente)

### 5.1 `M4` (`Cómo llegar` — `Google Maps`)
**Estado**: `VALIDADO` (`archivo recibido` actualizado — `_abrirComoLlegar` URI `google.com/maps`).
**Restricción**: `No reemplazar` mapa OSM (`TileLayer` intacto); `No eliminar` Atribución (`bottomLeft` intacta).

### 5.2 `E6` (`Atribución` — visibilidad opcional)
**Estado**: `VALIDADO` (`archivo recibido` actualizado — `fontSize` 13, `w600`, `padding` 8,4, `fondo` 0xDDF5F5F5).
**Restricción**: `Mantener` texto (`© Colaboradores`), enlace (`copyright`), sin prefijo (`flutter_map | ` descartado).

### 5.3 `M3` (`Onboarding`) — intacto
**Estado**: `VALIDADO` (`archivo recibido` `mapa_principal_page.dart`: `mostrarOnboardingUbicacionSiCorresponde` funcional).

### 5.4 `M5` (`GPS` + Pin) — intacto
**Estado**: `VALIDADO` (`archivo recibido`: `_centrarEnMiUbicacion` funcional; `AjustarUbicacionPage` funcional).

### 5.5 `M6` (`Centrar`) — intacto + pendiente
**Estado**: `VALIDADO PARCIAL` (`#1`–`#5`, `#7 PASS`); `M6-06` (`NO VERIFICADO`).

### 5.6 `M11`–`M16`, `A2`, `B2`–`B7`, `A4`, `A1.4`
**Estado**: `PENDIENTE` (post-v1 o producto — `archivo recibido` no implementa).

### 5.7 `Data Safety` (Play Store) — `❓ NO DOCUMENTADO` (recomendado v18)
**Estado**: ❓ NO DOCUMENTADO. Requisito editorial Google Play Console previo a publicación.
**Acción recomendada**:
- Listar cada dato recopilado por la app y su flujo (entrada → procesamiento → almacenamiento → retención → borrado).
- Datos a declarar: ubicación GPS (M5/M6), fotografías (murales + avatares), perfil (apodo, avatar), email (Auth).
- Almacenamiento: Supabase (PostgreSQL + Storage).
- Compartición: ninguna explícita; declarar URLs externas que carga la app (OSM tiles, Google Maps).
- Verificar que `mapa_principal_page.dart` y `auth_page.dart` no hacen `analytics` ni `tracking` de terceros.
**Restricción**: No introducir SDKs de terceros que recopilen datos adicionales sin documentarlos; no modificar comportamiento de `Auth` ni políticas RLS.

---

## 6. Deuda (v18 — `archivo recibido` actualizado DT4/M4/E6 + Firma Release; resto intacto)

### Resuelta (`archivo recibido` actualizado + física)
- `DT4` (`email` — `autovalidate` + `Timer`): `CERRADO`.
- `DT4` (`email` — `"Siguiente"`): `CERRADO`.
- `DT4` (`Timer` 3s — `email`): `CERRADO`.
- `DT4` (`password` — regresión): `MITIGADO`.
- `M4` (`Google Maps` — URI): `CERRADO`.
- `Identidad` (`namespace`/`applicationId`): `CERRADO`.
- `Atribución` (v16 — integración + opcional): `CERRADO`.
- **`Firma Release` (Keystore + signingConfig + APK/AAB release + `apksigner verify`)**: `CERRADO` (v18).

### Pendiente (`archivo recibido` intacto — no modificada)
- `Colores` (`hardcodeados` — ~53 refs — DeepPurple).
- `DT8` (`Storage` — `uri.pathSegments.last`).
- `DT10` (`God-page` — `mapa_principal_page.dart`).
- `DT11`/`DT12` (`Repository`).
- `DT14` (`Tests`).
- `M6-06` (`GPS` — `NO VERIFICADO`).
- `M9` (`Leaked` — `BLOQUEADO`).
- `SMTP` (`Resend` — `PENDIENTE`).
- `Data Safety` (`NO DOCUMENTADO` — recomendado).
- `M17` (`Borradores`), `A4` (`Autor`), `A1.4` (`Historial`).
- **Hallazgo `ñ`/`Ñ`** (sanitización — pendiente auditoría controlada).

---

## 7. Hallazgos (v18 — `archivo recibido` intacto `mapa_principal_page.dart` funcional + DT4/M4/E6/Firma Release VALIDADO)

### Pendientes (`archivo recibido` no resuelve)
- **Hallazgo `ñ`/`Ñ`**: ❓ REPORTADO — NO REPRODUCIDO. Pendiente auditoría controlada. Revisar `nombreArchivoDesdeTitulo`, `_subirMural`, `formulario_mural_modal`.
- `Colores` (`hardcodeados` — `archivo recibido`: `mapa_principal_page.dart` DeepPurple FAB/Avisos/pin; `auth_page.dart` DeepPurple Icon).
- `M6-06` (`GPS` — `archivo recibido`: `_centrarEnMiUbicacion` maneja `sinSenal` como última conocida — no cubre ambos vacíos; Estado: `NO VERIFICADO` físico).
- `SMTP` (`Resend` — `archivo recibido`: no modificado).
- `Data Safety` (`archivo recibido`: no documentado; requisito editorial Play Store).

### Resueltos (`archivo recibido` actualizado DT4/M4/E6 + Firma Release)
- `DT4` (`email` autovalidate + `Timer`): `CERRADO`.
- `M4` (`Cómo llegar` — `Google Maps`): `CERRADO`.
- `Identidad` (`com.muralitoapp.app`): `CERRADO`.
- **`Firma Release`** (`Keystore` + `signingConfig` + APK/AAB): `CERRADO`.

---

## 8. Seguridad (v18 — `archivo recibido` intacto funcional + Firma Release cerrada)

### `RLS` (PostgreSQL — funcional VALIDADO; documental NO VERIFICADO)
- `public.murales`: SELECT (pública); INSERT (`auth.uid()`); UPDATE (`auth.uid()` — `lat`/`lng` omisión); DELETE (`auth.uid()`).
- `public.perfiles`: SELECT (pública); INSERT (`auth.uid()` — `trigger` automático `manejar_nuevo_usuario`); UPDATE (`auth.uid()`); DELETE (denegado clientes).
- **Nota**: `VALIDADO` funcional (`#015` perfiles trigger; `B1` Storage listing; `DT1`/`DT2` rollback; `M1`–`M6` autenticación operativo). `NO VERIFICADO` documental (`archivo .sql` `CREATE POLICY` no disponible; `trigger` SQL no inspeccionado). `Estado`: funcional `VALIDADO`; documental `NO VERIFICADO` — no cambia (`archivo recibido` funcional intacto).

### `Storage` (políticas funcionales — VALIDADO)
- `Bucket`: `murales` (plano — `archivo recibido`: `nombreArchivoDesdeTitulo`).
- `B1`: `Listing` restringido (autenticados — `archivo recibido`: funcional).
- `URLs`: Públicas (`archivo recibido`: funcional).
- `Subida`: Autenticado (`archivo recibido`: funcional).
- `Eliminación`: Owner (`auth.uid()` — `archivo recibido`: funcional).
- `Rollback`: `DT1` (INSERT falla → borra nuevo); `DT2` (UPDATE falla → borra nuevo; éxito → borra anterior).

### `Auth` (funcional — VALIDADO)
- `M1` (`contraseña` segura + `checklist` DT4-01): `VALIDADO` (`archivo recibido` intacto).
- `M2` (`OTP` Resend 60s): `VALIDADO` (`archivo recibido` intacto).
- `DT4` (`email` autovalidate reactivo + `Timer` 3s): `VALIDADO` (`archivo recibido` actualizado DT4 — `#1`–`#13 PASS`).
- `DT4-02` (anti-enumeración): `VALIDADO` (`archivo recibido`: respuesta genérica cuenta preexistente).

### `Android` (identidad + Atribución + Firma Release)
- `Identidad`: `namespace` + `applicationId` (`com.muralitoapp.app`) — `VALIDADO`.
- `Atribución`: `userAgentPackageName` (`com.muralitoapp.app`) + `bottomLeft` (texto `© Colaboradores`, click `copyright`) — `VALIDADO`.
- **`Firma Release`**: Keystore + `signingConfig.release` + APK/AAB firmados + `apksigner verify` V2/V3 — `VALIDADO` (`CERRADO`).

### `Bloqueos` (funcionales independientes)
- `M9`: Leaked Passwords (`BLOQUEADO` — Supabase Pro — `archivo recibido`: no implementado).
- `Firma Release`: Keystore (`CERRADO` — v18).

---

## 9. Estado (v18 — `archivo recibido` + evidencia física)

| Componente / Funcionalidad | Estado (v12 → v16 → v17 → v18) | Evidencia (`archivo recibido` / física) |
|---|---|---|
| `DT4` (`email` — `autovalidate` + `Timer`) | ✅ `VALIDADO` (`CERRADO`) | `#1`–`#5` (`PASS`); `archivo recibido`: `addListener` + `Timer` + `dispose` |
| `DT4` (`email` — `"Siguiente"`) | ✅ `VALIDADO` (`CERRADO`) | `#1` (`PASS` — visible); `archivo recibido`: `addListener` |
| `DT4` (`Timer` 3s — `email`) | ✅ `VALIDADO` (`CERRADO`) | `#2`, `#5` (`PASS`); `archivo recibido`: `_timerErrorEmail` |
| `DT4` (`password` — `DT4-01` — regresión) | ✅ `VALIDADO` (`SIN REGRESIÓN`) | `#6`, `#12` (`PASS`); `archivo recibido`: `_passFocusNode` intacto |
| `M4` (`Cómo llegar` — `Google Maps`) | ✅ `VALIDADO` (`CERRADO`) | `A`–`E` (`PASS`); `archivo recibido`: `_abrirComoLlegar` (URI: `google.com/maps`) |
| `M4` (restricción mapa intacto) | ✅ `CONFIRMADO` (`VALIDADO`) | `B` (`PASS` — `mapa` OSM); `archivo recibido`: `TileLayer` intacto |
| `E6` (Atribución — funcional + opcional) | ✅ `VALIDADO` (`CERRADO`) | `D` (`PASS` — funcional); `archivo recibido`: `fontSize` 13 `w600` `padding` 8,4 `fondo` 0xDDF5F5F5 |
| **`DT-Firma-Release`** (Firma Release) | ✅ `VALIDADO` (`CERRADO`) | `flutter build apk --release` `√ Built` (53.3MB); `flutter build appbundle --release` `√ Built` (52.2MB); `apksigner verify`: V2/V3 `true`; probado Infinix X6886 |
| `Flujos` (`mapa_principal_page.dart` — `God-page`) | ✅ `VALIDADO` (funcional intacto salvo URI M4 + estilo E6) | `archivo recibido`: `mapa` funcional (`clustering`, FAB, Ficha, CRUD, Perfil, Avisos) |
| `Flujos` (`auth` — `DT4` intacto salvo email actualizado) | ✅ `VALIDADO` (funcional intacto salvo DT4) | `archivo recibido`: `auth` funcional (`M1`, `M2`, perfil) |
| `Regresiones` (v12/v16 funcionales + DT4/M4 v17 + Firma Release v18) | ✅ `PASS` (`#1`–`#16` físico) | `archivo recibido`: `mapa_principal_page.dart` (funcional `PASS` `E`); `auth` (`PASS` `#1`–`#13`); `flutter analyze`: `No issues found!` |
| `Identidad` (`namespace`/`applicationId`) | ✅ `VALIDADO` (`CERRADO`) | `archivo recibido`: `build.gradle.kts` (`com.muralitoapp.app`) |
| `Atribución` (v16 integración + opcional v18) | ✅ `VALIDADO` (`CERRADO`) | `archivo recibido`: `bottomLeft` (texto mantenido, click mantenido, opcional aplicado) |
| `M6-06` (`GPS` — NO VERIFICADO) | ❓ `NO VERIFICADO` (`PENDIENTE` — hardware) | `archivo recibido`: funcional (`sinSenal` manejado como última conocida) pero no cubre ambos vacíos; Estado: `NO VERIFICADO` — prueba física (`GPS` apagado + sin historial) |
| **Hallazgo `ñ`/`Ñ`** (sanitización título) | ❓ `REPORTADO — NO REPRODUCIDO` (`PENDIENTE` — auditoría controlada) | Validación física APK release: título "pruebiññaañaña" no se pudo guardar; sin `ñ` no falló. Revisar `nombreArchivoDesdeTitulo`, `_subirMural`, `formulario_mural_modal` |
| `Colores` (`hardcodeados`) | ⏳ `PENDIENTE` (estilo — no bloqueante) | `archivo recibido`: `mapa_principal_page.dart` (FAB: `deepPurple`; Avisos: `deepPurple[700]`; pin: `deepPurple`); `auth`: `Icon` `deepPurple` |
| `DT8` (`Storage` — `uri.pathSegments.last`) | ⚠️ `RIESGO` (plano funcional; subcarpetas romperían) | `archivo recibido`: `borrarFotoDeStorage` (`uri.pathSegments.last` — funcional plano) |
| `DT10` (`God-page`) | ⚠️ `RIESGO` (no resuelto — no aumenta M4 URI independiente) | `archivo recibido`: `mapa_principal_page.dart` (concentración `mapa`/`clustering`/`auth`/UI) |
| `DT11`/`DT12` (`Repository`) | ⏳ `PENDIENTE` (`archivo recibido`: `supabase_client.dart` directo) | `archivo recibido`: `mapa_principal_page.dart` (`.from('murales').select()` directo) |
| `DT14` (`Tests`) | ⏳ `PENDIENTE` | `archivo recibido`: `flutter test` no creado |
| `M9` (`Leaked` — Supabase Pro) | ⛔ `BLOQUEADO` (`archivo recibido`: no implementado) | `archivo recibido`: no existe código `M9` |
| `Firma Release` (`Keystore`) | ✅ `CERRADO` (v18) | `apksigner verify`: V2/V3 `true`; APK/AAB compilados; backup externo confirmado |
| `SMTP` (`Resend` — dominio propio) | ⏳ `PENDIENTE` (`archivo recibido`: no actualizado) | `archivo recibido`: no modificado (`SMTP` Resend configurado) |
| `Data Safety` (`Play Store`) | ❓ `NO DOCUMENTADO` (`archivo recibido`: no menciona) | `archivo recibido`: `mapa_principal_page.dart`, Mejoras v17 no mencionan; requisito Play Store — verificar previo publicación |
| `M17` (`Borradores offline`) | ⏳ `PENDIENTE` (`post-v1`) | `archivo recibido`: no implementado (`image_picker` caché volátil) |
| `A4` (`Autor` ≠ `Uploader`) | ⏳ `PENDIENTE` (`archivo recibido`: `A3` Subido por muestra upload no artista) | `archivo recibido`: no hay campo artista (`public.murales` o `public.perfiles`) |
| `A1.4` (`Historial fotos` 6 días) | ⏳ `PENDIENTE` (`archivo recibido`: Storage plano; Rollback DT2 funcional; subcarpetas DT8 romperían) | `archivo recibido`: `nombreArchivoDesdeTitulo` (plano funcional) |
| `Supabase SQL` (`RLS` `CREATE POLICY` — archivo .sql) | ❓ `NO VERIFICADO` (`archivo recibido`: funcional `VALIDADO` `#015`/`B1`; `.sql` no disponible) | Estado: funcional `VALIDADO` (`archivo recibido` funcional intacto); documental `NO VERIFICADO` (`archivo .sql` no inspeccionado) — no cambia (`archivo recibido` funcional intacto) |

---

## 10. Próximo objetivo (v18 — recomendado: `Data Safety` — requisito editorial previo a publicación)

**Estado (`archivo recibido` actualizado DT4/M4/E6 + Firma Release v18 — funcional `VALIDADO` físico):**
- `DT4`: `CERRADO` (`VALIDADO` `#1`–`#13 PASS` — `archivo recibido` actualizado).
- `M4`: `CERRADO` (`VALIDADO` `A`–`E PASS` — `archivo recibido` actualizado).
- `E6`: `VALIDADO` (funcional intacto + opcional aplicado — `archivo recibido` actualizado).
- `Firma Release`: `CERRADO` (`VALIDADO` físico — `apksigner verify` V2/V3 + Infinix X6886).
- `Flujos`: `VALIDADO` (`archivo recibido` `mapa_principal_page.dart` funcional `PASS` `E` — `clustering`/`ficha`/`FAB`/`Avisos`/`Auth` intacto).

**Candidato (`Documentación Técnica v18` §6; `Mejoras v18` §10; `Handoff Técnico v007` §15):**
> **`Data Safety` (Play Store)** — Requisito editorial previo a publicación en Google Play. La barrera técnica de compilación ha quedado superada con el cierre de `Firma Release` (v18). El siguiente bloqueo real es de cumplimiento en la consola de Google Play.

- **Archivos a intervenir**:
  - Consola Google Play (sección `Data Safety`).
  - Documentación interna (`Mejoras v18`, `Documentación Técnica v18`) — sección nueva "Privacidad y datos".
- **Estado (`archivo recibido`)**: ❓ NO DOCUMENTADO. Muralito no aparece como recopilando datos en ninguna ficha; sin embargo, recopila: ubicación GPS (M5, F6), fotografías (Murales + Avatares), perfil (apodo, avatar), email (Auth).
- **Restricción (`archivo recibido` — no modificar funcional):**
  - `mapa_principal_page.dart` (`mapa`, `clustering`, FAB, Avisos, CRUD, Perfil, Atribución) intacto.
  - `auth_page.dart` (DT4) intacto.
  - `recuperar_password_page.dart` (DT4) intacto.
  - `helpers.dart` (Sanitización, Rollback, Notificaciones) intacto.
  - No introducir SDKs de terceros que recopilen datos adicionales sin documentarlos.
- **Auditoría previa necesaria:**
  - Listar cada dato recopilado y su flujo (entrada → procesamiento → almacenamiento → retención → borrado).
  - Confirmar que `mapa_principal_page.dart` y `auth_page.dart` no hacen `analytics` ni `tracking` de terceros.
  - Verificar URLs externas que carga la app (OSM tiles, Google Maps) y declararlas en la ficha.
- **Acción concreta recomendada:**
  - Recopilar respuestas para `Data Safety`:
    - ¿Se recopilan datos personales? Sí (email, ubicación precisa, fotos).
    - ¿Se comparten con terceros? Solo OSM (teselas) y Google Maps (navegación); declarar.
    - ¿El usuario puede eliminar sus datos? Sí (CRUD murales + perfil; cuenta se gestiona vía Auth).
    - ¿Se aplica cifrado en tránsito? Sí (HTTPS por defecto).
    - ¿Se aplica cifrado en reposo? Depende de configuración Supabase (declarar).
    - ¿Retención? Hasta que el usuario elimine el mural/cuenta.
- **Pruebas necesarias tras implementar:**
  - Cruzar la ficha declarada con el código real (auditoría estática de imports y llamadas de red).
  - Validar que el formulario enviado coincide con el comportamiento observable de la app.
- **Riesgos y efectos secundarios:** Mínimos si la auditoría previa es correcta. Riesgo medio si se declaran datos que la app no recopila realmente (rechazo de Play) o si se omiten datos reales (suspensión posterior).

**Alternativa 1 (`Mejoras v18` §3 — producto, no bloqueante):**
> **`M17` (`Borradores offline`)** — Detectado durante validación física del APK release: si falla la subida, recuperar el borrador (título/descripción/foto/ubicación/rotación) para no repetir trabajo. Sugerencia del dev. No bloqueante para publicación.

**Alternativa 2 (`Mejoras v18` §6 — estilo, no bloqueante):**
> **`Colores hardcodeados`** (`Colors.deepPurple` ~53 referencias — `Theme.of(context).colorScheme` — `archivo recibido`: `mapa_principal_page.dart` FAB/Avisos/pin `deepPurple`; `auth_page.dart` Icon `deepPurple`).

**Pendiente de auditoría controlada (previo a cualquier fix):**
> **Hallazgo `ñ`/`Ñ`** — Reproducción controlada antes de afirmar bug. Revisar `nombreArchivoDesdeTitulo`, `_subirMural`, validación en `formulario_mural_modal`.

**Estado (`v18` — cierre):**
- `MVP`: funcional avanzado (DT4/M4/E6/Firma Release `VALIDADO`).
- `Flujos`: Actualizado (v15 — `archivo recibido` `mapa_principal_page.dart` funcional `PASS` `E`; `auth` `VALIDADO` `#1`–`#13`; Firma Release `VALIDADO` físico).
- `Documentación`: Actualizado (v18 — `Estado`, `Funcionalidades`, `Deuda`, `Riesgos`, `Discrepancias`, `Siguiente`, `Auditoría` — bloque completo).
- `Siguiente (recomendado)`: `Data Safety` (`Play Store`).
- `Pendiente (post-v1/estilo/auditoría)`: `M17`, `Colores`, `M6-06`, `M9`, `SMTP`, `Hallazgo ñ/Ñ`.

**Estado final (`archivo recibido` + evidencia física + documentación v18 + flujos v15 + handoff v007):**
`No inventado`: `Todas` `afirmaciones` `se respaldan` `en los archivos recibidos` (`mapa_principal_page.dart` actualizado M4/E6; `auth_page.dart` actualizado DT4; `recuperar_password_page.dart` actualizado DT4; `helpers.dart` intacto; `pubspec.yaml` intacto; `models/`/`widgets/` intactos; `android/app/build.gradle.kts` actualizado Firma Release; `android/key.properties` nuevo; `android/app/muralito-release-key.jks` nuevo; `android/settings.gradle.kts` AGP 8.13.0; `android/gradle.properties` JDK Temurin 17 + newDsl; `.gitignore` actualizado) y en la evidencia física reportada (`#1`–`#16 PASS`; `flutter analyze`: `No issues found!`; `flutter build apk --release`: `√ Built` (53.3MB); `flutter build appbundle --release`: `√ Built` (52.2MB); `apksigner verify`: V2/V3 `true`; probado en Infinix X6886).

**Nota técnica final (v18 — `archivo recibido` funcional `VALIDADO` DT4/M4/E6 + Firma Release):**
- `Estado`: `DT4` (`VALIDADO` — autovalidate reactivo + `Timer` 3s — `archivo recibido` actualizado).
- `Estado`: `M4` (`VALIDADO` — Cómo llegar `Google Maps` — `archivo recibido` actualizado: `_abrirComoLlegar` URI `google.com/maps`).
- `Estado`: `E6` (`VALIDADO` — Atribución funcional intacta + opcional mejorado: `fontSize` 13, `w600`, `padding` 8,4, `fondo` 0xDDF5F5F5).
- `Estado`: `DT-Firma-Release` (`VALIDADO` — Keystore + `signingConfig.release` + APK/AAB firmados + `apksigner verify` V2/V3 + probado Infinix X6886 + backup externo del `.jks` confirmado).
- `Estado`: `Flujos` (v15 — `archivo recibido` `mapa_principal_page.dart` funcional `PASS` `E` — `clustering`/`ficha`/`FAB`/`Avisos`/`Auth` intacto).
- `Estado`: `Discrepancias` (resueltas: Identidad, AGP, JDK, `key.properties`, DT4, M4, E6, Firma Release consistente; persistentes: `M6-06` `NO VERIFICADO`; `Colores` `PENDIENTE`; `DT8` `RIESGO`; `DT10` `RIESGO`; `DT11`/`DT12` `PENDIENTE`; `DT14` `PENDIENTE`; `M9` `BLOQUEADO`; `SMTP` `PENDIENTE`; `Data Safety` `NO DOCUMENTADO`; `M17`/`A4`/`A1.4` `PENDIENTE`; Hallazgo `ñ`/`Ñ` `PENDIENTE` auditoría).
- `Estado`: `Siguiente objetivo (recomendado)`: `Data Safety` (`Play Store` — requisito editorial — barrera técnica de compilación ya superada con Firma Release v18).
- `Estado`: `No inventado`: Todas las afirmaciones se respaldan en los archivos recibidos y en la evidencia física reportada (`flutter run`: `#1`–`#16 PASS`; `flutter analyze`: `No issues found!`; `flutter build apk --release`: `√ Built`; `flutter build appbundle --release`: `√ Built`; `apksigner verify`: V2/V3 `true`).