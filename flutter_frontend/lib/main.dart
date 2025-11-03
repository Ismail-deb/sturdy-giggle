import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/dashboard_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/sensor_info_screen.dart';
import 'screens/settings_screen.dart';
import 'services/api_service.dart';
import 'services/notification_service.dart';
import 'services/notification_manager.dart';

// ============================================================================
// AppColors - Color Palette for Both Themes
// ============================================================================
class AppColors {
  // Light Theme Colors (Darker Grey)
  // Updated to Natural Earth (Soil) palette
  static const Color lightBackground = Color(0xFFF3EEE6);      // Warm beige/earth
  static const Color lightCard = Color(0xFFFFFAF0);            // Soft cream/ivory (updated for better contrast)
  static const Color lightPrimary = Color(0xFF6B4F3A);         // Soil brown
  static const Color lightSecondary = Color(0xFF8A9A5B);       // Olive green accent
  static const Color lightText = Color(0xFF3E2E20);            // Deep brown text
  static const Color lightTextSecondary = Color(0xFF6D5E50);   // Muted brown-gray
  
  // Dark Theme Colors (Dark Green)
  static const Color darkBackground = Color(0xFF0D1F12);       // Dark green
  static const Color darkCard = Color(0xFF1B3A1F);             // Lighter dark green
  static const Color darkPrimary = Color(0xFF4CAF50);          // Vibrant eco green
  static const Color darkSecondary = Color(0xFF66BB6A);        // Lighter eco green (consistent with primary)
  static const Color darkText = Color(0xFFE8F5E9);             // Soft off-white with green tint
  static const Color darkTextSecondary = Color(0xFFB0BEC5);    // Light gray-blue
  
  // Helper methods to get theme-aware colors
  static Color getPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkPrimary : lightPrimary;
  }
  
  static Color getSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkSecondary : lightSecondary;
  }
  
  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkBackground : lightBackground;
  }
  
  static Color getCard(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkCard : lightCard;
  }
  
  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkText : lightText;
  }
  
  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;
  }
  
  // Legacy properties for backward compatibility (uses dark theme colors)
  static const Color primary = darkPrimary;
  static const Color accent = darkSecondary;
  static const Color card = darkCard;
  static const Color textPrimary = darkText;
  static const Color textSecondary = darkTextSecondary;
}

// ============================================================================
// AppThemes - Theme Definitions
// ============================================================================
class AppThemes {
  // Light Theme (Natural Earth)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      surface: AppColors.lightCard,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
  onSurface: AppColors.lightText,
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    fontFamily: 'Roboto',
  // Text fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.lightTextSecondary),
      labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
      prefixIconColor: AppColors.lightSecondary,
      suffixIconColor: AppColors.lightSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.brown.shade200, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.brown.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    ),
    // Material 3 DropdownMenu
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(AppColors.lightCard),
        elevation: WidgetStatePropertyAll(2),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        )),
      ),
      inputDecorationTheme: const InputDecorationTheme(),
      textStyle: const TextStyle(color: AppColors.lightText, fontSize: 14),
    ),
    // SearchBar (Material 3)
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStatePropertyAll(AppColors.lightCard),
      elevation: const WidgetStatePropertyAll(0),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Color(0xFFBCAAA4), width: 1), // light brown border
      )),
      hintStyle: const WidgetStatePropertyAll(TextStyle(color: AppColors.lightTextSecondary)),
      textStyle: const WidgetStatePropertyAll(TextStyle(color: AppColors.lightText)),
    ),
    // Selection colors in inputs
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.lightPrimary,
      selectionColor: Color(0x336B4F3A),
      selectionHandleColor: AppColors.lightPrimary,
    ),
    
    textTheme: const TextTheme(
      displayMedium: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: AppColors.lightText, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.lightTextSecondary, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.lightTextSecondary, fontSize: 12),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.lightText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
      iconTheme: IconThemeData(color: AppColors.lightPrimary),
    ),
    
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.lightPrimary,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
    ),
  );
  
  // Dark Theme (Eco-Tech)
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      surface: AppColors.darkCard,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
  onSurface: AppColors.darkText,
      error: Colors.redAccent,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    fontFamily: 'Roboto',
  // Text fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.darkTextSecondary),
      labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
      prefixIconColor: AppColors.darkSecondary,
      suffixIconColor: AppColors.darkSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white24, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    ),
    // Material 3 DropdownMenu
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(AppColors.darkCard),
        elevation: WidgetStatePropertyAll(2),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        )),
      ),
      inputDecorationTheme: const InputDecorationTheme(),
      textStyle: const TextStyle(color: AppColors.darkText, fontSize: 14),
    ),
    // SearchBar (Material 3)
    searchBarTheme: SearchBarThemeData(
      backgroundColor: WidgetStatePropertyAll(AppColors.darkCard),
      elevation: const WidgetStatePropertyAll(0),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white24, width: 1),
      )),
      hintStyle: const WidgetStatePropertyAll(TextStyle(color: AppColors.darkTextSecondary)),
      textStyle: const WidgetStatePropertyAll(TextStyle(color: AppColors.darkText)),
    ),
    // Selection colors in inputs
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.darkPrimary,
      selectionColor: Color(0x334CAF50),
      selectionHandleColor: AppColors.darkPrimary,
    ),
    
    textTheme: const TextTheme(
      displayMedium: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: AppColors.darkText, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.darkTextSecondary, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.darkTextSecondary, fontSize: 12),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.darkText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Roboto',
      ),
      iconTheme: IconThemeData(color: AppColors.darkPrimary),
    ),
    
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
    ),
  );
}

// ============================================================================
// Main App
// ============================================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService().initNotification();
  
  // ALWAYS try to discover the server on app start (dynamic IP support)
  // This ensures the app works even if the PC's IP changes
  print('🔍 EcoView starting - discovering server...');
  await ApiService.initialize(forceRediscover: true);
  print('✅ API Service initialized');
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  
  @override
  void initState() {
    super.initState();
    // Load saved theme preference
    _loadThemePreference();
    
    // Start notification polling after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      NotificationManager().startAlertPolling();
    });
  }
  
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode') ?? 0; // 0=system, 1=light, 2=dark
    setState(() {
      _themeMode = ThemeMode.values[themeIndex];
    });
  }
  
  Future<void> _setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoView - Smart Greenhouse Monitoring',
      debugShowCheckedModeBanner: false,
      // Use selected theme mode
      themeMode: _themeMode,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      home: AppShell(
        onThemeChanged: _setThemeMode,
        currentThemeMode: _themeMode,
      ),
    );
  }
}

// ============================================================================
// AppShell - Main Navigation Structure
// ============================================================================
class AppShell extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;
  final ThemeMode? currentThemeMode;
  
  const AppShell({
    super.key,
    this.onThemeChanged,
    this.currentThemeMode,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  
  // Define all screens
  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const NotificationsScreen(),
      const SensorInfoScreen(),
      const SettingsScreen(),
    ];
  }
  
  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Scaffold(
      appBar: isSmallScreen ? AppBar(
        title: const Text('EcoView'),
        actions: [
          // Theme toggle button
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.brightness_6),
            tooltip: 'Change Theme',
            onSelected: (ThemeMode mode) {
              widget.onThemeChanged?.call(mode);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<ThemeMode>>[
              PopupMenuItem<ThemeMode>(
                value: ThemeMode.system,
                child: Row(
                  children: [
                    const Icon(Icons.brightness_auto),
                    const SizedBox(width: 8),
                    const Text('System'),
                    if (widget.currentThemeMode == ThemeMode.system)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.check, size: 16),
                      ),
                  ],
                ),
              ),
              PopupMenuItem<ThemeMode>(
                value: ThemeMode.light,
                child: Row(
                  children: [
                    const Icon(Icons.light_mode),
                    const SizedBox(width: 8),
                    const Text('Light'),
                    if (widget.currentThemeMode == ThemeMode.light)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.check, size: 16),
                      ),
                  ],
                ),
              ),
              PopupMenuItem<ThemeMode>(
                value: ThemeMode.dark,
                child: Row(
                  children: [
                    const Icon(Icons.dark_mode),
                    const SizedBox(width: 8),
                    const Text('Dark'),
                    if (widget.currentThemeMode == ThemeMode.dark)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(Icons.check, size: 16),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ) : null,
      
      // Main body with navigation
      body: Row(
        children: [
          // NavigationRail for larger screens
          if (!isSmallScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              leading: Column(
                children: [
                  const SizedBox(height: 8),
                  const CircleAvatar(
                    backgroundColor: Colors.green,
                    radius: 24,
                    child: Icon(Icons.eco, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 8),
                  // Theme toggle for large screens
                  PopupMenuButton<ThemeMode>(
                    icon: const Icon(Icons.brightness_6),
                    tooltip: 'Change Theme',
                    onSelected: (ThemeMode mode) {
                      widget.onThemeChanged?.call(mode);
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<ThemeMode>>[
                      PopupMenuItem<ThemeMode>(
                        value: ThemeMode.system,
                        child: Row(
                          children: [
                            const Icon(Icons.brightness_auto),
                            const SizedBox(width: 8),
                            const Text('System'),
                            if (widget.currentThemeMode == ThemeMode.system)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.check, size: 16),
                              ),
                          ],
                        ),
                      ),
                      PopupMenuItem<ThemeMode>(
                        value: ThemeMode.light,
                        child: Row(
                          children: [
                            const Icon(Icons.light_mode),
                            const SizedBox(width: 8),
                            const Text('Light'),
                            if (widget.currentThemeMode == ThemeMode.light)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.check, size: 16),
                              ),
                          ],
                        ),
                      ),
                      PopupMenuItem<ThemeMode>(
                        value: ThemeMode.dark,
                        child: Row(
                          children: [
                            const Icon(Icons.dark_mode),
                            const SizedBox(width: 8),
                            const Text('Dark'),
                            if (widget.currentThemeMode == ThemeMode.dark)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Icon(Icons.check, size: 16),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.notifications_outlined),
                  selectedIcon: Icon(Icons.notifications),
                  label: Text('Alerts'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.sensors_outlined),
                  selectedIcon: Icon(Icons.sensors),
                  label: Text('Sensors'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
          
          // Vertical divider
          if (!isSmallScreen)
            const VerticalDivider(thickness: 1, width: 1),
          
          // Main content area with background image and overlay
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image with multi-path fallback
                const _BackgroundImage(),
                // Subtle dark/light overlay for contrast
                Container(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withAlpha((0.25 * 255).round())
                      : Colors.white.withAlpha((0.10 * 255).round()),
                ),
                // Foreground screen content
                _screens[_selectedIndex],
              ],
            ),
          ),
        ],
      ),
      
      // BottomNavigationBar for small screens
      bottomNavigationBar: isSmallScreen
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onDestinationSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.notifications_outlined),
                  selectedIcon: Icon(Icons.notifications),
                  label: 'Alerts',
                ),
                NavigationDestination(
                  icon: Icon(Icons.sensors_outlined),
                  selectedIcon: Icon(Icons.sensors),
                  label: 'Sensors',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            )
          : null,
    );
  }
}

// Background image widget that tries several common filenames and falls back to a gradient
class _BackgroundImage extends StatefulWidget {
  const _BackgroundImage();

  @override
  State<_BackgroundImage> createState() => _BackgroundImageState();
}

class _BackgroundImageState extends State<_BackgroundImage> {
  // Candidate asset filenames users might add
  static const candidates = <String>[
    // New preferred background asset names
    'assets/the app background.png',
    'assets/app background.png',
    'assets/greenhouse_bg.png',
    'assets/greenhouse_bg.jpg',
    'assets/greenhouse_banner.jpg',
    'assets/greenhouse.jpg',
    'assets/greenhouse.png',
    // Known files currently in assets as fallbacks
    // Older background that may still exist in some clones
    'assets/Gemini_Generated_Image_vmo4davmo4davmo4.png',
    'assets/app_icon.png',
  ];

  String? _resolvedPath;
  bool _resolvedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_resolvedOnce) {
      _resolvedOnce = true;
      _resolve();
    }
  }

  Future<void> _resolve() async {
    for (final path in candidates) {
      try {
        await DefaultAssetBundle.of(context).load(path);
        if (mounted) {
          setState(() => _resolvedPath = path);
        }
        return;
      } catch (_) {
        // Try next candidate
      }
    }
    if (mounted) setState(() => _resolvedPath = null);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_resolvedPath == null) {
      // Gradient fallback
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF0D1F12), Color(0xFF1B3A1F)]
                : const [Color(0xFFF3EEE6), Color(0xFFE6D9C8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
    }
    return Image.asset(
      _resolvedPath!,
      fit: BoxFit.cover,
    );
  }
}