import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final appState = AppState();
  runApp(
    ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: const BabySheinApp(),
    ),
  );
  await appState.initialize();
}

class BabySheinApp extends StatefulWidget {
  const BabySheinApp({super.key});

  @override
  State<BabySheinApp> createState() => _BabySheinAppState();
}

class _BabySheinAppState extends State<BabySheinApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    context.read<AppState>().handleLifecycleChange(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baby Shein',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Consumer<AppState>(
        builder: (context, state, _) {
          if (!state.isReady) {
            return const _LoadingSplashScreen();
          }
          return const HomeScreen();
        },
      ),
    );
  }
}

class _LoadingSplashScreen extends StatelessWidget {
  const _LoadingSplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.skyBlueLight,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.skyBlue, width: 4),
              ),
              alignment: Alignment.center,
              child: const Text('🦉', style: TextStyle(fontSize: 62)),
            ),
            const SizedBox(height: 18),
            const Text(
              'Baby Shein',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'အင်္ဂလိပ်စာ ပျော်ပျော်ရွှင်ရွှင် သင်ယူကြမယ်',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 22),
            const CircularProgressIndicator(color: AppColors.skyBlue),
          ],
        ),
      ),
    );
  }
}
