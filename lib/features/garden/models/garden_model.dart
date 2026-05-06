class GardenModel {
  final int id;
  final String name;
  final String? location;
  final String? description;
  final String? imageUrl;
  final int plantCount;

  GardenModel({
    required this.id,
    required this.name,
    this.location,
    this.description,
    this.imageUrl,
    this.plantCount = 0,
  });

  factory GardenModel.fromJson(Map<String, dynamic> json) {
    return GardenModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      location: json['location'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      plantCount: json['plantCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  GardenModel copyWith({
    int? id,
    String? name,
    String? location,
    String? description,
    String? imageUrl,
    int? plantCount,
  }) {
    return GardenModel(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      plantCount: plantCount ?? this.plantCount,
    );
  }
}
