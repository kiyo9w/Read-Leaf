import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:read_leaf/features/companion_chat/data/ai_service.dart';

class ClaudeService extends AiService {
  final String? _apiKey;
  final _log = Logger('ClaudeService');
  static const String _baseUrl = 'https://api.anthropic.com/v1';

  ClaudeService(this._apiKey);

  @override
  Future<void> initialize() async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      throw Exception('Claude API key is not set');
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
      throw Exception('Claude service is not initialized');
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
        Uri.parse('$_baseUrl/messages'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey!,
          'anthropic-version': '2023-06-01',
        },
        body: json.encode({
          'model': 'claude-3-sonnet-20240229',
          'max_tokens': 1000,
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['content'][0]['text'];
      } else {
        _log.warning(
            'Claude API error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get response from Claude');
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
    // Claude doesn't need to store custom prompts as they're built dynamically
  }

  @override
  Future<void> dispose() async {
    // No cleanup needed for Claude service
  }
}
