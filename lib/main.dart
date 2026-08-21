import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables desde el archivo .env
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

class MapaPrincipalPage extends StatefulWidget {
  const MapaPrincipalPage({super.key});

  @override
  State<MapaPrincipalPage> createState() => _MapaPrincipalPageState();
}

class _MapaPrincipalPageState extends State<MapaPrincipalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muralito 🎨'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(-0.2800, -78.5450), // Coordenadas iniciales (Quito Sur / Quitumbe)
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.muralito_app',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Aquí conectaremos la cámara y la geolocalización
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listo para capturar un mural 📸')),
          );
        },
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Nuevo Mural'),
      ),
    );
  }
}