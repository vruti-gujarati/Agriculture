import 'dart:convert';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

// ─── Design Tokens (matching splash screen) ──────────────────────────────────
class _G {
  static const bg         = Color(0xFFE8F5EE);   // exact splash bg
  static const green950   = Color(0xFF0D2818);
  static const green900   = Color(0xFF1B4332);
  static const green800   = Color(0xFF2D6A4F);
  static const green700   = Color(0xFF3A7D5A);
  static const green600   = Color(0xFF52B788);
  static const green400   = Color(0xFF74C69D);
  static const green200   = Color(0xFFB7E4C7);
  static const green100   = Color(0xFFD8F3DC);
  static const green50    = Color(0xFFEDF7F1);
  static const white70    = Color(0xB3FFFFFF);
  static const white55    = Color(0x8CFFFFFF);
}

// Card definitions — glassy mint tones matching the splash palette
const _cardGradients = <List<Color>>[
  [Color(0xFFDDF5E8), Color(0xFFC0EDD4)], // Plant Guide – pale mint
  [Color(0xFFF0FAF3), Color(0xFFD5F0E0)], // Crops – misty green
  [Color(0xFFE0F4FF), Color(0xFFC2E8FF)], // Agri ChatBot – sky tint
  [Color(0xFFFFF5E0), Color(0xFFFFE5B0)], // 7/12 Record – warm cream
  [Color(0xFFEDE5FF), Color(0xFFD8C8FF)], // Calculator – soft lavender
  [Color(0xFFE5FFF8), Color(0xFFC5F5E8)], // Extra – fresh aqua
];

const _cardAccents = <Color>[
  Color(0xFF1A5C38),
  Color(0xFF2D6A4F),
  Color(0xFF1056A0),
  Color(0xFF7A5200),
  Color(0xFF4A1A9A),
  Color(0xFF0A5C52),
];

const _cardIcons = <IconData>[
  Icons.eco_rounded,
  Icons.grass_rounded,
  Icons.chat_bubble_outline_rounded,
  Icons.description_outlined,
  Icons.calculate_outlined,
  Icons.map_outlined,
];

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {

  String temperature = "";
  String description = "";
  String humidity    = "";
  String cityName    = "";

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  late AnimationController _floatCtrl;
  late Animation<double>   _floatAnim;

  // Leaf particle controller
  late AnimationController _leafCtrl;

  final List<AnimationController> _cardCtrl  = [];
  final List<Animation<Offset>>   _cardSlide = [];
  final List<Animation<double>>   _cardFade  = [];

  final List<_LeafParticle> _leaves = [];
  final math.Random _rng = math.Random();

  final String apiKey = "86ccb27e8e74f234c003068b6f9228aa";

  @override
  void initState() {
    super.initState();

    // Page fade in
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
    _fadeCtrl.forward();

    // Floating cards
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: 6)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    // Leaf particle drift
    _leafCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 8000))
      ..repeat();

    // Generate leaf particles (matching splash)
    for (int i = 0; i < 12; i++) {
      _leaves.add(_LeafParticle(
        startX: _rng.nextDouble(),
        startY: _rng.nextDouble(),
        size: 6 + _rng.nextDouble() * 10,
        speed: 0.04 + _rng.nextDouble() * 0.06,
        phase: _rng.nextDouble(),
        angle: _rng.nextDouble() * math.pi * 2,
        opacity: 0.08 + _rng.nextDouble() * 0.18,
      ));
    }

    // Staggered card animations
    for (int i = 0; i < 6; i++) {
      final ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 560));
      _cardCtrl.add(ctrl);
      _cardSlide.add(
        Tween<Offset>(begin: const Offset(0, 0.22), end: Offset.zero)
            .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic)),
      );
      _cardFade.add(
        Tween<double>(begin: 0, end: 1)
            .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut)),
      );
      Future.delayed(Duration(milliseconds: 350 + i * 90), () {
        if (mounted) ctrl.forward();
      });
    }

    requestLocationAndFetchWeather();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _floatCtrl.dispose();
    _leafCtrl.dispose();
    for (final c in _cardCtrl) c.dispose();
    super.dispose();
  }

  Future<void> requestLocationAndFetchWeather() async {
    var status = await Permission.location.status;
    if (!status.isGranted) status = await Permission.location.request();
    if (status.isGranted) {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      fetchWeatherByLocation(pos.latitude, pos.longitude);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied. Enter city manually to get weather.")),
      );
    }
  }

  Future<void> fetchWeatherByLocation(double lat, double lon) async {
    final url = "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric";
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final d = jsonDecode(res.body);
        setState(() {
          cityName    = d["name"];
          temperature = d["main"]["temp"].toString();
          description = d["weather"][0]["description"];
          humidity    = d["main"]["humidity"].toString();
        });
      }
    } catch (e) {
      debugPrint("Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _G.bg,
      drawer: MenuScreen(),
      body: Stack(
        children: [
          // ── Leaf particle background (matching splash) ──
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _leafCtrl,
              builder: (_, __) => CustomPaint(
                painter: _LeafParticlePainter(_leaves, _leafCtrl.value),
              ),
            ),
          ),

          // ── Soft blob background ──
          Positioned.fill(child: CustomPaint(painter: _BlobPainter())),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          _buildGreetingBadge(),
                          const SizedBox(height: 16),
                          _buildWeatherCard(),
                          const SizedBox(height: 28),
                          _buildSectionLabel("Manage Your Fields"),
                          const SizedBox(height: 14),
                          _buildAllCards(),
                          const SizedBox(height: 36),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo area — matching splash screen style
          Row(children: [
            // Leaf icon circle (like splash center circle, smaller)
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: _G.green400.withOpacity(0.30),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.eco_rounded, color: _G.green800, size: 20),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Gr",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: _G.green600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: "eenexis",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: _G.green900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "Smart Farming Assistant",
                style: TextStyle(
                  fontSize: 10.5,
                  color: _G.green700.withOpacity(0.75),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ]),
          ]),

          // Menu button — glassy circle
          Builder(
            builder: (context) => GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Scaffold.of(context).openDrawer();
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _G.green200.withOpacity(0.9), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: _G.green400.withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.menu_rounded, color: _G.green800, size: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── GREETING BADGE (matches splash "v1.0 • Made for Farmers" pill style) ──
  Widget _buildGreetingBadge() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? "Good Morning" : hour < 17 ? "Good Afternoon" : "Good Evening";
    final emoji = hour < 12 ? "🌱" : hour < 17 ? "☀️" : "🌙";

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.45),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _G.green200.withOpacity(0.8), width: 1),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Text(
              "$greeting, Farmer",
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _G.green800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 4, height: 4, decoration: const BoxDecoration(color: _G.green600, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(
              "Grow smarter. Farm better.",
              style: TextStyle(
                fontSize: 11,
                color: _G.green700.withOpacity(0.70),
                fontWeight: FontWeight.w400,
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ── SECTION LABEL ────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String text) {
    return Row(children: [
      Container(
        width: 3.5, height: 20,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_G.green700, _G.green400],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        text,
        style: const TextStyle(
          fontSize: 15.5,
          fontWeight: FontWeight.w800,
          color: _G.green900,
          letterSpacing: 0.1,
        ),
      ),
    ]);
  }

  // ── WEATHER CARD ─────────────────────────────────────────────────────────────
  Widget _buildWeatherCard() {
    return _TapCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WeatherDetailPage(
            cityName: cityName,
            temperature: temperature,
            description: description,
            humidity: humidity,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: double.infinity,
            height: 155,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.55),
                  _G.green100.withOpacity(0.40),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white.withOpacity(0.75), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _G.green600.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative leaf circle (splash motif)
                Positioned(
                  right: -20, top: -20,
                  child: Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _G.green200.withOpacity(0.25),
                    ),
                  ),
                ),
                Positioned(
                  right: 10, top: 10,
                  child: Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.55),
                      border: Border.all(color: _G.green200.withOpacity(0.6), width: 1),
                    ),
                    child: const Icon(Icons.wb_sunny_outlined, color: _G.green700, size: 26),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(
                          temperature.isEmpty ? "Loading..." : "${temperature}°C",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: _G.green900,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            cityName.isEmpty ? "Locating..." : cityName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _G.green800,
                            ),
                          ),
                          Text(
                            description.isEmpty ? "Fetching weather..." : _capitalize(description),
                            style: TextStyle(
                              fontSize: 11,
                              color: _G.green700.withOpacity(0.70),
                            ),
                          ),
                        ]),
                      ]),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _WeatherPill(
                            icon: Icons.water_drop_outlined,
                            label: "Humidity",
                            value: humidity.isEmpty ? "--" : "$humidity%",
                          ),
                          _WeatherPill(icon: Icons.grass_outlined, label: "Soil", value: "Good"),
                          _WeatherPill(icon: Icons.umbrella_outlined, label: "Rain", value: "Low"),
                          // Tap hint
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: _G.green700.withOpacity(0.10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_forward_ios_rounded, color: _G.green800, size: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── GRID CARDS ───────────────────────────────────────────────────────────────
  Widget _buildAllCards() {
    final items = [
      _CardItem(
        title: "Plant Guide",
        subtitle: "Diagnose plants",
        imagePath: "assets/home_screen/plant_guide.png",
        icon: _cardIcons[0],
        gradientColors: _cardGradients[0],
        accentColor: _cardAccents[0],
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlantGuide())),
      ),
      _CardItem(
        title: "Crops",
        subtitle: "Browse varieties",
        imagePath: "assets/home_screen/crops.png",
        icon: _cardIcons[1],
        gradientColors: _cardGradients[1],
        accentColor: _cardAccents[1],
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Crops(userLocation: cityName))),
      ),
      _CardItem(
        title: "Agri ChatBot",
        subtitle: "Ask anything",
        imagePath: "assets/home_screen/agrichatbot.png",
        icon: _cardIcons[2],
        gradientColors: _cardGradients[2],
        accentColor: _cardAccents[2],
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgriChatBot())),
      ),
      _CardItem(
        title: "7/12 Record",
        subtitle: "Land documents",
        imagePath: "assets/home_screen/info712.png",
        icon: _cardIcons[3],
        gradientColors: _cardGradients[3],
        accentColor: _cardAccents[3],
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandMap())),
      ),
      _CardItem(
        title: "Calculator",
        subtitle: "Costs & yield",
        imagePath: "assets/home_screen/calculator.png",
        icon: _cardIcons[4],
        gradientColors: _cardGradients[4],
        accentColor: _cardAccents[4],
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Calculator())),
      ),
      _CardItem(
        title: "Land Map",
        subtitle: "View your land",
        imagePath: "assets/home_screen/calculator.png",
        icon: _cardIcons[5],
        gradientColors: _cardGradients[5],
        accentColor: _cardAccents[5],
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandMap())),
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 13,
      mainAxisSpacing: 13,
      childAspectRatio: 1.0,
      children: List.generate(items.length, (i) {
        return SlideTransition(
          position: _cardSlide[i],
          child: FadeTransition(
            opacity: _cardFade[i],
            child: AnimatedBuilder(
              animation: _floatAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, i.isEven ? -_floatAnim.value * 0.35 : _floatAnim.value * 0.35),
                child: child,
              ),
              child: _TapCard(
                onTap: items[i].onTap,
                child: _buildCardShell(items[i]),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCardShell(_CardItem item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: item.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.80), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: item.accentColor.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.85),
                blurRadius: 0,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative orb top-right (like splash leaf aura)
              Positioned(
                top: -22, right: -22,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.28),
                  ),
                ),
              ),
              Positioned(
                top: -8, right: -8,
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.22),
                  ),
                ),
              ),

              // Card content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon in glassy circle
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.60),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: item.accentColor.withOpacity(0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            item.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(item.icon, color: item.accentColor, size: 26),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: item.accentColor,
                        letterSpacing: 0.1,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: item.accentColor.withOpacity(0.58),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    // Bottom arrow — like the splash bottom badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 26, height: 26,
                          decoration: BoxDecoration(
                            color: item.accentColor.withOpacity(0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: item.accentColor,
                            size: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── WEATHER PILL (glassy, matching splash pill "v1.0 • Made for Farmers") ─────
class _WeatherPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _WeatherPill({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _G.green200.withOpacity(0.7), width: 1),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: _G.green700, size: 13),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: _G.green900,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: _G.green700.withOpacity(0.65),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── TAP CARD with press animation ──────────────────────────────────────────────
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
      duration: const Duration(milliseconds: 130),
      reverseDuration: const Duration(milliseconds: 280),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn, reverseCurve: _SpringOut()));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _ctrl.forward();
      },
      onTapUp: (_) {
        widget.onTap();
        _ctrl.reverse();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}

class _SpringOut extends Curve {
  @override
  double transformInternal(double t) =>
      1.0 - math.exp(-6.5 * t) * math.cos(11.0 * t);
}

// ── CARD ITEM ──────────────────────────────────────────────────────────────────
class _CardItem {
  final String title;
  final String subtitle;
  final String imagePath;
  final IconData icon;
  final List<Color> gradientColors;
  final Color accentColor;
  final VoidCallback onTap;
  const _CardItem({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.icon,
    required this.gradientColors,
    required this.accentColor,
    required this.onTap,
  });
}

// ── LEAF PARTICLE (matching splash floating leaves) ──────────────────────────
class _LeafParticle {
  final double startX;
  final double startY;
  final double size;
  final double speed;
  final double phase;
  final double angle;
  final double opacity;
  const _LeafParticle({
    required this.startX,
    required this.startY,
    required this.size,
    required this.speed,
    required this.phase,
    required this.angle,
    required this.opacity,
  });
}

class _LeafParticlePainter extends CustomPainter {
  final List<_LeafParticle> leaves;
  final double t;
  const _LeafParticlePainter(this.leaves, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    for (final leaf in leaves) {
      final progress = (t * leaf.speed + leaf.phase) % 1.0;
      final x = (leaf.startX + math.sin(progress * math.pi * 2 + leaf.phase) * 0.06) * size.width;
      final y = (leaf.startY - progress * 0.3 + 0.3) % 1.0 * size.height;
      final rotation = leaf.angle + progress * math.pi * 2;

      final paint = Paint()
        ..color = _G.green600.withOpacity(leaf.opacity * (1 - (progress > 0.85 ? (progress - 0.85) / 0.15 : 0)))
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);
      _drawLeaf(canvas, leaf.size, paint);
      canvas.restore();
    }
  }

  void _drawLeaf(Canvas canvas, double s, Paint paint) {
    final path = Path()
      ..moveTo(0, -s)
      ..cubicTo(s * 0.6, -s * 0.5, s * 0.6, s * 0.5, 0, s)
      ..cubicTo(-s * 0.6, s * 0.5, -s * 0.6, -s * 0.5, 0, -s)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LeafParticlePainter old) => old.t != t;
}

// ── BLOB BACKGROUND (soft, matching splash glow) ──────────────────────────────
class _BlobPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    void blob(Offset c, double r, Color col) {
      canvas.drawCircle(c, r, Paint()
        ..color = col
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 70));
    }
    blob(Offset(size.width * 0.85, size.height * 0.08), size.width * 0.55,
        const Color(0xFFB7E4C7).withOpacity(0.32));
    blob(Offset(size.width * 0.10, size.height * 0.22), size.width * 0.44,
        const Color(0xFFD8F3DC).withOpacity(0.26));
    blob(Offset(size.width * 0.65, size.height * 0.55), size.width * 0.40,
        const Color(0xFFB7E4C7).withOpacity(0.22));
    blob(Offset(size.width * 0.20, size.height * 0.78), size.width * 0.38,
        const Color(0xFFD8F3DC).withOpacity(0.18));
  }

  @override
  bool shouldRepaint(_) => false;
}