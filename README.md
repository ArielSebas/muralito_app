# 🎨 Muralito App

Aplicación móvil desarrollada con **Flutter para Android** orientada al mapeo colaborativo de arte urbano.

Muralito permite registrar murales mediante una fotografía, obtener su ubicación geográfica y almacenar la información en **Supabase**, para luego visualizarlos sobre un mapa **OpenStreetMap**. El mapa es público mediante un **modo espectador**; la autenticación solo es necesaria para registrar, editar o eliminar murales propios.

---

## 📱 Características actuales

* 🗺️ Mapa interactivo con OpenStreetMap, con **modo espectador** (explorar sin cuenta).
* 🔐 Autenticación con correo y contraseña (Supabase Auth), con confirmación de correo y logout sin salir del mapa.
* 📷 Registro de murales: cámara → GPS → formulario → compresión → Supabase Storage → PostgreSQL.
* 🔄 Corrección automática de orientación (EXIF) + rotación manual antes de guardar.
* ✏️ Edición de murales propios (título, descripción y **foto**, desde cámara o galería), sin dejar archivos huérfanos en Storage si algo falla a mitad de camino.
* 🗑️ Eliminación de murales propios, protegida en la interfaz y con Row Level Security en Supabase.
* 🧩 Agrupamiento (clustering) de murales muy cercanos (radio de 30 m), con lista de selección y zoom de contexto al tocar un grupo.
* 💬 Mensajes de error breves y en español en toda la app, en vez de excepciones técnicas crudas.
* 🧭 Opción "Cómo llegar" desde la ficha de cada mural.
* 📄 Licencia MIT.

---

## 🚧 Próximos pasos

El backlog completo, priorizado y con ideas a futuro, se documenta aparte en **Mejoras priorizadas**. A modo de resumen, lo siguiente en la fila:

* **A1.4** — Historial de versiones del mural (cuando se repinta un muro, conservar el mural anterior en vez de perderlo).
* **A2** — Perfil básico de usuario (apodo + foto).
* **A3 / A4** — Mostrar y registrar el autor en la ficha del mural.

---

## 🛠️ Stack tecnológico

| Capa | Tecnología |
| --- | --- |
| Framework | Flutter |
| Lenguaje | Dart |
| Plataforma | Android |
| Mapa | `flutter_map` + OpenStreetMap |
| Coordenadas | `latlong2` |
| GPS | `geolocator` |
| Cámara / galería | `image_picker` |
| Compresión | `flutter_image_compress` |
| Backend | Supabase (PostgreSQL + Auth + Storage) |
| Variables de entorno | `flutter_dotenv` |
| Enlaces externos | `url_launcher` |

```yaml
supabase_flutter: ^2.17.2
flutter_map: ^8.3.1
latlong2: ^0.10.1
geolocator: ^14.0.3
image_picker: ^1.2.3
flutter_image_compress: ^2.5.1
flutter_dotenv: ^6.0.1
url_launcher: ^6.3.1
cupertino_icons: ^1.0.8
```

---

## 📋 Requisitos

* Flutter 3.47.0 · Dart 3.13.0
* Android SDK Platform 36 + Command-line Tools
* Android Studio o VS Code
* Dispositivo Android o emulador
* Cuenta y proyecto de Supabase

---

## 📥 Instalación

```bash
git clone <URL_DEL_REPOSITORIO>
cd muralito_app
flutter pub get
flutter run
```

---

## 🔐 Configuración de Supabase

Crear un archivo `.env` en la raíz del proyecto (usar `.env.example` como plantilla):

```env
SUPABASE_URL=TU_SUPABASE_URL
SUPABASE_ANON_KEY=TU_SUPABASE_ANON_KEY
```

**Tabla `murales`** (PostgreSQL):

| Campo | Tipo | Nullable |
| --- | --- | --- |
| id | bigint | No |
| created_at | timestamptz | No |
| titulo | text | No |
| descripcion | text | Sí |
| foto_url | text | No |
| latitud | double precision | No |
| longitud | double precision | No |
| user_id | uuid | Sí |

**Row Level Security:** `SELECT` público (modo espectador); `INSERT`/`UPDATE`/`DELETE` restringidos al propietario (`auth.uid() = user_id`).

**Storage — bucket `murales`** (público): `SELECT` público, `INSERT` y `DELETE` solo para usuarios autenticados (el `DELETE` es necesario para poder reemplazar la foto de un mural sin acumular archivos huérfanos).

Detalle completo de políticas y esquema → ver **Documentación Técnica**.

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

## 📁 Estructura principal

```text
muralito_app/
├── android/app/src/main/AndroidManifest.xml
├── lib/main.dart
├── .env                  # local, ignorado por Git
├── .env.example          # plantilla pública
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