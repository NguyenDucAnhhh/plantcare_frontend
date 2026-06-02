class AdminReportModel {
  final int id;
  final String reporterName;
  final String? reporterEmail;
  final String reason;
  final String status;
  final DateTime createdAt;
  final int postId;
  final String? postContent;
  final String postAuthorId;
  final String postAuthorName;
  final String? postAuthorAvatar;
  final List<String> postImageUrls;
  final int postLikeCount;
  final int postCommentCount;
  final bool postIsVisible;
  final DateTime postCreatedAt;

  AdminReportModel({
    required this.id,
    required this.reporterName,
    this.reporterEmail,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.postId,
    this.postContent,
    required this.postAuthorId,
    required this.postAuthorName,
    this.postAuthorAvatar,
    this.postImageUrls = const [],
    this.postLikeCount = 0,
    this.postCommentCount = 0,
    this.postIsVisible = true,
    required this.postCreatedAt,
  });

  factory AdminReportModel.fromJson(Map<String, dynamic> json) {
    return AdminReportModel(
      id: json['id'] as int,
      reporterName: json['reporterName'] as String? ?? 'N/A',
      reporterEmail: json['reporterEmail'] as String?,
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      postId: json['postId'] as int? ?? 0,
      postContent: json['postContent'] as String?,
      postAuthorId: json['postAuthorId']?.toString() ?? '0',
      postAuthorName: json['postAuthorName'] as String? ?? 'N/A',
      postAuthorAvatar: json['postAuthorAvatar'] as String?,
      postImageUrls: json['postImageUrls'] != null ? List<String>.from(json['postImageUrls']) : [],
      postLikeCount: json['postLikeCount'] as int? ?? 0,
      postCommentCount: json['postCommentCount'] as int? ?? 0,
      postIsVisible: json['postIsVisible'] as bool? ?? true,
      postCreatedAt: json['postCreatedAt'] != null ? DateTime.parse(json['postCreatedAt']) : DateTime.now(),
    );
  }
}
