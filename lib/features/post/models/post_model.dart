class PostModel {
  final String id;
  final String content;
  final List<String> imageUrls;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isMine;
  final String timeAgo;

  PostModel({
    required this.id,
    required this.content,
    this.imageUrls = const [],
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isMine = false,
    required this.timeAgo,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['imageUrls'] != null) {
      images = List<String>.from(json['imageUrls']);
    }

    // Convert ISO date to readable string (just a simple mapping for now)
    String rawDate = json['createdAt'] ?? '';
    String timeStr = 'Vừa xong';
    if (rawDate.isNotEmpty) {
      try {
        DateTime dt = DateTime.parse(rawDate).toLocal();
        Duration diff = DateTime.now().difference(dt);
        if (diff.inDays > 0) {
          timeStr = '${diff.inDays} ngày trước';
        } else if (diff.inHours > 0) {
          timeStr = '${diff.inHours} giờ trước';
        } else if (diff.inMinutes > 0) {
          timeStr = '${diff.inMinutes} phút trước';
        }
      } catch (e) {
        // ignore
      }
    }

    return PostModel(
      id: json['id']?.toString() ?? '',
      content: json['content'] ?? '',
      imageUrls: images,
      authorId: json['authorId']?.toString() ?? '',
      authorName: json['authorName'] ?? 'Người dùng',
      authorAvatar: json['authorAvatar'] ?? '',
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isMine: json['isMine'] ?? false,
      timeAgo: timeStr,
    );
  }

  PostModel copyWith({
    String? id,
    String? content,
    List<String>? imageUrls,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    bool? isMine,
    String? timeAgo,
  }) {
    return PostModel(
      id: id ?? this.id,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      isMine: isMine ?? this.isMine,
      timeAgo: timeAgo ?? this.timeAgo,
    );
  }
}

