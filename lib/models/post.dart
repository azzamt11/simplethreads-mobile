class Post {
  int? id;
  int? userId;
  String? userName;
  String? content;
  int? likeCount;
  bool? isLiked;
  int? parentPostId;
  String? error;

  Post({
    this.id = 0,
    this.userId = 0,
    this.userName = '',
    this.content = '',
    this.likeCount = 0,
    this.parentPostId, // Removed default 0 to allow null for top-level posts
    this.isLiked = false,
    this.error,
  });

  factory Post.fromJson(Map<String, dynamic> data) {
    return Post(
      id: data['id'],
      userId: data['user_id'],
      userName: data['user_name'],
      content: data['content'],
      likeCount: data['like_count'] ?? 0,
      parentPostId: data['parent_post_id'],
      // FIX: Check if is_liked is an int (1/0) or a bool
      isLiked: data['is_liked'] is bool 
          ? data['is_liked'] 
          : (data['is_liked'] == 1), 
    );
  }

  // Use null-aware operators to prevent crashes
  void likePost() {
    likeCount = (likeCount ?? 0) + 1;
    isLiked = true;
  }

  void unlikePost() {
    likeCount = (likeCount ?? 0) - 1;
    if (likeCount! < 0) likeCount = 0; // Prevent negative likes
    isLiked = false;
  }

  void setError(String error) {
    this.error = error;
  }
}