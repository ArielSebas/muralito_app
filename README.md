# 🎨 Muralito App

Aplicación móvil desarrollada con **Flutter para Android** orientada al mapeo colaborativo de arte urbano.

Muralito permite registrar murales mediante una fotografía, obtener su ubicación geográfica, almacenar la información en **Supabase** y visualizarlos sobre un mapa **OpenStreetMap**. El mapa es público (**modo espectador**). La autenticación solo se exige para registrar un mural.

---

## 📱 Características actuales

* Mapa interactivo con OpenStreetMap.
* **Modo espectador** — explorar el mapa y ver murales sin iniciar sesión (Prueba 006).
* **Autenticación** — registro y login con correo y contraseña (Supabase Auth, confirmación por correo).
* Login exigido solo al tocar **Nuevo Mural** si no hay sesión.
* Logout: el usuario permanece en el mapa.
* AppBar: “Modo espectador” o el correo; ícono de entrada `person_outline`.
* GPS, cámara, rotación manual 90° y auto-orientación EXIF.
* Compresión JPEG y subida a Supabase Storage.
* Registro en PostgreSQL con `user_id`.
* Clustering por distancia GPS real (radio 30 m) y lista al tocar un grupo.
* Ficha de detalle (bottom sheet): foto, título, descripción, coordenadas y **Cómo llegar** (OpenStreetMap).
* Configuración con `.env` y licencia MIT.

---

## 🚧 En desarrollo

**Prioridad alta**

* [ ] Edición y eliminación de murales (solo el autor). Requiere políticas RLS `UPDATE` / `DELETE`.
* [ ] Perfil de usuario (apodo, foto) y mostrarlo en AppBar y en la ficha del mural.

**Prioridad media**

* [ ] Contraseña fuerte en el registro (mayúscula, minúscula, número, especial, 8+).
* [ ] Recuperar contraseña (`resetPasswordForEmail`).
* [ ] Onboarding “Cómo usar” (GPS preciso vs aproximado).
* [ ] Visor de imagen con zoom (*pinch-to-zoom*) en la ficha.
* [ ] “Cómo llegar” con Google Maps.
* [ ] Permisos de ubicación más amables + pin manual si se niega el GPS.
* [ ] Botón “Mi ubicación” con marcador del usuario.

**Prioridad baja**

* [ ] Ajustar la ubicación en el mapa antes de guardar.
* [ ] Tamaño de marcadores según zoom.
* [ ] Animación “spiderfy” en clusters pequeños.
* [ ] Restringir el SELECT del bucket Storage para que no liste todos los archivos (aviso de Supabase).
* [ ] Activar Leaked Password Protection en Auth Settings (HaveIBeenPwned).

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
| Cámara | `image_picker` |
| Compresión | `flutter_image_compress` |
| Backend | Supabase |
| Base de datos | PostgreSQL |
| Storage | Supabase Storage |
| Auth | Supabase Auth |
| Variables de entorno | `flutter_dotenv` |
| Enlaces externos | `url_launcher` |

---

## 📋 Requisitos

- Flutter 3.47.0 o superior
- Dart 3.13.0 o compatible
- Android SDK Platform 36
- Android SDK Command-line Tools
- Android Studio o VS Code
- Dispositivo Android o emulador
- Cuenta y proyecto de Supabase

---

## 📥 Instalación

```bash
git clone <URL_DEL_REPOSITORIO>
cd muralito_app
flutter pub get
flutter devices
flutter run

---

## 🔐 Configuración de Supabase

PostgreSQL: tabla murales
Storage: bucket público murales
Auth: email / contraseña

Campos de murales:
textid
created_at
titulo
descripcion
foto_url
latitud
longitud
user_id

En: titulo, descripcion, foto_url, latitud, longitud y user_id son nullable en PostgreSQL. La app valida título y coordenadas en el cliente.

RLS actual

SELECT tabla: público (espectador).
INSERT tabla: authenticated + auth.uid() = user_id.
UPDATE / DELETE: aún no.
Storage INSERT: solo authenticated.

Los usuarios viven en Authentication → Users. No hay tabla perfiles.
Nota sobre autenticación
Cualquiera abre la app y ve el mapa. Al tocar Nuevo Mural sin sesión aparece un diálogo: seguir explorando, registrarse o iniciar sesión.

---

## 🔑 Variables de entorno

Crear .env en la raíz (no subir a Git):

envSUPABASE_URL=TU_SUPABASE_URL
SUPABASE_ANON_KEY=TU_SUPABASE_ANON_KEY

.env.example es la plantilla pública, sin claves.

## 📱 Permisos Android

<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>

---

## 🔄 Flujo principal

Modo espectador (sin login)

Abrir app
     ↓
Mapa con murales visibles
     ↓
Tocar marcador → Ficha de detalle
     ↓
"Cómo llegar" / Cerrar

Modo Registrar (con login)

```text
Nuevo Mural
     ↓
(si no hay sesión → diálogo de login)
     ↓
Permisos → Cámara → GPS
     ↓
Formulario + rotación
     ↓
Compresión → Storage → PostgreSQL
     ↓
Actualizar mapa (clustering)
```

---


## 🧪 Pruebas realizadas

Prueba 001
Flujo completo de registro (permisos, cámara, GPS, formulario, compresión, Storage, BD, mapa).

Prueba 002
Ficha de detalle. Se detectó solapamiento de pines, foto horizontal y el deseo de Google Maps.

Prueba 003
Clustering radio 30 m, lista del grupo, pines lejanos individuales.

Prueba 004
EXIF + rotación 90°; ficha adaptable vertical/horizontal.

Prueba 005 — Auth
Registro, correo de confirmación, login, user_id poblado, RLS INSERT y Storage INSERT autenticado. Logout funcional.

Prueba 006 — Modo espectador
App abre en el mapa sin login. FAB pide sesión. Tras login continúa la cámara. Logout permanece en el mapa. Ícono de persona para entrar.

---

## 📌 Estado del proyecto

MVP funcional. Auth + modo espectador validados.
Hecho: mapa, alta, clustering, rotación, ficha, auth, espectador, user_id + RLS INSERT.
Siguiente: editar/borrar (autor) y perfil (apodo + foto).
---

## 📁 Estructura principal

muralito_app/
├── android/app/src/main/AndroidManifest.xml
├── lib/main.dart
├── .env                 # local, ignorado por git
├── .env.example
├── .gitignore
├── LICENSE
├── pubspec.yaml
└── README.md

---

## 📜 Licencia

Este proyecto está distribuido bajo la licencia **MIT**.

Consulta el archivo [`LICENSE`](LICENSE) para conocer los términos completos.

---

## 👨‍💻 Autor

**Ariel Sebastian Cuenca Paillacho**

Proyecto desarrollado como una aplicación móvil para el registro y visualización colaborativa de arte urbano.
