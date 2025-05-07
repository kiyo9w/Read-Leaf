import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:read_leaf/features/companion_chat/data/ai_service.dart';

class OpenAiService extends AiService {
  final String? _apiKey;
  final _log = Logger('OpenAiService');
  static const String _baseUrl = 'https://api.openai.com/v1';

  OpenAiService(this._apiKey);

  @override
  Future<void> initialize() async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('OpenAI API key is not set');
    }
    isInitialized = true;
  }

  @override
  Future<String> askAboutText(
    String selectedText, {
    String? customPrompt,
    required String bookTitle,
    required int currentPage,
    required int totalPages,
    String task = 'analyze_text',
  }) async {
    if (!isInitialized) {
      throw Exception('OpenAI service is not initialized');
    }

    try {
      final prompt = _buildPrompt(
        selectedText,
        customPrompt: customPrompt,
        bookTitle: bookTitle,
        currentPage: currentPage,
        totalPages: totalPages,
        task: task,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful AI reading companion.',
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        _log.warning(
            'OpenAI API error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get response from OpenAI');
      }
    } catch (e) {
      _log.severe('Error in askAboutText: $e');
      rethrow;
    }
  }

  String _buildPrompt(
    String selectedText, {
    String? customPrompt,
    required String bookTitle,
    required int currentPage,
    required int totalPages,
    required String task,
  }) {
    // Build prompt based on task type
    if (task == 'encouragement') {
      return '''You are an AI reading companion encouraging the user to continue reading their book.

Book Context:
Title: $bookTitle
Current Page: $currentPage/$totalPages
Progress: ${((currentPage / totalPages) * 100).toStringAsFixed(1)}%

Task: Provide a brief, encouraging message to motivate the user to continue reading.
Keep it concise, friendly, and focused on their progress.''';
    }

    return '''You are an AI reading companion helping the user understand their book.

Book Context:
Title: $bookTitle
Current Page: $currentPage/$totalPages
Selected Text: $selectedText

${customPrompt ?? 'Please analyze this text passage and provide insights.'} 
Keep your response concise and focused on the text.''';
  }

  @override
  Future<void> setCustomEncouragementPrompt(String customPrompt) async {
    // OpenAI doesn't need to store custom prompts as they're built dynamically
  }

  @override
  Future<void> dispose() async {
    // No cleanup needed for OpenAI service
  }
}
