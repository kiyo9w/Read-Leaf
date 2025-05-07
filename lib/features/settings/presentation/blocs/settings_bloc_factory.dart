import 'package:flutter/material.dart';
import 'package:read_leaf/features/settings/presentation/blocs/settings_bloc.dart';
import 'package:read_leaf/features/settings/domain/models/ai_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsBlocFactory {
  static Future<SettingsBloc> create() async {
    final prefs = await SharedPreferences.getInstance();

    // Load reader loading screen preference (default to true if not set)
    final showLoadingScreen = prefs.getBool('show_loading_screen') ?? true;

    // Load reading reminders preference (default to true if not set)
    final remindersEnabled = prefs.getBool('reminders_enabled') ?? true;

    // Load selected AI model
    final selectedModelType =
        prefs.getString('selected_ai_model') ?? AiModelType.gemini.name;
    final selectedModel = AiModel.availableModels.firstWhere(
      (model) => model.type.name == selectedModelType,
      orElse: () => AiModel.availableModels.first,
    );

    // Load API keys
    final Map<AiModelType, String> apiKeys = {};
    for (final model in AiModel.availableModels) {
      if (model.requiresApiKey) {
        final key = prefs.getString('ai_model_key_${model.type.name}');
        if (key != null) {
          apiKeys[model.type] = key;
        }
      }
    }

    // Load locale
    final languageCode = prefs.getString('language_code') ?? 'en';
    final countryCode = prefs.getString('country_code') ?? '';
    final locale = Locale(languageCode, countryCode);

    // Create and return a new SettingsBloc
    final bloc = SettingsBloc();

    // Manually initialize state with the correct values
    bloc.add(SettingsInitialized());

    return bloc;
  }
}
