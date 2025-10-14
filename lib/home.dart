import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:application/auth_service.dart';
import 'package:application/chat_service.dart';
import 'package:application/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService authService = AuthService();
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Format last seen text
  String formatLastSeen(dynamic lastSeen) {
    if (lastSeen == null) return 'Last seen: unknown';
    DateTime lastSeenTime;

    if (lastSeen is DateTime) {
      lastSeenTime = lastSeen;
    } else if (lastSeen is int) {
      lastSeenTime = DateTime.fromMillisecondsSinceEpoch(lastSeen);
    } else if (lastSeen is Timestamp) {
      lastSeenTime = lastSeen.toDate();
    } else {
      return 'Last seen: unknown';
    }

    final now = DateTime.now();
    final diff = now.difference(lastSeenTime);

    if (diff.inMinutes < 1) return 'Last seen: just now';
    if (diff.inMinutes < 60) return 'Last seen: ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'Last seen: ${diff.inHours} hr ago';
    return 'Last seen: ${lastSeenTime.day}/${lastSeenTime.month}/${lastSeenTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 85, 19, 142),
        title: const Text(
          '𝗕𝘂𝘇𝘇𝗖𝗵𝗮𝘁',
          style: TextStyle(color: CupertinoColors.tertiarySystemBackground),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: CupertinoColors.extraLightBackgroundGray,
            ),
            tooltip: 'Sign Out',
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to sign out?'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await authService.signOut();
              }
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.chat),
        label: const Text("New Chat"),
        onPressed: () {
          _openNewChatDialog(context, _chatService);
        },
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(
              child: Text('No users available to chat with'),
            );
          }

          // ✅ Apply search filter
          final filteredUsers = users.where((user) {
            final name = (user['displayName'] ?? '').toLowerCase();
            final email = (user['email'] ?? '').toLowerCase();
            final query = _searchQuery.toLowerCase();

            final isNotSelf = user['email'] != currentUser?.email;
            final matchesQuery = query.isEmpty ||
                name.contains(query) ||
                email.contains(query);

            return isNotSelf && matchesQuery;
          }).toList();

          return Column(
            children: [
              // Current user card
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.deepPurple.shade50,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: currentUser?.photoURL != null
                          ? NetworkImage(currentUser!.photoURL!)
                          : null,
                      child: currentUser?.photoURL == null
                          ? Text(
                              currentUser?.displayName?[0] ?? 'U',
                              style: const TextStyle(fontSize: 24),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentUser?.displayName ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            currentUser?.email ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ Search bar (working)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.deepPurple),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepPurple.shade100),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),

              // ✅ Filtered list
              Expanded(
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user['photoURL'] != null
                              ? NetworkImage(user['photoURL'])
                              : null,
                          child: user['photoURL'] == null
                              ? Text(user['displayName']?[0] ?? 'U')
                              : null,
                        ),
                        title: Text(
                          user['displayName'] ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(formatLastSeen(user['lastSeen'])),
                        trailing: const Icon(Icons.chat_bubble_outline),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                receiverEmail: user['email'],
                                receiverId: user['uid'],
                                receiverName:
                                    user['displayName'] ?? 'Unknown',
                                receiverPhotoUrl: user['photoURL'],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openNewChatDialog(BuildContext context, ChatService chatService) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Start New Chat"),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: "Enter user's email",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;

              final user = await chatService.findUserByEmail(email);

              if (context.mounted) Navigator.pop(context);

              if (user != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      receiverEmail: user['email'],
                      receiverId: user['uid'],
                      receiverName: user['displayName'] ?? 'Unknown',
                      receiverPhotoUrl: user['photoURL'],
                    ),
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User not found.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text("Chat"),
          ),
        ],
      ),
    );
  }
}

extension on ChatService {
  Future findUserByEmail(String email) async {}
}
