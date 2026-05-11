import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'utils/app_routes.dart';
import 'utils/app_colors.dart';
import 'utils/app_text_styles.dart';
import 'widgets/auth_gate.dart';

// ── Screen imports ────────────────────────────────────────────────────────────
import 'screens/login_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/event_feed_screen.dart';
import 'screens/event_detail_screen.dart';
import 'screens/event_chat_screen.dart';
import 'screens/my_events_screen.dart';
import 'screens/create_event_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/event_history_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/report_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GatherUpApp());
}

class GatherUpApp extends StatelessWidget {
  const GatherUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ── Atakan's providers ──────────────────────────────────────────────
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // ── Add other providers here as teammates build them ─────────────────
        // e.g. ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'GatherUp',
            debugShowCheckedModeBanner: false,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: themeProvider.themeMode,

            // ── Named routes ────────────────────────────────────────────────
            initialRoute: AppRoutes.authGate,
            routes: {
              // Auth gate — decides login vs home based on auth state
              AppRoutes.authGate: (_) => const AuthGate(),

              // Auth flow
              AppRoutes.login:          (_) => const LoginScreen(),
              AppRoutes.signUp:         (_) => const SignUpScreen(),
              AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),

              // Main app
              AppRoutes.home:           (_) => const EventFeedScreen(),
              AppRoutes.myEvents:       (_) => const MyEventsScreen(),
              AppRoutes.createEvent:    (_) => const CreateEventScreen(),
              AppRoutes.profile:        (_) => const ProfileScreen(),

              // Profile sub-screens
              AppRoutes.editProfile:    (_) => const EditProfileScreen(),
              AppRoutes.eventHistory:   (_) => const EventHistoryScreen(),
              AppRoutes.notifications:  (_) => const NotificationsScreen(),
              AppRoutes.settings:       (_) => const SettingsScreen(),
              AppRoutes.reportProfile:  (_) => const ReportProfileScreen(),

              // Event sub-screens
              AppRoutes.eventDetail:    (_) => const EventDetailScreen(),
              AppRoutes.eventChat:      (_) => const EventChatScreen(),
            },
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        background: AppColors.background,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
      ),
      fontFamily: AppTextStyles.fontFamily,
    );
  }
}
