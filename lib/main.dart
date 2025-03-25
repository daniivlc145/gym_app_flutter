import 'package:flutter/material.dart';
import 'package:gym_app/themes/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://yomjlscxsdqswdtogntm.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlvbWpsc2N4c2Rxc3dkdG9nbnRtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA4NDkwNDksImV4cCI6MjA1NjQyNTA0OX0.wB8OBgNjyfWyLtxpM2zqlDO_vqr8HrmtIWIfnfvanyk',
    );
  } catch (e) {
    print('Error initializing Supabase: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: Consumer<MyAppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Gym App',
            theme: appState.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
            home: LoginScreen(),
          );
        },
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  bool isDarkMode = false;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
