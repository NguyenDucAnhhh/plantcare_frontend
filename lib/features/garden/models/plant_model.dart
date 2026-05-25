class PlantModel {
  final int id;
  final String name;
  final String? species;
  final String? description;
  final String? imageUrl;
  final String? datePlanted;
  final int gardenId;

  PlantModel({
    required this.id,
    required this.name,
    this.species,
    this.description,
    this.imageUrl,
    this.datePlanted,
    required this.gardenId,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      species: json['species'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      datePlanted: json['datePlanted'] as String?,
      gardenId: json['gardenId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'description': description,
      'imageUrl': imageUrl,
      'datePlanted': datePlanted,
    };
  }

  PlantModel copyWith({
    int? id,
    String? name,
    String? species,
    String? description,
    String? imageUrl,
    String? datePlanted,
    int? gardenId,
  }) {
    return PlantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      datePlanted: datePlanted ?? this.datePlanted,
      gardenId: gardenId ?? this.gardenId,
    );
  }
}
