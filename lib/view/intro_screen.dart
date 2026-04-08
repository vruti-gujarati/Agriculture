import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import 'login_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {

  // ── Page state ─────────────────────────────────────────────────────────────
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;
  static const int _totalPages = 3;

  // ── Animation controllers ──────────────────────────────────────────────────
  late AnimationController _bgCtrl;
  late AnimationController _leafCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _illustCtrl;
  late AnimationController _textCtrl;
  late AnimationController _exitCtrl;
  late AnimationController _farmCtrl;
  late AnimationController _sunCtrl;
  late AnimationController _waterCtrl;
  late AnimationController _growCtrl;

  late Animation<double> _bgFloat;
  late Animation<double> _illustScale;
  late Animation<double> _illustFade;
  late Animation<Offset> _illustSlide;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _glowPulse;
  late Animation<double> _exitFade;
  late Animation<double> _farmAnim;
  late Animation<double> _sunAnim;
  late Animation<double> _waterAnim;
  late Animation<double> _growAnim;

  // // ── Slide data ─────────────────────────────────────────────────────────────
  // static const _slides = [
  //   _SlideData(
  //     title: AppLocalizations.of(context)?.titleone ?? 'The Next Generation\nof Farming',
  //     description:
  //     AppLocalizations.of(context)?.descriptionone ?? 'We provide smart data that enables the goals of modern global agriculture — from soil health to yield optimization, all in one place.',
  //     badge: AppLocalizations.of(context)?.smartfarming ?? 'Smart Farming',
  //     badgeIcon: Icons.location_on_rounded,
  //     illustType: _IllustType.farm,
  //   ),
  //   _SlideData(
  //     title: 'Detect Crop Diseases\nEasily',
  //     description:
  //     'Point your camera at any plant and get instant AI-powered disease detection. Identify 200+ crop diseases early and receive personalized treatment tips.',
  //     badge: 'AI Scanner',
  //     badgeIcon: Icons.search_rounded,
  //     illustType: _IllustType.scanner,
  //   ),
  //   _SlideData(
  //     title: 'Track Your Farm\n& Grow Smarter',
  //     description:
  //     'View all your farm analytics in one beautiful dashboard. Track moisture, temperature, humidity and yield trends to make smarter decisions every season.',
  //     badge: 'Dashboard',
  //     badgeIcon: Icons.bar_chart_rounded,
  //     illustType: _IllustType.dashboard,
  //   ),
  // ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _initControllers();
    _playPageEntry();
  }

  void _initControllers() {
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat(reverse: true);
    _bgFloat = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut));

    _leafCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat(reverse: true);

    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _farmCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3600))
      ..repeat();
    _farmAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _farmCtrl, curve: Curves.linear));

    _sunCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 8000))
      ..repeat();
    _sunAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _sunCtrl, curve: Curves.linear));

    _waterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat();
    _waterAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _waterCtrl, curve: Curves.easeInOut));

    _growCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _growAnim = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _growCtrl, curve: Curves.easeInOut));

    _illustCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _illustScale = Tween<double>(begin: 0.80, end: 1.0).animate(
        CurvedAnimation(parent: _illustCtrl, curve: Curves.easeOutBack));
    _illustFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _illustCtrl,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _illustSlide = Tween<Offset>(
        begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _illustCtrl, curve: Curves.easeOutCubic));

    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textCtrl,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOut)));
    _textSlide = Tween<Offset>(
        begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    _exitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));
  }

  void _playPageEntry() {
    _illustCtrl.forward(from: 0);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _textCtrl.forward(from: 0);
    });
  }

  void _onNext() {
    if (_currentPage < _totalPages - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOutCubic);
    } else {
      _navigateAway();
    }
  }

  void _onSkip() => _navigateAway();

  void _navigateAway() {
    _exitCtrl.forward().then((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ));
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose(); _bgCtrl.dispose(); _leafCtrl.dispose();
    _glowCtrl.dispose(); _illustCtrl.dispose(); _textCtrl.dispose();
    _exitCtrl.dispose(); _farmCtrl.dispose(); _sunCtrl.dispose();
    _waterCtrl.dispose(); _growCtrl.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Create the list here so it can use 'context'
    final List<_SlideData> localizedSlides = [
      _SlideData(
        title: AppLocalizations.of(context)?.titleone ?? 'The Next Generation\nof Farming',
        description: AppLocalizations.of(context)?.descriptionone ?? 'We provide smart data...',
        badge: AppLocalizations.of(context)?.smartfarming ?? 'Smart Farming',
        badgeIcon: Icons.location_on_rounded,
        illustType: _IllustType.farm,
      ),
      _SlideData(
        title: AppLocalizations.of(context)?.titletwo ?? 'Detect Crop Diseases\nEasily',
        description: AppLocalizations.of(context)?.descriptiontwo ?? 'Point your camera at any plant...',
        badge: AppLocalizations.of(context)?.aiscanner ?? 'AI Scanner',
        badgeIcon: Icons.search_rounded,
        illustType: _IllustType.scanner,
      ),
      _SlideData(
        title: AppLocalizations.of(context)?.titlethree ?? 'Track Your Farm\n& Grow Smarter',
        description: AppLocalizations.of(context)?.descriptionthree ?? 'View all your farm analytics...',
        badge: AppLocalizations.of(context)?.farmhealth ?? 'Dashboard',
        badgeIcon: Icons.bar_chart_rounded,
        illustType: _IllustType.dashboard,
      ),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: AnimatedBuilder(
        animation: _exitFade,
        builder: (_, child) => Opacity(opacity: _exitFade.value, child: child),
        child: Scaffold(
          backgroundColor: const Color(0xFFF2FAF4),
          body: Stack(children: [
            // ... (Your Painter widgets here) ...

            // UPDATE: Use 'localizedSlides' instead of '_slides'
            PageView.builder(
              controller: _pageCtrl,
              itemCount: _totalPages,
              onPageChanged: (i) {
                setState(() => _currentPage = i);
                _playPageEntry();
              },
              itemBuilder: (_, i) => _buildPage(localizedSlides[i], size),
            ),

            _buildBottomControls(size),
          ]),
        ),
      ),
    );
  }

  // ── Page layout: illustration top half, white card static bottom half ───────
  Widget _buildPage(_SlideData slide, Size size) {
    final cardHeight = size.height * 0.48;
    return Stack(
      children: [
        // ── TOP: Farming illustration ─────────────────────────────────────────
        Positioned(
          top: 0, left: 0, right: 0,
          bottom: cardHeight - 24,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: FadeTransition(
                opacity: _illustFade,
                child: SlideTransition(
                  position: _illustSlide,
                  child: ScaleTransition(
                    scale: _illustScale,
                    child: _buildIllustration(slide, size),
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── BOTTOM: White card — static, no animation ─────────────────────────
        Positioned(
          left: 0, right: 0, bottom: 0,
          height: cardHeight,
          child: _buildWhiteCard(slide, size),
        ),
      ],
    );
  }

  // ── Illustration circle ────────────────────────────────────────────────────
  Widget _buildIllustration(_SlideData slide, Size size) {
    final cardSize = math.min(size.width * 0.82, 310.0);
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [_glowPulse, _farmAnim, _sunAnim, _waterAnim, _growAnim]),
        builder: (_, __) => SizedBox(
          width: cardSize * 1.18,
          height: cardSize * 1.18,
          child: Stack(alignment: Alignment.center, children: [

            // ── Outer slow orbit ring (dashed dots) ──────────────────────
            Transform.rotate(
              angle: _sunAnim.value * math.pi * 2,
              child: CustomPaint(
                size: Size(cardSize * 1.14, cardSize * 1.14),
                painter: _OrbitRingPainter(
                  radius: cardSize * 0.57,
                  dotCount: 12,
                  dotRadius: 3.5,
                  color: const Color(0xFF52B788),
                  opacity: 0.28 + 0.12 * _glowPulse.value,
                ),
              ),
            ),

            // ── Inner fast orbit ring with leaf dots ─────────────────────
            Transform.rotate(
              angle: -_farmAnim.value * math.pi * 2 * 0.7,
              child: CustomPaint(
                size: Size(cardSize * 1.04, cardSize * 1.04),
                painter: _OrbitRingPainter(
                  radius: cardSize * 0.52,
                  dotCount: 8,
                  dotRadius: 5.0,
                  color: const Color(0xFF40916C),
                  opacity: 0.20 + 0.14 * _glowPulse.value,
                  isLeaf: true,
                ),
              ),
            ),

            // ── Main circle ───────────────────────────────────────────────
            Container(
              width: cardSize,
              height: cardSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFFB7E4C7).withOpacity(0.55),
                  const Color(0xFF95D5B2).withOpacity(0.35),
                  const Color(0xFF74C69D).withOpacity(0.18),
                  Colors.transparent,
                ], stops: const [0.0, 0.45, 0.72, 1.0]),
                boxShadow: [BoxShadow(
                  color: const Color(0xFF52B788).withOpacity(0.18 * _glowPulse.value),
                  blurRadius: 40, spreadRadius: 8,
                )],
              ),
              child: Stack(alignment: Alignment.center, children: [

                // Glow ring
                Opacity(
                  opacity: 0.20 * _glowPulse.value,
                  child: Container(
                    width: cardSize * 0.92, height: cardSize * 0.92,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                          colors: [Color(0xFF52B788), Colors.transparent],
                          stops: [0.55, 1.0]),
                    ),
                  ),
                ),

                // Botanical ring
                CustomPaint(
                  size: Size(cardSize * 0.85, cardSize * 0.85),
                  painter: _BotanicalPainter(_leafCtrl.value, _glowPulse.value),
                ),

                // Scene
                SizedBox(
                  width: cardSize * 0.72, height: cardSize * 0.72,
                  child: CustomPaint(
                    painter: _FarmingIllustPainter(
                      type: slide.illustType, glowPulse: _glowPulse.value,
                      farmT: _farmAnim.value, sunT: _sunAnim.value,
                      waterT: _waterAnim.value, growT: _growAnim.value,
                    ),
                  ),
                ),

                // Badge pill
                Positioned(
                  bottom: cardSize * 0.07,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.82),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.90), width: 1.5),
                          boxShadow: [BoxShadow(
                            color: const Color(0xFF52B788).withOpacity(0.12),
                            blurRadius: 14, offset: const Offset(0, 4),
                          )],
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(slide.badgeIcon,
                              color: const Color(0xFF2D6A4F), size: 15),
                          const SizedBox(width: 6),
                          Text(slide.badge,
                              style: const TextStyle(fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D6A4F),
                                  letterSpacing: 0.3)),
                        ]),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  //  WHITE CARD — static bottom half, rounded top corners, no animation
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildWhiteCard(_SlideData slide, Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(28, 32, 28, size.height * 0.18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A52B788),
            blurRadius: 32,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          // ── Green accent handle bar ───────────────────────────────────
          Container(
            width: 44, height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFF52B788),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          const SizedBox(height: 24),

          // ── Bold title ────────────────────────────────────────────────
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size.width * 0.067,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1B4332),
              height: 1.22,
              letterSpacing: -0.6,
            ),
          ),

          const SizedBox(height: 12),

          // ── Thin divider ──────────────────────────────────────────────
          Container(
            width: 52, height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFFB7E4C7),
              borderRadius: BorderRadius.circular(1),
            ),
          ),

          const SizedBox(height: 14),

          // ── Description paragraph ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              slide.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.036,
                color: const Color(0xFF5A7A6A),
                height: 1.72,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom controls ────────────────────────────────────────────────────────
  Widget _buildBottomControls(Size size) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_totalPages, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: active
                        ? const Color(0xFF1B4332)
                        : const Color(0xFFB7E4C7),
                  ),
                );
              }),
            ),

            const SizedBox(height: 18),

            // Next / Get Started
            GestureDetector(
              onTap: _onNext,
              child: Container(
                width: double.infinity,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  boxShadow: [BoxShadow(
                    color: const Color(0xFF1B4332).withOpacity(0.30),
                    blurRadius: 18, offset: const Offset(0, 6),
                  )],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentPage == _totalPages - 1 ? AppLocalizations.of(context)?.getstarted ??'Get Started' : AppLocalizations.of(context)?.next ?? 'Next',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16,
                          fontWeight: FontWeight.w700, letterSpacing: 0.4),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      _currentPage == _totalPages - 1
                          ? Icons.login_rounded
                          : Icons.arrow_forward_rounded,
                      color: Colors.white, size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Slide Data Model
// ════════════════════════════════════════════════════════════════════════════
enum _IllustType { farm, scanner, dashboard }

class _SlideData {
  final String title;
  final String description;
  final String badge;
  final IconData badgeIcon;
  final _IllustType illustType;
  const _SlideData({
    required this.title, required this.description,
    required this.badge, required this.badgeIcon, required this.illustType,
  });
}

// ════════════════════════════════════════════════════════════════════════════
//  Farming Illustration Painter
// ════════════════════════════════════════════════════════════════════════════
class _FarmingIllustPainter extends CustomPainter {
  final _IllustType type;
  final double glowPulse, farmT, sunT, waterT, growT;
  _FarmingIllustPainter({required this.type, required this.glowPulse,
    required this.farmT, required this.sunT,
    required this.waterT, required this.growT});

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case _IllustType.farm:      _drawFarm(canvas, size);      break;
      case _IllustType.scanner:   _drawScanner(canvas, size);   break;
      case _IllustType.dashboard: _drawDashboard(canvas, size); break;
    }
  }

  // ── Scene 1: Smart Farm ────────────────────────────────────────────────────
  void _drawFarm(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, cy + 10),
        Paint()..color = const Color(0xFFE8F5E9).withOpacity(0.4));

    // Sun + rays
    final sx = cx + 46.0, sy = cy - 48.0;
    final ss = 1.0 + 0.08 * math.sin(sunT * math.pi * 2);
    for (int r = 0; r < 8; r++) {
      final a = (r / 8) * math.pi * 2 + sunT * math.pi * 0.5;
      canvas.drawLine(
        Offset(sx + 13 * ss * math.cos(a), sy + 13 * ss * math.sin(a)),
        Offset(sx + (21 * ss + 4 * math.sin(sunT * math.pi * 2 + r)) * math.cos(a),
            sy + (21 * ss + 4 * math.sin(sunT * math.pi * 2 + r)) * math.sin(a)),
        Paint()..color = const Color(0xFFFFD166).withOpacity(0.65)
          ..strokeWidth = 2..strokeCap = StrokeCap.round,
      );
    }
    canvas.drawCircle(Offset(sx, sy), 11 * ss,
        Paint()..color = const Color(0xFFFFD166).withOpacity(0.92));
    canvas.drawCircle(Offset(sx, sy), 16 * ss,
        Paint()..color = const Color(0xFFFFD166).withOpacity(0.22));

    // Cloud
    _cloud(canvas, cx - 50 + 5 * math.sin(farmT * math.pi * 2), cy - 50, 0.85);

    // Ground
    canvas.drawPath(
      Path()..moveTo(0, cy+14)..lineTo(size.width, cy+14)
        ..lineTo(size.width, size.height)..lineTo(0, size.height)..close(),
      Paint()..color = const Color(0xFF95D5B2).withOpacity(0.45),
    );
    for (int r = 0; r < 3; r++) {
      canvas.drawLine(Offset(8, cy+17+r*14), Offset(size.width-8, cy+17+r*14),
          Paint()..color = const Color(0xFF2D6A4F).withOpacity(0.18)..strokeWidth = 2.5);
    }

    // Crops
    const cc = [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C),
      Color(0xFF52B788), Color(0xFF74C69D), Color(0xFF95D5B2)];
    for (int i = 0; i < 6; i++) {
      final bx = 16.0 + i * (size.width - 32) / 5;
      final bh = (26.0 + (i%3)*10) * (0.88 + 0.12 * math.sin(growT * math.pi * 2 + i * 0.8));
      canvas.drawLine(Offset(bx, cy+14), Offset(bx, cy+14-bh),
          Paint()..color = cc[i]..strokeWidth = 3..strokeCap = StrokeCap.round);
      _cropLeaf(canvas, bx, cy+14-bh*0.5, cc[i]);
      canvas.drawCircle(Offset(bx, cy+14-bh), 5+1.5*math.sin(growT*math.pi*2+i),
          Paint()..color = cc[i].withOpacity(0.85));
    }

    // Tractor
    _tractor(canvas, (farmT * (size.width + 70)) - 35, cy + 3);

    // Water drops
    for (int d = 0; d < 4; d++) {
      final dp = (waterT + d * 0.25) % 1.0;
      canvas.drawCircle(Offset(18 + d * size.width / 4, cy - 5 - 18 * dp),
          3*(1-dp), Paint()..color = const Color(0xFF4895EF).withOpacity(0.55*(1-dp)));
    }

    _statBadge(canvas, Offset(cx-76, cy-58), '+24%', 'YIELD', const Color(0xFF1B4332));
  }

  void _cloud(Canvas canvas, double x, double y, double s) {
    final p = Paint()..color = Colors.white.withOpacity(0.75);
    canvas.drawCircle(Offset(x, y), 10*s, p);
    canvas.drawCircle(Offset(x+12*s, y-3*s), 14*s, p);
    canvas.drawCircle(Offset(x+26*s, y), 10*s, p);
    canvas.drawCircle(Offset(x+8*s,  y+5*s), 11*s, p);
    canvas.drawCircle(Offset(x+20*s, y+4*s), 10*s, p);
  }

  void _cropLeaf(Canvas canvas, double sx, double y, Color c) {
    for (final sign in [-1.0, 1.0]) {
      canvas.save();
      canvas.translate(sx, y);
      canvas.rotate(sign * 0.5);
      canvas.drawPath(
        Path()..moveTo(0,0)..cubicTo(sign*6,-5,sign*5,-14,0,-18)
          ..cubicTo(-sign*5,-14,-sign*6,-5,0,0),
        Paint()..color = c.withOpacity(0.70),
      );
      canvas.restore();
    }
  }

  void _tractor(Canvas canvas, double x, double y) {
    final body = Paint()..color = const Color(0xFF2D6A4F);
    final dark = Paint()..color = const Color(0xFF1B4332);
    final light = Paint()..color = const Color(0xFF74C69D);

    // --- MAIN BODY (long rectangle) ---
    canvas.drawRect(
      Rect.fromLTWH(x - 18, y - 14, 28, 12),
      body,
    );

    // --- FRONT HOOD (small rectangle) ---
    canvas.drawRect(
      Rect.fromLTWH(x + 10, y - 12, 14, 10),
      body,
    );

    // --- CABIN (square) ---
    canvas.drawRect(
      Rect.fromLTWH(x - 2, y - 26, 14, 12),
      dark,
    );

    // --- WINDOW (small square) ---
    canvas.drawRect(
      Rect.fromLTWH(x + 1, y - 23, 8, 7),
      Paint()..color = Colors.white.withOpacity(0.7),
    );

    // --- EXHAUST PIPE (thin rectangle) ---
    canvas.drawRect(
      Rect.fromLTWH(x + 12, y - 30, 2, 6),
      dark,
    );

    // --- BACK WHEEL (big circle) ---
    canvas.drawCircle(Offset(x - 10, y + 4), 11, dark);
    canvas.drawCircle(Offset(x - 10, y + 4), 5, light);

    // --- FRONT WHEEL (small circle) ---
    canvas.drawCircle(Offset(x + 18, y + 4), 6, dark);
    canvas.drawCircle(Offset(x + 18, y + 4), 2.8, light);

    // --- BODY CONNECTOR (gives structure like real tractor) ---
    canvas.drawRect(
      Rect.fromLTWH(x - 2, y - 14, 12, 4),
      dark,
    );

    // --- ENGINE DETAIL (small square for realism) ---
    canvas.drawRect(
      Rect.fromLTWH(x + 14, y - 10, 4, 4),
      dark,
    );

    // --- SUBTLE ANIMATION HIGHLIGHT ---
    canvas.drawCircle(
      Offset(x + 14, y - 20),
      2 + 1.5 * math.sin(farmT * math.pi * 4),
      Paint()..color = Colors.white.withOpacity(0.3),
    );
  }

  // ── Scene 2: AI Scanner ────────────────────────────────────────────────────
  void _drawScanner(Canvas canvas, Size size) {
    final cx = size.width/2, cy = size.height/2;
    final sway = 4.0 * math.sin(growT * math.pi * 2);
    final lw   = 3.0 * math.sin(growT * math.pi * 2);

    canvas.drawPath(
      Path()..moveTo(cx+30+sway*0.3, cy+50)
        ..cubicTo(cx+30+sway, cy+20, cx+28+sway*0.8, cy, cx+30+sway*0.5, cy-18),
      Paint()..color = const Color(0xFF2D6A4F)..strokeWidth = 4
        ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
    );
    _animLeaf(canvas, cx+20, cy+12, -0.55, const Color(0xFF52B788),  lw);
    _animLeaf(canvas, cx+40, cy+2,   0.65, const Color(0xFF40916C), -lw);
    _animLeaf(canvas, cx+26, cy-8,  -0.30, const Color(0xFF74C69D),  lw*0.5);

    final fr = 11.0 + 2.5*math.sin(growT*math.pi*2);
    final fx = cx+30+sway*0.5, fy = cy-18.0;
    canvas.drawCircle(Offset(fx, fy), fr,
        Paint()..color = const Color(0xFF95D5B2).withOpacity(0.90));
    canvas.drawCircle(Offset(fx, fy), 6, Paint()..color = const Color(0xFF2D6A4F));
    for (int p = 0; p < 5; p++) {
      final pa = (p/5)*math.pi*2 + sunT*math.pi*2;
      canvas.drawCircle(Offset(fx+fr*math.cos(pa), fy+fr*math.sin(pa)), 2.5,
          Paint()..color = Colors.white.withOpacity(0.60));
    }

    final pr = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx-54, cy-52, 66, 92), const Radius.circular(12));
    canvas.drawRRect(pr, Paint()..color = const Color(0xFF1B4332).withOpacity(0.12));
    canvas.drawRRect(pr, Paint()..color = const Color(0xFF2D6A4F)
      ..style = PaintingStyle.stroke..strokeWidth = 3);
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(cx-48, cy-44, 54, 74), const Radius.circular(6)),
        Paint()..color = const Color(0xFFD8F3DC).withOpacity(0.55));

    final br = Paint()..color = const Color(0xFF52B788)..strokeWidth = 3
      ..style = PaintingStyle.stroke..strokeCap = StrokeCap.square;
    const bL = 10.0;
    canvas.drawLine(Offset(cx-44, cy-40), Offset(cx-44+bL, cy-40), br);
    canvas.drawLine(Offset(cx-44, cy-40), Offset(cx-44, cy-40+bL), br);
    canvas.drawLine(Offset(cx+2,  cy-40), Offset(cx+2-bL, cy-40),  br);
    canvas.drawLine(Offset(cx+2,  cy-40), Offset(cx+2, cy-40+bL),  br);
    canvas.drawLine(Offset(cx-44, cy+26), Offset(cx-44+bL, cy+26), br);
    canvas.drawLine(Offset(cx-44, cy+26), Offset(cx-44, cy+26-bL), br);
    canvas.drawLine(Offset(cx+2,  cy+26), Offset(cx+2-bL, cy+26),  br);
    canvas.drawLine(Offset(cx+2,  cy+26), Offset(cx+2, cy+26-bL),  br);

    final bp = farmT % 1.0;
    final by = cy-44+74*bp;
    final bo = (1-(bp-0.5).abs()*2).clamp(0.0,1.0);
    canvas.drawLine(Offset(cx-48, by), Offset(cx+6, by),
        Paint()..color = const Color(0xFF52B788).withOpacity(0.8*bo)..strokeWidth = 2.5);
    canvas.drawLine(Offset(cx-48, by), Offset(cx+6, by),
        Paint()..color = const Color(0xFF52B788).withOpacity(0.25)
          ..strokeWidth = 8..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

    for (int d = 0; d < 3; d++) {
      final dp = (waterT+d*0.33)%1.0;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx-60+d*8, cy-52-24*dp),
            width: 5*(1-dp), height: 8*(1-dp)),
        Paint()..color = const Color(0xFF4895EF).withOpacity(0.55*(1-dp)),
      );
    }
    _aiBadge(canvas, Offset(cx+8, cy-58));
    _diseaseBadge(canvas, Offset(cx-50, cy+34), 'Leaf Blight — 91%');
  }

  void _animLeaf(Canvas canvas, double lx, double ly, double angle, Color c, double wave) {
    canvas.save();
    canvas.translate(lx+wave, ly);
    canvas.rotate(angle);
    canvas.drawPath(Path()..moveTo(0,0)..cubicTo(-14,-10,-12,-32,0,-40)
      ..cubicTo(12,-32,14,-10,0,0), Paint()..color = c);
    canvas.drawLine(const Offset(0,0), const Offset(0,-36),
        Paint()..color = Colors.white.withOpacity(0.3)..strokeWidth = 1);
    canvas.restore();
  }

  // ── Scene 3: Dashboard ─────────────────────────────────────────────────────
  void _drawDashboard(Canvas canvas, Size size) {
    final cx = size.width/2, cy = size.height/2;

    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(cx-72, cy-60, 144, 116), const Radius.circular(18)),
        Paint()..color = const Color(0xFF52B788).withOpacity(0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(cx-72, cy-60, 144, 116), const Radius.circular(18)),
        Paint()..color = Colors.white.withOpacity(0.78));

    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(cx-62, cy-52, 90, 7), const Radius.circular(3)),
        Paint()..color = const Color(0xFF1B4332).withOpacity(0.50));
    canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(cx-62, cy-40, 60, 4), const Radius.circular(3)),
        Paint()..color = const Color(0xFF52B788).withOpacity(0.45));

    const vals = [0.45, 0.70, 0.55, 0.85, 0.65, 0.90];
    const bc = [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C),
      Color(0xFF52B788), Color(0xFF74C69D), Color(0xFF95D5B2)];
    for (int i = 0; i < vals.length; i++) {
      final bx = cx-58+i*22.0;
      final av = vals[i] * (0.88+0.12*math.sin(growT*math.pi*2+i*0.5));
      final bh = 52.0 * av;
      canvas.drawRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, cy+30-bh, 15, bh), const Radius.circular(4)),
          Paint()..color = bc[i]);
      canvas.drawRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(bx+2, cy+30-bh, 5, bh*0.4), const Radius.circular(3)),
          Paint()..color = Colors.white.withOpacity(0.18));
    }

    final lpath = Path();
    for (int i = 0; i < vals.length; i++) {
      final bx = cx-58+i*22.0+7.5;
      final av = vals[i]*(0.88+0.12*math.sin(growT*math.pi*2+i*0.5));
      final by = cy+30-52.0*av;
      i==0 ? lpath.moveTo(bx, by) : lpath.lineTo(bx, by);
    }
    canvas.drawPath(lpath, Paint()..color = const Color(0xFFFFD166).withOpacity(0.90)
      ..strokeWidth = 2.5..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);

    for (int i = 0; i < vals.length; i++) {
      final bx = cx-58+i*22.0+7.5;
      final av = vals[i]*(0.88+0.12*math.sin(growT*math.pi*2+i*0.5));
      final by = cy+30-52.0*av;
      canvas.drawCircle(Offset(bx, by), 3, Paint()..color = const Color(0xFFFFD166));
      canvas.drawCircle(Offset(bx, by), 5, Paint()..color = const Color(0xFFFFD166).withOpacity(0.30));
    }

    _statBadge(canvas, Offset(cx+22, cy-58), '+18%', 'YIELD', const Color(0xFF1B4332));
    _miniChip(canvas, Offset(cx-70, cy+40), '72%', 'Soil');
    _miniChip(canvas, Offset(cx+2,  cy+40), '28°C', 'Temp');

    for (int d = 0; d < 3; d++) {
      final dp = (waterT+d*0.33)%1.0;
      canvas.drawCircle(Offset(cx-75, cy-60-15*dp), 2.5*(1-dp),
          Paint()..color = const Color(0xFF4895EF).withOpacity(0.6*(1-dp)));
    }
  }

  // ── Shared helpers ─────────────────────────────────────────────────────────
  void _statBadge(Canvas canvas, Offset p, String val, String lbl, Color c) {
    final rr = RRect.fromRectAndRadius(Rect.fromLTWH(p.dx, p.dy, 54, 32), const Radius.circular(8));
    canvas.drawRRect(rr, Paint()..color = Colors.white.withOpacity(0.88));
    canvas.drawRRect(rr, Paint()..color = c.withOpacity(0.22)
      ..style = PaintingStyle.stroke..strokeWidth = 1);
    (TextPainter(
      text: TextSpan(text: '$lbl\n',
          style: TextStyle(fontSize: 7, fontWeight: FontWeight.w600, color: c.withOpacity(0.60)),
          children: [TextSpan(text: val,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: c))]),
      textDirection: TextDirection.ltr,
    )..layout()).paint(canvas, Offset(p.dx+5, p.dy+3));
  }

  void _aiBadge(Canvas canvas, Offset p) {
    final rr = RRect.fromRectAndRadius(Rect.fromLTWH(p.dx, p.dy, 40, 18), const Radius.circular(9));
    canvas.drawRRect(rr, Paint()..color = Colors.white.withOpacity(0.92));
    canvas.drawCircle(Offset(p.dx+10, p.dy+9), 5, Paint()..color = const Color(0xFF52B788));
    (TextPainter(
      text: const TextSpan(text: ' AI',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF1B4332))),
      textDirection: TextDirection.ltr,
    )..layout()).paint(canvas, Offset(p.dx+13, p.dy+4));
  }

  void _diseaseBadge(Canvas canvas, Offset p, String text) {
    final rr = RRect.fromRectAndRadius(Rect.fromLTWH(p.dx, p.dy, 102, 18), const Radius.circular(4));
    canvas.drawRRect(rr, Paint()..color = Colors.white.withOpacity(0.88));
    (TextPainter(
      text: TextSpan(text: text,
          style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFF1B4332))),
      textDirection: TextDirection.ltr,
    )..layout()).paint(canvas, Offset(p.dx+6, p.dy+4));
  }

  void _miniChip(Canvas canvas, Offset p, String val, String lbl) {
    final rr = RRect.fromRectAndRadius(Rect.fromLTWH(p.dx, p.dy, 60, 22), const Radius.circular(6));
    canvas.drawRRect(rr, Paint()..color = const Color(0xFFD8F3DC).withOpacity(0.85));
    (TextPainter(
      text: TextSpan(text: '$lbl $val',
          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF2D6A4F))),
      textDirection: TextDirection.ltr,
    )..layout()).paint(canvas, Offset(p.dx+5, p.dy+7));
  }

  @override
  bool shouldRepaint(_FarmingIllustPainter old) =>
      old.glowPulse != glowPulse || old.farmT != farmT || old.sunT != sunT ||
          old.waterT != waterT || old.growT != growT || old.type != type;
}

// ════════════════════════════════════════════════════════════════════════════
//  Farm Particle Painter
// ════════════════════════════════════════════════════════════════════════════
class _FarmParticlePainter extends CustomPainter {
  final double t, gt;
  _FarmParticlePainter(this.t, this.gt);
  static const _p = [
    [0.05,0.30,0.6,0.00,0],[0.92,0.15,0.9,0.20,1],[0.18,0.65,0.7,0.40,2],
    [0.78,0.55,1.1,0.60,0],[0.42,0.10,0.8,0.80,1],[0.65,0.82,0.6,0.10,2],
    [0.10,0.88,1.0,0.50,0],[0.88,0.75,0.7,0.30,1],[0.30,0.45,0.9,0.70,2],[0.55,0.25,0.8,0.15,0],
  ];
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _p.length; i++) {
      final s  = _p[i];
      final ph = (t*s[2]+s[3])%1.0;
      final x  = s[0]*size.width  + 10*math.sin(ph*math.pi*2);
      final y  = s[1]*size.height + 8 *math.cos(ph*math.pi*2*0.75);
      final op = 0.12 + 0.10*math.sin(ph*math.pi*2);
      if (s[4]==0) {
        canvas.save(); canvas.translate(x,y); canvas.rotate(ph*math.pi);
        canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 6, height: 10),
            Paint()..color = const Color(0xFF74C69D).withOpacity(op));
        canvas.restore();
      } else if (s[4]==1) {
        final sp = Paint()..color = const Color(0xFFFFD166).withOpacity(op*1.5)
          ..strokeWidth = 1.5..strokeCap = StrokeCap.round;
        for (int k=0;k<4;k++) {
          final a = k*math.pi/2;
          canvas.drawLine(Offset(x+3*math.cos(a),y+3*math.sin(a)),
              Offset(x+6*math.cos(a),y+6*math.sin(a)), sp);
        }
        canvas.drawCircle(Offset(x,y), 2,
            Paint()..color = const Color(0xFFFFD166).withOpacity(op*1.5));
      } else {
        canvas.save(); canvas.translate(x,y); canvas.rotate(ph*math.pi*2);
        const r = 4.0;
        canvas.drawPath(Path()..moveTo(0,0)..cubicTo(-r*0.5,-r*0.8,-r*0.3,-r*1.6,0,-r*2)
          ..cubicTo(r*0.3,-r*1.6,r*0.5,-r*0.8,0,0),
            Paint()..color = const Color(0xFF52B788).withOpacity(op*1.2));
        canvas.restore();
      }
    }
  }
  @override bool shouldRepaint(_FarmParticlePainter o) => o.t!=t||o.gt!=gt;
}

// ════════════════════════════════════════════════════════════════════════════
//  Watercolor Background Painter
// ════════════════════════════════════════════════════════════════════════════
class _WatercolorBgPainter extends CustomPainter {
  final double t;
  _WatercolorBgPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0,0,size.width,size.height),
        Paint()..color = const Color(0xFFF2FAF4));
    final blobs = [
      [0.80+0.04*math.sin(t*math.pi),       0.10+0.03*math.cos(t*math.pi*1.3), 0.55, 0xFFB7E4C7, 0.38, 80.0],
      [0.10+0.03*math.cos(t*math.pi*0.9),   0.22+0.04*math.sin(t*math.pi*1.1), 0.48, 0xFF95D5B2, 0.28, 70.0],
      [0.70+0.05*math.sin(t*math.pi*1.2),   0.55+0.04*math.cos(t*math.pi*0.8), 0.42, 0xFF74C69D, 0.22, 65.0],
      [0.15+0.03*math.sin(t*math.pi*1.4),   0.75+0.03*math.cos(t*math.pi),     0.40, 0xFFD8F3DC, 0.45, 60.0],
      [0.50+0.02*math.cos(t*math.pi*1.6),   0.90+0.02*math.sin(t*math.pi),     0.38, 0xFF52B788, 0.14, 55.0],
    ];
    for (final b in blobs) {
      canvas.drawCircle(
        Offset(size.width*(b[0] as double), size.height*(b[1] as double)),
        size.width*(b[2] as double),
        Paint()..color = Color(b[3] as int).withOpacity(b[4] as double)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, b[5] as double),
      );
    }
  }
  @override bool shouldRepaint(_WatercolorBgPainter o) => o.t!=t;
}

// ════════════════════════════════════════════════════════════════════════════
//  Botanical Centre Painter
// ════════════════════════════════════════════════════════════════════════════
class _BotanicalPainter extends CustomPainter {
  final double t, g;
  _BotanicalPainter(this.t, this.g);
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width/2, cy = size.height/2;
    for (int i=0;i<6;i++) {
      final a = (i/6)*math.pi*2 + 0.04*math.sin(t*math.pi*2+i);
      final d = 72.0 + 6*math.sin(t*math.pi*2+i*1.2);
      _leaf(canvas, Offset(cx+d*math.cos(a), cy+d*math.sin(a)), a+math.pi/2, i);
    }
    for (int i=0;i<12;i++) {
      final a = (i/12)*math.pi*2;
      final r = 108.0 + 4*math.sin(t*math.pi*2+i*0.8);
      canvas.drawCircle(Offset(cx+r*math.cos(a), cy+r*math.sin(a)),
          3.0+1.5*math.sin(t*math.pi*2+i),
          Paint()..color = [const Color(0xFF52B788),const Color(0xFF74C69D),
            const Color(0xFF40916C),const Color(0xFFB7E4C7)][i%4]
              .withOpacity(0.55+0.25*math.sin(t*math.pi*2+i)));
    }
    for (int s=0;s<3;s++) _spiral(canvas,cx,cy,s);
  }
  void _leaf(Canvas canvas, Offset tip, double angle, int idx) {
    const colors = [Color(0xFF2D6A4F),Color(0xFF40916C),Color(0xFF52B788),
      Color(0xFF74C69D),Color(0xFF1B4332),Color(0xFF95D5B2)];
    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(angle);
    canvas.drawPath(Path()..moveTo(0,0)..cubicTo(-9,-8.8,-5.4,-17.6,0,-22)
      ..cubicTo(5.4,-17.6,9,-8.8,0,0),
        Paint()..color = colors[idx%colors.length].withOpacity(0.70));
    canvas.drawLine(Offset.zero, const Offset(0,-18.7),
        Paint()..color = Colors.white.withOpacity(0.35)..strokeWidth = 0.8..strokeCap = StrokeCap.round);
    canvas.restore();
  }
  void _spiral(Canvas canvas, double cx, double cy, int idx) {
    final sa = (idx/3)*math.pi*2 + t*math.pi*0.3;
    final path = Path();
    for (int i=0;i<=60;i++) {
      final f=i/60.0, r=18+28*f, a=sa+f*math.pi*3;
      i==0 ? path.moveTo(cx+r*math.cos(a),cy+r*math.sin(a))
          : path.lineTo(cx+r*math.cos(a),cy+r*math.sin(a));
    }
    canvas.drawPath(path, Paint()..color = const Color(0xFF40916C).withOpacity(0.22)
      ..strokeWidth = 1.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
  }
  @override bool shouldRepaint(_BotanicalPainter o) => o.t!=t||o.g!=g;
}

// ════════════════════════════════════════════════════════════════════════════
//  Floating Leaf Particles Painter
// ════════════════════════════════════════════════════════════════════════════
class _FloatingLeafPainter extends CustomPainter {
  final double t;
  _FloatingLeafPainter(this.t);
  static const _seeds = [
    [0.08,0.15,0.7,0.0],[0.88,0.08,1.1,0.3],[0.15,0.78,0.9,0.6],[0.82,0.70,0.6,0.9],
    [0.45,0.05,1.3,0.15],[0.60,0.88,0.8,0.45],[0.05,0.50,1.0,0.75],[0.92,0.45,0.7,0.55],
  ];
  @override
  void paint(Canvas canvas, Size size) {
    const cols = [Color(0xFF52B788),Color(0xFF74C69D),Color(0xFF40916C),Color(0xFFB7E4C7)];
    for (int i=0;i<_seeds.length;i++) {
      final s=_seeds[i], ph=(t+s[3])%1.0;
      final x=s[0]*size.width +14*math.sin(ph*math.pi*2*s[2]);
      final y=s[1]*size.height+10*math.cos(ph*math.pi*2*s[2]*0.8);
      final r=5.0+3*math.sin(ph*math.pi);
      canvas.save();
      canvas.translate(x,y);
      canvas.rotate(ph*math.pi*2*(i.isEven?1:-1));
      canvas.drawPath(Path()..moveTo(0,0)
        ..cubicTo(-r*0.6,-r*0.9,-r*0.4,-r*1.8,0,-r*2.2)
        ..cubicTo(r*0.4,-r*1.8,r*0.6,-r*0.9,0,0),
          Paint()..color = cols[i%4].withOpacity(0.18+0.14*math.sin(ph*math.pi*2)));
      canvas.restore();
    }
  }
  @override bool shouldRepaint(_FloatingLeafPainter o) => o.t!=t;
}

// ════════════════════════════════════════════════════════════════════════════
//  Orbit Ring Painter — animated dots orbiting around the illustration circle
// ════════════════════════════════════════════════════════════════════════════
class _OrbitRingPainter extends CustomPainter {
  final double radius;
  final int dotCount;
  final double dotRadius;
  final Color color;
  final double opacity;
  final bool isLeaf;

  _OrbitRingPainter({
    required this.radius,
    required this.dotCount,
    required this.dotRadius,
    required this.color,
    required this.opacity,
    this.isLeaf = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * math.pi * 2;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      // Vary opacity per dot for a sparkle effect
      final dotOpacity = opacity * (0.5 + 0.5 * math.sin(angle * 2));
      final paint = Paint()..color = color.withOpacity(dotOpacity);

      if (isLeaf) {
        // Draw small leaf shapes
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(angle + math.pi / 2);
        final r = dotRadius;
        canvas.drawPath(
          Path()
            ..moveTo(0, 0)
            ..cubicTo(-r * 0.6, -r * 0.9, -r * 0.4, -r * 1.8, 0, -r * 2.2)
            ..cubicTo(r * 0.4, -r * 1.8, r * 0.6, -r * 0.9, 0, 0),
          paint,
        );
        canvas.restore();
      } else {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
        // Inner bright highlight
        canvas.drawCircle(Offset(x, y), dotRadius * 0.45,
            Paint()..color = Colors.white.withOpacity(dotOpacity * 0.6));
      }
    }
    // Draw the orbit track circle (faint)
    canvas.drawCircle(
      Offset(cx, cy),
      radius,
      Paint()
        ..color = color.withOpacity(opacity * 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(_OrbitRingPainter old) =>
      old.opacity != opacity || old.radius != radius;
}