import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import '../models/mural.dart';
import '../utils/helpers.dart';

class EditarMuralModal extends StatefulWidget {
  final Mural mural;

  const EditarMuralModal({super.key, required this.mural});

  @override
  State<EditarMuralModal> createState() => _EditarMuralModalState();
}

class _EditarMuralModalState extends State<EditarMuralModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _descripcionController;
  String? _nuevaFotoPath; // null = conserva la foto actual del mural
  int _rotacion = 0; // solo aplica a la foto nueva, si se eligió una

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.mural.titulo);
    _descripcionController = TextEditingController(
      text: widget.mural.descripcion ?? '',
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _cambiarFoto() async {
    final XFile? foto = await elegirFuenteFoto(context);
    if (foto == null || !mounted) return;
    setState(() {
      _nuevaFotoPath = foto.path;
      _rotacion = 0; // la rotación anterior no aplica a la foto nueva
    });
  }

  void _rotarImagen() {
    setState(() => _rotacion = (_rotacion + 90) % 360);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bool haySeleccionNueva = _nuevaFotoPath != null;

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
                'Editar mural',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Foto actual, o la nueva si se eligió una, + botón de rotar
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
                        child: haySeleccionNueva
                            ? RotatedBox(
                                quarterTurns: _rotacion ~/ 90,
                                child: Image.file(
                                  File(_nuevaFotoPath!),
                                  fit: BoxFit.contain,
                                ),
                              )
                            : (widget.mural.fotoUrl != null &&
                                      widget.mural.fotoUrl!.isNotEmpty
                                  ? Image.network(
                                      widget.mural.fotoUrl!,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.broken_image_outlined,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 40,
                                      color: Colors.grey,
                                    )),
                      ),
                    ),
                  ),
                  if (haySeleccionNueva)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton.filledTonal(
                        onPressed: _rotarImagen,
                        icon: const Icon(Icons.rotate_right),
                        tooltip: 'Rotar imagen',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(
                            alpha: 0.9,
                          ),
                          foregroundColor: Colors.deepPurple,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _cambiarFoto,
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: Text(
                  haySeleccionNueva ? 'Elegir otra foto' : 'Cambiar foto',
                ),
              ),
              const SizedBox(height: 8),

              // Info de coordenadas (no editable: la ubicación no cambia)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.deepPurple,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Lat: ${widget.mural.latitud.toStringAsFixed(5)} | '
                      'Lng: ${widget.mural.longitud.toStringAsFixed(5)}',
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
                            'descripcion': _descripcionController.text
                                .trim(),
                            'rotacion': _rotacion,
                            'nuevaFotoPath': _nuevaFotoPath,
                          });
                        }
                      },
                      icon: const Icon(Icons.save_outlined),
                      label: const Text(
                        'Guardar cambios',
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
