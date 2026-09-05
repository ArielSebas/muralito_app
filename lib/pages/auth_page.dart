import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_client.dart';
import '../utils/helpers.dart';

class AuthPage extends StatefulWidget {
  final bool empezarEnRegistro;

  const AuthPage({super.key, this.empezarEnRegistro = false});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late bool _esRegistro;
  bool _cargando = false;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _esRegistro = widget.empezarEnRegistro;

    _passController.addListener(_actualizarValidacionContrasena);
    _confirmPassController.addListener(_actualizarValidacionContrasena);
  }

  void _actualizarValidacionContrasena() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _tieneLongitudMinima => _passController.text.length >= 8;

  bool get _tieneMayuscula => RegExp(r'[A-Z]').hasMatch(_passController.text);

  bool get _tieneMinuscula => RegExp(r'[a-z]').hasMatch(_passController.text);

  bool get _tieneNumero => RegExp(r'[0-9]').hasMatch(_passController.text);

  bool get _tieneCaracterEspecial =>
      RegExp(r'[^A-Za-z0-9]').hasMatch(_passController.text);

  bool get _contrasenaEsSegura =>
      _tieneLongitudMinima &&
      _tieneMayuscula &&
      _tieneMinuscula &&
      _tieneNumero &&
      _tieneCaracterEspecial;

  bool get _confirmacionTieneTexto => _confirmPassController.text.isNotEmpty;

  bool get _contrasenasCoinciden =>
      _confirmPassController.text.isNotEmpty &&
      _confirmPassController.text == _passController.text;

  bool get _confirmacionNoCoincide =>
      _confirmPassController.text.isNotEmpty &&
      _confirmPassController.text != _passController.text;

  @override
  void dispose() {
    _passController.removeListener(_actualizarValidacionContrasena);
    _confirmPassController.removeListener(_actualizarValidacionContrasena);

    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();

    super.dispose();
  }

  String? _validarContrasenaRegistro(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Ingresa una contraseña';
    }

    final errores = <String>[];

    if (valor.length < 8) {
      errores.add('mínimo 8 caracteres');
    }

    if (!RegExp(r'[A-Z]').hasMatch(valor)) {
      errores.add('una mayúscula');
    }

    if (!RegExp(r'[a-z]').hasMatch(valor)) {
      errores.add('una minúscula');
    }

    if (!RegExp(r'[0-9]').hasMatch(valor)) {
      errores.add('un número');
    }

    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(valor)) {
      errores.add('un carácter especial');
    }

    if (errores.isEmpty) {
      return null;
    }

    return 'Debe tener ${errores.join(', ')}.';
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_esRegistro) {
      if (_confirmPassController.text.isEmpty) {
        _mostrarSnackBar('❌ Confirma tu contraseña.', isError: true);
        return;
      }

      if (!_contrasenasCoinciden) {
        _mostrarSnackBar('❌ Las contraseñas no coinciden.', isError: true);
        return;
      }
    }

    setState(() => _cargando = true);

    try {
      if (_esRegistro) {
        await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
        );
        if (mounted) {
          _mostrarSnackBar(
            '📧 Revisa tu correo para confirmar la cuenta. '
            'Luego inicia sesión.',
          );
          setState(() => _esRegistro = false);
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passController.text.trim(),
        );
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        }
      }
    } on AuthException catch (e) {
      if (mounted) _mostrarSnackBar('❌ ${e.message}', isError: true);
    } catch (e) {
      if (mounted) {
        _mostrarSnackBar('❌ ${mensajeErrorAmigable(e)}', isError: true);
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarSnackBar(String mensaje, {bool isError = false}) {
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

  Widget _requisitosContrasena() {
    final requisitos = [
      (cumple: _tieneLongitudMinima, texto: 'Al menos 8 caracteres'),
      (cumple: _tieneMayuscula, texto: 'Una letra mayúscula'),
      (cumple: _tieneMinuscula, texto: 'Una letra minúscula'),
      (cumple: _tieneNumero, texto: 'Un número'),
      (cumple: _tieneCaracterEspecial, texto: 'Un carácter especial'),
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _contrasenaEsSegura
                ? '✓ Contraseña segura'
                : 'Requisitos de contraseña',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: _contrasenaEsSegura ? Colors.green[700] : Colors.grey[700],
            ),
          ),
          if (!_contrasenaEsSegura) ...[
            const SizedBox(height: 8),
            ...requisitos.map(
              (requisito) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      requisito.cumple
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 18,
                      color: requisito.cumple
                          ? Colors.green[600]
                          : Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        requisito.texto,
                        style: TextStyle(
                          fontSize: 13,
                          color: requisito.cumple
                              ? Colors.green[700]
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.brush, size: 72, color: Colors.deepPurple),
                const SizedBox(height: 16),
                Text(
                  'Muralito',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _esRegistro
                      ? 'Crea tu cuenta para registrar murales'
                      : 'Inicia sesión para registrar murales',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Ingresa tu correo';
                          }
                          if (!v.contains('@')) return 'Correo inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (v) {
                          if (_esRegistro) {
                            if (_validarContrasenaRegistro(v) != null) {
                              return 'Revisa los requisitos de contraseña';
                            }
                            return null;
                          }

                          if (v == null || v.isEmpty) {
                            return 'Ingresa tu contraseña';
                          }

                          return null;
                        },
                      ),

                      if (_esRegistro && _passController.text.isNotEmpty)
                        _requisitosContrasena(),

                      if (_esRegistro) ...[
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _confirmPassController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirmar contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _confirmacionNoCoincide
                                    ? Colors.red.shade700
                                    : Colors.grey.shade600,
                                width: _confirmacionNoCoincide ? 2 : 1,
                              ),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _confirmacionNoCoincide
                                    ? Colors.red.shade700
                                    : Colors.deepPurple,
                                width: 2,
                              ),
                            ),

                            filled: true,
                            fillColor: Colors.grey[50],
                          ),

                          validator: (_) => null,
                        ),

                        if (_confirmacionTieneTexto) ...[
                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Row(
                                key: ValueKey(_contrasenasCoinciden),
                                children: [
                                  Icon(
                                    _contrasenasCoinciden
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    size: 18,
                                    color: _contrasenasCoinciden
                                        ? Colors.green
                                        : Colors.red,
                                  ),

                                  const SizedBox(width: 6),

                                  Expanded(
                                    child: Text(
                                      _contrasenasCoinciden
                                          ? 'Las contraseñas coinciden'
                                          : 'Las contraseñas no coinciden',
                                      style: TextStyle(
                                        color: _contrasenasCoinciden
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _cargando ? null : _enviar,
                    icon: _cargando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(_esRegistro ? Icons.person_add : Icons.login),
                    label: Text(
                      _esRegistro ? 'Crear cuenta' : 'Iniciar sesión',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => setState(() => _esRegistro = !_esRegistro),
                  child: Text(
                    _esRegistro
                        ? '¿Ya tienes cuenta? Inicia sesión'
                        : '¿No tienes cuenta? Regístrate',
                  ),
                ),
                if (Navigator.of(context).canPop())
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Continuar sin cuenta',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
