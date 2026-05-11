import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'models/event.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/create_event_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/event_chat_screen.dart';
import 'screens/event_detail_screen.dart';
import 'screens/event_feed_screen.dart';
import 'screens/event_history_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_events_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/report_profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signup_screen.dart';
import 'utils/app_colors.dart';
import 'utils/app_routes.dart';
import 'widgets/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  final themeProvider = ThemeProvider(prefs);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppAuthProvider>(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
      ],
      child: const GatherUpApp(),
    ),
  );
}

class GatherUpApp extends StatelessWidget {
  const GatherUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    AppColors.update(themeProvider.isDarkMode);

    return MaterialApp(
      title: 'GatherUp',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: themeProvider.themeMode,
      home: const AuthGate(),
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.signup: (_) => const SignUpScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.home: (_) => const AuthGate(child: EventFeedScreen()),
        AppRoutes.myEvents: (_) => const AuthGate(child: MyEventsScreen()),
        AppRoutes.createEvent: (_) => const AuthGate(child: CreateEventScreen()),
        AppRoutes.profile: (_) => const AuthGate(child: ProfileScreen()),
        AppRoutes.editProfile: (_) => const AuthGate(child: EditProfileScreen()),
        AppRoutes.reportProfile: (_) => const AuthGate(child: ReportProfileScreen()),
        AppRoutes.eventHistory: (_) => const AuthGate(child: EventHistoryScreen()),
        AppRoutes.notifications: (_) => const AuthGate(child: NotificationsScreen()),
        AppRoutes.settings: (_) => const AuthGate(child: SettingsScreen()),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.eventDetail &&
            settings.arguments is Event) {
          return MaterialPageRoute(
            builder: (_) => AuthGate(
              child: EventDetailScreen(event: settings.arguments as Event),
            ),
            settings: settings,
          );
        }
        if (settings.name == AppRoutes.eventChat &&
            settings.arguments is Event) {
          return MaterialPageRoute(
            builder: (_) => AuthGate(
              child: EventChatScreen(event: settings.arguments as Event),
            ),
            settings: settings,
          );
        }
        return null;
      },
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const AuthGate(),
      ),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.poppinsTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
