# 🎨 Muralito App

Aplicación móvil en **Flutter (Android)** para el mapeo colaborativo de arte urbano: captura foto, ubicación GPS, subida a Supabase y visualización en mapa **OpenStreetMap**.

---

## Características actuales

- Mapa interactivo con OpenStreetMap (`flutter_map`)
- Registro de murales: cámara → GPS → formulario → compresión → Storage + BD
- Marcadores en el mapa
- Ficha de detalle (bottom sheet): foto, título, descripción, coordenadas y **Cómo llegar**
- Backend serverless con Supabase (PostgreSQL + Storage)

### En progreso / pendientes
- Clustering de marcadores cercanos
- Corrección de orientación de fotos (horizontal)
- Abrir “Cómo llegar” en Google Maps
- Mejora del flujo de permisos de ubicación
- Ajustar pin en el mapa antes de guardar

---

## Stack

| Capa | Tecnología |
|------|------------|
| Framework | Flutter / Dart |
| Mapa | `flutter_map` + `latlong2` |
| GPS | `geolocator` |
| Cámara | `image_picker` |
| Compresión | `flutter_image_compress` |
| Backend | Supabase (`supabase_flutter`) |
| Config | `flutter_dotenv` |
| Enlaces | `url_launcher` |

---

## Estructura del proyecto

```text
muralito_app/
├── android/                    # Permisos nativos (GPS, cámara, internet)
├── lib/
│   └── main.dart               # App, modelo Mural, mapa, formulario y subida
├── .env                        # SUPABASE_URL y SUPABASE_ANON_KEY (no subir a git)
└── pubspec.yaml