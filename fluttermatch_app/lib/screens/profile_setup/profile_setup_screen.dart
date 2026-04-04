import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../main_shell.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _pageController = PageController();
  int _step = 0;

  // Step 1
  int? _age;
  String? _gender;
  final _cityCtrl = TextEditingController();

  // Step 2
  final _bioCtrl = TextEditingController();
  final _selectedInterests = <String>[];

  // Step 3
  String? _interestedIn;
  RangeValues _ageRange = const RangeValues(18, 50);
  double _maxDistance = 50;

  // Step 4
  final _photos = <XFile>[];
  bool _saving = false;

  static const _allInterests = [
    'Music', 'Sports', 'Travel', 'Food & Drink', 'Gaming',
    'Reading', 'Movies', 'Fitness', 'Art', 'Cooking',
    'Dancing', 'Yoga', 'Hiking', 'Photography', 'Fashion',
    'Tech', 'Pets', 'Coffee', 'Surfing', 'Running',
  ];

  bool get _step1Ok =>
      _age != null && _age! >= 18 && _gender != null && _cityCtrl.text.trim().isNotEmpty;
  bool get _step2Ok => _bioCtrl.text.trim().length >= 10;
  bool get _step3Ok => _interestedIn != null;
  bool get _step4Ok => _photos.isNotEmpty;
  bool get _canProceed => [_step1Ok, _step2Ok, _step3Ok, _step4Ok][_step];

  void _next() => _pageController.nextPage(
      duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);

  void _back() => _pageController.previousPage(
      duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);

  Future<void> _pickPhoto() async {
    if (_photos.length >= 6) return;
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) setState(() => _photos.add(file));
  }

  Future<void> _save() async {
    if (!_step4Ok) return;
    setState(() => _saving = true);
    try {
      await ref.read(profileProvider.notifier).updateProfile({
        'age': _age,
        'gender': _gender,
        'city': _cityCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
        'interests': _selectedInterests,
        'interested_in': _interestedIn,
        'min_age': _ageRange.start.toInt(),
        'max_age': _ageRange.end.toInt(),
        'max_distance': _maxDistance.toInt(),
      });
      for (final photo in _photos) {
        await ref.read(profileProvider.notifier).uploadPhoto(photo.path);
      }
      await ref.read(authProvider.notifier).refreshUser();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cityCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Gradient background ────────────────────────────────────────────
          const GlassBackground(child: SizedBox.expand()),

          // ── Decorative blobs ───────────────────────────────────────────────
          const Positioned(top: -60, right: -50, child: GlassBlob(size: 220, opacity: 0.11)),
          const Positioned(bottom: 120, left: -60, child: GlassBlob(size: 160, opacity: 0.09)),

          SafeArea(
            child: Column(
              children: [
                // ── Header with progress ───────────────────────────────────
                _GlassHeader(step: _step, total: 4, primary: primary, onSurface: onSurface,
                    onSurfaceVariant: onSurfaceVariant),

                // ── Page content ───────────────────────────────────────────
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (i) => setState(() => _step = i),
                    children: [
                      _Step1(
                        age: _age, gender: _gender, cityCtrl: _cityCtrl,
                        onAge: (v) => setState(() => _age = v),
                        onGender: (v) => setState(() => _gender = v),
                        onCityChange: (_) => setState(() {}),
                        primary: primary, onSurface: onSurface,
                        onSurfaceVariant: onSurfaceVariant,
                      ),
                      _Step2(
                        bioCtrl: _bioCtrl,
                        selected: _selectedInterests,
                        all: _allInterests,
                        onToggle: (v) {
                          setState(() {
                            _selectedInterests.contains(v)
                                ? _selectedInterests.remove(v)
                                : _selectedInterests.length < 10
                                    ? _selectedInterests.add(v)
                                    : null;
                          });
                        },
                        onBioChange: (_) => setState(() {}),
                        primary: primary, onSurface: onSurface,
                        onSurfaceVariant: onSurfaceVariant,
                      ),
                      _Step3(
                        interestedIn: _interestedIn,
                        ageRange: _ageRange,
                        maxDistance: _maxDistance,
                        onInterested: (v) => setState(() => _interestedIn = v),
                        onRange: (v) => setState(() => _ageRange = v),
                        onDist: (v) => setState(() => _maxDistance = v),
                        primary: primary, onSurface: onSurface,
                        onSurfaceVariant: onSurfaceVariant,
                      ),
                      _Step4(
                        photos: _photos,
                        onAdd: _pickPhoto,
                        onRemove: (i) => setState(() => _photos.removeAt(i)),
                        primary: primary, onSurfaceVariant: onSurfaceVariant,
                      ),
                    ],
                  ),
                ),

                // ── Glass Nav Bar ──────────────────────────────────────────
                _GlassNavBar(
                  step: _step,
                  canProceed: _canProceed,
                  isLast: _step == 3,
                  saving: _saving,
                  onNext: _next,
                  onBack: _back,
                  onSave: _save,
                  primary: primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Glass Header with Progress ────────────────────────────────────────────────

class _GlassHeader extends StatelessWidget {
  final int step, total;
  final Color primary, onSurface, onSurfaceVariant;

  static const _titles = ['Basic Info', 'About You', 'Preferences', 'Photos'];
  static const _emojis = ['👤', '✨', '💝', '📸'];

  const _GlassHeader({
    required this.step, required this.total,
    required this.primary, required this.onSurface, required this.onSurfaceVariant,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress dots / pills
            Row(
              children: List.generate(total, (i) {
                final active = i == step;
                final done = i < step;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: done
                          ? primary.withValues(alpha: 0.55)
                          : active
                              ? primary
                              : primary.withValues(alpha: 0.15),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${_emojis[step]}  ${_titles[step]}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${step + 1} / $total',
                    style: TextStyle(
                      color: primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─── Glass Nav Bar ────────────────────────────────────────────────────────────

class _GlassNavBar extends StatelessWidget {
  final int step;
  final bool canProceed, isLast, saving;
  final VoidCallback onNext, onBack, onSave;
  final Color primary;

  const _GlassNavBar({
    required this.step, required this.canProceed, required this.isLast,
    required this.saving, required this.onNext, required this.onBack,
    required this.onSave, required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Row(
        children: [
          if (step > 0) ...[
            GlassCard(
              borderRadius: 14,
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: primary),
                      const SizedBox(width: 6),
                      Text('Back', style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: GradientButton(
              onPressed: canProceed ? (isLast ? onSave : onNext) : null,
              child: saving
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLast ? 'Complete Setup' : 'Continue',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        if (!isLast) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 1 — Basic Info ──────────────────────────────────────────────────────

class _Step1 extends StatelessWidget {
  final int? age;
  final String? gender;
  final TextEditingController cityCtrl;
  final ValueChanged<int?> onAge;
  final ValueChanged<String?> onGender;
  final ValueChanged<String> onCityChange;
  final Color primary, onSurface, onSurfaceVariant;

  static const _genders = [
    ('male', 'Man', Icons.male_rounded),
    ('female', 'Woman', Icons.female_rounded),
    ('non_binary', 'Non-binary', Icons.people_outline),
    ('other', 'Other', Icons.person_outline),
  ];

  const _Step1({
    required this.age, required this.gender, required this.cityCtrl,
    required this.onAge, required this.onGender, required this.onCityChange,
    required this.primary, required this.onSurface, required this.onSurfaceVariant,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Age
          GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('How old are you?', onSurface),
                const SizedBox(height: 12),
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (v) => onAge(int.tryParse(v)),
                  decoration: _inputDeco('Your age', suffixText: 'years', primary: primary),
                ),
                if (age != null && age! < 18)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Must be at least 18',
                        style: TextStyle(color: Colors.red.shade400, fontSize: 12)),
                  ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.12, end: 0),

          const SizedBox(height: 16),

          // Gender
          GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel("What's your gender?", onSurface),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10, runSpacing: 10,
                  children: _genders.map((g) {
                    final selected = gender == g.$1;
                    return GestureDetector(
                      onTap: () => onGender(g.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                        decoration: BoxDecoration(
                          color: selected ? primary : primary.withValues(alpha: 0.06),
                          border: Border.all(
                              color: selected ? primary : primary.withValues(alpha: 0.2)),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(g.$3, size: 16,
                              color: selected ? Colors.white : primary.withValues(alpha: 0.7)),
                          const SizedBox(width: 6),
                          Text(g.$2,
                              style: TextStyle(
                                  color: selected ? Colors.white : onSurface.withValues(alpha: 0.75),
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.12, end: 0),

          const SizedBox(height: 16),

          // City
          GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('Where are you based?', onSurface),
                const SizedBox(height: 12),
                TextField(
                  controller: cityCtrl,
                  onChanged: onCityChange,
                  decoration: _inputDeco('City or town', primary: primary),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.12, end: 0),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Step 2 — About You ───────────────────────────────────────────────────────

class _Step2 extends StatelessWidget {
  final TextEditingController bioCtrl;
  final List<String> selected, all;
  final ValueChanged<String> onToggle, onBioChange;
  final Color primary, onSurface, onSurfaceVariant;

  const _Step2({
    required this.bioCtrl, required this.selected, required this.all,
    required this.onToggle, required this.onBioChange,
    required this.primary, required this.onSurface, required this.onSurfaceVariant,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio
          GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel('Write a short bio', onSurface),
                const SizedBox(height: 4),
                Text('At least 10 characters',
                    style: TextStyle(color: onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 12),
                TextField(
                  controller: bioCtrl,
                  maxLines: 5,
                  maxLength: 500,
                  onChanged: onBioChange,
                  decoration: _inputDeco('I love hiking, good coffee and...', primary: primary),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.12, end: 0),

          const SizedBox(height: 16),

          // Interests
          GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _sectionLabel('Interests', onSurface),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('${selected.length}/10',
                        style: TextStyle(color: primary, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 4),
                Text('Pick up to 10 things you enjoy',
                    style: TextStyle(color: onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: all.map((interest) {
                    final isOn = selected.contains(interest);
                    final maxed = selected.length >= 10 && !isOn;
                    return GestureDetector(
                      onTap: maxed ? null : () => onToggle(interest),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isOn
                              ? primary
                              : maxed
                                  ? primary.withValues(alpha: 0.03)
                                  : primary.withValues(alpha: 0.06),
                          border: Border.all(
                              color: isOn
                                  ? primary
                                  : primary.withValues(alpha: maxed ? 0.08 : 0.2)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(interest,
                            style: TextStyle(
                              color: isOn
                                  ? Colors.white
                                  : maxed
                                      ? onSurface.withValues(alpha: 0.3)
                                      : onSurface.withValues(alpha: 0.75),
                              fontSize: 13,
                              fontWeight: isOn ? FontWeight.w600 : FontWeight.w400,
                            )),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.12, end: 0),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Step 3 — Preferences ─────────────────────────────────────────────────────

class _Step3 extends StatelessWidget {
  final String? interestedIn;
  final RangeValues ageRange;
  final double maxDistance;
  final ValueChanged<String> onInterested;
  final ValueChanged<RangeValues> onRange;
  final ValueChanged<double> onDist;
  final Color primary, onSurface, onSurfaceVariant;

  const _Step3({
    required this.interestedIn, required this.ageRange, required this.maxDistance,
    required this.onInterested, required this.onRange, required this.onDist,
    required this.primary, required this.onSurface, required this.onSurfaceVariant,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Interested In
          GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel("I'm interested in", onSurface),
                const SizedBox(height: 14),
                Row(children: [
                  _GlassPill(label: 'Men', value: 'male', selected: interestedIn,
                      onTap: onInterested, primary: primary, onSurface: onSurface),
                  const SizedBox(width: 10),
                  _GlassPill(label: 'Women', value: 'female', selected: interestedIn,
                      onTap: onInterested, primary: primary, onSurface: onSurface),
                  const SizedBox(width: 10),
                  _GlassPill(label: 'Everyone', value: 'everyone', selected: interestedIn,
                      onTap: onInterested, primary: primary, onSurface: onSurface),
                ]),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.12, end: 0),

          const SizedBox(height: 16),

          // Sliders
          GlassCard(
            borderRadius: 20,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Age Range
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionLabel('Age range', onSurface),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${ageRange.start.toInt()} – ${ageRange.end.toInt()}',
                        style: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                RangeSlider(
                  values: ageRange, min: 18, max: 99, divisions: 81,
                  activeColor: primary,
                  onChanged: onRange,
                ),

                const SizedBox(height: 16),

                // Distance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionLabel('Maximum distance', onSurface),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${maxDistance.toInt()} km',
                        style: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Slider(
                  value: maxDistance, min: 1, max: 200, divisions: 199,
                  activeColor: primary,
                  onChanged: onDist,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.12, end: 0),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Interest / Gender Pill ───────────────────────────────────────────────────

class _GlassPill extends StatelessWidget {
  final String label, value;
  final String? selected;
  final ValueChanged<String> onTap;
  final Color primary, onSurface;

  const _GlassPill({
    required this.label, required this.value, required this.selected,
    required this.onTap, required this.primary, required this.onSurface,
  });

  @override
  Widget build(BuildContext context) {
    final on = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: on ? primary : primary.withValues(alpha: 0.06),
            border: Border.all(color: on ? primary : primary.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: on ? Colors.white : onSurface.withValues(alpha: 0.75),
                    fontWeight: on ? FontWeight.w700 : FontWeight.w500)),
          ),
        ),
      ),
    );
  }
}

// ─── Step 4 — Photos ──────────────────────────────────────────────────────────

class _Step4 extends StatelessWidget {
  final List<XFile> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final Color primary, onSurfaceVariant;

  const _Step4({
    required this.photos, required this.onAdd, required this.onRemove,
    required this.primary, required this.onSurfaceVariant,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Icon(Icons.photo_library_rounded, color: primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Add at least 1 photo. The first one will be your main photo.',
                  style: TextStyle(color: onSurfaceVariant, fontSize: 13),
                ),
              ),
            ]),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 16),

          Expanded(
            child: GridView.builder(
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (ctx, i) {
                final hasPhoto = i < photos.length;
                final isNextSlot = i == photos.length;

                return GestureDetector(
                  onTap: isNextSlot ? onAdd : null,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: hasPhoto
                              ? Colors.transparent
                              : primary.withValues(alpha: isNextSlot ? 0.08 : 0.04),
                          border: Border.all(
                            color: isNextSlot && !hasPhoto
                                ? primary.withValues(alpha: 0.40)
                                : primary.withValues(alpha: 0.12),
                            width: isNextSlot && !hasPhoto ? 1.5 : 1,
                          ),
                          image: hasPhoto
                              ? DecorationImage(
                                  image: FileImage(File(photos[i].path)),
                                  fit: BoxFit.cover)
                              : null,
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (!hasPhoto)
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      color: isNextSlot
                                          ? primary
                                          : primary.withValues(alpha: 0.25),
                                      size: 28,
                                    ),
                                    if (i == 0 && isNextSlot) ...[
                                      const SizedBox(height: 4),
                                      Text('Main',
                                          style: TextStyle(
                                              color: primary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ],
                                ),
                              ),

                            // Delete button
                            if (hasPhoto)
                              Positioned(
                                top: 6, right: 6,
                                child: GestureDetector(
                                  onTap: () => onRemove(i),
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                        color: Colors.black54, shape: BoxShape.circle),
                                    child: const Icon(Icons.close, color: Colors.white, size: 13),
                                  ),
                                ),
                              ),

                            // Main badge
                            if (i == 0 && hasPhoto)
                              Positioned(
                                bottom: 6, left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [primary, Color.lerp(primary, Colors.pink, 0.5)!]),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Main',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 80 * i));
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

Widget _sectionLabel(String text, Color onSurface) => Text(
      text,
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: onSurface),
    );

InputDecoration _inputDeco(String hint, {String? suffixText, required Color primary}) =>
    InputDecoration(
      hintText: hint,
      suffixText: suffixText,
      filled: true,
      fillColor: primary.withValues(alpha: 0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary.withValues(alpha: 0.18)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary.withValues(alpha: 0.18)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
