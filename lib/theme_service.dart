// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class ThemeService extends ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   ThemeMode _themeMode = ThemeMode.system;
//   ThemeMode get themeMode => _themeMode;

//   ThemeService() {
//     _loadUserTheme();
//   }

//   // 🔹 Load user's saved theme from Firestore
//   Future<void> _loadUserTheme() async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     try {
//       final doc =
//           await _firestore.collection('users').doc(user.uid).get();

//       if (doc.exists && doc.data()?['theme'] != null) {
//         final theme = doc['theme'] as String;
//         if (theme == 'dark') {
//           _themeMode = ThemeMode.dark;
//         } else if (theme == 'light') {
//           _themeMode = ThemeMode.light;
//         } else {
//           _themeMode = ThemeMode.system;
//         }
//       } else {
//         _themeMode = ThemeMode.system;
//       }

//       notifyListeners();
//     } catch (e) {
//       debugPrint("⚠️ Error loading theme: $e");
//     }
//   }

//   // 🔹 Toggle between Light/Dark mode
//   Future<void> toggleTheme() async {
//     if (_themeMode == ThemeMode.dark) {
//       await _saveTheme('light');
//       _themeMode = ThemeMode.light;
//     } else {
//       await _saveTheme('dark');
//       _themeMode = ThemeMode.dark;
//     }
//     notifyListeners();
//   }

//   // 🔹 Save user preference to Firestore
//   Future<void> _saveTheme(String theme) async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     try {
//       await _firestore.collection('users').doc(user.uid).set(
//         {'theme': theme},
//         SetOptions(merge: true),
//       );
//     } catch (e) {
//       debugPrint("⚠️ Error saving theme: $e");
//     }
//   }
// }
