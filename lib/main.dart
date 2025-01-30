import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const FLUTTER_APPLICATION_1());
}

class FLUTTER_APPLICATION_1 extends StatelessWidget {
  const FLUTTER_APPLICATION_1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lallamaa AI Chat',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  // Free API Configuration (DeepSeek)
  final String _apiUrl = "https://api.deepseek.com/v1/chat/completions";
  
  Future<String> _getResponse(String prompt) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${dotenv.env['DEEPSEEK_API_KEY']}",
      },
      body: jsonEncode({
        "model": "deepseek-chat",
        "messages": [
          {"role": "user", "content": prompt}
        ],
        "temperature": 0.7
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['choices'][0]['message']['content'];
    } else {
      throw Exception('API Error: ${response.body}');
    }
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    
    setState(() {
      _messages.add({"text": _controller.text, "isBot": false});
      _messages.add({"text": "Typing...", "isBot": true});
    });

    _controller.clear();
    _scrollToEnd();

    try {
      final response = await _getResponse(_messages[_messages.length - 2]["text"]);
      setState(() {
        _messages.removeLast();
        _messages.add({"text": response, "isBot": true});
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add({"text": "Error: $e", "isBot": true});
      });
    }
    
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lallamaa 🤖"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(
                  text: _messages[index]["text"],
                  isBot: _messages[index]["isBot"],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask Lallamaa...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isBot;

  const ChatBubble({super.key, required this.text, required this.isBot});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBot ? Colors.deepPurple[100] : Colors.blue[100],
        borderRadius: BorderRadius.circular(15),
      ),
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Text(text),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Enable History"),
            subtitle: const Text("Save chat history locally"),
            value: true,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }
}
