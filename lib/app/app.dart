import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'layout/responsive_scaffold.dart';
import 'app_state.dart';
import '../features/sell/store/seller_store.dart';
import '../features/admin/store/admin_store.dart';
import '../features/messaging/messaging_store.dart';
import '../features/categories/categories_store.dart';
import '../features/stateinfo/store/state_info_store.dart';
import '../features/splash/splash_screen.dart';
import '../services/demo_data_service.dart';

class VidyutApp extends StatelessWidget {
  const VidyutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DemoDataService()),
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (context) => SellerStore(context.read<DemoDataService>())),
        ChangeNotifierProvider(create: (context) => AdminStore(context.read<DemoDataService>())),
                ChangeNotifierProvider(create: (context) => MessagingStore(context.read<DemoDataService>())),
                ChangeNotifierProvider(create: (context) => CategoriesStore(context.read<AppState>(), context.read<DemoDataService>())),
                ChangeNotifierProvider(create: (context) => StateInfoStore(context.read<DemoDataService>())),
      ],
      child: MaterialApp(
        title: 'Vidyut',
        debugShowCheckedModeBanner: false,
        theme: buildVidyutTheme(),
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const ResponsiveScaffold(),
          // '/auth-test': (context) => const AuthTestPage(),
        },
      ),
    );
  }
}
