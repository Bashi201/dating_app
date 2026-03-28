import 'photo_model.dart';

class ProfileModel {
  final int id;
  final int userId;
  final String? bio;
  final int? age;
  final String? gender;
  final String? interestedIn;
  final String? city;
  final double? lat;
  final double? lng;
  final List<String> interests;
  final String? instagram;
  final String? spotify;
  final int minAge;
  final int maxAge;
  final int maxDistance;
  final bool showMe;
  final bool isComplete;
  final List<PhotoModel> photos;

  const ProfileModel({
    required this.id,
    required this.userId,
    this.bio,
    this.age,
    this.gender,
    this.interestedIn,
    this.city,
    this.lat,
    this.lng,
    this.interests = const [],
    this.instagram,
    this.spotify,
    this.minAge = 18,
    this.maxAge = 99,
    this.maxDistance = 50,
    this.showMe = true,
    this.isComplete = false,
    this.photos = const [],
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: json['id'],
    userId: json['user_id'],
    bio: json['bio'],
    age: json['age'],
    gender: json['gender'],
    interestedIn: json['interested_in'],
    city: json['city'],
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
    interests: List<String>.from(json['interests'] ?? []),
    instagram: json['instagram'],
    spotify: json['spotify'],
    minAge: json['min_age'] ?? 18,
    maxAge: json['max_age'] ?? 99,
    maxDistance: json['max_distance'] ?? 50,
    showMe: json['show_me'] ?? true,
    isComplete: json['is_complete'] ?? false,
    photos:
        (json['photos'] as List<dynamic>?)
            ?.map((p) => PhotoModel.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [],
  );

  PhotoModel? get primaryPhoto =>
      photos.isEmpty ? null : photos.firstWhere((p) => p.isPrimary, orElse: () => photos.first);

  String? get primaryPhotoUrl => primaryPhoto?.url;

  ProfileModel copyWith({
    String? bio,
    int? age,
    String? gender,
    String? interestedIn,
    String? city,
    List<String>? interests,
    int? minAge,
    int? maxAge,
    int? maxDistance,
    bool? showMe,
    bool? isComplete,
    List<PhotoModel>? photos,
  }) => ProfileModel(
    id: id,
    userId: userId,
    bio: bio ?? this.bio,
    age: age ?? this.age,
    gender: gender ?? this.gender,
    interestedIn: interestedIn ?? this.interestedIn,
    city: city ?? this.city,
    lat: lat,
    lng: lng,
    interests: interests ?? this.interests,
    instagram: instagram,
    spotify: spotify,
    minAge: minAge ?? this.minAge,
    maxAge: maxAge ?? this.maxAge,
    maxDistance: maxDistance ?? this.maxDistance,
    showMe: showMe ?? this.showMe,
    isComplete: isComplete ?? this.isComplete,
    photos: photos ?? this.photos,
  );
}

