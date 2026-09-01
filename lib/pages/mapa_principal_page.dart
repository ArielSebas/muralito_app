import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_client.dart';
import '../models/mural.dart';
import '../models/perfil.dart';
import '../utils/helpers.dart';
import '../widgets/dialogo_carga.dart';
import '../widgets/formulario_mural_modal.dart';
import '../widgets/editar_mural_modal.dart';
import '../widgets/editar_perfil_modal.dart';
import 'auth_page.dart';

class MapaPrincipalPage extends StatefulWidget {
  const MapaPrincipalPage({super.key});

  @override
  State<MapaPrincipalPage> createState() => _MapaPrincipalPageState();
}

class _MapaPrincipalPageState extends State<MapaPrincipalPage> {
  final MapController _mapController = MapController();
  final List<Mural> _murales = [];
  Perfil? _perfilActual;
  bool _cargandoMurales = true;
  String? _errorMurales;
  bool _mapaInteractivo = true;
  StreamSubscription<AuthState>? _authSub;

  bool get _haySesion => supabase.auth.currentUser != null;

  @override
  void initState() {
    super.initState();
    _cargarMurales();
    _cargarPerfilActual();
    _authSub = supabase.auth.onAuthStateChange.listen((_) {
      if (mounted) {
        _cargarPerfilActual();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  /// Consulta el perfil del usuario autenticado actual desde Supabase
  Future<void> _cargarPerfilActual() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _perfilActual = null);
      return;
    }

    try {
      final res = await supabase
          .from('perfiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (res != null && mounted) {
        setState(() => _perfilActual = Perfil.fromMap(res));
      }
    } catch (_) {
      // Best-effort: si falla la consulta, se mantiene el estado previo
    }
  }

  Future<void> _abrirEditarPerfil() async {
    final user = supabase.auth.currentUser;
    if (user == null || _perfilActual == null) return;

    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditarPerfilModal(perfil: _perfilActual!),
    );

    if (resultado == true) {
      await _cargarPerfilActual();
      if (mounted) {
        _mostrarSnackBar('✅ Perfil actualizado correctamente.');
      }
    }
  }

  /// Consulta los murales desde Supabase y actualiza el estado
  Future<void> _cargarMurales() async {
    setState(() {
      _cargandoMurales = true;
      _errorMurales = null;
    });

    try {
      final response = await supabase
          .from('murales')
          .select()
          .order('created_at', ascending: false);

      final List<Mural> muralesCargados = (response as List)
          .map((m) => Mural.fromMap(m))
          .toList();

      setState(() {
        _murales.clear();
        _murales.addAll(muralesCargados);
        _cargandoMurales = false;
      });
    } catch (e) {
      setState(() {
        _errorMurales = mensajeErrorAmigable(e);
        _cargandoMurales = false;
      });
    }
  }

  /// Distancia máxima (en metros) entre dos murales para considerarlos
  /// parte del mismo cluster. Ajustable según qué tan "cercanos" deban estar.
  static const double _radioClusterMetros = 30;

  /// Agrupa los murales cuya distancia real (GPS) sea menor o igual al
  /// radio definido en [_radioClusterMetros]. Un grupo de un solo mural
  /// se representa luego como pin individual; de dos o más, como cluster.
  List<List<Mural>> _agruparMuralesCercanos() {
    const Distance calculadora = Distance();
    final List<Mural> pendientes = List.of(_murales);
    final List<List<Mural>> grupos = [];

    while (pendientes.isNotEmpty) {
      final Mural base = pendientes.removeAt(0);
      final List<Mural> grupo = [base];

      pendientes.removeWhere((mural) {
        final double metros = calculadora(
          LatLng(base.latitud, base.longitud),
          LatLng(mural.latitud, mural.longitud),
        );
        if (metros <= _radioClusterMetros) {
          grupo.add(mural);
          return true;
        }
        return false;
      });

      grupos.add(grupo);
    }

    return grupos;
  }

  /// Calcula el punto central (promedio) de un grupo de murales.
  LatLng _centroDelGrupo(List<Mural> grupo) {
    final double lat =
        grupo.map((m) => m.latitud).reduce((a, b) => a + b) / grupo.length;
    final double lng =
        grupo.map((m) => m.longitud).reduce((a, b) => a + b) / grupo.length;
    return LatLng(lat, lng);
  }

  /// Construye la lista de marcadores para flutter_map, agrupando en
  /// clusters los murales que estén muy cerca entre sí.
  List<Marker> _buildMarkers() {
    final List<List<Mural>> grupos = _agruparMuralesCercanos();

    return grupos.map((grupo) {
      if (grupo.length == 1) {
        final mural = grupo.first;
        return Marker(
          point: LatLng(mural.latitud, mural.longitud),
          width: 50,
          height: 50,
          child: GestureDetector(
            onTap: () => _mostrarDetalleMural(mural),
            child: _pinMural(),
          ),
        );
      }

      return Marker(
        point: _centroDelGrupo(grupo),
        width: 54,
        height: 54,
        child: GestureDetector(
          onTap: () {
            _zoomHaciaGrupo(grupo);
            _mostrarGrupoMurales(grupo);
          },
          child: _pinCluster(grupo.length),
        ),
      );
    }).toList();
  }

  /// Acerca el mapa hacia el centro de un grupo de murales al tocar su
  /// cluster. Como el agrupamiento es por distancia GPS real (no por
  /// píxeles), el zoom no separa los pines si siguen dentro del radio de
  /// [_radioClusterMetros]; esto solo da contexto visual de la zona antes
  /// de abrir la lista seleccionable.
  void _zoomHaciaGrupo(List<Mural> grupo) {
    final LatLng centro = _centroDelGrupo(grupo);
    final double zoomActual = _mapController.camera.zoom;
    final double nuevoZoom = (zoomActual + 2).clamp(6.0, 18.0);
    _mapController.move(centro, nuevoZoom);
  }

  /// Pin morado con ícono de pincel para un mural individual (mismo estilo
  /// visual que se usaba antes de introducir el clustering).
  Widget _pinMural() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(Icons.brush, color: Colors.white, size: 24),
    );
  }

  /// Pin de cluster: círculo morado con la cantidad de murales agrupados.
  /// El tono se oscurece un poco si el grupo es más grande, como pista
  /// visual rápida para el usuario.
  Widget _pinCluster(int cantidad) {
    final Color color = cantidad < 5
        ? Colors.deepPurple
        : cantidad < 10
        ? Colors.deepPurple[700]!
        : Colors.deepPurple[900]!;

    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          cantidad.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  /// Muestra una lista con los murales de un cluster para que el usuario
  /// elija cuál quiere ver en detalle (cubre el caso de murales tan cercanos
  /// que ni haciendo zoom se separan visualmente).
  Future<void> _mostrarGrupoMurales(List<Mural> grupo) async {
    setState(() => _mapaInteractivo = false);

    final Mural? elegido = await showModalBottomSheet<Mural>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  '${grupo.length} murales en este punto',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...grupo.map((mural) {
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: mural.fotoUrl != null && mural.fotoUrl!.isNotEmpty
                          ? Image.network(
                              mural.fotoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  title: Text(mural.titulo),
                  subtitle:
                      mural.descripcion != null &&
                          mural.descripcion!.trim().isNotEmpty
                      ? Text(
                          mural.descripcion!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  onTap: () => Navigator.of(ctx).pop(mural),
                );
              }),
            ],
          ),
        );
      },
    );

    if (elegido != null) {
      await _mostrarDetalleMural(elegido);
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _mapaInteractivo = true);
  }

  Future<void> _editarMural(Mural mural) async {
    final usuarioActual = supabase.auth.currentUser;

    // Protección adicional en la interfaz.
    // La seguridad real sigue estando en RLS.
    if (usuarioActual == null || mural.userId != usuarioActual.id) {
      _mostrarSnackBar(
        'No tienes permiso para editar este mural.',
        isError: true,
      );
      return;
    }

    final resultado = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditarMuralModal(mural: mural),
    );

    // Cancelar edición.
    if (resultado == null || !mounted) return;

    final String titulo = resultado['titulo'] as String;
    final String descripcion = resultado['descripcion'] as String;
    final String? nuevaFotoPath = resultado['nuevaFotoPath'] as String?;
    final int rotacion = resultado['rotacion'] as int? ?? 0;

    // ── Caso simple: no se cambió la foto ──
    // Mismo comportamiento que antes, no toca Storage.
    if (nuevaFotoPath == null) {
      try {
        await supabase
            .from('murales')
            .update({
              'titulo': titulo,
              'descripcion': descripcion.isEmpty ? null : descripcion,
            })
            .eq('id', mural.id!)
            .eq('user_id', usuarioActual.id);

        await _cargarMurales();
        if (!mounted) return;
        _mostrarSnackBar('✅ Mural "$titulo" actualizado correctamente.');
      } on PostgrestException catch (e) {
        if (!mounted) return;
        _mostrarSnackBar('❌ ${mensajeErrorAmigable(e)}', isError: true);
      } catch (e) {
        if (!mounted) return;
        _mostrarSnackBar('❌ ${mensajeErrorAmigable(e)}', isError: true);
      }
      return;
    }

    // ── Caso con foto nueva: comprimir → subir con nombre nuevo →
    // actualizar → solo si todo salió bien, borrar la foto anterior ──
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const DialogoCarga(
        mensaje: 'Guardando cambios...',
        submensaje: 'Comprimiendo y subiendo la nueva foto',
      ),
    );

    String nuevaFotoUrl;
    try {
      final Uint8List? imagenComprimida =
          await FlutterImageCompress.compressWithFile(
            nuevaFotoPath,
            minWidth: 1200,
            minHeight: 1200,
            quality: 80,
            rotate: rotacion,
            autoCorrectionAngle: true,
          );

      if (imagenComprimida == null) {
        throw Exception('No se pudo comprimir la imagen');
      }

      final String nombreArchivo =
          '${DateTime.now().millisecondsSinceEpoch}_${titulo.replaceAll(' ', '_')}.jpg';

      await supabase.storage
          .from('murales')
          .uploadBinary(
            nombreArchivo,
            imagenComprimida,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      nuevaFotoUrl = supabase.storage
          .from('murales')
          .getPublicUrl(nombreArchivo);
    } catch (e) {
      // Falló la compresión o la subida: no se toca la base de datos,
      // el mural conserva su foto original.
      if (!mounted) return;
      Navigator.of(context).pop(); // Cierra DialogoCarga
      _mostrarSnackBar('❌ ${mensajeErrorAmigable(e)}', isError: true);
      return;
    }

    try {
      await supabase
          .from('murales')
          .update({
            'titulo': titulo,
            'descripcion': descripcion.isEmpty ? null : descripcion,
            'foto_url': nuevaFotoUrl,
          })
          .eq('id', mural.id!)
          .eq('user_id', usuarioActual.id);

      // Éxito: borrar la foto anterior (best-effort).
      if (mural.fotoUrl != null && mural.fotoUrl!.isNotEmpty) {
        await borrarFotoDeStorage(mural.fotoUrl!);
      }

      await _cargarMurales();
      if (!mounted) return;
      Navigator.of(context).pop(); // Cierra DialogoCarga
      _mostrarSnackBar('✅ Mural "$titulo" actualizado correctamente.');
    } catch (e) {
      // El UPDATE falló después de subir la foto nueva: borra la foto
      // recién subida para no dejar un huérfano; el mural conserva su
      // foto original.
      await borrarFotoDeStorage(nuevaFotoUrl);
      if (!mounted) return;
      Navigator.of(context).pop(); // Cierra DialogoCarga
      _mostrarSnackBar('❌ ${mensajeErrorAmigable(e)}', isError: true);
    }
  }

  Future<void> _eliminarMural(Mural mural) async {
    final usuarioActual = supabase.auth.currentUser;

    // Protección adicional en la interfaz.
    // La seguridad real sigue estando en RLS.
    if (usuarioActual == null || mural.userId != usuarioActual.id) {
      _mostrarSnackBar(
        'No tienes permiso para eliminar este mural.',
        isError: true,
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red),
              SizedBox(width: 8),
              Expanded(child: Text('Eliminar mural')),
            ],
          ),
          content: Text(
            '¿Seguro que quieres eliminar "${mural.titulo}"?\n\n'
            'Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.of(ctx).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) return;

    try {
      await supabase
          .from('murales')
          .delete()
          .eq('id', mural.id!)
          .eq('user_id', usuarioActual.id);

      // Borrar la foto del mural de Storage (best-effort)
      if (mural.fotoUrl != null && mural.fotoUrl!.isNotEmpty) {
        await borrarFotoDeStorage(mural.fotoUrl!);
      }

      await _cargarMurales();

      if (!mounted) return;

      _mostrarSnackBar('✅ Mural "${mural.titulo}" eliminado correctamente.');
    } on PostgrestException catch (e) {
      if (!mounted) return;

      _mostrarSnackBar(
        '❌ No se pudo eliminar el mural: ${e.message}',
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      _mostrarSnackBar('❌ ${mensajeErrorAmigable(e)}', isError: true);
    }
  }

  /// Muestra un diálogo con los detalles del mural seleccionado
  /// Ficha de detalle del mural (bottom sheet).
  /// Siempre muestra título, descripción y coordenadas aunque la foto falle.
  Future<void> _mostrarDetalleMural(Mural mural) async {
    final usuarioActual = supabase.auth.currentUser;
    final bool esPropietario =
        usuarioActual != null &&
        mural.userId != null &&
        mural.userId == usuarioActual.id;

    setState(() => _mapaInteractivo = false);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Foto adaptable (nunca bloquea el resto del contenido)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 280),
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: mural.fotoUrl != null && mural.fotoUrl!.isNotEmpty
                          ? Image.network(
                              mural.fotoUrl!,
                              fit: BoxFit.contain,
                              cacheWidth: 900,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  height: 180,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, _, _) => Container(
                                height: 160,
                                color: Colors.grey[200],
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'No se pudo cargar la imagen',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              height: 160,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                    ),
                  ),

                  // Título
                  Text(
                    mural.titulo,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Descripción
                  if (mural.descripcion != null &&
                      mural.descripcion!.trim().isNotEmpty)
                    Text(
                      mural.descripcion!,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Colors.grey[800],
                      ),
                    )
                  else
                    Text(
                      'Sin descripción',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[500],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Coordenadas
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.deepPurple,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Lat: ${mural.latitud.toStringAsFixed(5)}\n'
                            'Lng: ${mural.longitud.toStringAsFixed(5)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (esPropietario) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              _editarMural(mural);
                            },
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Editar'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              _eliminarMural(mural);
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Eliminar'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Cómo llegar
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () =>
                          _abrirComoLlegar(mural.latitud, mural.longitud),
                      icon: const Icon(Icons.directions),
                      label: const Text('Cómo llegar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Cerrar
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _mapaInteractivo = true);
  }

  Future<void> _abrirComoLlegar(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng#map=18/$lat/$lng',
    );
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      _mostrarSnackBar(
        'No se pudo abrir el mapa. Coordenadas: '
        '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
        isError: true,
      );
    }
  }

  /// Flujo completo: cámara → GPS → formulario → subida → refresh
  Future<void> _iniciarFlujoNuevoMural() async {
    if (!_haySesion) {
      await _pedirSesionParaNuevoMural();
      return;
    }

    // 1. Verificar permisos de ubicación
    final permiso = await _verificarPermisosUbicacion();
    if (!permiso) return;

    // 2. Abrir cámara
    final XFile? foto = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (foto == null) return; // Usuario canceló

    // 3. Obtener coordenadas GPS
    Position? posicion;
    try {
      posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _mostrarSnackBar(
        '⚠️ No se pudo obtener la ubicación GPS: $e',
        isError: true,
      );
      return;
    }

    // 4. Abrir modal de formulario
    if (!mounted) return;
    final Map<String, dynamic>? resultado =
        await showModalBottomSheet<Map<String, dynamic>>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => FormularioMuralModal(
            fotoPath: foto.path,
            latitud: posicion!.latitude,
            longitud: posicion.longitude,
          ),
        );

    if (resultado == null) return; // Usuario canceló el formulario

    // 5. Subir imagen y guardar en BD
    await _subirMural(
      foto: foto,
      titulo: resultado['titulo'] as String,
      descripcion: resultado['descripcion'] as String,
      rotacionManual: resultado['rotacion'] as int? ?? 0,
      latitud: posicion.latitude,
      longitud: posicion.longitude,
    );
  }

  Future<void> _pedirSesionParaNuevoMural() async {
    final bool? irARegistro = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Inicia sesión para registrar'),
        content: const Text(
          'Puedes explorar el mapa sin cuenta. '
          'Para subir un mural necesitas iniciar sesión o crear una cuenta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Seguir explorando'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Registrarse'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Iniciar sesión'),
          ),
        ],
      ),
    );

    if (!mounted || irARegistro == null) return;

    final bool? sesionOk = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AuthPage(empezarEnRegistro: irARegistro),
      ),
    );

    if (sesionOk == true && mounted && _haySesion) {
      await _iniciarFlujoNuevoMural();
    }
  }

  Future<void> _abrirAuth({bool registro = false}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AuthPage(empezarEnRegistro: registro)),
    );
  }

  /// Verifica y solicita permisos de ubicación en tiempo de ejecución
  Future<bool> _verificarPermisosUbicacion() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _mostrarSnackBar(
        'Por favor activa el GPS del dispositivo.',
        isError: true,
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _mostrarSnackBar('Permiso de ubicación denegado.', isError: true);
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _mostrarSnackBar(
        'Permiso de ubicación denegado permanentemente. '
        'Actívalo en Configuración del dispositivo.',
        isError: true,
      );
      return false;
    }

    return true;
  }

  /// Comprime la imagen, la sube a Storage y guarda el registro en PostgreSQL
  Future<void> _subirMural({
    required XFile foto,
    required String titulo,
    required String descripcion,
    required int rotacionManual,
    required double latitud,
    required double longitud,
  }) async {
    if (!mounted) return;

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      _mostrarSnackBar(
        'Debes iniciar sesión para registrar un mural.',
        isError: true,
      );
      return;
    }

    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const DialogoCarga(),
    );

    try {
      // ── Compresión de imagen con corrección de orientación ──
      final Uint8List? imagenComprimida =
          await FlutterImageCompress.compressWithFile(
            foto.path,
            minWidth: 1200,
            minHeight: 1200,
            quality: 80,
            rotate: rotacionManual,
            autoCorrectionAngle: true,
          );

      if (imagenComprimida == null) {
        throw Exception('No se pudo comprimir la imagen');
      }

      // ── Subida a Supabase Storage ──
      final String nombreArchivo =
          '${DateTime.now().millisecondsSinceEpoch}_${titulo.replaceAll(' ', '_')}.jpg';

      await supabase.storage
          .from('murales')
          .uploadBinary(
            nombreArchivo,
            imagenComprimida,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      // Obtener URL pública
      final String fotoUrl = supabase.storage
          .from('murales')
          .getPublicUrl(nombreArchivo);

      // ── Insertar registro en PostgreSQL ──
      final nuevoMural = Mural(
        titulo: titulo,
        descripcion: descripcion.isNotEmpty ? descripcion : null,
        fotoUrl: fotoUrl,
        latitud: latitud,
        longitud: longitud,
        userId: userId,
      );

      await supabase.from('murales').insert(nuevoMural.toMap());

      // Cerrar diálogo de carga
      if (!mounted) return;
      Navigator.of(context).pop(); // Cierra DialogoCarga

      _mostrarSnackBar('✅ Mural "$titulo" guardado exitosamente!');

      // Refrescar mapa y centrar en el nuevo mural
      await _cargarMurales();
      _mapController.move(LatLng(latitud, longitud), 16.0);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Cierra DialogoCarga
      _mostrarSnackBar('❌ ${mensajeErrorAmigable(e)}', isError: true);
    }
  }

  void _mostrarSnackBar(String mensaje, {bool isError = false}) {
    if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: _haySesion ? _abrirEditarPerfil : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_haySesion) ...[
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.deepPurple[100],
                    backgroundImage:
                        _perfilActual?.avatarUrl != null &&
                            _perfilActual!.avatarUrl!.isNotEmpty
                        ? NetworkImage(_perfilActual!.avatarUrl!)
                        : null,
                    child:
                        _perfilActual?.avatarUrl == null ||
                            _perfilActual!.avatarUrl!.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 18,
                            color: Colors.deepPurple,
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                ],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Muralito 🎨'),
                    Text(
                      _haySesion
                          ? (_perfilActual?.apodo ?? 'Muralista')
                          : 'Modo espectador',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar murales',
            onPressed: _cargarMurales,
          ),
          if (_haySesion)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
              onPressed: () async {
                await supabase.auth.signOut();
                if (mounted) {
                  _mostrarSnackBar('Sesión cerrada. Sigues viendo el mapa.');
                }
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: 'Iniciar sesión',
              onPressed: () => _abrirAuth(),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(-0.2800, -78.5450),
              initialZoom: 14.0,
              minZoom: 6,
              maxZoom: 18,
              backgroundColor: const Color(0xFFE8E4DC),
              interactionOptions: InteractionOptions(
                flags: _mapaInteractivo
                    ? (InteractiveFlag.all & ~InteractiveFlag.flingAnimation)
                    : InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.muralito_app',
                maxNativeZoom: 19,
                keepBuffer: 1,
                panBuffer: 1,
              ),
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),

          if (_cargandoMurales)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Cargando murales...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (_errorMurales != null && !_cargandoMurales)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMurales!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => setState(() => _errorMurales = null),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _iniciarFlujoNuevoMural,
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Nuevo Mural'),
      ),
    );
  }
}
