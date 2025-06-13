import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Get current Firebase user ID
  static String? get currentUserId {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // Create a new post
  static Future<Map<String, dynamic>?> createPost({
    required String title,
    required String description,
    double? latitude,
    double? longitude,
    File? imageFile,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      String? imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, userId);
      }

      // Insert post into Supabase
      final response =
          await _supabase
              .from('posts')
              .insert({
                'user_id': userId,
                'title': title,
                'description': description,
                'latitude': latitude,
                'longitude': longitude,
                'image_url': imageUrl,
                'created_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

      return response;
    } catch (e) {
      print('Error creating post: $e');
      return null;
    }
  }

  // Upload image to Supabase Storage
  static Future<String?> _uploadImage(File imageFile, String userId) async {
    try {
      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'posts/$fileName';

      await _supabase.storage
          .from('post-images')
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl = _supabase.storage
          .from('post-images')
          .getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Get all posts ordered by creation date
  static Future<List<Map<String, dynamic>>> getPosts() async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }

  // Get posts by specific user
  static Future<List<Map<String, dynamic>>> getUserPosts(String userId) async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching user posts: $e');
      return [];
    }
  }

  // Delete a post
  static Future<bool> deletePost(int postId) async {
    try {
      final userId = currentUserId;
      if (userId == null) return false;

      await _supabase
          .from('posts')
          .delete()
          .eq('id', postId)
          .eq('user_id', userId); // Ensure user can only delete their own posts

      return true;
    } catch (e) {
      print('Error deleting post: $e');
      return false;
    }
  }

  // Listen to real-time changes in posts
  static Stream<List<Map<String, dynamic>>> getPostsStream() {
    return _supabase
        .from('posts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }
}
