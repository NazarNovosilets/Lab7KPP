import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_strings.dart';
import 'models/user_model.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Оновлений метод _register з інтеграцією Firebase Auth та Firestore (Завдання 3)
  void _register() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // 1. Реєстрація користувача через Firebase Auth [cite: 588]
        final UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final User? user = userCredential.user;

        if (user != null) {
          // 2. Створення запису користувача у Firestore [cite: 588]
          final UserModel newUser = UserModel(
            id: user.uid,
            nickname: _nicknameController.text.trim(),
            email: user.email!,
          );

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set(newUser.toMap());

          // Якщо успішно, AuthChecker в main.dart автоматично перенаправить
          if (mounted) {
            // Закриваємо сторінку реєстрації
            Navigator.of(context).pop();
          }
        }
      } on FirebaseAuthException catch (e) {
        // Обробка помилок
        String errorMessage = 'Помилка реєстрації: ${e.code}';
        if (e.code == 'weak-password') {
          errorMessage = 'Пароль занадто простий.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'Цей e-mail вже використовується.'; // [cite: 590]
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
    const Color hintColor = Color(0xFFAAAAAA);

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
          hintStyle: const TextStyle(color: hintColor),
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: iconColor, size: 20),
          prefixIconConstraints: const BoxConstraints(minWidth: 40),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFF0F4FF);
    const Color buttonColor = Color(0xFF1A1A3A);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(AppStrings.signUpTitle),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: buttonColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24.0),
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: const [],
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
                    AppStrings.signUpTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    AppStrings.signUpSubtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 24),

                  /// Нікнейм
                  _buildLabel(AppStrings.nicknameLabel),
                  _buildTextFormField(
                    controller: _nicknameController,
                    hint: 'Ваш нікнейм',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.errorEmptyField;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  /// Email
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
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(value)) {
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
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? _buildLoadingIndicator()
                        : Text(
                      AppStrings.submitButtonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text.rich(
                      TextSpan(
                        text: AppStrings.alreadyHaveAccount,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: AppStrings.signInButtonText,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4C8CFF),
                              decoration: TextDecoration.none,
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
}