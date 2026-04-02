import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



const String geminiApiKey = "AIzaSyAmUnyYi8f_1XRhr7RAOiybATh-8anv5xM";

class AgriChatBot extends StatefulWidget {
  const AgriChatBot({super.key});

  @override
  State<AgriChatBot> createState() => _AgriChatBotState();
}

class _AgriChatBotState extends State<AgriChatBot> {

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];

  bool _isLoading = false;

  final List<String> quickQuestions = [
    "Best crop for this season?",
    "Fertilizer for cotton?",
    "How to stop pests?",
    "Water tips for wheat?"
  ];

  @override
  void initState() {
    super.initState();

    messages.add({
      "role": "bot",
      "text": "Hello Farmer 👋\nAsk me about crops, soil, irrigation or pests."
    });
  }

  Future<void> sendMessage(String message) async {

    if(message.trim().isEmpty) return;

    setState(() {
      messages.add({"role": "user", "text": message});
      _isLoading = true;
    });

    _controller.clear();

    try {

      final url = Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=$geminiApiKey"
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": """
You are an expert agriculture advisor chatbot for Indian farmers.

Rules:
- Give short practical advice
- Suggest crops, fertilizers, irrigation tips
- Focus on Gujarat farming
- Speak simple

Farmer Question:
$message
"""
                }
              ]
            }
          ]
        }),
      );

      if(response.statusCode == 200){

        final data = jsonDecode(response.body);
        final botReply =
        data['candidates'][0]['content']['parts'][0]['text'];

        setState(() {
          messages.add({"role": "bot", "text": botReply});
        });

      } else {
        messages.add({"role": "bot", "text": "Server error"});
      }

    } catch(e){
      messages.add({"role": "bot", "text": "Something went wrong"});
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget buildMessage(Map<String,String> msg){

    bool isUser = msg['role'] == "user";

    return Container(
      margin: const EdgeInsets.symmetric(vertical:6),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF66BB6A) : Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          msg['text'] ?? "",
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F1),
      appBar: AppBar(
        title: const Text("Agri AI Assistant"),
        backgroundColor: const Color(0xFF66BB6A),
        centerTitle: true,
      ),

      body: Stack(
        children: [

          // 🌿 Your Existing Chat UI
          Column(
            children: [

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index){
                    return buildMessage(messages[index]);
                  },
                ),
              ),

              if(messages.length < 3)
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: quickQuestions.map((q){
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal:6),
                        child: ActionChip(
                          label: Text(q),
                          onPressed: (){
                            sendMessage(q);
                          },
                          backgroundColor: const Color(0xFFE8F5E9),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              if(_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF66BB6A),
                      ),
                      SizedBox(width:10),
                      Text("AI is typing...")
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: 25
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal:10, vertical:10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 5)
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Row(
                    children: [

                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Ask farming question...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF1F8F4),
                          ),
                        ),
                      ),

                      const SizedBox(width:8),

                      CircleAvatar(
                        backgroundColor: const Color(0xFF66BB6A),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: (){
                            sendMessage(_controller.text);
                          },
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),

          // 🤖 ADD FLOATING ROBOT HERE


        ],
      ),

    );
  }
}
