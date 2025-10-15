import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🧑‍🤝‍🧑 Get all users except current user
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != _auth.currentUser!.uid)
          .map((doc) => doc.data())
          .toList();
    });
  }

  // 💬 Send message
  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // Chat room ID
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    // Message data
    Map<String, dynamic> newMessage = {
      'senderId': currentUserId,
      'senderEmail': currentUserEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'isRead': false,
    };

    // Add message
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage);

    // Update metadata
    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'participants': [currentUserId, receiverId],
      'lastMessage': message,
      'lastMessageTime': timestamp,
      'lastMessageSender': currentUserId,
    }, SetOptions(merge: true));
  }

  // 📨 Get messages stream
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // 💭 Get chat rooms for current user
  Stream<QuerySnapshot> getChatRooms() {
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: _auth.currentUser!.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  // 🔍 Get username by email
  Future<String?> getUsernameByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first['displayName'] ?? 'Unknown';
      }
      return null;
    } catch (e) {
      print('⚠️ Error fetching username: $e');
      return null;
    }
  }

  // 🆔 Get user ID by email
  Future<String?> getUserIdByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.id;
      }
      return null;
    } catch (e) {
      print('⚠️ Error fetching userId: $e');
      return null;
    }
  }

  // 🖼️ Get user profile photo by email
  Future<String?> getUserPhotoByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first['photoURL'];
      }
      return null;
    } catch (e) {
      print('⚠️ Error fetching photoURL: $e');
      return null;
    }
  }
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: email)
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    return snapshot.docs.first.data();
  } else {
    return null;
  }
}

}
