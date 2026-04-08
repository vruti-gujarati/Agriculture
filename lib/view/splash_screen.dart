import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import 'language_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // ── Controllers ─────────────────────────────────────────────────────────
  late AnimationController _bgCtrl;      // background blob float
  late AnimationController _entryCtrl;   // staggered element entry
  late AnimationController _leafCtrl;    // floating leaves
  late AnimationController _glowCtrl;    // center glow pulse
  late AnimationController _shimmerCtrl; // logo shimmer
  late AnimationController _exitCtrl;    // exit fade

  // ── Animations ──────────────────────────────────────────────────────────
  late Animation<double> _bgFloat;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _badgeFade;
  late Animation<double> _glowPulse;
  late Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    // ── Background blob float (infinite) ──────────────────────────────────
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat(reverse: true);
    _bgFloat = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut));

    // ── Entry animation (one-shot, 1.8 s) ────────────────────────────────
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));

    _logoScale = Tween<double>(begin: 0.65, end: 1.0).animate(
        CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.0, 0.55, curve: Curves.elasticOut)));

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.0, 0.40, curve: Curves.easeOut)));

    _logoSlide = Tween<Offset>(
        begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic)));

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.40, 0.75, curve: Curves.easeOut)));

    _taglineSlide = Tween<Offset>(
        begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.40, 0.75, curve: Curves.easeOutCubic)));

    _badgeFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.65, 1.0, curve: Curves.easeOut)));

    // ── Floating leaves ───────────────────────────────────────────────────
    _leafCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat(reverse: true);

    // ── Center glow pulse ─────────────────────────────────────────────────
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    // ── Shimmer ───────────────────────────────────────────────────────────
    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat();

    // ── Exit ──────────────────────────────────────────────────────────────
    _exitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));

    // ── Start sequence ────────────────────────────────────────────────────
    _entryCtrl.forward();

    // Navigate after 3.5 s
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      _exitCtrl.forward().then((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => LanguageSelectionScreen(isFromHomeScreen: false,),
            transitionDuration: Duration.zero,
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _entryCtrl.dispose();
    _leafCtrl.dispose();
    _glowCtrl.dispose();
    _shimmerCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: AnimatedBuilder(
        animation: _exitFade,
        builder: (_, child) => Opacity(opacity: _exitFade.value, child: child),
        child: Scaffold(
          backgroundColor: const Color(0xFFF2FAF4),
          body: Stack(
            children: [

              // ── 1. Watercolor blob background ──────────────────────────
              AnimatedBuilder(
                animation: _bgFloat,
                builder: (_, __) => CustomPaint(
                  size: size,
                  painter: _WatercolorBgPainter(_bgFloat.value),
                ),
              ),

              // ── 2. Floating botanical particles ────────────────────────
              AnimatedBuilder(
                animation: _leafCtrl,
                builder: (_, __) => CustomPaint(
                  size: size,
                  painter: _FloatingLeafPainter(_leafCtrl.value),
                ),
              ),

              // ── 3. Main content ────────────────────────────────────────
              SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // ── Center illustration cluster ──────────────────────
                    _buildIllustrationCluster(size),

                    const SizedBox(height: 40),

                    // ── Logo text ────────────────────────────────────────
                    _buildLogoText(),

                    const SizedBox(height: 14),

                    // ── Tagline ──────────────────────────────────────────
                    _buildTagline(),

                    const Spacer(flex: 2),

                    // ── Bottom badge ─────────────────────────────────────
                    _buildBottomBadge(),

                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Illustration cluster ─────────────────────────────────────────────────
  Widget _buildIllustrationCluster(Size size) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entryCtrl, _glowCtrl, _leafCtrl]),
      builder: (_, __) {
        return FadeTransition(
          opacity: _logoFade,
          child: SlideTransition(
            position: _logoSlide,
            child: ScaleTransition(
              scale: _logoScale,
              child: SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [

                    // Outer watercolor glow ring
                    Opacity(
                      opacity: 0.25 * _glowPulse.value,
                      child: Container(
                        width: 270,
                        height: 270,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFF52B788).withOpacity(0.6),
                              const Color(0xFF95D5B2).withOpacity(0.3),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.55, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Mid watercolor blob
                    Opacity(
                      opacity: 0.55,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFB7E4C7).withOpacity(0.80),
                              const Color(0xFF74C69D).withOpacity(0.50),
                              const Color(0xFF52B788).withOpacity(0.20),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.45, 0.75, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Secondary teal blob (offset)
                    Positioned(
                      top: 30, right: 30,
                      child: Opacity(
                        opacity: 0.35,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF95D5B2).withOpacity(0.70),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Blue-green accent blob
                    Positioned(
                      bottom: 40, left: 25,
                      child: Opacity(
                        opacity: 0.30,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFF40916C).withOpacity(0.60),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Custom botanical SVG-style painter
                    CustomPaint(
                      size: const Size(260, 260),
                      painter: _BotanicalPainter(_leafCtrl.value, _glowPulse.value),
                    ),

                    // Glassmorphism center circle with leaf icon
                    ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.55),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.80),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF52B788).withOpacity(0.30),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _glowPulse,
                              builder: (_, __) => Transform.scale(
                                scale: 0.92 + 0.08 * _glowPulse.value,
                                child: const Icon(
                                  Icons.eco_rounded,
                                  color: Color(0xFF2D6A4F),
                                  size: 54,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Logo text with shimmer ───────────────────────────────────────────────
  Widget _buildLogoText() {
    return FadeTransition(
      opacity: _logoFade,
      child: SlideTransition(
        position: _logoSlide,
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _shimmerCtrl,
              builder: (_, __) {
                return ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) {
                    final x = _shimmerCtrl.value * (bounds.width + 160) - 80;
                    return LinearGradient(
                      colors: const [
                        Color(0xFF1B4332),
                        Color(0xFF2D6A4F),
                        Color(0xFF52B788),
                        Color(0xFFB7E4C7),
                        Color(0xFF52B788),
                        Color(0xFF2D6A4F),
                        Color(0xFF1B4332),
                      ],
                      stops: const [0.0, 0.20, 0.38, 0.50, 0.62, 0.80, 1.0],
                      begin: Alignment((x / bounds.width) * 2 - 1, 0),
                      end:   Alignment((x / bounds.width) * 2 + 1, 0),
                    ).createShader(bounds);
                  },
                  child: Text(
                    AppLocalizations.of(context)?.appname ?? "Greenexis",
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B4332),
                      letterSpacing: -1.5,
                      height: 1.0,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Tagline ──────────────────────────────────────────────────────────────
  Widget _buildTagline() {
    return FadeTransition(
      opacity: _taglineFade,
      child: SlideTransition(
        position: _taglineSlide,
        child: Column(
          children: [
            // Decorative divider
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28, height: 1.5,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.transparent, Color(0xFF74C69D)],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 6, height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF52B788),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 28, height: 1.5,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF74C69D), Colors.transparent],
                    ),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
             Text(
              AppLocalizations.of(context)?.taglinemain ?? "Smart Farming Assistant",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF40916C),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)?.taglinesub ?? "Grow smarter. Farm better.",
              style: TextStyle(
                fontSize: 13.5,
                color: Color(0xFF74C69D),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom badge with loading dots ───────────────────────────────────────
  Widget _buildBottomBadge() {
    return FadeTransition(
      opacity: _badgeFade,
      child: Column(
        children: [
          // Animated loading dots
          AnimatedBuilder(
            animation: _glowCtrl,
            builder: (_, __) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final delay = i / 3.0;
                  final t = (_glowCtrl.value + delay) % 1.0;
                  final scale = 0.6 + 0.4 * math.sin(t * math.pi);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 7, height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.lerp(
                            const Color(0xFFB7E4C7),
                            const Color(0xFF2D6A4F),
                            scale,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 18),

          // Version pill

        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Watercolor Background Painter
// ════════════════════════════════════════════════════════════════════════════
class _WatercolorBgPainter extends CustomPainter {
  final double t;
  _WatercolorBgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    // Soft cream-white base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFF2FAF4),
    );

    final blobs = [
      _Blob(
        center: Offset(
          size.width * (0.80 + 0.04 * math.sin(t * math.pi)),
          size.height * (0.10 + 0.03 * math.cos(t * math.pi * 1.3)),
        ),
        radius: size.width * 0.55,
        color: const Color(0xFFB7E4C7).withOpacity(0.38),
        blur: 80,
      ),
      _Blob(
        center: Offset(
          size.width * (0.10 + 0.03 * math.cos(t * math.pi * 0.9)),
          size.height * (0.22 + 0.04 * math.sin(t * math.pi * 1.1)),
        ),
        radius: size.width * 0.48,
        color: const Color(0xFF95D5B2).withOpacity(0.28),
        blur: 70,
      ),
      _Blob(
        center: Offset(
          size.width * (0.70 + 0.05 * math.sin(t * math.pi * 1.2)),
          size.height * (0.55 + 0.04 * math.cos(t * math.pi * 0.8)),
        ),
        radius: size.width * 0.42,
        color: const Color(0xFF74C69D).withOpacity(0.22),
        blur: 65,
      ),
      _Blob(
        center: Offset(
          size.width * (0.15 + 0.03 * math.sin(t * math.pi * 1.4)),
          size.height * (0.75 + 0.03 * math.cos(t * math.pi)),
        ),
        radius: size.width * 0.40,
        color: const Color(0xFFD8F3DC).withOpacity(0.45),
        blur: 60,
      ),
      _Blob(
        center: Offset(
          size.width * (0.50 + 0.02 * math.cos(t * math.pi * 1.6)),
          size.height * (0.90 + 0.02 * math.sin(t * math.pi)),
        ),
        radius: size.width * 0.38,
        color: const Color(0xFF52B788).withOpacity(0.14),
        blur: 55,
      ),
    ];

    for (final b in blobs) {
      canvas.drawCircle(
        b.center,
        b.radius,
        Paint()
          ..color = b.color
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, b.blur),
      );
    }
  }

  @override
  bool shouldRepaint(_WatercolorBgPainter old) => old.t != t;
}

class _Blob {
  final Offset center;
  final double radius;
  final Color color;
  final double blur;
  const _Blob({required this.center, required this.radius, required this.color, required this.blur});
}

// ════════════════════════════════════════════════════════════════════════════
//  Botanical Centre Painter  (leaves, petals, spirals)
// ════════════════════════════════════════════════════════════════════════════
class _BotanicalPainter extends CustomPainter {
  final double t; // 0..1 leaf float
  final double g; // 0..1 glow pulse

  _BotanicalPainter(this.t, this.g);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ── Leaf cluster (6 leaves around center) ───────────────────────────
    for (int i = 0; i < 6; i++) {
      final baseAngle = (i / 6) * math.pi * 2;
      final wobble = 0.04 * math.sin(t * math.pi * 2 + i);
      final angle = baseAngle + wobble;
      final dist = 72.0 + 6 * math.sin(t * math.pi * 2 + i * 1.2);

      final lx = cx + dist * math.cos(angle);
      final ly = cy + dist * math.sin(angle);

      _drawLeaf(canvas, Offset(lx, ly), angle + math.pi / 2, i);
    }

    // ── Small petal dots ─────────────────────────────────────────────────
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * math.pi * 2;
      final r = 108.0 + 4 * math.sin(t * math.pi * 2 + i * 0.8);
      final px = cx + r * math.cos(angle);
      final py = cy + r * math.sin(angle);
      final dotSize = 3.0 + 1.5 * math.sin(t * math.pi * 2 + i);

      canvas.drawCircle(
        Offset(px, py),
        dotSize,
        Paint()
          ..color = [
            const Color(0xFF52B788),
            const Color(0xFF74C69D),
            const Color(0xFF40916C),
            const Color(0xFFB7E4C7),
          ][i % 4]
              .withOpacity(0.55 + 0.25 * math.sin(t * math.pi * 2 + i)),
      );
    }

    // ── Spiral tendrils ──────────────────────────────────────────────────
    for (int s = 0; s < 3; s++) {
      _drawSpiral(canvas, cx, cy, s, t);
    }
  }

  void _drawLeaf(Canvas canvas, Offset tip, double angle, int index) {
    final colors = [
      const Color(0xFF2D6A4F),
      const Color(0xFF40916C),
      const Color(0xFF52B788),
      const Color(0xFF74C69D),
      const Color(0xFF1B4332),
      const Color(0xFF95D5B2),
    ];

    final paint = Paint()
      ..color = colors[index % colors.length].withOpacity(0.70)
      ..style = PaintingStyle.fill;

    final leafLen = 22.0;
    final leafW   = 9.0;

    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(angle);

    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(-leafW, -leafLen * 0.4, -leafW * 0.6, -leafLen * 0.8, 0, -leafLen)
      ..cubicTo(leafW * 0.6, -leafLen * 0.8, leafW, -leafLen * 0.4, 0, 0);

    canvas.drawPath(path, paint);

    // Mid vein
    canvas.drawLine(
      Offset.zero,
      Offset(0, -leafLen * 0.85),
      Paint()
        ..color = Colors.white.withOpacity(0.35)
        ..strokeWidth = 0.8
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  void _drawSpiral(Canvas canvas, double cx, double cy, int index, double t) {
    final startAngle = (index / 3) * math.pi * 2 + t * math.pi * 0.3;
    final paint = Paint()
      ..color = const Color(0xFF40916C).withOpacity(0.22)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    bool first = true;

    for (int i = 0; i <= 60; i++) {
      final frac = i / 60.0;
      final r = 18 + 28 * frac;
      final a = startAngle + frac * math.pi * 3;
      final px = cx + r * math.cos(a);
      final py = cy + r * math.sin(a);

      if (first) {
        path.moveTo(px, py);
        first = false;
      } else {
        path.lineTo(px, py);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BotanicalPainter old) => old.t != t || old.g != g;
}

// ════════════════════════════════════════════════════════════════════════════
//  Floating Leaf Particles Painter
// ════════════════════════════════════════════════════════════════════════════
class _FloatingLeafPainter extends CustomPainter {
  final double t;
  _FloatingLeafPainter(this.t);

  static const _seeds = [
    [0.08, 0.15, 0.7, 0.0],
    [0.88, 0.08, 1.1, 0.3],
    [0.15, 0.78, 0.9, 0.6],
    [0.82, 0.70, 0.6, 0.9],
    [0.45, 0.05, 1.3, 0.15],
    [0.60, 0.88, 0.8, 0.45],
    [0.05, 0.50, 1.0, 0.75],
    [0.92, 0.45, 0.7, 0.55],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFF52B788),
      const Color(0xFF74C69D),
      const Color(0xFF40916C),
      const Color(0xFFB7E4C7),
    ];

    for (int i = 0; i < _seeds.length; i++) {
      final seed = _seeds[i];
      final phase = (t + seed[3]) % 1.0;
      final baseX = seed[0] * size.width;
      final baseY = seed[1] * size.height;
      final speed = seed[2];

      final x = baseX + 14 * math.sin(phase * math.pi * 2 * speed);
      final y = baseY + 10 * math.cos(phase * math.pi * 2 * speed * 0.8);
      final rotation = phase * math.pi * 2 * (i.isEven ? 1 : -1);
      final opacity = 0.18 + 0.14 * math.sin(phase * math.pi * 2);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final r = 5.0 + 3 * math.sin(phase * math.pi);
      final paint = Paint()
        ..color = colors[i % colors.length].withOpacity(opacity);

      // Simple leaf shape
      final path = Path()
        ..moveTo(0, 0)
        ..cubicTo(-r * 0.6, -r * 0.9, -r * 0.4, -r * 1.8, 0, -r * 2.2)
        ..cubicTo(r * 0.4, -r * 1.8, r * 0.6, -r * 0.9, 0, 0);

      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_FloatingLeafPainter old) => old.t != t;
}
