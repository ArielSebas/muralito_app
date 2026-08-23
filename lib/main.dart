import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muralito App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MapaPrincipalPage(),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// MODELO DE DATOS
// ──────────────────────────────────────────────────────────────
class Mural {
  final int? id;
  final String titulo;
  final String? descripcion;
  final String? fotoUrl;
  final double latitud;
  final double longitud;
  final DateTime? createdAt;

  Mural({
    this.id,
    required this.titulo,
    this.descripcion,
    this.fotoUrl,
    required this.latitud,
    required this.longitud,
    this.createdAt,
  });

  factory Mural.fromMap(Map<String, dynamic> map) {
    return Mural(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descripcion: map['descripcion'] as String?,
      fotoUrl: map['foto_url'] as String?,
      latitud: (map['latitud'] as num).toDouble(),
      longitud: (map['longitud'] as num).toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'foto_url': fotoUrl,
      'latitud': latitud,
      'longitud': longitud,
    };
  }
}

// ──────────────────────────────────────────────────────────────
// PÁGINA PRINCIPAL: MAPA CON MURALES
// ──────────────────────────────────────────────────────────────
class MapaPrincipalPage extends StatefulWidget {
  const MapaPrincipalPage({super.key});

  @override
  State<MapaPrincipalPage> createState() => _MapaPrincipalPageState();
}

class _MapaPrincipalPageState extends State<MapaPrincipalPage> {
  final MapController _mapController = MapController();
  final List<Mural> _murales = [];
  bool _cargandoMurales = true;
  String? _errorMurales;

  @override
  void initState() {
    super.initState();
    _cargarMurales();
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

      final List<Mural> muralesCargados =
          (response as List).map((m) => Mural.fromMap(m)).toList();

      setState(() {
        _murales.clear();
        _murales.addAll(muralesCargados);
        _cargandoMurales = false;
      });
    } catch (e) {
      setState(() {
        _errorMurales = 'Error al cargar murales: $e';
        _cargandoMurales = false;
      });
    }
  }

  /// Construye la lista de marcadores para flutter_map
  List<Marker> _buildMarkers() {
    return _murales.map((mural) {
      return Marker(
        point: LatLng(mural.latitud, mural.longitud),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () => _mostrarDetalleMural(mural),
          child: Container(
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
            child: const Icon(
              Icons.brush,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Muestra un diálogo con los detalles del mural seleccionado
  /// Ficha de detalle del mural (bottom sheet).
  /// Siempre muestra título, descripción y coordenadas aunque la foto falle.
  void _mostrarDetalleMural(Mural mural) {
    showModalBottomSheet(
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

                  // Foto (nunca bloquea el resto del contenido)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: mural.fotoUrl != null && mural.fotoUrl!.isNotEmpty
                          ? Image.network(
                              mural.fotoUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[200],
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image_outlined,
                                        size: 40, color: Colors.grey),
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
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.image_not_supported_outlined,
                                    size: 40, color: Colors.grey),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

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
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.deepPurple, size: 20),
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

                  // Cómo llegar
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _abrirComoLlegar(
                        mural.latitud,
                        mural.longitud,
                      ),
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
      _mostrarSnackBar('⚠️ No se pudo obtener la ubicación GPS: $e', isError: true);
      return;
    }

    // 4. Abrir modal de formulario
    if (!mounted) return;
    final resultado = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FormularioMuralModal(
        fotoPath: foto.path,
        latitud: posicion!.latitude,
        longitud: posicion.longitude,
      ),
    );

    if (resultado == null) return; // Usuario canceló el formulario

    // 5. Subir imagen y guardar en BD
    await _subirMural(
      foto: foto,
      titulo: resultado['titulo']!,
      descripcion: resultado['descripcion']!,
      latitud: posicion.latitude,
      longitud: posicion.longitude,
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
        _mostrarSnackBar(
          'Permiso de ubicación denegado.',
          isError: true,
        );
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
    required double latitud,
    required double longitud,
  }) async {
    if (!mounted) return;

    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _DialogoCarga(),
    );

    try {
      // ── Compresión de imagen ──
      final Uint8List? imagenComprimida =
          await FlutterImageCompress.compressWithFile(
        foto.path,
        minWidth: 1200,
        minHeight: 1200,
        quality: 80,
      );

      if (imagenComprimida == null) {
        throw Exception('No se pudo comprimir la imagen');
      }

      // ── Subida a Supabase Storage ──
      final String nombreArchivo =
          '${DateTime.now().millisecondsSinceEpoch}_${titulo.replaceAll(' ', '_')}.jpg';

      await supabase.storage.from('murales').uploadBinary(
            nombreArchivo,
            imagenComprimida,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      // Obtener URL pública
      final String fotoUrl =
          supabase.storage.from('murales').getPublicUrl(nombreArchivo);

      // ── Insertar registro en PostgreSQL ──
      final nuevoMural = Mural(
        titulo: titulo,
        descripcion: descripcion.isNotEmpty ? descripcion : null,
        fotoUrl: fotoUrl,
        latitud: latitud,
        longitud: longitud,
      );

      await supabase.from('murales').insert(nuevoMural.toMap());

      // Cerrar diálogo de carga
      if (!mounted) return;
      Navigator.of(context).pop(); // Cierra _DialogoCarga

      _mostrarSnackBar('✅ Mural "$titulo" guardado exitosamente!');

      // Refrescar mapa y centrar en el nuevo mural
      await _cargarMurales();
      _mapController.move(LatLng(latitud, longitud), 16.0);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Cierra _DialogoCarga
      _mostrarSnackBar('❌ Error al guardar: $e', isError: true);
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
        title: const Text('Muralito 🎨'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar murales',
            onPressed: _cargarMurales,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(-0.2800, -78.5450),
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.muralito_app',
              ),
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),

          // Indicador de carga de murales
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

          // Mensaje de error
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

// ──────────────────────────────────────────────────────────────
// MODAL DE FORMULARIO: TÍTULO + DESCRIPCIÓN
// ──────────────────────────────────────────────────────────────
class _FormularioMuralModal extends StatefulWidget {
  final String fotoPath;
  final double latitud;
  final double longitud;

  const _FormularioMuralModal({
    required this.fotoPath,
    required this.latitud,
    required this.longitud,
  });

  @override
  State<_FormularioMuralModal> createState() => _FormularioMuralModalState();
}

class _FormularioMuralModalState extends State<_FormularioMuralModal> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: bottomInset + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle visual
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Registrar Nuevo Mural',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Preview de la foto capturada
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(widget.fotoPath),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),

              // Info de coordenadas
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.deepPurple, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Lat: ${widget.latitud.toStringAsFixed(5)} | '
                      'Lng: ${widget.longitud.toStringAsFixed(5)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Formulario
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                        labelText: 'Título del mural *',
                        hintText: 'Ej: Mural de la esperanza',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El título es obligatorio';
                        }
                        if (value.trim().length < 3) {
                          return 'Mínimo 3 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descripcionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción (opcional)',
                        hintText: 'Ej: Pintado por artistas locales en 2024...',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancelar'),
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
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).pop({
                            'titulo': _tituloController.text.trim(),
                            'descripcion': _descripcionController.text.trim(),
                          });
                        }
                      },
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text(
                        'Guardar Mural',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

// ──────────────────────────────────────────────────────────────
// DIÁLOGO DE CARGA DURANTE LA SUBIDA
// ──────────────────────────────────────────────────────────────
class _DialogoCarga extends StatelessWidget {
  const _DialogoCarga();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Subiendo mural...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Comprimiendo imagen y guardando en la nube',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
