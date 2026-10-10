# Muralito App — Documentación Técnica v17

**Versión:** 17  
**Fecha:** [actualiza con fecha de hoy]  
**Estado:** MVP funcional avanzado — DT4 y M4 validados mediante ejecución física (`flutter run`)  
**Sustituye a:** Documentación Técnica v16 (26/09/2026)  
**Referencias documentales sincronizadas:** Flujos Funcionales v12, Mejoras v16, README.md (26/09/2026), Handoff Técnico (27/09/2026).

---

## 0. Control de versiones y cambios v16 → v17

**Documentos vigentes:**
- Documentación Técnica v17 (esta revisión)
- Flujos Funcionales v12 (26/09/2026)
- Mejoras v16 (26/09/2026)
- README.md (26/09/2026)
- Handoff Técnico — Sesión 27/09/2026

**Cambios formales v16 → v17:**
- `DT4` (`email` — `autovalidate` reactivo + `Timer 3s`): implementado y validado (`auth_page.dart` + `recuperar_password_page.dart`, evidencia física `#1`–`#13 PASS`).
- `M4` (`Cómo llegar` → `Google Maps` nativo): implementado y validado (`mapa_principal_page.dart`: `_abrirComoLlegar` actualizado a `URI` `google.com/maps/dir/?api=1`; evidencia `A`–`E PASS`).
- `E6` (`Atribución OSM` — `visibilidad` mejorada, opcional): actualizado (`fontSize 13`, `fontWeight w600`, `padding 8,4`, `fondo 0xDDF5F5F5`); funcional intacto (`D PASS`, `política OSM` cumplida).
- `Identidad Android` (`namespace`/`applicationId`): confirmada (`com.muralitoapp.app`, `v15` rectificado formalmente).
- `Discrepancias resueltas`: `Identidad Android` (`v15` → `v16`), `DT4` (`v16` pendiente → `v17` validado), `M4` (`v12` `OSM` → `v17` `Google Maps` implementado), `E6` (`archivo` `v16` `§5.2` → `archivo recibido` actualizado, consistente).

---

## 1. ESTADO ACTUAL

**Estado del proyecto:** MVP funcional avanzado (`Flutter 3.47.0`, `Dart 3.13.0`, `Android SDK 36`). `Supabase` (`PostgreSQL 15+`, `Auth`, `Storage`). `OpenStreetMap` (`flutter_map ^8.3.1`).

**Estado de la documentación (`v17`):** Sincronizada con código recibido (`mapa_principal_page.dart`, `auth_page.dart`, `recuperar_password_page.dart`, `helpers.dart`, `pubspec.yaml`) y con evidencia física (`flutter run`: `#1`–`#16 PASS`).

**Estado técnico (`archivo recibido` verificado en esta sesión):**

| Área | Estado | Evidencia / Nota |
|---|---|---|
| `DT4` (`email` — `autovalidate` + `Timer 3s`) | 🧪 **VALIDADO** (`CERRADO`) | `auth_page.dart` (`_emailFocusNode.addListener` + `_iniciarTimerErrorEmail`); `recuperar_password_page.dart` (`mismo` patrón). Ejecución física: `#1` (`Siguiente` visible) `PASS`; `#2` (`Timer` `3s`) `PASS`; `#3` (`escribir` limpia) `PASS`; `#4` (`vacío` + botón `bloquea`) `PASS`; `#5` (`Timer` tras vacío) `PASS`; `#6` (`password` sin regresión) `PASS`; `#7` (`envío` `válido`) `PASS`. `flutter analyze`: `No issues found!`. |
| `DT4` (`password` — `DT4-01`) | 🧪 **VALIDADO** (sin regresión) | `_passFocusNode.addListener` (`_alCambiarFocoPassword`, `_ocultarErrorPasswordAlEscribir`). Ejecución: `#6`, `#12 PASS`. |
| `M4` (`Cómo llegar` → `Google Maps`) | 🧪 **VALIDADO** (`CERRADO`) | `mapa_principal_page.dart`: `_abrirComoLlegar` (`URI` `https://www.google.com/maps/dir/?api=1&destination=$lat,$lng`; `LaunchMode.externalApplication`). Ejecución: `A` (`botón` existe) `PASS`; `B` (`mapa` `OSM` `intacto`) `PASS`; `C` (`Google Maps` `abre`) `PASS`; `D` (`Atribución` `bottomLeft` `intacta`) `PASS`; `E` (`regresión` `God-page`: `clustering`, `FAB`, `Avisos`, `Auth`) `PASS`. `E6` (`visibilidad` `mejorada`) `funcional` `PASS`. |
| `E6` (`Atribución OSM` — `visibilidad` mejorada, opcional) | 🧪 **VALIDADO** (`funcional` + `opcional`) | `archivo recibido`: `fontSize: 13`, `fontWeight: w600`, `padding: 8,4`, `fondo: 0xDDF5F5F5` (anterior: `11`, `normal`, `6,3`, `CCFFFFFF`). `Texto`: `© Colaboradores de OpenStreetMap` (`mantenido`). `Enlace`: `https://www.openstreetmap.org/copyright` (`mantenido`). `Sin prefijo`: `flutter_map | ` (`descartado`, `Mejoras v16`, §2.1). `Política OSM` (`tile.openstreetmap.org`) `cumplida` (`v16`, §5.2). |
| `M6` (`Centrar ubicación`) | 🧪 **VALIDADO PARCIAL** | `M6-01`...`05` y `07` (`PASS`). `M6-06` (`GPS` `apagado` + `sin última ubicación` `conocida`): **NO VERIFICADO** (`hardware físico` `no aislado` `en esta sesión`; `Documentación Técnica v16`, §13; `Flujos Funcionales v12`, §19; `Mejoras v16`, §5). |
| `Auth` (`M1` — `contraseña`; `M2` — `OTP`; `DT4-02` — `anti-enumeración`) | 🧪 **VALIDADO** | `auth_page.dart`: `checklist` (`_requisitosContrasena`), `DT4-01` (`password`), `DT4` (`email` + `Timer`). `recuperar_password_page.dart`: `M2` (`OTP` `6` dígitos, `Resend`, `cooldown` `60s`). `DT4-02` (`respuesta` `genérica` `cuenta` `preexistente`). `Mejoras v16`, §1. |
| `Perfil` (`trigger` + `avatar`) | 🧪 **VALIDADO** | `public.perfiles`: `trigger` `on_auth_user_created` (`manejar_nuevo_usuario()`, `SECURITY DEFINER`). `RLS`: `SELECT` `pública`; `INSERT`/`UPDATE` (`auth.uid()`); `DELETE` (`denegada`). `DT2` (`avatar` `rollback` `Storage`) `VALIDADO` (`pruebas` `DT2-01`...`05`). |
| `CRUD` (`murales`) | 🧪 **VALIDADO** | `public.murales`: `RLS` (`SELECT` `pública`; `INSERT`/`UPDATE`/`DELETE` `auth.uid()`). `Inmutabilidad` (`lat`/`lng` `no editables` `post-publicación`). `Rollback` (`DT1` — `Storage` `borrado` `si INSERT` `falla`) `VALIDADO`. `Sanitización` (`nombreArchivoDesdeTitulo`) `VALIDADO` (`prueba` `"/"` `en título`). |
| `Map` (`flutter_map` + `OSM` + `clustering`) | 🧪 **VALIDADO** | `flutter_map ^8.3.1`. `TileLayer` (`openstreetmap.org`). `Clustering` (`_radioClusterMetros = 30` `m`). `_AvisoUI` (`toasts` `superior`, `3s`, `verde`/`rojo`/`morado`). `Atribución` (`bottomLeft`, `clickable`). `M4` (`URI` `Google Maps`) `VALIDADO` (`C PASS`). `Regresión` (`E PASS`). |
| `Identidad Android` (`namespace`/`applicationId`) | 🧪 **VALIDADO** | `android/app/build.gradle.kts`: `namespace = "com.muralitoapp.app"`; `applicationId = "com.muralitoapp.app"`. `MainActivity.kt`: `package com.muralitoapp.app`. `Mejoras v16`, §2.1. |
| `Storage` (`bucket murales` — `políticas`) | 🧪 **VALIDADO** (funcional) | `B1` (`listing` `restringido` `autenticados`). `SELECT` (`URLs` `públicas`). `INSERT` (`autenticado`). `DELETE` (`owner = auth.uid()`). `Rollback` (`DT1`/`DT2`) `VALIDADO`. `Sanitización` (`nombreArchivoDesdeTitulo`) `VALIDADO`. ❓ `Políticas SQL` (`CREATE POLICY`) `NO VERIFICADAS` (`archivo .sql` `no disponible`; `Handoff Técnico`, §0, §7). |
| `M5` (`GPS` + `Pin` `fijo`) | 🧪 **VALIDADO** | `M5-01`...`11` (`PASS`). `Pin` `fijo` (`AjustarUbicacionPage`: `cámara` `centro` `estático`). `GPS` (`timeout` `10s`, `no bloqueante`). `Manual` (`mapa` `arrastre`). `Inmutabilidad` (`lat`/`lng` `post-publicación`). |
| `M3` (`Onboarding` `ubicación` — `shared_preferences`) | 🧪 **VALIDADO** | `4` `pruebas` `manuales` (`PASS`). `Persistencia` (`clave` `onboarding_ubicacion_visto`). `Disparo` (`primera` `acción` `GPS`: `Nuevo Mural` `o` `Mi ubicación`). |
| `Sistema Avisos` (`_AvisoUI`) | 🧪 **VALIDADO** | `mapa_principal_page.dart`: `Stack` `superior` (`AppBar` `debajo`). `_AvisoUI` (`exito`, `error`, `info` `+ GPS`, `accion` `interactiva`). `Duración`: `3s` (`Timer`). `No colisión`: `FAB` (`Nuevo Mural`, `Mi ubicación`) `anclados` `inferior` `derecho` (`padding` `retirado`, `Mejoras v16`, §2.3). |
| `Selector Foto` (`Cámara` / `Galería`) | 🧪 **VALIDADO** | `_seleccionarOrigenFoto()` (`modal` `inferior`: `Tomar fotografía` / `Elegir de galería`). `4` `pruebas` `PASS` (`Mejoras v16`, §2.2). |
| `M9` (`Leaked Passwords` — `HIBP`) | ⛔ **BLOQUEADO** | `Requiere` `plan` `Supabase Pro`. `Documentación Técnica v16`, `§Funcionalidad bloqueada`. |
| `Tests automatizados` (`DT14` — `flutter test`) | ⏳ **PENDIENTE** | `Mejoras v16`, §6. `Cobertura` `funcional` `manual` (`#1`–`#16`) `disponible`. |
| `Colores hardcodeados` (`Colors.deepPurple` — `~53` refs, `8` archivos) | ⏳ **PENDIENTE** (deuda `estilo`) | `mapa_principal_page.dart`: `FAB` (`Colors.deepPurple`), `pin` (`Colors.deepPurple`), `Aviso` (`Colors.deepPurple[700]`), `AppBar` (`Colors.deepPurple`). `auth_page.dart`: `Icon` (`Colors.deepPurple`). `Mejoras v16`, §6; `Handoff Técnico`, §13. `No aumenta` (`DT4` `no usa` `deepPurple`; `M4` `URI` `no afecta`). |
| `Firma Release` (`Keystore` `.jks`) | ⏳ **PENDIENTE** (`Bloqueante Play Store`) | `android/app/build.gradle.kts`: `release` → `signingConfigs.getByName("debug")`. `Keystore` (`.jks`) `no generado`. `key.properties` (`excluido` `.gitignore`). `Mejoras v16`, §7. |
| `SMTP` (`Resend` — `dominio` `propio` — `SPF`/`DKIM`) | ⏳ **PENDIENTE** (`Evaluadores externos`) | `Remitente`: `onboarding@resend.dev`. `Dominio` `verificado` `pendiente`. `Documentación Técnica v16`, §Hallazgos. |
| `M6-06` (`GPS` — `sin señal` `ni` `última ubicación`) | ❓ **NO VERIFICADO** | `Estado`: `NO VERIFICADO` (`hardware` `físico` `no aislado` `en esta sesión`). `No afectado` (`DT4`/`M4` `independiente`). `Documentación Técnica v16`, §13; `Flujos Funcionales v12`, §19. |
| `Publicación` (`Data Safety` — `Google Play`) | ❓ **NO DOCUMENTADO** (`archivo recibido` `no menciona`) | `Estado`: `NO VERIFICADO` (`requisito` `Play Store`; `no inventado`). `Requiere` `verificación previa` (`M4` `VALIDADO` `no resuelve` `esto`; `Firma Release` `PENDIENTE` `tampoco`). |

> ❓ **Nota técnica (`Supabase` — `SQL`/`Console`)**: `No se dispone` `de acceso` `directo` `a la consola` `ni a los archivos .sql` `de Supabase` (`Handoff Técnico`, §0, §7). `Las políticas RLS`, `triggers` (`manejar_nuevo_usuario`), `políticas de Storage` (`bucket murales`) `se respaldan` `por la documentación técnica` (`Documentación Técnica v16`, §8, §9) `y por las pruebas de integración funcionales` (`#015`, `B1`, `DT1`, `DT2`, `M1`...`M6`), `pero no por evidencia directa del archivo SQL en esta sesión`.

---

## 2. FUNCIONALIDADES (`v17` actualizado — `archivo recibido` `mapa_principal_page.dart`, `auth_page.dart`, `recuperar_password_page.dart`, `helpers.dart`)

### ✅ HECHO / IMPLEMENTADO (`archivo recibido` + `evidencia física`)

- **`DT4` (`email` — `autovalidate` `reactivo` + `Timer 3s`)**: `auth_page.dart` (`_emailFocusNode` `addListener`, `_mostrarErrorEmail`, `onChanged`, `onTapOutside`, `_enviar()` `setState` + `_iniciarTimerErrorEmail()`); `recuperar_password_page.dart` (`mismo` `patrón`: `_emailFocusNode`, `onChanged`, `onTapOutside`, `_enviarCodigo` `setState` + `_iniciarTimerErrorEmail()`); `Timer` (`_timerErrorEmail`, `Duration(seconds: 3)`); `dispose()` (`_timerErrorEmail?.cancel()`, `_emailFocusNode.removeListener`, `.dispose()`).
- **`DT4` (`password` — `DT4-01`)**: `auth_page.dart` (`_passFocusNode` `addListener`: `_alCambiarFocoPassword`, `_ocultarErrorPasswordAlEscribir`, `_actualizarValidacionContrasena`); `recuperar_password_page.dart` (`_passFocusNode` `addListener`: `_alCambiarFocoPassword`, `_ocultarErrorPasswordAlEscribir`, `_requisitosContrasena`).
- **`M4` (`Cómo llegar` — `Google Maps`)**: `mapa_principal_page.dart`: `_abrirComoLlegar` (`Future<void>`; `final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');`; `await launchUrl(uri, mode: LaunchMode.externalApplication);`; `if (!mounted) return;`; `if (!ok) { _mostrarAviso(...) ... }`).
- **`E6` (`Atribución OSM` — `visibilidad` `mejorada`, `opcional`)**: `mapa_principal_page.dart`: `Align(alignment: Alignment.bottomLeft)`; `ColoredBox(color: Color(0xDDF5F5F5))`; `InkWell` (`onTap`: `launchUrl` `copyright`); `Text('© Colaboradores de OpenStreetMap', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87))`; `padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4)`.
- **`Mapa` (`flutter_map` + `OSM`)**: `mapa_principal_page.dart`: `FlutterMap` (`mapController`, `options`: `initialCenter`, `initialZoom`, `minZoom`, `maxZoom`, `backgroundColor`, `interactionOptions`); `TileLayer` (`urlTemplate`: `https://tile.openstreetmap.org/{z}/{x}/{y}.png`, `userAgentPackageName`: `com.muralitoapp.app`, `maxNativeZoom`, `keepBuffer`, `panBuffer`); `MarkerLayer` (`markers`: `_buildMarkers()`).
- **`Clustering` (`30m`)**: `mapa_principal_page.dart`: `_radioClusterMetros` (`30`); `_agruparMuralesCercanos()` (`Distance()` `latlong2`); `_centroDelGrupo()` (`LatLng` `promedio`); `_zoomHaciaGrupo()` (`zoomActual + 2` `clamp` `6.0` `18.0`); `_mostrarGrupoMurales()` (`DraggableScrollableSheet` `lista`).
- **`Pin` (`individual` / `cluster`)**: `_pinMural()` (`Container`: `Colors.deepPurple`, `border`: `white`, `boxShadow`, `Icon`: `brush`); `_pinCluster()` (`Container`: `Colors.deepPurple` / `[700]` / `[900]`, `border`: `white`, `boxShadow`, `Text`: `cantidad`).
- **`Ficha` (`DraggableScrollableSheet`)**: `_mostrarDetalleMural()` (`DraggableScrollableSheet`: `initialChildSize`, `minChildSize`, `maxChildSize`, `expand`: `false`); `foto` (`Image.network`, `errorBuilder`); `título`; `_filaAutor()` (`A3`: `apodo`, `avatar`); `descripción` (`texto` / `Sin descripción`); `coordenadas` (`Lat`/`Lng` `formateado`); `botones` (`Editar` `esPropietario`, `Eliminar` `esPropietario`, `Cómo llegar` `M4` `actualizado`, `Cerrar`).
- **`CRUD` (`mural`)**: `_subirMural()` (`compresión` `FlutterImageCompress`, `uploadBinary` `Storage`, `insert` `PostgreSQL`, `rollback` `Storage` `si INSERT` `falla`); `_editarMural()` (`UPDATE` `título`/`descripción` `o` `foto` `nueva` `+ rollback` `anterior` `si UPDATE` `falla`); `_eliminarMural()` (`DELETE` `PostgreSQL` `+ borrado` `Storage`).
- **`Perfil` (`avatar` `seguro`)**: `_guardarPerfil()` (`DT2`: `compressWithFile` `400x400` `quality 80`, `uploadBinary` `Storage`, `UPDATE` `PostgreSQL`, `rollback` `Storage` `si UPDATE` `falla`, `borrado` `anterior` `best-effort` `si éxito`).
- **`Auth` (`M1` — `contraseña` `segura`)**: `_validarContrasenaRegistro()` (`8` `caracteres`, `mayúscula`, `minúscula`, `número`, `especial`); `_requisitosContrasena()` (`AnimatedContainer`, `checklist` `visual`).
- **`Auth` (`M2` — `recuperación` `OTP`)**: `RecuperarPasswordPage`: `_enviarCodigo()` (`resetPasswordForEmail`, `_iniciarCooldownReenvio` `60s`); `_confirmarRecuperacion()` (`verifyOTP` `recovery`, `updateUser` `UserAttributes` `password`).
- **`Onboarding` (`M3`)**: `mostrarOnboardingUbicacionSiCorresponde()` (`shared_preferences`, `clave`: `onboarding_ubicacion_visto`); `onboarding_ubicacion_dialog.dart` (`dialogo` `explicativo`, `única vez`).
- **`GPS` (`M5`/`M6`/`Servicio`)**: `ubicacion_service.dart`: `obtenerUbicacion()` (`Geolocator` `timeout` `10s`); `ResultadoUbicacion` (`estado`: `listo`, `gpsApagado`, `permisoDenegado`, `permisoBloqueado`, `sinSenal`); `_centrarEnMiUbicacion()` (`mapa_principal_page.dart`: `spinner` `FAB`, `toast` `interactivo` `Ajustes`/`Activar`).
- **`Notificaciones` (`_AvisoUI`)**: `mapa_principal_page.dart`: `_AvisoUI` (`mensaje`, `tipo`: `exito`/`error`/`info`, `accionLabel`, `onAccion`); `_mostrarAviso()` (`Timer` `3s`, `cancel` `previo`); `_mostrarAvisoUbicacion()` (`GPS` `interactivo`).
- **`Selector` (`Cámara` / `Galería`)**: `_seleccionarOrigenFoto()` (`showModalBottomSheet` `ImageSource`: `camera` / `gallery`); `ImagePicker` (`maxWidth`: `1920`, `maxHeight`: `1920`, `quality`: `85`).
- **`Sanitización` (`Storage`)**: `helpers.dart`: `nombreArchivoDesdeTitulo()` (`RegExp` `[^a-zA-Z0-9áéíóúÁÉÍÓÚñÑ_-]` → `_`, `timestamp`, `.jpg`).
- **`Rollback` (`DT1`/`DT2`)**: `_subirMural()` (`try` `INSERT` → `catch` → `borrarFotoDeStorage` `nuevo`); `_guardarPerfil()` (`try` `UPDATE` → `catch` → `borrarFotoDeStorage` `nuevo`; `exito` → `borrarFotoDeStorage` `anterior`).
- **`Restricción` (`B1`)**: `Supabase` (`Storage`): `políticas` (`listing` `restringido` `autenticados`; `URLs` `públicas` `operativas`).
- **`Identidad` (`namespace`/`applicationId`)**: `build.gradle.kts` + `MainActivity.kt` (`com.muralitoapp.app`).

### 🧪 VALIDADO MEDIANTE PRUEBAS (`archivo recibido` + `evidencia física` `flutter run` `#1`–`#16 PASS`)

- `DT4` (`auth`): `#1` (`Siguiente` `visible` `PASS`); `#2` (`Timer` `3s` `PASS`); `#3` (`escribir` `limpia` `PASS`); `#4` (`vacío` + `botón` `bloquea` `PASS`); `#5` (`Timer` `tras` `vacío` `PASS`); `#6` (`password` `sin regresión` `PASS`); `#7` (`envío` `válido` `PASS`).
- `DT4` (`recuperación`): `#8` (`Siguiente` `paso 1` `PASS`); `#9` (`Timer` `3s` `PASS`); `#10` (`vacío` + `"Enviar código"` `bloquea` + `Timer` `PASS`); `#11` (`email inicial` `conservado` `PASS`); `#12` (`password` `sin regresión` `PASS`); `#13` (`Timer` `no interfiere` `OTP` `PASS`).
- `M4` (`mapa`): `A` (`botón` `"Cómo llegar"` `existe` `PASS`); `B` (`mapa` `OSM` `funciona` `PASS`); `C` (`Google Maps` `abre` `PASS`); `D` (`Atribución` `bottomLeft` `visible` + `clickable` `PASS`); `E` (`regresión` `clustering`/`ficha`/`FAB`/`Avisos`/`Auth` `PASS`).
- `E6` (`Atribución` `visibilidad` `mejorada`, `opcional`): `D` (`texto` `© Colaboradores` `mantenido` `PASS`); `fondo` (`0xDDF5F5F5` `visible` `PASS`); `font` (`13` `w600` `PASS`).
- `Regresión` `general`: `#14` (`flutter analyze`: `No issues found!` `PASS`); `#15` (`mapa_principal_page.dart`: `mapa` `intacto` `PASS`); `#16` (`build` `limpio` `PASS`).

### ⏳ PENDIENTE (`v17` — `no modificados` `en esta actualización` `DT4`/`M4`)

- `M6-06` (`GPS` `sin` `señal` `ni` `última` `ubicación` `conocida`): `NO VERIFICADO`.
- `Colores` (`Colors.deepPurple` — `~53` `referencias`): `PENDIENTE`.
- `DT8` (`Storage` — `borrarFotoDeStorage` `uri.pathSegments.last`): `RIESGO` (`funcional` `plano`; `subcarpetas` `rompería`).
- `DT10` (`God-page` — `mapa_principal_page.dart`): `RIESGO`.
- `DT11`/`DT12` (`Repository`): `PENDIENTE`.
- `DT14` (`Tests` `automatizados`): `PENDIENTE`.
- `M9` (`Leaked Passwords`): `BLOQUEADO`.
- `Firma Release` (`Keystore` `.jks`): `PENDIENTE` (`bloqueante`).
- `SMTP` (`Resend` — `dominio` `propio`): `PENDIENTE`.
- `Data Safety` (`Play Store`): `NO DOCUMENTADO`.
- `M17` (`Borradores` `offline`): `PENDIENTE` (`post-v1`).
- `A4` (`Uploader` ≠ `Artista`): `PENDIENTE` (`producto`).
- `A1.4` (`Historial` `fotos` — `6` `días`): `PENDIENTE` (`producto` + `Storage` `subrutas`).

### ❓ NO VERIFICADO / REQUIERE VERIFICACIÓN

- `M6-06` (`GPS` — `caso` `borde` `no aislado` `hardware`).
- `Supabase` (`RLS` `SQL` — `CREATE POLICY`, `trigger`, `Storage policies` — `archivo .sql` `no disponible` `en esta sesión`).
- `Data Safety` (`requisito` `Play Store` — `no inventado`).
- `IM` (`TextInputAction` `Next` — `DT4` `email`: `funciona` `estándar`; `otros` `IME` `no probados` `todos`).

---

## 3. DEUDA TÉCNICA (`v17` actualizado)

### Confirmada y resuelta (`evidencia` `archivo recibido` + `física`)

| ID / Elemento | Estado anterior | Estado (`v17`) | Evidencia (`archivo recibido` / `ejecución`) |
|---|---|---|---|
| `DT4` (`email` — `autovalidate`) | ⚠️ `PROBLEMA` (`retiene` `error`) | ✅ `VALIDADO` (`CERRADO`) | `auth_page.dart`: `_emailFocusNode.addListener(_alCambiarFocoEmail)`; `_mostrarErrorEmail`; `_iniciarTimerErrorEmail()`. `Ejecución`: `#1`–`#5 PASS`. |
| `DT4` (`email` — `"Siguiente"`) | ⚠️ `RIESGO` (`blanco`) | ✅ `VALIDADO` (`CERRADO`) | `Ejecución`: `#1 PASS` (`Siguiente` `visible`). `archivo recibido`: `addListener` `captura` `transición`. |
| `DT4` (`email` — `Timer`) | ⏳ `PENDIENTE` (`"luego"`) | ✅ `VALIDADO` (`CERRADO`) | `Ejecución`: `#2`, `#5`, `#9`, `#10 PASS`. `archivo recibido`: `Timer` (`3s`). |
| `DT4` (`password` — `DT4-01` — `regresión`) | ✅ `VALIDADO` (`v16`) | ✅ `VALIDADO` (`sin regresión`) | `Ejecución`: `#6`, `#12 PASS`. `archivo recibido`: `addListener` (`_passFocusNode`) `intacto`. |
| `M4` (`Cómo llegar` — `Google Maps`) | ⏳ `PENDIENTE` (`v16`) | ✅ `VALIDADO` (`CERRADO`) | `archivo recibido`: `_abrirComoLlegar` (`URI`: `google.com/maps`). `Ejecución`: `C PASS`. |
| `Identidad Android` (`namespace`/`applicationId`) | ⚠️ `DISCREPANCIA` (`v15`) | ✅ `VALIDADO` (`v16` → `v17`) | `build.gradle.kts` + `MainActivity.kt`. `Mejoras v16`, §2.1. |
| `Atribución OSM` (`v16` — `integración`) | ❌ `NO IMPLEMENTADO` (`v15`) | ✅ `VALIDADO` (`v16` → `v17`) | `archivo recibido`: `Align` (`bottomLeft`). `Ejecución`: `D PASS`. `Mejoras v16`, §2.1. |
| `Selector Foto` (`v16` — `Cámara`/`Galería`) | ❌ `NO IMPLEMENTADO` (`v15`) | ✅ `VALIDADO` (`v16` → `v17`) | `archivo recibido`: `_seleccionarOrigenFoto()`. `Ejecución`: `4` `pruebas` `PASS`. `Mejoras v16`, §2.2. |
| `Sistema Avisos` (`v16` — `Toast` `superior`) | ❌ `NO IMPLEMENTADO` (`v15`) | ✅ `VALIDADO` (`v16` → `v17`) | `archivo recibido`: `_AvisoUI`. `Ejecución`: `PASS`. `Mejoras v16`, §2.3. |
| `E6` (`Atribución` — `visibilidad` `mejorada`, `opcional`) | ❌ `NO APLICADO` (`opcional`) | ✅ `VALIDADO` (`opcional` `aplicado`) | `archivo recibido`: `fontSize` `13`, `fontWeight` `w600`, `padding` `8,4`, `fondo` `0xDDF5F5F5`. `No afecta` `política`. `Ejecución`: `D PASS`. |

### Confirmada pendiente (`v17` — `no modificada` `en esta actualización`)

- `Colores` (`Colors.deepPurple`): `PENDIENTE`.
- `DT8` (`Storage` — `uri.pathSegments.last`): `RIESGO`.
- `DT10` (`God-page`): `RIESGO`.
- `DT11`/`DT12` (`Repository`): `PENDIENTE`.
- `DT14` (`Tests`): `PENDIENTE`.
- `Colores` (`mapa_principal_page.dart` — `FAB`, `Avisos`, `pin` `deepPurple`): `No aumenta` (`M4` `URI` `independiente`; `E6` `black87`).
- `M6-06`: `NO VERIFICADO`.
- `M9`: `BLOQUEADO`.
- `Firma Release`: `PENDIENTE` (`bloqueante`).
- `SMTP` (`Resend`): `PENDIENTE`.
- `Data Safety`: `NO DOCUMENTADO`.
- `M17`: `PENDIENTE`.
- `A4`: `PENDIENTE`.
- `A1.4`: `PENDIENTE`.

---

## 4. RIESGOS (`v17` actualizado)

### `Supabase` (`PostgreSQL`, `Auth`, `Storage`, `RLS`)
- **Estado**: `NO MODIFICADO` (`archivo recibido` `intacto`: `supabase_client.dart`, `models/mural.dart`, `models/perfil.dart`, `public.murales`, `public.perfiles`). `DT4` (`auth`) `VALIDADO` (`#1`–`#13`); `M4` (`mapa`) `independiente`; `E6` (`UI`) `independiente`.
- **`RLS` (`public.murales` / `public.perfiles`)**: `VALIDADO` (`funcional`). ❓ `SQL` (`CREATE POLICY`, `trigger`) `NO VERIFICADO` (`archivo .sql` `no disponible`; `Handoff Técnico`, §0, §7). `No cambia` (`v17`).
- **`Storage` (`bucket murales`)**: `VALIDADO` (`funcional`). `Rollback` (`DT1`/`DT2`) `VALIDADO`. `Sanitización` (`nombreArchivoDesdeTitulo`) `VALIDADO`. `Políticas` (`B1`) `VALIDADO`. ❓ `SQL` (`políticas Storage`) `NO VERIFICADO`. `No cambia`.
- **`Auth` (`M1`/`M2` — `contraseña`/`OTP`)**: `VALIDADO`. `DT4` (`email` + `Timer`) `VALIDADO` (`#1`–`#13`). `DT4-02` (`anti-enumeración`) `VALIDADO`. `No cambia`.

### `Auth` (`email` — `DT4`)
- **Mitigado**: `addListener` (`_emailFocusNode`) + `Timer` (`3s`) + `dispose()` (`cancel`). `Regresión` (`password` `DT4-01`) `mitigada` (`#6`, `#12 PASS`).
- **Riesgo residual (`IME` — `TextInputAction` `Next`)**: `Mitigado` (`estándar` `PASS`; `otros` `IME` `no probados` `todos` — `conservador`).

### `Auth` (`password` — `DT4-01`)
- **Sin regresión**: `addListener` (`_passFocusNode`) `intacto`; `_requisitosContrasena` `operativo`.

### `Android` (`Identidad`, `Atribución`)
- **`namespace`/`applicationId` (`com.muralitoapp.app`)**: `VALIDADO`.
- **`Atribución` (`OSM`)**: `VALIDADO` (`funcional` + `visibilidad` `opcional` `mejorada`). `Política tiles` (`openstreetmap.org`) `cumplida` (`texto` `© Colaboradores` `intacto`; `enlace` `copyright` `intacto`).

### `Android` (`Release`)
- **`Keystore` (`.jks`)**: `PENDIENTE` (`bloqueante` `Play Store`). `build.gradle.kts`: `signingConfig` (`debug`). `No resuelto` (`v17`).

### `Rendimiento` (`mapa_principal_page.dart`)
- **`Clustering` (`O(n²)`)**: `RIESGO` (`NO RESUELTO`). `M4` (`URI`) `NO AFECTA`. `No cambia`.
- **`God-page` (`DT10`)**: `RIESGO`. `M4` (`cambio mínimo`) `NO AUMENTA`. `E6` (`UI` `Atribución`) `NO AUMENTA` (`solo` `estilo` `opcional`).

### `Escalabilidad` / `Arquitectura`
- **`Repository` (`DT11`/`DT12`)**: `PENDIENTE`. `No resuelto`.
- **`Storage` (`DT8`)**: `RIESGO` (`plano` `funciona`; `subcarpetas` `romperían`).

### `Publicación` (`Play Store`)
- **`Firma Release` (`Keystore`)**: `PENDIENTE` (`bloqueante`).
- **`SMTP` (`Resend`)**: `PENDIENTE` (`dominio` `propio`).
- **`Data Safety`**: `NO DOCUMENTADO` (`archivo recibido` `no menciona`; `Mejoras v16` `no menciona`).

---

## 5. DISCREPANCIAS (`v17` actualizado)

### Resueltas (`archivo recibido` + `evidencia física` `#1`–`#16 PASS`)

- **`Identidad Android` (`v15` → `v16`)**: `RESUELTA` (`Mejoras v16`, §2.1; `build.gradle.kts`).
- **`DT4` (`email` — `autovalidate` + `Timer`) (`v16` `§10` → `archivo recibido`)**: `RESUELTA` (`addListener` + `Timer` `3s` + `dispose` `validado` `#1`–`#5`, `#9`, `#10`).
- **`DT4` (`email` — `"Siguiente"`) (`archivo recibido`)**: `RESUELTA` (`#1 PASS`: `Siguiente` `visible`, `no blanco`).
- **`M4` (`Cómo llegar` — `v12` `OSM` → `v16` `Google Maps`)**: `RESUELTA` (`archivo recibido` `actualizado`: `_abrirComoLlegar` `URI` `google.com/maps`; `C PASS`: `Google Maps`; `D PASS`: `Atribución` `intacta`).
- **`E6` (`Atribución` — `visibilidad` `opcional`) (`archivo recibido`)**: `CONSISTENTE` (`archivo recibido` `v16` `§5.2`: `texto` `© Colaboradores` `intacto`; `enlace` `copyright` `intacto`; `sin prefijo` `intacto`). `Mejora opcional` (`fontSize` `13`, `padding` `8,4`, `fondo` `0xDDF5F5F5`) `no contradice` `política`.

### Persisten (`v17` — `no resueltas` `en esta actualización`)

- **`M6-06` (`GPS` — `NO VERIFICADO`)**: `NO RESUELTO` (`hardware` `físico` `no aislado`).
- **`Colores` (`Colors.deepPurple`)**: `NO RESUELTO` (`PENDIENTE`).
- **`DT10` (`God-page`)**: `NO RESUELTO` (`RIESGO`; `M4` `cambio mínimo` `NO AUMENTA`).
- **`DT8` (`Storage` — `uri.pathSegments.last`)**: `NO RESUELTO` (`RIESGO`; `funcional` `plano`).
- **`DT11`/`DT12` (`Repository`)**: `NO RESUELTO` (`PENDIENTE`).
- **`DT14` (`Tests`)**: `NO RESUELTO` (`PENDIENTE`).
- **`M9` (`Leaked Passwords`)**: `NO RESUELTO` (`BLOQUEADO`).
- **`Firma Release` (`Keystore`)**: `NO RESUELTO` (`PENDIENTE`; `bloqueante`).
- **`SMTP` (`Resend` — `dominio` `propio`)**: `NO RESUELTO` (`PENDIENTE`).
- **`Data Safety` (`Play Store`)**: `NO DOCUMENTADO` (`archivo recibido` `no menciona`; `Mejoras v16` `no menciona`).
- **`Supabase SQL` (`RLS`, `trigger`, `políticas Storage`)**: `NO VERIFICADO` (`archivo .sql` `no disponible`; `consola` `no accesible` `en esta sesión`).

---

## 6. SIGUIENTE OBJETIVO (`v17` actualizado)

Según `Documentación Técnica v16`, §16 (`"Objetivo de producto"`); `Mejoras v16`, §10 (`"Siguiente línea de trabajo"`); `Handoff Técnico`, §15 (`"Siguiente objetivo técnico"`):

**Estado (`DT4` + `M4` + `E6` `VALIDADO`)**:
- `DT4`: `CERRADO` (`email` `autovalidate` `reactivo` + `Timer 3s` `VALIDADO` `físico`).
- `M4`: `CERRADO` (`Cómo llegar` → `Google Maps` `VALIDADO` `físico` `A`–`E` `PASS`).
- `E6`: `ACTUALIZADO` (`visibilidad` `mejorada` `opcional` `VALIDADO` `funcional`).

**Candidatos vigentes (`Mejoras v16`, §7, §10)**:

> **`Firma Release` (`Keystore` `.jks` + `signingConfig` `release`)** (`Mejoras v16`, §7; `Documentación Técnica v16`, §5.3; `Handoff Técnico`, §16):
> - **Estado**: `PENDIENTE` (`bloqueante` `Google Play`).
> - **Archivo**: `android/app/build.gradle.kts` (`release`: `signingConfigs.getByName("debug")` → `signingConfigs.release`).
> - **Verificación previa**: `namespace` (`com.muralitoapp.app`) `intacto`; `.env` (`SUPABASE`) `excluido`; `.jks` (`nuevo`); `key.properties` (`nuevo`, `.gitignore`).
> - **No afecta** (`mapa_principal_page.dart`, `auth`, `Supabase`, `Storage`).

> **`Colores hardcodeados` (`~53` referencias, `8` archivos`)** (`Mejoras v16`, §6; `Documentación Técnica v16`, §Hallazgos):
> - **Estado**: `PENDIENTE` (`estilo`, `no bloqueante`).
> - **Archivos**: `mapa_principal_page.dart` (`FAB` `deepPurple`, `Aviso` `deepPurple[700]`, `pin` `deepPurple`), `auth_page.dart` (`Icon` `deepPurple`), otros (`widgets/`).
> - **Nota**: `M4` (`URI`) `no aumenta`; `E6` (`black87`) `no aumenta`. `Cambio` `gradual` (`Theme.of(context).colorScheme`).

**Recomendación (`Mejoras v16`, §10; `Handoff Técnico`, §16)**:
Priorizar `Firma Release` (`bloqueante`) antes que `Colores` (`estético`). `DT4` y `M4` (`VALIDADO`) permiten avanzar (`no bloquean` `funcionalidad`).

---

## 7. AUDITORÍA PREVIA (`v17` — `Firma Release` como `siguiente objetivo recomendado`)

Según `archivo recibido` (`mapa_principal_page.dart`, `pubspec.yaml`, `auth_page.dart`, `helpers.dart`, `models/`, `widgets/`) y `Documentación Técnica v16` (`§5.3`, `§16`):

### Si avanzas a `Firma Release` (`Keystore` `.jks`)

- [ ] Confirmar `android/app/build.gradle.kts` (`archivo recibido` `no pegado` `en esta sesión`; `referencia`: `Documentación Técnica v16`, §5.3).
- [ ] Confirmar `namespace` (`com.muralitoapp.app`) `intacto` (`archivo recibido`: `Mejoras v16`, §2.1).
- [ ] Confirmar `applicationId` (`com.muralitoapp.app`) `intacto`.
- [ ] Confirmar `.env` (`SUPABASE_URL`, `ANON_KEY`) `excluido` (`.gitignore`).
- [ ] Confirmar `.env.example` `existe` (`archivo recibido`: `pubspec.yaml`: `assets: - .env`).
- [ ] Generar `Keystore` (`.jks`) (`nuevo` — `no existe` `en archivo recibido`).
- [ ] Crear `key.properties` (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`) (`nuevo` — `excluir` `.gitignore`).
- [ ] Actualizar `build.gradle.kts` (`release`): `signingConfigs.release` (referenciar `key.properties`).
- [ ] Confirmar `flutter analyze`: `No issues found!` (`archivo recibido`: `#14 PASS`).
- [ ] Confirmar `flutter build apk` / `flutter build appbundle`: `release` `compila` (`no errores` `firma`).

### Si avanzas a `Colores hardcodeados` (`opcional`, `estético`)

- [ ] Confirmar `mapa_principal_page.dart` (`archivo recibido`): localizar `Colors.deepPurple` (`FAB`, `Aviso`, `pin`).
- [ ] Confirmar `auth_page.dart`: `Colors.deepPurple` (`Icon` `email`/`password`).
- [ ] Confirmar otros (`widgets/`, `pages/`, `utils/`).
- [ ] Confirmar `theme` (`ThemeData`) `existe` (`archivo recibido`: `Theme.of(context)` `usado` `AppBar`).
- [ ] Confirmar `ColorScheme` (`Theme.of(context).colorScheme`) `disponible`.

### General (`Proyecto` — `v17` actualizado)

- [ ] `DT4`: `VALIDADO` (`archivo recibido`: `auth` + `recuperación` `intactos`; `flutter run`: `#1`–`#13 PASS`).
- [ ] `M4`: `VALIDADO` (`archivo recibido`: `mapa_principal_page.dart` `intacto` `salvo` `_abrirComoLlegar`; `C PASS`; `E PASS`; `E6 PASS`).
- [ ] `E6`: `VALIDADO` (`archivo recibido`: `Atribución` `bottomLeft` `funcional`; `opcional` `aplicado`).
- [ ] `M6-06`: `NO VERIFICADO` (`no resuelto`).
- [ ] `Colores`: `PENDIENTE` (`no resuelto`).
- [ ] `DT10`: `RIESGO` (`no resuelto`).
- [ ] `Firma Release`: `PENDIENTE` (`recomendado` `siguiente`).
- [ ] `Documentación`: `v17` (`este bloque`) `actualizado` (`Estado`, `Funcionalidades`, `Deuda`, `Riesgos`, `Discrepancias`, `Siguiente`, `Auditoría`).

---

## CIERRE (`v17` — `Estado final` para `copiar` y `pegar`)

- **`DT4`**: `CERRADO` (`email` `autovalidate` `reactivo` + `Timer 3s` `VALIDADO` `físico`).
- **`M4`**: `CERRADO` (`Cómo llegar` → `Google Maps` `VALIDADO` `físico` `A`–`E`).
- **`E6`**: `ACTUALIZADO` (`Atribución` `funcional` + `visibilidad` `opcional`).
- **`Archivo recibido` (`mapa_principal_page.dart`)**: `Modificado` (`_abrirComoLlegar`: `Google Maps`; `E6`: `visibilidad` `opcional`); `resto` (`mapa`, `clustering`, `FAB`, `Avisos`, `Auth`) `intacto`.
- **`Archivo recibido` (`auth_page.dart`, `recuperar_password_page.dart`)**: `Modificado` (`DT4`: `addListener`, `Timer`, `dispose`); `resto` (`M1`, `M2`, `perfil`) `intacto`.
- **`Documentación` (`v17`)**: `Este bloque` (`completo`) `para` `copiar`/`pegar` (`Estado` + `Funcionalidades` + `Deuda` + `Riesgos` + `Discrepancias` + `Siguiente` + `Auditoría`).
- **`Siguiente` (`recomendado`)**: `Firma Release` (`Keystore` `.jks`).
- **`Siguiente` (`alternativo`)**: `Colores` (`estilo`).

¿Confirmas que pegas este bloque (`v17`) en tu archivo (`Documentacion_Tecnica_v17.md` o `v16.md` actualizado) y que `siguiente objetivo` es `Firma Release` (`Keystore`)? Una vez confirmes (`documento` `actualizado`), entrego el análisis final (`v17` `cerrado`) y paso al plan (`Keystore`).