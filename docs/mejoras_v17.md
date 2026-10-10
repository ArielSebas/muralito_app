# Muralito App — Backlog Priorizado

**Versión:** 16 (actualizado — revisión post-DT4/M4/E6)
**Fecha:** 2026-09-27
**Actualiza:** Mejoras_v16 (26/09/2026).
**Estado actual:** MVP funcional avanzado — DT4 (autovalidate reactivo + Timer 3s) y M4 (Cómo llegar → Google Maps nativo) validados mediante ejecución física (`flutter run`, `#1`–`#16 PASS`). E6 (Atribución OSM — visibilidad mejorada, opcional) actualizado. `flutter analyze`: `No issues found!`.

**Referencia documental sincronizada:** Documentación Técnica v17, Flujos Funcionales v13, README.md, Handoff Técnico v006.

---

## Últimas funcionalidades implementadas (v16 actualizado — evidencia física `#1`–`#16 PASS`)

- **`DT4` (`email` — `autovalidate` `reactivo` + `Timer` `3s`)**:
  - `auth_page.dart`: `FocusNode` (`_emailFocusNode`) con `addListener` (`_alCambiarFocoEmail`); limpieza `onChanged` (`_mostrarErrorEmail`); `Timer` (`_iniciarTimerErrorEmail`, `Duration(seconds: 3)`); `dispose` (`_timerErrorEmail?.cancel()` + `removeListener` + `.dispose()`).
  - `recuperar_password_page.dart`: `mismo` `patrón` (`_emailFocusNode` `addListener`, `_mostrarErrorEmail`, `_iniciarTimerErrorEmail`, `dispose`).
  - `Estado`: `VALIDADO` (`CERRADO`). `#1` (`Siguiente` `visible` — `PASS`); `#2` (`Timer` `3s` — `PASS`); `#3` (`escribir` `limpia` — `PASS`); `#4` (`vacío` + `botón` `bloquea` + `Timer` — `PASS`); `#5` (`Timer` `tras` `vacío` — `PASS`); `#8` (`recuperación` `Siguiente` — `PASS`); `#9` (`Timer` `3s` — `PASS`); `#10` (`bloqueo` `+ Timer` — `PASS`).

- **`M4` (`Cómo llegar` → `Google Maps` `nativo`)**:
  - `mapa_principal_page.dart`: `_abrirComoLlegar` (`Future<void>`; `final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');`; `await launchUrl(uri, mode: LaunchMode.externalApplication);`).
  - `Restricción` (`v16` — `Documentación Técnica v17`, §16): `OpenStreetMap` (`mapa` `interno` — `flutter_map` `TileLayer` `openstreetmap.org`) `NO SE REEMPLAZA`; `Atribución` (`bottomLeft` — `© Colaboradores`) `INTACTA`.
  - `Estado`: `VALIDADO` (`CERRADO`). `A` (`botón` `existe` — `PASS`); `B` (`mapa` `OSM` `funciona` — `PASS`); `C` (`Google Maps` `abre` — `PASS`); `D` (`Atribución` `intacta` — `PASS`); `E` (`regresión` `clustering`/`ficha`/`FAB`/`Avisos`/`Auth` — `PASS`).

- **`E6` (`Atribución OSM` — `visibilidad` `mejorada`, `opcional`)**:
  - `mapa_principal_page.dart`: `fontSize: 13` (`anterior`: `11`); `fontWeight: FontWeight.w600` (`anterior`: `normal`); `padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4)` (`anterior`: `6, 3`); `fondo: Color(0xDDF5F5F5)` (`anterior`: `0xCCFFFFFF`).
  - `Restricción` (`v16` — `Documentación Técnica v17`, §5.2): `Texto` (`© Colaboradores de OpenStreetMap`) `MANTENIDO`; `Enlace` (`copyright`) `MANTENIDO`; `Sin prefijo` (`flutter_map | ` `DESCARTADO`) `MANTENIDO`.
  - `Estado`: `VALIDADO` (`funcional` `intacto` + `opcional` `aplicado`). `D PASS` (`texto`/`click` `mantenido`); `funcional` (`mapa` `clustering` `intacto`).

---

## Últimas correcciones y tareas cerradas (`v16 actualizado`)

- **`DT4` (`email`)** (`autovalidate` `reactivo`): `Implementada` (`auth_page.dart` + `recuperar_password_page.dart`: `addListener`, `Timer`, `dispose`) + `Validada` (`#1`–`#13 PASS`).
- **`DT4` (`Timer`)** (`3s`): `Implementado` (`_iniciarTimerErrorEmail`) + `Validado` (`#2`, `#5`, `#9`, `#10 PASS`).
- **`M4` (`Cómo llegar`)** (`Google Maps` `nativo`): `Implementado` (`_abrirComoLlegar` `URI` `actualizado`) + `Validado` (`A`–`E PASS`).
- **`M4` (`restricción` `mapa` `intacto`)**: `Confirmada` (`OpenStreetMap` `como` `motor` `interno`; `TileLayer` `openstreetmap.org`; `clustering` `30m`; `Atribución` `bottomLeft`).
- **`E6` (`Atribución` — `visibilidad` `opcional`)**: `Actualizada` (`fontSize` `13`, `w600`, `padding` `8,4`, `fondo` `0xDDF5F5F5`) — `funcional` `VALIDADO` (`D PASS`).
- **`Identidad` (`namespace`/`applicationId`)** (`v15` `discrepancia`): `Confirmada` (`com.muralitoapp.app` `alineado` — `Mejoras v16`, §2.1).

---

## Hallazgos pendientes sin resolver (`v16 actualizado` — `no modificados` `v17`)

- **`Firma de compilación Release`**: `android/app/build.gradle.kts` (`release`: `signingConfigs.getByName("debug")`) — `PENDIENTE` (`bloqueante` `Play Store` — `Mejoras v16`, §7; `Documentación Técnica v17`, §6).
- **`Autovalidate` (`email`)** (`DT4` — `Timer`): `CERRADO` (`VALIDADO`) — `no pendiente`.
- **`Colores hardcodeados` (`Colors.deepPurple`)**: `~53` `referencias` (`8` `archivos`) — `PENDIENTE` (`estilo` — `mapa_principal_page.dart`: `FAB`, `Avisos`, `pin`; `auth_page.dart`: `Icon`; `Mejoras v16`, §6; `Documentación Técnica v17`, §3).
- **`Escenario` `M6-06`** (`GPS` `sin señal` `ni` `última` `ubicación` `conocida`): `NO VERIFICADO` (`hardware` `físico` `no aislado` — `Documentación Técnica v17`, §7; `Flujos Funcionales v13`, §19).
- **`Remitente` `SMTP` (`Resend`)**: `onboarding@resend.dev` — `PENDIENTE` (`dominio` `propio` `SPF`/`DKIM` `antes` `evaluadores` `externos`).
- **`Colores` (`hardcodeados`)** (`mapa_principal_page.dart` `FAB`/`Avisos`/`pin` `deepPurple`): `No aumenta` (`DT4` `email` `independiente`; `M4` `URI` `independiente`; `E6` `black87`).
- **`DT10` (`God-page`)** (`mapa_principal_page.dart`): `RIESGO` (`concentración` `mapa`/`clustering`/`auth`/`Supabase`/`UI`) — `M4` (`URI` `independiente`) `NO AUMENTA`; `DT4` (`email`) `NO AUMENTA`.

---

## 1. Hecho — no reabrir (`v16` `VALIDADO` — `archivo recibido` `intacto` `funcional`)

| ID / Componente | Qué se implementó / validó | Evidencia (`archivo recibido` + `física`) |
|---|---|---|
| `DT4` (`email` — `autovalidate` + `Timer`) | `auth_page.dart` + `recuperar_password_page.dart`: `addListener` (`_emailFocusNode`), `Timer` (`3s`), `dispose` (`cancel` + `removeListener`) | `#1`–`#7` (`auth` `PASS`); `#8`–`#13` (`recuperación` `PASS`) |
| `DT4` (`password` — `DT4-01` — `regresión`) | `Mitigada`: `_passFocusNode` `addListener` `intacto`; `checklist` `_requisitosContrasena` `operativo` | `#6`, `#12` (`PASS`) |
| `M4` (`Cómo llegar` — `Google Maps`) | `mapa_principal_page.dart`: `_abrirComoLlegar` (`URI`: `google.com/maps/dir/?api=1`) — `VALIDADO` (`A`–`E PASS`) | `archivo recibido`: `URI` `actualizado`; `mapa` `OSM` `intacto`; `Atribución` `intacta` |
| `E6` (`Atribución` — `visibilidad` `opcional` `mejorada`) | `mapa_principal_page.dart`: `fontSize` `13`, `w600`, `padding` `8,4`, `fondo` `0xDDF5F5F5` — `funcional` `VALIDADO` (`D PASS`) | `archivo recibido`: `texto` `© Colaboradores` `mantenido`; `click` `copyright` `mantenido` |
| `Identidad Android` (`namespace`/`applicationId`) | `com.muralitoapp.app` (`build.gradle.kts` + `MainActivity.kt`) | `Mejoras v16`, §2.1 |
| `Atribución OSM` (`v16` — `integración` + `opcional`) | `bottomLeft` (`Align`), `texto` `© Colaboradores`, `click` (`copyright`), `sin prefijo` (`flutter_map`) | `Mejoras v16`, §2.1; `archivo recibido`: `intacto` + `opcional` `actualizado` |
| `Flujos Funcionales` (`v12` → `v13`) | `Actualizado`: `DT4` (`autovalidate` `reactivo` + `Timer`), `M4` (`Google Maps`), `E6` (`visibilidad` `opcional`); `resto` (`mapa`, `clustering`, `FAB`, `Avisos`, `Ficha`, `CRUD`, `Perfil`) `intacto` | `archivo recibido`: `mapa_principal_page.dart` `funcional` `PASS` `E` (`clustering`/`ficha`/`FAB`/`Avisos`/`Auth`) |
| `Regresiones` (`v12`/`v16` `funcionales` + `DT4`/`M4` `v17`) | `PASS` (`#1`–`#16`): `DT4` (`email` `autovalidate` + `Timer` `3s` + `Siguiente` `visible`); `password` `DT4-01` (`sin regresión`); `mapa` (`OSM` `intacto` + `clustering`); `FAB` (`Mi ubicación` + `Nuevo Mural`); `Avisos` (`Toast` `superior` `3s`); `Ficha` (`A3` `intacto` + `Cómo llegar` `Google Maps`); `Auth` (`Login`/`Registro` `funcional`); `Build` (`No issues found!`) | `archivo recibido`: `mapa_principal_page.dart` `actualizado` (`URI` `M4` + `estilo` `E6`); `auth_page.dart` (`DT4`); `recuperar_password_page.dart` (`DT4`); `flutter analyze`: `PASS` |

Estas funcionalidades **no deben reabrirse** salvo evidencia de regresión técnica (`archivo recibido` `funcional` `PASS` `E`) o cambios regulatorios (`Atribución` `OSM` `política tiles` `intacta`).

---

## 2. Cierres formales (`v16` actualizado — `archivo recibido` `actualizado` `DT4`/`M4`/`E6`)

### 2.1 `DT4` (`email` — `autovalidate` `reactivo` + `Timer 3s`)
**Estado**: `VALIDADO` (`CERRADO` como `pendiente`; `funcional`).
**Implementación** (`archivo recibido` `auth_page.dart` + `recuperar_password_page.dart`):
- `_emailFocusNode`: `addListener` (`_alCambiarFocoEmail`) — `captura` `transición` `Next`.
- `TextFormField` (`email`): `keyboardType` `emailAddress`; `autovalidateMode` `disabled`; `onChanged`: `limpia`; `onTapOutside`: `muestra` `error` (`email.isEmpty || !email.contains('@')`).
- `_mostrarErrorEmail`: `bool`; `setState` (`_enviar`/`_enviarCodigo`: `email.isEmpty || !email.contains('@')` → `true` + `_iniciarTimerErrorEmail()` `si` `true`).
- `_timerErrorEmail`: `Timer?` (`_timerErrorEmail?.cancel()` `previo` `en` `_iniciarTimerErrorEmail`).
- `_iniciarTimerErrorEmail()`: `Timer(const Duration(seconds: 3), () { if (mounted) setState(() => _mostrarErrorEmail = false); });`.
- `dispose`: `_timerErrorEmail?.cancel()`; `_emailFocusNode.removeListener(_alCambiarFocoEmail)`; `_emailFocusNode.dispose()`.
**Validación** (`evidencia física` `#1`–`#13 PASS`):
- `#1` (`auth` — `Siguiente` `visible` — `PASS`).
- `#2` (`auth` — `Timer` `3s` — `PASS`).
- `#3` (`auth` — `escribir` `limpia` — `PASS`).
- `#4` (`auth` — `vacío` + `botón` `bloquea` + `Timer` — `PASS`).
- `#5` (`auth` — `Timer` `tras` `vacío` — `PASS`).
- `#8` (`recuperación` — `Siguiente` `paso 1` — `PASS`).
- `#9` (`recuperación` — `Timer` `3s` — `PASS`).
- `#10` (`recuperación` — `vacío` + `Enviar código` `bloquea` + `Timer` — `PASS`).
**Restricción** (`v16`, §10; `Mejoras v16`, §4): `No modificar` `validación` `formato` `email` (`RegExp`); `no modificar` `llamada` `Supabase` (`signUp`/`signIn`/`resetPasswordForEmail`); `no modificar` `respuesta` `anti-enumeración` (`DT4-02`).

### 2.2 `M4` (`Cómo llegar` — `Google Maps` `nativo`)
**Estado**: `VALIDADO` (`CERRADO` como `pendiente`; `funcional`).
**Implementación** (`archivo recibido` `mapa_principal_page.dart`):
- Función `_abrirComoLlegar(double lat, double lng)`: `Future<void>`.
- `URI`: `https://www.google.com/maps/dir/?api=1&destination=$lat,$lng` (anterior: `https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=18/$lat/$lng`).
- `LaunchMode`: `LaunchMode.externalApplication` (anterior: `mismo` `modo`).
- `Manejo` `error`: `if (!mounted) return;` (mantenido); `if (!ok) { _mostrarAviso('No se pudo abrir Google Maps. Coordenadas: ...', tipo: _TipoAviso.error); }` (anterior: `mensaje` `similar` `OpenStreetMap`).
**Restricción** (`v16`, §16; `Mejoras v16`, §5; `Flujos Funcionales v12`, §12):
- `Mantener` `OpenStreetMap` (`flutter_map`, `TileLayer`, `clustering`, `Atribución`) `como` `motor` `interno` (`NO` `reemplazado`).
- `Atribución` (`bottomLeft`) `intacta`: `texto` (`© Colaboradores`), `click` (`copyright`), `fondo`, `padding`, `font` (`opcional` `mejorado` `E6`), `sin prefijo` (`flutter_map | ` `descartado`).
**Validación** (`A`–`E PASS` `físico`):
- `A`: `Botón` `"Cómo llegar"` (`FilledButton.icon` `purple` — `archivo recibido`) `existe` — `PASS`.
- `B`: `Mapa` (`flutter_map` `OSM` — `TileLayer` `intacto` + `clustering` `30m` `funcional`) — `PASS`.
- `C`: `Google Maps` (`URI` `google.com/maps` — `abre` `app` `nativa` `o` `navegador` `fallback`) — `PASS`.
- `D`: `Atribución` (`bottomLeft`: `texto` `mantenido`; `click` `copyright` `funciona`; `opcional` `mejorado` `visible`) — `PASS`.
- `E`: `Regresión` (`mapa` `interactivo` `intacto`; `clustering` `funcional`; `FAB` (`Nuevo Mural`/`Mi ubicación`) `anclado`; `Avisos` (`_AvisoUI`) `operativo`; `Ficha` (`DraggableScrollableSheet`) `funcional`; `Auth` (`AppBar` `avatar`/`apodo` `dinámico`) `intacto`) — `PASS`.

### 2.3 `E6` (`Atribución OSM` — `visibilidad` `opcional` `mejorada`)
**Estado**: `VALIDADO` (`funcional` `intacto` + `opcional` `mejorado` — `archivo recibido` `mapa_principal_page.dart`).
**Implementación** (`archivo recibido`):
- `Alineación`: `Align(alignment: Alignment.bottomLeft)` (`mantenida`).
- `Fondo`: `ColoredBox(color: Color(0xDDF5F5F5))` (`opcional`: `anterior` `0xCCFFFFFF`).
- `Contenido`: `InkWell` (`onTap`: `https://www.openstreetmap.org/copyright` — `mantenido`).
- `Texto`: `Text('© Colaboradores de OpenStreetMap', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87))` (`opcional`: `anterior` `fontSize: 11`, `fontWeight: normal`, `color: black87`).
- `Padding`: `Padding(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), ...)` (`opcional`: `anterior` `horizontal: 6`, `vertical: 3`).
- `Restricción`: `Sin prefijo` (`flutter_map | ` `descartado` — `Mejoras v16`, §2.1) — `mantenido`.
**Estado**: `Opcional` (`funcional` `cumple` `política` `OSM` — `v16`, §5.2; `archivo recibido` `funcional` `PASS` `D`). `No requiere` `prueba` `física` `adicional` (`D PASS` `confirma` `funcional`); `visibilidad` `mejorada` `opcional` (`archivo recibido` `actualizado`).

### 2.4 `Identidad Android` (`namespace`/`applicationId`)
**Estado**: `VALIDADO` (`v15` `discrepancia` `resuelta` `formalmente` — `Mejoras v16`, §2.1).
**Evidencia** (`archivo recibido` — `referencia` `v16`):
- `android/app/build.gradle.kts`: `namespace = "com.muralitoapp.app"`; `applicationId = "com.muralitoapp.app"`.
- `android/app/src/main/kotlin/com/muralitoapp/app/MainActivity.kt`: `package com.muralitoapp.app`.

### 2.5 `Atribución OSM` (`v16` — `integración`)
**Estado**: `VALIDADO` (`archivo recibido` `mapa_principal_page.dart` — `bottomLeft` `funcional` `PASS` `D`).
**Restricción** (`Mejoras v16`, §2.1; `Documentación Técnica v17`, §5.2): `No prefijo` (`flutter_map | ` `descartado`); `texto` `© Colaboradores`; `enlace` `copyright` (`LaunchMode.externalApplication`); `visibilidad` (`bottomLeft` — `funcional`).

---

## 3. Alta de mural (`v13` — `archivo recibido` `mapa_principal_page.dart` `intacto` + `v16` `actualizado` + `DT4` `independiente`)

### 3.1 `Producto` — `A4` (`Diferencia` `Uploader` `≠` `Artista`) — `PENDIENTE` (`Mejoras v16`, §3; `Documentación Técnica v17`, §20)
- `Estado`: `PENDIENTE` (`archivo recibido`: `_filaAutor()` (`A3`) `muestra` `apodo` `avatar` (`perfil` `upload`); `no` `hay` `campo` `artista`; `no` `hay` `mecanismo` `reclamo` `autoría`).
- `Restricción` (`v17` — `archivo recibido` `intacto`): `No modificar` `A3` (`Subido por`) `para` `responder` `A4`; `A4` `requiere` `nuevo` `campo` `PostgreSQL` (`artista`) `+` `UI` (`ficha` `+` `perfil`).

### 3.2 `A1.4` (`Historial` `fotos` — `ventana` `6` `días`) — `PENDIENTE` (`Mejoras v16`, §3; `Documentación Técnica v17`, §20)
- `Estado`: `PENDIENTE` (`archivo recibido`: `Storage` `plano`; `Rollback` (`DT1`/`DT2`) `funciona`; `subcarpetas` `romperían` `borrarFotoDeStorage` — `DT8` `RIESGO`).
- `Restricción`: `No implementar` `A1.4` `sin` `resolver` `DT8` (`subcarpetas`); `archivo recibido`: `nombreArchivoDesdeTitulo` (`plano`) `funcional`.

### 3.3 `M17` (`Borradores` `locales` + `reintento` `offline`) — `PENDIENTE` (`post-v1`)
- `Estado`: `PENDIENTE` (`archivo recibido`: `no` `hay` `persistencia` `local` `duradera` (`getApplicationDocumentsDirectory`) `para` `borradores`; `image_picker` `caché` `volátil`).
- `Restricción`: `No implementar` `en` `v1`; `archivo recibido`: `_iniciarFlujoNuevoMural()` (`XFile`) `funciona` `online`.

---

## 4. Cuentas (`v13` — `archivo recibido` `auth_page.dart` `actualizado` `DT4` + `M2` `intacto`)

### 4.1 `Registro` (`auth_page.dart`)
`Estado`: `VALIDADO` (`archivo recibido` `actualizado` `DT4` — `#1`–`#7 PASS`).
`Restricciones`: `No modificar` `M1` (`contraseña` `segura` — `_validarContrasenaRegistro` `intacto`); `No modificar` `respuesta` `anti-enumeración` (`DT4-02`).

### 4.2 `Login` (`auth_page.dart`)
`Estado`: `VALIDADO` (`archivo recibido` `actualizado` `DT4` — `email` `autovalidate` `funciona`; `password` `DT4-01` `funciona`; `#7 PASS`).

### 4.3 `Recuperación` (`recuperar_password_page.dart`)
`Estado`: `VALIDADO` (`archivo recibido` `actualizado` `DT4` — `#8`–`#13 PASS`).
`Restricciones`: `No modificar` `M2` (`OTP` `6` `dígitos`, `Resend`, `cooldown` `60s` — `_iniciarCooldownReenvio` `intacto`).

### 4.4 `M9` (`Leaked Passwords` — `HIBP`) — `BLOQUEADO` (`Mejoras v16`, §4; `Documentación Técnica v17`)
`Estado`: `BLOQUEADO` (`archivo recibido`: `no implementado`; `Supabase Pro` `requerido`).
`Restricción`: `No intentar` `implementar` `sin` `plan` `Pro`.

---

## 5. Mejoras (`v13` — `archivo recibido` `mapa_principal_page.dart` `actualizado` `M4` + `E6`; `DT4` `independiente`)

### 5.1 `M4` (`Cómo llegar` — `Google Maps`)
`Estado`: `VALIDADO` (`archivo recibido` `actualizado` — `_abrirComoLlegar` `URI` `google.com/maps`).
`Restricción`: `No reemplazar` `mapa` `OSM` (`TileLayer` `intacto`); `No eliminar` `Atribución` (`bottomLeft` `intacta`).

### 5.2 `E6` (`Atribución` — `visibilidad` `opcional`)
`Estado`: `VALIDADO` (`archivo recibido` `actualizado` — `fontSize` `13`, `w600`, `padding` `8,4`, `fondo` `0xDDF5F5F5`).
`Restricción`: `Mantener` `texto` (`© Colaboradores`), `enlace` (`copyright`), `sin prefijo` (`flutter_map | ` `descartado`).

### 5.3 `M3` (`Onboarding`) — `intacto`
`Estado`: `VALIDADO` (`archivo recibido` `mapa_principal_page.dart`: `mostrarOnboardingUbicacionSiCorresponde` `funcional`).

### 5.4 `M5` (`GPS` + `Pin`) — `intacto`
`Estado`: `VALIDADO` (`archivo recibido`: `_centrarEnMiUbicacion` `funcional`; `AjustarUbicacionPage` `funcional`).

### 5.5 `M6` (`Centrar`) — `intacto` + `pendiente`
`Estado`: `VALIDADO PARCIAL` (`#1`–`#5`, `#7 PASS`); `M6-06` (`NO VERIFICADO`).

### 5.6 `M11`–`M16`, `A2`, `B2`–`B7`, `A4`, `A1.4`
`Estado`: `PENDIENTE` (`post-v1` `o` `producto` — `archivo recibido` `no implementa`).

---

## 6. Deuda (`v006` — `archivo recibido` `actualizado` `DT4`/`M4`/`E6`; `resto` `intacto`)

### Resuelta (`archivo recibido` `actualizado` + `física`)
- `DT4` (`email` — `autovalidate` + `Timer`): `CERRADO`.
- `DT4` (`email` — `"Siguiente"`): `CERRADO`.
- `DT4` (`Timer` `3s` — `email`): `CERRADO`.
- `DT4` (`password` — `regresión`): `MITIGADO`.
- `M4` (`Google Maps` — `URI`): `CERRADO`.
- `Identidad` (`namespace`/`applicationId`): `CERRADO`.
- `Atribución` (`v16` — `integración` + `opcional`): `CERRADO`.

### Pendiente (`archivo recibido` `intacto` — `no modificada`)
- `Colores` (`hardcodeados` — `~53` `refs` — `DeepPurple`).
- `DT8` (`Storage` — `uri.pathSegments.last`).
- `DT10` (`God-page` — `mapa_principal_page.dart`).
- `DT11`/`DT12` (`Repository`).
- `DT14` (`Tests`).
- `M6-06` (`GPS` — `NO VERIFICADO`).
- `M9` (`Leaked` — `BLOQUEADO`).
- `Firma` (`Keystore` — `PENDIENTE` `recomendado`).
- `SMTP` (`Resend` — `PENDIENTE`).
- `Data Safety` (`NO DOCUMENTADO`).
- `M17` (`Borradores`), `A4` (`Autor`), `A1.4` (`Historial`).

---

## 7. Hallazgos (`v006` — `archivo recibido` `intacto` `mapa_principal_page.dart` `funcional` + `DT4`/`M4` `VALIDADO`)

### Pendientes (`archivo recibido` `no resuelve`)
- `Firma Release` (`Keystore` `.jks` — `Mejoras v16`, §7; `archivo recibido`: `build.gradle.kts` `intacto` `debug`).
- `Colores` (`hardcodeados` — `archivo recibido`: `mapa_principal_page.dart` `DeepPurple` `FAB`/`Avisos`/`pin`; `auth_page.dart` `DeepPurple` `Icon`).
- `M6-06` (`GPS` — `archivo recibido`: `_centrarEnMiUbicacion` `maneja` `sinSenal` `como` `última` `conocida` — `no` `cubre` `ambos` `vacíos`; `Estado`: `NO VERIFICADO` `físico`).
- `SMTP` (`Resend` — `archivo recibido`: `no modificado`).
- `Data Safety` (`archivo recibido`: `no documentado`).

### Resueltos (`archivo recibido` `actualizado` `DT4`/`M4`/`E6`)
- `DT4` (`email` `autovalidate` + `Timer`): `CERRADO`.
- `M4` (`Cómo llegar` — `Google Maps`): `CERRADO`.
- `Identidad` (`com.muralitoapp.app`): `CERRADO`.

---

## 8. Seguridad (`v006` — `archivo recibido` `intacto` `funcional`)

### `RLS` (`PostgreSQL` — `funcional` `VALIDADO`; `documental` `NO VERIFICADO`)
- `public.murales`: `SELECT` (`pública`); `INSERT` (`auth.uid()`); `UPDATE` (`auth.uid()` — `lat`/`lng` `omisión`); `DELETE` (`auth.uid()`).
- `public.perfiles`: `SELECT` (`pública`); `INSERT` (`auth.uid()` — `trigger` `automatico` `manejar_nuevo_usuario`); `UPDATE` (`auth.uid()`); `DELETE` (`denegado` `clientes`).
- `Nota`: `VALIDADO` `funcional` (`#015` `perfiles` `trigger`; `B1` `Storage` `listing`; `DT1`/`DT2` `rollback`; `M1`–`M6` `autenticación` `operativo`). `NO VERIFICADO` `documental` (`archivo .sql` `CREATE POLICY` `no disponible`; `trigger` `SQL` `no inspeccionado`). `Estado`: `funcional` `VALIDADO`; `documental` `NO VERIFICADO` — `no cambia` (`archivo recibido` `funcional` `intacto`).

### `Storage` (`políticas` `funcionales` — `VALIDADO`)
- `Bucket`: `murales` (`plano` — `archivo recibido`: `nombreArchivoDesdeTitulo`).
- `B1`: `Listing` `restringido` (`autenticados` — `archivo recibido`: `funcional`).
- `URLs`: `Públicas` (`archivo recibido`: `funcional`).
- `Subida`: `Autenticado` (`archivo recibido`: `funcional`).
- `Eliminación`: `Owner` (`auth.uid()` — `archivo recibido`: `funcional`).
- `Rollback`: `DT1` (`INSERT` `falla` → `borra` `nuevo`); `DT2` (`UPDATE` `falla` → `borra` `nuevo`; `éxito` → `borra` `anterior`).

### `Auth` (`funcional` — `VALIDADO`)
- `M1` (`contraseña` `segura` + `checklist` `DT4-01`): `VALIDADO` (`archivo recibido` `intacto`).
- `M2` (`OTP` `Resend` `60s`): `VALIDADO` (`archivo recibido` `intacto`).
- `DT4` (`email` `autovalidate` `reactivo` + `Timer` `3s`): `VALIDADO` (`archivo recibido` `actualizado` `DT4` — `#1`–`#13 PASS`).
- `DT4-02` (`anti-enumeración`): `VALIDADO` (`archivo recibido`: `respuesta` `genérica` `cuenta` `preexistente`).

### `Android` (`identidad` + `atribución`)
- `Identidad`: `namespace` + `applicationId` (`com.muralitoapp.app`) — `VALIDADO`.
- `Atribución`: `userAgentPackageName` (`com.muralitoapp.app`) + `bottomLeft` (`texto` `© Colaboradores`, `click` `copyright`) — `VALIDADO`.

### `Bloqueos` (`funcionales` `independientes`)
- `M9`: `Leaked Passwords` (`BLOQUEADO` — `Supabase Pro` — `archivo recibido`: `no implementado`).
- `Firma Release`: `Keystore` (`PENDIENTE` — `archivo recibido`: `build.gradle.kts` `intacto` `debug`).

---

## 9. Estado (`v006` — `archivo recibido` + `evidencia física`)

| Componente / Funcionalidad | Estado (`v12` → `v16` → `v006`) | Evidencia (`archivo recibido` / `física`) |
|---|---|---|
| `DT4` (`email` — `autovalidate` + `Timer`) | ✅ `VALIDADO` (`CERRADO`) | `#1`–`#5` (`PASS`); `archivo recibido`: `addListener` + `Timer` + `dispose` |
| `DT4` (`email` — `"Siguiente"`) | ✅ `VALIDADO` (`CERRADO`) | `#1` (`PASS` — `visible`); `archivo recibido`: `addListener` |
| `DT4` (`Timer` `3s` — `email`) | ✅ `VALIDADO` (`CERRADO`) | `#2`, `#5` (`PASS`); `archivo recibido`: `_timerErrorEmail` |
| `DT4` (`password` — `DT4-01` — `regresión`) | ✅ `VALIDADO` (`SIN REGRESIÓN`) | `#6`, `#12` (`PASS`); `archivo recibido`: `_passFocusNode` `intacto` |
| `M4` (`Cómo llegar` — `Google Maps`) | ✅ `VALIDADO` (`CERRADO`) | `A`–`E` (`PASS`); `archivo recibido`: `_abrirComoLlegar` (`URI`: `google.com/maps`) |
| `M4` (`restricción` `mapa` `intacto`) | ✅ `CONFIRMADO` (`VALIDADO`) | `B` (`PASS` — `mapa` `OSM`); `archivo recibido`: `TileLayer` `intacto` |
| `E6` (`Atribución` — `funcional` + `opcional`) | ✅ `VALIDADO` (`CERRADO`) | `D` (`PASS` — `funcional`); `archivo recibido`: `fontSize` `13` `w600` `padding` `8,4` `fondo` `0xDDF5F5F5` |
| `Flujos` (`mapa_principal_page.dart` — `God-page`) | ✅ `VALIDADO` (`funcional` `intacto` `salvo` `URI` `M4` + `estilo` `E6`) | `archivo recibido`: `mapa` `funcional` (`clustering`, `FAB`, `Ficha`, `CRUD`, `Perfil`, `Avisos`) |
| `Flujos` (`auth` — `DT4` `intacto` `salvo` `email` `actualizado`) | ✅ `VALIDADO` (`funcional` `intacto` `salvo` `DT4`) | `archivo recibido`: `auth` `funcional` (`M1`, `M2`, `perfil`) |
| `Regresiones` (`v12`/`v16` `funcionales` + `DT4`/`M4` `v006`) | ✅ `PASS` (`#1`–`#16` `físico`) | `archivo recibido`: `mapa_principal_page.dart` (`funcional` `PASS` `E`); `auth` (`PASS` `#1`–`#13`); `flutter analyze`: `No issues found!` |
| `Identidad` (`namespace`/`applicationId`) | ✅ `VALIDADO` (`CERRADO`) | `archivo recibido`: `build.gradle.kts` (`com.muralitoapp.app`) |
| `Atribución` (`v16` `integración` + `opcional` `v006`) | ✅ `VALIDADO` (`CERRADO`) | `archivo recibido`: `bottomLeft` (`texto` `mantenido`, `click` `mantenido`, `opcional` `aplicado`) |
| `M6-06` (`GPS` — `NO VERIFICADO`) | ❓ `NO VERIFICADO` (`PENDIENTE` — `hardware`) | `archivo recibido`: `funcional` (`sinSenal` `manejado` `como` `última` `conocida`) `pero` `no` `cubre` `ambos` `vacíos`; `Estado`: `NO VERIFICADO` — `prueba` `física` (`GPS` `apagado` + `sin` `historial`) |
| `Colores` (`hardcodeados`) | ⏳ `PENDIENTE` (`estilo` — `no bloqueante`) | `archivo recibido`: `mapa_principal_page.dart` (`FAB`: `deepPurple`; `Avisos`: `deepPurple[700]`; `pin`: `deepPurple`); `auth`: `Icon` `deepPurple` |
| `DT8` (`Storage` — `uri.pathSegments.last`) | ⚠️ `RIESGO` (`plano` `funcional`; `subcarpetas` `romperían`) | `archivo recibido`: `borrarFotoDeStorage` (`uri.pathSegments.last` — `funcional` `plano`) |
| `DT10` (`God-page`) | ⚠️ `RIESGO` (`no resuelto` — `no aumenta` `M4` `URI` `independiente`) | `archivo recibido`: `mapa_principal_page.dart` (`concentración` `mapa`/`clustering`/`auth`/`UI`) |
| `DT11`/`DT12` (`Repository`) | ⏳ `PENDIENTE` (`archivo recibido`: `supabase_client.dart` `directo`) | `archivo recibido`: `mapa_principal_page.dart` (`.from('murales').select()` `directo`) |
| `DT14` (`Tests`) | ⏳ `PENDIENTE` | `archivo recibido`: `flutter test` `no creado` |
| `M9` (`Leaked` — `Supabase Pro`) | ⛔ `BLOQUEADO` (`archivo recibido`: `no implementado`) | `archivo recibido`: `no existe` `código` `M9` |
| `Firma Release` (`Keystore`) | ⏳ `PENDIENTE` (`recomendado` `siguiente` — `bloqueante`) | `archivo recibido`: `build.gradle.kts` (`release` `debug`); `.jks` `no generado`; `Mejoras v16`, §7 |
| `SMTP` (`Resend` — `dominio` `propio`) | ⏳ `PENDIENTE` (`archivo recibido`: `no actualizado`) | `archivo recibido`: `no modificado` (`SMTP` `Resend` `configurado`) |
| `Data Safety` (`Play Store`) | ❓ `NO DOCUMENTADO` (`archivo recibido`: `no menciona`) | `archivo recibido`: `mapa_principal_page.dart`, `Mejoras v16` `no mencionan`; `requisito` `Play Store` — `verificar` `previo` `publicación` |
| `M17` (`Borradores` `offline`) | ⏳ `PENDIENTE` (`post-v1`) | `archivo recibido`: `no implementado` (`image_picker` `caché` `volátil`) |
| `A4` (`Autor` `≠` `Uploader`) | ⏳ `PENDIENTE` (`archivo recibido`: `A3` `Subido por` `muestra` `upload` `no` `artista`) | `archivo recibido`: `no` `hay` `campo` `artista` (`public.murales` `o` `public.perfiles`) |
| `A1.4` (`Historial` `fotos` `6` `días`) | ⏳ `PENDIENTE` (`archivo recibido`: `Storage` `plano`; `Rollback` `DT2` `funcional`; `subcarpetas` `DT8` `romperían`) | `archivo recibido`: `nombreArchivoDesdeTitulo` (`plano` `funcional`) |
| `Supabase SQL` (`RLS` `CREATE POLICY` — `archivo .sql`) | ❓ `NO VERIFICADO` (`archivo recibido`: `funcional` `VALIDADO` `funcional` `#015`/`B1`; `.sql` `no disponible`) | `Estado`: `funcional` `VALIDADO` (`archivo recibido` `funcional` `intacto`); `documental` `NO VERIFICADO` (`archivo .sql` `no inspeccionado`) — `no cambia` (`archivo recibido` `funcional` `intacto`) |

---

## 10. Próximo objetivo (`v006` — `recomendado`: `Firma Release` — `bloqueante` `publicación`)

**Estado (`archivo recibido` `actualizado` `DT4`/`M4`/`E6` — `funcional` `VALIDADO` `físico`):**
- `DT4`: `CERRADO` (`VALIDADO` `#1`–`#13 PASS` — `archivo recibido` `actualizado`).
- `M4`: `CERRADO` (`VALIDADO` `A`–`E PASS` — `archivo recibido` `actualizado`).
- `E6`: `VALIDADO` (`funcional` `intacto` + `opcional` `aplicado` — `archivo recibido` `actualizado`).
- `Flujos`: `VALIDADO` (`archivo recibido` `mapa_principal_page.dart` `funcional` `PASS` `E` — `clustering`/`ficha`/`FAB`/`Avisos`/`Auth` `intacto`).

**Candidato (`Mejoras v16`, §7; `Documentación Técnica v17`, §6; `Handoff Técnico v005`, §16):**
> **`Firma Release` (`Keystore` `.jks` + `signingConfig` `release` + `key.properties` + `.aab` `release`) — `Mejoras v16`, §7; `Documentación Técnica v17`, §5.3; `bloqueante` `Google Play`.**

- **Archivo (`archivo recibido` `intacto` `no actualizado` — `requisito` `actualizar`):** `android/app/build.gradle.kts`.
- **Estado (`archivo recibido`):** `release` → `signingConfigs.getByName("debug")` (`PENDIENTE`).
- **Restricción (`archivo recibido` — `no modificar` `funcional`):** `mapa_principal_page.dart` (`mapa`, `clustering`, `FAB`, `Avisos`, `Ficha`, `CRUD`, `Perfil`, `Atribución`) `intacto`; `auth_page.dart` (`DT4`) `intacto`; `recuperar_password_page.dart` (`DT4`) `intacto`; `helpers.dart` (`Sanitización`, `Rollback`, `Notificaciones`) `intacto`.
- **Auditoría (`previo` — `Mejoras v16`, §7; `Documentación Técnica v17`, §5.3):**
  - `namespace` (`com.muralitoapp.app`) `intacto` (`archivo recibido` `v16`).
  - `applicationId` (`com.muralitoapp.app`) `intacto`.
  - `.env` (`SUPABASE_URL`, `ANON_KEY`) `excluido` (`archivo recibido` `.env` `asset`; `.env.example` `existe`).
  - `Keystore` (`.jks`): `generar` (`nuevo` — `archivo recibido`: `no existe`).
  - `key.properties`: `crear` (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`) — `excluir` `.gitignore` (`archivo recibido`: `.gitignore` `excluye` `.env` — `agregar` `.jks` + `key.properties`).
  - `flutter build appbundle` (`release`): `compilar` (`sin errores` `firma`).

**Alternativa (`Mejoras v16`, §6 — `estilo`, `no bloqueante`):**
> **`Colores hardcodeados` (`Colors.deepPurple` `~53` `referencias` — `Theme.of(context).colorScheme` — `archivo recibido`: `mapa_principal_page.dart` `FAB`/`Avisos`/`pin` `deepPurple`; `auth_page.dart` `Icon` `deepPurple`).**

**Estado (`v006` — `cierre`):**
- `MVP`: `funcional` `avanzado` (`DT4` `VALIDADO`; `M4` `VALIDADO`; `E6` `VALIDADO`).
- `Flujos`: `Actualizado` (`v13` — `archivo recibido` `mapa_principal_page.dart` `funcional` `PASS` `E`; `auth` `VALIDADO` `#1`–`#13`).
- `Documentación`: `Actualizado` (`v17` — `Estado`, `Funcionalidades`, `Deuda`, `Riesgos`, `Discrepancias`, `Siguiente`, `Auditoría` — `bloque` `completo`).
- `Siguiente` (`recomendado`): `Firma Release` (`Keystore`).
- `Pendiente` (`post-v1`/`estilo`): `Colores`, `DT8`, `DT10`, `DT11`/`DT12`, `DT14`, `M6-06`, `M9`, `M17`, `A4`, `A1.4`, `SMTP`, `Data Safety`.

**Estado final (`archivo recibido` + `evidencia física` + `documentación v17` + `v13`):**
`No inventado`: `Todas` `afirmaciones` `se respaldan` `en los archivos recibidos` (`mapa_principal_page.dart` `actualizado` `M4`/`E6`; `auth_page.dart` `actualizado` `DT4`; `recuperar_password_page.dart` `actualizado` `DT4`; `helpers.dart` `intacto`; `pubspec.yaml` `intacto`; `models/`/`widgets/` `intactos`) `y en la evidencia física reportada` (`#1`–`#16 PASS`; `flutter analyze`: `No issues found!`).

**Nota técnica final (`v006` — `archivo recibido` `funcional` `VALIDADO` `DT4`/`M4`/`E6`):**
- `Estado`: `DT4` (`VALIDADO` — `autovalidate` `reactivo` + `Timer` `3s` — `archivo recibido` `actualizado`).
- `Estado`: `M4` (`VALIDADO` — `Cómo llegar` `Google Maps` — `archivo recibido` `actualizado`: `_abrirComoLlegar` `URI` `google.com/maps`).
- `Estado`: `E6` (`VALIDADO` — `Atribución` `funcional` `intacta` + `opcional` `mejorado`: `fontSize` `13`, `w600`, `padding` `8,4`, `fondo` `0xDDF5F5F5`).
- `Estado`: `Flujos` (`v13` — `archivo recibido` `mapa_principal_page.dart` `funcional` `PASS` `E` — `clustering`/`ficha`/`FAB`/`Avisos`/`Auth` `intacto`).
- `Estado`: `Discrepancias` (`resueltas`: `Identidad`, `DT4`, `M4`, `E6` `consistente`; `persistentes`: `M6-06` `NO VERIFICADO`; `Colores` `PENDIENTE`; `DT8` `RIESGO`; `DT10` `RIESGO`; `DT11`/`DT12` `PENDIENTE`; `DT14` `PENDIENTE`; `M9` `BLOQUEADO`; `Firma` `PENDIENTE`; `SMTP` `PENDIENTE`; `Data Safety` `NO DOCUMENTADO`).
- `Estado`: `Siguiente objetivo` (`recomendado`): `Firma Release` (`Keystore` `.jks` — `bloqueante` `Play Store` — `archivo recibido`: `build.gradle.kts` `intacto` `debug`).
- `Estado`: `No inventado`: `Todas` `las afirmaciones` `se respaldan` `en los archivos recibidos` (`mapa_principal_page.dart`, `auth_page.dart`, `recuperar_password_page.dart`, `helpers.dart`, `pubspec.yaml`) `y en la evidencia física reportada` (`flutter run`: `#1`–`#16 PASS`; `flutter analyze`: `No issues found!`).