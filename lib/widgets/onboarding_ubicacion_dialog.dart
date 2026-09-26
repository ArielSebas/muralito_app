import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _claveOnboardingUbicacionVisto = 'onboarding_ubicacion_visto';

/// M3 — Onboarding de ubicación.
///
/// Muestra, una única vez en la vida de la instalación (persistido con
/// [SharedPreferences], no solo por sesión), un diálogo explicando por
/// qué Muralito pide permiso de ubicación, antes de que se dispare el
/// diálogo nativo de Android. Se llama al inicio de los dos flujos que
/// necesitan ubicación: "Nuevo Mural" (M5) y "Mi ubicación" (M6) — lo
/// que el usuario toque primero.
///
/// Si ya se mostró antes, no hace nada (retorna de inmediato). El
/// llamador debe hacer `await` de esta función antes de continuar con
/// la acción original, para que "Entendido" siga el flujo sin un toque
/// adicional.
Future<void> mostrarOnboardingUbicacionSiCorresponde(
  BuildContext context,
) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool yaVisto = prefs.getBool(_claveOnboardingUbicacionVisto) ?? false;
  if (yaVisto) return;

  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      icon: Icon(
        Icons.location_on,
        color: Theme.of(ctx).colorScheme.primary,
        size: 40,
      ),
      title: const Text('Ubicación para murales'),
      content: const Text(
        'Muralito pide tu ubicación para marcar exactamente dónde está '
        'cada mural en el mapa, y para centrarlo en el lugar donde te '
        'encuentres. Puedes seguir usando la app sin dar este permiso — '
        'simplemente ajustas el pin a mano.',
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Entendido'),
        ),
      ],
    ),
  );

  await prefs.setBool(_claveOnboardingUbicacionVisto, true);
}
