import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../providers/post_provider.dart';
import '../providers/comment_provider.dart';
import '../widgets/post_card.dart';
import '../widgets/report_post_dialog.dart';
import '../../../core/widgets/custom_header.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final TextEditingController _commentCtrl = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  CommentModel? _replyingTo;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(postProvider.notifier).loadPostById(widget.postId);
    });
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postProvider);
    final profileState = ref.watch(profileProvider);
    
    final myAvatarUrl = profileState.profile?['avatarUrl'];

    // 2. Tìm bài viết cụ thể trong danh sách posts của state mới
    final post = postsState.posts.firstWhere(
      (p) => p.id == widget.postId,
      orElse: () => PostModel(
        id: widget.postId,
        content: 'Không tìm thấy bài viết',
        authorId: '',
        authorName: '',
        authorAvatar: '',
        timeAgo: '',
      ),
    );

    if (postsState.isLoading && post.authorId.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomHeader(
          title: 'Chi tiết bài đăng',
          showBackButton: true,
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final commentsAsync = ref.watch(commentProvider(widget.postId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomHeader(
        title: 'Chi tiết bài đăng',
        showBackButton: true,
        actions: [
          if (!post.isMine)
            IconButton(
              icon: const Icon(Icons.flag_outlined, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => ReportPostDialog(postId: widget.postId),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bai dang
                  if (post != null) PostCard(post: post, isDetailView: true),
                  
                  Divider(color: Colors.grey.shade200, thickness: 8, height: 8),

                  // Binh luan Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Bình luận (${commentsAsync.value?.length ?? 0})',
                      style: AppTextStyles.heading2.copyWith(fontSize: 18),
                    ),
                  ),

                  // Danh sach binh luan
                  commentsAsync.when(
                    data: (comments) {
                      if (comments.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('Chưa có bình luận nào.', style: AppTextStyles.bodyGrey),
                        );
                      }
                      final topLevelComments = comments.where((c) => c.parentCommentId == null).toList();
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: topLevelComments.length,
                        separatorBuilder: (_, __) => Divider(color: Colors.grey.shade200, height: 1),
                        itemBuilder: (context, index) {
                          return _buildCommentThread(topLevelComments[index], comments);
                        },
                      );
                    },
                    loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: AppColors.primary))),
                    error: (err, stack) => Padding(padding: const EdgeInsets.all(16), child: Text('Lỗi tải bình luận: $err', style: AppTextStyles.body.copyWith(color: AppColors.error))),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // O nhap binh luan
          _buildCommentInput(myAvatarUrl),
        ],
      ),
    );
  }

  Widget _buildCommentThread(CommentModel comment, List<CommentModel> allComments, {bool isReply = false}) {
    final replies = allComments.where((c) => c.parentCommentId == comment.id).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCommentItem(comment, isReply: isReply),
        if (replies.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: isReply ? 0 : 40),
            child: Column(
              children: replies.map((reply) => _buildCommentThread(reply, allComments, isReply: true)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentItem(CommentModel comment, {bool isReply = false}) {
    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, top: isReply ? 8 : 16, bottom: isReply ? 8 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              if (comment.isMine) {
                context.go('/profile');
              } else {
                context.push('/user/${comment.authorId}');
              }
            },
            child: AppAvatar(
              imageUrl: comment.authorAvatar,
              radius: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                      if (comment.isMine) {
                        context.go('/profile');
                    } else {
                        context.push('/user/${comment.authorId}');
                    }
                  },
                  child: Text(
                    comment.authorName,
                    style: AppTextStyles.heading3.copyWith(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      comment.timeAgo,
                      style: AppTextStyles.bodyGrey.copyWith(fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() { _replyingTo = comment; });
                        FocusScope.of(context).requestFocus(_commentFocusNode);
                      },
                      child: Text(
                        'Trả lời',
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(String? userAvatar) {
    return Column(
      children: [
        if (_replyingTo != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Đang trả lời ${_replyingTo!.authorName}',
                    style: AppTextStyles.bodyGrey.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() { _replyingTo = null; });
                  },
                  child: const Icon(Icons.close, size: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go('/profile'),
            child: AppAvatar(
              imageUrl: userAvatar,
              radius: 18
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.inputBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _commentCtrl,
                focusNode: _commentFocusNode,
                decoration: InputDecoration(
                  hintText: 'Thêm bình luận...',
                  hintStyle: AppTextStyles.bodyGrey,
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: AppTextStyles.body,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: AppColors.primary),
            onPressed: () async {
              if (_commentCtrl.text.trim().isNotEmpty) {
                FocusScope.of(context).unfocus();
                final content = _commentCtrl.text;
                _commentCtrl.clear();
                
                try {
                  await ref.read(commentProvider(widget.postId).notifier).addComment(content, parentId: _replyingTo?.id);
                  setState(() { _replyingTo = null; });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    ),
      ],
    );
  }
}
