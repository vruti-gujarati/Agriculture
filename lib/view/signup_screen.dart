import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_screen.dart';
import 'login_screen.dart';
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {

  late AnimationController _bgCtrl, _entryCtrl, _leafCtrl, _glowCtrl, _shimmerCtrl;
  late Animation<double> _bgFloat, _logoFade, _cardFade, _glowPulse;
  late Animation<Offset> _logoSlide, _cardSlide;

  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _cpassCtrl  = TextEditingController();

  bool _obscurePass  = true;
  bool _obscureCPass = true;
  bool _loading      = false;
  bool _agreeTerms   = false;

  final _nameFocus  = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passFocus  = FocusNode();
  final _cpassFocus = FocusNode();

  // Farm type selection
  String _selectedFarm = "Crop Farming";
  final _farmTypes = [
    "Crop Farming", "Dairy Farming", "Poultry", "Horticulture", "Mixed Farming"
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    _bgCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat(reverse: true);
    _bgFloat = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut));

    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.0, 0.45, curve: Curves.easeOut)));
    _logoSlide = Tween<Offset>(begin: const Offset(0, -0.05), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.0, 0.50, curve: Curves.easeOutCubic)));
    _cardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.25, 0.80, curve: Curves.easeOut)));
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.25, 0.80, curve: Curves.easeOutCubic)));

    _leafCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat(reverse: true);

    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.6, end: 1.0)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat();

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _bgCtrl.dispose(); _entryCtrl.dispose(); _leafCtrl.dispose();
    _glowCtrl.dispose(); _shimmerCtrl.dispose();
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _cpassCtrl.dispose();
    _nameFocus.dispose(); _phoneFocus.dispose(); _emailFocus.dispose();
    _passFocus.dispose(); _cpassFocus.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please agree to the Terms & Conditions"),
          backgroundColor: const Color(0xFF2D6A4F),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MyHomePage(title: "Home"),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2FAF4),
        resizeToAvoidBottomInset: true,
        body: Stack(children: [
          AnimatedBuilder(
            animation: _bgFloat,
            builder: (_, __) =>
                CustomPaint(size: size, painter: _SuBgPainter(_bgFloat.value)),
          ),
          AnimatedBuilder(
            animation: _leafCtrl,
            builder: (_, __) =>
                CustomPaint(size: size, painter: _SuLeafPainter(_leafCtrl.value)),
          ),
// ── Back Button (matching UI) ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFB7E4C7).withOpacity(0.9),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF52B788).withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF2D6A4F),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),          SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: Column(children: [
                    SizedBox(height: size.height * 0.022),
                    _buildHeader(size),
                    SizedBox(height: size.height * 0.020),
                    _buildCard(size),
                    SizedBox(height: size.height * 0.018),
                    _buildBadge(),
                    SizedBox(height: size.height * 0.022),
                  ]),
                ),
              );
            }),
          ),
        ]),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(Size size){
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
          SizedBox(height: size.height * 0.015),
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
              child: Text("Greenexis",
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
          const SizedBox(height: 7),
          Text("Smart Farming Assistant",
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
    width: 24, height: 1.5,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: reverse
          ? [Colors.transparent, const Color(0xFF74C69D)]
          : [const Color(0xFF74C69D), Colors.transparent]),
      borderRadius: BorderRadius.circular(1),
    ),
  );

  // ── Form card ─────────────────────────────────────────────────────────────
  Widget _buildCard(Size size) {
    return FadeTransition(
      opacity: _cardFade,
      child: SlideTransition(
        position: _cardSlide,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.72),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.82), width: 1.2),
                boxShadow: [BoxShadow(
                    color: const Color(0xFF52B788).withOpacity(0.12),
                    blurRadius: 32, offset: const Offset(0, 8))],
              ),
              padding: EdgeInsets.fromLTRB(
                size.width * 0.06, size.height * 0.026,
                size.width * 0.06, size.height * 0.026,
              ),
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // Card heading
                  Row(children: [
                    Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFE8F5E9),
                        border: Border.all(color: const Color(0xFFB7E4C7), width: 1),
                      ),
                      child: const Icon(Icons.person_add_rounded,
                          color: Color(0xFF2D6A4F), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Join Greenexis",
                          style: TextStyle(
                            fontSize: size.width * 0.055, fontWeight: FontWeight.w800,
                            color: const Color(0xFF1B4332), letterSpacing: -0.4, height: 1.1,
                          )),
                      Text("Register your farm today",
                          style: TextStyle(
                              fontSize: size.width * 0.030,
                              color: const Color(0xFF74C69D))),
                    ]),
                  ]),

                  SizedBox(height: size.height * 0.022),
                  _sectionDivider("Personal Details"),
                  SizedBox(height: size.height * 0.014),

                  // Full name
                  _lbl("Full Name"),
                  const SizedBox(height: 7),
                  _field(controller: _nameCtrl, focusNode: _nameFocus,
                    hint: "Enter your full name", icon: Icons.person_outline_rounded,
                    action: TextInputAction.next,
                    onSubmit: (_) => FocusScope.of(context).requestFocus(_phoneFocus),
                    validate: (v) => (v == null || v.trim().isEmpty) ? "Name is required" : null,
                  ),

                  SizedBox(height: size.height * 0.015),

                  // Phone
                  _lbl("Phone Number"),
                  const SizedBox(height: 7),
                  _field(controller: _phoneCtrl, focusNode: _phoneFocus,
                    hint: "Enter mobile number", icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    action: TextInputAction.next,
                    onSubmit: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                    validate: (v) {
                      if (v == null || v.trim().isEmpty) return "Phone is required";
                      if (v.trim().length < 10) return "Enter valid phone number";
                      return null;
                    },
                  ),

                  SizedBox(height: size.height * 0.015),

                  // Email
                  _lbl("Email Address"),
                  const SizedBox(height: 7),
                  _field(controller: _emailCtrl, focusNode: _emailFocus,
                    hint: "Enter email (optional)", icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    action: TextInputAction.next,
                    onSubmit: (_) => FocusScope.of(context).requestFocus(_passFocus),
                    validate: (v) {
                      if (v != null && v.isNotEmpty) {
                        if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(v)) {
                          return "Enter valid email";
                        }
                      }
                      return null;
                    },
                  ),


                  SizedBox(height: size.height * 0.014),



                  // Password
                  _lbl("Password"),
                  const SizedBox(height: 7),
                  _field(controller: _passCtrl, focusNode: _passFocus,
                    hint: "Create password", icon: Icons.lock_outline_rounded,
                    obscure: _obscurePass,
                    action: TextInputAction.next,
                    onSubmit: (_) => FocusScope.of(context).requestFocus(_cpassFocus),
                    suffix: IconButton(
                      icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20, color: const Color(0xFF95D5B2)),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                    validate: (v) {
                      if (v == null || v.isEmpty) return "Password is required";
                      if (v.length < 6) return "Minimum 6 characters";
                      return null;
                    },
                  ),

                  SizedBox(height: size.height * 0.015),

                  // Confirm password
                  _lbl("Confirm Password"),
                  const SizedBox(height: 7),
                  _field(controller: _cpassCtrl, focusNode: _cpassFocus,
                    hint: "Re-enter password", icon: Icons.lock_outline_rounded,
                    obscure: _obscureCPass,
                    action: TextInputAction.done,
                    onSubmit: (_) => _handleSignup(),
                    suffix: IconButton(
                      icon: Icon(_obscureCPass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 20, color: const Color(0xFF95D5B2)),
                      onPressed: () => setState(() => _obscureCPass = !_obscureCPass),
                    ),
                    validate: (v) {
                      if (v == null || v.isEmpty) return "Please confirm password";
                      if (v != _passCtrl.text) return "Passwords do not match";
                      return null;
                    },
                  ),

                  SizedBox(height: size.height * 0.018),

                  // Password strength indicator
                  _buildPasswordStrength(size),

                  SizedBox(height: size.height * 0.018),

                  // Terms checkbox
                  GestureDetector(
                    onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20, height: 20, margin: const EdgeInsets.only(top: 1),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: _agreeTerms ? const Color(0xFF52B788) : Colors.transparent,
                          border: Border.all(
                            color: _agreeTerms ? const Color(0xFF52B788) : const Color(0xFF95D5B2),
                            width: 1.5,
                          ),
                        ),
                        child: _agreeTerms
                            ? const Icon(Icons.check, size: 13, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                                fontSize: size.width * 0.030, color: const Color(0xFF5A8A6A)),
                            children: const [
                              TextSpan(text: "I agree to the "),
                              TextSpan(text: "Terms & Conditions",
                                  style: TextStyle(
                                      color: Color(0xFF2D6A4F),
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline)),
                              TextSpan(text: " and "),
                              TextSpan(text: "Privacy Policy",
                                  style: TextStyle(
                                      color: Color(0xFF2D6A4F),
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline)),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),

                  SizedBox(height: size.height * 0.024),

                  // Create account button
                  _signupBtn(size),

                  SizedBox(height: size.height * 0.018),

                  // Already have account
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                              fontSize: size.width * 0.033, color: const Color(0xFF74C69D)),
                          children: const [
                            TextSpan(text: "Already a farmer?  "),
                            TextSpan(text: "Sign In →",
                                style: TextStyle(
                                    color: Color(0xFF2D6A4F), fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Section divider ────────────────────────────────────────────────────────
  Widget _sectionDivider(String label) => Row(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB7E4C7), width: 1),
      ),
      child: Row(children: [
        Container(width: 5, height: 5,
            decoration: const BoxDecoration(color: Color(0xFF52B788), shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: Color(0xFF2D6A4F), letterSpacing: 0.5)),
      ]),
    ),
    const SizedBox(width: 10),
    Expanded(child: Container(height: 1,
        color: const Color(0xFFB7E4C7).withOpacity(0.5))),
  ]);

  // ── Farm type dropdown ─────────────────────────────────────────────────────
  Widget _farmDropdown(Size size) => Container(
    height: 52,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.75),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFB7E4C7).withOpacity(0.6), width: 1.5),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedFarm,
        isExpanded: true,
        icon: const Padding(
          padding: EdgeInsets.only(right: 14),
          child: Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF52B788), size: 22),
        ),
        style: const TextStyle(
            fontSize: 15, color: Color(0xFF1B4332), fontWeight: FontWeight.w500),
        dropdownColor: const Color(0xFFF0FAF4),
        borderRadius: BorderRadius.circular(14),
        items: _farmTypes.map((t) => DropdownMenuItem(
          value: t,
          child: Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Row(children: [
              const Icon(Icons.agriculture_rounded, color: Color(0xFF52B788), size: 18),
              const SizedBox(width: 10),
              Text(t),
            ]),
          ),
        )).toList(),
        onChanged: (v) => setState(() => _selectedFarm = v!),
      ),
    ),
  );

  // ── Password strength ──────────────────────────────────────────────────────
  Widget _buildPasswordStrength(Size size) {
    final pass = _passCtrl.text;
    int strength = 0;
    if (pass.length >= 6) strength++;
    if (pass.contains(RegExp(r'[A-Z]'))) strength++;
    if (pass.contains(RegExp(r'[0-9]'))) strength++;
    if (pass.contains(RegExp(r'[!@#\$&*~%^]'))) strength++;

    final labels = ["", "Weak", "Fair", "Good", "Strong"];
    final colors = [
      Colors.transparent,
      const Color(0xFFE57373),
      const Color(0xFFFFB74D),
      const Color(0xFF81C784),
      const Color(0xFF2D6A4F),
    ];

    return AnimatedBuilder(
      animation: _passCtrl,
      builder: (_, __) {
        final p = _passCtrl.text;
        int s = 0;
        if (p.length >= 6) s++;
        if (p.contains(RegExp(r'[A-Z]'))) s++;
        if (p.contains(RegExp(r'[0-9]'))) s++;
        if (p.contains(RegExp(r'[!@#\$&*~%^]'))) s++;

        if (p.isEmpty) return const SizedBox.shrink();

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: List.generate(4, (i) => Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i < s ? colors[s] : const Color(0xFFB7E4C7).withOpacity(0.4),
              ),
            ),
          ))),
          const SizedBox(height: 4),
          Text(labels[s],
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600,
                color: colors[s],
              )),
        ]);
      },
    );
  }

  Widget _lbl(String t) => Text(t.toUpperCase(),
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
          color: Color(0xFF40916C), letterSpacing: 0.8));

  Widget _field({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction action = TextInputAction.next,
    bool obscure = false,
    Widget? suffix,
    void Function(String)? onSubmit,
    String? Function(String?)? validate,
  }) =>
      TextFormField(
        controller: controller, focusNode: focusNode,
        obscureText: obscure, keyboardType: keyboardType,
        textInputAction: action, onFieldSubmitted: onSubmit, validator: validate,
        style: const TextStyle(fontSize: 15, color: Color(0xFF1B4332), fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: const Color(0xFF95D5B2).withOpacity(0.8), fontSize: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(icon, color: const Color(0xFF52B788), size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: suffix,
          filled: true, fillColor: Colors.white.withOpacity(0.75),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: _ob(), enabledBorder: _ob(), focusedBorder: _fb(),
          errorBorder: _eb(), focusedErrorBorder: _eb(f: true),
          errorStyle: const TextStyle(color: Color(0xFFB74343), fontSize: 11.5),
        ),
      );

  OutlineInputBorder _ob() => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: const Color(0xFFB7E4C7).withOpacity(0.6), width: 1.5));
  OutlineInputBorder _fb() => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF52B788), width: 2));
  OutlineInputBorder _eb({bool f = false}) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: const Color(0xFFE57373), width: f ? 2 : 1.5));

  Widget _signupBtn(Size size) => AnimatedBuilder(
    animation: _glowPulse,
    builder: (_, __) => GestureDetector(
      onTap: _loading ? null : _handleSignup,
      child: Container(
        height: size.height * 0.068,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF2D6A4F), Color(0xFF1B4332)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          boxShadow: [BoxShadow(
            color: const Color(0xFF1B4332).withOpacity(0.25 + 0.10 * _glowPulse.value),
            blurRadius: 16 + 8 * _glowPulse.value, offset: const Offset(0, 6),
          )],
        ),
        child: Stack(children: [
          Positioned.fill(child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
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
                : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.agriculture_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text("Create Account",
                  style: TextStyle(
                      fontSize: size.width * 0.042, fontWeight: FontWeight.w700,
                      color: Colors.white, letterSpacing: 0.4)),
            ]),
          ),
        ]),
      ),
    ),
  );

  Widget _buildBadge() => FadeTransition(
    opacity: _cardFade,

  );
}

// ── Background Painter ─────────────────────────────────────────────────────────
class _SuBgPainter extends CustomPainter {
  final double t; _SuBgPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFF2FAF4));
    final blobs = [
      [0.82 + 0.04*math.sin(t*math.pi), 0.08+0.03*math.cos(t*math.pi*1.3), 0.55, 0xFFB7E4C7, 0.32, 80.0],
      [0.08+0.03*math.cos(t*math.pi*0.9), 0.20+0.04*math.sin(t*math.pi*1.1), 0.48, 0xFF95D5B2, 0.22, 70.0],
      [0.68+0.05*math.sin(t*math.pi*1.2), 0.60+0.04*math.cos(t*math.pi*0.8), 0.42, 0xFF74C69D, 0.18, 65.0],
      [0.12+0.03*math.sin(t*math.pi*1.4), 0.78+0.03*math.cos(t*math.pi), 0.40, 0xFFD8F3DC, 0.40, 60.0],
      [0.50+0.02*math.cos(t*math.pi*1.6), 0.40+0.02*math.sin(t*math.pi), 0.35, 0xFF52B788, 0.12, 55.0],
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
  @override bool shouldRepaint(_SuBgPainter o) => o.t != t;
}

// ── Leaf Painter ────────────────────────────────────────────────────────────────
class _SuLeafPainter extends CustomPainter {
  final double t; _SuLeafPainter(this.t);
  static const _s = [
    [0.05,0.10,0.7,0.0],[0.92,0.07,1.1,0.3],[0.10,0.82,0.9,0.6],[0.88,0.70,0.6,0.9],
    [0.50,0.03,1.3,0.15],[0.60,0.92,0.8,0.45],[0.03,0.55,1.0,0.75],[0.95,0.50,0.7,0.55],
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
  @override bool shouldRepaint(_SuLeafPainter o) => o.t != t;
}
