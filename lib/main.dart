import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/event.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_events_screen.dart';
import 'screens/create_event_screen.dart';
import 'screens/event_detail_screen.dart';
import 'screens/event_chat_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/report_profile_screen.dart';
import 'screens/event_history_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/app_colors.dart';
import 'utils/app_routes.dart';
import 'providers/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  final themeProvider = ThemeProvider(prefs);

  runApp(
    ChangeNotifierProvider<ThemeProvider>.value(
      value: themeProvider,
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
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.signup: (_) => const SignUpScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.myEvents: (_) => const MyEventsScreen(),
        AppRoutes.createEvent: (_) => const CreateEventScreen(),
        AppRoutes.eventChat: (_) => const EventChatScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.editProfile: (_) => const EditProfileScreen(),
        AppRoutes.reportProfile: (_) => const ReportProfileScreen(),
        AppRoutes.eventHistory: (_) => const EventHistoryScreen(),
        AppRoutes.notifications: (_) => const NotificationsScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
      },
      // EventDetailScreen needs an Event argument — handled here
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.eventDetail) {
          final event = settings.arguments is Event
              ? settings.arguments as Event
              : _placeholderEvent();
          return MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: event),
            settings: settings,
          );
        }
        return null;
      },
    );
  }

  // Fallback used when navigating to eventDetail without an Event argument
  // (e.g., from the HomeScreen quick-action grid during development)
  Event _placeholderEvent() {
    return const Event(
      id: 'placeholder',
      title: 'Event Detail Preview',
      status: 'upcoming',
      location: 'TBD',
      organizer: 'Organizer',
      description: 'Navigate here from the Event Feed with a real Event object.',
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
