import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/dashboard_screen.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'services/notification_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService().initNotification();
  
  // Get saved IP address from shared preferences, if any
  final prefs = await SharedPreferences.getInstance();
  final serverIP = prefs.getString('server_ip');
  
  // Initialize API service with the saved IP if available
  await ApiService.initialize(customServerIP: serverIP);
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Start notification polling after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      NotificationManager().startAlertPolling();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoView - Smart Greenhouse Monitoring',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: Colors.green[500]!,
          secondary: Colors.orange,
          surface: const Color(0xFF1A1A1A),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
      ),
      home: const DashboardScreen(),
    );
  }
}