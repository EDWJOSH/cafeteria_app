import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'data/catalogo_repository.dart';
import 'providers/catalogo_provider.dart';
import 'providers/conectividad_provider.dart';
import 'providers/perfil_provider.dart';
import 'screens/home_screen.dart';
import 'services/cache_service.dart';
import 'services/connectivity_service.dart';
import 'services/media_service.dart';

/// Agrupa los servicios nativos. Se crean una sola vez y se inyectan,
/// así la interfaz no depende de los plugins (y en las pruebas se usan falsos).
class Servicios {
  final CacheService cache;
  final ConnectivityService conectividad;
  final CatalogoRepository catalogo;
  final MediaService media;

  Servicios({
    required this.cache,
    required this.conectividad,
    required this.catalogo,
    required this.media,
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cache = CacheService(await SharedPreferences.getInstance());

  runApp(
    GranoApp(
      servicios: Servicios(
        cache: cache,
        conectividad: ConnectivityService(),
        catalogo: CatalogoRepository(cache),
        media: MediaService(),
      ),
    ),
  );
}

class GranoApp extends StatelessWidget {
  final Servicios servicios;

  const GranoApp({super.key, required this.servicios});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Servicios>.value(value: servicios),
        ChangeNotifierProvider(
          create: (_) => ConectividadProvider(servicios.conectividad),
        ),
        ChangeNotifierProvider(
          create: (_) => PerfilProvider(servicios.media, servicios.cache),
        ),
        ChangeNotifierProxyProvider<ConectividadProvider, CatalogoProvider>(
          create: (_) => CatalogoProvider(servicios.catalogo),
          update: (_, conexion, catalogo) => catalogo!
            ..actualizarConexion(
              verificado: conexion.verificado,
              enLinea: conexion.enLinea,
            ),
        ),
      ],
      child: MaterialApp(
        title: 'Grano & Co.',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.claro,
        home: const HomeScreen(),
      ),
    );
  }
}
