# 🎨 Muralito App

Aplicación móvil desarrollada con **Flutter para Android** orientada al mapeo colaborativo de arte urbano.

Muralito permite registrar murales mediante una fotografía, obtener su ubicación geográfica y almacenar la información en **Supabase**, para luego visualizarlos sobre un mapa **OpenStreetMap**. El mapa es público mediante un **modo espectador**; la autenticación solo es necesaria para registrar, editar o eliminar murales propios.

---

## 📱 Características actuales

* 🗺️ Mapa interactivo con OpenStreetMap, con **modo espectador** (explorar sin cuenta).
* 🔐 Autenticación con correo y contraseña (Supabase Auth), con confirmación de correo y logout sin salir del mapa.
* 👤 **Perfil de usuario:** Perfil básico automático (apodo y avatar) gestionado con tabla `perfiles` y trigger en PostgreSQL. Visualización del apodo y avatar en el `AppBar`.
* ✏️ **Edición de perfil:** Modal interactivo para personalizar apodo y foto de perfil (cámara o galería), con compresión y reemplazo seguro sin huérfanos en Storage.
* 📷 Registro de murales: cámara → GPS → formulario → compresión → Supabase Storage → PostgreSQL.
* 🔄 Corrección automática de orientación (EXIF) + rotación manual antes de guardar.
* ✏️ Edición de murales propios (título, descripción y **foto**, desde cámara o galería), sin dejar archivos huérfanos en Storage si algo falla a mitad de camino.
* 🗑️ Eliminación de murales propios con limpieza automática de la foto en Storage, protegida en la interfaz y con Row Level Security en Supabase.
* 🧩 Agrupamiento (clustering) de murales muy cercanos (radio de 30 m), con lista de selección y zoom de contexto al tocar un grupo.
* 💬 Mensajes de error breves y en español en toda la app, en vez de excepciones técnicas crudas.
* 🧭 Opción "Cómo llegar" desde la ficha de cada mural.
* 📄 Licencia MIT.

---

## 🚧 Próximos pasos

El backlog completo, priorizado y con ideas a futuro, se documenta aparte en **Mejoras priorizadas**. A modo de resumen, lo siguiente en la fila:

* **A3** — Mostrar el autor en la ficha de detalle del mural (`Subido por: [avatar] [apodo]`).
* **A4** — Vincular información del autor durante el registro.
* **A1.4** — Historial de versiones del mural (cuando se repinta un muro, conservar el mural anterior en vez de perderlo).
* **M1** — Validación de contraseña fuerte (mínimo 8 caracteres, mayúscula, minúscula, número y especial).
* **M4** — "Cómo llegar" directo a Google Maps.
* **M7** — Visor de imagen con zoom interactivo (*pinch-to-zoom*).

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
```

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

**Row Level Security:**
* `SELECT`: Público (`anon` y `authenticated`)
* `INSERT`: Solo `authenticated` con `auth.uid() = user_id`
* `UPDATE`: Solo propietario (`auth.uid() = user_id`)
* `DELETE`: Solo propietario (`auth.uid() = user_id`)

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

```text
muralito_app/
├── android/app/src/main/AndroidManifest.xml
├── lib/
│   ├── main.dart                          # Inicialización + AuthGate
│   ├── models/
│   │   ├── mural.dart                     # Modelo Mural
│   │   └── perfil.dart                    # Modelo Perfil
│   ├── pages/
│   │   ├── auth_page.dart                 # Login / Registro
│   │   └── mapa_principal_page.dart       # Mapa, clustering, lógica principal
│   ├── services/
│   │   └── supabase_client.dart           # Cliente Supabase global
│   ├── utils/
│   │   └── helpers.dart                   # Helpers reutilizables
│   └── widgets/
│       ├── dialogo_carga.dart
│       ├── editar_mural_modal.dart
│       ├── editar_perfil_modal.dart
│       └── formulario_mural_modal.dart
├── .env                                   # local, ignorado por Git
├── .env.example                           # plantilla pública
├── .gitignore
├── LICENSE
├── pubspec.yaml
└── README.md
```

---

## 📜 Licencia

Distribuido bajo la licencia **MIT**. Ver [`LICENSE`](LICENSE).

## 👨‍💻 Autor

**Ariel Sebastian Cuenca Paillacho** — proyecto para el registro y visualización colaborativa de arte urbano.
