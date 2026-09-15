# 🎨 Muralito App

Aplicación móvil desarrollada con **Flutter para Android** orientada al mapeo colaborativo de arte urbano.

Muralito permite registrar murales mediante una fotografía, obtener su ubicación geográfica y almacenar la información en **Supabase**, para luego visualizarlos sobre un mapa **OpenStreetMap**.

El mapa es público mediante un **modo espectador**; la autenticación solo es necesaria para registrar, editar o eliminar murales propios.

---

## 📱 Características actuales

- 🗺️ Mapa interactivo con OpenStreetMap y **modo espectador** (explorar sin cuenta).

- 🔐 **Autenticación con correo y contraseña** mediante Supabase Auth, con confirmación de correo y login/logout sin abandonar el mapa.

- 🔑 **Contraseña segura durante el registro**:
  - Mínimo 8 caracteres.
  - Una letra mayúscula.
  - Una letra minúscula.
  - Un número.
  - Un carácter especial.
  - Validación visual de requisitos en tiempo real.
  - Indicador de **"✓ Contraseña segura"** cuando se cumplen todos los requisitos.
  - Confirmación de contraseña validada en tiempo real.

- 🔁 **Recuperación de contraseña mediante código OTP** (M2): se solicita por correo, se ingresa junto con la nueva contraseña (misma política de seguridad que en el registro), con reenvío controlado por un cooldown de 60 segundos.

- 👤 Perfil de usuario: apodo y avatar automáticos (perfiles + trigger). RLS auditada y validada (DT3): lectura pública para modo espectador y autoría, modificación restringida al dueño, eliminación bloqueada desde cliente e integridad referencial ON DELETE CASCADE vinculada a auth.users.

- 🧑‍🎨 **Subido por** (A3, Prueba 013): la ficha muestra el avatar y apodo de quien cargó el mural. También se muestra en modo espectador. Si el registro es antiguo y no tiene `user_id`, se etiqueta como **Muralista anónimo**.

- 📷 **Registro de murales:** cámara → GPS → formulario → compresión → Storage → PostgreSQL, utilizando el `user_id` del usuario autenticado.

- 🔄 **Corrección EXIF + rotación manual** antes de guardar la fotografía.

- ✏️ **Edición de murales propios** (título, descripción y foto), con la misma lógica segura: la foto anterior solo se elimina tras confirmar que el cambio se guardó correctamente.

- 🗑️ **Eliminación de murales propios** con limpieza de la fotografía en Storage, protegida mediante interfaz y RLS.

- 🧹 **Limpieza ante errores durante el registro:** si la fotografía se sube correctamente a Storage pero falla el INSERT del mural en PostgreSQL, la aplicación intenta eliminar el archivo recién subido para evitar archivos huérfanos.

- 🧩 **Clustering de murales a menos de 30 m**, con lista de selección y zoom de contexto.

- 🗺️ **Zoom del mapa limitado** (niveles 6–18) para reducir problemas de memoria al realizar zoom y desplazamiento.

- 💬 Mensajes de error breves y en español.

- 🧭 **"Cómo llegar"** desde la ficha utilizando OpenStreetMap.

- 📄 Licencia MIT.

> **A4 no está implementado.** "Subido por" representa la cuenta que cargó la fotografía, no necesariamente al autor de la pintura. Ver *Próximos pasos*.

---

## 🚧 Próximos pasos

El backlog técnico y funcional detallado se mantiene en el documento **Mejoras priorizadas**.

### 🔧 Siguiente trabajo técnico

- **DT3 — Auditoría RLS de la tabla `perfiles`**
  - Confirmar que las políticas `SELECT`/`INSERT`/`UPDATE` no permiten consultar ni modificar perfiles ajenos de forma indebida.
  - Definir si hace falta una política `DELETE` explícita.

### 📧 Pendiente antes de testers externos / Play Store

- **Verificar un dominio propio en Resend** (SMTP usado para los correos de Auth).
  - Mientras se use el dominio de pruebas (`onboarding@resend.dev`), solo se pueden enviar correos a la dirección con la que se creó la cuenta de Resend.
  - Requiere agregar registros DNS (SPF/DKIM) al dominio elegido.

### 🔴 Alta — producto

- **A4 — Autor del mural ≠ quien sube**
  - En la ficha deben verse **dos** cosas:
    - **Subido por:** cuenta que cargó la fotografía.
    - **Autor del mural:** persona que pintó la obra o firma del artista.
  - Al registrar o editar: campo opcional para el nombre o perfil del artista.
  - Para todo el mundo: **"¿Eres el autor? Reclámalo"** (requiere sesión).
  - El artista podrá atribuirse la obra aunque otra persona haya realizado la fotografía.
  - Es independiente de la idea de publicar ocultando el apodo.

### 🔐 Alta — cuentas

- **M9 — Protección frente a contraseñas filtradas** mediante HaveIBeenPwned / configuración correspondiente de Supabase.

### 🟡 Media

- **M4 — "Cómo llegar" a Google Maps.**
- **M5 — GPS robusto + posibilidad de ajustar manualmente la ubicación.**
- **M6 — Botón para centrar el mapa en mi ubicación.**
- **M7 — Visor de imagen con pinch-to-zoom.**
- **A1.4 — Historial de versiones si se repinta el muro.**

### 🚀 M16 — Sistema de actualización de versión

Sistema para detectar cuando existe una versión más reciente de Muralito y avisar al usuario.

Características previstas:

- Detectar la versión instalada.
- Consultar la versión más reciente disponible.
- Mostrar una notificación o diálogo cuando exista una actualización.
- Mostrar un resumen de novedades.
- Permitir acceder al proceso de actualización.
- Opción **"Ahora no"** para continuar utilizando la versión actual.
- Las actualizaciones serán inicialmente **opcionales y no bloqueantes**.

Ejemplo conceptual:

> 🎉 **¡Hay una nueva versión de Muralito!**
>
> Hemos agregado nuevas funciones y mejoras.
>
> **[Actualizar] [Ahora no]**

### 👁️ Mejoras futuras de autenticación

- **Visibilidad de contraseña**
  - Añadir un botón de ojo para mostrar/ocultar la contraseña.
  - Posible pequeña animación al cambiar entre visible y oculta.

- **Mejora del mensaje de confirmación de correo**
  - Mensaje más amigable después del registro.
  - Recordatorio para revisar **Spam / Correo no deseado**.

- **Reenviar correo de confirmación**
  - Permitir solicitar nuevamente el correo de confirmación (distinto del reenvío de código de M2).
  - Considerar posteriormente límites para evitar solicitudes excesivas.

### 🔵 Más adelante

- Publicar estando logueado pero ocultando el apodo ("como anónimo").
- B1 — Restringir el listado público del bucket de Storage.
- M8 — Perfil público desde "Subido por".
- B2 — Biografía y redes sociales.
- B3 — Inicio de sesión con Google.
- B4 — Direcciones dentro de la aplicación.
- B5 — Mejoras de logo y branding.
- B6 — Login mediante apodo o correo.
- B7 — Límites para cambios de apodo.
- Sistema comunitario de verificación, reportes y moderación.
- Optimización adicional del rendimiento del mapa.

---

## 🛠️ Stack tecnológico

| Capa | Tecnología | Versión |
| --- | --- | --- |
| Framework | Flutter | ^3.47.0 |
| Lenguaje | Dart | ^3.13.0 |
| Plataforma | Android | SDK Platform 36 |
| Mapa | `flutter_map` + OpenStreetMap | ^8.3.1 |
| Coordenadas | `latlong2` | ^0.10.1 |
| GPS | `geolocator` | ^14.0.3 |
| Cámara / galería | `image_picker` | ^1.2.3 |
| Compresión | `flutter_image_compress` | ^2.5.1 |
| Backend | Supabase (PostgreSQL + Auth + Storage) | `supabase_flutter` ^2.17.2 |
| Variables de entorno | `flutter_dotenv` | ^6.0.1 |
| Enlaces externos | `url_launcher` | ^6.3.1 |

No se agregó ninguna dependencia nueva para M2 (recuperación por OTP) ni para DT2 (avatar seguro): ambas reutilizan `supabase_flutter`, `image_picker` y `flutter_image_compress` ya existentes.

### Dependencias principales

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  supabase_flutter: ^2.17.2
  flutter_map: ^8.3.1
  latlong2: ^0.10.1
  geolocator: ^14.0.3
  image_picker: ^1.2.3
  flutter_image_compress: ^2.5.1
  flutter_dotenv: ^6.0.1
  url_launcher: ^6.3.1
```

---

## 📋 Requisitos

* Flutter 3.47.0 · Dart 3.13.0
* Android SDK Platform 36 + Command-line Tools
* Android Studio o VS Code
* Dispositivo Android físico o emulador
* Proyecto de Supabase configurado, **incluyendo SMTP propio** (ver sección siguiente)

---

## 📥 Instalación

```bash
git clone <URL_DEL_REPOSITORIO>
cd muralito_app
flutter pub get
```

Crear un archivo `.env` en la raíz del proyecto (usar `.env.example` como plantilla):

```env
SUPABASE_URL=TU_SUPABASE_URL
SUPABASE_ANON_KEY=TU_SUPABASE_ANON_KEY
```

```bash
flutter run
```

---

## 🔐 Configuración de Supabase

### Tabla `murales` (PostgreSQL)

| Campo | Tipo | Nullable |
| --- | --- | --- |
| id | bigint (PK, identity) | No |
| created_at | timestamptz | No |
| titulo | text | No |
| descripcion | text | Sí |
| foto_url | text | No |
| latitud | double precision | No |
| longitud | double precision | No |
| user_id | uuid (references auth.users) | Sí |

`user_id` representa a la cuenta que subió el mural, no necesariamente al artista. Esto se modificará cuando se implemente A4 — Autor del mural ≠ quien sube.

**Row Level Security:**
* `SELECT`: Público (`anon` y `authenticated`)
* `INSERT`: Solo `authenticated` con `auth.uid() = user_id`
* `UPDATE`: Solo propietario (`auth.uid() = user_id`)
* `DELETE`: Solo propietario (`auth.uid() = user_id`)

Los murales sin `user_id` (pruebas antiguas) no se pueden borrar desde la app. Eliminarlos en Table Editor.

### Tabla `perfiles` (PostgreSQL)

| Campo | Tipo | Nullable |
| --- | --- | --- |
| id | uuid (PK, references auth.users) | No |
| apodo | text | No |
| avatar_url | text | Sí |
| created_at | timestamptz | No |

**Row Level Security:**
* `SELECT`: Público (`anon` y `authenticated`)
* `INSERT`: Solo propio usuario (`auth.uid() = id`)
* `UPDATE`: Solo propio usuario (`auth.uid() = id`)

Auditoría completa de estas políticas: pendiente como **DT3**.

### Trigger automático

```sql
create or replace function public.manejar_nuevo_usuario()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.perfiles (id, apodo)
  values (new.id, coalesce(split_part(new.email, '@', 1), 'Muralista'));
  return new;
end;
$$;

create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.manejar_nuevo_usuario();
```

### Storage — bucket `murales` (público)

Compartido entre fotografías de murales y avatares de perfil.

* `SELECT`: Lectura pública de objetos (renderizado en mapa y AppBar)
* `INSERT`: Solo usuarios `authenticated`
* `DELETE`: Solo propietario del archivo (`bucket_id = 'murales' and owner = auth.uid()`)

⚠️ Nota de seguridad: el bucket actualmente permite listado público de archivos. Se recomienda restringir la política SELECT de `storage.objects` para evitar exponer el listado completo. Pendiente: **B1**.

### Envío de correos (Auth) — SMTP vía Resend

Los correos de confirmación de registro y de recuperación de contraseña requieren **SMTP propio** en Supabase (sin él, no se puede editar la plantilla para mostrar el código OTP, y el envío queda limitado a 2 correos/hora).

Se probó primero con Gmail personal, pero los reenvíos eran aceptados sin error visible y nunca llegaban al destinatario (filtro anti-abuso silencioso de Gmail ante envíos automatizados). Se migró a **Resend**:

```
Host: smtp.resend.com
Port: 465
Username: resend
Password: <API key de Resend, con permiso "Sending access">
```

⚠️ Mientras se use el dominio de pruebas de Resend (`onboarding@resend.dev`), solo se pueden enviar correos a la dirección con la que se creó la cuenta de Resend. Verificar un dominio propio es un paso pendiente antes de tener testers externos o publicar en Play Store.

La plantilla de correo "Reset Password" en Supabase debe incluir `{{ .Token }}` para que el correo muestre el código de recuperación, no solo el enlace.

---

## 📱 Permisos Android

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

La galería no requiere permiso adicional en el manifiesto; `image_picker` lo gestiona internamente.

---

## 📁 Estructura del proyecto

```text
muralito_app/
├── android/app/src/main/AndroidManifest.xml
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
│   │   └── supabase_client.dart
│   ├── utils/
│   │   └── helpers.dart
│   └── widgets/
│       ├── dialogo_carga.dart
│       ├── editar_mural_modal.dart
│       ├── editar_perfil_modal.dart
│       └── formulario_mural_modal.dart
├── .env
├── .env.example
├── .gitignore
├── LICENSE
├── pubspec.yaml
└── README.md
```

`recuperar_password_page.dart` se agregó junto con M2.

---

## 🧪 Estado de pruebas

El proyecto cuenta con pruebas funcionales y técnicas realizadas durante el desarrollo. El detalle caso por caso se mantiene en la **Documentación Técnica**; aquí un resumen.

**Pruebas principales**
- Prueba 001 — Registro completo de mural.
- Prueba 002 — Ficha de detalle y solapamiento de pines.
- Prueba 003 — Clustering de 30 m.
- Prueba 004 — EXIF + rotación manual.
- Prueba 005 — Autenticación, confirmación de correo, `user_id`, RLS y Storage.
- Prueba 006 — Modo espectador.
- Prueba 007 — Edición y eliminación de murales.
- Prueba 008/009 — Cambio de fotografía al editar y limpieza de Storage.
- Prueba 010 — Perfil de usuario.
- Prueba 011 — Refactor de estructura de `lib`.
- Prueba 012 — Eliminación de mural con limpieza de Storage.
- Prueba 013 — "Subido por" y casos con usuarios/murales antiguos.
- DT1-01 / DT1-02 — Registro normal y fallo controlado del INSERT con limpieza de Storage.
- DT2-01 a DT2-05 — Actualización segura del avatar (éxito, fallo de UPDATE, cancelar, error de subida, repetición sin huérfanos).
- M1-01 a M1-09, M1-UX-01 a M1-UX-04 — Validación de contraseña, confirmación, registro y login.
- M2-01 a M2-08 — Recuperación de contraseña por OTP, reenvío y cooldown.

**Estado actual**

| Elemento | Estado |
| --- | --- |
| M1 — Contraseña fuerte | ✅ DONE |
| DT1 — Limpieza de Storage ante fallo de INSERT | ✅ DONE |
| DT2 — Actualización segura del avatar | ✅ DONE |
| M2 — Recuperación de contraseña | ✅ DONE |
| DT3 — Auditoría RLS de perfiles | ✅ DONE |
| M9 — Protección de contraseñas filtradas | ⛔ Bloqueado (Requiere Plan Pro)
| DT4 — Unificación de errores y loading | 🔜 Siguiente 
| M16 — Actualización de versión | 📋 Backlog |

---

## 📜 Licencia

Distribuido bajo la licencia **MIT**. Ver [LICENSE](LICENSE).

## 👨‍💻 Autor

**Ariel Sebastian Cuenca Paillacho** — proyecto para el registro y visualización colaborativa de arte urbano.