import 'package:flutter/material.dart';
import 'package:application/auth_service.dart';
import 'package:application/chat_service.dart';
import 'package:application/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final ChatService chatService = ChatService();
    final currentUser = authService.currentUser;

    return Scaffold(
     appBar: AppBar(
  title: const Text('BuzzChat'),
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
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
          _openNewChatDialog(context, chatService);
        },
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: chatService.getUsersStream(),
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

          return Column(
            children: [
              // Current user info card
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

              const Padding(
                padding: EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Start a conversation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    if (user['email'] == currentUser?.email) return const SizedBox(); // Skip self

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
                        subtitle: Text(user['email'] ?? ''),
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

  // 🔹 Opens a dialog for manual new chat input
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
