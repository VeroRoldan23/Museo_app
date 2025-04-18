import 'package:flutter/material.dart';

// Modelo de Obra de Arte
class ObraArte {
  final String titulo;
  final String artista;
  final int anio;
  final String imagenUrl;

  ObraArte({
    required this.titulo,
    required this.artista,
    required this.anio,
    this.imagenUrl = 'assets/default_art.png',
  });

  String get descripcion => '$titulo ($anio) - $artista';
}

// Modelo de Museo
class Museo {
  final String nombre;
  final String ubicacion;
  final String descripcion;
  final List<ObraArte> obras;

  Museo({
    required this.nombre,
    required this.ubicacion,
    required this.descripcion,
    required this.obras,
  });
}

// Servicio que simula obtener datos
class MuseoService {
  static Future<Museo> obtenerDatosMuseo() async {
    await Future.delayed(const Duration(seconds: 1)); // Simula latencia

    return Museo(
      nombre: 'Museo de Arte Moderno',
      ubicacion: 'Ciudad de México',
      descripcion: 'El museo más importante de arte moderno en Latinoamérica',
      obras: [
        ObraArte(
          titulo: 'La Noche de los Pobres',
          artista: 'Rufino Tamayo',
          anio: 1945,
          imagenUrl: "../img/tamayo.jpg",
        ),
        ObraArte(
          titulo: 'Las Dos Fridas',
          artista: 'Frida Kahlo',
          anio: 1939,
          imagenUrl: "../img/Frida.jpg",
        ),
      ],
    );
  }
}

void main() => runApp(const MuseoApp());

class MuseoApp extends StatelessWidget {
  const MuseoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Museo App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MuseoHomePage(),
    );
  }
}

class MuseoHomePage extends StatefulWidget {
  const MuseoHomePage({super.key});

  @override
  State<MuseoHomePage> createState() => _MuseoHomePageState();
}

class _MuseoHomePageState extends State<MuseoHomePage> {
  late Future<Museo> _museoFuture;

  @override
  void initState() {
    super.initState();
    _museoFuture = MuseoService.obtenerDatosMuseo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galería del Museo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              _museoFuture = MuseoService.obtenerDatosMuseo();
            }),
          ),
        ],
      ),
      body: FutureBuilder<Museo>(
        future: _museoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final museo = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMuseoHeader(museo),
                const SizedBox(height: 24),
                _buildObrasList(museo.obras),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMuseoHeader(Museo museo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          museo.nombre,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          museo.ubicacion,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Text(
          museo.descripcion,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildObrasList(List<ObraArte> obras) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Obras Destacadas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: obras.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final obra = obras[index];
            return Card(
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(obra.imagenUrl),
                  onBackgroundImageError: (_, __) => const Icon(Icons.error),
                ),
                title: Text(obra.titulo),
                subtitle: Text(obra.artista),
                trailing: Text(obra.anio.toString()),
                onTap: () => _mostrarDetalleObra(context, obra),
              ),
            );
          },
        ),
      ],
    );
  }

  void _mostrarDetalleObra(BuildContext context, ObraArte obra) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(obra.titulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              obra.imagenUrl,
              errorBuilder: (_, __, ___) => const Icon(Icons.error),
            ),
            const SizedBox(height: 16),
            Text('Artista: ${obra.artista}'),
            Text('Año: ${obra.anio}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
