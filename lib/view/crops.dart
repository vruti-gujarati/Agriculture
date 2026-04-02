import 'dart:convert';
import 'dart:io';
import 'floating_robot.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';

const String geminiApiKey = "AIzaSyAmUnyYi8f_1XRhr7RAOiybATh-8anv5xM";

class Crops extends StatefulWidget {
  final String userLocation;
  const Crops({super.key, required this.userLocation});

  @override
  State<Crops> createState() => _CropsState();
}

class _CropsState extends State<Crops> {

  final TextEditingController soilType = TextEditingController();
  final TextEditingController location = TextEditingController();
  final TextEditingController landArea = TextEditingController();

  String waterSource = "Yes";
  String selectedSeason = "Unalu";

  File? _selectedImage;
  bool _isLoading = false;
  Map<String, dynamic>? _result;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    location.text = widget.userLocation; // Auto-fill location
  }

  void _setLoading(bool value){
    setState(() {
      _isLoading = value;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
      Navigator.pop(context);
    }
  }

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

  Future<void> suggestCrop() async {
    if(_selectedImage == null){
      Fluttertoast.showToast(msg: "Please upload land photo");
      return;
    }

    _setLoading(true);

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=$geminiApiKey'
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': '''
You are an expert agricultural advisor AI with deep knowledge of soil science, irrigation management, climate patterns, and Indian crop market trends.

Analyze the following farmer land details carefully:

Soil Type: ${soilType.text}
Location: ${location.text}
Land Area: ${landArea.text}
Water Source Available: $waterSource
Current Season: $selectedSeason

Tasks:
1. Analyze soil suitability from the provided land image and details.
2. Consider water availability and irrigation limitations.
3. Consider historical climate patterns of the given location (rainfall trends, temperature, drought risk).
4. Predict likely weather conditions for the upcoming season.
5. Suggest crops that:
   - Match soil and water conditions
   - Suit the current season
   - Have stable market demand and good selling price
   - Carry lower climate risk

Return response strictly in JSON format:

{
  "bestCrop": "",
  "alternativeCrop": "",
  "waterNeed": "",
  "fertilizerAdvice": "",
  "seasonSuitability": "",
  "estimatedProfitability": "",
  "riskLevel": "",
  "futureWeatherPrediction": "",
  "reason": ""
}

Rules:
- Do NOT add explanation outside JSON.
- Provide practical advice for small and medium farmers.
- Focus on profitability + sustainability.
'''
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

      if(response.statusCode == 200){

        final data = jsonDecode(response.body);
        print("this is response sucess $data");
        final String textResponse =
        data['candidates'][0]['content']['parts'][0]['text'];

        final result = jsonDecode(textResponse);

        setState(() {
          _result = result;
        });

      } else {
        print("this is response sucess ${response.body}");
        Fluttertoast.showToast(msg: "API Error");
      }

    } catch(e){
      print("this is response sucess $e");
      Fluttertoast.showToast(msg: "Error: $e");
    }

    _setLoading(false);
  }

  Widget _inputField(TextEditingController controller, String label, IconData icon){
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        cursorColor: Colors.black,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          floatingLabelStyle: const TextStyle(color: Colors.black),
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.black, width:1),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildResult() {
    if (_result == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(vertical:3),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFF66BB6A), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "🌾 Crop Recommendation",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF388E3C),
              ),
            ),
          ),
          const SizedBox(height: 12),

          _detailRow("Best Crop", _result!['bestCrop']),
          _detailRow("Alternative Crop", _result!['alternativeCrop']),
          _detailRow("Water Need", _result!['waterNeed']),
          _detailRow("Fertilizer Advice", _result!['fertilizerAdvice']),
          _detailRow("Season Suitability", _result!['seasonSuitability']),
          _detailRow("Reason", _result!['reason']),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ New helper to show button only when result is null
  bool _canShowButton() {
    return _result == null;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F1),
      appBar: AppBar(
        title: const Text("Smart Crop Advisor"),
        backgroundColor: const Color(0xFF66BB6A),
        centerTitle: true,
      ),
      body: Stack(
        children: [

          /// 👉 YOUR ORIGINAL SCREEN (UNCHANGED)
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF66BB6A),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "AI Crop Recommendation",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Enter your land details to find best crops",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _inputField(soilType, "Soil Type", Icons.grass),
                _inputField(landArea, "Land Area (acre)", Icons.square_foot),
                _inputField(location, "Full Address[Street, City, State]", Icons.location_on),

                DropdownButtonFormField(
                  value: waterSource,
                  items: ["Yes", "No"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) { setState(() { waterSource = v.toString(); }); },
                  decoration: InputDecoration(
                    labelText: "Water Source Available?",
                    prefixIcon: const Icon(Icons.water),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.black, width:1),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField(
                  value: selectedSeason,
                  items: ["Unalu", "Shiyalu", "Chomasu"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) { setState(() { selectedSeason = v.toString(); }); },
                  decoration: InputDecoration(
                    labelText: "Season",
                    prefixIcon: const Icon(Icons.calendar_today),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.black, width:1),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: _showImageSourcePopup,
                  child: DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      radius: const Radius.circular(20),
                      dashPattern: const [6,3],
                      strokeWidth: 1.5,
                      color: const Color(0xFF66BB6A),
                    ),
                    child: Container(
                      height: 270,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFFF1F8F4),
                      ),
                      child: _selectedImage == null
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.upload, size: 40, color: Color(0xFF66BB6A)),
                          SizedBox(height: 8),
                          Text("Tap to upload land photo")
                        ],
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                if(_result != null) _buildResult(),

                if (_canShowButton())
                  Center(
                    child: SizedBox(
                      width: 250,
                      child: ElevatedButton(
                        onPressed: suggestCrop,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF66BB6A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "Suggest Best Crop",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),// space so robot doesn't overlap
                if(_isLoading)
                  const CircularProgressIndicator(
                    color: Color(0xFF66BB6A),
                  ),
              ],
            ),
          ),

          const FloatingRobot(),

        ],
      ),
    );
  }
}
