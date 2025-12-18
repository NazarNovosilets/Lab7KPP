// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
//
// class AuthRepository {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
//
//   Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
//
//   Future<void> signUp({
//     required String email,
//     required String password,
//     required String nickname,
//   }) async {
//     try {
//       await _firebaseAuth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       await _firebaseAuth.currentUser?.updateDisplayName(nickname);
//
//       await _analytics.logSignUp(
//         signUpMethod: 'email_password',
//       );
//       await _analytics.logEvent(
//         name: 'user_registered',
//         parameters: {'nickname_length': nickname.length},
//       );
//
//     } on FirebaseAuthException catch (e) {
//       throw Exception(_mapFirebaseErrorToMessage(e.code));
//     } catch (e) {
//       throw Exception('Помилка реєстрації: ${e.toString()}');
//     }
//   }
//
//   Future<void> signIn({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       await _firebaseAuth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       await _analytics.logLogin(
//         loginMethod: 'email_password',
//       );
//
//     } on FirebaseAuthException catch (e) {
//       throw Exception(_mapFirebaseErrorToMessage(e.code));
//     } catch (e) {
//       throw Exception('Помилка входу: ${e.toString()}');
//     }
//   }
//
//   Future<void> signOut() async {
//     await _firebaseAuth.signOut();
//   }
//
//   String _mapFirebaseErrorToMessage(String errorCode) {
//     switch (errorCode) {
//       case 'email-already-in-use':
//         return 'Цей Email вже зареєстрований.';
//       case 'invalid-email':
//         return 'Некоректний формат Email.';
//       case 'weak-password':
//         return 'Пароль має бути сильнішим (мінімум 6 символів).';
//       case 'user-not-found':
//       case 'wrong-password':
//         return 'Невірний Email або пароль.';
//       case 'user-disabled':
//         return 'Обліковий запис заблоковано.';
//       default:
//         return 'Невідома помилка автентифікації.';
//     }
//   }
// }
