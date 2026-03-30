import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'providers/app_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/generating_screen.dart';
import 'screens/main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = AppProvider();
  await provider.initialize();

  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const BelayApp(),
    ),
  );
}

class BelayApp extends StatelessWidget {
  const BelayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Belay',
      theme: BelayTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const _RootRouter(),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppProvider>().state;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: switch (state) {
        AppState.loading => const _SplashScreen(),
        AppState.onboarding => const OnboardingScreen(),
        AppState.generating || AppState.error => const GeneratingScreen(),
        AppState.ready => const MainScaffold(),
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: BelayColors.accent),
      ),
    );
  }
}
