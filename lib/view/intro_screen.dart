import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agriculture/view/login_screen.dart';


class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {

  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ── Animation controllers ────────────────────────────────────────────────
  late AnimationController _bgCtrl;       // watercolor blob float
  late AnimationController _particleCtrl; // leaf particles
  late AnimationController _floatCtrl;    // image float up/down
  late AnimationController _entryCtrl;    // text entry per page
  late AnimationController _btnCtrl;      // button pulse

  late Animation<double> _floatAnim;
  late Animation<double> _btnScale;

  // ── Page data ────────────────────────────────────────────────────────────
  final List<_PageData> _pages = [
    _PageData(
      title: 'The Next Generation\nof Farming',
      description: 'We provide smart data that enables the goals of modern global agriculture.',
      imagePath: 'assets/intro_screen/first.png',
      accentColor: const Color(0xFF2D6A4F),
      tagColor: const Color(0xFFD4F5E2),
      tagIcon: Icons.agriculture_rounded,
      tagLabel: 'Smart Farming',
    ),
    _PageData(
      title: 'Detect Crop Diseases\nEasily',
      description: 'Scan your plant using the camera and identify diseases instantly with AI.',
      imagePath: 'assets/intro_screen/diseases.png',
      accentColor: const Color(0xFF40916C),
      tagColor: const Color(0xFFC8ECDA),
      tagIcon: Icons.document_scanner_rounded,
      tagLabel: 'AI Scanner',
    ),
    _PageData(
      title: 'Track Your Farm\nHealth',
      description: 'Monitor crops and keep a full history of all issues and treatments.',
      imagePath: 'assets/intro_screen/farm.png',
      accentColor: const Color(0xFF1B4332),
      tagColor: const Color(0xFFB7E4C7),
      tagIcon: Icons.favorite_rounded,
      tagLabel: 'Farm Health',
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 5000))
      ..repeat(reverse: true);

    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3500))
      ..repeat();

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: 8).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _entryCtrl.forward();

    _btnCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _btnScale = Tween<double>(begin: 1.0, end: 1.03).animate(
        CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgCtrl.dispose();
    _particleCtrl.dispose();
    _floatCtrl.dispose();
    _entryCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _goHome();
    }
  }

  void _goHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _entryCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final data = _pages[_currentPage];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFEAF7F0),
        body: Stack(
          children: [

            // ── 1. Animated watercolor blob background ─────────────────
            AnimatedBuilder(
              animation: _bgCtrl,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _WatercolorBgPainter(
                    _bgCtrl.value, data.accentColor),
              ),
            ),

            // ── 2. Floating leaf particles ──────────────────────────────
            AnimatedBuilder(
              animation: _particleCtrl,
              builder: (_, __) => CustomPaint(
                size: size,
                painter: _LeafParticlePainter(_particleCtrl.value),
              ),
            ),

            // ── 3. Top image area (60% of screen) ──────────────────────
            SizedBox(
              height: size.height * 0.62,
              width: double.infinity,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (_, index) =>
                    _buildImageSlide(_pages[index], size),
              ),
            ),

            // ── 4. Bottom white sheet ───────────────────────────────────
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomSheet(size, data),
            ),

            // ── 5. Skip button ──────────────────────────────────────────
            if (_currentPage < _pages.length - 1)
              Positioned(
                top: MediaQuery.of(context).padding.top + 14,
                right: 16,
                child: GestureDetector(
                  onTap: _goHome,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.70),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Skip',
                                style: TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF2D6A4F),
                                    fontWeight: FontWeight.w700)),
                            SizedBox(width: 4),
                            Icon(Icons.close_rounded,
                                size: 13, color: Color(0xFF2D6A4F)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // ── 6. Page number badge (top-left) ─────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + 14,
              left: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.70)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF52B788),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_currentPage + 1} / ${_pages.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2D6A4F),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Image slide with floating effect + tag badge ─────────────────────────
  Widget _buildImageSlide(_PageData page, Size size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Floating image
        AnimatedBuilder(
          animation: _floatAnim,
          builder: (_, child) => Transform.translate(
            offset: Offset(0, -_floatAnim.value),
            child: child,
          ),
          child: SizedBox(
            width: double.infinity,
            height: size.height * 0.62,
            child: Image.asset(
              page.imagePath,
              fit: BoxFit.cover, // 🔥 makes it full like your second code
              errorBuilder: (_, __, ___) => _fallbackImage(page),
            ),

          ),
        ),

        // Floating tag badge (bottom of image)
        Positioned(
          bottom: 22,
          child: AnimatedBuilder(
            animation: _entryCtrl,
            builder: (_, child) => FadeTransition(
              opacity: _entryCtrl,
              child: SlideTransition(
                position: Tween<Offset>(
                    begin: const Offset(0, 0.4), end: Offset.zero)
                    .animate(CurvedAnimation(
                    parent: _entryCtrl, curve: Curves.easeOutCubic)),
                child: child,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.72),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.85), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: page.accentColor.withOpacity(0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: page.tagColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(page.tagIcon,
                            color: page.accentColor, size: 16),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        page.tagLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: page.accentColor,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Fallback when image asset is missing ─────────────────────────────────
  Widget _fallbackImage(_PageData page) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            page.tagColor,
            page.accentColor.withOpacity(0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.55),
                shape: BoxShape.circle,
              ),
              child: Icon(page.tagIcon,
                  color: page.accentColor, size: 50),
            ),
            const SizedBox(height: 16),
            Text(page.tagLabel,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: page.accentColor)),
          ],
        ),
      ),
    );
  }

  // ── Bottom white card ─────────────────────────────────────────────────────
  Widget _buildBottomSheet(Size size, _PageData data) {
    return Container(
      height: size.height * 0.44,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(38),
          topRight: Radius.circular(38),
        ),
        boxShadow: [
          BoxShadow(
            color: data.accentColor.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // ── Decorative top handle ──────────────────────────────────
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFB7E4C7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Title ──────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _entryCtrl,
            builder: (_, child) => FadeTransition(
              opacity: CurvedAnimation(
                  parent: _entryCtrl,
                  curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
              child: SlideTransition(
                position: Tween<Offset>(
                    begin: const Offset(0, 0.12), end: Offset.zero)
                    .animate(CurvedAnimation(
                    parent: _entryCtrl,
                    curve: const Interval(0.0, 0.7,
                        curve: Curves.easeOutCubic))),
                child: child,
              ),
            ),
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: data.accentColor,
                height: 1.28,
                letterSpacing: -0.3,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Description ────────────────────────────────────────────
          AnimatedBuilder(
            animation: _entryCtrl,
            builder: (_, child) => FadeTransition(
              opacity: CurvedAnimation(
                  parent: _entryCtrl,
                  curve: const Interval(0.25, 0.85, curve: Curves.easeOut)),
              child: child,
            ),
            child: Text(
              data.description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                color: Color(0xFF7A9B8A),
                height: 1.65,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          const Spacer(),

          // ── Page dots ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
                  (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == i ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? data.accentColor
                      : const Color(0xFFB7E4C7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Next / Get Started button ───────────────────────────────
          AnimatedBuilder(
            animation: _btnScale,
            builder: (_, child) => Transform.scale(
              scale: _btnScale.value,
              child: child,
            ),
            child: GestureDetector(
              onTap: _onNext,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF52B788),
                      data.accentColor,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: data.accentColor.withOpacity(0.38),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Watercolor Background Painter — same as splash screen
// ════════════════════════════════════════════════════════════════════════════
class _WatercolorBgPainter extends CustomPainter {
  final double t;
  final Color accentColor;
  _WatercolorBgPainter(this.t, this.accentColor);

  @override
  void paint(Canvas canvas, Size size) {
    // Base mint gradient
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFE8F8F0), Color(0xFFF2FAF4)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Animated watercolor blobs
    final blobs = [
      // Top-right large blob
      _BlobData(
        x: size.width * (0.82 + 0.04 * math.sin(t * math.pi)),
        y: size.height * (0.08 + 0.03 * math.cos(t * math.pi)),
        r: size.width * 0.52,
        opacity: 0.30,
      ),
      // Left mid blob
      _BlobData(
        x: size.width * (0.10 + 0.03 * math.cos(t * math.pi * 1.2)),
        y: size.height * (0.25 + 0.04 * math.sin(t * math.pi * 0.9)),
        r: size.width * 0.44,
        opacity: 0.22,
      ),
      // Bottom-right blob
      _BlobData(
        x: size.width * (0.70 + 0.04 * math.sin(t * math.pi * 1.3)),
        y: size.height * (0.72 + 0.03 * math.cos(t * math.pi * 0.8)),
        r: size.width * 0.40,
        opacity: 0.18,
      ),
      // Bottom-left blob
      _BlobData(
        x: size.width * (0.18 + 0.03 * math.sin(t * math.pi * 1.5)),
        y: size.height * (0.82 + 0.02 * math.cos(t * math.pi)),
        r: size.width * 0.38,
        opacity: 0.14,
      ),
    ];

    for (final b in blobs) {
      canvas.drawCircle(
        Offset(b.x, b.y),
        b.r,
        Paint()
          ..color = const Color(0xFF74C69D).withOpacity(b.opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
      );
    }
  }

  @override
  bool shouldRepaint(_WatercolorBgPainter old) =>
      old.t != t || old.accentColor != accentColor;
}

class _BlobData {
  final double x, y, r, opacity;
  const _BlobData(
      {required this.x, required this.y, required this.r, required this.opacity});
}

// ════════════════════════════════════════════════════════════════════════════
//  Leaf Particle Painter — same as splash screen
// ════════════════════════════════════════════════════════════════════════════
class _LeafParticlePainter extends CustomPainter {
  final double t;
  _LeafParticlePainter(this.t);

  // Seed positions: [relX, relY, phaseOffset, size]
  static const _seeds = [
    [0.05, 0.08, 0.00, 1.0],
    [0.88, 0.06, 0.28, 0.8],
    [0.12, 0.55, 0.55, 1.2],
    [0.82, 0.52, 0.82, 0.9],
    [0.22, 0.88, 0.14, 0.7],
    [0.72, 0.82, 0.42, 1.1],
    [0.46, 0.04, 0.68, 0.8],
    [0.90, 0.38, 0.36, 1.0],
    [0.06, 0.72, 0.90, 0.75],
    [0.60, 0.92, 0.60, 0.85],
  ];

  static const _leafColors = [
    Color(0xFF52B788),
    Color(0xFF74C69D),
    Color(0xFF40916C),
    Color(0xFFB7E4C7),
    Color(0xFF2D6A4F),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _seeds.length; i++) {
      final seed = _seeds[i];
      final phase = (t + seed[2]) % 1.0;
      final baseX = seed[0] * size.width;
      final baseY = seed[1] * size.height;
      final sizeScale = seed[3];

      final x = baseX + 14 * math.sin(phase * math.pi * 2 + i * 0.7);
      final y = baseY + 10 * math.cos(phase * math.pi * 2 * 0.8 + i * 0.5);
      final rotation = phase * math.pi * 2 * (i.isEven ? 0.8 : -0.8);
      final opacity = 0.16 + 0.14 * math.sin(phase * math.pi * 2);
      final r = (4.0 + 3.0 * math.sin(phase * math.pi)) * sizeScale;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      // Leaf shape
      final path = Path()
        ..moveTo(0, 0)
        ..cubicTo(-r * 0.55, -r * 0.9, -r * 0.35, -r * 2.0, 0, -r * 2.4)
        ..cubicTo(r * 0.35, -r * 2.0, r * 0.55, -r * 0.9, 0, 0);

      canvas.drawPath(
        path,
        Paint()
          ..color = _leafColors[i % _leafColors.length].withOpacity(opacity),
      );

      // Leaf vein
      if (r > 4) {
        canvas.drawLine(
          Offset.zero,
          Offset(0, -r * 2.0),
          Paint()
            ..color = Colors.white.withOpacity(opacity * 0.6)
            ..strokeWidth = 0.6
            ..strokeCap = StrokeCap.round,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_LeafParticlePainter old) => old.t != t;
}

// ════════════════════════════════════════════════════════════════════════════
//  Page Data Model
// ════════════════════════════════════════════════════════════════════════════
class _PageData {
  final String title;
  final String description;
  final String imagePath;
  final Color accentColor;
  final Color tagColor;
  final IconData tagIcon;
  final String tagLabel;

  const _PageData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.accentColor,
    required this.tagColor,
    required this.tagIcon,
    required this.tagLabel,
  });
}
