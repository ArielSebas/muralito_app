# 🎨 Muralito App

Aplicación móvil desarrollada con **Flutter para Android** orientada al mapeo colaborativo de arte urbano.

Muralito permite registrar murales mediante una fotografía, obtener su ubicación geográfica y almacenar la información en **Supabase**, para luego visualizarlos sobre un mapa **OpenStreetMap**. El mapa es público mediante un **modo espectador**; la autenticación solo es necesaria para registrar, editar o eliminar murales propios.

---

## 📱 Características actuales

* 🗺️ Mapa interactivo con OpenStreetMap y **modo espectador** (explorar sin cuenta).
* 🔐 Autenticación con correo y contraseña (Supabase Auth), con confirmación de correo y logout sin salir del mapa.
* 👤 **Perfil de usuario:** apodo y avatar automáticos (`perfiles` + trigger). Se ven en el `AppBar` y se pueden editar (cámara o galería) sin dejar huérfanos en Storage.
* 🧑‍🎨 **Subido por** (A3, Prueba 013): la ficha muestra avatar y apodo de quien cargó el mural. También se ve en modo espectador. Si el registro es antiguo y no tiene `user_id`, se etiqueta **Muralista anónimo**.
* 📷 Registro de murales: cámara → GPS → formulario → compresión → Storage → PostgreSQL, con `user_id` del usuario autenticado.
* 🔄 Corrección EXIF + rotación manual antes de guardar.
* ✏️ Edición de murales propios (título, descripción y foto), sin dejar archivos huérfanos si algo falla a mitad de camino.
* 🗑️ Eliminación de murales propios con limpieza de la foto en Storage, protegida en la interfaz y con RLS.
* 🧩 Clustering de murales a menos de 30 m, con lista de selección y zoom de contexto.
* 🗺️ Zoom del mapa limitado (niveles 6–18) para evitar cuelgues por falta de memoria al pellizcar.
* 💬 Mensajes de error breves y en español.
* 🧭 “Cómo llegar” desde la ficha (OpenStreetMap).
* 📄 Licencia MIT.

> **A4 no está implementado.** “Subido por” no es el autor de la pintura. Ver *Próximos pasos*.

---

## 🚧 Próximos pasos

El backlog detallado está en **Mejoras priorizadas**.

### Alta — producto (pendiente, no implementar aún)

* **A4 — Autor del mural ≠ quien sube**
  * En la ficha deben verse **dos** cosas: **Subido por** (cuenta que cargó la foto, ya existe) y **Autor del mural** (quien lo pintó / la firma).
  * Al registrar o editar: campo opcional para el nombre o perfil del artista.
  * Para todo el mundo: **“¿Eres el autor? Reclámalo”** (pide sesión). Así el artista puede atribuirse la obra aunque otra persona la haya fotografiado.
  * Distinto de “publicar ocultando el apodo”: eso es otra idea, más adelante.

### Alta — cuentas (siguiente parche chico)

* **M1** — Contraseña fuerte (mín. 8, mayúscula, minúscula, número y especial).
* **M2** — Recuperar contraseña.

### Media

* **M4** — “Cómo llegar” a Google Maps.
* **M7** — Visor de imagen con pinch-to-zoom.
* **A1.4** — Historial de versiones si se repinta el muro.

### Más adelante

* Publicar logueado pero ocultando el apodo (“como anónimo”).
* B1 — Restringir el listado público del bucket.

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

---

## 📋 Requisitos

* Flutter 3.47.0 · Dart 3.13.0
* Android SDK Platform 36 + Command-line Tools
* Android Studio o VS Code
* Dispositivo Android físico o emulador
* Cuenta y proyecto de Supabase configurado

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

user_id = quien subió el mural, no necesariamente el artista (A4 pendiente).

**Row Level Security:**
* `SELECT`: Público (`anon` y `authenticated`)
* `INSERT`: Solo `authenticated` con `auth.uid() = user_id`
* `UPDATE`: Solo propietario (`auth.uid() = user_id`)
* `DELETE`: Solo propietario (`auth.uid() = user_id`)

Los murales sin user_id (pruebas antiguas) no se pueden borrar desde la app. Eliminarlos en Table Editor.

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

* `SELECT`: Lectura pública de objetos (renderizado en mapa y AppBar)
* `INSERT`: Solo usuarios `authenticated`
* `DELETE`: Solo propietario del archivo (`bucket_id = 'murales' and owner = auth.uid()`)

> ⚠️ **Nota de seguridad:** El bucket actualmente permite listado público de archivos. Se recomienda restringir la política `SELECT` de `storage.objects` para evitar exponer el listado completo (pendiente: B1).

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


muralito_app/
├── android/app/src/main/AndroidManifest.xml
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── mural.dart
│   │   └── perfil.dart
│   ├── pages/
│   │   ├── auth_page.dart
│   │   └── mapa_principal_page.dart
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

---

## 📜 Licencia

Distribuido bajo la licencia **MIT**. Ver [`LICENSE`](LICENSE).

## 👨‍💻 Autor

**Ariel Sebastian Cuenca Paillacho** — proyecto para el registro y visualización colaborativa de arte urbano.
