import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class ApiClient {
  static const String baseUrl = 'http://187.124.246.195:8200';

  static Map<String, String> get _headers => {
        "Content-type": "application/json",
        "Access-Control-Allow-Origin": "*",
      };

  /// GET: Fetch all posts or comments for a specific parent
  static Future<List<Post>> getPosts({int? parentPostId}) async {
    List<Post> data = [];
    try {
      final url = parentPostId != null 
          ? '$baseUrl/posts?parentPostId=$parentPostId' 
          : '$baseUrl/posts';

      var response = await http.get(Uri.parse(url), headers: _headers);
      
      if (response.statusCode == 200) {
        var decodedResponse = json.decode(response.body) as List;
        return decodedResponse.map<Post>((e) => Post.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('azzam_debug error fetching posts: ${e.toString()}');
      Post post = Post();
      post.setError('No Connection');
      data.add(post);
    }
    return data;
  }

  /// POST: Create a new post or comment
  static Future<void> createPost({
    required String content,
    required int userId,
    int? parentPostId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: _headers,
        body: jsonEncode({
          'content': content,
          'user_id': userId,
          'parent_post_id': parentPostId,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create post: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('azzam_debug error creating post: $e');
      rethrow;
    }
  }

  /// POST: Like a post
  static Future<void> likePost({required int postId, required int userId}) async {
    debugPrint('azzam_debug liking postId: $postId by userId: $userId');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/likes'),
        headers: _headers,
        body: jsonEncode({
          'post_id': postId,
          'user_id': userId,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to like post');
      }
    } catch (e) {
      debugPrint('azzam_debug error liking: $e');
      rethrow;
    }
  }

  /// DELETE: Unlike a post (using Query Parameters for Go)
  static Future<void> unlikePost({required int postId, required int userId}) async {
    debugPrint('azzam_debug unliking postId: $postId by userId: $userId');
    try {
      // Your Go backend uses r.URL.Query().Get("post_id")
      final url = '$baseUrl/likes/delete?post_id=$postId&user_id=$userId';
      
      final response = await http.delete(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to unlike post');
      }
    } catch (e) {
      debugPrint('azzam_debug error unliking: $e');
      rethrow;
    }
  }

  static Future<void> deletePost(int postId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/posts/delete?id=$postId'),
        headers: _headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete post');
      }
    } catch (e) {
      debugPrint('azzam_debug error deleting: $e');
      rethrow;
    }
  }

  static Future<void> updatePost({required int postId, required String content}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/posts/update'),
        headers: _headers,
        body: jsonEncode({
          'id': postId,
          'content': content,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update post');
      }
    } catch (e) {
      debugPrint('azzam_debug error updating: $e');
      rethrow;
    }
  }
}