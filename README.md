# 🎨 Muralito App

Aplicación móvil multiplataforma desarrollada en **Flutter** para el mapeo colaborativo, geolocalización y preservación digital del arte urbano y murales locales utilizando **OpenStreetMap** y **Supabase**.

---

## 🚀 Características Principales

* **Mapa Interactivo:** Visualización fluida de mapas vectoriales/rasterizados con OpenStreetMap (`flutter_map`).
* **Geolocalización Automática:** Detección de coordenadas GPS en tiempo real para el registro exacto de cada obra de arte.
* **Captura y Compresión:** Integración de cámara nativa con optimización de imágenes antes del guardado.
* **Backend Serverless:** Almacenamiento de datos relacionales y buckets públicos de fotos mediante Supabase (PostgreSQL).

---

## 🛠️ Stack Tecnológico

| Capa / Componente | Tecnología |
| :--- | :--- |
| **Framework Móvil** | Flutter (Dart SDK 3.47+) |
| **Motor de Mapas** | `flutter_map` + `latlong2` (OpenStreetMap Tile Server) |
| **Backend & Base de Datos** | Supabase (PostgreSQL + Row Level Security) |
| **Almacenamiento de Archivos**| Supabase Storage (Public Buckets) |
| **Hardware & Sensores** | `geolocator` (GPS), `image_picker` (Cámara) |

---

## 📋 Estructura del Proyecto

```text
muralito_app/
├── android/               # Configuración nativa de Android y permisos (GPS/Cámara)
├── lib/
│   ├── main.dart          # Inicialización de Supabase y punto de entrada
│   ├── models/            # Modelo de datos para Mural
│   ├── services/          # Conexión con Supabase y subida de archivos
│   └── views/             # Pantalla de Mapa y Formulario de nuevo mural
└── pubspec.yaml           # Gestión de dependencias y assets