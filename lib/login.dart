import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Примітка: переконайтеся, що файл firebase_options.dart
// знаходиться у папці lib/ та містить коректні ключі.
import 'firebase_options.dart';

import 'app_strings.dart';
import 'mainPage.dart';
import 'registrationPage.dart';
import 'providers/post_provider.dart';
import 'providers/post_creation_provider.dart';

// ===================== AUTH CHECKER (Перевірка авторизації) ===========================
class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    // Використовуємо StreamBuilder для реактивної перевірки стану автентифікації
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Якщо очікуємо результат (наприклад, перевірка токена), показуємо спіннер
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Якщо користувач авторизований (snapshot.hasData), переходимо на головну сторінку
        if (snapshot.hasData && snapshot.data != null) {
          return const mainPage();
        }

        // Інакше - на сторінку входу
        return const LoginPage();
      },
    );
  }
}

// ===================== MY APP ===========================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthChecker(),
    );
  }
}

// ===================== MAIN FUNCTION ===========================
void main() async {
  // 1. ПОТРІБНО БУТИ ПЕРШИМ ВИКЛИКОМ ДЛЯ БУДЬ-ЯКОЇ ВЗАЄМОДІЇ З ПЛАГІНАМИ/BINDINGS
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Ініціалізація Firebase Core (АСИНХРОННА ОПЕРАЦІЯ)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Ініціалізація Sentry та запуск застосунку в зоні Sentry
  await SentryFlutter.init(
        (options) {
      options.dsn =
      'https://2795871429a6051b9161d9fc5a9bcfb1@o4510279175176192.ingest.de.sentry.io/4510279801438288';
    },
    appRunner: () => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PostProvider()),
          // Примітка: loadPostsWithError потрібно буде замінити на реальну логіку Firestore
          ChangeNotifierProvider(create: (_) => PostProvider()..loadPostsWithError()),
          ChangeNotifierProvider(create: (_) => PostCreationProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

// ===================== LOGIN PAGE (ВИПРАВЛЕНО) ===========================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  // !!! ВИПРАВЛЕННЯ: Додано обов'язковий метод createState() !!!
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Логіка входу через Firebase Auth
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // AuthChecker автоматично перенаправить на головний екран
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Помилка входу: ${e.code}';
        if (e.code == 'user-not-found') {
          errorMessage = 'Користувача з таким e-mail не знайдено.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Невірний пароль.';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Виникла невідома помилка.')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _logTestError() async {
    try {
      throw Exception('TEST: Non-fatal помилка для ЛР №4 (Sentry.io)');
    } catch (exception, stackTrace) {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Тестова помилка Sentry зафіксована.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFF0F4FF);
    const Color buttonColor = Color(0xFF1A1A3A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: const Color(0xFFD4E0FF),
                width: 1.0,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    AppStrings.signInTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.signInSubtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildLabel(AppStrings.emailLabel),
                  _buildTextFormField(
                    controller: _emailController,
                    hint: 'example@email.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.errorEmptyField;
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return AppStrings.errorInvalidEmail;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildLabel(AppStrings.passwordLabel),
                  _buildTextFormField(
                    controller: _passwordController,
                    hint: AppStrings.passwordHint,
                    icon: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.errorEmptyField;
                      }
                      if (value.length < 6) {
                        return AppStrings.errorPasswordLength;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? _buildLoadingIndicator()
                        : Text(
                      AppStrings.signInButtonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: _logTestError,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: buttonColor,
                      backgroundColor: Colors.amber.shade100,
                    ),
                    child: const Text(
                      'Згенерувати Test Error (Sentry.io)',
                      style:
                      TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistrationPage(),
                        ),
                      );
                    },
                    child: Text.rich(
                      TextSpan(
                        text: AppStrings.noAccountYet,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: AppStrings.registerLink,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4C8CFF),
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    const Color borderColor = Color(0xFFE0E0E0);
    const Color iconColor = Color(0xFFAAAAAA);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: isPassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: iconColor, size: 20),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}