import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_lifecycle.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';

class AiHealthCompanionApp extends ConsumerStatefulWidget {
  const AiHealthCompanionApp({super.key});

  @override
  ConsumerState<AiHealthCompanionApp> createState() =>
      _AiHealthCompanionAppState();
}

class _AiHealthCompanionAppState extends ConsumerState<AiHealthCompanionApp> {
  @override
  void initState() {
    super.initState();

    // Initialize app lifecycle after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLifecycle.initialize(ref);
    });
  }

  @override
  void dispose() {
    AppLifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final theme = ref.watch(appThemeProvider);

    return MaterialApp.router(
      title: 'AI Health Companion',
      debugShowCheckedModeBanner: false,
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
