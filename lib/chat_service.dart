import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Safe current user check
  User? get currentUser => _auth.currentUser;

  // 🧑🤝🧑 Get all users except current user (with null safety)
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('users').snapshots().handleError((error) {
      print('❌ Error in getUsersStream: $error');
      return <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    }).map((snapshot) {
      final currentUserId = currentUser?.uid;
      if (currentUserId == null) return [];
      
      return snapshot.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) => doc.data())
          .toList();
    });
  }

  // 💬 Send message (with error handling)
  Future<void> sendMessage(String receiverId, String message) async {
    try {
      final currentUserId = currentUser?.uid;
      final currentUserEmail = currentUser?.email;
      
      if (currentUserId == null || currentUserEmail == null) {
        throw Exception('User not authenticated');
      }

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
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }

  // 📨 Get messages stream (with error handling)
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .handleError((error) {
      print('❌ Error getting messages: $error');
    });
  }

  // 💭 Get chat rooms for current user (with null safety)
  Stream<QuerySnapshot> getChatRooms() {
    final currentUserId = currentUser?.uid;
    if (currentUserId == null) {
      return Stream.empty();
    }

    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .handleError((error) {
      print('❌ Error getting chat rooms: $error');
    });
  }

  // 🔍 Find user by email (with error handling)
  Future<Map<String, dynamic>?> findUserByEmail(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      }
      return null;
    } catch (e) {
      print('❌ Error finding user: $e');
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

      return query.docs.isNotEmpty ? query.docs.first.id : null;
    } catch (e) {
      print('⚠️ Error fetching userId: $e');
      return null;
    }
  }

  // 🔎 Get username by email
  Future<String?> getUsernameByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return query.docs.isNotEmpty 
          ? query.docs.first['displayName'] ?? 'Unknown' 
          : null;
    } catch (e) {
      print('⚠️ Error fetching username: $e');
      return null;
    }
  }

  // 🖼️ Get user photo by email
  Future<String?> getUserPhotoByEmail(String email) async {
    try {
      final query = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return query.docs.isNotEmpty ? query.docs.first['photoURL'] : null;
    } catch (e) {
      print('⚠️ Error fetching photoURL: $e');
      return null;
    }
  }
}
