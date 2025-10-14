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

//   Future<void> _loadUserTheme() async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     final doc = await _firestore.collection('users').doc(user.uid).get();

//     if (doc.exists && doc.data()?['theme'] != null) {
//       final theme = doc['theme'];
//       if (theme == 'dark') {
//         _themeMode = ThemeMode.dark;
//       } else if (theme == 'light') {
//         _themeMode = ThemeMode.light;
//       } else {
//         _themeMode = ThemeMode.system;
//       }
//     } else {
//       _themeMode = ThemeMode.system;
//     }
//     notifyListeners();
//   }

//   Future<void> toggleTheme() async {
//     if (_themeMode == ThemeMode.dark) {
//       await _setTheme('light');
//       _themeMode = ThemeMode.light;
//     } else {
//       await _setTheme('dark');
//       _themeMode = ThemeMode.dark;
//     }
//     notifyListeners();
//   }

//   Future<void> _setTheme(String theme) async {
//     final user = _auth.currentUser;
//     if (user == null) return;
//     await _firestore.collection('users').doc(user.uid).set({
//       'theme': theme,
//     }, SetOptions(merge: true));
//   }
// }
