import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/platform/platform_utils.dart';
import '../../../core/theme/app_theme.dart';
import '../../../presentation/providers/auth_providers.dart';

// ── Palette ────────────────────────────────────────────────────────────────
const _terracotta = ScolarisPalette.terracotta;
const _orange     = ScolarisPalette.orange;
const _gold       = ScolarisPalette.gold;
const _green      = ScolarisPalette.forestGreen;
const _cream      = ScolarisPalette.cream;
const _ink        = Color(0xFF1A0A00);
const _muted      = Color(0xFF7A5C44);
const _border     = Color(0xFFDDCCBB);
const _white      = Colors.white;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'student@scolaris.app');
  final _passCtrl  = TextEditingController(text: 'demo1234');
  final _form      = GlobalKey<FormState>();
  bool _loading    = false;
  bool _obscure    = true;
  String? _error;
  String _selectedRole = 'student';

  static const _roles = [
    ('student',     Icons.school_outlined,              'Student'),
    ('parent',      Icons.family_restroom_outlined,     'Parent'),
    ('teacher',     Icons.menu_book_outlined,           'Teacher'),
    ('surveillance',Icons.shield_outlined,              'Surveillance'),
    ('finance',     Icons.payments_outlined,            'Finance'),
    ('admin',       Icons.admin_panel_settings_outlined,'Admin'),
  ];

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
      _emailCtrl.text = '$role@scolaris.app';
      _passCtrl.text  = 'demo1234';
      _error          = null;
    });
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(signInUseCaseProvider)(_emailCtrl.text.trim(), _passCtrl.text);
    } on ArgumentError catch (e) {
      setState(() => _error = (e.message as String).tr());
    } catch (_) {
      setState(() => _error = 'auth.errors.failed'.tr());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _quickQrLogin() async {
    setState(() => _loading = true);
    try {
      await ref.read(signInWithQrUseCaseProvider)('teacher:teacher@scolaris.app');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width  = MediaQuery.sizeOf(context).width;
    final isWide = PlatformUtils.isLargeFormFactor(width);
    return Scaffold(
      backgroundColor: _cream,
      body: SafeArea(
        child: Row(
          children: [
            if (isWide) const Expanded(child: _AnimatedLeftPanel()),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _buildForm(context),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Brand mark
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 36,
                  height: 36,
                  errorBuilder: (_, __, ___) => Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_terracotta, _orange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: Text('S',
                        style: TextStyle(color: _white, fontWeight: FontWeight.w800, fontSize: 18))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppConfig.appName,
                      style: const TextStyle(color: _ink, fontWeight: FontWeight.w800, fontSize: 17)),
                  Text(AppConfig.appTagline,
                      style: TextStyle(color: _muted.withOpacity(.8), fontSize: 10, fontStyle: FontStyle.italic)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text('auth.welcome'.tr(),
              style: const TextStyle(color: _ink, fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('auth.subWelcome'.tr(),
              style: const TextStyle(color: _muted, fontSize: 13)),
          const SizedBox(height: 24),
          _label('auth.email'.tr()),
          const SizedBox(height: 6),
          _STextField(
            controller: _emailCtrl,
            hint: 'nom@ecole.com',
            icon: Icons.mail_outline_rounded,
            keyboard: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email requis';
              if (!v.contains('@')) return 'Email invalide';
              return null;
            },
          ),
          const SizedBox(height: 14),
          Row(children: [
            _label('auth.password'.tr()),
            const Spacer(),
            Text('Mot de passe oublié ?',
                style: TextStyle(color: _muted, fontSize: 11, fontWeight: FontWeight.w500)),
          ]),
          const SizedBox(height: 6),
          _STextField(
            controller: _passCtrl,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _obscure,
            suffix: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 16, color: _muted),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Mot de passe requis' : null,
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(children: [
                const Icon(Icons.error_outline, size: 14, color: Color(0xFFB91C1C)),
                const SizedBox(width: 8),
                Expanded(child: Text(_error!,
                    style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12))),
              ]),
            ),
          ],
          const SizedBox(height: 20),
          _PrimaryBtn(label: 'auth.login'.tr(), loading: _loading, onTap: _submit),
          const SizedBox(height: 10),
          _SecondaryBtn(
            label: 'auth.loginWithQr'.tr(),
            icon: Icons.qr_code_2_rounded,
            onTap: _loading ? null : _quickQrLogin,
          ),
          const SizedBox(height: 24),
          Row(children: [
            const Expanded(child: Divider(color: _border, height: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('Comptes de démonstration',
                  style: const TextStyle(fontSize: 11, color: _muted)),
            ),
            const Expanded(child: Divider(color: _border, height: 1)),
          ]),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: [
              for (final r in _roles)
                _RoleChip(
                  label: r.$3, icon: r.$2,
                  selected: _selectedRole == r.$1,
                  onTap: () => _selectRole(r.$1),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Center(child: Text('Mot de passe : demo1234',
              style: TextStyle(color: _muted.withOpacity(.8), fontSize: 11))),
        ],
      ),
    );
  }

  Widget _label(String s) => Text(s,
      style: const TextStyle(fontSize: 12, color: _ink, fontWeight: FontWeight.w600));
}

// ─── Animated Left Panel ──────────────────────────────────────────────────
class _AnimatedLeftPanel extends StatefulWidget {
  const _AnimatedLeftPanel();
  @override
  State<_AnimatedLeftPanel> createState() => _AnimatedLeftPanelState();
}

class _AnimatedLeftPanelState extends State<_AnimatedLeftPanel>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _rotCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _rotCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat();
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    _rotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3E1A00), Color(0xFF8B1A00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(child: CustomPaint(painter: _AfricanPatternPainter(_rotCtrl))),

          // Campus illustration
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _floatCtrl,
              builder: (_, __) {
                final t = _floatCtrl.value;
                return Transform.translate(
                  offset: Offset(0, -8 * math.sin(t * math.pi)),
                  child: CustomPaint(painter: _CampusPainter()),
                );
              },
            ),
          ),

          // Floating icons
          _FloatingIcon(ctrl: _floatCtrl, delay: 0.0, top: 0.15, left: 0.12,
              icon: Icons.menu_book_rounded, color: _gold.withOpacity(.9), size: 28),
          _FloatingIcon(ctrl: _floatCtrl, delay: 0.3, top: 0.30, left: 0.72,
              icon: Icons.school_rounded, color: _white.withOpacity(.85), size: 24),
          _FloatingIcon(ctrl: _floatCtrl, delay: 0.6, top: 0.60, left: 0.08,
              icon: Icons.emoji_events_rounded, color: _gold.withOpacity(.8), size: 22),
          _FloatingIcon(ctrl: _floatCtrl, delay: 0.15, top: 0.72, left: 0.78,
              icon: Icons.science_rounded, color: _white.withOpacity(.7), size: 20),
          _FloatingIcon(ctrl: _floatCtrl, delay: 0.5, top: 0.45, left: 0.85,
              icon: Icons.calculate_rounded, color: _gold.withOpacity(.75), size: 18),

          // Pulsing dots
          for (int i = 0; i < 6; i++)
            _PulsingDot(ctrl: _pulseCtrl,
                delay: i * 0.16,
                top: 0.12 + i * 0.13,
                left: 0.05 + (i % 2) * 0.82,
                color: i.isEven ? _gold : _white),

          // Bottom text
          Positioned(
            bottom: 48, left: 40, right: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo + name
                Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset('assets/images/logo.png', width: 40, height: 40,
                        errorBuilder: (_, __, ___) => Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: _gold.withOpacity(.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.school_rounded, color: _gold, size: 24),
                        )),
                  ),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Scolaris', style: TextStyle(
                        color: _white, fontSize: 22, fontWeight: FontWeight.w800)),
                    Text('Savoir, Héritage, Avenir',
                        style: TextStyle(color: _gold.withOpacity(.9), fontSize: 12,
                            fontStyle: FontStyle.italic)),
                  ]),
                ]),
                const SizedBox(height: 20),
                const Text('La plateforme scolaire\nde l\'Afrique de demain.',
                    style: TextStyle(color: _white, fontSize: 24,
                        fontWeight: FontWeight.w700, height: 1.3)),
                const SizedBox(height: 14),
                Row(children: [
                  _FeaturePill(icon: Icons.people_rounded, label: '6 rôles'),
                  const SizedBox(width: 8),
                  _FeaturePill(icon: Icons.offline_bolt_rounded, label: 'Hors-ligne'),
                  const SizedBox(width: 8),
                  _FeaturePill(icon: Icons.translate_rounded, label: '4 langues'),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _white.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _white.withOpacity(.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: _gold),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: _white, fontSize: 11,
            fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  final AnimationController ctrl;
  final double delay, top, left;
  final IconData icon;
  final Color color;
  final double size;
  const _FloatingIcon({
    required this.ctrl, required this.delay,
    required this.top, required this.left,
    required this.icon, required this.color, required this.size,
  });

  @override
  Widget build(BuildContext context) {
    // Convert 0..1 fractions to -1..1 Alignment coordinates
    final alignX = left * 2 - 1;
    final alignY = top * 2 - 1;
    return Align(
      alignment: Alignment(alignX, alignY),
      child: AnimatedBuilder(
        animation: ctrl,
        builder: (_, __) {
          final t = ((ctrl.value + delay) % 1.0);
          final dy = -12 * math.sin(t * math.pi * 2);
          return Transform.translate(
            offset: Offset(0, dy),
            child: Opacity(
              opacity: 0.7 + 0.3 * math.sin(t * math.pi * 2),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _white.withOpacity(.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: size),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PulsingDot extends StatelessWidget {
  final AnimationController ctrl;
  final double delay, top, left;
  final Color color;
  const _PulsingDot({
    required this.ctrl, required this.delay,
    required this.top, required this.left, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final alignX = left * 2 - 1;
    final alignY = top * 2 - 1;
    return Align(
      alignment: Alignment(alignX, alignY),
      child: AnimatedBuilder(
        animation: ctrl,
        builder: (_, __) {
          final t = ((ctrl.value + delay) % 1.0);
          final scale = 0.5 + 0.5 * t;
          return Opacity(
            opacity: (1 - t) * 0.4,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── CustomPainter – campus silhouette ────────────────────────────────────
class _CampusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _white.withOpacity(.07);
    final w = size.width;
    final h = size.height;

    // Ground
    final ground = Paint()..color = _white.withOpacity(.05);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.62, w, h * 0.38), ground);

    // Main building
    final bPaint = Paint()..color = _white.withOpacity(.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w*0.25, h*0.38, w*0.5, h*0.25), const Radius.circular(4)),
      bPaint,
    );
    // Roof triangle
    final roof = Path()
      ..moveTo(w*0.22, h*0.38)
      ..lineTo(w*0.5, h*0.22)
      ..lineTo(w*0.78, h*0.38)
      ..close();
    canvas.drawPath(roof, Paint()..color = _gold.withOpacity(.15));

    // Left building
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w*0.05, h*0.48, w*0.17, h*0.15), const Radius.circular(3)),
      Paint()..color = _white.withOpacity(.08),
    );
    // Right building
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w*0.78, h*0.44, w*0.17, h*0.19), const Radius.circular(3)),
      Paint()..color = _white.withOpacity(.08),
    );

    // Windows
    final win = Paint()..color = _gold.withOpacity(.2);
    for (int row = 0; row < 2; row++) {
      for (int col = 0; col < 4; col++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w*0.30 + col*w*0.10, h*0.42 + row*h*0.07, w*0.07, h*0.05),
            const Radius.circular(2),
          ),
          win,
        );
      }
    }

    // Flag pole
    canvas.drawLine(Offset(w*0.5, h*0.22), Offset(w*0.5, h*0.12), paint..strokeWidth = 2);
    // Flag
    final flag = Path()
      ..moveTo(w*0.5, h*0.12)
      ..lineTo(w*0.62, h*0.155)
      ..lineTo(w*0.5, h*0.19)
      ..close();
    canvas.drawPath(flag, Paint()..color = _gold.withOpacity(.5));

    // Trees
    _drawTree(canvas, Offset(w*0.12, h*0.62), h*0.07, paint);
    _drawTree(canvas, Offset(w*0.88, h*0.62), h*0.07, paint);
    _drawTree(canvas, Offset(w*0.22, h*0.62), h*0.055, paint);
    _drawTree(canvas, Offset(w*0.78, h*0.62), h*0.055, paint);
  }

  void _drawTree(Canvas canvas, Offset base, double h, Paint p) {
    final trunk = Paint()..color = _gold.withOpacity(.12);
    canvas.drawRect(Rect.fromCenter(center: base, width: h*0.15, height: h*0.3), trunk);
    final leaves = Paint()..color = _white.withOpacity(.12);
    canvas.drawCircle(base.translate(0, -h*0.5), h*0.35, leaves);
    canvas.drawCircle(base.translate(-h*0.2, -h*0.35), h*0.25, leaves);
    canvas.drawCircle(base.translate(h*0.2, -h*0.35), h*0.25, leaves);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Background African pattern ────────────────────────────────────────────
class _AfricanPatternPainter extends CustomPainter {
  final Animation<double> anim;
  _AfricanPatternPainter(this.anim) : super(repaint: anim);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _gold.withOpacity(.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final t = anim.value * 2 * math.pi;
    final spacing = 60.0;
    final cols = (size.width / spacing).ceil() + 1;
    final rows = (size.height / spacing).ceil() + 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cx = c * spacing + math.sin(t + r * 0.4) * 3;
        final cy = r * spacing + math.cos(t + c * 0.4) * 3;
        _drawAdinkra(canvas, Offset(cx, cy), 14, paint);
      }
    }
  }

  void _drawAdinkra(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size * 0.7, center.dy - size * 0.3)
      ..lineTo(center.dx + size * 0.7, center.dy + size * 0.3)
      ..lineTo(center.dx, center.dy + size)
      ..lineTo(center.dx - size * 0.7, center.dy + size * 0.3)
      ..lineTo(center.dx - size * 0.7, center.dy - size * 0.3)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AfricanPatternPainter old) => true;
}

// ─── Form widgets ──────────────────────────────────────────────────────────
class _STextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;
  const _STextField({
    required this.controller, required this.hint, required this.icon,
    this.obscure = false, this.suffix, this.keyboard, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      validator: validator,
      style: const TextStyle(fontSize: 13.5, color: _ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _muted, fontSize: 13.5),
        prefixIcon: Icon(icon, size: 16, color: _muted),
        prefixIconConstraints: const BoxConstraints.tightFor(width: 38),
        suffixIcon: suffix,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 13),
        filled: true,
        fillColor: _white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _terracotta, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onTap;
  const _PrimaryBtn({required this.label, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: MouseRegion(
        cursor: loading ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: AnimatedOpacity(
          opacity: loading ? .8 : 1,
          duration: const Duration(milliseconds: 200),
          child: Container(
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_terracotta, _orange],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: _terracotta.withOpacity(.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _white))
                : Text(label, style: const TextStyle(
                    color: _white, fontSize: 14, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

class _SecondaryBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const _SecondaryBtn({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 16, color: _terracotta),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: _ink, fontSize: 14,
                fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _RoleChip({required this.label, required this.icon,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: selected ? _terracotta : _white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? _terracotta : _border),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 13, color: selected ? _white : _muted),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
                color: selected ? _white : _ink,
                fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}
