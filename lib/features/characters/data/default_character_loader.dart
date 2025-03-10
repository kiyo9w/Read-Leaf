import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:read_leaf/features/characters/domain/models/ai_character.dart';

/// Utility to load built-in characters that ship with the app
class DefaultCharacterLoader {
  static final _log = Logger('DefaultCharacterLoader');
  static List<AiCharacter>? _cachedCharacters;

  /// Load default characters from assets
  static Future<List<AiCharacter>> loadDefaultCharacters() async {
    // Return from cache if available
    if (_cachedCharacters != null) {
      return _cachedCharacters!;
    }

    try {
      _log.info('Loading default characters from assets');
      final jsonString = await rootBundle
          .loadString('lib/features/characters/data/default_characters.json');
      final jsonMap = json.decode(jsonString);
      final charactersList = jsonMap['characters'] as List;

      // Convert each character JSON to an AiCharacter object
      final characters = charactersList
          .map((charJson) {
            try {
              final Map<String, dynamic> characterData =
                  charJson.containsKey('data') ? charJson['data'] : charJson;
              return AiCharacter.fromJson(characterData);
            } catch (e) {
              _log.warning('Failed to parse character: $e');
              return null;
            }
          })
          .whereType<AiCharacter>() // Filter out nulls
          .toList();

      if (characters.isEmpty) {
        throw Exception('No valid characters could be parsed from JSON');
      }

      // Cache the characters
      _cachedCharacters = characters;

      _log.info('Successfully loaded ${characters.length} default characters');
      return characters;
    } catch (e, stack) {
      _log.severe('Error loading default characters', e, stack);
      // Return empty list on error
      return [];
    }
  }

  /// Get a specific default character by name
  static Future<AiCharacter?> getDefaultCharacter(String name) async {
    try {
      final characters = await loadDefaultCharacters();
      return characters.firstWhere(
        (char) => char.name == name,
        orElse: () => throw Exception('Character not found: $name'),
      );
    } catch (e) {
      _log.warning('Error getting default character: $name', e);
      return null;
    }
  }

  /// Clear the character cache
  static void clearCache() {
    _cachedCharacters = null;
    _log.info('Default character cache cleared');
  }

  /// Validate all default characters
  static Future<bool> validateDefaultCharacters() async {
    try {
      final characters = await loadDefaultCharacters();
      return characters.isNotEmpty;
    } catch (e) {
      _log.warning('Error validating default characters: $e');
      return false;
    }
  }
}
