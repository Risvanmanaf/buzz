import 'package:application/auth_service.dart';
import 'package:application/screen.dart/login.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {


  // logout 
 
 Future<void>logout()async{
  showDialog(context: context, builder: (context)=>AlertDialog(
    title: Text('Logout'),
    content: Text('Are you sure you want to logout'),
    actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
          
            final authService = AuthService();
            await authService.signOut();

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          },
          child: const Text('Logout'),
        ),
      ],
  ));
 }

  // custom widget
  Widget _buildChatCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
      Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const ChatPage()),
);

      },
      child: Column(
        children: [
          Container(
            height: 80,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black26,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Name', style: TextStyle(fontSize: 16)),
                          Text(
                            'last seen',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 2),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return _buildChatCard(context);
        },
      ),
    );
  }
}

// Chat page to navigate
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat Page")),
      body: const Center(child: Text("This is the chat interface")),
    );
  }
}
