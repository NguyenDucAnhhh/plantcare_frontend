class CommentModel {
  final String id;
  final String postId;
  final String authorName;
  final String authorAvatar;
  final String content;
  final String timeAgo;
  final String? parentCommentId;
  final String authorId;
  final bool isMine;

  CommentModel({
    required this.id,
    required this.postId,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.timeAgo,
    this.parentCommentId,
    required this.authorId,
    required this.isMine,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json, String postId) {
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

    return CommentModel(
      id: json['id']?.toString() ?? '',
      postId: postId,
      authorName: json['authorName'] ?? 'Người dùng ẩn danh',
      authorAvatar: json['authorAvatar'] ?? '',
      content: json['content'] ?? '',
      parentCommentId: json['parentCommentId']?.toString(),
      timeAgo: timeStr,
      authorId: json['authorId']?.toString() ?? '',
      isMine: json['isMine'] ?? false,
    );
  }
}

