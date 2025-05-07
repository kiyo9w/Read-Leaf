import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:read_leaf/features/settings/domain/models/ai_model.dart';

// Settings Events
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsInitialized extends SettingsEvent {}

class LoadingScreenToggled extends SettingsEvent {
  final bool value;

  const LoadingScreenToggled(this.value);

  @override
  List<Object?> get props => [value];
}

class RemindersToggled extends SettingsEvent {
  final bool value;

  const RemindersToggled(this.value);

  @override
  List<Object?> get props => [value];
}

class AiModelChanged extends SettingsEvent {
  final AiModel model;

  const AiModelChanged(this.model);

  @override
  List<Object?> get props => [model];
}

class AiModelApiKeyUpdated extends SettingsEvent {
  final String apiKey;

  const AiModelApiKeyUpdated(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class LocaleChanged extends SettingsEvent {
  final Locale locale;

  const LocaleChanged(this.locale);

  @override
  List<Object?> get props => [locale];
}

// Settings State
class SettingsState extends Equatable {
  final bool showLoadingScreen;
  final bool remindersEnabled;
  final AiModel selectedModel;
  final Map<AiModelType, String> apiKeys;
  final Locale locale;

  const SettingsState({
    required this.showLoadingScreen,
    required this.remindersEnabled,
    required this.selectedModel,
    required this.apiKeys,
    required this.locale,
  });

  @override
  List<Object?> get props =>
      [showLoadingScreen, remindersEnabled, selectedModel, apiKeys, locale];

  SettingsState copyWith({
    bool? showLoadingScreen,
    bool? remindersEnabled,
    AiModel? selectedModel,
    Map<AiModelType, String>? apiKeys,
    Locale? locale,
  }) {
    return SettingsState(
      showLoadingScreen: showLoadingScreen ?? this.showLoadingScreen,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      selectedModel: selectedModel ?? this.selectedModel,
      apiKeys: apiKeys ?? this.apiKeys,
      locale: locale ?? this.locale,
    );
  }
}

// Settings Bloc
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc()
      : super(SettingsState(
          showLoadingScreen: true,
          remindersEnabled: true,
          selectedModel: AiModel.availableModels.first,
          apiKeys: const {},
          locale: const Locale('en', ''),
        )) {
    on<SettingsInitialized>(_onInitialized);
    on<LoadingScreenToggled>(_onLoadingScreenToggled);
    on<RemindersToggled>(_onRemindersToggled);
    on<AiModelChanged>(_onAiModelChanged);
    on<AiModelApiKeyUpdated>(_onAiModelApiKeyUpdated);
    on<LocaleChanged>(_onLocaleChanged);

    // Initialize settings
    add(SettingsInitialized());
  }

  Future<void> _onInitialized(
      SettingsInitialized event, Emitter<SettingsState> emit) async {
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

    emit(state.copyWith(
      showLoadingScreen: showLoadingScreen,
      remindersEnabled: remindersEnabled,
      selectedModel: selectedModel,
      apiKeys: apiKeys,
      locale: locale,
    ));
  }

  Future<void> _onLoadingScreenToggled(
      LoadingScreenToggled event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_loading_screen', event.value);

    emit(state.copyWith(
      showLoadingScreen: event.value,
    ));
  }

  Future<void> _onRemindersToggled(
      RemindersToggled event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminders_enabled', event.value);

    emit(state.copyWith(
      remindersEnabled: event.value,
    ));
  }

  Future<void> _onAiModelChanged(
      AiModelChanged event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_ai_model', event.model.type.name);

    emit(state.copyWith(
      selectedModel: event.model,
    ));
  }

  Future<void> _onAiModelApiKeyUpdated(
      AiModelApiKeyUpdated event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final currentModel = state.selectedModel;

    // Save API key
    await prefs.setString(
        'ai_model_key_${currentModel.type.name}', event.apiKey);

    // Update state
    final newApiKeys = Map<AiModelType, String>.from(state.apiKeys);
    newApiKeys[currentModel.type] = event.apiKey;

    emit(state.copyWith(
      apiKeys: newApiKeys,
    ));
  }

  Future<void> _onLocaleChanged(
      LocaleChanged event, Emitter<SettingsState> emit) async {
    final prefs = await SharedPreferences.getInstance();

    // Save language preferences
    await prefs.setString('language_code', event.locale.languageCode);
    await prefs.setString('country_code', event.locale.countryCode ?? '');

    emit(state.copyWith(
      locale: event.locale,
    ));
  }
}
