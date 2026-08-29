import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
// ignore: unnecessary_import
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/perfil.dart';
import '../services/supabase_client.dart';
import '../utils/helpers.dart';

class EditarPerfilModal extends StatefulWidget {
  final Perfil perfil;

  const EditarPerfilModal({super.key, required this.perfil});

  @override
  State<EditarPerfilModal> createState() => _EditarPerfilModalState();
}

class _EditarPerfilModalState extends State<EditarPerfilModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _apodoController;
  String? _nuevoAvatarPath;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _apodoController = TextEditingController(text: widget.perfil.apodo);
  }

  @override
  void dispose() {
    _apodoController.dispose();
    super.dispose();
  }

  Future<void> _cambiarAvatar() async {
    final XFile? foto = await elegirFuenteFoto(context);
    if (foto == null || !mounted) return;
    setState(() => _nuevoAvatarPath = foto.path);
  }

  Future<void> _guardarPerfil() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    String? nuevaUrl = widget.perfil.avatarUrl;

    try {
      if (_nuevoAvatarPath != null) {
        final Uint8List? bytes = await FlutterImageCompress.compressWithFile(
          _nuevoAvatarPath!,
          minWidth: 400,
          minHeight: 400,
          quality: 80,
          autoCorrectionAngle: true,
        );

        if (bytes == null) throw Exception('Error al comprimir avatar');

        final String nombreArchivo =
            'avatar_${widget.perfil.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        await supabase.storage.from('murales').uploadBinary(
              nombreArchivo,
              bytes,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );

        nuevaUrl = supabase.storage.from('murales').getPublicUrl(nombreArchivo);

        if (widget.perfil.avatarUrl != null &&
            widget.perfil.avatarUrl!.isNotEmpty) {
          await borrarFotoDeStorage(widget.perfil.avatarUrl!);
        }
      }

      await supabase.from('perfiles').update({
        'apodo': _apodoController.text.trim(),
        'avatar_url': nuevaUrl,
      }).eq('id', widget.perfil.id);

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${mensajeErrorAmigable(e)}'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.only(top: 80),
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
                'Mi Perfil',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.deepPurple[100],
                      backgroundImage: _nuevoAvatarPath != null
                          ? FileImage(File(_nuevoAvatarPath!))
                          : (widget.perfil.avatarUrl != null &&
                                  widget.perfil.avatarUrl!.isNotEmpty
                              ? NetworkImage(widget.perfil.avatarUrl!)
                              : null) as ImageProvider?,
                      child: _nuevoAvatarPath == null &&
                              (widget.perfil.avatarUrl == null ||
                                  widget.perfil.avatarUrl!.isEmpty)
                          ? const Icon(Icons.person, size: 50, color: Colors.deepPurple)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton.filled(
                        onPressed: _cambiarAvatar,
                        icon: const Icon(Icons.camera_alt, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _apodoController,
                  decoration: InputDecoration(
                    labelText: 'Apodo / Nombre artístico *',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El apodo es obligatorio';
                    }
                    if (value.trim().length < 2) {
                      return 'Mínimo 2 caracteres';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 28),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _guardando ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _guardando ? null : _guardarPerfil,
                      icon: _guardando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: const Text('Guardar Perfil', style: TextStyle(fontSize: 16)),
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
