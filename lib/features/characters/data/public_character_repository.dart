import 'package:read_leaf/features/characters/domain/models/ai_character.dart';
import 'package:read_leaf/features/characters/domain/models/public_character.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import 'dart:async';

class PublicCharacterRepository {
  final _log = Logger('PublicCharacterRepository');
  final SupabaseClient _supabase;

  // Singleton instance
  static PublicCharacterRepository? _instance;

  // Factory constructor
  factory PublicCharacterRepository() {
    _instance ??= PublicCharacterRepository._internal(Supabase.instance.client);
    return _instance!;
  }

  // Private constructor
  PublicCharacterRepository._internal(this._supabase);

  // Get all public characters
  Future<List<PublicCharacter>> getAllPublicCharacters({
    int limit = 50,
    int offset = 0,
    String sortBy = 'created_at',
    bool descending = true,
    String? category,
    List<String>? tags,
  }) async {
    try {
      _log.info('Getting all public characters');

      // Start with base query - using the new unified 'characters' table
      dynamic query =
          _supabase.from('characters').select('*').eq('is_public', true);

      // Add category filter if specified
      if (category != null && category.isNotEmpty && category != 'All') {
        query = query.eq('category', category);
      }

      // Add tags filter if specified
      if (tags != null && tags.isNotEmpty) {
        query = query.contains('tags', tags);
      }

      // Add sorting and pagination
      query = query
          .order(sortBy, ascending: !descending)
          .range(offset, offset + limit - 1);

      final response = await query;
      final userId = _supabase.auth.currentUser?.id;

      // Separately check which characters are liked by the current user if logged in
      List<String> likedCharacterIds = [];
      if (userId != null) {
        try {
          final likes = await _supabase
              .from('character_likes')
              .select('character_id')
              .eq('user_id', userId);

          likedCharacterIds = (likes as List)
              .map((like) => like['character_id'] as String)
              .toList();
        } catch (e) {
          _log.warning('Error fetching likes: $e');
        }
      }

      return (response as List).map((json) {
        // Check if the character is liked by the current user
        final isLiked =
            userId != null && likedCharacterIds.contains(json['id']);

        // Add isLiked field to the JSON
        json['is_liked'] = isLiked;

        return _convertToPublicCharacter(json);
      }).toList();
    } catch (e, stack) {
      _log.severe('Error getting public characters', e, stack);
      return [];
    }
  }

  // Get public characters by category
  Future<List<PublicCharacter>> getPublicCharactersByCategory(
    String category, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      _log.info('Getting public characters by category: $category');

      final response = await _supabase
          .from('characters')
          .select('*')
          .eq('is_public', true)
          .eq('category', category)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final userId = _supabase.auth.currentUser?.id;

      // Separately check which characters are liked by the current user if logged in
      List<String> likedCharacterIds = [];
      if (userId != null) {
        try {
          final likes = await _supabase
              .from('character_likes')
              .select('character_id')
              .eq('user_id', userId);

          likedCharacterIds = (likes as List)
              .map((like) => like['character_id'] as String)
              .toList();
        } catch (e) {
          _log.warning('Error fetching likes: $e');
        }
      }

      return (response as List).map((json) {
        // Check if the character is liked by the current user
        final isLiked =
            userId != null && likedCharacterIds.contains(json['id']);

        // Add isLiked field to the JSON
        json['is_liked'] = isLiked;

        return _convertToPublicCharacter(json);
      }).toList();
    } catch (e, stack) {
      _log.severe('Error getting public characters by category', e, stack);
      return [];
    }
  }

  // Get trending public characters (most downloaded/liked)
  Future<List<PublicCharacter>> getTrendingPublicCharacters({
    int limit = 10,
  }) async {
    try {
      _log.info('Getting trending public characters');

      final response = await _supabase
          .from('characters')
          .select('*')
          .eq('is_public', true)
          .order('download_count', ascending: false)
          .limit(limit);

      final userId = _supabase.auth.currentUser?.id;

      // Separately check which characters are liked by the current user if logged in
      List<String> likedCharacterIds = [];
      if (userId != null) {
        try {
          final likes = await _supabase
              .from('character_likes')
              .select('character_id')
              .eq('user_id', userId);

          likedCharacterIds = (likes as List)
              .map((like) => like['character_id'] as String)
              .toList();
        } catch (e) {
          _log.warning('Error fetching likes: $e');
        }
      }

      return (response as List).map((json) {
        // Check if the character is liked by the current user
        final isLiked =
            userId != null && likedCharacterIds.contains(json['id']);

        // Add isLiked field to the JSON
        json['is_liked'] = isLiked;

        return _convertToPublicCharacter(json);
      }).toList();
    } catch (e, stack) {
      _log.severe('Error getting trending public characters', e, stack);
      return [];
    }
  }

  // Get most liked public characters
  Future<List<PublicCharacter>> getMostLikedPublicCharacters({
    int limit = 10,
  }) async {
    try {
      _log.info('Getting most liked public characters');

      final response = await _supabase
          .from('characters')
          .select('*')
          .eq('is_public', true)
          .order('like_count', ascending: false)
          .limit(limit);

      final userId = _supabase.auth.currentUser?.id;

      // Separately check which characters are liked by the current user if logged in
      List<String> likedCharacterIds = [];
      if (userId != null) {
        try {
          final likes = await _supabase
              .from('character_likes')
              .select('character_id')
              .eq('user_id', userId);

          likedCharacterIds = (likes as List)
              .map((like) => like['character_id'] as String)
              .toList();
        } catch (e) {
          _log.warning('Error fetching likes: $e');
        }
      }

      return (response as List).map((json) {
        // Check if the character is liked by the current user
        final isLiked =
            userId != null && likedCharacterIds.contains(json['id']);

        // Add isLiked field to the JSON
        json['is_liked'] = isLiked;

        return _convertToPublicCharacter(json);
      }).toList();
    } catch (e, stack) {
      _log.severe('Error getting most liked public characters', e, stack);
      return [];
    }
  }

  // Get public characters created by the current user
  Future<List<PublicCharacter>> getUserPublicCharacters() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      _log.info('Getting public characters for user: $userId');

      final response = await _supabase
          .from('characters')
          .select('*')
          .eq('user_id', userId)
          .eq('is_public', true)
          .order('created_at', ascending: false);

      return (response as List).map((json) {
        // Check if the character is liked by the current user (always true for own characters)
        json['is_liked'] = true;

        return _convertToPublicCharacter(json);
      }).toList();
    } catch (e, stack) {
      _log.severe('Error getting user public characters', e, stack);
      return [];
    }
  }

  // Get a specific public character by ID
  Future<PublicCharacter?> getPublicCharacterById(String id) async {
    try {
      _log.info('Getting public character by ID: $id');

      final response =
          await _supabase.from('characters').select('*').eq('id', id).single();

      final userId = _supabase.auth.currentUser?.id;

      // Check if this character is liked by the current user
      bool isLiked = false;
      if (userId != null) {
        try {
          final like = await _supabase
              .from('character_likes')
              .select('id')
              .eq('user_id', userId)
              .eq('character_id', id)
              .maybeSingle();

          isLiked = like != null;
        } catch (e) {
          _log.warning('Error checking like status: $e');
        }
      }

      // Add isLiked field to the JSON
      response['is_liked'] = isLiked;

      return _convertToPublicCharacter(response);
    } catch (e, stack) {
      _log.severe('Error getting public character by ID', e, stack);
      return null;
    }
  }

  // Publish a character to the public repository
  Future<PublicCharacter?> publishCharacter(
    AiCharacter character, {
    required String category,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      _log.info('Publishing character: ${character.name}');

      // Create task_prompts JSONB object
      final taskPrompts = {
        'greeting': character.greetingMessage,
        'summary': character.summary,
        'scenario': character.scenario,
      };

      final payload = {
        'user_id': userId,
        'name': character.name,
        'summary': character.summary,
        'personality': character.personality,
        'scenario': character.scenario,
        'greeting_message': character.greetingMessage,
        'example_messages': character.exampleMessages,
        'avatar_image_path': character.avatarImagePath,
        'character_version': character.characterVersion,
        'system_prompt': character.systemPrompt,
        'tags': character.tags,
        'creator': character.creator,
        'is_public': true,
        'is_template': false,
        'category': category,
        'task_prompts': taskPrompts,
        'created_at': character.createdAt.toIso8601String(),
        'updated_at': character.updatedAt.toIso8601String(),
      };

      final response =
          await _supabase.from('characters').upsert(payload).select().single();

      // This character is implicitly liked by its creator
      response['is_liked'] = true;

      return _convertToPublicCharacter(response);
    } catch (e, stack) {
      _log.severe('Error publishing character', e, stack);
      return null;
    }
  }

  // Update a public character
  Future<PublicCharacter?> updatePublicCharacter(
    PublicCharacter character,
  ) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      if (character.userId != userId) {
        throw Exception('Cannot update a character you do not own');
      }

      _log.info('Updating public character: ${character.name}');

      // Create task_prompts JSONB object
      final taskPrompts = {
        'greeting': character.greetingMessage,
        'summary': character.summary,
        'scenario': character.scenario,
      };

      final payload = {
        'name': character.name,
        'summary': character.summary,
        'personality': character.personality,
        'scenario': character.scenario,
        'greeting_message': character.greetingMessage,
        'example_messages': character.exampleMessages,
        'avatar_image_path': character.avatarImagePath,
        'character_version': character.characterVersion,
        'system_prompt': character.systemPrompt,
        'tags': character.tags,
        'is_public': character.isPublic,
        'category': character.category,
        'task_prompts': taskPrompts,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('characters')
          .update(payload)
          .eq('id', character.id)
          .select()
          .single();

      response['is_liked'] = character.isLiked;

      return _convertToPublicCharacter(response);
    } catch (e, stack) {
      _log.severe('Error updating public character', e, stack);
      return null;
    }
  }

  // Delete a public character
  Future<bool> deletePublicCharacter(String id) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      _log.info('Deleting public character: $id');

      await _supabase
          .from('characters')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);

      return true;
    } catch (e, stack) {
      _log.severe('Error deleting public character', e, stack);
      return false;
    }
  }

  // Like a character
  Future<bool> likeCharacter(String characterId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      _log.info('Liking character: $characterId');

      await _supabase.from('character_likes').upsert({
        'user_id': userId,
        'character_id': characterId,
      });

      return true;
    } catch (e, stack) {
      _log.severe('Error liking character', e, stack);
      return false;
    }
  }

  // Unlike a character
  Future<bool> unlikeCharacter(String characterId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      _log.info('Unliking character: $characterId');

      await _supabase
          .from('character_likes')
          .delete()
          .eq('user_id', userId)
          .eq('character_id', characterId);

      return true;
    } catch (e, stack) {
      _log.severe('Error unliking character', e, stack);
      return false;
    }
  }

  // Increment download count
  Future<bool> incrementDownloadCount(String characterId) async {
    try {
      _log.info('Incrementing download count for character: $characterId');

      await _supabase.rpc('increment_character_download_count', params: {
        'character_id': characterId,
      });

      return true;
    } catch (e, stack) {
      _log.severe('Error incrementing download count', e, stack);
      return false;
    }
  }

  // Search public characters
  Future<List<PublicCharacter>> searchPublicCharacters(
    String query, {
    int limit = 20,
    String? category,
  }) async {
    try {
      _log.info('Searching public characters: $query');

      dynamic dbQuery = _supabase
          .from('characters')
          .select('*')
          .eq('is_public', true)
          .or('name.ilike.%$query%,summary.ilike.%$query%,tags.cs.{$query}');

      if (category != null && category.isNotEmpty && category != 'All') {
        dbQuery = dbQuery.eq('category', category);
      }

      final response =
          await dbQuery.order('created_at', ascending: false).limit(limit);

      final userId = _supabase.auth.currentUser?.id;

      // Separately check which characters are liked by the current user if logged in
      List<String> likedCharacterIds = [];
      if (userId != null) {
        try {
          final likes = await _supabase
              .from('character_likes')
              .select('character_id')
              .eq('user_id', userId);

          likedCharacterIds = (likes as List)
              .map((like) => like['character_id'] as String)
              .toList();
        } catch (e) {
          _log.warning('Error fetching likes: $e');
        }
      }

      return (response as List).map((json) {
        // Check if the character is liked by the current user
        final isLiked =
            userId != null && likedCharacterIds.contains(json['id']);

        // Add isLiked field to the JSON
        json['is_liked'] = isLiked;

        return _convertToPublicCharacter(json);
      }).toList();
    } catch (e, stack) {
      _log.severe('Error searching public characters', e, stack);
      return [];
    }
  }

  // Helper method to convert JSON from the characters table to PublicCharacter model
  PublicCharacter _convertToPublicCharacter(Map<String, dynamic> json) {
    try {
      // Process example_messages
      List<String> exampleMessages = [];
      if (json['example_messages'] != null) {
        if (json['example_messages'] is List) {
          exampleMessages = (json['example_messages'] as List)
              .map((e) => e.toString())
              .toList();
        }
      }

      // Process tags
      List<String> tags = [];
      if (json['tags'] != null) {
        if (json['tags'] is List) {
          tags = (json['tags'] as List).map((e) => e.toString()).toList();
        }
      }

      // Extract is_liked flag, defaulting to false if not present
      final isLiked = json['is_liked'] ?? false;

      return PublicCharacter(
        id: json['id'],
        userId: json['user_id'],
        name: json['name'],
        summary: json['summary'],
        personality: json['personality'],
        scenario: json['scenario'],
        greetingMessage: json['greeting_message'],
        exampleMessages: exampleMessages,
        avatarImagePath: json['avatar_image_path'],
        characterVersion: json['character_version'],
        systemPrompt: json['system_prompt'],
        tags: tags,
        creator: json['creator'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
        isPublic: json['is_public'] ?? true,
        downloadCount: json['download_count'] ?? 0,
        likeCount: json['like_count'] ?? 0,
        category: json['category'] ?? 'Custom',
        isLiked: isLiked,
      );
    } catch (e, stack) {
      _log.severe('Error converting to PublicCharacter: $e', e, stack);
      throw Exception(
          'Failed to convert database record to PublicCharacter: $e');
    }
  }
}
