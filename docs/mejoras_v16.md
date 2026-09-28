# Muralito App — Backlog Priorizado

**Versión:** 16
**Fecha:** 26/09/2026
**Actualiza:** Mejoras_v15 (21/09/2026). Se conserva el histórico de versiones anteriores.
**Estado actual:** MVP funcional avanzado.

**Últimas funcionalidades implementadas:**
* Atribución visible y legal de OpenStreetMap en el mapa principal y pantalla de ajuste.
* Origen de fotografía en «Nuevo Mural» (modal selector entre cámara nativa y galería).
* Sistema unificado de avisos y notificaciones (Toast superior en el mapa principal).

**Últimas correcciones y tareas cerradas:**
* Atribución OSM validada (cumplimiento de la política de tiles de OSM).
* Selección de cámara / galería validada con 4 pruebas manuales PASS.
* Estandarización de toasts superiores y reposicionamiento de botones flotantes (FABs).
* Corrección documental sobre la identidad de la app: constatación en código de que namespace y applicationId están alineados en com.muralitoapp.app.

**Hallazgos pendientes sin resolver:**
* Firma de compilación Release (sigue configurada con la clave debug).
* Autovalidate del campo «Correo electrónico» en autenticación (mismo patrón resuelto en DT4-01).
* Colores hardcodeados en 8 archivos (~53 referencias directas a Colors.deepPurple).

**Siguiente línea de trabajo:** A definir entre los candidatos vigentes: autovalidate en campo de correo (UX), M4 redefinido («Cómo llegar» hacia app de Google Maps) o firma de release para producción.

## 1. Hecho — no reabrir

| ID / Componente | Qué se implementó | Prueba / Evidencia |
| --- | --- | --- |
| A1 / A1.3 | Propietario + RLS murales + foto segura al editar | Pruebas históricas 007–009. |
| A2 | Perfil + trigger on_auth_user_created | Prueba 010. |
| A3 | Atribución «Subido por» en fichas | Prueba 013. |
| M1 | Contraseña segura + checklist interactivo | Pruebas M1-01…09. |
| DT1 | Limpieza en Storage ante fallo de INSERT (rollback) | Pruebas DT1-01/02. |
| DT2 | Avatar seguro (rollback en Storage) | Pruebas DT2-01…05. |
| M2 | OTP + SMTP Resend con cooldown de 60 s | Pruebas M2-01…08. |
| DT3 | RLS auditada en tabla perfiles | Prueba #015. |
| DT4 / DT13 | Errores en español + diálogos de carga protegidos | Pruebas DT4 / DT13. |
| M5 / M10 | GPS no bloqueante + pin central + reajuste manual | Pruebas M5-01…11. |
| B1 | Restricción de listing anónimo en bucket murales | Prueba B1 (data: []). |
| M6 | Centrar mapa en mi ubicación (escenarios principales) | Pruebas M6-01…05 y M6-07. |
| DT4-01 | Borde rojo de contraseña (registro y recuperación) | flutter analyze + 8 pruebas manuales. |
| Storage — nombre | Sanitización compartida y estricta en alta y edición | Prueba con carácter «/» en título. |
| Identidad Android | applicationId y namespace unificados (com.muralitoapp.app) | Verificado en build.gradle.kts y MainActivity.kt. |
| M3 | Onboarding de ubicación persistido con shared_preferences | 4 pruebas manuales validadas. |
| Atribución OSM | Enlace visible y clicable «© Colaboradores de OpenStreetMap» | VALIDADO v16 (flutter analyze + apertura externa). |
| Origen de foto | Modal selector para capturar con cámara o elegir de galería | VALIDADO v16 (4 pruebas manuales PASS). |
| Avisos UI mapa | Banner superior toast unificado en MapaPrincipalPage | VALIDADO v16 (sin SnackBars a media pantalla). |

Estas funcionalidades no deben reabrirse salvo evidencia de regresión técnica o cambios regulatorios externos.

## 2. Cierres formales de la versión 16

### 2.1 Atribución visible de OpenStreetMap
**Implementación:** Integración de un widget ligero Align(alignment: Alignment.bottomLeft) en mapa_principal_page.dart y ajustar_ubicacion_page.dart.
**Cumplimiento:** Despliega de forma limpia © Colaboradores de OpenStreetMap y abre mediante url_launcher la URL oficial de copyright ([https://www.openstreetmap.org/copyright](https://www.openstreetmap.org/copyright)). Se descartó el prefijo redundante flutter_map | para mayor prolijidad de interfaz.
**Estado:** VALIDADO (Cerrado).

### 2.2 Selección de origen de imagen en «Nuevo Mural»
**Implementación:** Modal inferior en _iniciarFlujoNuevoMural() que permite optar entre:
* Icons.photo_camera_outlined → Cámara nativa (ImageSource.camera).
* Icons.photo_library_outlined → Galería de imágenes (ImageSource.gallery).

**Comportamiento:** Si el usuario descarta el modal o cancela dentro de la galería/cámara, el flujo regresa al mapa sin errores ni disparar diálogos secundarios. Al elegir imagen, el flujo M3 y el ajuste de pin continúan de forma automática.

**Estado de pruebas:**
* Prueba 1 (Cancelación del menú modal): PASS.
* Prueba 2 (Cámara activa y captura normal): PASS.
* Prueba 3 (Cancelación dentro de la galería): PASS.
* Prueba 4 (Flujo completo con imagen seleccionada de galería): PASS.

**Estado:** VALIDADO (Cerrado).

### 2.3 Sistema de avisos y controles flotantes en Mapa
**Implementación:** Componente centralizado _AvisoUI en el Stack superior bajo la AppBar para éxito, error e información/GPS con botones interactivos.
**Ajuste visual:** Retiro de paddings excesivos en floatingActionButton, permitiendo que los botones «Nuevo Mural» y «Mi ubicación» descansen de forma natural en la esquina inferior derecha sin interferir con la atribución en la izquierda.
**Estado:** VALIDADO (Cerrado).

## 3. Alta de mural — Producto

**A4 — Autor de la obra ≠ Usuario que sube**
**Objetivo:** Diferenciar formalmente en base de datos e interfaz entre el usuario que toma la fotografía/registra y el artista autor de la pintura.
**Requisito previo:** Definir modelo de datos, campos opcionales y posibles mecanismos de reclamo de autoría.
**Estado:** PENDIENTE (Producto).

**A1.4 — Historial de fotos**
**Criterio de producto definido:** La fotografía previa no se purga inmediatamente; se mantiene una ventana de 6 días para revertir cambios o hasta confirmación explícita del usuario. En la app se visualizará como galería de versiones.
**Impacto técnico:** Requerirá tabla relacional en PostgreSQL, reglas de retención y revisión de borrado en subrutas de Storage (DT8).
**Estado:** PENDIENTE (Producto — criterio definido, sin implementar).

**M17 — Sistema de borradores y reintento de subida offline [NUEVO v16]**
**Objetivo:** Si un usuario completa el registro de un mural y la subida falla por pérdida de cobertura o error de red, la aplicación debe resguardar un borrador local para reintentar la publicación sin perder la fotografía ni los textos ingresados.
**Requisitos técnicos definidos:**
* Persistir la imagen física en almacenamiento local duradero (getApplicationDocumentsDirectory con path_provider) y no en la caché volátil de image_picker.
* Estructura de persistencia local (JSON en disco o SQLite local) con metadatos: coordenadas, título, descripción, ruta de imagen y marca temporal.
* Ciclo de vida: purgar el archivo local únicamente cuando el mural se confirme en Supabase o el usuario descarte voluntariamente el borrador.
**Clasificación:** Mejora de resiliencia / Offline-first.
**Estado:** PENDIENTE (Post-v1).

## 4. Cuentas y Autenticación restantes

| ID | Tarea | Estado |
| --- | --- | --- |
| M9 | Leaked Password Protection (HIBP) | BLOQUEADO (Requiere Supabase Pro) |
| Autovalidate correo | Limpieza reactiva de error al escribir en campo de email | PENDIENTE (UX — Prioridad Inmediata) |
| UX-AUTH-01…05 | Alternar visibilidad de contraseña, reenvío de confirmación | PENDIENTE |
| SMTP dominio propio | Configurar y verificar dominio propio en Resend para testers | PENDIENTE (Antes de testers externos) |
| Eliminar cuenta | Borrado seguro de cuenta y registros asociados | FUTURO |

## 5. Mejoras de producto — Mapa y UX

| ID | Mejora | Estado |
| --- | --- | --- |
| M3 | Onboarding de ubicación explicativo y persistido | VALIDADO (v15) |
| M4 (redefinido) | Botón «Cómo llegar» invocando app nativa de Google Maps | PENDIENTE |
| M6 | Centrar en mi ubicación (M6-01…05 y M6-07 PASS) | VALIDADO PARCIAL (M6-06 sin verificar) |
| M7 | Visor de imagen con pinch-to-zoom en ficha de detalle | PENDIENTE |
| M8 | Perfil público de muralista | PENDIENTE |
| M11–M16 | Animación de marcadores, spiderfy, recorte y avisos de versión | PENDIENTE |
| B2–B7 | Bio en perfil, login social, límite de cambios de apodo | PENDIENTE (Baja prioridad) |

## 6. Deuda técnica restante

**DT5–DT9 (Bajo nivel y arquitectura menor)**
Auditoría puntual de serialización fromMap, gestión de rutas en Storage y passthrough de AuthGate.
**Estado:** POSPUESTO por decisión de producto en favor de mejoras funcionales directas.

**DT8 (Subrutas en Storage)**
borrarFotoDeStorage() toma el último segmento de la URL (uri.pathSegments.last). Mientras el bucket murales conserve almacenamiento plano no falla; requerirá refactor cuando se implemente A1.4.
**Estado:** RIESGO TÉCNICO.

**DT10–DT12 (Desacoplamiento arquitectónico)**
mapa_principal_page.dart concentra mapa, persistencia, clustering, auth listener y modales.
**Estado:** NO AHORA. No se realizarán refactorizaciones globales sin un bloqueo funcional concreto.

**Colores hardcodeados**
~53 referencias a Colors.deepPurple distribuidas en 8 archivos.
**Estado:** PENDIENTE (Deuda de estilo). Migrar gradualmente hacia Theme.of(context).colorScheme.

**DT14–DT18 (Testing automatizado y escalabilidad)**
Ausencia de suite automatizada de pruebas unitarias o de widgets.
Clustering _agruparMuralesCercanos() con complejidad computacional O(n²).
**Estado:** PENDIENTE.

## 7. Hallazgos pendientes para publicación (Release)

**Firma de compilación Release:**
android/app/build.gradle.kts mantiene signingConfig = signingConfigs.getByName("debug") en el bloque release.
Google Play rechaza artefactos con llaves de depuración. Requiere generar un Keystore (.jks) y configurar variables de entorno locales protegidas.
**Estado:** PENDIENTE (Bloqueante para Play Store).

**Dominio en Resend:**
Remitente en onboarding@resend.dev. Debe verificarse dominio propio con registros SPF/DKIM antes de abrir la aplicación a evaluadores externos.
**Estado:** PENDIENTE.

## 8. Seguridad actual

| Elemento | Estado | Observación |
| --- | --- | --- |
| RLS en murales | VALIDADO | Permisos delegados a PostgreSQL (auth.uid()). |
| RLS en perfiles | VALIDADO | Lectura pública; modificación por propietario; DELETE denegado. |
| Storage: Listing anónimo | VALIDADO | Bloqueado mediante B1; URLs públicas operativas. |
| Storage: Subida y borrado | VALIDADO | Subida autenticada; borrado por propietario (owner = auth.uid()). |
| Rollback de Storage | VALIDADO | DT1 y DT2 operativos en alta y edición. |
| Inmutabilidad de pin | VALIDADO | Coordenadas no editables tras la publicación inicial. |
| Anti-enumeración Auth | VALIDADO | DT4-02 implementado para cuentas preexistentes. |
| Atribución OSM | VALIDADO | Cumplimiento estricto de la política de tiles de OSM. |
| Identidad Android | VALIDADO | com.muralitoapp.app alineado en Gradle y Kotlin. |
| Firma de release | PENDIENTE | Bloqueante para publicación final. |
| HIBP / Passwords filtradas | BLOQUEADO | Requiere plan Supabase Pro (M9). |

## 9. Estado resumido del backlog

| Tarea / ID | Estado |
| --- | --- |
| Atribución visible OSM | VALIDADO (v16) |
| Origen foto (Cámara / Galería) | VALIDADO (v16) |
| Avisos UI mapa (Toast superior) | VALIDADO (v16) |
| M5 / M10 (GPS + pin en alta) | VALIDADO |
| B1 (Restricción Storage) | VALIDADO |
| M3 (Onboarding de ubicación) | VALIDADO |
| M6 (Centrar mi ubicación) | VALIDADO (M6-06 sin verificar) |
| DT4-01 (Borde rojo contraseña) | VALIDADO |
| Identidad Android (com.muralitoapp.app) | VALIDADO |
| Autovalidate campo correo | PENDIENTE (UX) |
| M4 redefinido (Google Maps) | PENDIENTE (Producto) |
| Firma de release (Keystore) | PENDIENTE (Bloqueante Play Store) |
| Colores hardcodeados | PENDIENTE (Estilo) |
| A4 (Autor obra ≠ Uploader) | PENDIENTE (Producto) |
| A1.4 (Historial fotos) | PENDIENTE (Producto) |
| M17 (Borradores y subida offline) | PENDIENTE (Post-v1) |
| DT5–DT9 | POSPUESTO |
| DT10–DT12 | NO AHORA |
| DT14–DT18 | PENDIENTE |
| M9 (Leaked Passwords) | BLOQUEADO (Supabase Pro) |
| Resend dominio propio | PENDIENTE |

## 10. Próximo objetivo técnico

Con los ítems cerrados en esta sesión (Atribución OSM, selector Cámara/Galería, sistema de avisos UI y formalización de identidad Android), los candidatos prioritarios para continuar el desarrollo son:

**Autovalidate en campo «Correo electrónico»:**
* **Alcance:** Replicar el patrón probado de DT4-01 en auth_page.dart (y recuperar_password_page.dart) para limpiar el borde rojo y mensaje de error reactivamente mientras el usuario escribe la corrección. Tarea acotada y de bajo riesgo.

**M4 Redefinido («Cómo llegar» hacia app nativa):**
* **Alcance:** Modificar _abrirComoLlegar para que invoque Google Maps (geo: o [https://www.google.com/maps/dir/?api=1&destination=lat,lng](https://www.google.com/maps/dir/?api=1&destination=lat,lng)), manteniendo intacto OpenStreetMap en la app.

**Firma de compilación Release:**
* **Alcance:** Generación del almacén de claves Keystore (.jks), configuración de key.properties y actualización del bloque signingConfigs en android/app/build.gradle.kts.

## 11. Control de versión

**Documento:** Mejoras_v16
**Fecha:** 26/09/2026
**Sustituye a:** Mejoras_v15

**Resumen de cambios:**
* Atribución de OpenStreetMap movida a «Hecho — no reabrir» tras su implementación y validación.
* Cierre formal de la funcionalidad de selección de imagen (Cámara o Galería) con evidencia de 4 pruebas manuales PASS.
* Cierre formal del sistema de notificaciones mediante toast superior y reposicionamiento de controles en el mapa.
* Registro de la identidad Android (namespace y applicationId) unificada en com.muralitoapp.app.
* Incorporación de M17 (Borradores y reintento offline) al backlog de producto para etapas posteriores a la v1.
* Reordenamiento de candidatos inmediatos para las próximas sesiones.