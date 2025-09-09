import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'layout/responsive_scaffold.dart';
import 'app_state.dart';
import '../features/sell/store/seller_store.dart';
import '../features/admin/store/admin_store.dart';

class VidyutApp extends StatelessWidget {
  const VidyutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => SellerStore()),
        ChangeNotifierProvider(create: (_) => AdminStore()),
      ],
      child: MaterialApp(
        title: 'Vidyut',
        debugShowCheckedModeBanner: false,
        theme: buildVidyutTheme(),
        home: const ResponsiveScaffold(),
        // routes: {
        //   '/auth-test': (context) => const AuthTestPage(),
        // },
      ),
    );
  }
}
