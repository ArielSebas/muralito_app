import 'package:geolocator/geolocator.dart';

/// Resultado de una consulta de ubicación, sin acoplar la lógica GPS a una UI.
class ResultadoUbicacion {
  final Position? posicion;
  final EstadoUbicacion estado;

  const ResultadoUbicacion({required this.posicion, required this.estado});
}

enum EstadoUbicacion {
  listo,
  gpsApagado,
  permisoDenegado,
  permisoBloqueado,
  sinSenal,
}

/// Servicio pequeño para centralizar la comprobación de GPS/permisos y la
/// obtención puntual de la ubicación.
class UbicacionService {
  const UbicacionService();

  Future<ResultadoUbicacion> obtenerUbicacion() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return const ResultadoUbicacion(
        posicion: null,
        estado: EstadoUbicacion.gpsApagado,
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return const ResultadoUbicacion(
        posicion: null,
        estado: EstadoUbicacion.permisoDenegado,
      );
    }

    if (permission == LocationPermission.deniedForever) {
      return const ResultadoUbicacion(
        posicion: null,
        estado: EstadoUbicacion.permisoBloqueado,
      );
    }

    try {
      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return ResultadoUbicacion(
        posicion: posicion,
        estado: EstadoUbicacion.listo,
      );
    } catch (_) {
      Position? ultima;
      try {
        ultima = await Geolocator.getLastKnownPosition();
      } catch (_) {
        ultima = null;
      }

      return ResultadoUbicacion(
        posicion: ultima,
        estado: EstadoUbicacion.sinSenal,
      );
    }
  }
}
