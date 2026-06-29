import 'package:flutter/foundation.dart';
import '../services/api_key_service.dart';

/// Провайдер для управления состоянием API ключа
class ApiKeyProvider extends ChangeNotifier {
  bool _hasValidApiKey = false;
  bool _isLoading = true;
  String? _currentApiKey;
  String _currentProvider = 'OpenRouter';
  String _currentBaseUrl = 'https://openrouter.ai/api/v1';

  bool get hasValidApiKey => _hasValidApiKey;
  bool get isLoading => _isLoading;
  String? get currentApiKey => _currentApiKey;
  String get currentProvider => _currentProvider;
  String get currentBaseUrl => _currentBaseUrl;

  /// Инициализация провайдера
  Future<void> initialize() async {
    await _loadApiKeyState();
  }

  /// Загружает состояние API ключа из хранилища
  Future<void> _loadApiKeyState() async {
    try {
      print('=== DEBUG: _loadApiKeyState ===');
      
      _currentApiKey = await ApiKeyService.getApiKey();
      _currentProvider = await ApiKeyService.getProvider();
      _currentBaseUrl = await ApiKeyService.getBaseUrl();
      
      print('API Key loaded: ${_currentApiKey != null ? 'present' : 'null'}');
      print('Provider: $_currentProvider');
      print('Base URL: $_currentBaseUrl');
      
      if (_currentApiKey != null && _currentApiKey!.isNotEmpty) {
        print('Validating API key...');
        _hasValidApiKey = await ApiKeyService.validateApiKey(_currentApiKey!, _currentProvider);
        print('API key validation result: $_hasValidApiKey');
      } else {
        _hasValidApiKey = false;
        print('No API key found, setting hasValidApiKey to false');
      }
    } catch (e) {
      _hasValidApiKey = false;
      print('Ошибка загрузки состояния API ключа: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      print('Final state - hasValidApiKey: $_hasValidApiKey, isLoading: $_isLoading');
    }
  }

  /// Обновляет API ключ и уведомляет об изменениях
  Future<bool> updateApiKey(String apiKey, String provider, String baseUrl) async {
    try {
      print('=== DEBUG: updateApiKey ===');
      print('New API Key: [HIDDEN]');
      print('New Provider: $provider');
      print('New Base URL: $baseUrl');
      print('Current state - hasValidApiKey: $_hasValidApiKey');
      
      // Проверяем, изменился ли API ключ
      if (_currentApiKey == apiKey && 
          _currentProvider == provider && 
          _currentBaseUrl == baseUrl &&
          _hasValidApiKey) {
        // Настройки не изменились и уже валидны
        print('Settings unchanged and already valid, returning true');
        return true;
      }
      
      print('Validating new API key...');
      // Валидируем API ключ только если он изменился
      final isValid = await ApiKeyService.validateApiKey(apiKey, provider);
      print('API key validation result: $isValid');
      
      if (!isValid) {
        print('API key validation failed');
        return false;
      }

      // Сохраняем настройки
      final success = await ApiKeyService.saveApiKey(apiKey, provider, baseUrl);
      
      if (success) {
        // Обновляем локальное состояние
        _currentApiKey = apiKey;
        _currentProvider = provider;
        _currentBaseUrl = baseUrl;
        _hasValidApiKey = true;
        
        print('API ключ успешно обновлен: $_hasValidApiKey');
        
        // Уведомляем все слушатели об изменении
        notifyListeners();
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Ошибка обновления API ключа: $e');
      return false;
    }
  }

  /// Очищает API ключ
  Future<void> clearApiKey() async {
    try {
      await ApiKeyService.clearApiKey();
      
      // Сбрасываем локальное состояние
      _currentApiKey = null;
      _currentProvider = 'OpenRouter';
      _currentBaseUrl = 'https://openrouter.ai/api/v1';
      _hasValidApiKey = false;
      
      // Уведомляем все слушатели об изменении
      notifyListeners();
      
      print('API ключ успешно сброшен');
    } catch (e) {
      print('Ошибка сброса API ключа: $e');
      rethrow;
    }
  }

  /// Принудительно обновляет состояние
  Future<void> refreshState() async {
    await _loadApiKeyState();
  }
}

