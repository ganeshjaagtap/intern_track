import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {

  final String title;

  const ChatScreen({super.key, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final TextEditingController messageController = TextEditingController();

  final List<String> messages = [];

  void sendMessage() {

    if (messageController.text.trim().isEmpty) return;

    setState(() {
      messages.add(messageController.text.trim());
    });

    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: Column(
        children: [

          /// MESSAGE LIST

          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      "No messages yet 👋",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {

                      return Align(
                        alignment: Alignment.centerRight,

                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),

                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(14),
                          ),

                          child: Text(
                            messages[index],
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          /// MESSAGE INPUT

          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.orange.shade100,

            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: messageController,

                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blue,

                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}