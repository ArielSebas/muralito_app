import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_client.dart';
import '../widgets/dialogo_carga.dart';

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

/// Muestra un SnackBar flotante con estilo consistente en toda la app:
/// rojo para errores, verde para confirmaciones.
void mostrarSnackBar(
  BuildContext context,
  String mensaje, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensaje),
      backgroundColor: isError ? Colors.red[700] : Colors.green[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ),
  );
}

/// Traduce los errores de Supabase Auth más comunes al español.
///
/// Si el mensaje indica un límite de espera ("...after N seconds"),
/// también devuelve esos N segundos para que el llamador pueda
/// sincronizar un cooldown visual con el valor real del servidor, en
/// vez de dejar el botón habilitado para un reintento que el servidor
/// va a rechazar igual.
///
/// Los mensajes que no se reconocen NO se muestran crudos al usuario:
/// se devuelve un texto genérico en español y el original queda solo
/// en la consola de depuración.
///
/// El orden de las comprobaciones importa: los mensajes específicos se
/// evalúan antes que los patrones genéricos ("invalid"/"expired"), para
/// que "Invalid login credentials" no se confunda con un código OTP
/// incorrecto.
({String mensaje, int? segundosDeEspera}) traducirErrorAuth(
  AuthException error,
) {
  final texto = error.message.toLowerCase();

  // Límite de frecuencia reportado por el servidor
  // ("you can only request this after N seconds").
  final coincidenciaEspera = RegExp(r'after (\d+) seconds?').firstMatch(texto);
  if (coincidenciaEspera != null) {
    final segundos = int.tryParse(coincidenciaEspera.group(1)!) ?? 60;
    return (
      mensaje:
          'Por seguridad, espera $segundos segundos antes de pedir otro código.',
      segundosDeEspera: segundos,
    );
  }

  if (texto.contains('invalid login credentials') ||
      texto.contains('invalid_credentials')) {
    return (
      mensaje: 'Correo o contraseña incorrectos.',
      segundosDeEspera: null,
    );
  }

  if (texto.contains('email not confirmed')) {
    return (
      mensaje:
          'Debes confirmar tu correo antes de iniciar sesión. '
          'Revisa tu bandeja de entrada.',
      segundosDeEspera: null,
    );
  }

  if (texto.contains('already registered')) {
    return (
      mensaje: 'Ya existe una cuenta con este correo. Inicia sesión.',
      segundosDeEspera: null,
    );
  }

  if (texto.contains('too many requests')) {
    return (
      mensaje: 'Demasiados intentos. Espera un momento e inténtalo de nuevo.',
      segundosDeEspera: null,
    );
  }

  if (texto.contains('should be different')) {
    return (
      mensaje: 'La nueva contraseña debe ser diferente de la anterior.',
      segundosDeEspera: null,
    );
  }

  // Código OTP incorrecto o expirado. Solo llegamos aquí si el mensaje
  // no fue reconocido como ninguno de los casos anteriores.
  if (texto.contains('expired') || texto.contains('invalid')) {
    return (
      mensaje: 'El código es incorrecto o ya expiró. Solicita uno nuevo.',
      segundosDeEspera: null,
    );
  }

  debugPrint('⚠️ Mensaje de Auth no mapeado: ${error.message}');
  return (
    mensaje: 'No se pudo completar la operación. Inténtalo de nuevo.',
    segundosDeEspera: null,
  );
}

/// Convierte un error técnico en un mensaje corto y amigable para
/// mostrar en pantalla. El detalle completo (URLs, stacktrace, etc.)
/// queda solo en la consola de depuración, nunca en la interfaz.
///
/// Los errores de Supabase Auth se traducen mediante
/// [traducirErrorAuth], de modo que ningún mensaje en inglés llegue
/// crudo al usuario.
String mensajeErrorAmigable(Object error) {
  debugPrint('Error técnico: $error');

  if (error is AuthException) {
    return traducirErrorAuth(error).mensaje;
  }

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

/// Ejecuta [trabajo] mostrando un [DialogoCarga] mientras tanto.
///
/// El diálogo se cierra exactamente una vez al terminar [trabajo], sea
/// éxito o error, incluso si el widget que llamó se desmontó a mitad del
/// proceso: la ruta del diálogo vive en el navegador raíz, independiente
/// del widget llamador. Si [trabajo] lanza una excepción, ésta se
/// re-lanza para que el llamador decida cómo mostrarla.
///
/// Convención de la app (DT4/DT13): spinner en el botón para acciones
/// cortas (auth), DialogoCarga para operaciones multi-paso
/// (Storage + PostgreSQL).
Future<T?> conDialogoCarga<T>(
  BuildContext context, {
  required Future<T> Function() trabajo,
  String mensaje = 'Guardando...',
  String submensaje = 'Conectando con la nube',
}) async {
  // Se captura antes de cualquier await: si el widget se desmonta, su
  // BuildContext queda inválido, pero el NavigatorState del raíz sigue
  // vivo y puede cerrar el diálogo.
  final navigator = Navigator.of(context, rootNavigator: true);

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => DialogoCarga(mensaje: mensaje, submensaje: submensaje),
  );

  var cerrado = false;
  void cerrar() {
    if (cerrado) return;
    cerrado = true;
    // Esperar al próximo frame evita cerrar el diálogo antes de que
    // termine de construirse.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigator.mounted) navigator.pop();
    });
  }

  try {
    return await trabajo();
  } finally {
    cerrar();
  }
}
