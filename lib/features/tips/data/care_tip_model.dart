class CareTipModel {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final String? category;
  final String? createdAt;

  CareTipModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.category,
    this.createdAt,
  });

  factory CareTipModel.fromJson(Map<String, dynamic> json) {
    return CareTipModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String? ?? 'Chung', // Default to Chung if backend doesn't have it yet
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'category': category,
      'createdAt': createdAt,
    };
  }

  CareTipModel copyWith({
    int? id,
    String? title,
    String? content,
    String? imageUrl,
    String? category,
    String? createdAt,
  }) {
    return CareTipModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
