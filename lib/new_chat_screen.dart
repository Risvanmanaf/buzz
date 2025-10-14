import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔍 Fetch username from email
  Future<String?> getUsernameByEmail(String email) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first['name'];
      } else {
        print("⚠️ No user found for email: $email");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching username: $e");
      return null;
    }
  }
}
