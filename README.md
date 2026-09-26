# 🎨 Muralito App

Aplicación móvil desarrollada con **Flutter para Android** orientada al mapeo colaborativo de arte urbano. Muralito permite registrar murales mediante una fotografía, obtener y ajustar su ubicación geográfica y almacenar la información en **Supabase**, para luego visualizarlos sobre un mapa **OpenStreetMap**.

El mapa es público mediante un **modo espectador**; la autenticación solo es necesaria para registrar, editar o eliminar murales propios.

**Documentación de referencia vigente (21/09/2026):**

* **Documentación Técnica v15**
* **Mejoras v15**
* **Flujos Funcionales v11**
* **Handoff técnico #006** *(sin actualizar en esta sesión)*

---

## 🆕 Novedades de esta versión

Resumen de lo que cambió desde el README anterior (alineado con Documentación Técnica v14 / Flujos v10 / Mejoras v14):

**Cerrado y validado:**

* **DT4-01 corregido** — el borde rojo del campo de contraseña ahora se comporta igual en **registro y recuperación**: se limpia apenas se escribe, y solo aparece al perder el foco o al intentar enviar con una contraseña inválida. Antes, recuperación no tenía este comportamiento bien implementado.
* **Corrección de Storage** — el nombre de archivo generado al cambiar la foto de un mural (edición) ahora usa la misma sanitización estricta que el alta, evitando que un título con `/` cree una subcarpeta accidental.
* **Identidad de la app para publicación** — `applicationId` real (`com.muralitoapp.app`) configurado en Android, reemplazando el placeholder de Flutter.
* **📍 M3 — Onboarding de ubicación** (nuevo, ver detalle más abajo).

**Detectado, todavía sin resolver** (para no perderlo de vista):

* Falta el widget de atribución "© OpenStreetMap contributors" en el mapa — lo exige la política de uso de tiles de OSM.
* El build de release sigue firmado con la clave de debug — bloqueante para Google Play.
* El campo "Correo electrónico" tiene el mismo tipo de problema de validación visual que tenía antes la contraseña (DT4-01), pospuesto a pedido.
* Colores hardcodeados en 8 archivos (~53 referencias a `Colors.deepPurple`) — cambiar la paleta a futuro va a requerir más trabajo del ideal.

**Redefinido:**

* **M4** ya no significa reemplazar el mapa por Google Maps. Ahora es: el botón "Cómo llegar" abre la app de Google Maps en vez de OpenStreetMap. El mapa en sí se mantiene sobre OpenStreetMap.

---

## 📱 Características actuales

* 🗺️ **Mapa interactivo con OpenStreetMap y modo espectador**, permitiendo explorar murales sin cuenta.

* 🔐 **Autenticación con correo y contraseña** mediante Supabase Auth, con confirmación de correo y login/logout sin abandonar el mapa.

* 🔑 **Contraseña segura durante el registro (M1)**:

  * Mínimo 8 caracteres.
  * Una letra mayúscula.
  * Una letra minúscula.
  * Un número.
  * Un carácter especial.
  * Validación visual de requisitos en tiempo real (checklist).
  * Indicador de **"✓ Contraseña segura"** cuando se cumplen todos los requisitos.
  * Confirmación de contraseña validada en tiempo real.
  * El borde rojo del campo Contraseña se limpia apenas el usuario escribe, y solo aparece al perder el foco o al intentar enviar con una contraseña inválida (DT4-01) — implementado igual en **registro** y en **recuperación**.

* 🔁 **Recuperación de contraseña mediante código OTP (M2)**:

  * Solicitud mediante correo.
  * Verificación del código OTP.
  * Nueva contraseña con la misma política de seguridad del registro, y el mismo comportamiento de borde rojo descrito arriba (DT4-01).
  * Reenvío controlado mediante cooldown de 60 segundos.
  * Resincronización si el servidor exige una espera superior.

* 👤 **Perfil de usuario**:

  * Apodo automático.
  * Avatar.
  * Creación automática mediante trigger.
  * RLS auditada y validada (DT3, Prueba #015).
  * Lectura pública necesaria para modo espectador y "Subido por".
  * Modificación restringida al propietario.
  * Eliminación bloqueada desde el cliente.
  * Integridad referencial `ON DELETE CASCADE` hacia `auth.users`.

* 🧑‍🎨 **Subido por (A3, Prueba 013)**:

  * La ficha muestra el avatar y apodo de la cuenta que cargó el mural.
  * También funciona en modo espectador.
  * Los registros antiguos sin `user_id` se muestran como **"Muralista anónimo"**.

* 📷 **Registro de murales**:

  * Cámara o galería.
  * Ajuste de ubicación.
  * Formulario.
  * Corrección de orientación.
  * Compresión.
  * Storage.
  * PostgreSQL.
  * Uso del `user_id` del usuario autenticado.

* 📍 **GPS robusto + pin manual (M5, cubre M10)**:

  * Si el GPS está apagado, no hay permiso o se produce un timeout, el alta no se aborta.
  * El pin permanece fijo en el centro de la pantalla mientras se desplaza el mapa.
  * Las coordenadas pueden reajustarse antes de publicar.
  * Una vez publicado, la ubicación no se edita.
  * Acciones disponibles según el estado: **Activar GPS** · **Permitir ubicación** · **Abrir ajustes** · **Reintentar GPS** · **Usar GPS**.

* 📍 **Centrar mi ubicación (M6)**:

  * Control para centrar el mapa en la ubicación actual.
  * Reutiliza la lógica de ubicación del alta.
  * Maneja GPS apagado, permisos denegados y `deniedForever` (con acción para abrir ajustes).
  * Utiliza la última ubicación conocida cuando corresponde.
  * Los avisos de ubicación tienen un ciclo de vida controlado para evitar acumulación de SnackBars.

* 📍 **Onboarding de ubicación (M3)** — *nuevo*:

  * Diálogo explicativo mostrado **una única vez en la vida de la instalación** (persistido con `shared_preferences`, no solo por sesión).
  * Se dispara antes de la primera de estas dos acciones que el usuario toque: "Nuevo Mural" o "Mi ubicación" — lo que ocurra primero.
  * Al tocar "Entendido", el flujo original continúa automáticamente, sin un segundo toque.
  * Explica que el permiso de ubicación es opcional (se puede seguir usando la app ajustando el pin a mano).
  * Disponible también para el espectador, ya que "Mi ubicación" no requiere sesión.

* 🔄 **Corrección EXIF + rotación manual** antes de guardar fotografías.

* ✏️ **Edición de murales propios**:

  * Título.
  * Descripción.
  * Fotografía.
  * La fotografía anterior solo se elimina después de confirmar que el cambio se guardó correctamente.
  * Las coordenadas no se modifican durante la edición.

* 🗑️ **Eliminación de murales propios** con limpieza de la fotografía en Storage, protegida mediante interfaz y RLS.

* 🧹 **Limpieza ante errores durante el registro (DT1)**:

  * Si la fotografía se sube correctamente a Storage pero falla el INSERT del mural en PostgreSQL, la aplicación intenta eliminar el archivo recién subido para evitar archivos huérfanos.

* 🧩 **Clustering de murales a menos de 30 m**, con lista de selección y zoom de contexto.

* 🗺️ **Zoom del mapa limitado** entre niveles 6–18.

* 💬 **Mensajes de error breves y en español** (DT4).

* ⏳ **Diálogos de carga controlados** para evitar cierres múltiples (DT13).

* 🧭 **"Cómo llegar"** desde la ficha, actualmente abre OpenStreetMap externo. *(Hay una redefinición de M4 acordada — que en su lugar abra Google Maps — todavía sin implementar.)*

* 📜 **Licencia MIT**.

> **A4 no está implementado.** "Subido por" representa la cuenta que cargó la fotografía, no necesariamente al autor de la pintura.

> **A1.4 (historial de fotos) no está implementado**, pero ya tiene criterio de producto definido: la foto anterior debería quedar disponible para "deshacer" hasta 6 días después del cambio, o hasta que el usuario confirme explícitamente que no hará más cambios; el historial debería verse en la app como una galería de versiones.

> **DT4-02 (seguridad):** si alguien intenta registrarse con un correo que ya existe, Supabase no revela esa información. La aplicación muestra un mensaje genérico de confirmación.

---

# 🚧 Próximos pasos

El backlog técnico y funcional detallado se mantiene en **Mejoras v15**.

La estrategia actual es:

**1. Deuda técnica → 2. Mejoras de producto → 3. Rendimiento y escalabilidad → 4. Release Candidate / Google Play**

No se busca convertir el proyecto en un backlog indefinido. Cada tarea debe justificarse por su impacto real sobre la primera versión.

Candidatos abiertos para el siguiente trabajo (sin decidir todavía cuál sigue): resolver los hallazgos de esta versión (atribución OSM, firma de release, correo, colores), M4 redefinido, o retomar deuda técnica DT5–DT9.

---

## 🔧 Estado técnico actual

### ✅ B1 — Restricción del listing de Storage

B1 está **implementado y validado**.

La política de lectura del bucket `murales` fue restringida para impedir el listing anónimo de objetos.

El acceso mediante una URL pública conocida continúa funcionando.

La prueba de listing anónimo realizada devolvió:

```text
data: []
error: null
```

INSERT continúa restringido a usuarios autenticados y DELETE al propietario correspondiente.

---

### 📍 M6 — Centrar mi ubicación

M6 está implementado.

Se añadió el servicio:

```text
lib/services/ubicacion_service.dart
```

La funcionalidad permite centrar el mapa utilizando la ubicación disponible y reutiliza la lógica empleada durante M5.

Estado de pruebas:

| Prueba                            | Estado          |
| --------------------------------- | ---------------- |
| M6-01 — GPS activo + permiso      | 🧪 Validado     |
| M6-02 — GPS apagado               | 🧪 Validado     |
| M6-03 — Permiso denegado          | 🧪 Validado     |
| M6-04 — `deniedForever` / ajustes | 🧪 Validado     |
| M6-05 — Última ubicación conocida | 🧪 Validado     |
| M6-06 — Escenario pendiente       | ❓ No verificado |
| M6-07 — Regresión general         | 🧪 Validado     |

M6-06 permanece sin verificar y no se considera una prueba aprobada.

---

### 📍 M3 — Onboarding de ubicación *(nuevo)*

M3 está **implementado y validado**.

Se añadió el widget:

```text
lib/widgets/onboarding_ubicacion_dialog.dart
```

y la dependencia `shared_preferences`, usada para persistir que el diálogo ya se mostró — no es un flag de sesión, sobrevive a cerrar y reabrir la app.

Se engancha en dos puntos de `mapa_principal_page.dart`: al inicio del flujo de "Nuevo Mural" (antes de que se intente el GPS) y al inicio de "Mi ubicación" — lo que el usuario toque primero.

Estado de pruebas:

| Prueba                                                    | Estado      |
| ---------------------------------------------------------- | ----------- |
| Aparece antes de la primera acción de ubicación            | 🧪 Validado |
| "Entendido" continúa automáticamente con la acción original | 🧪 Validado |
| No se repite al tocar la segunda acción de ubicación       | 🧪 Validado |
| Persiste tras cerrar y reabrir la app                      | 🧪 Validado |

---

### 🤖 Identidad de la app y preparación para Android *(nuevo)*

* **`applicationId`**: `com.muralitoapp.app` — configurado en `android/app/build.gradle.kts`, reemplazando el placeholder `com.example.muralito_app` que generaba Flutter por defecto. No puede cambiarse después de la primera publicación en Google Play sin perder historial, por eso se definió ahora.
* **`namespace` y `MainActivity.kt`** permanecen deliberadamente en `com.example.muralito_app` — es una decisión consciente, no un descuido: `namespace` no necesita coincidir con `applicationId`, y el manifest referencia la actividad de forma relativa (`.MainActivity`), así que no hace falta ningún otro cambio. Alinearlos por prolijidad implicaría mover físicamente `MainActivity.kt`, algo que no se hizo todavía.
* **`userAgentPackageName`** de los dos `TileLayer` (mapa principal y ajuste de ubicación) actualizado a `com.muralitoapp.app`.
* ⏳ **Pendiente — atribución de OpenStreetMap**: la política de uso de tiles exige mostrar "© OpenStreetMap contributors" visible en el mapa. Hoy no existe ese widget en la app.
* ⏳ **Pendiente — firma de release**: el build de tipo `release` todavía firma con la clave de debug (`signingConfigs.getByName("debug")`), lo cual Google Play no acepta. No es urgente hasta preparar un build de release real.

---

## 📧 Antes de testers externos

### Resend — dominio propio

El envío de correos de Auth funciona mediante SMTP de Resend.

Antes de entregar la aplicación a testers externos debe verificarse un dominio propio y configurar el remitente correspondiente.

Con el dominio de pruebas `onboarding@resend.dev` existen limitaciones para el envío a destinatarios distintos de la cuenta propietaria de Resend.

La configuración del dominio requiere los registros DNS correspondientes, incluyendo SPF/DKIM según la configuración de Resend.

---

# 🔴 Alta — producto

## A4 — Autor del mural ≠ quien sube

Pendiente.

La intención es diferenciar:

* **Subido por:** cuenta que cargó la fotografía.
* **Autor del mural:** persona que pintó la obra o firma del artista.

La funcionalidad podrá contemplar: campo opcional durante el registro; edición posterior; reclamación de autoría; atribución independiente de la cuenta que realizó la fotografía.

Las reglas de propiedad y reclamación deben definirse antes de implementar A4.

## A1.4 — Historial de fotos *(nuevo)*

Pendiente de implementar. Criterio de producto ya definido:

* La foto anterior de un mural no se borraría de inmediato al editar — quedaría disponible para "deshacer" hasta **6 días** después del cambio, o hasta que el usuario confirme explícitamente que no hará más cambios.
* El historial debería verse en la app como una **galería de versiones**, no solo como un respaldo interno.

Implementarlo requeriría: dejar de borrar la foto anterior al editar, una tabla nueva en Postgres con su propia RLS, una política de retención en Storage, y probablemente una estructura de carpetas por mural (lo que reabriría la deuda técnica de rutas de Storage, hoy sin aplicar porque el bucket es plano).

---

# 🔐 Cuentas / Auth

## M9 — Protección frente a contraseñas filtradas

Pendiente.

La funcionalidad relacionada con HaveIBeenPwned / Leaked Password Protection se encuentra:

**⛔ BLOQUEADA — requiere Supabase Pro**

Mientras tanto, M1 continúa aplicando las reglas de contraseña segura durante el registro.

---

## 👁️ Mejoras futuras de autenticación

Pendientes:

* Botón de mostrar/ocultar contraseña.
* Pequeña animación al cambiar visibilidad.
* Mensaje de confirmación de correo más amigable.
* Recordatorio de revisar Spam / Correo no deseado.
* Reenvío del correo de confirmación.
* Límites para evitar solicitudes excesivas de reenvío.
* ⏳ *(nuevo)* Corregir en el campo "Correo electrónico" el mismo problema de validación visual que tenía la contraseña antes de DT4-01 — el error queda pegado en pantalla mientras el usuario escribe una corrección, hasta el próximo intento de envío.

El reenvío de confirmación es independiente del reenvío del código OTP de M2.

---

# 🟡 Mejoras de producto

| ID      | Mejora                                                                  | Estado                                |
| ------- | ------------------------------------------------------------------------ | -------------------------------------- |
| M3      | Onboarding de ubicación                                                  | 🧪 Validado                            |
| M4      | "Cómo llegar" abre Google Maps *(redefinido — ya no reemplaza el mapa)* | ⏳ Pendiente                            |
| M6      | Centrar mi ubicación                                                     | 🧪 Validado en escenarios principales  |
| M7      | Visor de imagen con pinch-to-zoom                                        | ⏳ Pendiente                            |
| M8      | Perfil público                                                           | ⏳ Pendiente                            |
| M10     | Ajustar pin durante el alta                                              | 🧪 Cubierto por M5                     |
| M11–M16 | Mejoras UX, zoom, spiderfy, recorte, landing y actualización de versión | ⏳ Pendiente                            |

---

# 🚀 M16 — Sistema de actualización de versión

Mejora aprobada como sistema opcional y no bloqueante.

Características previstas:

* Detectar la versión instalada.
* Consultar la versión más reciente.
* Mostrar aviso cuando exista una actualización.
* Mostrar resumen de novedades.
* Permitir acceder al proceso de actualización.
* Opción **"Ahora no"** para continuar utilizando la versión actual.

Ejemplo conceptual:

> 🎉 **¡Hay una nueva versión de Muralito!**
>
> Hemos agregado nuevas funciones y mejoras.
>
> **[Actualizar] [Ahora no]**

---

# 🔵 Más adelante

* Publicar estando logueado pero ocultando el apodo.
* M8 — Perfil público desde "Subido por".
* B2 — Biografía y redes sociales.
* B3 — Inicio de sesión con Google.
* B4 — Direcciones dentro de la aplicación.
* B5 — Mejoras de logo y branding.
* B6 — Login mediante apodo o correo.
* B7 — Límites para cambios de apodo.
* Sistema comunitario de verificación, reportes y moderación.
* Optimización adicional del rendimiento del mapa.
* DT10 — Separar `MapaPrincipalPage`.
* Revisión de la paleta de colores — hoy hardcodeada (`Colors.deepPurple`) en ~8 archivos; centralizar en el `ColorScheme` del tema si se busca variarla más adelante.
* Otras mejoras arquitectónicas DT10–DT12 cuando exista evidencia de necesidad.

---

# 🛠️ Stack tecnológico

| Capa                 | Tecnología                             | Versión                    |
| -------------------- | --------------------------------------- | --------------------------- |
| Framework            | Flutter                                 | 3.47.0                      |
| Lenguaje             | Dart                                    | 3.13.0                      |
| Plataforma           | Android                                 | SDK Platform 36             |
| Mapa                 | `flutter_map` + OpenStreetMap           | ^8.3.1                      |
| Coordenadas          | `latlong2`                              | ^0.10.1                     |
| GPS                  | `geolocator`                            | ^14.0.3                     |
| Cámara / galería     | `image_picker`                          | ^1.2.3                      |
| Compresión           | `flutter_image_compress`                | ^2.5.1                      |
| Backend              | Supabase (PostgreSQL + Auth + Storage)  | `supabase_flutter` ^2.17.2  |
| Variables de entorno | `flutter_dotenv`                        | ^6.0.1                      |
| Enlaces externos     | `url_launcher`                          | ^6.3.1                      |
| Persistencia local   | `shared_preferences` *(nuevo, para M3)* | ^2.5.4                      |

No se agregó ninguna dependencia nueva para M2, DT2, DT3, DT4, DT13, M5 ni M6. La única dependencia nueva desde la versión anterior de este README es `shared_preferences`, agregada específicamente para M3.

---

## Dependencias principales

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
  shared_preferences: ^2.5.4
```

---

# 📋 Requisitos

* Flutter 3.47.0
* Dart 3.13.0
* Android SDK Platform 36 + Command-line Tools
* Android Studio o VS Code
* Dispositivo Android físico o emulador
* Proyecto de Supabase configurado
* SMTP de Resend configurado para los correos de Auth

---

# 📥 Instalación

```bash
git clone <URL_DEL_REPOSITORIO>

cd muralito_app

flutter pub get
```

Crear un archivo `.env` en la raíz del proyecto utilizando `.env.example` como plantilla:

```env
SUPABASE_URL=TU_SUPABASE_URL
SUPABASE_ANON_KEY=TU_SUPABASE_ANON_KEY
```

Ejecutar:

```bash
flutter run
```

**No incluir el archivo `.env` real en commits ni documentación pública.**

---

# 🔐 Configuración de Supabase

## Tabla `murales`

| Campo       | Tipo                   | Nullable |
| ----------- | ----------------------- | -------- |
| id          | bigint (PK, identity)   | No       |
| created_at  | timestamptz             | No       |
| titulo      | text                    | No       |
| descripcion | text                    | Sí       |
| foto_url    | text                    | No       |
| latitud     | double precision        | No       |
| longitud    | double precision        | No       |
| user_id     | uuid                    | Sí       |

`user_id` representa la cuenta que subió el mural, no necesariamente al artista.

### Row Level Security

* **SELECT:** público (`anon` y `authenticated`).
* **INSERT:** solo `authenticated` con `auth.uid() = user_id`.
* **UPDATE:** solo propietario.
* **DELETE:** solo propietario.

Los murales antiguos sin `user_id` no se pueden administrar como propietario desde la aplicación.

Al editar desde la aplicación no se modifican `latitud` ni `longitud`.

---

## Tabla `perfiles`

| Campo      | Tipo                                                  | Nullable |
| ---------- | ------------------------------------------------------ | -------- |
| id         | uuid (PK, references `auth.users` ON DELETE CASCADE)    | No       |
| apodo      | text                                                    | No       |
| avatar_url | text                                                    | Sí       |
| created_at | timestamptz                                             | No       |

### Row Level Security — DT3 validado

* **SELECT:** público.
* **INSERT:** solo propio usuario.
* **UPDATE:** solo propio usuario.
* **DELETE:** sin política para el cliente.

El alta automática del perfil se realiza mediante trigger `SECURITY DEFINER`, no desde el cliente.

---

## Trigger automático

```sql
create or replace function public.manejar_nuevo_usuario()

returns trigger
language plpgsql

security definer set search_path = public

as $$

begin

  insert into public.perfiles (id, apodo)

  values (
    new.id,
    coalesce(split_part(new.email, '@', 1), 'Muralista')
  );

  return new;

end;

$$;

create trigger on_auth_user_created

after insert on auth.users

for each row execute procedure public.manejar_nuevo_usuario();
```

---

# 🗂️ Storage — bucket `murales`

El bucket `murales` se utiliza para fotografías de murales y avatares.

Estado actual de políticas:

* **SELECT:** restringido a usuarios autenticados para el listing de objetos.
* **INSERT:** solo usuarios autenticados.
* **DELETE:** restringido al propietario correspondiente.

### B1 — Listing anónimo

B1 fue implementado y validado.

La restricción evita el listing anónimo del contenido del bucket.

El acceso mediante una URL pública conocida continúa funcionando para los objetos que deben ser visualizados por la aplicación.

> El bucket mantiene su comportamiento necesario para renderizar imágenes mediante URLs conocidas, pero el listing de objetos ya no queda abierto al cliente anónimo.

### Nombre de archivo — corregido

El nombre de archivo generado al subir una foto (tanto en alta como en edición de mural) sanitiza el título de forma estricta, evitando que caracteres como `/` creen subcarpetas implícitas en Storage. Antes de esta corrección, la edición usaba una sanitización más débil que el alta.

---

# 📧 Envío de correos de Auth — SMTP vía Resend

Los correos de confirmación de registro y recuperación de contraseña utilizan SMTP de Resend configurado en Supabase.

Configuración utilizada:

```text
Host: smtp.resend.com
Port: 465
Username: resend
Password: <API key de Resend>
```

La plantilla de recuperación debe incluir:

```text
{{ .Token }}
```

para permitir el flujo de recuperación mediante código OTP.

### Dominio de producción

Antes de testers externos debe verificarse un dominio propio en Resend y configurar el remitente correspondiente.

---

# 📱 Permisos Android

```xml
<uses-permission android:name="android.permission.INTERNET"/>

<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>

<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

<uses-permission android:name="android.permission.CAMERA"/>
```

La galería no requiere un permiso adicional declarado en el manifiesto; `image_picker` gestiona su acceso según la plataforma.

---

# 📁 Estructura del proyecto

```text
muralito_app/

├── android/app/src/main/AndroidManifest.xml
├── android/app/build.gradle.kts        (applicationId: com.muralitoapp.app)
├── android/app/src/main/kotlin/com/example/muralito_app/MainActivity.kt   (namespace, sin cambiar)

├── lib/
│   ├── main.dart
│   │
│   ├── models/
│   │   ├── mural.dart
│   │   └── perfil.dart
│   │
│   ├── pages/
│   │   ├── auth_page.dart
│   │   ├── mapa_principal_page.dart
│   │   └── recuperar_password_page.dart
│   │
│   ├── services/
│   │   ├── supabase_client.dart
│   │   └── ubicacion_service.dart
│   │
│   ├── utils/
│   │   └── helpers.dart
│   │
│   └── widgets/
│       ├── dialogo_carga.dart
│       ├── editar_mural_modal.dart
│       ├── editar_perfil_modal.dart
│       ├── formulario_mural_modal.dart
│       ├── ajustar_ubicacion_page.dart
│       └── onboarding_ubicacion_dialog.dart   (nuevo — M3)
│
├── .env
├── .env.example
├── .gitignore
├── LICENSE
├── pubspec.yaml
└── README.md
```

`recuperar_password_page.dart` se incorporó con M2.

`ajustar_ubicacion_page.dart` se incorporó con M5.

`ubicacion_service.dart` se incorporó con M6 para centralizar la lógica reutilizable de ubicación.

`onboarding_ubicacion_dialog.dart` se incorporó con M3 para el diálogo de onboarding de ubicación.

---

# 🧪 Estado de pruebas

El proyecto cuenta con pruebas funcionales y técnicas realizadas durante el desarrollo. El detalle completo se mantiene en la **Documentación Técnica v15** y los flujos correspondientes.

## Pruebas principales

* **Prueba 001** — Registro completo de mural.
* **Prueba 002** — Ficha de detalle y solapamiento de pines.
* **Prueba 003** — Clustering de 30 m.
* **Prueba 004** — EXIF + rotación manual.
* **Prueba 005** — Autenticación, confirmación de correo, `user_id`, RLS y Storage.
* **Prueba 006** — Modo espectador.
* **Prueba 007** — Edición y eliminación de murales.
* **Prueba 008/009** — Cambio de fotografía al editar y limpieza de Storage.
* **Prueba 010** — Perfil de usuario.
* **Prueba 011** — Refactor de estructura de `lib`.
* **Prueba 012** — Eliminación de mural con limpieza de Storage.
* **Prueba 013** — "Subido por" y casos con usuarios/murales antiguos.
* **DT1-01 / DT1-02** — Registro normal y fallo controlado del INSERT con limpieza de Storage.
* **DT2-01 a DT2-05** — Actualización segura del avatar.
* **M1-01 a M1-09 / M1-UX-01 a M1-UX-04** — Contraseña, confirmación, registro y login.
* **M2-01 a M2-08** — Recuperación de contraseña por OTP, reenvío y cooldown.
* **DT3-01 a DT3-04** — RLS de perfiles.
* **DT4-01 a DT4-07 / DT13-01 a DT13-03** — Errores, red, cooldown y diálogos.
* **M5-01 a M5-11** — GPS, pin, permisos, timeout y reajuste durante el alta.
* **B1** — Restricción del listing anónimo de Storage.
* **M6-01 a M6-05 / M6-07** — Centrado de ubicación y regresión general.
* **DT4-01 (corrección v15)** — 8 escenarios manuales (4 por pantalla, registro y recuperación).
* **Storage — nombre de archivo (corrección v15)** — prueba con título conteniendo `/`.
* **Identidad Android (v15)** — `flutter run` normal, tiles OSM cargando en ambas pantallas.
* **M3 — Onboarding de ubicación** — 4 escenarios manuales (ver tabla abajo).

### M6 — pruebas

| Prueba | Resultado       |
| ------ | ---------------- |
| M6-01  | 🧪 PASS          |
| M6-02  | 🧪 PASS          |
| M6-03  | 🧪 PASS          |
| M6-04  | 🧪 PASS          |
| M6-05  | 🧪 PASS          |
| M6-06  | ❓ NO VERIFICADO |
| M6-07  | 🧪 PASS          |

M6-06 no debe considerarse aprobado hasta realizar su escenario específico.

### M3 — pruebas

| Prueba                                                       | Resultado |
| -------------------------------------------------------------- | --------- |
| Primera vez (instalación limpia)                                | 🧪 PASS   |
| "Entendido" continúa automáticamente con la acción original     | 🧪 PASS   |
| No se repite al tocar la segunda acción de ubicación             | 🧪 PASS   |
| Persiste tras cerrar y reabrir la app                            | 🧪 PASS   |

---

## `flutter analyze`

Última ejecución registrada, tras la corrección de identidad Android:

```text
Analyzing muralito_app...
No issues found! (ran in 53.3s)
```

**Resultado: 🧪 VALIDADO — sin problemas de análisis estático.**

---

# 📊 Estado actual

| Elemento                                            | Estado                                                              |
| ----------------------------------------------------- | ---------------------------------------------------------------------- |
| **M1 — Contraseña fuerte**                             | 🧪 Validado                                                            |
| **DT1 — Limpieza de Storage ante fallo de INSERT**     | 🧪 Validado                                                            |
| **DT2 — Actualización segura del avatar**              | 🧪 Validado                                                            |
| **M2 — Recuperación de contraseña**                    | 🧪 Validado                                                            |
| **DT3 — Auditoría RLS de perfiles**                    | 🧪 Validado                                                            |
| **DT4 / DT13 — Errores, loading y diálogos**           | 🧪 Validado                                                            |
| **DT4-01 — Borde rojo de contraseña (registro + recuperación)** | 🧪 Validado                                                   |
| **M5 / M10 — GPS robusto + pin en el alta**            | 🧪 Validado                                                            |
| **B1 — Restricción del listing de Storage**            | 🧪 Validado                                                            |
| **Storage — nombre de archivo unificado**              | 🧪 Validado                                                            |
| **Identidad Android (applicationId)**                  | 🧪 Validado                                                            |
| **M3 — Onboarding de ubicación**                       | 🧪 Validado                                                            |
| **M6 — Centrar mapa en mi ubicación**                  | 🧪 Implementado / validado en escenarios principales                  |
| **M6-06**                                              | ❓ No verificado                                                       |
| **Atribución de OpenStreetMap**                        | ⏳ Pendiente                                                            |
| **Firma de release**                                   | ⏳ Pendiente                                                            |
| **Autovalidate del campo de correo**                   | ⏳ Pendiente                                                            |
| **Colores hardcodeados**                               | ⏳ Pendiente — deuda de estilo                                         |
| **M9 — Protección de contraseñas filtradas**           | ⛔ Bloqueado — requiere Plan Pro                                       |
| **A4 — Autor del mural ≠ quien sube**                  | ⏳ Backlog                                                              |
| **A1.4 — Historial de fotos**                          | ⏳ Backlog — criterio de producto definido                             |
| **M4 — "Cómo llegar" hacia Google Maps** *(redefinido)* | ⏳ Backlog                                                              |
| **M16 — Actualización de versión**                     | ⏳ Backlog                                                              |
| **DT5–DT9**                                            | ⏳ Pendiente de revisión/priorización                                  |
| **DT10–DT12**                                          | 🔜 No ahora                                                            |
| **DT14–DT18**                                          | ⏳ Pendiente de revisión/priorización                                  |
| **Rendimiento / escalabilidad**                        | 🔜 Siguiente fase después de deuda técnica y mejoras prioritarias      |
| **Release Google Play**                                | 🔜 Fase posterior                                                      |

---

# ⚙️ Estrategia de rendimiento y escalabilidad

El rendimiento se analizará después de revisar la deuda técnica y las mejoras de producto prioritarias.

El proceso será:

**Medir → identificar → optimizar → volver a medir → comprobar regresiones**

Áreas previstas:

* carga inicial del mapa;
* carga de tiles;
* consultas iniciales a Supabase;
* carga y procesamiento de imágenes;
* creación de marcadores;
* clustering;
* consumo de memoria;
* desplazamiento y zoom del mapa.

No se realizarán optimizaciones destructivas ni refactorizaciones amplias basadas únicamente en una percepción de lentitud o consumo.

---

# 🎯 Objetivo de v1

El objetivo es preparar una primera versión de Muralito que sea:

* estable;
* usable;
* segura;
* mantenible;
* suficientemente probada;
* preparada para testers;
* posteriormente preparada para Google Play.

**Noviembre de 2026 es un objetivo orientativo, no una fecha límite.**

La calidad y estabilidad tienen prioridad sobre cumplir una fecha artificial.

---

# 📜 Licencia

Distribuido bajo la licencia MIT. Ver `LICENSE`.

# 👨‍💻 Autor

**Ariel Sebastian Cuenca Paillacho**

Proyecto para el registro y visualización colaborativa de arte urbano.
