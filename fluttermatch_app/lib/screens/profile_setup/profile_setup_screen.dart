import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  static const _pink = Color(0xFFE84393);
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
    'Music',
    'Sports',
    'Travel',
    'Food & Drink',
    'Gaming',
    'Reading',
    'Movies',
    'Fitness',
    'Art',
    'Cooking',
    'Dancing',
    'Yoga',
    'Hiking',
    'Photography',
    'Fashion',
    'Tech',
    'Pets',
    'Coffee',
    'Surfing',
    'Running',
  ];

  bool get _step1Ok =>
      _age != null &&
      _age! >= 18 &&
      _gender != null &&
      _cityCtrl.text.trim().isNotEmpty;
  bool get _step2Ok => _bioCtrl.text.trim().length >= 10;
  bool get _step3Ok => _interestedIn != null;
  bool get _step4Ok => _photos.isNotEmpty;

  bool get _canProceed => [_step1Ok, _step2Ok, _step3Ok, _step4Ok][_step];

  void _next() => _pageController.nextPage(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );

  void _back() => _pageController.previousPage(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );

  Future<void> _pickPhoto() async {
    if (_photos.length >= 6) return;
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) setState(() => _photos.add(file));
  }

  Future<void> _save() async {
    if (!_step4Ok) return;
    setState(() => _saving = true);

    try {
      final ok = await ref.read(profileProvider.notifier).updateProfile({
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

      if (!ok) throw Exception('Could not save profile');

      for (final photo in _photos) {
        await ref.read(profileProvider.notifier).uploadPhoto(photo.path);
      }

      // Refresh auth user so profile_complete flag updates
      await ref.read(authProvider.notifier).refreshUser();
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _Header(step: _step, total: 4),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _step = i),
                children: [
                  _Step1(
                    age: _age,
                    gender: _gender,
                    cityCtrl: _cityCtrl,
                    onAge: (v) => setState(() => _age = v),
                    onGender: (v) => setState(() => _gender = v),
                    onCityChange: (_) => setState(() {}),
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
                  ),
                  _Step3(
                    interestedIn: _interestedIn,
                    ageRange: _ageRange,
                    maxDistance: _maxDistance,
                    onInterested: (v) => setState(() => _interestedIn = v),
                    onRange: (v) => setState(() => _ageRange = v),
                    onDist: (v) => setState(() => _maxDistance = v),
                  ),
                  _Step4(
                    photos: _photos,
                    onAdd: _pickPhoto,
                    onRemove: (i) => setState(() => _photos.removeAt(i)),
                  ),
                ],
              ),
            ),
            _NavBar(
              step: _step,
              canProceed: _canProceed,
              isLast: _step == 3,
              saving: _saving,
              onNext: _next,
              onBack: _back,
              onSave: _save,
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Header
// ──────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final int step;
  final int total;

  const _Header({required this.step, required this.total});

  static const _titles = ['Basic Info', 'About You', 'Preferences', 'Photos'];
  static const _pink = Color(0xFFE84393);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(total, (i) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: i <= step ? _pink : Colors.grey.shade200,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Text(
            'Step ${step + 1} of $total',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _titles[step],
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Nav Bar
// ──────────────────────────────────────────────────────────────
class _NavBar extends StatelessWidget {
  final int step;
  final bool canProceed, isLast, saving;
  final VoidCallback onNext, onBack, onSave;

  static const _pink = Color(0xFFE84393);

  const _NavBar({
    required this.step,
    required this.canProceed,
    required this.isLast,
    required this.saving,
    required this.onNext,
    required this.onBack,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Row(
        children: [
          if (step > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: _pink),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(color: _pink, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canProceed ? (isLast ? onSave : onNext) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _pink,
                disabledBackgroundColor: Colors.grey.shade200,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isLast ? 'Complete Setup' : 'Continue',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Step 1 — Basic Info
// ──────────────────────────────────────────────────────────────
class _Step1 extends StatelessWidget {
  final int? age;
  final String? gender;
  final TextEditingController cityCtrl;
  final ValueChanged<int?> onAge;
  final ValueChanged<String?> onGender;
  final ValueChanged<String> onCityChange;

  static const _pink = Color(0xFFE84393);
  static const _genders = [
    ('male', 'Man', Icons.male_rounded),
    ('female', 'Woman', Icons.female_rounded),
    ('non_binary', 'Non-binary', Icons.people_outline),
    ('other', 'Other', Icons.person_outline),
  ];

  const _Step1({
    required this.age,
    required this.gender,
    required this.cityCtrl,
    required this.onAge,
    required this.onGender,
    required this.onCityChange,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('How old are you?'),
          const SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.number,
            onChanged: (v) => onAge(int.tryParse(v)),
            decoration: _inputDeco('Your age', suffix: 'years'),
          ),
          if (age != null && age! < 18)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Must be at least 18',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 24),
          _label("What's your gender?"),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _genders.map((g) {
              final selected = gender == g.$1;
              return GestureDetector(
                onTap: () => onGender(g.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? _pink : Colors.white,
                    border: Border.all(
                      color: selected ? _pink : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        g.$3,
                        size: 16,
                        color: selected ? Colors.white : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        g.$2,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.grey.shade700,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _label('Where are you based?'),
          const SizedBox(height: 8),
          TextField(
            controller: cityCtrl,
            onChanged: onCityChange,
            decoration: _inputDeco('City or town'),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Step 2 — About You
// ──────────────────────────────────────────────────────────────
class _Step2 extends StatelessWidget {
  final TextEditingController bioCtrl;
  final List<String> selected;
  final List<String> all;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onBioChange;

  static const _pink = Color(0xFFE84393);

  const _Step2({
    required this.bioCtrl,
    required this.selected,
    required this.all,
    required this.onToggle,
    required this.onBioChange,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Write a short bio'),
          Text(
            'At least 10 characters',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: bioCtrl,
            maxLines: 5,
            maxLength: 500,
            onChanged: onBioChange,
            decoration: _inputDeco('I love hiking, good coffee and...'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _label('Interests'),
              const Spacer(),
              Text(
                '${selected.length}/10',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Pick up to 10 things you enjoy',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: all.map((interest) {
              final isOn = selected.contains(interest);
              final maxed = selected.length >= 10 && !isOn;
              return GestureDetector(
                onTap: maxed ? null : () => onToggle(interest),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isOn
                        ? _pink
                        : maxed
                        ? Colors.grey.shade100
                        : Colors.white,
                    border: Border.all(
                      color: isOn ? _pink : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    interest,
                    style: TextStyle(
                      color: isOn
                          ? Colors.white
                          : maxed
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: isOn ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Step 3 — Preferences
// ──────────────────────────────────────────────────────────────
class _Step3 extends StatelessWidget {
  final String? interestedIn;
  final RangeValues ageRange;
  final double maxDistance;
  final ValueChanged<String> onInterested;
  final ValueChanged<RangeValues> onRange;
  final ValueChanged<double> onDist;

  static const _pink = Color(0xFFE84393);

  const _Step3({
    required this.interestedIn,
    required this.ageRange,
    required this.maxDistance,
    required this.onInterested,
    required this.onRange,
    required this.onDist,
  });

  @override
  Widget build(BuildContext context) {
    final sliderTheme = SliderTheme.of(context).copyWith(
      activeTrackColor: _pink,
      inactiveTrackColor: Colors.grey.shade200,
      thumbColor: _pink,
      overlayColor: const Color(0x20E84393),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("I'm interested in"),
          const SizedBox(height: 12),
          Row(
            children: [
              _PillBtn(
                label: 'Men',
                value: 'male',
                selected: interestedIn,
                onTap: onInterested,
              ),
              const SizedBox(width: 10),
              _PillBtn(
                label: 'Women',
                value: 'female',
                selected: interestedIn,
                onTap: onInterested,
              ),
              const SizedBox(width: 10),
              _PillBtn(
                label: 'Everyone',
                value: 'everyone',
                selected: interestedIn,
                onTap: onInterested,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _label('Age range'),
              Text(
                '${ageRange.start.toInt()} – ${ageRange.end.toInt()}',
                style: const TextStyle(
                  color: _pink,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: sliderTheme.copyWith(
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: 12,
              ),
            ),
            child: RangeSlider(
              values: ageRange,
              min: 18,
              max: 99,
              divisions: 81,

              onChanged: onRange,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _label('Maximum distance'),
              Text(
                '${maxDistance.toInt()} km',
                style: const TextStyle(
                  color: _pink,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SliderTheme(
            data: sliderTheme,
            child: Slider(
              value: maxDistance,
              min: 1,
              max: 200,
              divisions: 199,
              onChanged: onDist,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillBtn extends StatelessWidget {
  final String label, value;
  final String? selected;
  final ValueChanged<String> onTap;

  static const _pink = Color(0xFFE84393);

  const _PillBtn({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final on = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: on ? _pink : Colors.white,
            border: Border.all(color: on ? _pink : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: on ? Colors.white : Colors.grey.shade700,
                fontWeight: on ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Step 4 — Photos
// ──────────────────────────────────────────────────────────────
class _Step4 extends StatelessWidget {
  final List<XFile> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  static const _pink = Color(0xFFE84393);

  const _Step4({
    required this.photos,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add at least 1 photo to get started',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
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
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isNextSlot && !hasPhoto
                                ? _pink
                                : Colors.grey.shade200,
                            width: isNextSlot && !hasPhoto ? 1.5 : 1,
                          ),
                          image: hasPhoto
                              ? DecorationImage(
                                  image: FileImage(File(photos[i].path)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: hasPhoto
                            ? null
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      color: isNextSlot
                                          ? _pink
                                          : Colors.grey.shade300,
                                      size: 28,
                                    ),
                                    if (i == 0 && isNextSlot) ...[
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Main',
                                        style: TextStyle(
                                          color: _pink,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                      ),
                      if (hasPhoto)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => onRemove(i),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      if (i == 0 && hasPhoto)
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _pink,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Main',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Shared helpers
// ──────────────────────────────────────────────────────────────
Widget _label(String text) => Text(
  text,
  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
);

InputDecoration _inputDeco(String hint, {String? suffix}) => InputDecoration(
  hintText: hint,
  suffixText: suffix,
  filled: true,
  fillColor: Colors.grey.shade50,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.grey.shade200),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.grey.shade200),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFE84393), width: 1.5),
  ),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
);
