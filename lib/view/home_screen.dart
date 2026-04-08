import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'plant_guide.dart';
import 'crops.dart';
import 'agri_chat.dart';
import 'landmap.dart';
import 'calculator.dart';
import 'weather_detail.dart';
import 'menu_screen.dart';

// ════════════════════════════════════════════════════════════════════════════
//  Design Tokens — exact match with splash / intro / login
// ════════════════════════════════════════════════════════════════════════════
class _G {
  static const bg       = Color(0xFFF2FAF4);
  static const g950     = Color(0xFF0D2818);
  static const g900     = Color(0xFF1B4332);
  static const g800     = Color(0xFF2D6A4F);
  static const g700     = Color(0xFF40916C);
  static const g600     = Color(0xFF52B788);
  static const g400     = Color(0xFF74C69D);
  static const g200     = Color(0xFFB7E4C7);
  static const g100     = Color(0xFFD8F3DC);
  static const g50      = Color(0xFFEDF7F1);
  static const gold     = Color(0xFFFFD166);
  static const blue     = Color(0xFF4895EF);
}

// ════════════════════════════════════════════════════════════════════════════
//  Home Page
// ════════════════════════════════════════════════════════════════════════════
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

  // ── Weather data ───────────────────────────────────────────────────────────
  String temperature = '';
  String description = '';
  String humidity    = '';
  String cityName    = '';
  String windSpeed   = '';

  // ── Animation controllers ──────────────────────────────────────────────────
  late AnimationController _bgCtrl;      // watercolor blob float
  late AnimationController _leafCtrl;    // floating botanical leaves
  late AnimationController _glowCtrl;    // pulse glow
  late AnimationController _shimmerCtrl; // header shimmer
  late AnimationController _entryCtrl;   // page entry
  late AnimationController _floatCtrl;   // card float

  late Animation<double> _bgFloat;
  late Animation<double> _glowPulse;
  late Animation<double> _headerFade;
  late Animation<Offset>  _headerSlide;
  late Animation<double> _cardsFade;
  late Animation<Offset>  _cardsSlide;
  late Animation<double> _weatherFade;
  late Animation<Offset>  _weatherSlide;
  late Animation<double> _floatAnim;

  // Per-card stagger
  final List<AnimationController> _cardCtrl  = [];
  final List<Animation<Offset>>   _cardSlide = [];
  final List<Animation<double>>   _cardFade  = [];

  final String _apiKey = "86ccb27e8e74f234c003068b6f9228aa";

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    // Background blob float (matches all other screens)
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat(reverse: true);
    _bgFloat = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut));

    // Botanical leaf float
    _leafCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat(reverse: true);

    // Glow pulse
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    // Shimmer
    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat();

    // Entry sequence
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _headerFade  = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.0, 0.40, curve: Curves.easeOut)));
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.05), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic)));
    _weatherFade  = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.25, 0.65, curve: Curves.easeOut)));
    _weatherSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.25, 0.65, curve: Curves.easeOutCubic)));
    _cardsFade  = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.50, 1.0, curve: Curves.easeOut)));
    _cardsSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.50, 1.0, curve: Curves.easeOutCubic)));

    // Floating card drift
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: 5)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    // Per-card stagger (6 cards)
    for (int i = 0; i < 6; i++) {
      final ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
      _cardCtrl.add(ctrl);
      _cardSlide.add(Tween<Offset>(begin: const Offset(0, 0.20), end: Offset.zero)
          .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic)));
      _cardFade.add(Tween<double>(begin: 0, end: 1)
          .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut)));
      Future.delayed(Duration(milliseconds: 500 + i * 80), () {
        if (mounted) ctrl.forward();
      });
    }

    _entryCtrl.forward();
    requestLocationAndFetchWeather();
  }

  @override
  void dispose() {
    _bgCtrl.dispose(); _leafCtrl.dispose(); _glowCtrl.dispose();
    _shimmerCtrl.dispose(); _entryCtrl.dispose(); _floatCtrl.dispose();
    for (final c in _cardCtrl) c.dispose();
    super.dispose();
  }

  // ── Weather fetch ──────────────────────────────────────────────────────────
  Future<void> requestLocationAndFetchWeather() async {
    var status = await Permission.location.status;
    if (!status.isGranted) status = await Permission.location.request();
    if (status.isGranted) {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      fetchWeatherByLocation(pos.latitude, pos.longitude);
    }
  }

  Future<void> fetchWeatherByLocation(double lat, double lon) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric";
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        setState(() {
          cityName    = d["name"];
          temperature = d["main"]["temp"].toStringAsFixed(1);
          description = d["weather"][0]["description"];
          humidity    = d["main"]["humidity"].toString();
          windSpeed   = d["wind"]["speed"].toStringAsFixed(1);
        });
      }
    } catch (_) {}
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get _greetingEmoji {
    final h = DateTime.now().hour;
    if (h < 12) return '🌱';
    if (h < 17) return '☀️';
    return '🌙';
  }

  // ════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _G.bg,
        drawer: MenuScreen(),
        body: Stack(children: [

          // ── 1. Watercolor blob background (exact match with all screens) ──
          AnimatedBuilder(
            animation: _bgFloat,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _WatercolorBgPainter(_bgFloat.value),
            ),
          ),

          // ── 2. Floating botanical leaf particles ──────────────────────────
          AnimatedBuilder(
            animation: _leafCtrl,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _FloatingLeafPainter(_leafCtrl.value),
            ),
          ),

          // ── 3. Main content ───────────────────────────────────────────────
          SafeArea(
            child: Column(children: [
              _buildHeader(size),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildGreetingPill(size),
                        const SizedBox(height: 18),
                        _buildWeatherCard(size),
                        const SizedBox(height: 26),
                        _buildSectionLabel('Manage Your Fields', size),
                        const SizedBox(height: 14),
                        _buildCardGrid(size),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  HEADER
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildHeader(Size size) {
    return FadeTransition(
      opacity: _headerFade,
      child: SlideTransition(
        position: _headerSlide,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // Logo — glassmorphism circle + shimmer text (same as splash/login)
              Row(children: [
                AnimatedBuilder(
                  animation: _glowPulse,
                  builder: (_, __) => ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.55),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.85), width: 1.5),
                          boxShadow: [BoxShadow(
                            color: _G.g600.withOpacity(0.18 + 0.10 * _glowPulse.value),
                            blurRadius: 14 + 8 * _glowPulse.value,
                            spreadRadius: 1,
                          )],
                        ),
                        child: Center(
                          child: Transform.scale(
                            scale: 0.92 + 0.08 * _glowPulse.value,
                            child: const Icon(Icons.eco_rounded,
                                color: _G.g800, size: 22),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  AnimatedBuilder(
                    animation: _shimmerCtrl,
                    builder: (_, __) => ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) {
                        final x = _shimmerCtrl.value * (bounds.width + 120) - 60;
                        return LinearGradient(
                          colors: const [
                            _G.g900, _G.g800, _G.g600,
                            Color(0xFFB7E4C7), _G.g600, _G.g800, _G.g900,
                          ],
                          stops: const [0.0, 0.18, 0.36, 0.50, 0.64, 0.82, 1.0],
                          begin: Alignment((x / bounds.width) * 2 - 1, 0),
                          end:   Alignment((x / bounds.width) * 2 + 1, 0),
                        ).createShader(bounds);
                      },
                      child: Text(
                        'Greenexis',
                        style: TextStyle(
                          fontSize: size.width * 0.065,
                          fontWeight: FontWeight.w900,
                          color: _G.g900,
                          letterSpacing: -1.0,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Smart Farming Assistant',
                    style: TextStyle(
                      fontSize: size.width * 0.028,
                      color: _G.g700.withOpacity(0.72),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ]),
              ]),

              // Hamburger — glassy, exact match with login card style
              Builder(
                builder: (ctx) => GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Scaffold.of(ctx).openDrawer();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.60),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.85), width: 1.2),
                          boxShadow: [BoxShadow(
                            color: _G.g600.withOpacity(0.15),
                            blurRadius: 12, offset: const Offset(0, 3),
                          )],
                        ),
                        child: const Icon(Icons.menu_rounded, color: _G.g800, size: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  GREETING PILL (matches splash bottom badge style)
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildGreetingPill(Size size) {
    return FadeTransition(
      opacity: _headerFade,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.58),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.82), width: 1.2),
              boxShadow: [BoxShadow(
                color: _G.g600.withOpacity(0.10),
                blurRadius: 12, offset: const Offset(0, 3),
              )],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(_greetingEmoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Text(
                '$_greeting, Farmer',
                style: TextStyle(
                  fontSize: size.width * 0.034,
                  fontWeight: FontWeight.w700,
                  color: _G.g900,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(width: 10),
              Container(width: 4, height: 4,
                  decoration: const BoxDecoration(color: _G.g600, shape: BoxShape.circle)),
              const SizedBox(width: 10),
              Text(
                'Grow smarter. Farm better.',
                style: TextStyle(
                  fontSize: size.width * 0.028,
                  color: _G.g700.withOpacity(0.72),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  WEATHER CARD — rich, botanical, glassmorphic
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildWeatherCard(Size size) {
    return FadeTransition(
      opacity: _weatherFade,
      child: SlideTransition(
        position: _weatherSlide,
        child: _TapCard(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WeatherDetailPage(
              cityName: cityName, temperature: temperature,
              description: description, humidity: humidity,
            )),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: AnimatedBuilder(
                animation: _glowPulse,
                builder: (_, __) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.72),
                        _G.g100.withOpacity(0.50),
                        _G.g200.withOpacity(0.30),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.85), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: _G.g600.withOpacity(0.12 + 0.06 * _glowPulse.value),
                        blurRadius: 28, offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(children: [

                    // Decorative blobs inside card
                    Positioned(top: -24, right: -24, child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _G.g200.withOpacity(0.40)),
                    )),
                    Positioned(top: 8, right: 8, child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.60),
                            border: Border.all(
                                color: _G.g200.withOpacity(0.80), width: 1.2),
                          ),
                          child: const Icon(Icons.wb_sunny_outlined,
                              color: _G.g800, size: 26),
                        ),
                      ),
                    )),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location row
                        Row(children: [
                          Icon(Icons.location_on_rounded,
                              color: _G.g600, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            cityName.isEmpty ? 'Locating...' : cityName,
                            style: TextStyle(
                              fontSize: size.width * 0.032,
                              color: _G.g700,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 10),

                        // Temperature + description
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              temperature.isEmpty ? '--' : '${temperature}°',
                              style: TextStyle(
                                fontSize: size.width * 0.155,
                                fontWeight: FontWeight.w800,
                                color: _G.g900,
                                height: 1.0,
                                letterSpacing: -2,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'C',
                                style: TextStyle(
                                  fontSize: size.width * 0.055,
                                  fontWeight: FontWeight.w700,
                                  color: _G.g700,
                                ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),

                        Text(
                          description.isEmpty ? 'Fetching weather...' : _capitalize(description),
                          style: TextStyle(
                            fontSize: size.width * 0.035,
                            color: _G.g700.withOpacity(0.80),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Thin divider
                        Container(
                          height: 1,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Colors.transparent,
                              _G.g200.withOpacity(0.80),
                              Colors.transparent,
                            ]),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Stat pills row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _WeatherStatPill(
                              icon: Icons.water_drop_outlined,
                              label: 'Humidity',
                              value: humidity.isEmpty ? '--' : '$humidity%',
                            ),
                            _WeatherStatPill(
                              icon: Icons.air_rounded,
                              label: 'Wind',
                              value: windSpeed.isEmpty ? '--' : '${windSpeed}m/s',
                            ),
                            _WeatherStatPill(
                              icon: Icons.grass_outlined,
                              label: 'Soil',
                              value: 'Good',
                            ),
                            _WeatherStatPill(
                              icon: Icons.umbrella_outlined,
                              label: 'Rain',
                              value: 'Low',
                            ),
                            // Tap arrow
                            ClipOval(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                                child: Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _G.g800.withOpacity(0.10),
                                    border: Border.all(
                                        color: _G.g200.withOpacity(0.60), width: 1),
                                  ),
                                  child: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: _G.g800, size: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  SECTION LABEL — same decorative divider style as intro/login screens
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildSectionLabel(String text, Size size) {
    return FadeTransition(
      opacity: _cardsFade,
      child: Row(children: [
        Container(
          width: 3.5, height: 22,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_G.g800, _G.g400],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: size.width * 0.045,
            fontWeight: FontWeight.w800,
            color: _G.g900,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        // Decorative dot row (matches intro divider dots)
        Row(children: [
          Container(width: 20, height: 1.5,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.transparent, _G.g400]),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 6),
          Container(width: 5, height: 5,
              decoration: const BoxDecoration(color: _G.g600, shape: BoxShape.circle)),
        ]),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  CARD GRID
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildCardGrid(Size size) {
    final cards = _cardItems(context);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 0.96,
      children: List.generate(cards.length, (i) {
        return SlideTransition(
          position: _cardSlide[i],
          child: FadeTransition(
            opacity: _cardFade[i],
            child: AnimatedBuilder(
              animation: _floatAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, i.isEven ? -_floatAnim.value * 0.30 : _floatAnim.value * 0.30),
                child: child,
              ),
              child: _TapCard(
                onTap: cards[i].onTap,
                child: _buildCardShell(cards[i], size),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Single card shell with glassmorphism + botanical orb ─────────────────
  Widget _buildCardShell(_CardItem item, Size size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: item.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withOpacity(0.82), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: item.accentColor.withOpacity(0.14),
                blurRadius: 18, offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.80),
                blurRadius: 0, offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Stack(children: [

            // Decorative blob orb (matches splash botanical aura)
            Positioned(top: -26, right: -26, child: Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.30),
              ),
            )),
            Positioned(top: -10, right: -10, child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.22),
              ),
            )),

            // Bottom left micro spiral dot (matches splash dot pattern)
            Positioned(bottom: 10, left: 14, child: Row(children: [
              Container(width: 4, height: 4,
                  decoration: BoxDecoration(color: item.accentColor.withOpacity(0.25), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Container(width: 3, height: 3,
                  decoration: BoxDecoration(color: item.accentColor.withOpacity(0.15), shape: BoxShape.circle)),
              const SizedBox(width: 3),
              Container(width: 2, height: 2,
                  decoration: BoxDecoration(color: item.accentColor.withOpacity(0.10), shape: BoxShape.circle)),
            ])),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Icon circle (glassmorphism like login field icons)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        width: 54, height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.68),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.90), width: 1.2),
                          boxShadow: [BoxShadow(
                            color: item.accentColor.withOpacity(0.14),
                            blurRadius: 8, offset: const Offset(0, 3),
                          )],
                        ),
                        child: Center(
                          child: Icon(item.icon, color: item.accentColor, size: 26),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Title
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: size.width * 0.040,
                      fontWeight: FontWeight.w800,
                      color: item.accentColor,
                      letterSpacing: -0.2,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Subtitle
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      fontSize: size.width * 0.029,
                      color: item.accentColor.withOpacity(0.60),
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Arrow pill (matches intro badge pill)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: item.accentColor.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: item.accentColor.withOpacity(0.20), width: 1),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text(
                              'Open',
                              style: TextStyle(
                                fontSize: size.width * 0.026,
                                fontWeight: FontWeight.w700,
                                color: item.accentColor,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded,
                                color: item.accentColor, size: 11),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  List<_CardItem> _cardItems(BuildContext ctx) => [
    _CardItem(
      title: 'Plant Guide',
      subtitle: 'Diagnose & identify plants',
      icon: Icons.eco_rounded,
      gradientColors: [const Color(0xFFDDF5E8), const Color(0xFFC0EDD4)],
      accentColor: const Color(0xFF1A5C38),
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const PlantGuide())),
    ),
    _CardItem(
      title: 'Crops',
      subtitle: 'Browse crop varieties',
      icon: Icons.grass_rounded,
      gradientColors: [const Color(0xFFF0FAF3), const Color(0xFFD5F0E0)],
      accentColor: const Color(0xFF2D6A4F),
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => Crops(userLocation: cityName))),
    ),
    _CardItem(
      title: 'Agri ChatBot',
      subtitle: 'AI farming assistant',
      icon: Icons.chat_bubble_outline_rounded,
      gradientColors: [const Color(0xFFE0F4FF), const Color(0xFFC2E8FF)],
      accentColor: const Color(0xFF0D5E9E),
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const AgriChatBot())),
    ),
    _CardItem(
      title: '7/12 Record',
      subtitle: 'Land ownership docs',
      icon: Icons.description_outlined,
      gradientColors: [const Color(0xFFFFF8E8), const Color(0xFFFFECC2)],
      accentColor: const Color(0xFF7A5200),
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const LandMap())),
    ),
    _CardItem(
      title: 'Calculator',
      subtitle: 'Costs, yield & profits',
      icon: Icons.calculate_outlined,
      gradientColors: [const Color(0xFFEDE5FF), const Color(0xFFD8C8FF)],
      accentColor: const Color(0xFF4A1A9A),
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const Calculator())),
    ),
    _CardItem(
      title: 'Land Map',
      subtitle: 'View & track your land',
      icon: Icons.map_outlined,
      gradientColors: [const Color(0xFFE5FFF8), const Color(0xFFC5F5E8)],
      accentColor: const Color(0xFF0A5C52),
      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => const LandMap())),
    ),
  ];

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ════════════════════════════════════════════════════════════════════════════
//  Weather Stat Pill (matches splash badge pill + intro feature chips)
// ════════════════════════════════════════════════════════════════════════════
class _WeatherStatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _WeatherStatPill({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.58),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _G.g200.withOpacity(0.75), width: 1),
            boxShadow: [BoxShadow(
              color: _G.g600.withOpacity(0.08),
              blurRadius: 6, offset: const Offset(0, 2),
            )],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: _G.g700, size: 13),
            const SizedBox(height: 3),
            Text(value,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: _G.g900)),
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    color: _G.g700.withOpacity(0.65),
                    fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Tap Card — press scale with spring reverse (matches all screen buttons)
// ════════════════════════════════════════════════════════════════════════════
class _TapCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _TapCard({required this.child, required this.onTap});

  @override
  State<_TapCard> createState() => _TapCardState();
}

class _TapCardState extends State<_TapCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 320),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) { HapticFeedback.lightImpact(); _ctrl.forward(); },
      onTapUp:   (_) { widget.onTap(); _ctrl.reverse(); },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  Card Item Data Model
// ════════════════════════════════════════════════════════════════════════════
class _CardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final Color accentColor;
  final VoidCallback onTap;
  const _CardItem({
    required this.title, required this.subtitle, required this.icon,
    required this.gradientColors, required this.accentColor, required this.onTap,
  });
}

// ════════════════════════════════════════════════════════════════════════════
//  Watercolor Background Painter (exact copy from splash / intro / login)
// ════════════════════════════════════════════════════════════════════════════
class _WatercolorBgPainter extends CustomPainter {
  final double t;
  _WatercolorBgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFF2FAF4));

    final blobs = [
      _Blob(
        center: Offset(
          size.width  * (0.80 + 0.04 * math.sin(t * math.pi)),
          size.height * (0.10 + 0.03 * math.cos(t * math.pi * 1.3)),
        ),
        radius: size.width * 0.55,
        color: const Color(0xFFB7E4C7).withOpacity(0.38),
        blur: 80,
      ),
      _Blob(
        center: Offset(
          size.width  * (0.10 + 0.03 * math.cos(t * math.pi * 0.9)),
          size.height * (0.22 + 0.04 * math.sin(t * math.pi * 1.1)),
        ),
        radius: size.width * 0.48,
        color: const Color(0xFF95D5B2).withOpacity(0.28),
        blur: 70,
      ),
      _Blob(
        center: Offset(
          size.width  * (0.70 + 0.05 * math.sin(t * math.pi * 1.2)),
          size.height * (0.55 + 0.04 * math.cos(t * math.pi * 0.8)),
        ),
        radius: size.width * 0.42,
        color: const Color(0xFF74C69D).withOpacity(0.22),
        blur: 65,
      ),
      _Blob(
        center: Offset(
          size.width  * (0.15 + 0.03 * math.sin(t * math.pi * 1.4)),
          size.height * (0.75 + 0.03 * math.cos(t * math.pi)),
        ),
        radius: size.width * 0.40,
        color: const Color(0xFFD8F3DC).withOpacity(0.45),
        blur: 60,
      ),
      _Blob(
        center: Offset(
          size.width  * (0.50 + 0.02 * math.cos(t * math.pi * 1.6)),
          size.height * (0.90 + 0.02 * math.sin(t * math.pi)),
        ),
        radius: size.width * 0.38,
        color: const Color(0xFF52B788).withOpacity(0.14),
        blur: 55,
      ),
    ];

    for (final b in blobs) {
      canvas.drawCircle(b.center, b.radius,
          Paint()..color = b.color
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, b.blur));
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
  const _Blob({required this.center, required this.radius,
    required this.color, required this.blur});
}

// ════════════════════════════════════════════════════════════════════════════
//  Floating Leaf Particles Painter (exact copy from all other screens)
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
    [0.33, 0.35, 0.8, 0.22],
    [0.70, 0.62, 1.0, 0.68],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const colors = [
      Color(0xFF52B788), Color(0xFF74C69D),
      Color(0xFF40916C), Color(0xFFB7E4C7),
    ];

    for (int i = 0; i < _seeds.length; i++) {
      final s  = _seeds[i];
      final ph = (t + s[3]) % 1.0;
      final x  = s[0] * size.width  + 14 * math.sin(ph * math.pi * 2 * s[2]);
      final y  = s[1] * size.height + 10 * math.cos(ph * math.pi * 2 * s[2] * 0.8);
      final r  = 5.0 + 3 * math.sin(ph * math.pi);
      final op = 0.18 + 0.14 * math.sin(ph * math.pi * 2);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(ph * math.pi * 2 * (i.isEven ? 1 : -1));
      canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..cubicTo(-r * 0.6, -r * 0.9, -r * 0.4, -r * 1.8, 0, -r * 2.2)
          ..cubicTo(r * 0.4, -r * 1.8, r * 0.6, -r * 0.9, 0, 0),
        Paint()..color = colors[i % 4].withOpacity(op),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_FloatingLeafPainter old) => old.t != t;
}
