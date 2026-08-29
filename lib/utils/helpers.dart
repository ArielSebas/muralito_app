import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_client.dart';

/// Muestra un selector para elegir la fuente de una foto (cámara o
/// galería) y devuelve el archivo elegido, o null si el usuario cancela.
Future<XFile?> elegirFuenteFoto(BuildContext context) async {
  final ImageSource? origen = await showModalBottomSheet<ImageSource>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Tomar foto'),
            onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Elegir de galería'),
            onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
          ),
        ],
      ),
    ),
  );

  if (origen == null) return null;

  return ImagePicker().pickImage(
    source: origen,
    maxWidth: 1920,
    maxHeight: 1920,
    imageQuality: 85,
  );
}

/// Intenta borrar una foto del bucket "murales" a partir de su URL
/// pública. Es un intento best-effort: si falla, no interrumpe el flujo
/// principal (en el peor caso queda un archivo huérfano recuperable
/// manualmente desde el dashboard de Supabase).
Future<void> borrarFotoDeStorage(String fotoUrl) async {
  try {
    // Extraer nombre de archivo, quitando query params si los hay
    final Uri uri = Uri.parse(fotoUrl);
    final String nombreArchivo = uri.pathSegments.last;

    debugPrint('🗑️ Intentando borrar de Storage: $nombreArchivo');

    await supabase.storage.from('murales').remove([nombreArchivo]);

    debugPrint('✅ Foto borrada de Storage: $nombreArchivo');
  } catch (e) {
    debugPrint('⚠️ No se pudo borrar foto de Storage: $e');
    // Best-effort: no bloquea el flujo si falla.
  }
}

/// Convierte un error técnico en un mensaje corto y amigable para
/// mostrar en pantalla. El detalle completo (URLs, stacktrace, etc.)
/// queda solo en la consola de depuración, nunca en la interfaz.
String mensajeErrorAmigable(Object error) {
  debugPrint('Error técnico: $error');

  final String texto = error.toString().toLowerCase();

  if (texto.contains('socketexception') ||
      texto.contains('failed host lookup') ||
      texto.contains('network is unreachable') ||
      texto.contains('connection refused') ||
      texto.contains('timeout')) {
    return 'Sin conexión a internet. Verifica tu red e inténtalo de nuevo.';
  }

  if (error is StorageException) {
    return 'No se pudo subir la foto. Inténtalo de nuevo.';
  }

  if (error is PostgrestException) {
    return 'No se pudo guardar el cambio. Inténtalo de nuevo.';
  }

  return 'Ocurrió un error inesperado. Inténtalo de nuevo.';
}
