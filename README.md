# 🎨 Muralito App

Aplicación móvil desarrollada con **Flutter para Android** orientada al mapeo colaborativo de arte urbano.

Muralito permite registrar murales mediante una fotografía, obtener su ubicación geográfica, almacenar la información en **Supabase** y visualizar los murales sobre un mapa basado en **OpenStreetMap**.

---

## 📱 Características actuales

* 🗺️ Mapa interactivo con OpenStreetMap.
* 📍 Obtención de ubicación mediante GPS.
* 📷 Captura de fotografías desde la cámara.
* 🔄 Corrección automática y rotación manual (pasos de 90°) de fotos antes de guardar.
* 🖼️ Previsualización y ficha de detalle adaptables a orientaciones verticales y horizontales.
* 📝 Registro de título y descripción del mural.
* 🖼️ Compresión de imágenes antes de subirlas.
* ☁️ Almacenamiento de fotografías mediante Supabase Storage.
* 🗄️ Registro de información mediante PostgreSQL/Supabase.
* 🟣 Agrupamiento inteligente (clustering) por distancia GPS real para murales cercanos.
* 📋 Ficha de detalle del mural y selector de grupo.
* 🧭 Opción "Cómo llegar".
* 🔐 Configuración mediante variables de entorno (`.env`).
* 📄 Licencia MIT.

---

## 🚧 En desarrollo

Las siguientes funcionalidades están priorizadas como próximas mejoras:

**Prioridad alta**

* [ ] Autenticación de usuarios (login/registro).
* [ ] Edición y eliminación de murales (depende de tener autenticación para hacerlo de forma segura).

**Prioridad media**

* [ ] Visor de imagen con zoom interactivo (*pinch-to-zoom*) en la ficha de detalle.
* [ ] Abrir "Cómo llegar" mediante Google Maps en lugar de OpenStreetMap.
* [ ] Mejorar el manejo de permisos de ubicación (no tratar el cierre del diálogo como denegado para siempre; permitir continuar con pin manual).
* [ ] Botón "centrar en mi ubicación" con marcador de posición del usuario en el mapa (estilo Google Maps).

**Prioridad baja**

* [ ] Permitir seleccionar o ajustar manualmente la ubicación del mural antes de guardar.
* [ ] Adaptar el tamaño de los marcadores según el nivel de zoom.
* [ ] Animación de separación ("spiderfy") al tocar un cluster de hasta ~6 murales, mostrando la lista actual para grupos más grandes.
* [ ] Revisar la política de lectura (SELECT) del bucket de Storage para que no permita listar todos los archivos públicamente.

La lista completa de mejoras, ideas a futuro y las notas de seguridad (RLS) se documentan con más detalle en el archivo de mejoras priorizadas y en la documentación técnica del proyecto.

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

### ⚠️ Nota sobre políticas RLS

Actualmente las políticas de INSERT (tabla murales) y SELECT (bucket murales) están abiertas para el rol anon para posibilitar el MVP sin autenticación obligatoria. Se cerrarán en fases posteriores al integrar login de usuarios.


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
Formulario + Rotación manual
     ↓
Compresión de imagen (Auto-orientación EXIF)
     ↓
Supabase Storage
     ↓
PostgreSQL
     ↓
Actualizar mapa (Clustering automático)
     ↓
Marcador / Selector de grupo
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

### Prueba 003

Se verificó el clustering de murales cercanos:

* Dos murales a poca distancia se muestran agrupados en un círculo con el número de murales.
* Al tocar el grupo, el mapa se acerca un poco hacia esa zona y luego se abre una lista con los murales del grupo (foto, título y descripción), permitiendo elegir cuál ver en detalle.
* Se probó con zoom máximo sobre dos murales prácticamente en el mismo punto GPS: los pines no se separan visualmente (el agrupamiento es por distancia real, no por píxeles en pantalla), pero la lista permite acceder a cada uno sin problema.
* Se insertó manualmente un mural con coordenadas alejadas directamente en la tabla `murales` de Supabase, para confirmar que los murales lejanos siguen mostrándose como pines individuales sin agruparse.
* La ficha de detalle (foto, título, descripción, "Cómo llegar") continúa funcionando igual que antes del clustering.

Resultado: todas las verificaciones funcionaron correctamente.

### Prueba 004

Validación de auto-orientación EXIF, botón interactivo de rotación en pasos de 90° en el formulario, persistencia en Supabase y ficha de detalle visualmente adaptable sin encajonamientos negros para fotos verticales u horizontales.

---

## 📌 Estado del proyecto

**MVP funcional en desarrollo.**

Actualmente el flujo principal de registro y visualización de murales se encuentra implementado.

Mejoras priorizadas

Backlog técnico y de producto, organizado de mayor a menor prioridad. Actualizado tras implementar y probar la orientación y rotación manual de fotografías (Prueba 004).

✅ Resueltas
1. Marcadores muy cercanos se solapan — RESUELTO (Prueba 003). Agrupamiento en cluster con número mediante distancia GPS real con la clase Distance de latlong2.
2. Foto en horizontal mal orientada y ajuste visual — RESUELTO (Prueba 004). Auto-orientación EXIF en compresión, botón de giro manual (90° por toque) en el formulario de registro y contenedores flexibles sin marcos rígidos en la ficha de detalle.

🔴 Prioridad alta
• Autenticación de usuarios — Login/registro de usuarios. Es la base para poder restringir de forma segura quién puede insertar, editar o eliminar murales.
• Edición y eliminación de murales — Permitir que el autor edite o borre sus propios murales. Depende de tener autenticación implementada.

🟡 Prioridad media
• Visor de imagen con zoom interactivo — Permitir pellizcar para hacer zoom (pinch-to-zoom) a la foto dentro de la ficha de detalle para observar detalles y firmas.
• "Cómo llegar" abra Google Maps — Cambiar la redirección externa para que abra directamente Google Maps (app o navegador).
• Permisos de ubicación ("denegado permanentemente") — No tratar el cierre del diálogo como denegado para siempre. Pedir GPS después de la foto y, si se cancela, dejar seguir con pin manual.
• Botón de ubicación del usuario — Botón flotante estilo Google Maps que centre automáticamente la vista en la ubicación actual, con un marcador distintivo que represente la posición del usuario.

🟢 Prioridad baja
• Ajustar ubicación en el mapa — En el formulario, botón "Ajustar en mapa" para mover el pin antes de guardar.
• Tamaño de los marcadores — Bajar el tamaño fijo (~32–36 px) o adaptarlo progresivamente al nivel de zoom.
• Animación de separación en clusters pequeños — Para grupos de hasta ~6 murales, evaluar animación "spiderfy" al tocar el cluster antes de abrir la lista.
• Revisar política SELECT del bucket de Storage — Restringir para que no permita listar todos los nombres de archivo públicamente.

🔐 Notas de seguridad (avisos de Supabase)
[Se mantienen las notas sobre RLS abierta en INSERT y política pública de Storage pendientes para la etapa de autenticación].

💡 Ideas a futuro
[Se mantienen las ideas de gamificación, insignias de autor, moderación, reportes de estado y personalización].

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
