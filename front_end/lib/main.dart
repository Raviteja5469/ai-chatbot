// Import necessary packages
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Main entry point of the app
void main() {
  runApp(OllamaApp());
}

// Main application widget
class OllamaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      title: 'Ollama Desktop', // Application title
      theme: ThemeData.dark(), // Application theme
      home: ChatScreen(), // Main screen of the application
    );
  }
}

// Stateful widget for the chat screen
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

// State of the chat screen
class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController(); // Controller for the text input
  String _response = ""; // Variable to hold the response

  // Function to send a request to the server
  Future<void> askOllama(String prompt) async {
    final url = Uri.parse("http://localhost:8000/generate");
    final client = http.Client();
    final request = http.Request('POST', url)
      ..headers['Content-Type'] = 'application/json' // Set the request headers
      ..body = jsonEncode({"prompt": prompt}); // Set the request body

    final streamedResponse = await client.send(request);

    if (streamedResponse.statusCode == 200) {
      final StringBuffer responseBuffer = StringBuffer();
      streamedResponse.stream.transform(utf8.decoder).listen((chunk) {
        responseBuffer.write(chunk); // Append each chunk to the buffer
      }, onDone: () {
        final responseString = responseBuffer.toString();
        print('Response String: $responseString');
        final jsonResponse = jsonDecode(responseString);
        final rawResponse = jsonResponse['raw_response'];
        final responses = rawResponse
            .split('\n')
            .map((response) {
              try {
                final jsonResponse = jsonDecode(response);
                final responseText = jsonResponse['response'];
                if (responseText.contains('<') ||
                    responseText.contains('>') ||
                    responseText.contains('ðŸ˜Š')) {
                  return null; // Ignore responses with HTML tags or ðŸ˜Š character
                }
                return responseText.trim(); // Remove leading and trailing whitespace
              } catch (e) {
                print('Error parsing JSON: $e');
                return null; // Return null if there's an error
              }
            })
            .where((response) => response != null && response.isNotEmpty)
            .toList();

        final responseText = responses.join(' ');
        print('Response Text: $responseText');

        setState(() {
          _response = responseText; // Update the response state
          print('_response: $_response');
        });
      });
    } else {
      setState(() {
        _response =
            "Error: ${streamedResponse.statusCode} ${streamedResponse.reasonPhrase}"; // Update the response state with the error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ollama Chatbot")), // AppBar with title
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller, // Text input controller
              decoration: InputDecoration(
                labelText: "Ask something...", // Input label
                border: OutlineInputBorder(), // Input border
              ),
            ),
            SizedBox(height: 10), // Spacing
            ElevatedButton(
              onPressed: () => askOllama(_controller.text), // Send button action
              child: Text("Send"), // Send button text
            ),
            SizedBox(height: 20), // Spacing
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  "Response: $_response", // Display the response
                  style: TextStyle(fontSize: 16, color: Colors.white), // Response text style
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
