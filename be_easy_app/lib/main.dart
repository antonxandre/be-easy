import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'data/services/api_service.dart';
import 'data/services/server_manager.dart';
import 'ui/core/theme.dart';
import 'ui/features/desktop/admin/admin_settings_screen.dart';
import 'ui/features/desktop/desktop_main_screen.dart';
import 'ui/features/desktop/desktop_session_viewmodel.dart';
import 'ui/features/webapp/mobile_main_screen.dart';
import 'ui/features/webapp/mobile_session_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // No desktop/computador da loja, inicializa automaticamente o servidor Shelf local em background
  if (!kIsWeb) {
    final serverManager = getServerManager();
    await serverManager.startServer();
  }

  runApp(const BeEasyApp());
}

final _router = GoRouter(
  initialLocation: kIsWeb ? '/app' : '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) =>
          kIsWeb ? const MobileMainScreen() : const DesktopMainScreen(),
    ),
    GoRoute(
      path: '/desktop',
      builder: (context, state) => const DesktopMainScreen(),
    ),
    GoRoute(
      path: '/app',
      builder: (context, state) => const MobileMainScreen(),
    ),
    GoRoute(
      path: '/mobile',
      builder: (context, state) => const MobileMainScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminSettingsScreen(),
    ),
  ],
);

class BeEasyApp extends StatelessWidget {
  const BeEasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider(
          create: (_) => DesktopSessionViewModel(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => MobileSessionViewModel(apiService: apiService),
        ),
      ],
      child: MaterialApp.router(
        title: 'be EASY Print',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
