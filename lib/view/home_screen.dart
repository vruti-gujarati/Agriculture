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

// ─── Design Tokens ────────────────────────────────────────────────────────────
class _G {
  static const green950 = Color(0xFF0D2818);
  static const green900 = Color(0xFF1B4332);
  static const green800 = Color(0xFF2D6A4F);
  static const green700 = Color(0xFF40916C);
  static const green600 = Color(0xFF52B788);
  static const green400 = Color(0xFF74C69D);
  static const green200 = Color(0xFFB7E4C7);
  static const green100 = Color(0xFFD8F3DC);
  static const green50  = Color(0xFFF0FAF4);
}

// ✅ FIXED: All 6 cards have unique colors — mint, light yellow, sky blue, peach, lavender, aqua
const _cardGradients = <List<Color>>[
  [Color(0xFFC8F6D8), Color(0xFF9EECC0)], // Plant Guide – Soft mint
  [Color(0xFFFFFACC), Color(0xFFFFF099)], // Crops – Very light yellow
  [Color(0xFFC2EAFF), Color(0xFF85CFFF)], // Agri ChatBot – Sky blue
  [Color(0xFFFFD6C0), Color(0xFFFFB48A)], // 7/12 Record – Soft peach
  [Color(0xFFE8D5FF), Color(0xFFCFA8FF)], // Calculator – Lavender
  [Color(0xFFB2F2E8), Color(0xFF6FE0CE)], // Card 6 – Fresh aqua ✅ DIFFERENT
];

const _cardAccents = <Color>[
  Color(0xFF1E6B40), // Plant Guide – dark green
  Color(0xFF6B5200), // Crops – dark amber
  Color(0xFF1056A0), // ChatBot – dark blue
  Color(0xFF8B3200), // 7/12 Record – dark orange
  Color(0xFF4A1A9A), // Calculator – dark purple
  Color(0xFF0A5C52), // Card 6 – dark teal ✅ DIFFERENT
];

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin {

  String temperature = "";
  String description = "";
  String humidity    = "";
  String cityName    = "";

  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  late AnimationController _shimmerCtrl;

  late AnimationController _floatCtrl;
  late Animation<double>   _floatAnim;

  final List<AnimationController> _cardCtrl  = [];
  final List<Animation<Offset>>   _cardSlide = [];
  final List<Animation<double>>   _cardFade  = [];

  final TextEditingController cityController = TextEditingController();
  final String apiKey = "86ccb27e8e74f234c003068b6f9228aa";

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 950));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
    _fadeCtrl.forward();

    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat();

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: 5).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    for (int i = 0; i < 6; i++) {
      final ctrl = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 520));
      _cardCtrl.add(ctrl);
      _cardSlide.add(Tween<Offset>(
          begin: const Offset(0, 0.18), end: Offset.zero)
          .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic)));
      _cardFade.add(Tween<double>(begin: 0, end: 1)
          .animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut)));

      Future.delayed(Duration(milliseconds: 300 + i * 80), () {
        if (mounted) ctrl.forward();
      });
    }

    requestLocationAndFetchWeather();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _shimmerCtrl.dispose();
    _floatCtrl.dispose();
    for (final c in _cardCtrl) c.dispose();
    super.dispose();
  }

  Future<void> requestLocationAndFetchWeather() async {
    var status = await Permission.location.status;
    if (!status.isGranted) status = await Permission.location.request();
    if (status.isGranted) {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      fetchWeatherByLocation(pos.latitude, pos.longitude);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            "Location permission denied. Enter city manually to get weather."),
      ));
    }
  }

  Future<void> fetchWeatherByLocation(double lat, double lon) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric";
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unable to fetch weather")));
      }
    } catch (e) {
      debugPrint("Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _G.green50,
      drawer: const MenuScreen(),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _BgPainter())),

          SafeArea(
            child: Column(
              children: [

                // ✅ FIXED HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: _buildHeader(),
                ),

                // ✅ SCROLLABLE CONTENT
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          _buildWeatherCard(),
                          const SizedBox(height: 24),
                          _buildSectionLabel("Manage Your Fields"),
                          const SizedBox(height: 16),
                          _buildAllCards(),
                          const SizedBox(height: 32),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AnimatedBuilder(
            animation: _shimmerCtrl,
            builder: (_, __) {
              return ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  final shimmerX =
                      _shimmerCtrl.value * (bounds.width + 120) - 60;
                  return LinearGradient(
                    colors: const [
                      Color(0xFF1B4332),
                      Color(0xFF40916C),
                      Color(0xFFB7E4C7),
                      Color(0xFF40916C),
                      Color(0xFF1B4332),
                    ],
                    stops: const [0.0, 0.35, 0.50, 0.65, 1.0],
                    begin: Alignment(
                        (shimmerX / bounds.width) * 2 - 1, 0),
                    end: Alignment(
                        (shimmerX / bounds.width) * 2 + 1, 0),
                  ).createShader(bounds);
                },
                child: Text(
                  "Greenexis",
                  style: TextStyle(
                    fontSize: 64.sp, // ✅ INCREASED from 56 to 64
                    fontWeight: FontWeight.w900,
                    color: _G.green900,
                    letterSpacing: -1.0,
                    height: 1.0,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Row(children: [
            Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(
                  color: _G.green600, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text("Smart Farming Assistant",
                style: TextStyle(
                  fontSize: 22.sp,
                  color: _G.green700,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                )),
          ]),
        ]),

        // ✅ ATTRACTIVE MENU BUTTON
        Builder(
          builder: (context) => _PremiumTapCard(
            onTap: () => Scaffold.of(context).openDrawer(),
            accentColor: _G.green700,
            child: Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.55),
                border: Border.all(
                  color: _G.green200.withOpacity(0.8),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _G.green400.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.menu_rounded,
                color: _G.green800,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Row(children: [
      Container(
        width: 4, height: 22,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [_G.green700, _G.green400],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 10),
      Text(text,
          style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _G.green900,
              letterSpacing: 0.1)),
    ]);
  }

  Widget _buildWeatherCard() {
    return _PremiumTapCard(
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
      accentColor: _G.green700,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: _G.green700.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          image: const DecorationImage(
            image: AssetImage('assets/home_screen/weather.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.28),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          temperature.isEmpty
                              ? "Loading..."
                              : "$temperature°C",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          cityName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description.isEmpty ? "" : description,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _WeatherStatus(
                          title: "Humidity",
                          value: humidity.isEmpty ? "--" : "$humidity%",
                        ),
                        const _WeatherStatus(
                            title: "Soil Moisture", value: "Good"),
                        const _WeatherStatus(
                            title: "Precipitation", value: "Low"),
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

  Widget _weatherPill(IconData icon, String label, String value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.white.withOpacity(0.30), width: 1),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: Colors.white, size: 13),
            const SizedBox(width: 5),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }

  Widget _buildAllCards() {
    final items = [
      _CardItem(
        title: "Plant Guide",
        subtitle: "Diagnose plants",
        imagePath: "assets/home_screen/plant_guide.png",
        gradientColors: _cardGradients[0],
        accentColor: _cardAccents[0],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PlantGuide())),
      ),
      _CardItem(
        title: "Crops",
        subtitle: "Browse varieties",
        imagePath: "assets/home_screen/crops.png",
        gradientColors: _cardGradients[1],
        accentColor: _cardAccents[1],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => Crops(userLocation: cityName))),
      ),
      _CardItem(
        title: "Agri ChatBot",
        subtitle: "Ask anything",
        imagePath: "assets/home_screen/agrichatbot.png",
        gradientColors: _cardGradients[2],
        accentColor: _cardAccents[2],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AgriChatBot())),
      ),
      _CardItem(
        title: "7/12 Record",
        subtitle: "Land documents",
        imagePath: "assets/home_screen/info712.png",
        gradientColors: _cardGradients[3],
        accentColor: _cardAccents[3],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const LandMap())),
      ),
      _CardItem(
        title: "Agri Calculator",
        subtitle: "Costs & yield",
        imagePath: "assets/home_screen/calculator.png",
        gradientColors: _cardGradients[4],
        accentColor: _cardAccents[4],
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const Calculator())),
      ),
      // ✅ FIXED: Card 6 now uses index [5] not [4] — so color is different!
      _CardItem(
        title: "Agri Calculator",
        subtitle: "Costs & yield",
        imagePath: "assets/home_screen/calculator.png",
        gradientColors: _cardGradients[5], // ✅ was [4], now [5]
        accentColor: _cardAccents[5],      // ✅ was [4], now [5]
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const Calculator())),
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.05,
      children: List.generate(items.length, (i) {
        return SlideTransition(
          position: _cardSlide[i],
          child: FadeTransition(
            opacity: _cardFade[i],
            child: AnimatedBuilder(
              animation: _floatAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(0,
                    i.isEven
                        ? -_floatAnim.value * 0.4
                        : _floatAnim.value * 0.4),
                child: child,
              ),
              child: _PremiumTapCard(
                onTap: items[i].onTap,
                accentColor: items[i].accentColor,
                child: _buildCardShell(items[i]),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCardShell(_CardItem item) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: item.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: item.accentColor.withOpacity(0.20),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 7),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.80),
            blurRadius: 0,
            spreadRadius: 0,
            offset: const Offset(0, -1),
          ),
        ],
        border: Border.all(
            color: Colors.white.withOpacity(0.75), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Positioned(
              top: -28, right: -28,
              child: Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.22),
                ),
              ),
            ),
            Positioned(
              top: -10, right: -10,
              child: Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.18),
                ),
              ),
            ),
            _cardContentVertical(item),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(_CardItem item, {bool fullWidth = false}) {
    return _PremiumTapCard(
      onTap: item.onTap,
      accentColor: item.accentColor,
      child: _buildCardShell(item),
    );
  }

  Widget _cardContentVertical(_CardItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _floatAnim,
              builder: (_, child) => Transform.translate(
                offset: Offset(0, -_floatAnim.value * 0.6),
                child: child,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: item.accentColor.withOpacity(0.10),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        item.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 11),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              color: item.accentColor,
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: item.accentColor.withOpacity(0.60),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardContentHorizontal(_CardItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                height: 66, width: 66,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: item.accentColor.withOpacity(0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(item.imagePath, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.title,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: item.accentColor,
                      letterSpacing: 0.1)),
              const SizedBox(height: 3),
              Text(item.subtitle,
                  style: TextStyle(
                      fontSize: 11.5,
                      color: item.accentColor.withOpacity(0.60),
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const Spacer(),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: item.accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_forward_ios_rounded,
                color: item.accentColor, size: 13),
          ),
        ],
      ),
    );
  }

  Widget _glassCircle({required Widget child, double size = 44}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.55),
            border: Border.all(
                color: _G.green200.withOpacity(0.8), width: 1.2),
            boxShadow: [
              BoxShadow(
                  color: _G.green400.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}


class _PremiumTapCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color accentColor;

  const _PremiumTapCard({
    required this.child,
    required this.onTap,
    required this.accentColor,
  });

  @override
  State<_PremiumTapCard> createState() => _PremiumTapCardState();
}

class _PremiumTapCardState extends State<_PremiumTapCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _shadowBlur;
  late Animation<double> _shadowOffset;
  late Animation<double> _brightness;
  late Animation<double> _glowOpacity;

  bool _isPressed = false;
  bool _animating = false;
  Offset _tapPosition = Offset.zero;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 320),
    );

    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeIn,
        reverseCurve: _SpringOutCurve(),
      ),
    );

    _shadowBlur = Tween<double>(begin: 18, end: 4).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );

    _shadowOffset = Tween<double>(begin: 7, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );

    _brightness = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
    );

    _glowOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.35), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.35, end: 0.0), weight: 75),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _animating = false;
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails d) {
    if (_isPressed || _animating) return;
    _tapPosition = d.localPosition;
    _isPressed = true;
    _animating = true;
    _ctrl.forward(from: 0);
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    if (!_isPressed) return;
    _isPressed = false;
    widget.onTap();
    _ctrl.reverse();
  }

  void _onTapCancel() {
    if (!_isPressed) return;
    _isPressed = false;
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) {
          return Transform.scale(
            scale: _scale.value,
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(
                  _brightnessMatrix(_brightness.value)),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: widget.accentColor.withOpacity(0.22),
                          blurRadius: _shadowBlur.value,
                          spreadRadius: 0,
                          offset: Offset(0, _shadowOffset.value),
                        ),
                        BoxShadow(
                          color: Colors.white.withOpacity(0.80),
                          blurRadius: 0,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: child,
                  ),

                  if (_glowOpacity.value > 0.001)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: CustomPaint(
                          painter: _GlowPainter(
                            center: _tapPosition,
                            opacity: _glowOpacity.value,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  if (_ctrl.value > 0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _ctrl,
                          builder: (_, __) => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(26),
                              border: Border.all(
                                color: Colors.white.withOpacity(
                                    (_ctrl.value * 0.6).clamp(0.0, 0.6)),
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }

  List<double> _brightnessMatrix(double b) => [
    b, 0, 0, 0, 0,
    0, b, 0, 0, 0,
    0, 0, b, 0, 0,
    0, 0, 0, 1, 0,
  ];
}

class _SpringOutCurve extends Curve {
  @override
  double transformInternal(double t) {
    return 1.0 - math.exp(-6.5 * t) * math.cos(12.0 * t);
  }
}

class _GlowPainter extends CustomPainter {
  final Offset center;
  final double opacity;
  final Color color;

  const _GlowPainter({
    required this.center,
    required this.opacity,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxRadius = math.max(size.width, size.height) * 0.70;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(opacity),
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));
    canvas.drawCircle(center, maxRadius, paint);
  }

  @override
  bool shouldRepaint(_GlowPainter old) =>
      old.opacity != opacity || old.center != center;
}

class _CardItem {
  final String title;
  final String subtitle;
  final String imagePath;
  final List<Color> gradientColors;
  final Color accentColor;
  final VoidCallback onTap;
  const _CardItem({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.gradientColors,
    required this.accentColor,
    required this.onTap,
  });
}

class _BgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _blob(canvas, Offset(size.width * 0.88, size.height * 0.06),
        size.width * 0.58, const Color(0xFFB7E4C7).withOpacity(0.38));
    _blob(canvas, Offset(size.width * 0.08, size.height * 0.25),
        size.width * 0.46, const Color(0xFFD8F3DC).withOpacity(0.30));
    _blob(canvas, Offset(size.width * 0.72, size.height * 0.58),
        size.width * 0.42, const Color(0xFFC5E8D5).withOpacity(0.28));
    _blob(canvas, Offset(size.width * 0.18, size.height * 0.80),
        size.width * 0.40, const Color(0xFFB7E4C7).withOpacity(0.20));
  }

  void _blob(Canvas canvas, Offset center, double radius, Color color) {
    canvas.drawCircle(center, radius,
        Paint()
          ..color = color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 65));
  }

  @override
  bool shouldRepaint(_) => false;
}

class _WeatherStatus extends StatelessWidget {
  final String title;
  final String value;
  const _WeatherStatus({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(title, style: const TextStyle(fontSize: 12, color: Colors.black)),
      const SizedBox(height: 4),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 12)),
      ),
    ]);
  }
}