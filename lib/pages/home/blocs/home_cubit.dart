import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:simple_threads/models/post.dart';
import 'package:simple_threads/services/api_client.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const InitialHomeState());

  static HomeCubit create(BuildContext context) => HomeCubit();

  // Placeholder for the logged-in user. 
  // In a real app, this would come from an AuthRepository.
  final int currentUserId = 1;

  Future<void> fetch({int? parentPostId}) async {
    emit(const LoadingHomeState());
    try {
      final posts = await ApiClient.getPosts(parentPostId: parentPostId);
      if (posts.isNotEmpty) {
        emit(LoadedHomeState(posts: posts));
      } else {
        emit(ErrorHomeState(
          error: HomeError(message: 'No posts found', isOffline: false),
        ));
      }
    } catch (e) {
      _emitError(e);
    }
  }

  /// Creates a new post and refreshes the feed
  Future<void> createPost(String content, {int? parentPostId}) async {
    if (content.trim().isEmpty) return;

    try {
      // Calls your Go backend: db.Exec("INSERT INTO posts...")
      await ApiClient.createPost(
        content: content,
        userId: currentUserId,
        parentPostId: parentPostId, // null for top-level posts
      );
      
      // Refresh the list to show the new post
      await fetch();
    } catch (e) {
      _emitError(e);
    }
  }

  /// Toggles the like status of a post
  Future<void> toggleLike(Post post) async {
    try {
      // If your backend doesn't return "isLikedByMe", we handle it based on 
      // UI state or local tracking. For now, we assume a standard toggle.
      // We use the endpoints /likes (POST) and /likes/delete (DELETE)
      
      // Note: Ideally, you'd add 'isLiked' to your Post model.
      // If post.isLiked is true, we call unlike, else we call like.
      
      // This is a placeholder for your toggle logic:
      bool isCurrentlyLiked = post.isLiked ?? false;

      if (isCurrentlyLiked) {
        await ApiClient.unlikePost(postId: post.id ?? 0, userId: currentUserId);
      } else {
        await ApiClient.likePost(postId: post.id ?? 0, userId: currentUserId);
      }

      // Refresh to get updated LikeCount from backend
      await fetch();
    } catch (e) {
      _emitError(e);
    }
  }

  void _emitError(Object e) {
    emit(ErrorHomeState(
      error: HomeError(
        message: e.toString(),
        isOffline: e.toString().toLowerCase().contains("socket"),
      ),
    ));
  }

  Future<void> deletePost(int postId) async {
    try {
      await ApiClient.deletePost(postId);
      await fetch(); // Refresh the list after deletion
    } catch (e) {
      _emitError(e);
    }
  }

  Future<void> editPost(int postId, String newContent) async {
    try {
      await ApiClient.updatePost(postId: postId, content: newContent);
      await fetch(); // Refresh the feed
    } catch (e) {
      _emitError(e);
    }
  }
}

class HomeError {
  String? message;
  bool? isOffline;

  HomeError({required this.message, required this.isOffline});
}

class HomeHighlight {
  final String title;
  final String subtitle;
  const HomeHighlight({required this.title, required this.subtitle});
}