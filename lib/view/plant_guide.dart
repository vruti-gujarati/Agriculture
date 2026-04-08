import 'dart:convert';
import 'dart:io';
import 'floating_robot.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:dotted_border/dotted_border.dart';

const String geminiApiKey = "";

// ─── Design Tokens ────────────────────────────────────────────────
class _C {
  static const bg          = Color(0xFFF4FAF5);
  static const surface     = Color(0xFFFFFFFF);
  static const primary     = Color(0xFF2D7A45);
  static const primaryLight= Color(0xFF4CAF6A);
  static const accent      = Color(0xFFA8D5B5);
  static const accentWarm  = Color(0xFFD4EDDA);
  static const textDark    = Color(0xFF1B3A27);
  static const textMid     = Color(0xFF4A7A5C);
  static const textLight   = Color(0xFF8BB59A);
  static const healthy     = Color(0xFF2E7D32);
  static const healthyBg   = Color(0xFFE8F5E9);
  static const unhealthy   = Color(0xFFC62828);
  static const unhealthyBg = Color(0xFFFFEBEE);
  static const warning     = Color(0xFFF9A825);
  static const warningBg   = Color(0xFFFFFDE7);
}

class PlantGuide extends StatefulWidget {
  const PlantGuide({super.key});

  @override
  State<PlantGuide> createState() => _PlantGuideState();
}

class _PlantGuideState extends State<PlantGuide>
    with SingleTickerProviderStateMixin {

  File? _selectedImage;
  bool _isLoading = false;
  Map<String, dynamic>? _analysisResult;

  final ImagePicker _picker = ImagePicker();
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _setLoading(bool value) => setState(() => _isLoading = value);

  // ─── Image Picker ────────────────────────────────────────────────
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

  // ─── Bottom Sheet Popup ──────────────────────────────────────────
  void _showImageSourcePopup() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: _C.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // pill handle
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: _C.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                "Select Image Source",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _C.textDark,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Choose how you'd like to add your plant photo",
                style: TextStyle(fontSize: 13, color: _C.textLight),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _sheetButton(
                      icon: Icons.camera_alt_rounded,
                      label: "Camera",
                      subtitle: "Take a photo",
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _sheetButton(
                      icon: Icons.photo_library_rounded,
                      label: "Gallery",
                      subtitle: "Pick existing",
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sheetButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE8F5E9), Color(0xFFF1FAF3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.accent, width: 1.2),
          ),
          child: Column(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: _C.primaryLight,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _C.primaryLight.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
              Text(label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _C.textDark,
                    fontSize: 14,
                  )),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: const TextStyle(
                    fontSize: 11, color: _C.textLight,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Gemini API (unchanged logic) ────────────────────────────────
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
        setState(() => _analysisResult = result);
      } else {
        Fluttertoast.showToast(msg: "API Error");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      _setLoading(false);
    }
  }

  // ─── Result Cards ─────────────────────────────────────────────────
  Widget _buildResult() {
    if (_analysisResult == null) return const SizedBox();

    final String health = (_analysisResult!['health'] ?? "").toLowerCase();

    Color cardBg, borderColor, badgeColor;
    IconData healthIcon;
    String healthLabel;

    if (health.contains("healthy")) {
      cardBg = _C.healthyBg;
      borderColor = _C.healthy;
      badgeColor = _C.healthy;
      healthIcon = Icons.check_circle_rounded;
      healthLabel = "Healthy";
    } else if (health.contains("unhealthy")) {
      cardBg = _C.unhealthyBg;
      borderColor = _C.unhealthy;
      badgeColor = _C.unhealthy;
      healthIcon = Icons.cancel_rounded;
      healthLabel = "Unhealthy";
    } else {
      cardBg = _C.warningBg;
      borderColor = _C.warning;
      badgeColor = _C.warning;
      healthIcon = Icons.warning_rounded;
      healthLabel = "Needs Attention";
    }

    final List<_CardData> cards = [
      _CardData(
        icon: Icons.grass_rounded,
        title: "Crop Type",
        value: _analysisResult!['cropType'] ?? "",
        iconColor: _C.primary,
      ),
      _CardData(
        icon: healthIcon,
        title: "Health Status",
        value: _analysisResult!['health'] ?? "",
        iconColor: badgeColor,
      ),
      _CardData(
        icon: Icons.bug_report_rounded,
        title: "Diseases",
        value: (_analysisResult!['diseases'] ?? []).join(', '),
        iconColor: _C.unhealthy,
      ),
      _CardData(
        icon: Icons.science_rounded,
        title: "Fertilization",
        value: _analysisResult!['fertilization'] ?? "",
        iconColor: const Color(0xFF6A4C93),
      ),
      _CardData(
        icon: Icons.water_drop_rounded,
        title: "Water Level",
        value: _analysisResult!['waterLevel'] ?? "",
        iconColor: const Color(0xFF1565C0),
      ),
      _CardData(
        icon: Icons.emoji_objects_rounded,
        title: "Next Steps",
        value: _analysisResult!['nextSteps'] ?? "",
        iconColor: _C.warning,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              Container(
                width: 4, height: 22,
                decoration: BoxDecoration(
                  color: _C.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Analysis Report",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _C.textDark,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),

        ...cards.map((c) => _infoCard(c, cardBg, borderColor)).toList(),
      ],
    );
  }

  Widget _infoCard(_CardData c, Color cardBg, Color borderColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: c.iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(c.icon, color: c.iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: c.iconColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c.value.isEmpty ? "—" : c.value,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: _C.textDark,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Loading Shimmer ──────────────────────────────────────────────
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            builder: (_, val, child) => Opacity(opacity: val, child: child),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: _C.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Analyzing your plant…",
                  style: TextStyle(
                    color: _C.textMid,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(3, (_) => _shimmerCard()),
        ],
      ),
    );
  }

  Widget _shimmerCard() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, __) => Transform.scale(
        scale: _pulseAnim.value,
        child: Container(
          height: 70,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _C.accentWarm,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  // ─── Upload Box ───────────────────────────────────────────────────
  Widget _buildUploadBox() {
    return GestureDetector(
      onTap: _showImageSourcePopup,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            radius: const Radius.circular(24),
            dashPattern: const [8, 4],
            strokeWidth: 1.8,
            color: _C.primaryLight,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: _selectedImage == null
                  ? const LinearGradient(
                colors: [Color(0xFFF0FAF3), Color(0xFFE8F5ED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
                  : null,
              borderRadius: BorderRadius.circular(24),
            ),
            child: _selectedImage == null
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, child) => Transform.scale(
                    scale: _pulseAnim.value,
                    child: child,
                  ),
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: _C.primaryLight.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 40,
                      color: _C.primaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Tap to Upload Plant Photo",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _C.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Camera or Gallery • JPG / PNG",
                  style: TextStyle(
                    fontSize: 12,
                    color: _C.textLight,
                  ),
                ),
              ],
            )
                : Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
                // re-pick overlay
                Positioned(
                  bottom: 12, right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh_rounded,
                            color: Colors.white, size: 14),
                        SizedBox(width: 5),
                        Text("Change",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [
          // subtle leaf pattern background
          Positioned.fill(
            child: CustomPaint(painter: _LeafPatternPainter()),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                _buildAppBar(),
                // Body
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildUploadBox(),
                        const SizedBox(height: 24),
                        if (_isLoading) _buildLoadingState(),
                        if (!_isLoading) _buildResult(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Floating robot
          const FloatingRobot(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D7A45), Color(0xFF4CAF6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: _C.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.eco_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Plant Guide",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                "AI-powered crop analysis",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline_rounded,
                color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────
class _CardData {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;
  const _CardData({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
  });
}

// ─── Leaf Pattern Background ─────────────────────────────────────────────────
class _LeafPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF66BB6A).withOpacity(0.04)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final cx = (i % 3) * size.width / 2.5 + 60;
      final cy = (i ~/ 3) * size.height / 1.8 + 80;
      final path = Path();
      path.moveTo(cx, cy - 30);
      path.cubicTo(cx + 25, cy - 20, cx + 25, cy + 20, cx, cy + 30);
      path.cubicTo(cx - 25, cy + 20, cx - 25, cy - 20, cx, cy - 30);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}