`Estado`: `VALIDADO` (`C PASS`: `Google Maps`; `D PASS`: `Atribución` `intacta`).
`Restricción` (`v16`, §16): `OpenStreetMap` (`mapa` `interno`, `TileLayer`, `clustering`, `pin`, `Atribución`) `NO SE REEMPLAZA`.

## 13. Edición (`propio` `mural`) — `intacto` + `DT2` `VALIDADO`

`Acceso`: `Ficha` (`DraggableScrollableSheet`) → `Editar` (`esPropietario`: `usuarioActual.id == mural.userId`).
`Modal` (`EditarMuralModal`): `Título` (`TextFormField`), `Descripción` (`TextFormField`), `Foto` (`nuevo` `ImagePicker` — `cámara`/`galería`), `Rotación` (`slider` `0`/`90`/`180`/`270` — `preview`).
`Flujo` (`_editarMural` — `mapa_principal_page.dart`):
- `Sin foto` (`nuevaFotoPath` `null`): `UPDATE` (`título`, `descripción` — `null` `si` `vacío`) → `VALIDADO`.
- `Con foto` (`nuevaFotoPath` `!= null`):
  - `Compresión` (`FlutterImageCompress`: `minWidth`/`minHeight` `1200`, `quality` `80`, `rotate` `rotacion`, `autoCorrectionAngle` `true`) → `Uint8List`.
  - `Nombre`: `nombreArchivoDesdeTitulo` (`título` `limpio` + `timestamp` `.jpg`).
  - `Subida`: `uploadBinary` (`Storage`: `bucket` `murales`, `contentType` `image/jpeg`).
  - `URL`: `getPublicUrl` (`nuevaFotoUrl`).
  - `UPDATE`: `PostgreSQL` (`public.murales`: `.eq('id', id).eq('user_id', usuario.id)`) → `título`, `descripción`, `foto_url`.
  - `Rollback` (`DT2` — `archivo recibido` `mapa_principal_page.dart`):
    - `UPDATE` `falla`: `borrarFotoDeStorage` (`nuevaFotoUrl`) → `rethrow` (`excepción` `propagada`).
    - `UPDATE` `éxito`: `borrarFotoDeStorage` (`mural.fotoUrl` `anterior` — `best-effort`).
- `Inmutabilidad`: `Latitud`/`Longitud` (`payload` `omisión` `PostgreSQL` — `archivo recibido`: `update` `no` `incluye` `lat`/`lng`).
`Notificación`: `Toast` (`_mostrarAviso`: `exito` `verde` `3s`: `"Mural [título] actualizado correctamente."`) `o` `error` (`rojo`).

## 14. Eliminación (`propio` `mural`) — `intacto` + `VALIDADO`

`Acceso`: `Ficha` (`DraggableScrollableSheet`) → `Eliminar` (`esPropietario`: `usuarioActual.id == mural.userId`).
`Confirmación`: `AlertDialog` (`título`: `Eliminar mural`, `icono` `Icons.delete_outline` `rojo`, `contento`: `"¿Seguro...?"`, `acciones`: `Cancelar` / `Eliminar` — `FilledButton` `red`).
`Flujo` (`_eliminarMural`):
- `Confirmar` (`confirmar` `== true` `&&` `mounted`).
- `DELETE` (`supabase.from('murales').delete().eq('id', mural.id!).eq('user_id', usuario.id)`) — `RLS`.
- `Storage` (`best-effort`): `borrarFotoDeStorage` (`mural.fotoUrl`).
- `Recargar`: `_cargarMurales()`.
- `Notificación`: `Toast` (`exito` `verde` `3s`: `"Mural [título] eliminado correctamente."`).
- `Error`: `PostgrestException` (`mensajeErrorAmigable` — `DT4` `independiente`).

## 15. Gestión (`Perfil`) — `intacto` + `DT2` `VALIDADO`

`Acceso`: `AppBar` (`InkWell` — `avatar` `círculo` `radius` `16` + `apodo` `texto`).
`Modal` (`EditarPerfilModal` — `BottomSheet` `transparente`): `Apodo` (`TextFormField`), `Foto` (`avatar` — `ImagePicker`).
`Flujo` (`_guardarPerfil` — `archivo recibido`):
- `Sin cambio` (`nuevoAvatarPath` `null`): `UPDATE` (`apodo`) → `VALIDADO`.
- `Con cambio` (`nuevoAvatarPath` `!= null`):
  - `Compresión`: `FlutterImageCompress` (`minWidth`/`minHeight` `400`, `quality` `80`, `autoCorrectionAngle` `true`).
  - `Nombre`: `avatar_{perfilAnterior.id}_{timestamp}.jpg`.
  - `Subida`: `uploadBinary` (`Storage`).
  - `URL`: `getPublicUrl`.
  - `UPDATE`: `PostgreSQL` (`public.perfiles`: `.eq('id', perfilAnterior.id)`) → `apodo`, `avatar_url`.
  - `Rollback` (`DT2`): `UPDATE` `falla` → `borrarFotoDeStorage` (`nuevaUrl`); `Éxito` → `borrarFotoDeStorage` (`perfilAnterior.avatarUrl` — `best-effort`).
`Notificación`: `mostrarSnackBar` (`context`, `"✅ Perfil actualizado correctamente."`, `isError: false`) `o` `mensajeErrorAmigable` (`❌ ...`).

## 16. Notificaciones (`_AvisoUI`) — `v16` `VALIDADO`

`Modelo` (`mapa_principal_page.dart` — `archivo recibido`):
- `mensaje`: `String`
- `tipo`: `_TipoAviso` (`exito`, `error`, `info`)
- `accionLabel`: `String?` (`GPS`: `"Activar"` / `"Ajustes"`)
- `onAccion`: `VoidCallback?` (`Geolocator.openLocationSettings()` / `openAppSettings()`)

`Color` (`archivo recibido`):
- `exito`: `Colors.green[700]!`
- `error`: `Colors.red[700]!`
- `info`: `Colors.deepPurple[700]!`

`Icono`:
- `exito`: `Icons.check_circle`
- `error`: `Icons.error_outline`
- `info`: `Icons.info_outline`

`Comportamiento` (`archivo recibido`):
- `_mostrarAviso` (`mensaje`, `tipo`, `accionLabel`, `onAccion`, `duracion`: `3s` — `Default`).
- `_avisoTimer?.cancel()` (`previo`).
- `setState` (`_avisoActivo` `nuevo`).
- `_avisoTimer` (`Timer` `duracion`) → `mounted` → `setState` (`_avisoActivo` = `null`).
- `Botón` (`TextButton` — `foregroundColor`: `Colors.amberAccent`, `padding`: `horizontal 8`, `visualDensity`: `compact`) → `onPressed`: `setState` (`_avisoActivo` = `null`) + `onAccion?.call()`.

`Posición` (`Stack` — `archivo recibido`):
- `Positioned` (`top`: `12`, `left`: `16`, `right`: `16`).
- `Card` (`elevation`: `4`, `color`: `colorFondo`, `shape`: `RoundedRectangleBorder` `radius` `10`).

`No interferencia`:
- `FAB` (`Nuevo Mural` + `Mi ubicación` — `inferior` `derecho`) `independiente`.
- `Mapa` (`interactivo` `_mapaInteractivo` — `independiente`).

## 17. Regresiones (`v13` — `archivo recibido` + `evidencia física`)

- `Atribución` (`v16` + `E6` `opcional`) + `controles` (`FAB`, `clustering`): `PASS` (`mapa` `gestos` `intactos`; `Atribución` `bottomLeft` `visible`; `clustering` `30m` `funciona`).
- `Flujo` (`Cámara`/`Galería` — `v16`): `PASS` (`_seleccionarOrigenFoto` `funcional`; `cancelación` `limpia`; `galería` `completa`).
- `Avisos` (`v16` — `Toast` `superior`): `PASS` (`_mostrarAviso` `funciona`; `GPS` `interactivo`; `3s` `auto-cierre`).
- `Identidad` (`v16` — `namespace` `com.muralitoapp.app`): `PASS`.
- `DT4` (`v17` — `email` `autovalidate` `reactivo` + `Timer` `3s`): `PASS` (`#1`–`#7` `auth`; `#8`–`#13` `recuperación`; `Siguiente` `visible`; `Timer` `funciona`; `password` `DT4-01` `sin regresión` `#6`, `#12`).
- `M4` (`v17` — `Cómo llegar` → `Google Maps`): `PASS` (`A`: `botón` `existe`; `B`: `mapa` `OSM` `funciona`; `C`: `Google Maps` `abre`; `D`: `Atribución` `intacta`; `E`: `clustering`/`ficha`/`FAB`/`Avisos`/`Auth` `intacto`).
- `E6` (`v17` — `visibilidad` `mejorada` `opcional`): `PASS` (`funcional` `intacto`; `font` `13` `w600` `visible`; `fondo` `0xDDF5F5F5` `visible`; `click` `copyright` `funciona`).

## 18. Funcionalidades (`v13` — `archivo recibido` + `VALIDADO` `físico`)

- `Mapa` (`OSM` + `clustering` `30m` + `zoom` `6`–`18`) — `VALIDADO`.
- `Atribución` (`visible` + `clickable` + `opcional` `mejorado`) — `VALIDADO`.
- `Modo espectador` (`público`, `sin bloqueo`) — `VALIDADO`.
- `Avisos` (`unificado` `superior`, `exito`/`error`/`info` `+ GPS` `interactivo`, `3s`) — `VALIDADO`.
- `Registro` (`M1` `contraseña` `segura` + `checklist`; `confirmación` `correo`; `trigger` `perfil`) — `VALIDADO`.
- `Login`/`Logout` (`dinámico`, `AppBar`, `toast`) — `VALIDADO`.
- `Contraseña` (`segura` + `feedback` `reactivo` `DT4-01`) — `VALIDADO`.
- `Recuperación` (`OTP` `M2` + `email` `DT4` `reactivo` `Timer`) — `VALIDADO`.
- `Perfil` (`avatar` `DT2` + `trigger`) — `VALIDADO`.
- `Alta` (`selección` `foto` `Cámara`/`Galería` — `v16`; `independiente` `DT4`) — `VALIDADO`.
- `Compresión` + `rotación` `EXIF` — `VALIDADO`.
- `Onboarding` (`M3`) — `VALIDADO`.
- `Pin` (`GPS` `M5` — `no bloqueante` `10s`, `fijo`, `manual`) — `VALIDADO`.
- `Inmutabilidad` (`coordenadas`) — `VALIDADO`.
- `CRUD` (`edición` `rollback` `DT2`; `eliminación` `Storage`) — `VALIDADO`.
- `Sanitización` (`Storage`) — `VALIDADO`.
- `Clustering` (`30m` + `lista`) — `VALIDADO`.
- `A3` (`Subido por`) — `VALIDADO`.
- `Cómo llegar` (`M4` — `Google Maps` `nativo`) — `VALIDADO` (`C PASS`; `mapa` `OSM` `B PASS`; `Atribución` `D PASS`; `E PASS`).
- `Restricción` (`B1` — `Storage`) — `VALIDADO`.
- `RLS` (`murales`/`perfiles`) — `VALIDADO` (`funcional`; `SQL` `archivo` `.sql` `NO VERIFICADO`).
- `Identidad` (`namespace` `com.muralitoapp.app`) — `VALIDADO`.
- `Atribución` (`userAgentPackageName`) — `VALIDADO`.

## 19. No verificados / Pendientes (`v13` — `archivo recibido` `intacto` `salvo` `DT4`/`M4`/`E6`)

`M6-06` (`GPS` — `sin señal` `ni` `última` `ubicación` `conocida`): `❓ NO VERIFICADO` (`hardware` `no aislado`).
`Colores` (`hardcodeados` — `Colors.deepPurple` `~53` `referencias` `8` `archivos`): `⏳ PENDIENTE`.
`DT8` (`Storage` — `uri.pathSegments.last` `borrarFotoDeStorage`): `⚠️ RIESGO` (`plano` `funciona`; `subcarpetas` `romperían`).
`DT10` (`God-page` — `mapa_principal_page.dart` `acoplamiento`): `⚠️ RIESGO`.
`DT11`/`DT12` (`Repository` — `ausencia`): `⏳ PENDIENTE`.
`DT14` (`Tests` `automatizados` — `flutter test`): `⏳ PENDIENTE`.
`M9` (`Leaked Passwords` — `HIBP`): `⛔ BLOQUEADO` (`Supabase Pro`).
`M17` (`Borradores` `offline`): `⏳ PENDIENTE` (`post-v1`).
`A4` (`Uploader` `≠` `Artista`): `⏳ PENDIENTE` (`producto`).
`A1.4` (`Historial` `fotos` — `6` `días`): `⏳ PENDIENTE` (`producto`).
`Firma Release` (`Keystore` `.jks` — `release` `signingConfig`): `⏳ PENDIENTE` (`bloqueante` `Play Store` — `Mejoras v16`, §7; `Documentación Técnica v17`, §6).
`SMTP` (`Resend` — `dominio` `propio` — `SPF`/`DKIM`): `⏳ PENDIENTE` (`evaluadores`).
`Data Safety` (`Play Store` — `ficha` `seguridad` `datos`): `❓ NO DOCUMENTADO` (`archivo recibido` `no menciona`; `Mejoras v16` `no menciona`).
`Supabase SQL` (`RLS` `CREATE POLICY`, `trigger` `manejar_nuevo_usuario`, `políticas` `Storage`): `❓ NO VERIFICADO` (`archivo .sql` `no disponible`; `consola` `no accesible` `en esta sesión` — `Handoff Técnico`, §0, §7).

## 20. Backlog (`v13` — `Mejoras v16` `intacto`)

`Hecho` (`no reabrir` — `v16` `VALIDADO`): `Atribución OSM`, `Selector Foto`, `Avisos`, `Identidad Android`, `M3`, `M5`, `B1`, `M6` (`parcial`), `DT4-01`, `Sanitización`, `Identidad`, `A3`.
`Cerrado` (`v17` — `VALIDADO` `físico`): `DT4` (`email` `autovalidate` + `Timer`), `M4` (`Cómo llegar` `Google Maps`), `E6` (`Atribución` `opcional` `mejorado`).
`Pendiente` (`v1` — `próximo` `recomendado`): `Firma Release` (`Keystore`).
`Pendiente` (`v1` — `estilo`): `Colores` (`hardcodeados`).
`Pendiente` (`post-v1`): `M17`, `A4`, `A1.4`, `B2`–`B7`.
`Pendiente` (`no ahora`): `DT5`–`DT9` (`bajo nivel` — `pospuesto`), `DT10`–`DT12` (`desacoplamiento` — `no ahora`), `DT14`–`DT18` (`testing`/`escalabilidad`).

## 21. Control (`v13` — `archivo recibido` + `evidencia física`)

`Documento`: `Flujos Funcionales v13` (`fecha` `actual`) — `reemplaza` `v12` (`26/09/2026`).
`Archivo recibido` (`mapa_principal_page.dart` — `modificado` `v13`):
- `_abrirComoLlegar`: `URI` (`https://www.google.com/maps/dir/?api=1`) — `M4` `VALIDADO`.
- `Atribución`: `bottomLeft` (`opcional`: `fontSize` `13`, `w600`, `padding` `8,4`, `fondo` `0xDDF5F5F5`) — `E6` `VALIDADO` (`opcional`).
- `Restante`: `mapa` (`flutter_map` `OSM` `intacto`), `clustering` (`30m` `intacto`), `FAB` (`Nuevo Mural` + `Mi ubicación` `intacto`), `Ficha` (`DraggableScrollableSheet` `intacto`), `Avisos` (`_AvisoUI` `intacto`).
`Archivos recibidos` (`intactos` `v13` — `no modificados`):
- `auth_page.dart`: `DT4` (`email`: `addListener` `_emailFocusNode`, `Timer` `3s`, `dispose`) — `VALIDADO`.
- `recuperar_password_page.dart`: `DT4` (`email`: `addListener`, `Timer`, `dispose`) — `VALIDADO`.
- `helpers.dart`: `nombreArchivoDesdeTitulo`, `borrarFotoDeStorage`, `mensajeErrorAmigable`, `traducirErrorAuth`, `mostrarSnackBar`, `conDialogoCarga` — `intacto`.
- `models/`: `mural.dart`, `perfil.dart` — `intacto`.
- `widgets/`: `dialogo_carga.dart`, `formulario_mural_modal.dart`, `editar_mural_modal.dart`, `editar_perfil_modal.dart`, `ajustar_ubicacion_page.dart`, `onboarding_ubicacion_dialog.dart` — `intacto`.
- `pubspec.yaml`: `url_launcher` (`^6.3.1`), `flutter_map` (`^8.3.1`), `supabase_flutter` (`^2.17.2`), etc. — `intacto`.
`Estado`: `DT4` (`VALIDADO` `físico`), `M4` (`VALIDADO` `físico`), `E6` (`VALIDADO` `opcional`), `Flujos` (`archivo recibido` `mapa_principal_page.dart` `funcional` `PASS` `E`; `auth` `VALIDADO` `#1`–`#13`; `regresión` `PASS`).
`Siguiente objetivo` (`recomendado`): `Firma Release` (`Keystore` `.jks` — `Mejoras v16`, §7; `Documentación Técnica v17`, §6).
`Siguiente` (`alternativo` — `estilo`): `Colores` (`hardcodeados` — `Mejoras v16`, §6).

Nota final (`v13`): `Flujos_Funcionales_v12` (`26/09/2026`) → `Flujos_Funcionales_v13` (`fecha` `actual`). `DT4`: `CERRADO` (`VALIDADO` `físico`: `addListener` `_emailFocusNode`, `Timer` `3s`, `dispose`; `Siguiente` `visible`; `#1`–`#13 PASS`). `M4`: `CERRADO` (`VALIDADO` `físico`: `_abrirComoLlegar` `URI` `Google Maps`; `mapa` `OSM` `B PASS`; `Atribución` `D PASS`; `A`–`E PASS`). `E6`: `ACTUALIZADO` (`opcional` `aplicado`: `fontSize` `13`, `w600`, `padding` `8,4`, `fondo` `0xDDF5F5F5`; `funcional` `intacto`; `texto`/`click` `mantenido`). `Pendiente`: `M6-06` (`NO VERIFICADO`); `Colores`/`DT8`/`DT10`/`DT11`/`DT12`/`DT14` (`RIESGO`/`PENDIENTE`); `M9` (`BLOQUEADO`); `Firma` (`PENDIENTE` — `recomendado`); `SMTP` (`PENDIENTE`); `Data Safety` (`NO DOCUMENTADO`); `M17`/`A4`/`A1.4` (`PENDIENTE`). `Estado`: `MVP` `avanzado`; `próximo` (`recomendado`): `Firma Release`. `No inventado`: `todas` `afirmaciones` `se respaldan` `en los archivos recibidos` (`mapa_principal_page.dart`, `auth_page.dart`, `recuperar_password_page.dart`, `helpers.dart`, `pubspec.yaml`) `y en la evidencia física reportada` (`#1`–`#16 PASS`).