import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'home_screen.dart';
import 'signup_screen.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {

  late AnimationController _bgCtrl, _entryCtrl, _leafCtrl, _glowCtrl, _shimmerCtrl;
  late Animation<double> _bgFloat, _logoFade, _cardFade, _glowPulse;
  late Animation<Offset> _logoSlide, _cardSlide;

  final _formKey   = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;
  bool _loading    = false;
  bool _rememberMe = false;
  final _phoneFocus = FocusNode();
  final _passFocus  = FocusNode();

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
    _logoSlide = Tween<Offset>(begin: const Offset(0, -0.06), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.0, 0.50, curve: Curves.easeOutCubic)));
    _cardFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.30, 0.80, curve: Curves.easeOut)));
    _cardSlide = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryCtrl, curve: const Interval(0.30, 0.80, curve: Curves.easeOutCubic)));

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
    _phoneCtrl.dispose(); _passCtrl.dispose();
    _phoneFocus.dispose(); _passFocus.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => MyHomePage(title: "Home"),
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 500),
    ));
  }


  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Encrypt password using SHA256
  String encryptPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  // Email & Password Sign Up
  // Future<void> signUpWithEmail() async {
  //   try {
  //     final email = _phoneCtrl.text.trim();
  //     final password = _passCtrl.text.trim();
  //
  //     if (email.isEmpty || password.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Email and password cannot be empty')),
  //       );
  //       return;
  //     }
  //
  //     UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //
  //     // Save user info in Firestore
  //     await _firestore.collection('users').doc(userCredential.user!.uid).set({
  //       'email': email,
  //       'password': encryptPassword(password),
  //       'name': email.split('@')[0], // default name
  //     });
  //
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text('Sign up successful!')));
  //   } on FirebaseAuthException catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message!)));
  //   }
  // }

  // Email & Password Login
  Future<void> signInWithEmail() async {
    try {
      final email = _phoneCtrl.text.trim();
      final password = _passCtrl.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email and password cannot be empty')),
        );
        return;
      }

      await _auth.signInWithEmailAndPassword(email: email, password: password);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Login successful!')));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message!)));
    }
  }

  // Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize();

      // NEW METHOD (v7+)
      final GoogleSignInAccount googleUser =
      await googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Store user in Firestore if new
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!doc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName ?? 'No Name',
          'password': 'google_user',
          'createdAt': Timestamp.now(),
        });
      }

      print("Google Sign-In Successful");

    } catch (e) {
      print("Error: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    final size    = MediaQuery.of(context).size;
    final isSmall = size.height < 680;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2FAF4),
        resizeToAvoidBottomInset: true,
        body: Stack(children: [
          AnimatedBuilder(
            animation: _bgFloat,
            builder: (_, __) =>
                CustomPaint(size: size, painter: _BgPainter(_bgFloat.value)),
          ),
          AnimatedBuilder(
            animation: _leafCtrl,
            builder: (_, __) =>
                CustomPaint(size: size, painter: _LeafPainter(_leafCtrl.value)),
          ),
          SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    child: Column(children: [
                      SizedBox(height: isSmall ? 14 : 26),
                      _buildBrand(size),
                      SizedBox(height: isSmall ? 14 : 24),
                      _buildCard(size),
                      SizedBox(height: isSmall ? 10 : 18),
                      _buildBadge(),
                      SizedBox(height: isSmall ? 12 : 22),
                    ]),
                  ),
                ),
              );
            }),
          ),
        ]),
      ),
    );
  }

  // ── Brand ────────────────────────────────────────────────────────────────
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
          const SizedBox(height: 7),
          Text(
              AppLocalizations.of(context)?.taglinemain ??"Smart Farming Assistant",
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

  // ── Card ─────────────────────────────────────────────────────────────────
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
                size.width * 0.06, size.height * 0.028,
                size.width * 0.06, size.height * 0.028,
              ),
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                      AppLocalizations.of(context)?.welcome ??"Welcome back",
                      style: TextStyle(
                        fontSize: size.width * 0.063, fontWeight: FontWeight.w800,
                        color: const Color(0xFF1B4332), letterSpacing: -0.5, height: 1.1,
                      )),
                  const SizedBox(height: 4),
                  Text(
                      AppLocalizations.of(context)?.signinmessage ?? "Sign in to your farm account",
                      style: TextStyle(
                          fontSize: size.width * 0.033,
                          color: const Color(0xFF74C69D))),

                  SizedBox(height: size.height * 0.024),

                  _lbl(AppLocalizations.of(context)?.phoneemail ??"Phone or Email"),
                  const SizedBox(height: 8),
                  _field(
                    controller: _phoneCtrl, focusNode: _phoneFocus,
                    hint: AppLocalizations.of(context)?.phoneemailhint ??"Enter phone or email",
                    icon: Icons.person_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                    action: TextInputAction.next,
                    onSubmit: (_) => FocusScope.of(context).requestFocus(_passFocus),
                      validate: (v) {
                        if (v == null || v.trim().isEmpty) return AppLocalizations.of(context)?.phoneemailerrorrequired ??"Required";

                        final value = v.trim();

                        // Email regex
                        final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

                        // Phone regex (10 digits)
                        final phoneRegex = RegExp(r'^[0-9]{10}$');

                        if (!emailRegex.hasMatch(value) && !phoneRegex.hasMatch(value)) {
                          return AppLocalizations.of(context)?.phoneemailerrorinvalid ??"Enter valid email or 10-digit phone";
                        }

                        return null;
                      },
                  ),

                  SizedBox(height: size.height * 0.017),

                  _lbl(AppLocalizations.of(context)?.password ??"Password"),
                  const SizedBox(height: 8),
                  _field(
                    controller: _passCtrl, focusNode: _passFocus,
                    hint: AppLocalizations.of(context)?.passwordhint ??"Enter password",
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscure,
                    action: TextInputAction.done,
                    onSubmit: (_) => _handleLogin(),
                    suffix: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                          size: 20, color: const Color(0xFF95D5B2)),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validate: (v) {
                      if (v == null || v.isEmpty) return AppLocalizations.of(context)?.passworderrorrequired ??"Password is required";
                      if (v.length < 6) return AppLocalizations.of(context)?.passworderrormin ??"Minimum 6 characters";
                      return null;
                    },
                  ),

                  SizedBox(height: size.height * 0.013),

                  // Remember me + Forgot
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    GestureDetector(
                      onTap: () => setState(() => _rememberMe = !_rememberMe),
                      child: Row(children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: _rememberMe ? const Color(0xFF52B788) : Colors.transparent,
                            border: Border.all(
                              color: _rememberMe ? const Color(0xFF52B788) : const Color(0xFF95D5B2),
                              width: 1.5,
                            ),
                          ),
                          child: _rememberMe
                              ? const Icon(Icons.check, size: 13, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                            AppLocalizations.of(context)?.rememberme ??"Remember me",
                            style: TextStyle(
                                fontSize: size.width * 0.031,
                                color: const Color(0xFF40916C),
                                fontWeight: FontWeight.w500)),
                      ]),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                          AppLocalizations.of(context)?.forgotpassword ??"Forgot password?",
                          style: TextStyle(
                              fontSize: size.width * 0.031,
                              color: const Color(0xFF2D6A4F),
                              fontWeight: FontWeight.w600)),
                    ),
                  ]),

                  SizedBox(height: size.height * 0.025),

                  // Login button
                  _loginBtn(size),

                  SizedBox(height: size.height * 0.018),

                  // OR
                  Row(children: [
                    Expanded(child: Container(height: 1,
                        decoration: BoxDecoration(gradient: LinearGradient(
                            colors: [Colors.transparent, const Color(0xFFB7E4C7).withOpacity(0.7)])))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                          AppLocalizations.of(context)?.orcontinuewith ??"or continue with",
                          style: TextStyle(
                              fontSize: size.width * 0.030,
                              color: const Color(0xFF74C69D).withOpacity(0.9),
                              fontWeight: FontWeight.w500)),
                    ),
                    Expanded(child: Container(height: 1,
                        decoration: BoxDecoration(gradient: LinearGradient(
                            colors: [const Color(0xFFB7E4C7).withOpacity(0.7), Colors.transparent])))),
                  ]),

                  SizedBox(height: size.height * 0.015),

                  // Google only
                  _googleBtn(size),

                  SizedBox(height: size.height * 0.020),

                  // Sign up
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const SignupScreen(),
                        transitionsBuilder: (_, anim, __, child) =>
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, 0), end: Offset.zero,
                              ).animate(anim),
                              child: child,
                            ),
                        transitionDuration: const Duration(milliseconds: 400),
                      )),
                      child: RichText(
                        text: // ✅ Correct: Remove 'const' so the text can update
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "${AppLocalizations.of(context)?.newuser ?? "New farmer?"} ",
                              style: TextStyle(color: Colors.grey[600]), // Example style
                            ),
                            TextSpan(
                              text: AppLocalizations.of(context)?.createaccount ?? "Create account →",
                              style: const TextStyle(
                                color: Color(0xFF2D6A4F),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
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

  Widget _loginBtn(Size size) => AnimatedBuilder(
    animation: _glowPulse,
    builder: (_, __) => GestureDetector(
      onTap: _loading ? null : _handleLogin,
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
              const Icon(Icons.login_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text( AppLocalizations.of(context)?.login ??"Login", style: TextStyle(
                  fontSize: size.width * 0.043, fontWeight: FontWeight.w700,
                  color: Colors.white, letterSpacing: 0.4)),
            ]),
          ),
        ]),
      ),
    ),
  );

  Widget _googleBtn(Size size) => GestureDetector(
    onTap: () {signInWithGoogle();},
    child: Container(
      height: size.height * 0.063,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withOpacity(0.80),
        border: Border.all(color: const Color(0xFFB7E4C7).withOpacity(0.6), width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            width: 22,
            height: 22,
            child: CustomPaint(painter: _GoogleLogo()
            )
        ),
        const SizedBox(width: 10),
        Text(
            AppLocalizations.of(context)?.googlelogin ??"Continue with Google",
            style: TextStyle(
                fontSize: size.width * 0.036, fontWeight: FontWeight.w600,
                color: const Color(0xFF2D6A4F))),
      ]),
    ),
  );

  Widget _buildBadge() => FadeTransition(
    opacity: _cardFade,
    child: Column(children: [
      AnimatedBuilder(
        animation: _glowCtrl,
        builder: (_, __) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final phase = (_glowCtrl.value + i / 3.0) % 1.0;
            final scale = 0.6 + 0.4 * math.sin(phase * math.pi);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(scale: scale,
                  child: Container(width: 6, height: 6,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                          color: Color.lerp(const Color(0xFFB7E4C7), const Color(0xFF2D6A4F), scale)))),
            );
          }),
        ),
      ),

    ]),
  );
}

// ── Google Logo Painter ──────────────────────────────────────────────────────
class _GoogleLogo extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final strokeWidth = radius * 0.32;

    final rect = Rect.fromCircle(center: center, radius: radius * 0.75);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Blue
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.4, 1.6, false, paint);

    // Red
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 1.2, 1.2, false, paint);

    // Yellow
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.4, 1.0, false, paint);

    // Green
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 3.3, 1.8, false, paint);

    // Horizontal line
    paint.color = const Color(0xFF4285F4);

    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(center.dx + radius * 0.7, center.dy),
      paint..strokeWidth = strokeWidth * 0.9,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ── Background Painter ────────────────────────────────────────────────────────
class _BgPainter extends CustomPainter {
  final double t; _BgPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFF2FAF4));
    final blobs = [
      [0.80 + 0.04 * math.sin(t * math.pi), 0.10 + 0.03 * math.cos(t * math.pi * 1.3), 0.55, 0xFFB7E4C7, 0.35, 80.0],
      [0.10 + 0.03 * math.cos(t * math.pi * 0.9), 0.22 + 0.04 * math.sin(t * math.pi * 1.1), 0.48, 0xFF95D5B2, 0.25, 70.0],
      [0.70 + 0.05 * math.sin(t * math.pi * 1.2), 0.65 + 0.04 * math.cos(t * math.pi * 0.8), 0.42, 0xFF74C69D, 0.20, 65.0],
      [0.15 + 0.03 * math.sin(t * math.pi * 1.4), 0.80 + 0.03 * math.cos(t * math.pi), 0.40, 0xFFD8F3DC, 0.42, 60.0],
    ];
    for (final b in blobs) {
      canvas.drawCircle(
        Offset(size.width * (b[0] as double), size.height * (b[1] as double)),
        size.width * (b[2] as double),
        Paint()
          ..color = Color(b[3] as int).withOpacity(b[4] as double)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, b[5] as double),
      );
    }
  }
  @override bool shouldRepaint(_BgPainter o) => o.t != t;
}

// ── Leaf Painter ──────────────────────────────────────────────────────────────
class _LeafPainter extends CustomPainter {
  final double t; _LeafPainter(this.t);
  static const _s = [
    [0.06,0.12,0.7,0.0],[0.90,0.08,1.1,0.3],[0.12,0.80,0.9,0.6],[0.85,0.72,0.6,0.9],
    [0.48,0.04,1.3,0.15],[0.62,0.90,0.8,0.45],[0.04,0.52,1.0,0.75],[0.93,0.48,0.7,0.55],
  ];
  static const _cols = [0xFF52B788, 0xFF74C69D, 0xFF40916C, 0xFFB7E4C7];
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _s.length; i++) {
      final ph = (t + _s[i][3]) % 1.0;
      final x  = _s[i][0] * size.width  + 14 * math.sin(ph * math.pi * 2 * _s[i][2]);
      final y  = _s[i][1] * size.height + 10 * math.cos(ph * math.pi * 2 * _s[i][2] * 0.8);
      final r  = 5.0 + 3 * math.sin(ph * math.pi);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(ph * math.pi * 2 * (i.isEven ? 1 : -1));
      canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..cubicTo(-r*0.6,-r*0.9,-r*0.4,-r*1.8,0,-r*2.2)
          ..cubicTo(r*0.4,-r*1.8,r*0.6,-r*0.9,0,0),
        Paint()..color = Color(_cols[i % 4]).withOpacity(0.15 + 0.12 * math.sin(ph * math.pi * 2)),
      );
      canvas.restore();
    }
  }
  @override bool shouldRepaint(_LeafPainter o) => o.t != t;
}
