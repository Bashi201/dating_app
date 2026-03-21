class DiscoverUserModel {
  final int id;
  final String name;
  final int? age;
  final String? city;
  final String? bio;
  final List<String> interests;
  final String? primaryPhotoUrl;
  final double? distanceKm;

  const DiscoverUserModel({
    required this.id,
    required this.name,
    this.age,
    this.city,
    this.bio,
    this.interests = const [],
    this.primaryPhotoUrl,
    this.distanceKm,
  });

  factory DiscoverUserModel.fromJson(Map<String, dynamic> json) =>
      DiscoverUserModel(
        id: json['id'],
        name: json['name'],
        age: json['age'],
        city: json['city'],
        bio: json['bio'],
        interests: List<String>.from(json['interests'] ?? []),
        primaryPhotoUrl: json['primary_photo'],
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
      );
}
