# Muralito App — Flujos Funcionales Actuales

**Versión:** v14
**Fecha:** 2026-09-27
**Actualiza:** Flujos Funcionales v13 (26/09/2026).
**Estado:** MVP funcional avanzado — DT-Firma-Release y DT4, M4, E6 validados mediante ejecución física (`flutter run` + `flutter build apk --release` + `apksigner verify`). Hallazgo reportado con `ñ`/`Ñ` en títulos (no reproducido, pendiente auditoría).

## Resumen de cambios v13 → v14

Cerrados / validados (evidencia física):
- `DT-Firma-Release` (Keystore + signingConfigs.release + key.properties): Keystore generado, APK release compilado e instalado en Infinix X6886, firma V2/V3 verificada con `apksigner verify`.
- AGP ajustado a 8.13.0; JDK del proyecto: Temurin 17.0.20.1.

Pendientes (no modificados en v14):
- `M6-06` (`GPS` — `NO VERIFICADO`).
- `Colores`, `DT8`, `DT10`, `DT11`/`DT12`, `DT14`.
- `M9` (`Leaked` — `BLOQUEADO`), `SMTP` (dominio propio), `Data Safety` (NO DOCUMENTADO).
- `M17` (`Borradores` `offline`), `A4` (`Autor`), `A1.4` (`Historial`).
- Hallazgo a auditar: títulos con `ñ`/`Ñ` (reportado por el dev, no reproducido de forma controlada).

## 1. Tipos de usuario

### 1.1 Espectador
Visualiza mapa `OSM` (`clustering` `30m`, `zoom` `6`–`18`), `marcadores` (`_pinMural`, `_pinCluster`), `fichas` (`foto`, `título`, `descripción`, `coordenadas`, `A3` `Subido por`), `"Cómo llegar"` (`M4`: `Google Maps`), `Atribución` (`bottomLeft`: `© Colaboradores`, `clickable`, `copyright` — `E6` `opcional` `mejorado`). Usa `Mi ubicación` (`FAB`: `GPS` `no bloqueante` `10s`, `onboarding` `M3` `primera vez`, `toast` `interactivo`). No requiere `autenticación` (`AuthGate`: `passthrough`). No puede `registrar`, `editar`, `eliminar`, `gestionar` `perfil`.

### 1.2 Usuario autenticado
Todas capacidades `espectador`. Registro (`M1`: `contraseña` `segura` + `checklist` `reactivo`; `confirmación` `correo`; `trigger` `perfil`). Login/Logout (`dinámico`: `avatar` `apodo` → `espectador`; `toast` `morado`: `"Sesión cerrada"`). Recuperación (`M2`: `OTP` `6` `dígitos`, `Resend`, `cooldown` `60s`, `nueva` `contraseña` `DT4-01`). Alta (`selección` `foto` — `Cámara` (`ImageSource.camera`) / `Galería` (`ImageSource.gallery`) — `modal` `_seleccionarOrigenFoto`; `onboarding` `M3`; `pin` `fijo` `AjustarUbicacionPage`; `GPS` `timeout` `10s`; `manual`; `formulario`; `subida` `Storage` + `PostgreSQL` + `rollback` `DT1`). Edición (`título`/`descripción`/`rotación`/`foto` `nueva` + `rollback` `DT2`; `coordenadas` `inmutables`). Eliminación (`confirmación` `diálogo`; `DELETE` `PostgreSQL` `RLS`; `borrado` `Storage` `best-effort`). Perfil (`apodo`, `avatar` `DT2`). Atribución `A3` (`avatar` `perfil` + `apodo`; `fallback`: `Muralista anónimo`).

## 2. Inicio de la aplicación

```
Abrir aplicación
  ↓
Cargar `.env` (`flutter_dotenv` `^6.0.1`)
  ↓
Inicializar `Supabase` (`supabase_flutter` `^2.17.2`)
  ↓
`MapaPrincipalPage`
  ↓
Comprobar `Auth` (`AuthGate`: `passthrough`)
  ↓
Sesión `activa` / `Sin sesión`
  ↓
Cargar `murales` + `perfiles` (`public.murales` `SELECT` + `public.perfiles` `SELECT` — `RLS`)
  ↓
Renderizar `mapa` (`flutter_map` `^8.3.1`, `TileLayer` `openstreetmap.org`, `userAgentPackageName` `com.muralitoapp.app`, `clustering` `30m`, `zoom` `6`–`18`, `Atribución` `bottomLeft` — `E6` `opcional` `mejorado`)
```

## 2.5 Despliegue (`v14` — `nuevo`)

### 2.5.1 Desarrollo local (`flutter run`)
```
flutter run
  ↓
Detecta dispositivo/emulador conectado
  ↓
Compila en modo `debug`
  ↓
Instala APK debug (sin firma de release; firma automática de debug keystore)
  ↓
App abre con hot reload habilitado
```

### 2.5.2 Build local APK release (testing físico) — `DT-Firma-Release` `VALIDADO`
```
flutter build apk --release
  ↓
Gradle lee `android/key.properties` (UTF-8 sin BOM, ruta relativa)
  ↓
Carga credenciales del keystore
  ↓
Firma APK con `signingConfigs.release`
  ↓
`√ Built build\app\outputs\flutter-apk\app-release.apk`
  ↓
Instalación en dispositivo:
  - `flutter install --release` (recomendado; usa `adb` automáticamente)
  - o `adb install -r build\app\outputs\flutter-apk\app-release.apk`
  ↓
App abre con firma de release válida (verificable con `apksigner verify --print-certs`)
```

### 2.5.3 Build local AAB release (subir a Play Store) — `DT-Firma-Release` `VALIDADO`
```
flutter build appbundle --release
  ↓
Gradle aplica misma lógica que APK release
  ↓
`bundletool` empaqueta AAB
  ↓
`√ Built build\app\outputs\bundle\release\app-release.aab`
  ↓
Listo para subir a Google Play Console
```

### 2.5.4 Verificación de firma (`apksigner`)
```
apksigner verify --print-certs <archivo>.apk
  ↓
Salida esperada:
  - `Verified using v2 scheme (APK Signature Scheme v2): true`
  - `Verified using v3 scheme (APK Signature Scheme v3): true`
  - `Signer #1 certificate DN: CN=Muralito, OU=Muralito, O=Muralito, L=Quito, ST=Pichincha, C=EC`
```

## 3. Registro e inicio de sesión

### 3.1 Intentar registrar sin sesión
`Nuevo Muralista` (`FAB`) → `¿Sesión?` (`_haySesion`)
  ├─ Sí → `Flujo` `selección` `foto` (`§6`)
  └─ No → `Diálogo` `autenticación`
              ├─ `Seguir explorando` → `Mapa`
              ├─ `Iniciar sesión` → `AuthPage` (`login`)
              └─ `Registrarse` → `AuthPage` (`_esRegistro` = `true`)
`Reanudación`: `autenticación` `completa` (`success`) → `mapa` `reintenta` `flujo`.

### 3.2 Registro (`auth_page.dart` — `DT4` `validado`)
`Form` (`_formKey`) → `Email` (`_emailController`, `_emailFocusNode`: `addListener` `_alCambiarFocoEmail`; `onChanged`: `limpia`; `onTapOutside`: `muestra` `error`; `Timer`: `_mostrarErrorEmail` + `_iniciarTimerErrorEmail` `3s`) → `Contraseña` (`_passController`, `_passFocusNode`: `DT4-01` — `addListener` `_alCambiarFocoPassword`/`_ocultarErrorPasswordAlEscribir`; `checklist` `_requisitosContrasena`) → `Confirmación` (`_confirmPassController`: `rojo` `si` `no coincide`) → `Botón` `Crear cuenta` (`_enviar`) → `Validación` (`email` `vacío`/`sin @` → `bloqueo`; `form` `validate`; `registro`: `contraseña` `segura`; `confirmación` `coincide`) → `Carga` (`_cargando`) → `signUp` (`Supabase`) → `Éxito`: `SnackBar` (`📧 Revisa correo...`) + `_esRegistro` = `false` → `Error`: `mensajeErrorAmigable` (`DT4-02`: `respuesta` `genérica`) → `Timer` (`3s`) `limpieza` (`_mostrarErrorEmail`).

### 3.3 Inicio de sesión (`auth_page.dart`)
`Email` (`_emailFocusNode`: `DT4` `Timer` `3s`) → `Contraseña` (`_passFocusNode`: `DT4-01` — `no` `checklist` `en login`) → `Botón` `Iniciar sesión` (`_enviar` — `signInWithPassword`) → `Éxito`: `Navigator.pop(true)` (`mapa` `reintenta`) → `Logout`: `AppBar` `icon` `logout` → `signOut` → `AppBar` (`_haySesion` `false`) + `toast` (`_mostrarAviso`: `"Sesión cerrada..."`).

### 3.4 Recuperación (`M2` — `recuperar_password_page.dart` — `DT4` `validado`)
`Paso 1` (`_pasoCorreo` — `Form` `_formKeyCorreo`): `Email` (`_emailController`, `_emailFocusNode`: `DT4` — `addListener`, `onChanged`, `onTapOutside`, `_mostrarErrorEmail`, `_iniciarTimerErrorEmail` `3s`) → `Botón` `Enviar código` (`_enviarCodigo`) → `Validación` (`email` `vacío`/`sin @` → `bloqueo` + `Timer`) → `resetPasswordForEmail` → `Éxito`: `_codigoEnviado` = `true` + `_iniciarCooldownReenvio()` (`60s`) → `Error`: `traducirErrorAuth` (`mensaje` `español` + `segundosDeEspera` `si aplica`).
`Paso 2` (`_pasoCodigoYContrasena` — `Form` `_formKeyCodigo`): `Código` (`_codigoController`: `validator`: `no vacío`) → `Nueva contraseña` (`_passController`, `_passFocusNode`: `DT4-01` — `checklist` `_requisitosContrasena`) → `Confirmar` (`_confirmPassController`: `rojo` `si` `no coincide`) → `Botón` `Restablecer` (`_confirmarRecuperacion`) → `verifyOTP` (`recovery`) + `updateUser` (`password`) → `Éxito`: `SnackBar` (`✅ Contraseña actualizada`) + `Navigator.popUntil(route.isFirst)` → `Error`: `traducirErrorAuth`.

## 4. Recuperación (`M2`) — `v14`

Ver `§3.4`. `DT4` (`email`) aplicado (`addListener` `_emailFocusNode`, `Timer` `3s`, `dispose`). `DT4-01` (`password` `nueva`) aplicado (`_passFocusNode`, `_requisitosContrasena`).

## 5. Onboarding (`M3`) — `intacto`

`Primera` `acción` `GPS` (`Nuevo Mural` `o` `Mi ubicación`) → `mostrarOnboardingUbicacionSiCorresponde()` (`shared_preferences` `clave`: `onboarding_ubicacion_visto`) → `¿Ya visto?` (`Sí` → `saltar`; `No` → `mostrar` `dialogo` → `Entendido` → `persistir` → `continuar` `flujo`).

## 6. Alta (`M5` / `DT1` / `DT13` / `Selección`) — `intacto` + `v16` `actualizado`

`Nuevo Mural` (`FAB`) → `Sesión` (`Sí` `→` `flujo`; `No` `→` `_pedirSesionParaNuevoMural` `reanudación`) → `_seleccionarOrigenFoto()` (`modal`: `Tomar fotografía` / `Elegir de galería`) → `XFile` (`cámara` `o` `galería`) → `Cancelación` `limpia` (`return`) → `Onboarding` (`M3`) → `AjustarUbicacionPage` (`pin` `fijo` `centro`, `GPS` `10s` `timeout`, `manual` `mapa`) → `Confirmar` `LatLng` (`inmutable`) → `FormularioMuralModal` (`título`, `descripción`, `previsualización`) → `Guardar` → `_subirMural()` (`_enviar`):
- `Compresión` (`FlutterImageCompress`: `max` `1200x1200`, `q` `80`, `rotate`, `autoCorrectionAngle`)
- `Sanitización` de título: `nombreArchivoDesdeTitulo()` (RegExp `[^a-zA-Z0-9áéíóúÁÉÍÓÚñÑ_-]` → `_`, `timestamp`, `.jpg`)
- `Subida` (`Storage`: `uploadBinary`, `nombre` `sanitizado`)
- `INSERT` (`PostgreSQL`: `public.murales` — `user_id` = `auth.uid`)
- `Rollback` (`DT1`): `INSERT` `falla` → `borrarFotoDeStorage` (`archivo` `nuevo`)
- `Éxito`: `Toast` (`_mostrarAviso`: `"Mural guardado..."`, `exito`, `verde`, `3s`) + `_cargarMurales()` + `_mapController.move` (`zoom` `16`)
- `Error`: `Toast` (`_mostrarAviso`: mensaje amigable, `error`, `rojo`, `3s`)

> ❓ **Hallazgo a auditar (`v14`)**: durante validación física del APK release, el dev reportó que un título con `ñ`/`Ñ` ("pruebiññaañaña") no se pudo guardar, mientras que sin `ñ` no falló. **No fue reproducido de forma controlada**. Posibles causas (no asumir): `nombreArchivoDesdeTitulo()` real podría no coincidir con la documentación; validación del formulario; codificación en Storage/Supabase; coincidencia con error de red/foto. Requiere reproducción controlada antes de afirmar bug.

## 7. Control (`M6`) — `intacto` + `DT4` `independiente`

`FAB` (`Mi ubicación`) → `Spinner` (`_buscandoUbicacion`) → `Onboarding` (`M3`, `primera` `vez`) → `_ubicacionService.obtenerUbicacion()` (`GPS`, `timeout` `10s`):
- `M6-01` (`GPS` `activo`): `Centra` (`zoom` `17`) → `PASS`.
- `M6-02` (`GPS` `apagado`): `Toast` `morado` (`"El GPS está apagado..."`) + `botón` `Activar` (`openLocationSettings`) → `PASS`.
- `M6-03` (`Permiso` `denegado`): `Toast` `morado` (`"Necesitamos permiso..."`) → `PASS`.
- `M6-04` (`Permiso` `bloqueado` `permanente`): `Toast` `morado` (`"El permiso está bloqueado..."`) + `botón` `Ajustes` (`openAppSettings`) → `PASS`.
- `M6-05` (`Última` `ubicación` `conocida`): `Centra` `fallback` + `Toast` `morado` → `PASS`.
- `M6-06` (`Sin` `GPS` `ni` `última` `conocida`): `❓` `NO VERIFICADO` (`no aislado` `hardware`).
- `M6-07` (`Regresión`): `PASS`.
`Spinner` (`_buscandoUbicacion` = `false`).

## 8. Confirmación (`coordenadas` `inmutables`)

`AjustarUbicacionPage`: `Pin` `centro` (`fijo`) = `LatLng` (`lat`, `lng`) `confirmado` (`_abrirComoLlegar` `usa` `mismo` `lat`/`lng` `para` `Google Maps` — `M4` `VALIDADO`). `Inmutabilidad` (`_editarMural`: `payload` `omisión` `lat`/`lng` `PostgreSQL` `UPDATE`).

## 9. Subida (`Storage` / `Persistencia` / `Políticas`) — `intacto` + `DT4` `independiente`

`Bucket`: `murales` (`plano`).
`Sanitización`: `nombreArchivoDesdeTitulo()` (`RegExp` `[^a-zA-Z0-9áéíóúÁÉÍÓÚñÑ_-]` → `_`, `timestamp`).
`Políticas`: `Listing` (`restringido` `autenticados` — `B1`); `SELECT` (`URLs` `públicas`); `INSERT` (`autenticado`); `DELETE` (`owner` = `auth.uid()`).
`Rollback` (`DT1`): `Alta` (`INSERT` `falla` → `borrar` `archivo` `nuevo`); `Edición` (`UPDATE` `falla` → `borrar` `archivo` `nuevo`; `Éxito` → `borrar` `archivo` `anterior` `best-effort`).
`Compresión`: `flutter_image_compress` (`max` `1200x1200`, `q` `80`, `rotate`, `autoCorrectionAngle`).

## 10. Mapa (`clustering` / `Atribución` / `Controles`) — `intacto` + `v16` + `M4` + `E6` `opcional`

`flutter_map` `^8.3.1` + `TileLayer` (`openstreetmap.org`, `userAgentPackageName` `com.muralitoapp.app`, `maxNativeZoom` `19`).
`Zoom`: `6.0` – `18.0` (`clamp`).
`Clustering`: `_radioClusterMetros` (`30` `m`) — `_agruparMuralesCercanos()` (`Distance` `latlong2`).
`Pin`: `_pinMural()` (`morada`, `pincel` `blanco`); `_pinCluster()` (`morada` `oscurecida` `según` `cantidad`).
`Interacción`: `Clustering` (`tap` → `_zoomHaciaGrupo` + `_mostrarGrupoMurales` — `lista` `DraggableScrollableSheet`).
`Atribución` (`E6` — `opcional` `mejorado`): `bottomLeft` (`Align`); `fondo` (`0xDDF5F5F5`); `texto` (`© Colaboradores de OpenStreetMap`, `fontSize` `13`, `w600`, `black87`); `click` (`LaunchMode.externalApplication` → `copyright`); `sin prefijo` (`flutter_map` `descartado`).
`Controles` (`FAB` — `inferior` `derecho`, `estándar` `Material`):
  - `Nuevo Mural` (`FloatingActionButton.extended`: `heroTag` `nuevo-mural`, `icon` `add_a_photo`, `label` `Nuevo Mural`, `onPressed` `_iniciarFlujoNuevoMural`).
  - `Mi ubicación` (`FloatingActionButton`: `heroTag` `mi-ubicacion`, `icon` `my_location`, `onPressed` `_centrarEnMiUbicacion`, `spinner` `_buscandoUbicacion`).
`Notificaciones` (`_AvisoUI` — `v16`): `exito` (`verde` `700`), `error` (`rojo` `700`), `info` (`morado` `700`); `Timer` (`3s`); `acción` `interactiva` (`GPS` — `amberAccent`).

## 11. Ficha (`A3`) — `intacto` + `M4` `actualizado`

`DraggableScrollableSheet` (`bottom` `sheet` `deslizable`):
`Contenido`: `Foto` (`Image.network` `adaptable`, `maxHeight` `280`, `loading` `spinner`, `error` `icon` `gris`); `Título`; `_filaAutor()` (`A3`: `avatar` `perfil` + `apodo`; `fallback` `Muralista anónimo`); `Descripción`; `Coordenadas` (`Lat`/`Lng`, `formato` `5` `decimales`); `Cómo llegar` (`M4`: `FilledButton.icon` `purple` → `_abrirComoLlegar` `Google Maps`).
`Controles` (`esPropietario` `= usuario.id == mural.userId`):
  - `Editar` (`OutlinedButton.icon` `edit` → `_editarMural` — `formulario` `título`/`descripción`/`foto` `nueva` + `rollback` `DT2`).
  - `Eliminar` (`FilledButton.icon` `red` `delete` → `_eliminarMural` — `diálogo` `confirmación`; `DELETE` `RLS`; `Storage` `borrado` `best-effort`).
  - `Cerrar` (`OutlinedButton`).

## 12. Navegación (`Cómo llegar`) — `M4` (`v14` `actualizado`)

`Ficha` (`DraggableScrollableSheet`) → `Botón` `"Cómo llegar"` (`FilledButton.icon`).
`_abrirComoLlegar` (`mapa_principal_page.dart` — `v14`):
```dart
final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
if (!mounted) return;
if (!ok) { _mostrarAviso('No se pudo abrir Google Maps. Coordenadas: ...', error); }
```
`Estado`: `VALIDADO` (`C PASS`: `Google Maps`; `D PASS`: `Atribución` `intacta`; probado físicamente en Infinix X6886).
`Restricción`: `OpenStreetMap` (`mapa` `interno`, `TileLayer`, `clustering`, `pin`, `Atribución`) `NO SE REEMPLAZA`.

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
  - `Rollback` (`DT2`):
    - `UPDATE` `falla`: `borrarFotoDeStorage` (`nuevaFotoUrl`) → `rethrow`.
    - `UPDATE` `éxito`: `borrarFotoDeStorage` (`mural.fotoUrl` `anterior` — `best-effort`).
- `Inmutabilidad`: `Latitud`/`Longitud` (`payload` `omisión` `PostgreSQL`).
`Notificación`: `Toast` (`_mostrarAviso`: `exito` `verde` `3s` o `error` `rojo`).

## 14. Eliminación (`propio` `mural`) — `intacto` + `VALIDADO`

`Acceso`: `Ficha` (`DraggableScrollableSheet`) → `Eliminar` (`esPropietario`: `usuarioActual.id == mural.userId`).
`Confirmación`: `AlertDialog` (`título`: `Eliminar mural`, `icono` `Icons.delete_outline` `rojo`, `contento`: `"¿Seguro...?"`, `acciones`: `Cancelar` / `Eliminar` — `FilledButton` `red`).
`Flujo` (`_eliminarMural`):
- `Confirmar` (`confirmar` `== true` `&&` `mounted`).
- `DELETE` (`supabase.from('murales').delete().eq('id', mural.id!).eq('user_id', usuario.id)`) — `RLS`.
- `Storage` (`best-effort`): `borrarFotoDeStorage` (`mural.fotoUrl`).
- `Recargar`: `_cargarMurales()`.
- `Notificación`: `Toast` (`exito` `verde` `3s`).
- `Error`: `PostgrestException` (`mensajeErrorAmigable`).

## 15. Gestión (`Perfil`) — `intacto` + `DT2` `VALIDADO`

`Acceso`: `AppBar` (`InkWell` — `avatar` `círculo` `radius` `16` + `apodo` `texto`).
`Modal` (`EditarPerfilModal` — `BottomSheet` `transparente`): `Apodo` (`TextFormField`), `Foto` (`avatar` — `ImagePicker`).
`Flujo` (`_guardarPerfil`):
- `Sin cambio` (`nuevoAvatarPath` `null`): `UPDATE` (`apodo`) → `VALIDADO`.
- `Con cambio` (`nuevoAvatarPath` `!= null`):
  - `Compresión`: `FlutterImageCompress` (`minWidth`/`minHeight` `400`, `quality` `80`, `autoCorrectionAngle` `true`).
  - `Nombre`: `avatar_{perfilAnterior.id}_{timestamp}.jpg`.
  - `Subida`: `uploadBinary` (`Storage`).
  - `URL`: `getPublicUrl`.
  - `UPDATE`: `PostgreSQL` (`public.perfiles`: `.eq('id', perfilAnterior.id)`) → `apodo`, `avatar_url`.
  - `Rollback` (`DT2`): `UPDATE` `falla` → `borrarFotoDeStorage` (`nuevaUrl`); `Éxito` → `borrarFotoDeStorage` (`perfilAnterior.avatarUrl` — `best-effort`).
`Notificación`: `mostrarSnackBar` (`context`, `"✅ Perfil actualizado correctamente."`, `isError: false`) o `mensajeErrorAmigable` (`❌ ...`).

## 16. Notificaciones (`_AvisoUI`) — `v16` `VALIDADO`

`Modelo` (`mapa_principal_page.dart`):
- `mensaje`: `String`
- `tipo`: `_TipoAviso` (`exito`, `error`, `info`)
- `accionLabel`: `String?`
- `onAccion`: `VoidCallback?`

`Color`:
- `exito`: `Colors.green[700]!`
- `error`: `Colors.red[700]!`
- `info`: `Colors.deepPurple[700]!`

`Icono`:
- `exito`: `Icons.check_circle`
- `error`: `Icons.error_outline`
- `info`: `Icons.info_outline`

`Comportamiento`:
- `_mostrarAviso` (`mensaje`, `tipo`, `accionLabel`, `onAccion`, `duracion`: `3s`).
- `_avisoTimer?.cancel()` (`previo`).
- `setState` (`_avisoActivo` `nuevo`).
- `_avisoTimer` (`Timer` `duracion`) → `mounted` → `setState` (`_avisoActivo` = `null`).
- `Botón` (`TextButton` — `foregroundColor`: `Colors.amberAccent`) → `onPressed`: `setState` + `onAccion?.call()`.

`Posición`:
- `Positioned` (`top`: `12`, `left`: `16`, `right`: `16`).
- `Card` (`elevation`: `4`, `color`: `colorFondo`, `shape`: `RoundedRectangleBorder` `radius` `10`).

`No interferencia`:
- `FAB` (`Nuevo Mural` + `Mi ubicación`) `independiente`.
- `Mapa` (`interactivo`) `independiente`.

## 17. Regresiones (`v14` — `archivo recibido` + `evidencia física`)

- `Atribución` (`v16` + `E6` `opcional`) + `controles` (`FAB`, `clustering`): `PASS`.
- `Flujo` (`Cámara`/`Galería`): `PASS`.
- `Avisos`: `PASS`.
- `Identidad`: `PASS`.
- `DT4`: `PASS` (`#1`–`#13`; probado físicamente).
- `M4`: `PASS` (`A`–`E`; probado físicamente).
- `E6`: `PASS`.
- `DT-Firma-Release`: `PASS` (APK release compilado, instalado en Infinix X6886, firma V2/V3 verificada con `apksigner`).

## 18. Funcionalidades (`v14` — `archivo recibido` + `VALIDADO` `físico`)

- `Mapa` (`OSM` + `clustering` `30m` + `zoom` `6`–`18`) — `VALIDADO`.
- `Atribución` (`visible` + `clickable` + `opcional` `mejorado`) — `VALIDADO`.
- `Modo espectador` — `VALIDADO`.
- `Avisos` — `VALIDADO`.
- `Registro` (`M1`) — `VALIDADO`.
- `Login`/`Logout` — `VALIDADO`.
- `Contraseña` (`M1` + `DT4-01`) — `VALIDADO`.
- `Recuperación` (`M2` + `DT4`) — `VALIDADO`.
- `Perfil` (`avatar` `DT2` + `trigger`) — `VALIDADO`.
- `Alta` (`selección` `foto` + `rollback` `DT1`) — `VALIDADO` (con hallazgo pendiente sobre `ñ`/`Ñ`).
- `Compresión` + `rotación` `EXIF` — `VALIDADO`.
- `Onboarding` (`M3`) — `VALIDADO`.
- `Pin` (`GPS` `M5`) — `VALIDADO`.
- `Inmutabilidad` (`coordenadas`) — `VALIDADO`.
- `CRUD` (`edición` `rollback` `DT2`; `eliminación` `Storage`) — `VALIDADO`.
- `Sanitización` (`Storage`) — `VALIDADO` (con hallazgo pendiente sobre `ñ`/`Ñ`).
- `Clustering` (`30m` + `lista`) — `VALIDADO`.
- `A3` (`Subido por`) — `VALIDADO`.
- `Cómo llegar` (`M4` — `Google Maps`) — `VALIDADO`.
- `Restricción` (`B1` — `Storage`) — `VALIDADO`.
- `RLS` (`murales`/`perfiles`) — `VALIDADO` (funcional; SQL NO VERIFICADO).
- `Identidad` (`namespace` `com.muralitoapp.app`) — `VALIDADO`.
- `Atribución` (`userAgentPackageName`) — `VALIDADO`.
- **`Firma Release` (`DT-Firma-Release` — Keystore + signingConfig + APK/AAB release)** — `VALIDADO` (`v14`, nuevo).

## 19. No verificados / Pendientes (`v14` — `archivo recibido` `intacto` `salvo` Firma Release)

`M6-06` (`GPS` — `sin señal` `ni` `última` `ubicación` `conocida`): `❓ NO VERIFICADO`.
`Colores` (`hardcodeados` — `Colors.deepPurple` `~53` `referencias` `8` `archivos`): `⏳ PENDIENTE`.
`DT8` (`Storage` — `uri.pathSegments.last` `borrarFotoDeStorage`): `⚠️ RIESGO`.
`DT10` (`God-page` — `mapa_principal_page.dart` `acoplamiento`): `⚠️ RIESGO`.
`DT11`/`DT12` (`Repository` — `ausencia`): `⏳ PENDIENTE`.
`DT14` (`Tests` `automatizados` — `flutter test`): `⏳ PENDIENTE`.
`M9` (`Leaked Passwords` — `HIBP`): `⛔ BLOQUEADO`.
`M17` (`Borradores` `offline`): `⏳ PENDIENTE`.
`A4` (`Uploader` `≠` `Artista`): `⏳ PENDIENTE`.
`A1.4` (`Historial` `fotos` — `6` `días`): `⏳ PENDIENTE`.
`SMTP` (`Resend` — `dominio` `propio` — `SPF`/`DKIM`): `⏳ PENDIENTE`.
`Data Safety` (`Play Store` — `ficha` `seguridad` `datos`): `❓ NO DOCUMENTADO`.
`Supabase SQL` (`RLS` `CREATE POLICY`, `trigger` `manejar_nuevo_usuario`, `políticas` `Storage`): `❓ NO VERIFICADO`.
`Hallazgo a auditar`: títulos con `ñ`/`Ñ` (reportado por el dev, no reproducido de forma controlada). `❓ PENDIENTE`.

## 20. Backlog (`v14`)

`Hecho` (`no reabrir`):
- `Atribución OSM`, `Selector Foto`, `Avisos`, `Identidad Android`, `M3`, `M5`, `B1`, `M6` (`parcial`), `DT4-01`, `Sanitización` (con hallazgo pendiente), `Identidad`, `A3`.
- `DT4` (`email` `autovalidate` + `Timer`).
- `M4` (`Cómo llegar` `Google Maps`).
- `E6` (`Atribución` `opcional` `mejorado`).
- **`DT-Firma-Release` (`Firma Release` — `v14`)**: Keystore + signingConfig + APK/AAB release + verificado físicamente.

`Pendiente` (`v1` — `próximo` `recomendado`):
- **`Data Safety` (`Play Store`)** — Requisito previo a publicación. No documentado.

`Pendiente` (`v1` — `producto`):
- **`M17` (`Borradores` `offline`)** — Detectado durante validación física: si falla la subida, recuperar el borrador (título/descripción/foto/ubicación/rotación) para no repetir trabajo.

`Pendiente` (`v1` — `estilo`):
- `Colores` (`hardcodeados`).

`Pendiente` (`post-v1`):
- `A4`, `A1.4`, `B2`–`B7`.

`Pendiente` (`auditoría`):
- **Hallazgo**: títulos con `ñ`/`Ñ` — reproducción controlada antes de afirmar bug.

`Pendiente` (`no ahora`):
- `DT5`–`DT9`, `DT10`–`DT12`, `DT14`–`DT18`.

`Pendiente` (`publicación`):
- `SMTP` (`Resend` — `dominio` `propio`).

## 21. Control (`v14`)

`Documento`: `Flujos Funcionales v14` (`fecha` `actual`) — `reemplaza` `v13` (26/09/2026).
`Archivo recibido` (`mapa_principal_page.dart` — `intacto` en `v14` salvo `M4`/`E6` ya documentados en `v13`):
- `resto` (`mapa`, `clustering`, `FAB`, `Ficha`, `Avisos`) `intacto`.

`Archivos recibidos` (`intactos` `v14` — `no modificados`):
- `auth_page.dart`: `DT4` `VALIDADO`.
- `recuperar_password_page.dart`: `DT4` `VALIDADO`.
- `helpers.dart`: `nombreArchivoDesdeTitulo`, `borrarFotoDeStorage`, `mensajeErrorAmigable`, `traducirErrorAuth`, `mostrarSnackBar`, `conDialogoCarga` — `intacto` (con hallazgo pendiente).
- `models/`: `mural.dart`, `perfil.dart` — `intacto`.
- `widgets/`: `dialogo_carga.dart`, `formulario_mural_modal.dart`, `editar_mural_modal.dart`, `editar_perfil_modal.dart`, `ajustar_ubicacion_page.dart`, `onboarding_ubicacion_dialog.dart` — `intacto`.
- `pubspec.yaml`: `url_launcher` (`^6.3.1`), `flutter_map` (`^8.3.1`), `supabase_flutter` (`^2.17.2`), etc. — `intacto`.

`Archivos recibidos` (`modificados` en sesión Firma Release — `v14`):
- `android/app/build.gradle.kts`: `signingConfigs.release` con credenciales de `key.properties`.
- `android/key.properties`: `nuevo` (UTF-8 sin BOM, ruta relativa del keystore).
- `android/app/muralito-release-key.jks`: `nuevo` (Keystore RSA 2048, validez 10000 días, alias `muralito`).
- `android/settings.gradle.kts`: AGP ajustado a 8.13.0.
- `android/gradle.properties`: `org.gradle.java.home` apuntando a Temurin 17.0.20.1; `android.newDsl=true`.
- `.gitignore`: `android/key.properties`, `*.jks` (protegidos).

`Estado`:
- `DT-Firma-Release` (`VALIDADO` físico).
- `DT4` (`VALIDADO` físico).
- `M4` (`VALIDADO` físico).
- `E6` (`VALIDADO`).
- `Flujos` (archivo recibido funcional; hallazgo pendiente).
- `Siguiente objetivo` (`recomendado`): `Data Safety` (`Play Store`).
- `Siguiente` (`alternativo` — producto): `M17` (`Borradores` `offline`).
- `Auditoría` (`pendiente`): títulos con `ñ`/`Ñ`.

Nota final (`v14`): `Flujos_Funcionales_v13` (26/09/2026) → `Flujos_Funcionales_v14` (fecha actual). `DT-Firma-Release`: CERRADO (Keystore generado, signingConfig.release configurado, APK/AAB release compilados, firma V2/V3 verificada con `apksigner`, probado en Infinix X6886). `DT4`: CERRADO. `M4`: CERRADO. `E6`: ACTUALIZADO. `Pendiente`: `M6-06` (NO VERIFICADO); `Colores`/`DT8`/`DT10`/`DT11`/`DT12`/`DT14` (RIESGO/PENDIENTE); `M9` (BLOQUEADO); `SMTP` (PENDIENTE); `Data Safety` (NO DOCUMENTADO); `M17`/`A4`/`A1.4` (PENDIENTE); hallazgo `ñ`/`Ñ` (auditoría pendiente). `Estado`: MVP avanzado; próximo (recomendado): Data Safety. `No inventado`: todas las afirmaciones se respaldan en los archivos recibidos y en la evidencia física reportada (`#1`–`#16 PASS`; `flutter build apk --release`: √ Built; `apksigner verify`: Verified v2/v3).