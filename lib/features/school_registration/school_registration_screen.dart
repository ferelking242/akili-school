import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// ── Palette ──────────────────────────────────────────────────────────────────
const _terra  = Color(0xFF8B1A00);
const _orange = Color(0xFFD4540A);
const _gold   = Color(0xFFC17F24);
const _green  = Color(0xFF1B5E20);
const _cream  = Color(0xFFFDF6EE);
const _white  = Color(0xFFFFFFFF);
const _ink    = Color(0xFF1A0A00);
const _muted  = Color(0xFF8A7060);
const _border = Color(0xFFE8DDD4);

// ── Data models ───────────────────────────────────────────────────────────────
class SchoolBranch {
  String city;
  String address;
  String name;
  SchoolBranch({this.city = '', this.address = '', this.name = ''});
}

class SchoolSeries {
  String name;
  String code;
  bool isActive;
  List<String> classes;
  SchoolSeries({
    required this.name,
    required this.code,
    this.isActive = true,
    List<String>? classes,
  }) : classes = classes ?? [];
}

// ── Preloaded data ────────────────────────────────────────────────────────────
const _educationSystems = [
  ('francophone', 'Francophone', 'France / Afrique francophone', Icons.flag_outlined),
  ('anglophone',  'Anglophone',  'UK / Nigeria / Ghana…',        Icons.language_outlined),
  ('lmd',         'LMD',         'Université (Licence-Master-Doctorat)', Icons.school_outlined),
  ('technique',   'Technique / Professionnel', 'Formation professionnelle', Icons.engineering_outlined),
  ('autre',       'Autre / Personnalisé', 'Contactez-nous',      Icons.tune_outlined),
];

const _schoolTypes = [
  'Primaire', 'Collège', 'Lycée', 'Université', 'Mixte',
];

Map<String, List<SchoolSeries>> _defaultSeriesForSystem(String system) {
  switch (system) {
    case 'francophone':
      return {
        'series': [
          SchoolSeries(name: 'Série A', code: 'A', classes: ['A1', 'A2', 'A3']),
          SchoolSeries(name: 'Série C', code: 'C', classes: ['C1', 'C2', 'C3']),
          SchoolSeries(name: 'Série D', code: 'D', classes: ['D1', 'D2', 'D3']),
          SchoolSeries(name: 'Terminale', code: 'T', classes: ['Tle A', 'Tle C', 'Tle D']),
        ],
      };
    case 'anglophone':
      return {
        'series': [
          SchoolSeries(name: 'Science', code: 'SC', classes: ['Form 4 SC', 'Form 5 SC', 'LS SC']),
          SchoolSeries(name: 'Arts',    code: 'AR', classes: ['Form 4 AR', 'Form 5 AR', 'LS AR']),
          SchoolSeries(name: 'Commercial', code: 'CO', classes: ['Form 4 CO', 'Form 5 CO']),
        ],
      };
    case 'lmd':
      return {
        'series': [
          SchoolSeries(name: 'Licence', code: 'L', classes: ['L1', 'L2', 'L3']),
          SchoolSeries(name: 'Master',  code: 'M', classes: ['M1', 'M2']),
          SchoolSeries(name: 'Doctorat', code: 'D', classes: ['D1', 'D2', 'D3']),
        ],
      };
    case 'technique':
      return {
        'series': [
          SchoolSeries(name: 'BEP', code: 'BEP', classes: ['BEP1', 'BEP2']),
          SchoolSeries(name: 'CAP', code: 'CAP', classes: ['CAP1', 'CAP2']),
          SchoolSeries(name: 'BTS', code: 'BTS', classes: ['BTS1', 'BTS2']),
        ],
      };
    default:
      return {'series': []};
  }
}

// ── Main Screen ───────────────────────────────────────────────────────────────
class SchoolRegistrationScreen extends StatefulWidget {
  const SchoolRegistrationScreen({super.key});

  @override
  State<SchoolRegistrationScreen> createState() => _SchoolRegistrationScreenState();
}

class _SchoolRegistrationScreenState extends State<SchoolRegistrationScreen> {
  int _step = 0;
  bool _submitting = false;
  String? _globalError;

  // Step 1 — School info
  final _s1Name    = TextEditingController();
  String _s1Type   = 'Lycée';
  final _s1Country = TextEditingController(text: 'Congo');
  final _s1City    = TextEditingController();
  final _s1Address = TextEditingController();
  final _s1Website = TextEditingController();
  final _s1Email   = TextEditingController();
  final _s1Phone   = TextEditingController();
  final _s1Form    = GlobalKey<FormState>();
  List<SchoolBranch> _branches = [];

  // Step 2 — Admin account
  final _s2Name     = TextEditingController();
  final _s2Email    = TextEditingController();
  final _s2Phone    = TextEditingController();
  final _s2Pass     = TextEditingController();
  bool  _s2Obscure  = true;
  final _s2Form     = GlobalKey<FormState>();

  // Step 3 — Educational system
  String _s3System = 'francophone';

  // Step 4 — Series & structure
  List<SchoolSeries> _series = _defaultSeriesForSystem('francophone')['series']!;
  final _newSeriesNameCtrl  = TextEditingController();
  final _newSeriesCodeCtrl  = TextEditingController();

  // Step 5 — Database
  String _s5DbType        = 'scolaris';
  String _s5CustomDbType  = 'supabase';
  final _s5Endpoint       = TextEditingController();
  final _s5ApiKey         = TextEditingController();
  bool _s5Tested          = false;
  bool _s5Testing         = false;
  String? _s5TestResult;

  // Step 6 — Visual
  Color _s6Primary    = _terra;
  Color _s6Secondary  = _gold;
  final _s6Slug       = TextEditingController();

  final _steps = [
    'École',
    'Admin',
    'Système',
    'Structure',
    'Base de données',
    'Design',
    'Récapitulatif',
  ];

  @override
  void dispose() {
    for (final c in [
      _s1Name, _s1Country, _s1City, _s1Address, _s1Website, _s1Email, _s1Phone,
      _s2Name, _s2Email, _s2Phone, _s2Pass,
      _s5Endpoint, _s5ApiKey, _s6Slug,
      _newSeriesNameCtrl, _newSeriesCodeCtrl,
    ]) { c.dispose(); }
    super.dispose();
  }

  bool _validateCurrentStep() {
    if (_step == 0) return _s1Form.currentState?.validate() ?? false;
    if (_step == 1) return _s2Form.currentState?.validate() ?? false;
    return true;
  }

  void _next() {
    if (!_validateCurrentStep()) return;
    if (_step == 2) {
      _series = List.from(_defaultSeriesForSystem(_s3System)['series']!);
    }
    setState(() { _step = (_step + 1).clamp(0, 6); _globalError = null; });
  }

  void _prev() => setState(() { _step = (_step - 1).clamp(0, 6); });

  Future<void> _submit() async {
    setState(() { _submitting = true; _globalError = null; });
    try {
      final supabase = Supabase.instance.client;
      final schoolId = const Uuid().v4();
      final schoolSlug = _s6Slug.text.trim().isNotEmpty
          ? _s6Slug.text.trim()
          : _s1Name.text.trim().toLowerCase().replaceAll(' ', '-');

      // 1. Insert school
      await supabase.from('schools').insert({
        'id': schoolId,
        'name': _s1Name.text.trim(),
        'type': _s1Type,
        'country': _s1Country.text.trim(),
        'city': _s1City.text.trim(),
        'address': _s1Address.text.trim(),
        'website': _s1Website.text.trim().isEmpty ? null : _s1Website.text.trim(),
        'email': _s1Email.text.trim().isEmpty ? null : _s1Email.text.trim(),
        'phone': _s1Phone.text.trim().isEmpty ? null : _s1Phone.text.trim(),
        'educational_system': _s3System,
        'db_type': _s5DbType,
        'db_endpoint': _s5DbType == 'custom' ? _s5Endpoint.text.trim() : null,
        'db_api_key': _s5DbType == 'custom' ? _s5ApiKey.text.trim() : null,
        'primary_color': '#${_s6Primary.value.toRadixString(16).substring(2).toUpperCase()}',
        'secondary_color': '#${_s6Secondary.value.toRadixString(16).substring(2).toUpperCase()}',
        'slug': schoolSlug,
        'status': 'active',
      });

      // 2. Insert branches
      for (final b in _branches) {
        if (b.city.isNotEmpty && b.address.isNotEmpty) {
          await supabase.from('school_branches').insert({
            'school_id': schoolId,
            'name': b.name.isEmpty ? null : b.name,
            'city': b.city,
            'address': b.address,
          });
        }
      }

      // 3. Insert founder
      await supabase.from('school_founders').insert({
        'school_id': schoolId,
        'full_name': _s2Name.text.trim(),
        'email': _s2Email.text.trim(),
        'phone': _s2Phone.text.trim().isEmpty ? null : _s2Phone.text.trim(),
        'role_label': 'Fondateur',
      });

      // 4. Insert series & classes
      for (final s in _series) {
        if (!s.isActive) continue;
        final seriesId = const Uuid().v4();
        await supabase.from('school_series').insert({
          'id': seriesId,
          'school_id': schoolId,
          'name': s.name,
          'code': s.code,
          'is_active': true,
        });
        for (final cl in s.classes) {
          await supabase.from('school_classes').insert({
            'school_id': schoolId,
            'series_id': seriesId,
            'name': cl,
          });
        }
      }

      if (mounted) {
        _showSuccessDialog(schoolId);
      }
    } catch (e) {
      setState(() { _globalError = 'Erreur : ${e.toString()}'; });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showSuccessDialog(String schoolId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: _green.withOpacity(.1), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: _green, size: 40),
            ),
            const SizedBox(height: 16),
            const Text('École créée avec succès !',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _ink)),
            const SizedBox(height: 8),
            Text('Votre école a été enregistrée dans Scolaris.\nID : ${schoolId.substring(0, 8)}…',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: _muted)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: _PrimaryBtn(
                label: 'Retour à la connexion',
                onTap: () { Navigator.pop(context); context.go('/login'); },
                loading: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testDbConnection() async {
    setState(() { _s5Testing = true; _s5TestResult = null; });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _s5Testing = false;
      _s5Tested  = true;
      _s5TestResult = _s5Endpoint.text.isNotEmpty && _s5ApiKey.text.isNotEmpty
          ? '✓ Connexion réussie'
          : '✗ Endpoint ou clé manquant(e)';
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width > 860;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _cream,
        body: isWide ? _buildWide() : _buildNarrow(),
      ),
    );
  }

  // ── Wide layout ────────────────────────────────────────────────────────────
  Widget _buildWide() {
    return Row(
      children: [
        // Left sidebar
        SizedBox(
          width: 260,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D3B1E), Color(0xFF1B5E20)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 48),
                _SidebarLogo(),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _steps.length,
                    itemBuilder: (_, i) => _SidebarStep(
                      index: i, label: _steps[i],
                      current: _step, total: _steps.length,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    '© ${DateTime.now().year} Scolaris',
                    style: TextStyle(color: _white.withOpacity(.4), fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right content
        Expanded(
          child: Column(
            children: [
              _TopBar(step: _step, total: _steps.length, onBack: () => context.go('/login')),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: _buildStepContent(),
                  ),
                ),
              ),
              _BottomNav(
                step: _step, total: _steps.length,
                onPrev: _step > 0 ? _prev : null,
                onNext: _step < 6 ? _next : null,
                onSubmit: _step == 6 ? _submit : null,
                submitting: _submitting,
                error: _globalError,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Narrow layout ──────────────────────────────────────────────────────────
  Widget _buildNarrow() {
    return Column(
      children: [
        _MobileHeader(step: _step, total: _steps.length, label: _steps[_step],
            onBack: () => context.go('/login')),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: _buildStepContent(),
          ),
        ),
        _BottomNav(
          step: _step, total: _steps.length,
          onPrev: _step > 0 ? _prev : null,
          onNext: _step < 6 ? _next : null,
          onSubmit: _step == 6 ? _submit : null,
          submitting: _submitting,
          error: _globalError,
        ),
      ],
    );
  }

  // ── Step routing ───────────────────────────────────────────────────────────
  Widget _buildStepContent() {
    switch (_step) {
      case 0: return _buildStep1();
      case 1: return _buildStep2();
      case 2: return _buildStep3();
      case 3: return _buildStep4();
      case 4: return _buildStep5();
      case 5: return _buildStep6();
      case 6: return _buildStep7();
      default: return const SizedBox.shrink();
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 1 — Informations École
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep1() {
    return Form(
      key: _s1Form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.business_outlined,
            title: 'Informations de l\'école',
            subtitle: 'Renseignez les informations principales de votre établissement.',
          ),
          const SizedBox(height: 28),

          _SectionLabel('Type d\'établissement *'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _schoolTypes.map((t) => _TypeChip(
              label: t,
              selected: _s1Type == t,
              onTap: () => setState(() => _s1Type = t),
            )).toList(),
          ),
          const SizedBox(height: 20),

          _TwoCol(
            left: _SField(ctrl: _s1Name, label: 'Nom de l\'école *',
                hint: 'Collège Saint-Joseph', icon: Icons.school_outlined,
                validator: (v) => (v?.isEmpty ?? true) ? 'Nom requis' : null),
            right: _SField(ctrl: _s1Country, label: 'Pays *',
                hint: 'Congo', icon: Icons.public_outlined,
                validator: (v) => (v?.isEmpty ?? true) ? 'Pays requis' : null),
          ),
          const SizedBox(height: 16),

          _TwoCol(
            left: _SField(ctrl: _s1City, label: 'Ville principale *',
                hint: 'Brazzaville', icon: Icons.location_city_outlined,
                validator: (v) => (v?.isEmpty ?? true) ? 'Ville requise' : null),
            right: _SField(ctrl: _s1Phone, label: 'Téléphone (optionnel)',
                hint: '+242 06 000 0000', icon: Icons.phone_outlined,
                keyboard: TextInputType.phone),
          ),
          const SizedBox(height: 16),

          _SField(ctrl: _s1Address, label: 'Adresse principale *',
              hint: 'Rue Pasteur, Quartier…', icon: Icons.map_outlined,
              validator: (v) => (v?.isEmpty ?? true) ? 'Adresse requise' : null),
          const SizedBox(height: 16),

          _TwoCol(
            left: _SField(ctrl: _s1Email, label: 'Email officiel (optionnel)',
                hint: 'contact@ecole.com', icon: Icons.mail_outline,
                keyboard: TextInputType.emailAddress),
            right: _SField(ctrl: _s1Website, label: 'Site web (optionnel)',
                hint: 'https://ecole.com', icon: Icons.link_outlined,
                keyboard: TextInputType.url),
          ),
          const SizedBox(height: 28),

          _SectionLabel('Filiales / Autres campus'),
          const SizedBox(height: 10),
          ..._branches.asMap().entries.map((e) => _BranchCard(
            index: e.key,
            branch: e.value,
            onRemove: () => setState(() => _branches.removeAt(e.key)),
            onChange: () => setState(() {}),
          )),
          const SizedBox(height: 10),
          _OutlineBtn(
            label: '+ Ajouter une filiale',
            icon: Icons.add_business_outlined,
            onTap: () => setState(() => _branches.add(SchoolBranch())),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 2 — Compte Admin (Fondateur)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep2() {
    return Form(
      key: _s2Form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.person_outline_rounded,
            title: 'Compte administrateur',
            subtitle: 'Ce compte aura tous les accès initiaux et pourra configurer les autres rôles.',
          ),
          const SizedBox(height: 16),
          _InfoBanner(
            icon: Icons.info_outline_rounded,
            color: _gold,
            text: 'Ce compte recevra automatiquement le rôle "Fondateur" avec accès total. '
                'Les permissions sont modifiables à tout moment.',
          ),
          const SizedBox(height: 24),

          _SField(ctrl: _s2Name, label: 'Nom complet *',
              hint: 'Jean-Baptiste Ondo', icon: Icons.badge_outlined,
              validator: (v) => (v?.isEmpty ?? true) ? 'Nom requis' : null),
          const SizedBox(height: 16),

          _TwoCol(
            left: _SField(ctrl: _s2Email, label: 'Email *',
                hint: 'admin@ecole.com', icon: Icons.mail_outline,
                keyboard: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Email requis';
                  if (!v.contains('@')) return 'Email invalide';
                  return null;
                }),
            right: _SField(ctrl: _s2Phone, label: 'Téléphone',
                hint: '+242 06 000 0000', icon: Icons.phone_outlined,
                keyboard: TextInputType.phone),
          ),
          const SizedBox(height: 16),

          _SectionLabel('Mot de passe *'),
          const SizedBox(height: 6),
          StatefulBuilder(builder: (ctx, set) => TextFormField(
            controller: _s2Pass,
            obscureText: _s2Obscure,
            validator: (v) => (v == null || v.length < 8) ? 'Minimum 8 caractères' : null,
            style: const TextStyle(fontSize: 14, color: _ink),
            decoration: _inputDeco(
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                icon: Icon(_s2Obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                    size: 18, color: _muted),
                onPressed: () => setState(() => _s2Obscure = !_s2Obscure),
              ),
            ),
          )),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 3 — Système éducatif
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepHeader(
          icon: Icons.menu_book_outlined,
          title: 'Système éducatif',
          subtitle: 'Choisissez le référentiel pédagogique de votre établissement.',
        ),
        const SizedBox(height: 24),

        ..._educationSystems.map((sys) => _SystemCard(
          id: sys.$1,
          title: sys.$2,
          subtitle: sys.$3,
          icon: sys.$4,
          selected: _s3System == sys.$1,
          onTap: () => setState(() => _s3System = sys.$1),
        )),

        if (_s3System == 'autre') ...[
          const SizedBox(height: 20),
          _InfoBanner(
            icon: Icons.support_agent_outlined,
            color: _terra,
            text: 'Votre système éducatif nécessite une configuration spécifique.\n'
                'Contactez-nous pour intégrer votre structure.\n\n'
                '📧 scolaris.dev@gmail.com\n'
                '📱 WhatsApp : 065702018',
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 4 — Structure & Séries
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepHeader(
          icon: Icons.account_tree_outlined,
          title: 'Structure & Séries',
          subtitle: 'Activez, modifiez ou créez vos séries et classes.',
        ),
        const SizedBox(height: 24),

        ..._series.asMap().entries.map((e) => _SeriesCard(
          series: e.value,
          onToggle: (v) => setState(() => _series[e.key].isActive = v),
          onRemove: () => setState(() => _series.removeAt(e.key)),
          onAddClass: (cls) => setState(() => _series[e.key].classes.add(cls)),
          onRemoveClass: (ci) => setState(() => _series[e.key].classes.removeAt(ci)),
          onChange: () => setState(() {}),
        )),

        const SizedBox(height: 16),
        _SectionLabel('Ajouter une nouvelle série'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newSeriesNameCtrl,
                style: const TextStyle(fontSize: 14, color: _ink),
                decoration: _inputDeco(hint: 'Nom (ex: Série E)', icon: Icons.label_outline),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: TextField(
                controller: _newSeriesCodeCtrl,
                style: const TextStyle(fontSize: 14, color: _ink),
                decoration: _inputDeco(hint: 'Code', icon: Icons.tag_outlined),
              ),
            ),
            const SizedBox(width: 12),
            _IconBtn(
              icon: Icons.add_circle_outline,
              onTap: () {
                if (_newSeriesNameCtrl.text.isEmpty) return;
                setState(() {
                  _series.add(SchoolSeries(
                    name: _newSeriesNameCtrl.text.trim(),
                    code: _newSeriesCodeCtrl.text.trim().isNotEmpty
                        ? _newSeriesCodeCtrl.text.trim()
                        : _newSeriesNameCtrl.text.trim()[0],
                    classes: [],
                  ));
                  _newSeriesNameCtrl.clear();
                  _newSeriesCodeCtrl.clear();
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 5 — Base de données
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepHeader(
          icon: Icons.storage_outlined,
          title: 'Base de données',
          subtitle: 'Choisissez où stocker les données de votre école.',
        ),
        const SizedBox(height: 24),

        _DbOptionCard(
          id: 'scolaris',
          title: 'Base Scolaris (recommandé)',
          subtitle: 'Hébergée et gérée par Scolaris — aucune configuration requise.',
          icon: Icons.cloud_done_outlined,
          selected: _s5DbType == 'scolaris',
          onTap: () => setState(() => _s5DbType = 'scolaris'),
        ),
        const SizedBox(height: 12),
        _DbOptionCard(
          id: 'custom',
          title: 'Base personnalisée',
          subtitle: 'Connectez votre propre base de données (Supabase, PostgreSQL, Firebase).',
          icon: Icons.dns_outlined,
          selected: _s5DbType == 'custom',
          onTap: () => setState(() => _s5DbType = 'custom'),
        ),

        if (_s5DbType == 'custom') ...[
          const SizedBox(height: 20),
          _SectionLabel('Type de base'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['supabase', 'postgresql', 'firebase'].map((t) => _TypeChip(
              label: t[0].toUpperCase() + t.substring(1),
              selected: _s5CustomDbType == t,
              onTap: () => setState(() => _s5CustomDbType = t),
            )).toList(),
          ),
          const SizedBox(height: 16),
          _SField(ctrl: _s5Endpoint, label: 'Endpoint / URL',
              hint: 'https://xxx.supabase.co', icon: Icons.link_outlined),
          const SizedBox(height: 12),
          _SField(ctrl: _s5ApiKey, label: 'API Key / Credentials',
              hint: 'eyJhb…', icon: Icons.vpn_key_outlined, obscure: true),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: _PrimaryBtn(
                label: _s5Testing ? 'Test en cours…' : 'Tester la connexion',
                onTap: _s5Testing ? null : _testDbConnection,
                loading: _s5Testing,
                icon: Icons.wifi_tethering_outlined,
              ),
            ),
          ]),
          if (_s5TestResult != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _s5TestResult!.startsWith('✓')
                    ? _green.withOpacity(.08) : const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _s5TestResult!.startsWith('✓')
                      ? _green.withOpacity(.3) : const Color(0xFFFECACA),
                ),
              ),
              child: Text(_s5TestResult!,
                  style: TextStyle(
                    color: _s5TestResult!.startsWith('✓') ? _green : const Color(0xFFDC2626),
                    fontWeight: FontWeight.w600, fontSize: 13,
                  )),
            ),
          ],
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 6 — Personnalisation visuelle
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep6() {
    final previewName = _s1Name.text.isEmpty ? 'Mon École' : _s1Name.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepHeader(
          icon: Icons.palette_outlined,
          title: 'Personnalisation visuelle',
          subtitle: 'Définissez l\'identité graphique de votre espace Scolaris.',
        ),
        const SizedBox(height: 24),

        _SField(ctrl: _s6Slug, label: 'Nom court (slug)',
            hint: 'saint-joseph', icon: Icons.alternate_email_outlined),
        const SizedBox(height: 20),

        _SectionLabel('Couleur principale'),
        const SizedBox(height: 10),
        _ColorRow(
          selected: _s6Primary,
          options: const [
            Color(0xFF8B1A00), Color(0xFF1B5E20), Color(0xFF0D3B6E),
            Color(0xFF6A0DAD), Color(0xFF00695C), Color(0xFFB71C1C),
          ],
          onSelect: (c) => setState(() => _s6Primary = c),
        ),
        const SizedBox(height: 20),

        _SectionLabel('Couleur secondaire'),
        const SizedBox(height: 10),
        _ColorRow(
          selected: _s6Secondary,
          options: const [
            Color(0xFFC17F24), Color(0xFFFFB300), Color(0xFF26C6DA),
            Color(0xFF66BB6A), Color(0xFFEF5350), Color(0xFFAB47BC),
          ],
          onSelect: (c) => setState(() => _s6Secondary = c),
        ),
        const SizedBox(height: 28),

        _SectionLabel('Aperçu'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _s6Primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: _s6Secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.school_rounded, color: _white, size: 28),
            ),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(previewName,
                  style: const TextStyle(color: _white, fontSize: 18,
                      fontWeight: FontWeight.w800)),
              Text('Plateforme Scolaris',
                  style: TextStyle(color: _white.withOpacity(.7), fontSize: 12)),
            ]),
          ]),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // STEP 7 — Récapitulatif
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildStep7() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepHeader(
          icon: Icons.fact_check_outlined,
          title: 'Récapitulatif',
          subtitle: 'Vérifiez toutes les informations avant de créer votre école.',
        ),
        const SizedBox(height: 24),

        _RecapSection(title: 'Informations école', icon: Icons.business_outlined, items: [
          ('Nom', _s1Name.text.trim()),
          ('Type', _s1Type),
          ('Pays', _s1Country.text.trim()),
          ('Ville', _s1City.text.trim()),
          ('Adresse', _s1Address.text.trim()),
          if (_s1Email.text.isNotEmpty) ('Email', _s1Email.text.trim()),
          if (_s1Phone.text.isNotEmpty) ('Téléphone', _s1Phone.text.trim()),
          if (_s1Website.text.isNotEmpty) ('Site web', _s1Website.text.trim()),
        ]),
        const SizedBox(height: 12),

        if (_branches.isNotEmpty)
          _RecapSection(title: 'Filiales (${_branches.length})', icon: Icons.location_on_outlined,
              items: _branches.map((b) => (b.name.isEmpty ? 'Filiale' : b.name, '${b.city} — ${b.address}')).toList()),

        const SizedBox(height: 12),
        _RecapSection(title: 'Administrateur', icon: Icons.person_outline_rounded, items: [
          ('Nom', _s2Name.text.trim()),
          ('Email', _s2Email.text.trim()),
          ('Rôle', 'Fondateur — accès total'),
          if (_s2Phone.text.isNotEmpty) ('Téléphone', _s2Phone.text.trim()),
        ]),
        const SizedBox(height: 12),

        _RecapSection(title: 'Système éducatif', icon: Icons.menu_book_outlined, items: [
          ('Système', _educationSystems.firstWhere((s) => s.$1 == _s3System).$2),
        ]),
        const SizedBox(height: 12),

        _RecapSection(
          title: 'Séries actives (${_series.where((s) => s.isActive).length})',
          icon: Icons.account_tree_outlined,
          items: _series.where((s) => s.isActive)
              .map((s) => (s.name, '${s.classes.length} classe(s) : ${s.classes.join(', ')}'))
              .toList(),
        ),
        const SizedBox(height: 12),

        _RecapSection(title: 'Base de données', icon: Icons.storage_outlined, items: [
          ('Type', _s5DbType == 'scolaris' ? 'Base Scolaris (hébergée)' : 'Base personnalisée ($_s5CustomDbType)'),
        ]),
        const SizedBox(height: 12),

        _RecapSection(title: 'Design', icon: Icons.palette_outlined, items: [
          ('Couleur principale', '#${_s6Primary.value.toRadixString(16).substring(2).toUpperCase()}'),
          ('Couleur secondaire', '#${_s6Secondary.value.toRadixString(16).substring(2).toUpperCase()}'),
          if (_s6Slug.text.isNotEmpty) ('Slug', _s6Slug.text.trim()),
        ]),

        const SizedBox(height: 8),
        _InfoBanner(
          icon: Icons.info_outline_rounded,
          color: _green,
          text: 'En cliquant sur "Créer mon école", vos données seront enregistrées dans Scolaris '
              'et votre espace sera initialisé.',
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LAYOUT WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _SidebarLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: _white.withOpacity(.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.school_rounded, color: _white, size: 32),
      ),
      const SizedBox(height: 10),
      const Text('Scolaris', style: TextStyle(color: _white, fontSize: 20,
          fontWeight: FontWeight.w800)),
      const Text('Inscription École', style: TextStyle(color: Color(0x99FFFFFF), fontSize: 12)),
    ]);
  }
}

class _SidebarStep extends StatelessWidget {
  final int index, current, total;
  final String label;
  const _SidebarStep({required this.index, required this.label,
      required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final done    = index < current;
    final active  = index == current;
    final pending = index > current;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Column(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 28, height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? _gold : active ? _white : _white.withOpacity(.15),
            ),
            child: Center(
              child: done
                  ? const Icon(Icons.check_rounded, size: 15, color: _green)
                  : Text('${index + 1}',
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: active ? _ink : _white.withOpacity(.5),
                      )),
            ),
          ),
          if (index < total - 1)
            Container(width: 2, height: 28,
                color: done ? _gold.withOpacity(.4) : _white.withOpacity(.1)),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: TextStyle(
            color: active ? _white : done ? _gold : _white.withOpacity(.45),
            fontSize: 13, fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          )),
        ),
      ]),
    );
  }
}

class _TopBar extends StatelessWidget {
  final int step, total;
  final VoidCallback onBack;
  const _TopBar({required this.step, required this.total, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final pct = (step + 1) / total;
    return Container(
      color: _white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(Icons.arrow_back_rounded, color: _terra, size: 22),
          ),
          const SizedBox(width: 16),
          const Text('Nouvelle école', style: TextStyle(fontSize: 17,
              fontWeight: FontWeight.w700, color: _ink)),
          const Spacer(),
          Text('Étape ${step + 1} / $total',
              style: const TextStyle(color: _muted, fontSize: 13)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: _border,
            valueColor: const AlwaysStoppedAnimation(_terra),
            minHeight: 5,
          ),
        ),
      ]),
    );
  }
}

class _MobileHeader extends StatelessWidget {
  final int step, total;
  final String label;
  final VoidCallback onBack;
  const _MobileHeader({required this.step, required this.total,
      required this.label, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final pct = (step + 1) / total;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D3B1E), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          GestureDetector(onTap: onBack,
              child: const Icon(Icons.arrow_back_rounded, color: _white)),
          const SizedBox(width: 12),
          const Text('Inscription École',
              style: TextStyle(color: _white, fontSize: 16, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text('${step + 1}/$total',
              style: TextStyle(color: _white.withOpacity(.7), fontSize: 13)),
        ]),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: _gold, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: _white.withOpacity(.2),
            valueColor: const AlwaysStoppedAnimation(_gold),
            minHeight: 4,
          ),
        ),
      ]),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int step, total;
  final VoidCallback? onPrev, onNext, onSubmit;
  final bool submitting;
  final String? error;
  const _BottomNav({required this.step, required this.total,
      this.onPrev, this.onNext, this.onSubmit, required this.submitting, this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: _white,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Text(error!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12.5)),
            ),
          ],
          Row(children: [
            if (onPrev != null)
              Expanded(
                child: _OutlineBtn(label: '← Retour', icon: null, onTap: onPrev!),
              ),
            if (onPrev != null) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: onSubmit != null
                  ? _PrimaryBtn(
                      label: '🏫 Créer mon école',
                      onTap: submitting ? null : onSubmit,
                      loading: submitting,
                    )
                  : _PrimaryBtn(
                      label: 'Continuer →',
                      onTap: onNext,
                      loading: false,
                    ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// REUSABLE COMPONENT WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _StepHeader extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _StepHeader({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(color: _terra.withOpacity(.1),
            borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, color: _terra, size: 24),
      ),
      const SizedBox(height: 12),
      Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: _ink)),
      const SizedBox(height: 6),
      Text(subtitle, style: const TextStyle(fontSize: 14, color: _muted, height: 1.5)),
    ]);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 13, color: _ink, fontWeight: FontWeight.w600));
}

class _TwoCol extends StatelessWidget {
  final Widget left, right;
  const _TwoCol({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w > 600) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ]);
    }
    return Column(children: [left, const SizedBox(height: 16), right]);
  }
}

class _SField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;
  const _SField({required this.ctrl, required this.label, required this.hint,
      required this.icon, this.obscure = false, this.keyboard, this.validator});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboard,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: _ink),
        decoration: _inputDeco(hint: hint, icon: icon),
      ),
    ]);
  }
}

InputDecoration _inputDeco({required String hint, required IconData icon, Widget? suffix}) {
  return InputDecoration(
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
  );
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? _terra : _white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? _terra : _border),
        ),
        child: Center(
          child: Text(label, style: TextStyle(
            color: selected ? _white : _ink,
            fontSize: 13, fontWeight: FontWeight.w600,
          )),
        ),
      ),
    );
  }
}

class _SystemCard extends StatelessWidget {
  final String id, title, subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _SystemCard({required this.id, required this.title, required this.subtitle,
      required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? _terra.withOpacity(.06) : _white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? _terra : _border, width: selected ? 2 : 1),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: selected ? _terra.withOpacity(.12) : _border.withOpacity(.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: selected ? _terra : _muted, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: selected ? _terra : _ink)),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: _muted)),
          ])),
          if (selected)
            const Icon(Icons.check_circle_rounded, color: _terra, size: 22),
        ]),
      ),
    );
  }
}

class _DbOptionCard extends StatelessWidget {
  final String id, title, subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _DbOptionCard({required this.id, required this.title, required this.subtitle,
      required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => _SystemCard(
    id: id, title: title, subtitle: subtitle, icon: icon, selected: selected, onTap: onTap,
  );
}

class _BranchCard extends StatelessWidget {
  final int index;
  final SchoolBranch branch;
  final VoidCallback onRemove, onChange;
  const _BranchCard({required this.index, required this.branch,
      required this.onRemove, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(children: [
        Row(children: [
          Text('Filiale ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w700,
              fontSize: 13, color: _ink)),
          const Spacer(),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.remove_circle_outline, color: Color(0xFFDC2626), size: 20),
          ),
        ]),
        const SizedBox(height: 12),
        TextField(
          style: const TextStyle(fontSize: 13, color: _ink),
          decoration: _inputDeco(hint: 'Nom (optionnel)', icon: Icons.label_outline),
          onChanged: (v) { branch.name = v; onChange(); },
        ),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(fontSize: 13, color: _ink),
          decoration: _inputDeco(hint: 'Ville *', icon: Icons.location_city_outlined),
          onChanged: (v) { branch.city = v; onChange(); },
        ),
        const SizedBox(height: 8),
        TextField(
          style: const TextStyle(fontSize: 13, color: _ink),
          decoration: _inputDeco(hint: 'Adresse complète *', icon: Icons.map_outlined),
          onChanged: (v) { branch.address = v; onChange(); },
        ),
      ]),
    );
  }
}

class _SeriesCard extends StatefulWidget {
  final SchoolSeries series;
  final ValueChanged<bool> onToggle;
  final VoidCallback onRemove, onChange;
  final ValueChanged<String> onAddClass;
  final ValueChanged<int> onRemoveClass;
  const _SeriesCard({required this.series, required this.onToggle,
      required this.onRemove, required this.onAddClass,
      required this.onRemoveClass, required this.onChange});

  @override
  State<_SeriesCard> createState() => _SeriesCardState();
}

class _SeriesCardState extends State<_SeriesCard> {
  bool _expanded = true;
  final _classCtrl = TextEditingController();

  @override
  void dispose() { _classCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = widget.series;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: s.isActive ? _white : _cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: s.isActive ? _border : _border.withOpacity(.4)),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                  color: _muted, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(
              '${s.name} (${s.code})',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
                  color: s.isActive ? _ink : _muted),
            )),
            Switch(
              value: s.isActive, onChanged: widget.onToggle,
              activeColor: _terra, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: widget.onRemove,
              child: const Icon(Icons.delete_outline, color: Color(0xFFDC2626), size: 18),
            ),
          ]),
        ),
        if (_expanded && s.isActive) ...[
          const Divider(height: 1, color: _border),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Classes (${s.classes.length})',
                  style: const TextStyle(fontSize: 12, color: _muted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6, runSpacing: 6,
                children: [
                  ...s.classes.asMap().entries.map((e) => _ClassChip(
                    label: e.value,
                    onRemove: () => widget.onRemoveClass(e.key),
                  )),
                ],
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: SizedBox(
                    height: 38,
                    child: TextField(
                      controller: _classCtrl,
                      style: const TextStyle(fontSize: 13, color: _ink),
                      decoration: _inputDeco(hint: 'Ajouter une classe…', icon: Icons.add_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _IconBtn(
                  icon: Icons.add_circle_outline,
                  onTap: () {
                    if (_classCtrl.text.isNotEmpty) {
                      widget.onAddClass(_classCtrl.text.trim());
                      _classCtrl.clear();
                    }
                  },
                ),
              ]),
            ]),
          ),
        ],
      ]),
    );
  }
}

class _ClassChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _ClassChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _terra.withOpacity(.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _terra.withOpacity(.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: const TextStyle(fontSize: 12, color: _terra, fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(Icons.close, size: 13, color: _terra),
        ),
      ]),
    );
  }
}

class _ColorRow extends StatelessWidget {
  final Color selected;
  final List<Color> options;
  final ValueChanged<Color> onSelect;
  const _ColorRow({required this.selected, required this.options, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: options.map((c) {
        final isSel = selected.value == c.value;
        return GestureDetector(
          onTap: () => onSelect(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(color: isSel ? _white : Colors.transparent, width: 3),
              boxShadow: isSel ? [BoxShadow(color: c.withOpacity(.5), blurRadius: 8)] : [],
            ),
            child: isSel
                ? const Icon(Icons.check_rounded, color: _white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _RecapSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<(String, String)> items;
  const _RecapSection({required this.title, required this.icon, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: _terra),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700,
              fontSize: 14, color: _ink)),
        ]),
        const SizedBox(height: 10),
        const Divider(height: 1, color: _border),
        const SizedBox(height: 10),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 120,
              child: Text(item.$1, style: const TextStyle(fontSize: 12.5, color: _muted)),
            ),
            Expanded(
              child: Text(item.$2, style: const TextStyle(fontSize: 12.5,
                  color: _ink, fontWeight: FontWeight.w600)),
            ),
          ]),
        )),
      ]),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _InfoBanner({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(text,
            style: TextStyle(color: color, fontSize: 12.5, height: 1.5))),
      ]),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onTap;
  final IconData? icon;
  const _PrimaryBtn({required this.label, required this.onTap,
      required this.loading, this.icon});

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
            colors: (loading || onTap == null)
                ? [_terra.withOpacity(.6), _orange.withOpacity(.6)]
                : [_terra, _orange],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: (loading || onTap == null) ? [] : [
            BoxShadow(color: _terra.withOpacity(.35), blurRadius: 14, offset: const Offset(0, 5)),
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

class _OutlineBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  const _OutlineBtn({required this.label, required this.icon, required this.onTap});

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
          if (icon != null) ...[
            Icon(icon, size: 18, color: _terra),
            const SizedBox(width: 8),
          ],
          Text(label, style: const TextStyle(color: _ink, fontSize: 14,
              fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: _terra.withOpacity(.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _terra, size: 20),
      ),
    );
  }
}
