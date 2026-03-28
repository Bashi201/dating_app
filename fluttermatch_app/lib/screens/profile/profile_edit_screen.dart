import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/photo_model.dart';
import '../../providers/profile_provider.dart';


class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  static const _pink = Color(0xFFE84393);

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
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = ref.read(profileProvider).valueOrNull;
    if (profile == null) {
      await ref.read(profileProvider.notifier).loadProfile();
    }
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
          const SnackBar(content: Text('Profile updated successfully')),
        );
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: _pink)));
    }

    final profile = ref.watch(profileProvider).valueOrNull;
    final photos = profile?.photos ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_saving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _pink)),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('Save', style: TextStyle(color: _pink, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('Photos'),
            const SizedBox(height: 12),
            _photoGrid(photos),
            const SizedBox(height: 32),
            _sectionHeader('About Me'),
            const SizedBox(height: 16),
            _label('Age'),
            TextField(
              keyboardType: TextInputType.number,
              decoration: _inputDeco('Your age'),
              controller: TextEditingController(text: _age?.toString()),
              onChanged: (v) => _age = int.tryParse(v),
            ),
            const SizedBox(height: 20),
            _label('Gender'),
            const SizedBox(height: 12),
            _genderPicker(),
            const SizedBox(height: 20),
            _label('City'),
            TextField(
              controller: _cityCtrl,
              decoration: _inputDeco('Your city'),
            ),
            const SizedBox(height: 20),
            _label('Bio'),
            TextField(
              controller: _bioCtrl,
              maxLines: 4,
              maxLength: 500,
              decoration: _inputDeco('Tell people about yourself...'),
            ),
            const SizedBox(height: 32),
            _sectionHeader('Interests'),
            const SizedBox(height: 12),
            _interestsPicker(),
            const SizedBox(height: 32),
            _sectionHeader('Discovery Settings'),
            const SizedBox(height: 16),
            _label('Interested in'),
            const SizedBox(height: 12),
            _discoveryGenderPicker(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label('Age Range'),
                Text('${_ageRange.start.toInt()} - ${_ageRange.end.toInt()}', style: const TextStyle(color: _pink, fontWeight: FontWeight.bold)),
              ],
            ),
            RangeSlider(
              values: _ageRange,
              min: 18,
              max: 99,
              activeColor: _pink,
              onChanged: (v) => setState(() => _ageRange = v),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label('Distance'),
                Text('${_maxDistance.toInt()} km', style: const TextStyle(color: _pink, fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: _maxDistance,
              min: 1,
              max: 200,
              activeColor: _pink,
              onChanged: (v) => setState(() => _maxDistance = v),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)));
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _pink)),
    );
  }

  Widget _photoGrid(List<PhotoModel> photos) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        if (index < photos.length) {
          final photo = photos[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(photo.thumbnailUrl, fit: BoxFit.cover),
              ),
              if (photo.isPrimary)
                Positioned(
                  top: 0, left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: const BoxDecoration(color: _pink, borderRadius: BorderRadius.only(topLeft: Radius.circular(12), bottomRight: Radius.circular(12))),
                    child: const Text('Primary', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              Positioned(
                bottom: 0, right: 0,
                child: MenuAnchor(
                  builder: (context, controller, child) => IconButton(
                    onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.more_vert, color: Colors.white, size: 16),
                    ),
                  ),
                  menuChildren: [
                    if (!photo.isPrimary)
                      MenuItemButton(
                        onPressed: () => ref.read(profileProvider.notifier).setPrimaryPhoto(photo.id),
                        child: const Text('Set as Primary'),
                      ),
                    MenuItemButton(
                      onPressed: () => ref.read(profileProvider.notifier).deletePhoto(photo.id),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        if (index == photos.length) {
          return InkWell(
            onTap: _pickPhoto,
            child: Container(
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
              child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
            ),
          );
        }
        return Container(
          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        );
      },
    );
  }

  Widget _genderPicker() {
    return Wrap(
      spacing: 10, runSpacing: 10,
      children: _genders.map((g) {
        final selected = _gender == g.$1;
        return InkWell(
          onTap: () => setState(() => _gender = g.$1),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? _pink : Colors.white,
              border: Border.all(color: selected ? _pink : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(g.$3, size: 18, color: selected ? Colors.white : Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(g.$2, style: TextStyle(color: selected ? Colors.white : Colors.grey.shade800, fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _discoveryGenderPicker() {
    final options = [('male', 'Men'), ('female', 'Women'), ('everyone', 'Everyone')];
    return Row(
      children: options.map((o) {
        final selected = _interestedIn == o.$1;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => setState(() => _interestedIn = o.$1),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? _pink : Colors.white,
                  border: Border.all(color: selected ? _pink : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(o.$2, style: TextStyle(color: selected ? Colors.white : Colors.grey.shade800, fontWeight: selected ? FontWeight.bold : FontWeight.normal))),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _interestsPicker() {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: _allInterests.map((interest) {
        final isSelected = _selectedInterests.contains(interest);
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedInterests.remove(interest);
              } else if (_selectedInterests.length < 10) {
                _selectedInterests.add(interest);
              }
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? _pink : Colors.white,
              border: Border.all(color: isSelected ? _pink : Colors.grey.shade300),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(interest, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade700, fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ),
        );
      }).toList(),
    );
  }
}
