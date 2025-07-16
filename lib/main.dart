// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'providers/financial_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/finance_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('sw', 'KE'), // Swahili
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: const FarmersApp(),
    ),
  );
}

class FarmersApp extends StatelessWidget {
  const FarmersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
        ChangeNotifierProvider<FinancialProvider>(
          create: (context) => FinancialProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Farmer\'s Financial Tracker',
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: Colors.green[600],
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          // fontFamily: 'Poppins',
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        home: const AuthOrMainApp(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthOrMainApp extends StatefulWidget {
  const AuthOrMainApp({super.key});

  @override
  State<AuthOrMainApp> createState() => _AuthOrMainAppState();
}

class _AuthOrMainAppState extends State<AuthOrMainApp> {
  // 0: login, 1: register, 2: forgot, 3: reset
  int _authScreen = 0;

  void _goTo(int screen) => setState(() => _authScreen = screen);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    if (auth.isAuthenticated) {
      return const MainApp();
    }
    switch (_authScreen) {
      case 1:
        return RegisterScreen(onLogin: () => _goTo(0));
      case 2:
        return ForgotPasswordScreen(onLogin: () => _goTo(0));
      case 3:
        return ResetPasswordScreen(onLogin: () => _goTo(0));
      case 0:
      default:
        return LoginScreen(
          onRegister: () => _goTo(1),
          onForgotPassword: () => _goTo(2),
        );
    }
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const FinanceScreen(),
    const TasksScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.green[600],
        unselectedItemColor: Colors.grey[600],
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'home'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet),
            label: 'finance'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.task),
            label: 'tasks'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.analytics),
            label: 'analytics'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'profile'.tr(),
          ),
        ],
      ),
    );
  }
}
