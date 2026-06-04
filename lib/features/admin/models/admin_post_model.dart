
class AdminPostModel {
  final int id;
  final String authorName;
  final String authorEmail;
  final String content;
  final List<String> imageUrls;
  final bool isVisible;
  final int likeCount;
  final String createdAt;

  AdminPostModel({
    required this.id,
    required this.authorName,
    required this.authorEmail,
    required this.content,
    required this.imageUrls,
    required this.isVisible,
    required this.likeCount,
    required this.createdAt,
  });

  factory AdminPostModel.fromJson(Map<String, dynamic> json) {
    return AdminPostModel(
      id: json['id'] ?? 0,
      authorName: json['authorName'] ?? '',
      authorEmail: json['authorEmail'] ?? '',
      content: json['content'] ?? '',
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isVisible: json['visible'] ?? json['isVisible'] ?? true,
      likeCount: json['likeCount'] ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
