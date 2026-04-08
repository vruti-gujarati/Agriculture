import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../l10n/app_localizations.dart';
import 'intro_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final bool isFromHomeScreen;
  const LanguageSelectionScreen({super.key, required this.isFromHomeScreen});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with TickerProviderStateMixin {

  // ── Animation Controllers ─────────────────────────────────────────────────
  late AnimationController _bgCtrl, _entryCtrl, _leafCtrl, _glowCtrl,
      _shimmerCtrl, _selectCtrl;
  late Animation<double> _bgFloat, _logoFade, _titleFade, _cardsFade,
      _btnFade, _glowPulse, _selectScale;
  late Animation<Offset> _logoSlide, _titleSlide, _cardsSlide, _btnSlide;

  // ── State ─────────────────────────────────────────────────────────────────
  String? _selectedLang='English';
  String? _selectedLanguage='English';
  bool _loading = false;
  bool? isFirstLaunch;


  Future<void> _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String savedLang = prefs.getString('selectedLanguage') ?? 'English';

    setState(() {
      _selectedLanguage = savedLang;
      _selectedLang = savedLang;
    });

    print("Loaded Language: $savedLang");
  }


  final Map<String, String> _languageCodes = {
    'English': 'en',
    'Hindi': 'hi',
    'Gujarati': 'gu'
  };


  static const _languages = [
    {'code': 'en', 'name': 'English',  'native': 'English',  'flag': '🇬🇧', 'hint': ''},
    {'code': 'hi', 'name': 'Hindi',    'native': 'हिन्दी',    'flag': '🇮🇳', 'hint': ''},
    {'code': 'gu', 'name': 'Gujarati', 'native': 'ગુજરાતી', 'flag': '🇮🇳', 'hint': ''},
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _initAnimations();
    _checkFirstLaunch(); // Initialize the isFirstLaunch variable
    _loadSelectedLanguage();
    _initializeLanguageSettings();
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    print("language page isFirstLaunch $isFirstLaunch");

    setState(() {
      isFirstLaunch = firstLaunch;
      if (!firstLaunch && widget.isFromHomeScreen) {
        _selectedLanguage = prefs.getString('selectedLanguage');
      }
    });
  }

  Future<void> _initializeLanguageSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    print("language page $isFirstLaunch");

    setState(() {
      isFirstLaunch = firstLaunch;
      if (!firstLaunch || widget.isFromHomeScreen) {
        _selectedLanguage = prefs.getString('selectedLanguage');
        print("this is load _selectedlanguage $_selectedLanguage");
      }
    });
  }



  void _changeLanguage(String languageCode) async {
    final locale = Locale(languageCode);

    MyApp.setLocale(context, locale);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('selectedLanguage', _selectedLanguage!);

    _navigate();
  }

  void _initAnimations() {
    // Background float
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat(reverse: true);
    _bgFloat = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut));

    // Entry sequence
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.0, 0.35, curve: Curves.easeOut)));
    _logoSlide = Tween<Offset>(begin: const Offset(0, -0.06), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.0, 0.40, curve: Curves.easeOutCubic)));

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.20, 0.55, curve: Curves.easeOut)));
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.20, 0.55, curve: Curves.easeOutCubic)));

    _cardsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.40, 0.80, curve: Curves.easeOut)));
    _cardsSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.40, 0.80, curve: Curves.easeOutCubic)));

    _btnFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.65, 1.0, curve: Curves.easeOut)));
    _btnSlide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.65, 1.0, curve: Curves.easeOutCubic)));

    // Leaf float
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

    // Select scale bounce
    _selectCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _selectScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.04), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.04, end: 0.97), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.97, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _selectCtrl, curve: Curves.easeInOut));

    _entryCtrl.forward();
  }

  // Future<void> _loadSavedLanguage() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final saved = prefs.getString('selected_language');
  //   if (mounted) {
  //     setState(() => _selectedLang = saved ?? 'en');
  //   }
  // }

  Future<void> _selectLanguage(String code) async {
    setState(() {
      _selectedLanguage = code;
      _selectedLang = code;
    });

    HapticFeedback.selectionClick();
    _selectCtrl.forward(from: 0);

    print("Selected language: $_selectedLanguage");
  }

  Future<void> _navigate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => IntroScreen()),
      );
    } else {
      if (widget.isFromHomeScreen) {
        Navigator.pop(context);
      }
    }
  }


  @override
  void dispose() {
    _bgCtrl.dispose(); _entryCtrl.dispose(); _leafCtrl.dispose();
    _glowCtrl.dispose(); _shimmerCtrl.dispose(); _selectCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.height < 680;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2FAF4),
        resizeToAvoidBottomInset: true,
        body: Stack(children: [
          // Animated background blobs
          AnimatedBuilder(
            animation: _bgFloat,
            builder: (_, __) => CustomPaint(size: size, painter: _LsBgPainter(_bgFloat.value)),
          ),
          // Floating leaves
          AnimatedBuilder(
            animation: _leafCtrl,
            builder: (_, __) => CustomPaint(size: size, painter: _LsLeafPainter(_leafCtrl.value)),
          ),
          // Main content
          SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(height: isSmall ? 18 : 32),
                        _buildBrand(size),
                        SizedBox(height: isSmall ? 10 : 18),
                        _buildTitleSection(size),
                        SizedBox(height: isSmall ? 16 : 28),
                        _buildLanguageCards(size),
                        SizedBox(height: isSmall ? 20 : 32),
                        _buildContinueBtn(size),
                        SizedBox(height: isSmall ? 14 : 22),
                        _buildBadge(),
                        SizedBox(height: isSmall ? 12 : 20),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ]),
      ),
    );
  }

  // ── Brand / Logo ──────────────────────────────────────────────────────────
  Widget _buildBrand(Size size) {
    final lw = size.width * 0.20;
    return FadeTransition(
      opacity: _logoFade,
      child: SlideTransition(
        position: _logoSlide,
        child: Column(children: [
          AnimatedBuilder(
            animation: _glowPulse,
            builder: (_, __) => Container(
              width: lw, height: lw,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.55),
                border: Border.all(color: Colors.white.withOpacity(0.85), width: 2),
                boxShadow: [BoxShadow(
                  color: const Color(0xFF52B788).withOpacity(0.20 + 0.12 * _glowPulse.value),
                  blurRadius: 20 + 12 * _glowPulse.value, spreadRadius: 2,
                )],
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Center(
                    child: Transform.scale(
                      scale: 0.92 + 0.08 * _glowPulse.value,
                      child: Icon(Icons.eco_rounded,
                          color: const Color(0xFF2D6A4F), size: lw * 0.54),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.012),
          AnimatedBuilder(
            animation: _shimmerCtrl,
            builder: (_, __) => ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) {
                final x = _shimmerCtrl.value * (bounds.width + 160) - 80;
                return LinearGradient(
                  colors: const [
                    Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF52B788),
                    Color(0xFFB7E4C7), Color(0xFF52B788), Color(0xFF2D6A4F), Color(0xFF1B4332),
                  ],
                  stops: const [0.0, 0.20, 0.38, 0.50, 0.62, 0.80, 1.0],
                  begin: Alignment((x / bounds.width) * 2 - 1, 0),
                  end:   Alignment((x / bounds.width) * 2 + 1, 0),
                ).createShader(bounds);
              },
              child: Text(
                  AppLocalizations.of(context)?.appname ??"Greenexis",
                  style: TextStyle(
                    fontSize: size.width * 0.093,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1B4332),
                    letterSpacing: -1.2, height: 1.0,
                  )),
            ),
          ),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _dLine(reverse: true), const SizedBox(width: 10),
            Container(width: 6, height: 6,
                decoration: const BoxDecoration(color: Color(0xFF52B788), shape: BoxShape.circle)),
            const SizedBox(width: 10), _dLine(),
          ]),
          const SizedBox(height: 6),
          Text(
              AppLocalizations.of(context)?.tagline ?? "Smart Farming Assistant",
              style: TextStyle(
                fontSize: size.width * 0.033,
                color: const Color(0xFF40916C),
                fontWeight: FontWeight.w600, letterSpacing: 0.5,
              )),
        ]),
      ),
    );
  }

  Widget _dLine({bool reverse = false}) => Container(
    width: 28, height: 1.5,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: reverse
          ? [Colors.transparent, const Color(0xFF74C69D)]
          : [const Color(0xFF74C69D), Colors.transparent]),
      borderRadius: BorderRadius.circular(1),
    ),
  );

  // ── Title Section ─────────────────────────────────────────────────────────
  Widget _buildTitleSection(Size size) {
    return FadeTransition(
      opacity: _titleFade,
      child: SlideTransition(
        position: _titleSlide,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.06, vertical: size.height * 0.022),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.60),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.80), width: 1.2),
                boxShadow: [BoxShadow(
                  color: const Color(0xFF52B788).withOpacity(0.10),
                  blurRadius: 20, offset: const Offset(0, 6),
                )],
              ),
              child: Column(children: [
                // Icon pill

                const SizedBox(height: 10),
                Text(
                    AppLocalizations.of(context)?.selectlanguage ??"Select Your Language",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size.width * 0.060,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1B4332),
                      letterSpacing: -0.5, height: 1.15,
                    )),
                const SizedBox(height: 6),
                Text(
                    AppLocalizations.of(context)?.chooselanguage ??"Choose your preferred language\nto continue",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size.width * 0.035,
                      color: const Color(0xFF74C69D),
                      height: 1.5,
                    )),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  // ── Language Cards ────────────────────────────────────────────────────────
  Widget _buildLanguageCards(Size size) {
    return FadeTransition(
      opacity: _cardsFade,
      child: SlideTransition(
        position: _cardsSlide,
        child: Column(
          children: _languages.asMap().entries.map((entry) {
            final i    = entry.key;
            final lang = entry.value;
            final code = lang['name']!;
            final isSelected = _selectedLang == code;

            return AnimatedBuilder(
              animation: _selectScale,
              builder: (_, __) {
                return Transform.scale(
                  scale: isSelected ? _selectScale.value : 1.0,
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: i < _languages.length - 1 ? size.height * 0.014 : 0),
                    child: _LanguageCard(
                      flag:       lang['flag']!,
                      name:       lang['name']!,
                      native:     lang['native']!,
                      hint:       lang['hint']!,
                      isSelected: isSelected,
                      index:      i,
                      size:       size,
                      onTap:      () => _selectLanguage(code),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Continue Button ───────────────────────────────────────────────────────
  Widget _buildContinueBtn(Size size) {
    return FadeTransition(
      opacity: _btnFade,
      child: SlideTransition(
        position: _btnSlide,
        child: AnimatedBuilder(
          animation: _glowPulse,
          builder: (_, __) => GestureDetector(
            onTap:() {
              if (_selectedLanguage != null && _selectedLanguage!.isNotEmpty){
                print("this is code $_selectedLanguage ");
                final localeCode = _languageCodes[_selectedLanguage!];
                print("this is code $localeCode ");
                _changeLanguage(localeCode!);
                print(
                    'Selected Language Codes: $localeCode');
              } else {
                print('No language selected');
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: size.height * 0.068,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(38),
                gradient: LinearGradient(
                  colors: _selectedLang != null
                      ? const [Color(0xFF2D6A4F), Color(0xFF1B4332)]
                      : [const Color(0xFF95D5B2), const Color(0xFF74C69D)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                boxShadow: [BoxShadow(
                  color: const Color(0xFF1B4332).withOpacity(
                      _selectedLang != null ? 0.25 + 0.10 * _glowPulse.value : 0.10),
                  blurRadius: 16 + 8 * _glowPulse.value,
                  offset: const Offset(0, 6),
                )],
              ),
              child: Stack(children: [
                Positioned.fill(child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(decoration: BoxDecoration(gradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0.12), Colors.transparent],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ))),
                )),
                Center(
                  child: _loading
                      ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(Colors.white)))
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _selectedLang != null
                            ? (AppLocalizations.of(context)?.continuee ?? "Continue")
                            : (AppLocalizations.of(context)?.selectalanguage ?? "Select a Language"),
                        style: TextStyle(
                          fontSize: size.width * 0.043,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 19),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  // ── Badge ─────────────────────────────────────────────────────────────────
  Widget _buildBadge() => FadeTransition(
    opacity: _btnFade,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),

      ),
    ),
  );
}

// ── Language Card Widget ──────────────────────────────────────────────────────
class _LanguageCard extends StatefulWidget {
  final String flag, name, native, hint;
  final bool isSelected;
  final int index;
  final Size size;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.flag, required this.name, required this.native,
    required this.hint, required this.isSelected, required this.index,
    required this.size, required this.onTap,
  });

  @override
  State<_LanguageCard> createState() => _LanguageCardState();
}

class _LanguageCardState extends State<_LanguageCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp:   (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                  horizontal: widget.size.width * 0.05,
                  vertical: widget.size.height * 0.018),
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? const Color(0xFF2D6A4F).withOpacity(0.10)
                    : Colors.white.withOpacity(0.68),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected
                      ? const Color(0xFF2D6A4F)
                      : Colors.white.withOpacity(0.80),
                  width: widget.isSelected ? 2.0 : 1.2,
                ),
                boxShadow: [BoxShadow(
                  color: widget.isSelected
                      ? const Color(0xFF2D6A4F).withOpacity(0.18)
                      : const Color(0xFF52B788).withOpacity(0.08),
                  blurRadius: widget.isSelected ? 20 : 10,
                  offset: const Offset(0, 4),
                )],
              ),
              child: Row(children: [
                // Flag in a frosted circle
                ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isSelected
                            ? const Color(0xFF2D6A4F).withOpacity(0.12)
                            : const Color(0xFFE8F5E9).withOpacity(0.80),
                        border: Border.all(
                          color: widget.isSelected
                              ? const Color(0xFF52B788)
                              : const Color(0xFFB7E4C7),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(widget.flag, style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Text content
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: TextStyle(
                        fontSize: widget.size.width * 0.047,
                        fontWeight: FontWeight.w800,
                        color: widget.isSelected
                            ? const Color(0xFF1B4332)
                            : const Color(0xFF2D6A4F),
                        letterSpacing: -0.3,
                      ),
                      child: Text(widget.name),
                    ),
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: TextStyle(
                        fontSize: widget.size.width * 0.036,
                        fontWeight: FontWeight.w500,
                        color: widget.isSelected
                            ? const Color(0xFF40916C)
                            : const Color(0xFF74C69D),
                      ),
                      child: Text(widget.native),
                    ),
                    const SizedBox(height: 3),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 220),
                      style: TextStyle(
                        fontSize: widget.size.width * 0.026,
                        color: widget.isSelected
                            ? const Color(0xFF52B788)
                            : const Color(0xFF95D5B2),
                        fontStyle: FontStyle.italic,
                      ),
                      child: Text(widget.hint),
                    ),
                  ]),
                ),
                // Selection indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  width: 26, height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isSelected
                        ? const Color(0xFF2D6A4F)
                        : Colors.transparent,
                    border: Border.all(
                      color: widget.isSelected
                          ? const Color(0xFF2D6A4F)
                          : const Color(0xFFB7E4C7),
                      width: 1.8,
                    ),
                  ),
                  child: widget.isSelected
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
                      : null,
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Background Painter ────────────────────────────────────────────────────────
class _LsBgPainter extends CustomPainter {
  final double t; _LsBgPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFF2FAF4));
    final blobs = [
      [0.78 + 0.04*math.sin(t*math.pi),       0.08 + 0.03*math.cos(t*math.pi*1.3), 0.55, 0xFFB7E4C7, 0.32, 80.0],
      [0.10 + 0.03*math.cos(t*math.pi*0.9),   0.20 + 0.04*math.sin(t*math.pi*1.1), 0.48, 0xFF95D5B2, 0.22, 70.0],
      [0.72 + 0.05*math.sin(t*math.pi*1.2),   0.62 + 0.04*math.cos(t*math.pi*0.8), 0.42, 0xFF74C69D, 0.18, 65.0],
      [0.14 + 0.03*math.sin(t*math.pi*1.4),   0.76 + 0.03*math.cos(t*math.pi),     0.40, 0xFFD8F3DC, 0.40, 60.0],
      [0.50 + 0.02*math.cos(t*math.pi*1.6),   0.42 + 0.02*math.sin(t*math.pi),     0.32, 0xFF52B788, 0.10, 55.0],
    ];
    for (final b in blobs) {
      canvas.drawCircle(
        Offset(size.width*(b[0] as double), size.height*(b[1] as double)),
        size.width*(b[2] as double),
        Paint()
          ..color = Color(b[3] as int).withOpacity(b[4] as double)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, b[5] as double),
      );
    }
  }
  @override bool shouldRepaint(_LsBgPainter o) => o.t != t;
}

// ── Leaf Painter ──────────────────────────────────────────────────────────────
class _LsLeafPainter extends CustomPainter {
  final double t; _LsLeafPainter(this.t);
  static const _s = [
    [0.06,0.10,0.7,0.00],[0.91,0.07,1.1,0.30],[0.11,0.82,0.9,0.60],[0.87,0.71,0.6,0.90],
    [0.49,0.03,1.3,0.15],[0.63,0.91,0.8,0.45],[0.03,0.53,1.0,0.75],[0.94,0.49,0.7,0.55],
  ];
  static const _cols = [0xFF52B788, 0xFF74C69D, 0xFF40916C, 0xFFB7E4C7];
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _s.length; i++) {
      final ph = (t + _s[i][3]) % 1.0;
      final x  = _s[i][0]*size.width  + 14*math.sin(ph*math.pi*2*_s[i][2]);
      final y  = _s[i][1]*size.height + 10*math.cos(ph*math.pi*2*_s[i][2]*0.8);
      final r  = 5.0 + 3*math.sin(ph*math.pi);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(ph*math.pi*2*(i.isEven ? 1 : -1));
      canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..cubicTo(-r*0.6,-r*0.9,-r*0.4,-r*1.8,0,-r*2.2)
          ..cubicTo(r*0.4,-r*1.8,r*0.6,-r*0.9,0,0),
        Paint()..color = Color(_cols[i%4]).withOpacity(0.15+0.12*math.sin(ph*math.pi*2)),
      );
      canvas.restore();
    }
  }
  @override bool shouldRepaint(_LsLeafPainter o) => o.t != t;
}
