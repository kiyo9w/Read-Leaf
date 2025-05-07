import 'package:read_leaf/features/characters/domain/models/ai_character.dart';
import 'package:read_leaf/features/settings/domain/models/ai_model.dart';
import 'package:read_leaf/features/companion_chat/data/gemini_service.dart';
import 'package:read_leaf/features/companion_chat/data/claude_service.dart';
import 'package:read_leaf/features/companion_chat/data/openai_service.dart';
import 'package:read_leaf/features/characters/data/ai_character_service.dart';
import 'package:read_leaf/features/companion_chat/data/chat_service.dart';
import 'package:logging/logging.dart';
import 'package:get_it/get_it.dart';

abstract class AiService {
  final _log = Logger('AiService');
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  set isInitialized(bool value) => _isInitialized = value;

  Future<void> initialize();

  Future<String> askAboutText(
    String selectedText, {
    String? customPrompt,
    required String bookTitle,
    required int currentPage,
    required int totalPages,
    String task = 'analyze_text',
  });

  Future<void> setCustomEncouragementPrompt(String customPrompt);

  Future<void> dispose();
}

class AiServiceFactory {
  static AiService createService(AiModel model, String? apiKey) {
    final characterService = GetIt.I<AiCharacterService>();
    final chatService = GetIt.I<ChatService>();

    switch (model.type) {
      case AiModelType.gemini:
        return GeminiService(apiKey, characterService, chatService);
      case AiModelType.claude:
        return ClaudeService(apiKey);
      case AiModelType.openAi:
        return OpenAiService(apiKey);
      case AiModelType.wizardLM:
      case AiModelType.mythoMax:
        throw UnimplementedError(
            'Server hosted models are not yet implemented');
    }
  }
}
