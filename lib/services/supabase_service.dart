// services/supabase_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;
  User? get currentUser => client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  // Initialize Supabase
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  // ==================== AUTHENTICATION ====================

  /// Register a new user with email, username, and password
  Future<AuthResponse> registerUser({
    required String email,
    required String username,
    required String password,
    String? profilePicture,
  }) async {
    try {
      // Check if username already exists
      final usernameExists = await _checkUsernameExists(username);
      if (usernameExists) {
        throw Exception('Username already exists');
      }

      // Register user with Supabase Auth
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Create user profile
        await client.from('profiles').insert({
          'id': response.user!.id,
          'email': email.toLowerCase().trim(),
          'username': username.toLowerCase().trim(),
          'profile_picture': profilePicture ?? 'storage/default-profile.jpg',
        });
      }

      return response;
    } catch (error) {
      throw Exception('Registration failed: $error');
    }
  }

  /// Login user with email/username and password
  Future<AuthResponse> loginUser({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      String email = emailOrUsername.trim();

      // If input doesn't contain @, treat it as username and get email
      if (!email.contains('@')) {
        email = await _getEmailFromUsername(
          emailOrUsername.toLowerCase().trim(),
        );
      }

      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } catch (error) {
      throw Exception('Login failed: $error');
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await client.auth.signOut();
    } catch (error) {
      throw Exception('Logout failed: $error');
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Password reset failed: $error');
    }
  }

  /// Check if username already exists
  Future<bool> _checkUsernameExists(String username) async {
    try {
      final response =
          await client
              .from('profiles')
              .select('username')
              .eq('username', username.toLowerCase().trim())
              .maybeSingle();

      return response != null;
    } catch (error) {
      return false;
    }
  }

  /// Get email from username
  Future<String> _getEmailFromUsername(String username) async {
    try {
      final response =
          await client
              .from('profiles')
              .select('email')
              .eq('username', username)
              .single();

      return response['email'];
    } catch (error) {
      throw Exception('Username not found');
    }
  }

  // ==================== USER PROFILE ====================

  /// Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      if (currentUser == null) return null;

      final response =
          await client
              .from('profiles')
              .select()
              .eq('id', currentUser!.id)
              .single();

      return response;
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? username,
    String? profilePicture,
  }) async {
    try {
      if (currentUser == null) throw Exception('User not logged in');

      Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (username != null) {
        // Check if new username already exists
        final usernameExists = await _checkUsernameExists(username);
        if (usernameExists) {
          throw Exception('Username already exists');
        }
        updates['username'] = username.toLowerCase().trim();
      }

      if (profilePicture != null) {
        updates['profile_picture'] = profilePicture;
      }

      await client.from('profiles').update(updates).eq('id', currentUser!.id);
    } catch (error) {
      throw Exception('Failed to update profile: $error');
    }
  }

  // ==================== CRIME CATEGORIES ====================

  /// Get all crime categories
  Future<List<Map<String, dynamic>>> getCrimeCategories() async {
    try {
      final response = await client
          .from('crime_categories')
          .select()
          .order('crime_type');

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get crime categories: $error');
    }
  }

  /// Get crime category by ID
  Future<Map<String, dynamic>?> getCrimeCategoryById(int id) async {
    try {
      final response =
          await client.from('crime_categories').select().eq('id', id).single();

      return response;
    } catch (error) {
      throw Exception('Failed to get crime category: $error');
    }
  }

  // ==================== POSTS ====================

  /// Create a new crime report post
  Future<Map<String, dynamic>> createPost({
    required int crimeCategoryId,
    required String title,
    required String description,
    required String location,
    List<String>? evidenceFiles,
  }) async {
    try {
      if (currentUser == null) throw Exception('User not logged in');

      final response =
          await client
              .from('posts')
              .insert({
                'user_id': currentUser!.id,
                'crime_category_id': crimeCategoryId,
                'title': title.trim(),
                'description': description.trim(),
                'location': location.trim(),
                'evidence_files': evidenceFiles ?? [],
              })
              .select()
              .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create post: $error');
    }
  }

  /// Get all posts with user and crime category information
  Future<List<Map<String, dynamic>>> getAllPosts({
    int? limit,
    int? offset,
  }) async {
    try {
      var query = client
          .from('posts')
          .select('''
            *,
            profiles!posts_user_id_fkey(username, profile_picture),
            crime_categories!posts_crime_category_id_fkey(crime_type, severity, icon, color)
          ''')
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get posts: $error');
    }
  }

  /// Get posts by current user
  Future<List<Map<String, dynamic>>> getCurrentUserPosts() async {
    try {
      if (currentUser == null) throw Exception('User not logged in');

      final response = await client
          .from('posts')
          .select('''
            *,
            crime_categories!posts_crime_category_id_fkey(crime_type, severity, icon, color)
          ''')
          .eq('user_id', currentUser!.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get user posts: $error');
    }
  }

  /// Get posts by crime category
  Future<List<Map<String, dynamic>>> getPostsByCategory(int categoryId) async {
    try {
      final response = await client
          .from('posts')
          .select('''
            *,
            profiles!posts_user_id_fkey(username, profile_picture),
            crime_categories!posts_crime_category_id_fkey(crime_type, severity, icon, color)
          ''')
          .eq('crime_category_id', categoryId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get posts by category: $error');
    }
  }

  /// Get single post by ID
  Future<Map<String, dynamic>?> getPostById(int postId) async {
    try {
      final response =
          await client
              .from('posts')
              .select('''
            *,
            profiles!posts_user_id_fkey(username, profile_picture),
            crime_categories!posts_crime_category_id_fkey(crime_type, severity, icon, color)
          ''')
              .eq('id', postId)
              .single();

      return response;
    } catch (error) {
      throw Exception('Failed to get post: $error');
    }
  }

  /// Update post (only by post owner)
  Future<void> updatePost({
    required int postId,
    String? title,
    String? description,
    String? location,
    List<String>? evidenceFiles,
  }) async {
    try {
      if (currentUser == null) throw Exception('User not logged in');

      // Check if user owns the post
      final post =
          await client
              .from('posts')
              .select('user_id')
              .eq('id', postId)
              .single();

      if (post['user_id'] != currentUser!.id) {
        throw Exception('You can only update your own posts');
      }

      Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updates['title'] = title.trim();
      if (description != null) updates['description'] = description.trim();
      if (location != null) updates['location'] = location.trim();
      if (evidenceFiles != null) updates['evidence_files'] = evidenceFiles;

      await client.from('posts').update(updates).eq('id', postId);
    } catch (error) {
      throw Exception('Failed to update post: $error');
    }
  }

  /// Delete post (only by post owner)
  Future<void> deletePost(int postId) async {
    try {
      if (currentUser == null) throw Exception('User not logged in');

      // Check if user owns the post
      final post =
          await client
              .from('posts')
              .select('user_id')
              .eq('id', postId)
              .single();

      if (post['user_id'] != currentUser!.id) {
        throw Exception('You can only delete your own posts');
      }

      await client.from('posts').delete().eq('id', postId);
    } catch (error) {
      throw Exception('Failed to delete post: $error');
    }
  }

  // ==================== FILE STORAGE ====================

  /// Upload file to Supabase Storage
  Future<String> uploadFile({
    required File file,
    required String bucket,
    String? fileName,
  }) async {
    try {
      if (currentUser == null) throw Exception('User not logged in');

      final fileExtension = file.path.split('.').last;
      final uploadFileName =
          fileName ??
          '${currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';

      final uploadPath = await client.storage
          .from(bucket)
          .upload(uploadFileName, file);

      return client.storage.from(bucket).getPublicUrl(uploadFileName);
    } catch (error) {
      throw Exception('Failed to upload file: $error');
    }
  }

  /// Upload profile picture
  Future<String> uploadProfilePicture(File imageFile) async {
    try {
      final publicUrl = await uploadFile(
        file: imageFile,
        bucket: 'profiles',
        fileName:
            'profile_${currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Update profile with new picture URL
      await updateUserProfile(profilePicture: publicUrl);

      return publicUrl;
    } catch (error) {
      throw Exception('Failed to upload profile picture: $error');
    }
  }

  /// Upload evidence files for posts
  Future<List<String>> uploadEvidenceFiles(List<File> files) async {
    try {
      List<String> uploadedUrls = [];

      for (File file in files) {
        final publicUrl = await uploadFile(file: file, bucket: 'evidence');
        uploadedUrls.add(publicUrl);
      }

      return uploadedUrls;
    } catch (error) {
      throw Exception('Failed to upload evidence files: $error');
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Check if user email is verified
  bool get isEmailVerified => currentUser?.emailConfirmedAt != null;

  /// Resend email verification
  Future<void> resendEmailVerification() async {
    try {
      if (currentUser?.email == null) {
        throw Exception('No user email found');
      }

      await client.auth.resend(
        type: OtpType.signup,
        email: currentUser!.email!,
      );
    } catch (error) {
      throw Exception('Failed to resend verification email: $error');
    }
  }

  /// Get user statistics
  Future<Map<String, int>> getUserStats() async {
    try {
      if (currentUser == null) throw Exception('User not logged in');

      final postsCount = await client
          .from('posts')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('user_id', currentUser!.id);

      return {'posts_count': postsCount.count ?? 0};
    } catch (error) {
      throw Exception('Failed to get user stats: $error');
    }
  }

  /// Search posts by title or description
  Future<List<Map<String, dynamic>>> searchPosts(String query) async {
    try {
      final response = await client
          .from('posts')
          .select('''
            *,
            profiles!posts_user_id_fkey(username, profile_picture),
            crime_categories!posts_crime_category_id_fkey(crime_type, severity, icon, color)
          ''')
          .or('title.ilike.%$query%,description.ilike.%$query%')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to search posts: $error');
    }
  }
}
