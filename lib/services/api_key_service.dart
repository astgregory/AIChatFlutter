import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// Сервис для управления API ключами с шифрованным хранением
class ApiKeyService {
  static const String _apiKeyKey = 'encrypted_api_key';
  static const String _providerKey = 'selected_provider';
  static const String _baseUrlKey = 'base_url';
  static const String _salt = 'AIChatFlutter2024'; // Соль для шифрования
  
  // Кэш для результатов валидации (ключ: результат)
  static final Map<String, bool> _validationCache = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);
  static final Map<String, DateTime> _cacheTimestamps = {};

  /// Проверяет валидность API ключа OpenRouter
  static Future<bool> validateOpenRouterApiKey(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('https://openrouter.ai/api/v1/models'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Ошибка валидации API ключа: $e');
      return false;
    }
  }

  /// Проверяет валидность API ключа VseGPT
  static Future<bool> validateVseGptApiKey(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.vsetgpt.ru/v1/models'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Ошибка валидации API ключа VseGPT: $e');
      return false;
    }
  }

  /// Валидирует API ключ в зависимости от провайдера
  static Future<bool> validateApiKey(String apiKey, String provider) async {
    // Базовая проверка формата ключа
    if (apiKey.isEmpty || !apiKey.startsWith('sk-')) {
      return false;
    }

    // Проверяем длину ключа (OpenRouter ключи обычно 51 символ, VseGPT могут быть короче)
    if (apiKey.length < 20) {
      return false;
    }

    // Создаем ключ кэша
    final cacheKey = '${provider}_$apiKey';
    
    // Проверяем кэш
    if (_validationCache.containsKey(cacheKey)) {
      final timestamp = _cacheTimestamps[cacheKey];
      if (timestamp != null && DateTime.now().difference(timestamp) < _cacheExpiry) {
        print('Используем кэшированный результат валидации для $provider');
        return _validationCache[cacheKey]!;
      }
    }

    try {
      bool isValid;
      switch (provider) {
        case 'OpenRouter':
          isValid = await validateOpenRouterApiKey(apiKey);
          break;
        case 'VseGPT':
          isValid = await validateVseGptApiKey(apiKey);
          break;
        default:
          isValid = false;
      }
      
      // Сохраняем результат в кэш
      _validationCache[cacheKey] = isValid;
      _cacheTimestamps[cacheKey] = DateTime.now();
      
      return isValid;
    } catch (e) {
      print('Ошибка валидации API ключа: $e');
      return false;
    }
  }

  /// Шифрует API ключ
  static String _encryptApiKey(String apiKey) {
    final bytes = utf8.encode(apiKey + _salt);
    final digest = sha256.convert(bytes);
    return base64.encode(utf8.encode(apiKey + digest.toString().substring(0, 16)));
  }

  /// Расшифровывает API ключ
  static String _decryptApiKey(String encryptedKey) {
    try {
      final decoded = utf8.decode(base64.decode(encryptedKey));
      return decoded.substring(0, decoded.length - 16);
    } catch (e) {
      return '';
    }
  }

  /// Сохраняет API ключ в зашифрованном виде
  static Future<bool> saveApiKey(String apiKey, String provider, String baseUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedKey = _encryptApiKey(apiKey);
      
      await prefs.setString(_apiKeyKey, encryptedKey);
      await prefs.setString(_providerKey, provider);
      await prefs.setString(_baseUrlKey, baseUrl);
      
      return true;
    } catch (e) {
      print('Ошибка сохранения API ключа: $e');
      return false;
    }
  }

  /// Получает сохраненный API ключ
  static Future<String?> getApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedKey = prefs.getString(_apiKeyKey);
      
      if (encryptedKey != null && encryptedKey.isNotEmpty) {
        return _decryptApiKey(encryptedKey);
      }
      return null;
    } catch (e) {
      print('Ошибка получения API ключа: $e');
      return null;
    }
  }

  /// Получает сохраненного провайдера
  static Future<String> getProvider() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_providerKey) ?? 'OpenRouter';
    } catch (e) {
      return 'OpenRouter';
    }
  }

  /// Получает сохраненный базовый URL
  static Future<String> getBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_baseUrlKey) ?? 'https://openrouter.ai/api/v1';
    } catch (e) {
      return 'https://openrouter.ai/api/v1';
    }
  }

  /// Проверяет, есть ли валидный API ключ
  static Future<bool> hasValidApiKey() async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) return false;
    
    final provider = await getProvider();
    return await validateApiKey(apiKey, provider);
  }

  /// Очищает сохраненные данные
  static Future<void> clearApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_apiKeyKey);
      await prefs.remove(_providerKey);
      await prefs.remove(_baseUrlKey);
      
      // Очищаем кэш валидации
      _validationCache.clear();
      _cacheTimestamps.clear();
    } catch (e) {
      print('Ошибка очистки API ключа: $e');
    }
  }
  
  /// Очищает кэш валидации
  static void clearValidationCache() {
    _validationCache.clear();
    _cacheTimestamps.clear();
  }
}

