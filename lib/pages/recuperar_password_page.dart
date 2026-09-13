import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_client.dart';
import '../utils/helpers.dart';

/// Flujo de recuperación de contraseña en dos pasos, mediante un código
/// OTP enviado por correo (sin deep links):
///
///   Paso 1: el usuario ingresa su correo -> resetPasswordForEmail()
///   Paso 2: el usuario ingresa el código recibido + nueva contraseña ->
///           verifyOTP(type: recovery) + updateUser()
///
/// Requiere que la plantilla de correo "Reset Password" en el dashboard
/// de Supabase incluya {{ .Token }} para que el correo muestre el código
/// (la cantidad de dígitos la define Supabase, no hardcodeamos un número).
class RecuperarPasswordPage extends StatefulWidget {
  final String? emailInicial;

  const RecuperarPasswordPage({super.key, this.emailInicial});

  @override
  State<RecuperarPasswordPage> createState() => _RecuperarPasswordPageState();
}

class _RecuperarPasswordPageState extends State<RecuperarPasswordPage> {
  final _formKeyCorreo = GlobalKey<FormState>();
  final _formKeyCodigo = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  final _codigoController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _codigoEnviado = false;
  bool _cargando = false;

  Timer? _timerReenvio;
  int _segundosParaReenviar = 0;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.emailInicial ?? '');
    _passController.addListener(_actualizarValidacionContrasena);
    _confirmPassController.addListener(_actualizarValidacionContrasena);
  }

  void _actualizarValidacionContrasena() {
    if (mounted) setState(() {});
  }

  /// Inicia (o reinicia) el conteo para poder reenviar el código.
  /// Cancela cualquier timer previo primero, para nunca tener dos
  /// timers corriendo al mismo tiempo. Por defecto usa 60s (lo que
  /// indica el dashboard de Supabase), pero puede sincronizarse con
  /// los segundos exactos que reporte el servidor si nos rechaza un
  /// reenvío por ir demasiado rápido.
  void _iniciarCooldownReenvio({int segundos = 60}) {
    _timerReenvio?.cancel();
    setState(() => _segundosParaReenviar = segundos);

    _timerReenvio = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_segundosParaReenviar <= 1) {
        timer.cancel();
        setState(() => _segundosParaReenviar = 0);
      } else {
        setState(() => _segundosParaReenviar--);
      }
    });
  }

  /// Traduce los mensajes de error de Supabase Auth más comunes al
  /// español. Si el mensaje indica un límite de espera ("solo puedes
  /// pedir esto después de N segundos"), también devuelve esos N
  /// segundos para poder sincronizar el cooldown visual con el valor
  /// real del servidor, en vez de dejar el botón habilitado para un
  /// reintento que el servidor va a rechazar igual.
  ({String mensaje, int? segundosDeEspera}) _traducirErrorAuth(
    String original,
  ) {
    final texto = original.toLowerCase();

    final coincidenciaEspera = RegExp(r'after (\d+) seconds?')
        .firstMatch(texto);
    if (coincidenciaEspera != null) {
      final segundos = int.tryParse(coincidenciaEspera.group(1)!) ?? 60;
      return (
        mensaje:
            'Por seguridad, espera $segundos segundos antes de pedir otro código.',
        segundosDeEspera: segundos,
      );
    }

    if (texto.contains('expired') || texto.contains('invalid')) {
      return (
        mensaje: 'El código es incorrecto o ya expiró. Solicita uno nuevo.',
        segundosDeEspera: null,
      );
    }

    return (mensaje: original, segundosDeEspera: null);
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
    _timerReenvio?.cancel();
    _passController.removeListener(_actualizarValidacionContrasena);
    _confirmPassController.removeListener(_actualizarValidacionContrasena);
    _emailController.dispose();
    _codigoController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
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

  Future<void> _enviarCodigo({bool validarCorreo = true}) async {
    if (validarCorreo && !_formKeyCorreo.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      await supabase.auth.resetPasswordForEmail(_emailController.text.trim());

      if (!mounted) return;

      setState(() => _codigoEnviado = true);

      _iniciarCooldownReenvio();

      _mostrarSnackBar('📧 Te enviamos un código a tu correo.');
    } on AuthException catch (e) {
      final traduccion = _traducirErrorAuth(e.message);

      if (traduccion.segundosDeEspera != null) {
        _iniciarCooldownReenvio(segundos: traduccion.segundosDeEspera!);
      }

      if (mounted) {
        _mostrarSnackBar('❌ ${traduccion.mensaje}', isError: true);
      }
    } catch (e) {
      if (mounted) {
        _mostrarSnackBar('❌ ${mensajeErrorAmigable(e)}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _confirmarRecuperacion() async {
    if (!_formKeyCodigo.currentState!.validate()) return;

    if (!_contrasenaEsSegura) {
      _mostrarSnackBar('❌ Revisa los requisitos de contraseña.', isError: true);
      return;
    }

    if (!_contrasenasCoinciden) {
      _mostrarSnackBar('❌ Las contraseñas no coinciden.', isError: true);
      return;
    }

    setState(() => _cargando = true);
    try {
      await supabase.auth.verifyOTP(
        type: OtpType.recovery,
        token: _codigoController.text.trim(),
        email: _emailController.text.trim(),
      );

      await supabase.auth.updateUser(
        UserAttributes(password: _passController.text.trim()),
      );

      if (!mounted) return;
      _mostrarSnackBar('✅ Contraseña actualizada correctamente.');
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthException catch (e) {
      if (mounted) {
        _mostrarSnackBar(
          '❌ ${_traducirErrorAuth(e.message).mensaje}',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        _mostrarSnackBar('❌ ${mensajeErrorAmigable(e)}', isError: true);
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
                              : Colors.grey[600],
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

  Widget _pasoCorreo() {
    return Form(
      key: _formKeyCorreo,
      child: Column(
        children: [
          Text(
            'Ingresa tu correo y te enviaremos un código para restablecer '
            'tu contraseña.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
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
              if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
              if (!v.contains('@')) return 'Correo inválido';
              return null;
            },
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _cargando ? null : _enviarCodigo,
              icon: _cargando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_outlined),
              label: const Text(
                'Enviar código',
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
    );
  }

  Widget _pasoCodigoYContrasena() {
    return Form(
      key: _formKeyCodigo,
      child: Column(
        children: [
          Text(
            'Te enviamos un código a ${_emailController.text.trim()}. '
            'Ingrésalo junto con tu nueva contraseña.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _codigoController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Código de recuperación',
              prefixIcon: const Icon(Icons.pin_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Ingresa el código';
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passController,
            obscureText: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              labelText: 'Nueva contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return null;
              if (!_contrasenaEsSegura) {
                return 'Revisa los requisitos de contraseña';
              }
              return null;
            },
          ),
          if (_passController.text.isNotEmpty) _requisitosContrasena(),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPassController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirmar nueva contraseña',
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
              child: Row(
                children: [
                  Icon(
                    _contrasenasCoinciden ? Icons.check_circle : Icons.cancel,
                    size: 18,
                    color: _contrasenasCoinciden ? Colors.green : Colors.red,
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
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _cargando ? null : _confirmarRecuperacion,
              icon: _cargando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.lock_reset),
              label: const Text(
                'Restablecer contraseña',
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
          const SizedBox(height: 12),
          TextButton(
            onPressed: (_cargando || _segundosParaReenviar > 0)
                ? null
                : () => _enviarCodigo(validarCorreo: false),
            child: Text(
              _segundosParaReenviar > 0
                  ? 'Reenviar código en ${_segundosParaReenviar}s'
                  : '¿No recibiste el código? Reenviar',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _codigoEnviado
                      ? Icons.mark_email_read_outlined
                      : Icons.lock_reset,
                  size: 64,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 24),
                _codigoEnviado ? _pasoCodigoYContrasena() : _pasoCorreo(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
