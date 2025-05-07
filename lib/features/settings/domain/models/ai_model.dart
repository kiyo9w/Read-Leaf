import 'package:equatable/equatable.dart';

enum AiModelType {
  gemini,
  wizardLM,
  mythoMax,
  claude,
  openAi,
}

enum AiModelHostType {
  google,
  server,
  anthropic,
  openAi,
}

class AiModel extends Equatable {
  final String name;
  final String description;
  final AiModelType type;
  final AiModelHostType hostType;
  final bool requiresApiKey;
  final String? apiKey;

  const AiModel({
    required this.name,
    required this.description,
    required this.type,
    required this.hostType,
    required this.requiresApiKey,
    this.apiKey,
  });

  static const List<AiModel> availableModels = [
    AiModel(
      name: 'Google Gemini Pro',
      description: 'Google\'s latest and most capable model',
      type: AiModelType.gemini,
      hostType: AiModelHostType.google,
      requiresApiKey: true,
    ),
    AiModel(
      name: 'WizardLM-2 8x22B',
      description: 'Server hosted model (Coming soon)',
      type: AiModelType.wizardLM,
      hostType: AiModelHostType.server,
      requiresApiKey: false,
    ),
    AiModel(
      name: 'MythoMax 13B',
      description: 'Server hosted model (Coming soon)',
      type: AiModelType.mythoMax,
      hostType: AiModelHostType.server,
      requiresApiKey: false,
    ),
    AiModel(
      name: 'Claude 3.5 Sonnet',
      description: 'Anthropic\'s powerful language model',
      type: AiModelType.claude,
      hostType: AiModelHostType.anthropic,
      requiresApiKey: true,
    ),
    AiModel(
      name: 'GPT-4 Mini',
      description: 'OpenAI\'s compact but capable model',
      type: AiModelType.openAi,
      hostType: AiModelHostType.openAi,
      requiresApiKey: true,
    ),
  ];

  AiModel copyWith({
    String? name,
    String? description,
    AiModelType? type,
    AiModelHostType? hostType,
    bool? requiresApiKey,
    String? apiKey,
  }) {
    return AiModel(
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      hostType: hostType ?? this.hostType,
      requiresApiKey: requiresApiKey ?? this.requiresApiKey,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  @override
  List<Object?> get props =>
      [name, description, type, hostType, requiresApiKey, apiKey];
}
