import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'agri_chat.dart';

class FloatingRobot extends StatelessWidget {
  const FloatingRobot({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Transform.translate(
          offset: const Offset(20, 30),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AgriChatBot(),
                ),
              );
            },
            child: SizedBox(
              height: 220,
              width: 220,
              child: Lottie.asset(
                "assets/lottie/chatbot.json",
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
