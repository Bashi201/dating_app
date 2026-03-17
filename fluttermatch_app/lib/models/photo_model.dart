class PhotoModel {
  final int id;
  final String url;
  final String thumbnailUrl;
  final bool isPrimary;
  final int sortOrder;

  const PhotoModel({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    required this.isPrimary,
    required this.sortOrder,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) => PhotoModel(
    id: json['id'],
    url: json['url'],
    thumbnailUrl: json['thumbnail_url'] ?? json['url'],
    isPrimary: json['is_primary'] ?? false,
    sortOrder: json['sort_order'] ?? 0,
  );

  PhotoModel copyWith({bool? isPrimary}) => PhotoModel(
    id: id,
    url: url,
    thumbnailUrl: thumbnailUrl,
    isPrimary: isPrimary ?? this.isPrimary,
    sortOrder: sortOrder,
  );
}
