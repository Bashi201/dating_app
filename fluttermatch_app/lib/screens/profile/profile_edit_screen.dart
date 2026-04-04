import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../models/photo_model.dart';
import '../../providers/profile_provider.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _cityCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  int? _age;
  String? _gender;
  String? _interestedIn;
  RangeValues _ageRange = const RangeValues(18, 50);
  double _maxDistance = 50;
  List<String> _selectedInterests = [];

  bool _loading = true;
  bool _saving = false;

  static const _allInterests = [
    'Music', 'Sports', 'Travel', 'Food & Drink', 'Gaming',
    'Reading', 'Movies', 'Fitness', 'Art', 'Cooking',
    'Dancing', 'Yoga', 'Hiking', 'Photography', 'Fashion',
    'Tech', 'Pets', 'Coffee', 'Surfing', 'Running',
  ];

  static const _genders = [
    ('male', 'Man', Icons.male_rounded),
    ('female', 'Woman', Icons.female_rounded),
    ('non_binary', 'Non-binary', Icons.people_outline),
    ('other', 'Other', Icons.person_outline),
  ];

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final profile = ref.read(profileProvider).valueOrNull;
    if (profile == null) await ref.read(profileProvider.notifier).loadProfile();
    _initFields();
  }

  void _initFields() {
    final profile = ref.read(profileProvider).valueOrNull;
    if (profile != null) {
      setState(() {
        _age = profile.age;
        _gender = profile.gender;
        _cityCtrl.text = profile.city ?? '';
        _bioCtrl.text = profile.bio ?? '';
        _selectedInterests = List.from(profile.interests);
        _interestedIn = profile.interestedIn;
        _ageRange = RangeValues(profile.minAge.toDouble(), profile.maxAge.toDouble());
        _maxDistance = profile.maxDistance.toDouble();
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final success = await ref.read(profileProvider.notifier).updateProfile({
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
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated ✓')));
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() => _saving = true);
      await ref.read(profileProvider.notifier).uploadPhoto(image.path);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          const GlassBackground(child: SizedBox.expand()),
          Center(child: CircularProgressIndicator(color: primary)),
        ]),
      );
    }

    final profile = ref.watch(profileProvider).valueOrNull;
    final photos = profile?.photos ?? [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const GlassBackground(child: SizedBox.expand()),
          const Positioned(top: -40, right: -40, child: GlassBlob(size: 180, opacity: 0.08)),

          SafeArea(
            child: Column(
              children: [
                // ── Header ──────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: GlassCard(
                          borderRadius: 12,
                          padding: const EdgeInsets.all(10),
                          child: Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18, color: primary),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text('Edit Profile',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: onSurface)),
                      const Spacer(),
                      if (_saving)
                        SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: primary),
                        )
                      else
                        GlassCard(
                          borderRadius: 12,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: GestureDetector(
                            onTap: _save,
                            child: Text('Save',
                                style: TextStyle(
                                    color: primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Photos ─────────────────────────────────────────
                        _sectionHeader('Photos', primary, onSurface),
                        const SizedBox(height: 12),
                        GlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(16),
                          child: _photoGrid(photos, primary),
                        ),

                        const SizedBox(height: 24),

                        // ── About Me ────────────────────────────────────────
                        _sectionHeader('About Me', primary, onSurface),
                        const SizedBox(height: 12),
                        GlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                keyboardType: TextInputType.number,
                                controller: TextEditingController(text: _age?.toString()),
                                decoration: _inputDeco('Age'),
                                onChanged: (v) => _age = int.tryParse(v),
                              ),
                              const SizedBox(height: 16),
                              _label('Gender', onSurface),
                              const SizedBox(height: 10),
                              _genderPicker(primary),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _cityCtrl,
                                decoration: _inputDeco('City'),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _bioCtrl,
                                maxLines: 4,
                                maxLength: 500,
                                decoration: _inputDeco('Bio — tell people about yourself...'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Interests ───────────────────────────────────────
                        _sectionHeader('Interests', primary, onSurface),
                        const SizedBox(height: 12),
                        GlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(16),
                          child: _interestsPicker(primary, onSurface),
                        ),

                        const SizedBox(height: 24),

                        // ── Discovery Settings ──────────────────────────────
                        _sectionHeader('Discovery Settings', primary, onSurface),
                        const SizedBox(height: 12),
                        GlassCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Interested in', onSurface),
                              const SizedBox(height: 10),
                              _discoveryGenderPicker(primary, onSurface),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _label('Age Range', onSurface),
                                  Text(
                                    '${_ageRange.start.toInt()} – ${_ageRange.end.toInt()}',
                                    style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              RangeSlider(
                                values: _ageRange,
                                min: 18, max: 99,
                                activeColor: primary,
                                onChanged: (v) => setState(() => _ageRange = v),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _label('Max Distance', onSurface),
                                  Text('${_maxDistance.toInt()} km',
                                      style: TextStyle(color: primary, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Slider(
                                value: _maxDistance,
                                min: 1, max: 200,
                                activeColor: primary,
                                onChanged: (v) => setState(() => _maxDistance = v),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
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

  Widget _sectionHeader(String title, Color primary, Color onSurface) {
    return Row(
      children: [
        Container(width: 3, height: 18,
            decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface)),
      ],
    );
  }

  Widget _label(String text, Color onSurface) {
    return Text(text,
        style: TextStyle(
            color: onSurface.withValues(alpha: 0.65),
            fontWeight: FontWeight.w500,
            fontSize: 13));
  }

  InputDecoration _inputDeco(String hint) {
    const primary = AppColors.primary;
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8B4C8))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8B4C8))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2)),
    );
  }

  Widget _photoGrid(List<PhotoModel> photos, Color primary) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.8),
      itemBuilder: (context, index) {
        if (index < photos.length) {
          final photo = photos[index];
          return Stack(fit: StackFit.expand, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(photo.thumbnailUrl, fit: BoxFit.cover),
            ),
            if (photo.isPrimary)
              Positioned(
                top: 0, left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomRight: Radius.circular(10))),
                  child: const Text('Primary',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            Positioned(
              bottom: 0, right: 0,
              child: MenuAnchor(
                builder: (context, controller, child) => IconButton(
                  onPressed: () =>
                      controller.isOpen ? controller.close() : controller.open(),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.more_vert, color: Colors.white, size: 16),
                  ),
                ),
                menuChildren: [
                  if (!photo.isPrimary)
                    MenuItemButton(
                      onPressed: () =>
                          ref.read(profileProvider.notifier).setPrimaryPhoto(photo.id),
                      child: const Text('Set as Primary'),
                    ),
                  MenuItemButton(
                    onPressed: () =>
                        ref.read(profileProvider.notifier).deletePhoto(photo.id),
                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          ]);
        }
        if (index == photos.length) {
          return InkWell(
            onTap: _pickPhoto,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Icon(Icons.add_a_photo_outlined,
                  color: AppColors.primary.withValues(alpha: 0.6)),
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
          ),
        );
      },
    );
  }

  Widget _genderPicker(Color primary) {
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: _genders.map((g) {
        final selected = _gender == g.$1;
        return GestureDetector(
          onTap: () => setState(() => _gender = g.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? primary : primary.withValues(alpha: 0.06),
              border: Border.all(
                  color: selected ? primary : primary.withValues(alpha: 0.25)),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(g.$3, size: 18,
                  color: selected ? Colors.white : primary.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text(g.$2,
                  style: TextStyle(
                      color: selected ? Colors.white : primary.withValues(alpha: 0.8),
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
            ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _discoveryGenderPicker(Color primary, Color onSurface) {
    final options = [('male', 'Men'), ('female', 'Women'), ('everyone', 'Everyone')];
    return Row(
      children: options.map((o) {
        final selected = _interestedIn == o.$1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _interestedIn = o.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? primary : primary.withValues(alpha: 0.06),
                  border: Border.all(
                      color: selected ? primary : primary.withValues(alpha: 0.25)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(o.$2,
                      style: TextStyle(
                          color: selected ? Colors.white : onSurface.withValues(alpha: 0.75),
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _interestsPicker(Color primary, Color onSurface) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: _allInterests.map((interest) {
        final isSelected = _selectedInterests.contains(interest);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedInterests.remove(interest);
              } else if (_selectedInterests.length < 10) {
                _selectedInterests.add(interest);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primary : primary.withValues(alpha: 0.06),
              border: Border.all(
                  color: isSelected ? primary : primary.withValues(alpha: 0.25)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(interest,
                style: TextStyle(
                    color: isSelected ? Colors.white : onSurface.withValues(alpha: 0.75),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ),
        );
      }).toList(),
    );
  }
}
