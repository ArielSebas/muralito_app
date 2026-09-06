import 'dart:io';
import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:image_picker/image_picker.dart';
import '../models/perfil.dart';
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

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop({
      'apodo': _apodoController.text.trim(),
      'nuevoAvatarPath': _nuevoAvatarPath,
    });
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
                      onPressed: () => Navigator.of(context).pop(),
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
                      onPressed: _guardar,
                      icon: const Icon(Icons.save_outlined),
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