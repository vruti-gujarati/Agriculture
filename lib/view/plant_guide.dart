import 'dart:convert';
import 'dart:io';
import 'floating_robot.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';

const String geminiApiKey = "AIzaSyAmUnyYi8f_1XRhr7RAOiybATh-8anv5xM";

class PlantGuide extends StatefulWidget {
  const PlantGuide({super.key});

  @override
  State<PlantGuide> createState() => _PlantGuideState();
}

class _PlantGuideState extends State<PlantGuide> {

  File? _selectedImage;
  bool _isLoading = false;
  Map<String, dynamic>? _analysisResult;

  final ImagePicker _picker = ImagePicker();

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  /// PICK IMAGE
  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _analysisResult = null;
      });

      Navigator.pop(context);
      await analyzePlantImage(_selectedImage!);
    }
  }

  /// POPUP
  void _showImageSourcePopup() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F4),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Text(
                  "Choose how you'd like to pick image",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 20),

                _popupButton(
                  icon: Icons.camera_alt,
                  text: "Camera",
                  onTap: () => _pickImage(ImageSource.camera),
                ),

                const SizedBox(height: 15),

                _popupButton(
                  icon: Icons.photo,
                  text: "Gallery",
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _popupButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        splashColor: const Color(0xFF66BB6A).withOpacity(0.3),
        highlightColor: const Color(0xFF66BB6A).withOpacity(0.15),
        onTap: onTap,
        child: Ink(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFF66BB6A)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF66BB6A)),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF66BB6A),
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  /// GEMINI API
  Future<void> analyzePlantImage(File selectedImage) async {
    _setLoading(true);

    try {
      final bytes = await selectedImage.readAsBytes();
      final base64Image = base64Encode(bytes);

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=$geminiApiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'system_instruction': {
            'parts': [
              {
                'text':
                'You are an expert agronomist. Analyze the plant photo and provide complete information about crop type, health, fertilization, diseases, water level required, and next steps for the user.'
              }
            ]
          },
          'contents': [
            {
              'parts': [
                {
                  'text':
                  'Analyze this crop image and return JSON in this format:\n{\n"cropType": "Crop Name",\n"health": "Healthy/Unhealthy/Needs Attention",\n"diseases": ["Disease1"],\n"fertilization": "Fertilizer type and schedule",\n"waterLevel": "Required water level",\n"nextSteps": "What user should do next"\n}',
                },
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image,
                  },
                },
              ],
            },
          ],
          'generationConfig': {
            'response_mime_type': 'application/json',
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String textResponse =
        data['candidates'][0]['content']['parts'][0]['text'];
        final result = jsonDecode(textResponse);

        setState(() {
          _analysisResult = result;
        });

      } else {
        Fluttertoast.showToast(msg: "API Error");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      _setLoading(false);
    }
  }

  /// RESULT BOX → SEPARATE CONTAINERS
  Widget _buildResult() {
    if (_analysisResult == null) return const SizedBox();

    String health = (_analysisResult!['health'] ?? "").toLowerCase();

    Color boxColor = Colors.grey.shade200;
    Color borderColor = Colors.grey;

    if (health.contains("healthy")) {
      boxColor = const Color(0xFFE8F5E9);
      borderColor = Colors.green;
    }
    else if (health.contains("unhealthy")) {
      boxColor = const Color(0xFFFFEBEE);
      borderColor = Colors.red;
    }
    else if (health.contains("attention")) {
      boxColor = const Color(0xFFE0F7E9);
      borderColor = const Color(0xFF66BB6A);
    }

    Widget infoBox(String title, String value) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.90,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: boxColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor, width: 1.3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF66BB6A),
              ),
            ),
            const SizedBox(height: 4),
            Text(value),
          ],
        ),
      );
    }

    return Column(
      children: [
        infoBox("Crop Type", _analysisResult!['cropType'] ?? ""),
        infoBox("Health Status", _analysisResult!['health'] ?? ""),
        infoBox("Diseases", (_analysisResult!['diseases'] ?? []).join(', ')),
        infoBox("Fertilization", _analysisResult!['fertilization'] ?? ""),
        infoBox("Water Level", _analysisResult!['waterLevel'] ?? ""),
        infoBox("Next Steps", _analysisResult!['nextSteps'] ?? ""),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FBF7),
      appBar: AppBar(
        title: const Text("Plant Guide"),
        backgroundColor: const Color(0xFF66BB6A),
      ),
      body: Stack(
        children: [

          // 🌿 Your Existing UI
          SingleChildScrollView(
            child: Column(
              children: [

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: _showImageSourcePopup,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        radius: const Radius.circular(20),
                        dashPattern: const [7, 3],
                        strokeWidth: 1.5,
                        color: const Color(0xFF66BB6A),
                      ),
                      child: Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F8F4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: _selectedImage == null
                            ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.upload, size: 50, color: Color(0xFF66BB6A)),
                            SizedBox(height: 10),
                            Text("Tap to Select Image"),
                          ],
                        )
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (_isLoading)
                  const CircularProgressIndicator(
                    color: Color(0xFF66BB6A),
                  ),

                _buildResult(),

                const SizedBox(height: 40),
              ],
            ),
          ),

          // 🤖 FLOATING ROBOT ADDED
          const FloatingRobot(),

        ],
      ),

    );
  }
}
