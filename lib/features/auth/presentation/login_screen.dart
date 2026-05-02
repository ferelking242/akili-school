import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../presentation/providers/auth_providers.dart';
import 'forgot_password_screen.dart';

const _terra  = ScolarisPalette.terracotta;
const _orange = ScolarisPalette.orange;
const _gold   = ScolarisPalette.gold;
const _green  = ScolarisPalette.forestGreen;
const _cream  = ScolarisPalette.cream;
const _ink    = Color(0xFF1A0A00);
const _muted  = Color(0xFF7A5C44);
const _border = Color(0xFFDDCCBB);
const _white  = Colors.white;
const _dark   = Color(0xFF0D1117);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController(text: 'student@scolaris.app');
  final _passCtrl  = TextEditingController(text: 'demo1234');
  final _form      = GlobalKey<FormState>();

  bool _loading  = false;
  bool _obscure  = true;
  String? _error;
  String _selectedRole = 'student';
  bool _showQrScanner  = false;

  late final TabController _tabCtrl;

  static const _roles = [
    ('student',      Icons.school_outlined,               'Étudiant'),
    ('parent',       Icons.family_restroom_outlined,      'Parent'),
    ('teacher',      Icons.menu_book_outlined,            'Enseignant'),
    ('surveillance', Icons.shield_outlined,               'Surveillance'),
    ('finance',      Icons.payments_outlined,             'Finance'),
    ('admin',        Icons.admin_panel_settings_outlined, 'Admin'),
  ];

  static const _lottieUrls = [
    'https://assets6.lottiefiles.com/packages/lf20_ib4hcbca.json',
    'https://assets2.lottiefiles.com/packages/lf20_t9gkkhz4.json',
    'https://assets9.lottiefiles.com/packages/lf20_pprxh53t.json',
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  void _selectRole(String role) {
    setState(() {
      _selectedRole    = role;
      _emailCtrl.text  = '$role@scolaris.app';
      _passCtrl.text   = 'demo1234';
      _error           = null;
    });
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(signInUseCaseProvider)(
          _emailCtrl.text.trim(), _passCtrl.text);
    } on ArgumentError catch (e) {
      setState(() => _error = (e.message as String).tr());
    } catch (_) {
      setState(() => _error = 'auth.errors.failed'.tr());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleQrDetected(String rawValue) async {
    setState(() { _showQrScanner = false; _loading = true; _error = null; });
    try {
      await ref.read(signInWithQrUseCaseProvider)(rawValue);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'QR invalide ou carte non reconnue. Veuillez réessayer.';
          _loading = false;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width > 720;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _cream,
        body: isWide
            ? _buildWideLayout(context, size)
            : _buildMobileLayout(context, size),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, Size size) {
    return Row(
      children: [
        Expanded(child: _LeftHero(lottieUrls: _lottieUrls)),
        SizedBox(
          width: 480,
          child: _buildFormPanel(context),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, Size size) {
    return SafeArea(
      child: Column(
        children: [
          const _MobileHeader(),
          Expanded(child: _buildFormPanel(context)),
        ],
      ),
    );
  }

  Widget _buildFormPanel(BuildContext context) {
    if (_showQrScanner) return _QrScanPanel(onDetected: _handleQrDetected,
        onClose: () => setState(() => _showQrScanner = false));

    return Container(
      color: _white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _BrandMark(),
            const SizedBox(height: 28),

            TabBar(
              controller: _tabCtrl,
              labelColor: _terra,
              unselectedLabelColor: _muted,
              indicatorColor: _terra,
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              tabs: const [
                Tab(text: 'Connexion'),
                Tab(text: 'Scanner ID'),
              ],
            ),
            const SizedBox(height: 28),

            SizedBox(
              height: 480,
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _buildEmailForm(),
                  _buildQrTab(),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _divider('Comptes de démonstration'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                for (final r in _roles)
                  _RoleChip(
                    label: r.$3, icon: r.$2,
                    selected: _selectedRole == r.$1,
                    onTap: () => _selectRole(r.$1),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text('Mot de passe : demo1234',
                  style: TextStyle(color: _muted.withOpacity(.7), fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _fieldLabel('Adresse e-mail'),
          const SizedBox(height: 6),
          _STextField(
            controller: _emailCtrl,
            hint: 'nom@ecole.com',
            icon: Icons.mail_outline_rounded,
            keyboard: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'E-mail requis';
              if (!v.contains('@')) return 'E-mail invalide';
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(children: [
            _fieldLabel('Mot de passe'),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
              child: const Text('Mot de passe oublié ?',
                  style: TextStyle(color: _terra, fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 6),
          _STextField(
            controller: _passCtrl,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _obscure,
            suffix: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
              icon: Icon(_obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
                  size: 18, color: _muted),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            validator: (v) => (v == null || v.isEmpty) ? 'Mot de passe requis' : null,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _ErrorBanner(message: _error!),
          ],
          const SizedBox(height: 24),
          _PrimaryBtn(label: 'Se connecter', loading: _loading, onTap: _submit),
        ],
      ),
    );
  }

  Widget _buildQrTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5EEE6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _terra.withOpacity(.15)),
          ),
          child: Column(children: [
            SizedBox(
              height: 160,
              child: Lottie.asset(
                'assets/lottie/student_login.json',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: _terra.withOpacity(.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.credit_card_rounded, color: _terra, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Connectez-vous avec votre\ncarte étudiante',
                textAlign: TextAlign.center,
                style: TextStyle(color: _ink, fontSize: 16,
                    fontWeight: FontWeight.w700, height: 1.4)),
            const SizedBox(height: 6),
            Text(
              'Scannez le QR code imprimé sur votre carte étudiante. '
              'Il contient votre identifiant unique et vos informations d\'établissement.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 12.5, height: 1.5),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        if (_error != null) ...[
          _ErrorBanner(message: _error!),
          const SizedBox(height: 14),
        ],

        _PrimaryBtn(
          label: 'Scanner ma carte étudiante',
          loading: _loading,
          icon: Icons.qr_code_scanner_rounded,
          onTap: () => setState(() { _showQrScanner = true; _error = null; }),
        ),
        const SizedBox(height: 12),

        Row(children: [
          const Expanded(child: Divider(color: _border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('ou', style: TextStyle(color: _muted.withOpacity(.6), fontSize: 12)),
          ),
          const Expanded(child: Divider(color: _border)),
        ]),
        const SizedBox(height: 12),

        _SecondaryBtn(
          label: 'Saisir mon code manuellement',
          icon: Icons.keyboard_outlined,
          onTap: () => _tabCtrl.animateTo(0),
        ),

        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _gold.withOpacity(.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _gold.withOpacity(.2)),
          ),
          child: Row(children: [
            Icon(Icons.info_outline_rounded, color: _gold, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Le QR code de votre carte contient votre ID étudiant, votre établissement et votre promotion.',
                style: TextStyle(color: _muted, fontSize: 11.5, height: 1.5),
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _fieldLabel(String s) => Text(s,
      style: const TextStyle(fontSize: 13, color: _ink, fontWeight: FontWeight.w600));

  Widget _divider(String label) => Row(children: [
    const Expanded(child: Divider(color: _border, height: 1)),
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(label, style: const TextStyle(fontSize: 11, color: _muted)),
    ),
    const Expanded(child: Divider(color: _border, height: 1)),
  ]);
}

// ── Left Hero Panel (wide layout) ─────────────────────────────────────────
class _LeftHero extends StatefulWidget {
  final List<String> lottieUrls;
  const _LeftHero({required this.lottieUrls});
  @override
  State<_LeftHero> createState() => _LeftHeroState();
}

class _LeftHeroState extends State<_LeftHero> {
  int _lottieIdx = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D3B1E), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(fit: StackFit.expand, children: [
        _AfricanBg(),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            SizedBox(
              height: 300,
              child: _LottieSafe(url: widget.lottieUrls[_lottieIdx]),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'La plateforme scolaire\nde l\'Afrique de demain.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _white, fontSize: 26,
                    fontWeight: FontWeight.w800, height: 1.3),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Gérez votre établissement, suivez les performances et connectez toute la communauté éducative.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _white.withOpacity(.7), fontSize: 13, height: 1.6),
              ),
            ),
            const SizedBox(height: 28),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _FeaturePill(icon: Icons.people_rounded, label: '6 rôles'),
              const SizedBox(width: 8),
              _FeaturePill(icon: Icons.wifi_off_rounded, label: 'Hors-ligne'),
              const SizedBox(width: 8),
              _FeaturePill(icon: Icons.translate_rounded, label: '4 langues'),
            ]),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.lottieUrls.length, (i) =>
                GestureDetector(
                  onTap: () => setState(() => _lottieIdx = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _lottieIdx ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _lottieIdx ? _gold : _white.withOpacity(.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 24, left: 0, right: 0,
          child: Center(
            child: Text('© ${DateTime.now().year} Scolaris · Savoir, Héritage, Avenir',
                style: TextStyle(color: _white.withOpacity(.4), fontSize: 11)),
          ),
        ),
      ]),
    );
  }
}

// ── Mobile Header ──────────────────────────────────────────────────────────
class _MobileHeader extends StatelessWidget {
  const _MobileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A0A00), _terra],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      child: Column(
        children: [
          Row(children: [
            Image.asset('assets/images/logo_transparent.png', width: 40, height: 40,
                errorBuilder: (_, __, ___) => Image.asset(
                  'assets/images/logo.png', width: 40, height: 40,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.school_rounded, color: _gold, size: 36),
                )),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Scolaris',
                  style: TextStyle(color: _white, fontSize: 18,
                      fontWeight: FontWeight.w800)),
              Text('Savoir, Héritage, Avenir',
                  style: TextStyle(color: _gold.withOpacity(.8), fontSize: 10,
                      fontStyle: FontStyle.italic)),
            ]),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Lottie.asset('assets/lottie/student_login.json',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.school_rounded, size: 80, color: _gold)),
          ),
          const SizedBox(height: 8),
          const Text('Bienvenue sur Scolaris',
              style: TextStyle(color: _white, fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Plateforme scolaire africaine de nouvelle génération',
              textAlign: TextAlign.center,
              style: TextStyle(color: _white.withOpacity(.65), fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Brand Mark ────────────────────────────────────────────────────────────
class _BrandMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Image.asset(
        'assets/images/logo_transparent.png',
        width: 48, height: 48,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/logo.png', width: 48, height: 48,
          errorBuilder: (_, __, ___) => Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_terra, _orange]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Icon(Icons.school_rounded, color: _white, size: 26)),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Scolaris',
            style: TextStyle(color: _ink, fontWeight: FontWeight.w800, fontSize: 20)),
        Text(AppConfig.appTagline,
            style: TextStyle(color: _muted.withOpacity(.7), fontSize: 11,
                fontStyle: FontStyle.italic)),
      ]),
    ]);
  }
}

// ── QR Scanner Panel ──────────────────────────────────────────────────────
class _QrScanPanel extends StatefulWidget {
  final void Function(String) onDetected;
  final VoidCallback onClose;
  const _QrScanPanel({required this.onDetected, required this.onClose});

  @override
  State<_QrScanPanel> createState() => _QrScanPanelState();
}

class _QrScanPanelState extends State<_QrScanPanel> {
  final _ctrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );
  bool _scanned = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _ctrl,
            onDetect: (capture) {
              if (_scanned) return;
              final raw = capture.barcodes.firstOrNull?.rawValue;
              if (raw != null && raw.isNotEmpty) {
                _scanned = true;
                widget.onDetected(raw);
              }
            },
          ),

          // Overlay frame
          CustomPaint(painter: _ScanFramePainter()),

          // Top bar
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  GestureDetector(
                    onTap: widget.onClose,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: _white.withOpacity(.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: _white, size: 22),
                    ),
                  ),
                  const Spacer(),
                  const Text('Scanner carte étudiante',
                      style: TextStyle(color: _white, fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _ctrl.toggleTorch(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: _white.withOpacity(.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.flashlight_on_rounded,
                          color: _white, size: 20),
                    ),
                  ),
                ]),
              ),
            ),
          ),

          // Bottom info
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: SafeArea(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _white.withOpacity(.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _white.withOpacity(.15)),
                ),
                child: Column(children: [
                  const Icon(Icons.credit_card_rounded, color: _gold, size: 28),
                  const SizedBox(height: 10),
                  const Text('Pointez votre caméra vers le QR code\nde votre carte étudiante',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _white, fontSize: 13,
                          fontWeight: FontWeight.w600, height: 1.5)),
                  const SizedBox(height: 6),
                  Text(
                    'Le QR code contient votre identifiant étudiant (ID, établissement, promo)',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _white.withOpacity(.6), fontSize: 11, height: 1.4),
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dim = size.width * 0.65;
    final left = (size.width - dim) / 2;
    final top  = (size.height - dim) / 2 - 40;

    final overlay = Paint()..color = Colors.black.withOpacity(.55);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, top), overlay);
    canvas.drawRect(Rect.fromLTWH(0, top + dim, size.width, size.height - top - dim), overlay);
    canvas.drawRect(Rect.fromLTWH(0, top, left, dim), overlay);
    canvas.drawRect(Rect.fromLTWH(left + dim, top, size.width - left - dim, dim), overlay);

    final corner = Paint()
      ..color = ScolarisPalette.gold
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final r = 12.0;
    final len = 28.0;
    final pts = [
      [Offset(left, top + r), Offset(left, top), Offset(left + r, top)],
      [Offset(left + dim - r, top), Offset(left + dim, top), Offset(left + dim, top + r)],
      [Offset(left + dim, top + dim - r), Offset(left + dim, top + dim), Offset(left + dim - r, top + dim)],
      [Offset(left, top + dim - r), Offset(left, top + dim), Offset(left + r, top + dim)],
    ];
    for (final p in pts) {
      final path = Path()
        ..moveTo(p[0].dx, p[0].dy)
        ..lineTo(p[1].dx, p[1].dy)
        ..lineTo(p[2].dx, p[2].dy);
      canvas.drawPath(path, corner);
    }

    final line = Paint()
      ..color = ScolarisPalette.gold.withOpacity(.7)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(left + 12, top + dim / 2), Offset(left + dim - 12, top + dim / 2), line);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Lottie Safe Loader ────────────────────────────────────────────────────
class _LottieSafe extends StatelessWidget {
  final String url;
  const _LottieSafe({required this.url});

  @override
  Widget build(BuildContext context) {
    return Lottie.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => const _LottieFallback(),
    );
  }
}

class _LottieFallback extends StatelessWidget {
  const _LottieFallback();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(Icons.school_rounded,
          size: 80, color: _gold.withOpacity(.6)),
    );
  }
}

// ── African BG ────────────────────────────────────────────────────────────
class _AfricanBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _AfricanPatternPainter());
  }
}

class _AfricanPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = _white.withOpacity(.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const sp = 56.0;
    final cols = (size.width / sp).ceil() + 1;
    final rows = (size.height / sp).ceil() + 1;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        _hex(canvas, Offset(c * sp, r * sp), 14, p);
      }
    }
  }

  void _hex(Canvas canvas, Offset o, double r, Paint p) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final a = (i * 60 - 30) * 3.1416 / 180;
      final x = o.dx + r * _cos(a);
      final y = o.dy + r * _sin(a);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  double _cos(double a) => (a == 0) ? 1 : (a == 3.1416 / 2) ? 0 : (a == 3.1416) ? -1 : _approxCos(a);
  double _sin(double a) => _approxCos(3.1416 / 2 - a);
  double _approxCos(double a) {
    double r = 1, t = 1, s = -1;
    for (int i = 1; i < 8; i++) {
      t *= a * a / ((2 * i - 1) * (2 * i));
      r += s * t;
      s = -s;
    }
    return r;
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Feature Pill ─────────────────────────────────────────────────────────
class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _white.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _white.withOpacity(.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: _gold),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: _white, fontSize: 12,
            fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ── Form Widgets ──────────────────────────────────────────────────────────
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
      style: const TextStyle(fontSize: 14, color: _ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _muted.withOpacity(.6), fontSize: 14),
        prefixIcon: Icon(icon, size: 18, color: _muted),
        prefixIconConstraints: const BoxConstraints.tightFor(width: 44),
        suffixIcon: suffix,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
        filled: true,
        fillColor: const Color(0xFFFAF7F4),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _terra, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
        ),
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onTap;
  final IconData? icon;
  const _PrimaryBtn({
    required this.label, required this.loading,
    required this.onTap, this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: loading
                ? [_terra.withOpacity(.6), _orange.withOpacity(.6)]
                : [_terra, _orange],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: loading ? [] : [
            BoxShadow(color: _terra.withOpacity(.35),
                blurRadius: 14, offset: const Offset(0, 5)),
          ],
        ),
        child: loading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.2, color: _white))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (icon != null) ...[
                  Icon(icon, color: _white, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(label, style: const TextStyle(color: _white, fontSize: 15,
                    fontWeight: FontWeight.w700)),
              ]),
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
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border, width: 1.5),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: _terra),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: _ink, fontSize: 14,
              fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, size: 16, color: Color(0xFFDC2626)),
        const SizedBox(width: 10),
        Expanded(child: Text(message,
            style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12.5))),
      ]),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? _terra : _white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? _terra : _border),
          boxShadow: selected ? [BoxShadow(
            color: _terra.withOpacity(.25), blurRadius: 6, offset: const Offset(0, 2))] : [],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: selected ? _white : _muted),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(
              color: selected ? _white : _ink,
              fontSize: 12.5, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
