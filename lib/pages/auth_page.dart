import 'package:flutter/material.dart';

import '../services/supabase_client.dart';
import '../utils/helpers.dart';
import 'recuperar_password_page.dart';

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

  // DT4-01: control manual del borde rojo del campo "Contraseña" durante
  // el registro. Se limpia apenas el usuario escribe y solo reaparece al
  // perder foco o al intentar enviar. No aplica en login (ahí no se
  // vuelve a exigir la política de M1).
  final FocusNode _passFocusNode = FocusNode();
  bool _mostrarErrorPassword = false;

  // DT4-01: control manual del borde rojo del campo "Correo electrónico".
  // Se limpia apenas el usuario escribe y solo reaparece al perder foco
  // o al intentar enviar el formulario.
  final FocusNode _emailFocusNode = FocusNode();
  bool _mostrarErrorEmail = false;

  @override
  void initState() {
    super.initState();
    _esRegistro = widget.empezarEnRegistro;

    _passController.addListener(_actualizarValidacionContrasena);
    _passController.addListener(_ocultarErrorPasswordAlEscribir);
    _confirmPassController.addListener(_actualizarValidacionContrasena);
    _passFocusNode.addListener(_alCambiarFocoPassword);

    // DT4-01: listeners para el campo de email
    _emailController.addListener(_ocultarErrorEmailAlEscribir);
    _emailFocusNode.addListener(_alCambiarFocoEmail);
  }

  void _actualizarValidacionContrasena() {
    if (mounted) {
      setState(() {});
    }
  }

  /// DT4-01: apenas el usuario toca una tecla, se oculta el error visual
  /// aunque la contraseña siga sin cumplir los requisitos. El checklist
  /// ([_requisitosContrasena]) sigue mostrando el estado real; esto solo
  /// controla el borde rojo del campo.
  void _ocultarErrorPasswordAlEscribir() {
    if (_mostrarErrorPassword && mounted) {
      setState(() => _mostrarErrorPassword = false);
    }
  }

  /// DT4-01: apenas el usuario toca una tecla en el campo de email,
  /// se oculta el error visual aunque el correo siga siendo inválido.
  void _ocultarErrorEmailAlEscribir() {
    if (_mostrarErrorEmail && mounted) {
      setState(() => _mostrarErrorEmail = false);
    }
  }

  /// DT4-01: al perder el foco durante el registro, si quedó texto y
  /// sigue sin cumplir los requisitos, recién ahí se muestra el borde
  /// rojo. En login no aplica: la contraseña no se vuelve a validar
  /// contra la política de M1.
  void _alCambiarFocoPassword() {
    if (_passFocusNode.hasFocus || !mounted) return;
    final bool debeMostrarError =
        _esRegistro && _passController.text.isNotEmpty && !_contrasenaEsSegura;
    if (debeMostrarError != _mostrarErrorPassword) {
      setState(() => _mostrarErrorPassword = debeMostrarError);
    }
  }

  /// DT4-01: al perder el foco en el campo de email, si el correo
  /// sigue siendo inválido, se muestra el error visual.
  void _alCambiarFocoEmail() {
    if (_emailFocusNode.hasFocus || !mounted) return;
    final email = _emailController.text.trim();
    final bool debeMostrarError = email.isNotEmpty && !email.contains('@');
    if (debeMostrarError != _mostrarErrorEmail) {
      setState(() => _mostrarErrorEmail = debeMostrarError);
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
    _passController.removeListener(_ocultarErrorPasswordAlEscribir);
    _confirmPassController.removeListener(_actualizarValidacionContrasena);
    _passFocusNode.removeListener(_alCambiarFocoPassword);
    _passFocusNode.dispose();

    // DT4-01: limpieza de listeners para email
    _emailController.removeListener(_ocultarErrorEmailAlEscribir);
    _emailFocusNode.removeListener(_alCambiarFocoEmail);
    _emailFocusNode.dispose();

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
    // DT4-01: forzar validaci\u00f3n visual antes de enviar
    final email = _emailController.text.trim();
    setState(() {
      _mostrarErrorEmail = email.isEmpty || !email.contains('@');
      if (_esRegistro) {
        _mostrarErrorPassword = _passController.text.isNotEmpty && !_contrasenaEsSegura;
      }
    });

    if (!_formKey.currentState!.validate()) return;

    if (_esRegistro) {
      if (_validarContrasenaRegistro(_passController.text) != null) {
        setState(() => _mostrarErrorPassword = true);
        mostrarSnackBar(
          context,
          '❌ Revisa los requisitos de contraseña.',
          isError: true,
        );
        return;
      }

      if (_confirmPassController.text.isEmpty) {
        mostrarSnackBar(
          context,
          '❌ Confirma tu contraseña.',
          isError: true,
        );
        return;
      }

      if (!_contrasenasCoinciden) {
        mostrarSnackBar(
          context,
          '❌ Las contraseñas no coinciden.',
          isError: true,
        );
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
          mostrarSnackBar(
            context,
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
    } catch (e) {
      // Los AuthException se traducen a español dentro de
      // mensajeErrorAmigable (DT4): ningún mensaje crudo llega a la UI.
      if (mounted) {
        mostrarSnackBar(
          context,
          '❌ ${mensajeErrorAmigable(e)}',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
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
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        // DT4-01: el borde rojo se controla manualmente vía
                        // [_mostrarErrorEmail] (errorText), no por autovalidate.
                        // Se limpia al escribir y reaparece al perder foco o enviar.
                        autovalidateMode: AutovalidateMode.disabled,
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          errorText: _mostrarErrorEmail
                              ? _emailController.text.trim().isEmpty
                                  ? 'Ingresa tu correo'
                                  : 'Correo inválido'
                              : null,
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
                        focusNode: _passFocusNode,
                        obscureText: true,
                        // DT4-01: el borde rojo se controla manualmente vía
                        // [_mostrarErrorPassword] (errorText), no por
                        // autovalidate. Se limpia al escribir y reaparece
                        // al perder foco o al enviar. En login nunca se
                        // activa (ahí no se revalida la política de M1);
                        // la validación en vivo del registro sigue
                        // viviendo en [_requisitosContrasena].
                        autovalidateMode: AutovalidateMode.disabled,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          errorText: _mostrarErrorPassword
                              ? 'Revisa los requisitos de contraseña'
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (_) => null,
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
                if (!_esRegistro)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RecuperarPasswordPage(
                            emailInicial: _emailController.text.trim(),
                          ),
                        ),
                      );
                    },
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                TextButton(
                  onPressed: () => setState(() {
                    _esRegistro = !_esRegistro;
                    _mostrarErrorPassword = false;
                  }),
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