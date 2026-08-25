# 🎨 Muralito App

Aplicación móvil desarrollada con **Flutter para Android** orientada al mapeo colaborativo de arte urbano.

Muralito permite registrar murales mediante una fotografía, obtener su ubicación geográfica, almacenar la información en **Supabase** y visualizarlos sobre un mapa **OpenStreetMap**. El mapa es público mediante un **modo espectador**, mientras que la autenticación es necesaria para registrar, editar o eliminar murales propios.

---

## 📱 Características actuales

- Mapa interactivo con **OpenStreetMap**.
- **Modo espectador**: explorar el mapa y visualizar murales sin iniciar sesión.
- **Autenticación** mediante correo y contraseña con Supabase Auth.
- Confirmación de correo electrónico.
- Login exigido al intentar registrar un mural si no existe una sesión.
- Logout sin abandonar el mapa.
- AppBar adaptado al estado de autenticación:
  - "Modo espectador" cuando no existe sesión.
  - Correo del usuario cuando existe sesión.
  - Ícono `person_outline` para acceder a la autenticación.
- Registro de murales mediante:
  - Cámara.
  - GPS.
  - Formulario.
  - Compresión de imagen.
  - Supabase Storage.
  - PostgreSQL.
- Obtención y almacenamiento de coordenadas GPS.
- Rotación manual de imágenes en incrementos de 90°.
- Corrección de orientación mediante información EXIF.
- Clustering de murales cercanos mediante distancia GPS real.
- Radio de clustering actual: **30 metros**.
- Lista de murales cuando se selecciona un grupo.
- Ficha de detalle mediante `BottomSheet`.
- Visualización de:
  - Fotografía.
  - Título.
  - Descripción.
  - Latitud.
  - Longitud.
  - Botón "Cómo llegar".
- Edición de murales por parte de su propietario.
- Eliminación de murales por parte de su propietario.
- Protección de edición y eliminación mediante **Supabase RLS**.
- `user_id` asociado a cada mural.
- Configuración mediante `.env`.
- Licencia MIT.

---

## 🚧 En desarrollo

### 🔴 Prioridad alta

#### A2 — Perfil básico de usuario

- [ ] Crear perfil de usuario.
- [ ] Apodo.
- [ ] Foto de perfil.
- [ ] Mostrar apodo en el AppBar.
- [ ] Mostrar autor en la ficha del mural.
- [ ] Crear tabla `perfiles` o utilizar `user_metadata`.

#### A3 — Autor en la ficha del mural

- [ ] Mostrar información del autor.
- [ ] Foto del autor.
- [ ] Apodo.
- [ ] Avatar genérico si no existe información de perfil.

#### A4 — Campo de autor al registrar

- [ ] Vincular el mural con `user_id`.
- [ ] Definir si se permitirá crédito mediante apodo sin cuenta.

---

### 🟡 Prioridad media

- [ ] Contraseña fuerte durante el registro.
  - Mayúscula.
  - Minúscula.
  - Número.
  - Carácter especial.
  - Mínimo 8 caracteres.

- [ ] Recuperación de contraseña mediante `resetPasswordForEmail()`.

- [ ] Onboarding "Cómo usar".
  - Explicar GPS preciso vs. aproximado.
  - Explicar el flujo de registro.
  - Explicar permisos.

- [ ] Visor de imagen con **pinch-to-zoom**.

- [ ] "Cómo llegar" mediante Google Maps.

- [ ] Mejorar el flujo de permisos de ubicación.
  - Diferenciar correctamente permisos rechazados.
  - Evitar interpretar un cierre del diálogo como `deniedForever`.
  - Ofrecer alternativas cuando el GPS no está disponible.

- [ ] Botón "Mi ubicación".
  - Centrar el mapa en la ubicación del usuario.
  - Mostrar marcador de ubicación.

- [ ] Activar **Leaked Password Protection** en Supabase Auth.

---

### 🟢 Prioridad baja

- [ ] Ajustar manualmente la ubicación del mural antes de guardar.
- [ ] Tamaño de marcadores adaptado al nivel de zoom.
- [ ] Animación "spiderfy" para clusters pequeños.
- [ ] Restringir el `SELECT` del bucket de Storage para evitar el listado público de archivos.
- [ ] Bio y redes sociales en el perfil.
- [ ] Login con Google.
- [ ] Foto automática mediante proveedor de autenticación.
- [ ] Pantalla específica de "Indicaciones".
- [ ] Mejorar el logo/ícono de marca.

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
| Autenticación | Supabase Auth |
| Variables de entorno | `flutter_dotenv` |
| Enlaces externos | `url_launcher` |
| Iconos Cupertino | `cupertino_icons` |

### Dependencias principales

```yaml
cupertino_icons: ^1.0.8
supabase_flutter: ^2.17.2
flutter_map: ^8.3.1
latlong2: ^0.10.1
geolocator: ^14.0.3
image_picker: ^1.2.3
flutter_image_compress: ^2.5.1
flutter_dotenv: ^6.0.1
url_launcher: ^6.3.1

## 📋 Requisitos
Flutter 3.47.0
Dart 3.13.0
Android SDK Platform 36
Android SDK Command-line Tools
Android Studio o VS Code
Dispositivo Android o emulador
Cuenta/proyecto de Supabase
Developer Mode habilitado en Windows cuando sea necesario para Flutter y sus plugins.

Versión utilizada actualmente:

Flutter 3.47.0
Dart 3.13.0
DevTools 2.60.0

## 📥 Instalación

Clonar el repositorio:

git clone <URL_DEL_REPOSITORIO>

Entrar al proyecto:

cd muralito_app

Instalar dependencias:

flutter pub get

Comprobar dispositivos disponibles:

flutter devices

Ejecutar la aplicación:

flutter run

--

## 🔐 Configuración de Supabase

Muralito utiliza Supabase como backend serverless.

Actualmente se utilizan:

PostgreSQL.
Supabase Storage.
Supabase Auth.
Row Level Security (RLS).
Tabla murales

La tabla contiene actualmente:

Campo	Tipo	Nullable
id	bigint	No
created_at	timestamp with time zone	No
titulo	text	No
descripcion	text	Sí
foto_url	text	No
latitud	double precision	No
longitud	double precision	No
user_id	uuid	Sí

user_id identifica al usuario autenticado que creó el mural.

Los registros antiguos pueden tener user_id nulo.

---

## 🔒 Row Level Security (RLS)

La tabla public.murales tiene habilitado Row Level Security.

SELECT

La lectura es pública para permitir el modo espectador:

Roles:
anon
authenticated

Operación:
SELECT

Condición:
true

Por lo tanto, cualquier usuario puede visualizar los murales publicados.

INSERT

Solo los usuarios autenticados pueden crear murales.

Rol:
authenticated

Operación:
INSERT

Condición:
auth.uid() = user_id

Esto evita que un usuario autenticado inserte un mural asignándolo a otro usuario.

UPDATE

Solo el propietario puede modificar su mural.

Rol:
authenticated

Operación:
UPDATE

USING:
auth.uid() = user_id

WITH CHECK:
auth.uid() = user_id
DELETE

Solo el propietario puede eliminar su mural.

Rol:
authenticated

Operación:
DELETE

USING:
auth.uid() = user_id

La aplicación también comprueba la propiedad del mural en la interfaz antes de mostrar las opciones Editar y Eliminar.

La protección de la interfaz no sustituye a RLS. La seguridad real de UPDATE y DELETE se encuentra en las políticas de Supabase.

---

## 🗄️ Supabase Storage

Bucket utilizado:

murales

Configuración actual:

Bucket público.
Lectura pública de imágenes.
Subida de imágenes únicamente para usuarios autenticados.

Política de inserción:

Rol:
authenticated

Condición:
bucket_id = 'murales'

Actualmente existe una política de lectura pública sobre storage.objects.

Supabase puede advertir que esta política permite listar objetos del bucket. Esta situación está registrada como mejora futura.

---

## 🔑 Autenticación

Muralito utiliza Supabase Auth con:

Proveedor:
Email

Confirmación de correo:
Activada

Leaked Password Protection:
Pendiente de activar

Los usuarios se almacenan en:

auth.users

Actualmente no existe una tabla personalizada de perfiles.

La aplicación utiliza:

supabase.auth.signUp(...)
supabase.auth.signInWithPassword(...)
supabase.auth.signOut()

El usuario autenticado se relaciona con los murales mediante:

murales.user_id

---

## 🔐 Variables de entorno

Crear un archivo .env en la raíz del proyecto:

SUPABASE_URL=TU_SUPABASE_URL
SUPABASE_ANON_KEY=TU_SUPABASE_ANON_KEY

El archivo .env contiene las credenciales del proyecto y no debe subirse al repositorio.

Existe un archivo público:

.env.example

como plantilla:

SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu_anon_key_aqui

---

## 📱 Permisos Android

Actualmente AndroidManifest.xml declara los siguientes permisos:

<uses-permission android:name="android.permission.INTERNET"/>

<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>

<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

<uses-permission android:name="android.permission.CAMERA"/>

Estos permisos permiten utilizar:

Internet.
Ubicación precisa.
Ubicación aproximada.
Cámara.

Los permisos son solicitados durante el flujo correspondiente de la aplicación.

---

## 🔄 Flujo principal
Modo espectador
Abrir aplicación
        ↓
Mapa público
        ↓
Murales visibles
        ↓
Tocar marcador
        ↓
Ficha del mural
        ↓
Cómo llegar / Cerrar

No es necesario iniciar sesión para explorar los murales.

Registrar mural
Nuevo Mural
      ↓
¿Existe sesión?
      ↓
   NO → Registro / Login
      ↓
   SÍ
      ↓
Permisos
      ↓
Cámara
      ↓
Fotografía
      ↓
Orientación / rotación
      ↓
GPS
      ↓
Formulario
      ↓
Compresión de imagen
      ↓
Supabase Storage
      ↓
PostgreSQL
      ↓
user_id
      ↓
Actualizar mapa
      ↓
Clustering
Editar mural

Disponible únicamente para el propietario:

Tocar mural propio
       ↓
Ficha de detalle
       ↓
Editar
       ↓
Modificar título / descripción
       ↓
Guardar cambios
       ↓
UPDATE en PostgreSQL
       ↓
Recargar murales
       ↓
Ficha y mapa actualizados

Si el usuario cancela:

Editar
  ↓
Modificar datos
  ↓
Cancelar
  ↓
Cerrar diálogo
  ↓
No se realiza UPDATE

Este comportamiento fue validado en la Prueba 007-04-A y 007-04-B.

Eliminar mural

Disponible únicamente para el propietario:

Tocar mural propio
       ↓
Ficha de detalle
       ↓
Eliminar
       ↓
Confirmar
       ↓
DELETE en PostgreSQL
       ↓
Recargar murales
       ↓
Mural desaparece del mapa

Si el usuario cancela:

Eliminar
   ↓
Cancelar
   ↓
El mural permanece

---


## 🧪 Pruebas realizadas
Prueba 001 — Registro completo

Validado:

Permisos.
Cámara.
GPS.
Formulario.
Compresión.
Supabase Storage.
PostgreSQL.
Visualización del mural en el mapa.
Prueba 002 — Ficha de detalle

Validado:

Apertura de la ficha al tocar un mural.
Fotografía.
Título.
Descripción.
Coordenadas.
Botón "Cómo llegar".

Se detectaron inicialmente:

Problemas con fotografías horizontales.
Solapamiento de murales cercanos.
Necesidad de mejorar "Cómo llegar".

Estos problemas dieron origen a mejoras posteriores.

Prueba 003 — Clustering

Validado:

Clustering mediante distancia GPS.
Radio aproximado de 30 metros.
Visualización individual de murales alejados.
Lista de murales al seleccionar un grupo.
Prueba 004 — Orientación de imágenes

Validado:

Lectura de orientación EXIF.
Rotación manual de 90°.
Ficha adaptable a fotografías verticales y horizontales.
Prueba 005 — Autenticación

Validado:

Registro.
Confirmación por correo.
Login.
Logout.
user_id.
RLS para INSERT.
Storage INSERT únicamente autenticado.
Prueba 006 — Modo espectador

Validado:

La aplicación abre directamente en el mapa.
No es necesario iniciar sesión para explorar.
El botón "Nuevo Mural" solicita autenticación cuando corresponde.
Después del login continúa el flujo de registro.
Logout mantiene al usuario en el mapa.
Ícono person_outline para acceder a la autenticación.
Prueba 007 — Edición y eliminación

Validado:

007-01 — Visualización como propietario

Al abrir un mural propio aparecen:

Editar.
Eliminar.
Cómo llegar.
Cerrar.

Resultado: correcto.

007-02 — Editar título

Se modificó:

Prueba 001

a:

Prueba 001 - Editada

Resultado: correcto.

El cambio se refleja posteriormente en la ficha.

007-03 — Editar descripción

Validado:

UPDATE en Supabase.
Actualización de la ficha.
Actualización del mapa.

Resultado: correcto.

007-04-A — Cancelar edición de descripción

Se modificó únicamente la descripción y se canceló.

Resultado:

El diálogo se cierra.
No aparece error.
No se realiza UPDATE.
La descripción original permanece.

Resultado: correcto.

007-04-B — Cancelar edición completa

Se modificaron título y descripción y posteriormente se canceló.

Resultado:

Sin error.
Ningún cambio guardado.
Los datos originales permanecen.

Resultado: correcto.

007-04-C — Guardar edición

Se modificó la descripción y se guardó.

Resultado:

UPDATE en Supabase.
Mural actualizado.
Información actualizada en el mapa.

Resultado: correcto.

007-05 — Cancelar eliminación

Se abrió el diálogo de eliminación y se canceló.

Resultado:

El mural permanece.

Resultado: correcto.

007-06 — Eliminar mural

Se confirmó la eliminación.

Resultado:

Registro eliminado de PostgreSQL.
Mural eliminado del mapa después de recargar.

Resultado: correcto.

007-07 — Seguridad entre usuarios

Se validó el comportamiento de propiedad mediante RLS.

Resultado esperado:

Usuario A → Editar   ✅
Usuario A → Eliminar ✅

Usuario B → Editar   ❌
Usuario B → Eliminar ❌

La seguridad se mantiene en Supabase mediante:

auth.uid() = user_id

Resultado: correcto.

---

## stado actual del proyecto

MVP funcional.

Actualmente se encuentran implementados y validados:

Mapa público.
OpenStreetMap.
Modo espectador.
Autenticación.
Registro de murales.
GPS.
Cámara.
Orientación EXIF.
Rotación manual.
Compresión de imágenes.
Supabase Storage.
PostgreSQL.
user_id.
RLS para SELECT.
RLS para INSERT.
RLS para UPDATE.
RLS para DELETE.
Clustering.
Ficha de detalle.
Edición de murales propios.
Eliminación de murales propios.
Protección de operaciones por propietario.
Variables de entorno.
Licencia MIT.
Siguiente objetivo recomendado

A2 — Perfil básico de usuario

Propuesta:

Usuario
   ↓
Perfil
   ├── Apodo
   └── Foto
        ↓
AppBar
        ↓
Ficha del mural
        ↓
Autor del mural

---

## 📁 Estructura principal
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
├── .env                  # local, ignorado por Git
├── .env.example          # plantilla pública
├── .gitignore
├── LICENSE
├── pubspec.yaml
├── pubspec.lock
└── README.md

---

## 📜 Licencia

Este proyecto está distribuido bajo la licencia **MIT**.

Consulta el archivo [`LICENSE`](LICENSE) para conocer los términos completos.

---

## 👨‍💻 Autor

**Ariel Sebastian Cuenca Paillacho**

Proyecto desarrollado como una aplicación móvil para el registro y visualización colaborativa de arte urbano.
