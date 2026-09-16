import 'dart:io';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'ajustar_ubicacion_page.dart';

class FormularioMuralModal extends StatefulWidget {
  final String fotoPath;
  final double latitud;
  final double longitud;

  const FormularioMuralModal({
    super.key,
    required this.fotoPath,
    required this.latitud,
    required this.longitud,
  });

  @override
  State<FormularioMuralModal> createState() => _FormularioMuralModalState();
}

class _FormularioMuralModalState extends State<FormularioMuralModal> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  int _rotacion = 0; // 0, 90, 180, 270
  late double _latitud;
  late double _longitud;

  @override
  void initState() {
    super.initState();
    _latitud = widget.latitud;
    _longitud = widget.longitud;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _cambiarUbicacion() async {
    final LatLng? nueva = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => AjustarUbicacionPage(
          inicial: LatLng(_latitud, _longitud),
          intentarGpsAlAbrir: false,
        ),
      ),
    );
    if (nueva == null || !mounted) return;
    setState(() {
      _latitud = nueva.latitude;
      _longitud = nueva.longitude;
    });
  }

  void _rotarImagen() {
    setState(() {
      _rotacion = (_rotacion + 90) % 360;
    });
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
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Preview de la foto capturada adaptable
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      constraints: const BoxConstraints(
                        maxHeight: 260,
                        minHeight: 160,
                      ),
                      width: double.infinity,
                      color: Colors.grey[100],
                      child: Center(
                        child: RotatedBox(
                          quarterTurns: _rotacion ~/ 90,
                          child: Image.file(
                            File(widget.fotoPath),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton.filledTonal(
                      onPressed: _rotarImagen,
                      icon: const Icon(Icons.rotate_right),
                      tooltip: 'Rotar imagen',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        foregroundColor: Colors.deepPurple,
                      ),
                    ),
                  ),
                ],
              ),

              // M5: se puede reajustar el pin solo aquí, antes de publicar.
              // Después del INSERT la ubicación queda fija (tampoco en Editar).
              Material(
                color: Colors.deepPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: _cambiarUbicacion,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.deepPurple,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lat: ${_latitud.toStringAsFixed(5)} | '
                                'Lng: ${_longitud.toStringAsFixed(5)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Toca para ajustar el pin',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.deepPurple[300],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.edit_location_alt_outlined,
                          color: Colors.deepPurple,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
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
                            'rotacion': _rotacion,
                            'latitud': _latitud,
                            'longitud': _longitud,
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