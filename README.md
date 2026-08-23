# 🎨 Muralito App

Aplicación móvil desarrollada con **Flutter para Android** orientada al mapeo colaborativo de arte urbano.

Muralito permite registrar murales mediante una fotografía, obtener su ubicación geográfica, almacenar la información en **Supabase** y visualizar los murales sobre un mapa basado en **OpenStreetMap**.

---

## 📱 Características actuales

* 🗺️ Mapa interactivo con OpenStreetMap.
* 📍 Obtención de ubicación mediante GPS.
* 📷 Captura de fotografías desde la cámara.
* 📝 Registro de título y descripción del mural.
* 🖼️ Compresión de imágenes antes de subirlas.
* ☁️ Almacenamiento de fotografías mediante Supabase Storage.
* 🗄️ Registro de información mediante PostgreSQL/Supabase.
* 🎨 Marcadores de murales sobre el mapa.
* 📋 Ficha de detalle del mural.
* 🖼️ Visualización de la fotografía del mural.
* 🧭 Opción "Cómo llegar".
* 🔐 Configuración mediante variables de entorno.
* 📄 Licencia MIT.

---

## 🚧 En desarrollo

Las siguientes funcionalidades están identificadas como próximas mejoras:

* [ ] Clustering de murales cercanos.
* [ ] Corrección de orientación de fotografías horizontales.
* [ ] Rotación y ajuste de fotografías antes de guardar.
* [ ] Abrir "Cómo llegar" mediante Google Maps.
* [ ] Mejorar el manejo de permisos de ubicación.
* [ ] Permitir seleccionar o ajustar manualmente la ubicación.
* [ ] Adaptar el tamaño de los marcadores según el nivel de zoom.

---

## 🛠️ Stack tecnológico

| Capa                 | Tecnología                    |
| -------------------- | ----------------------------- |
| Framework            | Flutter                       |
| Lenguaje             | Dart                          |
| Plataforma           | Android                       |
| Mapa                 | `flutter_map` + OpenStreetMap |
| Coordenadas          | `latlong2`                    |
| GPS                  | `geolocator`                  |
| Cámara               | `image_picker`                |
| Compresión           | `flutter_image_compress`      |
| Backend              | Supabase                      |
| Base de datos        | PostgreSQL                    |
| Storage              | Supabase Storage              |
| Variables de entorno | `flutter_dotenv`              |
| Enlaces externos     | `url_launcher`                |

---

## 📋 Requisitos

- Flutter 3.47.0 o superior
- Dart 3.13.0 o compatible
- Android SDK Platform 36
- Android SDK Command-line Tools
- Android Studio
- Dispositivo Android o emulador
- Cuenta y proyecto de Supabase

---

## 📥 Instalación

Clonar el repositorio:

```bash
git clone <URL_DEL_REPOSITORIO>
```

Entrar en el proyecto:

```bash
cd muralito_app
```

Instalar las dependencias:

```bash
flutter pub get
```

Comprobar los dispositivos disponibles:

```bash
flutter devices
```

Ejecutar la aplicación:

```bash
flutter run
```

---

## 🔐 Configuración de Supabase

Muralito utiliza Supabase como backend.

La aplicación utiliza actualmente:

* PostgreSQL para los registros de los murales.
* Supabase Storage para las fotografías.

La tabla principal utilizada por la aplicación es:

```text
murales
```

Los campos utilizados actualmente son:

```text
id
created_at
titulo
descripcion
foto_url
latitud
longitud
```

El bucket utilizado para las fotografías es:

```text
murales
```

---

## 🔑 Variables de entorno

La aplicación utiliza `flutter_dotenv`.

Crear un archivo:

```text
.env
```

en la raíz del proyecto.

Su contenido debe tener la siguiente estructura:

```env
SUPABASE_URL=TU_SUPABASE_URL
SUPABASE_ANON_KEY=TU_SUPABASE_ANON_KEY
```

También se incluye:

```text
.env.example
```

como plantilla de configuración.

### ⚠️ Importante

No subir el archivo `.env` real al repositorio.

El archivo `.env.example` solamente debe contener los nombres de las variables, nunca las credenciales reales.

---

## 📱 Permisos Android

Actualmente la aplicación utiliza los siguientes permisos:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

Estos permisos permiten:

* Conectarse a Internet.
* Obtener ubicación precisa.
* Obtener ubicación aproximada.
* Utilizar la cámara.

Los permisos se solicitan durante la ejecución de la aplicación cuando son necesarios.

---

## 🔄 Flujo principal

El flujo actual para registrar un mural es:

```text
Nuevo Mural
     ↓
Permisos
     ↓
Cámara
     ↓
Fotografía
     ↓
Ubicación GPS
     ↓
Formulario
     ↓
Compresión de imagen
     ↓
Supabase Storage
     ↓
PostgreSQL
     ↓
Actualizar mapa
     ↓
Marcador
     ↓
Ficha de detalle
```

---

## 🗺️ Visualización

Los murales almacenados en Supabase se consultan al cargar la aplicación y se representan mediante marcadores sobre OpenStreetMap.

Al tocar un marcador se muestra una ficha con:

* Fotografía.
* Título.
* Descripción.
* Latitud.
* Longitud.
* Opción "Cómo llegar".

---

## 🧪 Pruebas realizadas

### Prueba 001

Se verificó el flujo completo de registro de un mural:

* Permisos.
* Cámara.
* Ubicación.
* Formulario.
* Captura de fotografía.
* Compresión.
* Subida a Supabase.
* Registro en la base de datos.
* Visualización en el mapa.

Durante la prueba también se identificaron oportunidades de mejora relacionadas con los permisos de ubicación, selección de ubicación y marcadores.

### Prueba 002

Se verificó la ficha de detalle y la visualización de fotografías.

También se identificaron problemas relacionados con:

* Murales ubicados muy cerca.
* Superposición de marcadores.
* Fotografías tomadas en orientación horizontal.
* Necesidad de utilizar Google Maps para "Cómo llegar".

---

## 📌 Estado del proyecto

**MVP funcional en desarrollo.**

Actualmente el flujo principal de registro y visualización de murales se encuentra implementado.

Las siguientes mejoras serán desarrolladas progresivamente:

```text
1. Clustering de marcadores
2. Orientación y ajuste de fotografías
3. Google Maps
4. Mejora de permisos de ubicación
5. Selección manual de ubicación
6. Optimización visual de marcadores
```

---

## 📁 Estructura principal

```text
muralito_app/
│
├── android/
│   └── app/
│       └── src/
│           └── main/
│               └── AndroidManifest.xml
│
├── lib/
│   └── main.dart
│
├── .env
├── .env.example
├── .gitignore
├── LICENSE
├── pubspec.yaml
└── README.md
```

---

## 📜 Licencia

Este proyecto está distribuido bajo la licencia **MIT**.

Consulta el archivo [`LICENSE`](LICENSE) para conocer los términos completos.

---

## 👨‍💻 Autor

**Ariel Sebastian Cuenca Paillacho**

Proyecto desarrollado como una aplicación móvil para el registro y visualización colaborativa de arte urbano.
