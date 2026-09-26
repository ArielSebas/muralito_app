import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

import '../services/ubicacion_service.dart';
import 'package:latlong2/latlong.dart';

/// M5 — confirmar o ajustar el pin al **registrar** un mural.
///
/// El pin queda en el centro de la pantalla; el usuario mueve el mapa
/// (estilo Uber). Al confirmar se usa `camera.center`.
///
/// No se usa al editar un mural ya publicado: mover la ubicación después
/// del alta queda fuera de M5 (riesgo de coordenadas falsas). Cuando exista
/// historial de fotos (A1.4), la ubicación de la versión actual se
/// considerará congelada.
class AjustarUbicacionPage extends StatefulWidget {
  final LatLng inicial;
  final String? aviso;
  final bool intentarGpsAlAbrir;

  const AjustarUbicacionPage({
    super.key,
    required this.inicial,
    this.aviso,
    this.intentarGpsAlAbrir = true,
  });

  @override
  State<AjustarUbicacionPage> createState() => _AjustarUbicacionPageState();
}

class _AjustarUbicacionPageState extends State<AjustarUbicacionPage> {
  final MapController _mapController = MapController();
  late LatLng _punto;
  String? _aviso;
  bool _buscandoGps = false;
  _EstadoGps _estadoGps = _EstadoGps.desconocido;

  @override
  void initState() {
    super.initState();
    _punto = widget.inicial;
    _aviso = widget.aviso;
    if (widget.intentarGpsAlAbrir) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reintentarGps();
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _actualizarPunto(LatLng centro) {
    if (_punto.latitude == centro.latitude &&
        _punto.longitude == centro.longitude) {
      return;
    }
    setState(() => _punto = centro);
  }

  String get _etiquetaBotonGps {
    switch (_estadoGps) {
      case _EstadoGps.apagado:
        return 'Activar GPS';
      case _EstadoGps.sinPermiso:
        return 'Permitir ubicación';
      case _EstadoGps.bloqueado:
        return 'Abrir ajustes';
      case _EstadoGps.sinSenal:
        return 'Reintentar GPS';
      case _EstadoGps.listo:
      case _EstadoGps.desconocido:
        return 'Usar GPS';
    }
  }

  IconData get _iconoBotonGps {
    switch (_estadoGps) {
      case _EstadoGps.apagado:
      case _EstadoGps.sinPermiso:
      case _EstadoGps.bloqueado:
        return Icons.location_disabled_outlined;
      default:
        return Icons.my_location;
    }
  }

  Future<void> _alPulsarGps() async {
    if (_buscandoGps) return;
    if (_estadoGps == _EstadoGps.apagado) {
      await Geolocator.openLocationSettings();
    } else if (_estadoGps == _EstadoGps.bloqueado) {
      await Geolocator.openAppSettings();
    }
    if (!mounted) return;
    await _reintentarGps();
  }

  Future<void> _reintentarGps() async {
    if (_buscandoGps) return;
    setState(() => _buscandoGps = true);

    try {
      final resultado = await const UbicacionService().obtenerUbicacion();

      if (!mounted) return;

      if (resultado.posicion != null) {
        final gps = LatLng(
          resultado.posicion!.latitude,
          resultado.posicion!.longitude,
        );
        try {
          _mapController.move(gps, 17);
        } catch (_) {}

        if (resultado.estado == EstadoUbicacion.sinSenal) {
          setState(() {
            _punto = gps;
            _estadoGps = _EstadoGps.sinSenal;
            _aviso =
                'No hay GPS actual. Te dejé en la última ubicación conocida; ajústala si hace falta.';
            _buscandoGps = false;
          });
          return;
        }

        setState(() {
          _punto = gps;
          _aviso = null;
          _estadoGps = _EstadoGps.listo;
          _buscandoGps = false;
        });
        return;
      }

      switch (resultado.estado) {
        case EstadoUbicacion.gpsApagado:
          setState(() {
            _estadoGps = _EstadoGps.apagado;
            _aviso =
                'El GPS está apagado. Pulsa «Activar GPS» o coloca el pin a mano.';
            _buscandoGps = false;
          });
          return;
        case EstadoUbicacion.permisoDenegado:
          setState(() {
            _estadoGps = _EstadoGps.sinPermiso;
            _aviso =
                'Necesitamos permiso de ubicación. Pulsa «Permitir ubicación» o coloca el pin a mano.';
            _buscandoGps = false;
          });
          return;
        case EstadoUbicacion.permisoBloqueado:
          setState(() {
            _estadoGps = _EstadoGps.bloqueado;
            _aviso =
                'El permiso está bloqueado. Pulsa «Abrir ajustes» para activarlo, o coloca el pin a mano.';
            _buscandoGps = false;
          });
          return;
        case EstadoUbicacion.sinSenal:
          setState(() {
            _estadoGps = _EstadoGps.sinSenal;
            _aviso =
                'No hay señal GPS. Te dejé en el mapa; mueve el pin hasta el mural.';
            _buscandoGps = false;
          });
          return;
        case EstadoUbicacion.listo:
          break;
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _estadoGps = _EstadoGps.sinSenal;
        _aviso =
            'No hay señal GPS. Te dejé en el mapa; mueve el pin hasta el mural.';
        _buscandoGps = false;
      });
    }
  }

  void _confirmar() {
    LatLng centro;
    try {
      centro = _mapController.camera.center;
    } catch (_) {
      centro = _punto;
    }
    Navigator.of(context).pop(centro);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación del mural'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancelar',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.inicial,
              initialZoom: 17,
              minZoom: 6,
              maxZoom: 18,
              backgroundColor: const Color(0xFFE8E4DC),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.flingAnimation,
              ),
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) _actualizarPunto(camera.center);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.muralitoapp.app',
                maxNativeZoom: 19,
                keepBuffer: 1,
                panBuffer: 1,
              ),
            ],
          ),

          // Pin fijo en el centro: el mapa se mueve debajo.
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 36),
                child: Icon(
                  Icons.location_on,
                  size: 48,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),

          if (_aviso != null)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Card(
                color: Colors.amber[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber[900]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _aviso!,
                          style: TextStyle(
                            color: Colors.amber[900],
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _aviso = null),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          if (_buscandoGps)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x33000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mueve el mapa hasta que el pin quede sobre el mural.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 6),
              Text(
                'Lat ${_punto.latitude.toStringAsFixed(5)}  ·  '
                'Lng ${_punto.longitude.toStringAsFixed(5)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _buscandoGps ? null : _alPulsarGps,
                      icon: Icon(_iconoBotonGps),
                      label: Text(_etiquetaBotonGps),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _buscandoGps ? null : _confirmar,
                      icon: const Icon(Icons.check),
                      label: const Text('Usar esta ubicación'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _EstadoGps { desconocido, listo, apagado, sinPermiso, bloqueado, sinSenal }