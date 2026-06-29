// Import JSON library
import 'dart:convert';
// Import HTTP client
import 'package:http/http.dart' as http;
// Import Flutter core classes
import 'package:flutter/foundation.dart';
// Import package for working with .env files
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Import API key service
import '../services/api_key_service.dart';

// Класс клиента для работы с API OpenRouter
class OpenRouterClient {
  // API ключ для авторизации
  final String? apiKey;
  // Базовый URL API
  final String? baseUrl;
  // Заголовки HTTP запросов
  final Map<String, String> headers;

  // Единственный экземпляр класса (Singleton)
  static final OpenRouterClient _instance = OpenRouterClient._internal();

  // Фабричный метод для получения экземпляра
  factory OpenRouterClient() {
    return _instance;
  }

  // Приватный конструктор для реализации Singleton
  OpenRouterClient._internal()
      : apiKey = null, // API ключ будет получаться динамически
        baseUrl = null, // Базовый URL будет получаться динамически
        headers = {
          'Content-Type': 'application/json', // Указание типа контента
          'X-Title': 'AI Chat Flutter', // Название приложения
        } {
    // Инициализация клиента
    _initializeClient();
  }

  // Метод инициализации клиента
  void _initializeClient() {
    try {
      if (kDebugMode) {
        print('Initializing OpenRouterClient...');
      }

      if (kDebugMode) {
        print('OpenRouterClient initialized successfully');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error initializing OpenRouterClient: $e');
        print('Stack trace: $stackTrace');
      }
      rethrow;
    }
  }

  /// Получает текущий API ключ из ApiKeyProvider
  Future<String?> getCurrentApiKey() async {
    try {
      return await ApiKeyService.getApiKey();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting API key: $e');
      }
      return null;
    }
  }

  /// Получает текущий базовый URL из ApiKeyProvider
  Future<String?> getCurrentBaseUrl() async {
    try {
      return await ApiKeyService.getBaseUrl();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting base URL: $e');
      }
      return null;
    }
  }

  /// Получает заголовки с текущим API ключом
  Future<Map<String, String>> getHeaders() async {
    final currentApiKey = await getCurrentApiKey();
    final currentHeaders = Map<String, String>.from(headers);
    
    if (currentApiKey != null) {
      currentHeaders['Authorization'] = 'Bearer $currentApiKey';
    }
    
    return currentHeaders;
  }

  // Метод получения списка доступных моделей
  Future<List<Map<String, dynamic>>> getModels() async {
    try {
      // Получаем текущий базовый URL и заголовки
      final currentBaseUrl = await getCurrentBaseUrl();
      final currentHeaders = await getHeaders();
      
      if (kDebugMode) {
        print('=== DEBUG: getModels ===');
        print('Base URL: $currentBaseUrl');
        print('Headers: $currentHeaders');
      }
      
      if (currentBaseUrl == null) {
        if (kDebugMode) {
          print('Base URL not configured, returning default models');
        }
        return _getDefaultModels();
      }
      
      // Проверяем наличие API ключа
      final apiKey = await getCurrentApiKey();
      if (kDebugMode) {
        print('API Key: ${apiKey != null ? 'present' : 'null'}');
      }
      
      if (apiKey == null || apiKey.isEmpty) {
        if (kDebugMode) {
          print('API key not configured, returning default models');
        }
        return _getDefaultModels();
      }
      
      // Выполнение GET запроса для получения моделей
      final response = await http.get(
        Uri.parse('$currentBaseUrl/models'),
        headers: currentHeaders,
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print('Models response status: ${response.statusCode}');
        print('Models response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        // Парсинг данных о моделях
        final modelsData = json.decode(response.body);
        if (modelsData['data'] != null) {
          return (modelsData['data'] as List)
              .map((model) => {
                    'id': model['id'] as String,
                    'name': (() {
                      try {
                        return utf8.decode((model['name'] as String).codeUnits);
                      } catch (e) {
                        // Remove invalid UTF-8 characters and try again
                        final cleaned = (model['name'] as String)
                            .replaceAll(RegExp(r'[^\x00-\x7F]'), '');
                        return utf8.decode(cleaned.codeUnits);
                      }
                    })(),
                    'pricing': {
                      'prompt': model['pricing']['prompt'] as String,
                      'completion': model['pricing']['completion'] as String,
                    },
                    'context_length': (model['context_length'] ??
                            model['top_provider']['context_length'] ??
                            0)
                        .toString(),
                  })
              .toList();
        }
        throw Exception('Invalid API response format');
      } else if (response.statusCode == 401) {
        // Неавторизованный доступ - API ключ неверный
        if (kDebugMode) {
          print('Unauthorized access - invalid API key');
        }
        return _getDefaultModels();
      } else {
        // Другие ошибки HTTP
        if (kDebugMode) {
          print('HTTP error ${response.statusCode}: ${response.body}');
        }
        return _getDefaultModels();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting models: $e');
      }
      // Возвращение моделей по умолчанию в случае ошибки
      return _getDefaultModels();
    }
  }

  /// Возвращает модели по умолчанию
  List<Map<String, dynamic>> _getDefaultModels() {
    return [
      {'id': 'deepseek/deepseek-chat-v3-0324:free', 'name': 'DeepSeek V3 0324 (free)'},
      {'id': 'claude-3-sonnet', 'name': 'Claude 3.5 Sonnet'},
      {'id': 'gpt-3.5-turbo', 'name': 'GPT-3.5 Turbo'},
    ];
  }

  // Метод отправки сообщения через API
  Future<Map<String, dynamic>> sendMessage(String message, String model) async {
    try {
      if (kDebugMode) {
        print('=== DEBUG: sendMessage ===');
        print('Message: $message');
        print('Model: $model');
      }
      
      // Получаем текущий базовый URL и заголовки
      final currentBaseUrl = await getCurrentBaseUrl();
      final currentHeaders = await getHeaders();
      
      if (kDebugMode) {
        print('Base URL: $currentBaseUrl');
        print('Headers: $currentHeaders');
      }
      
      if (currentBaseUrl == null) {
        return {'error': 'Base URL not configured'};
      }
      
      // Проверяем наличие API ключа
      final apiKey = await getCurrentApiKey();
      if (kDebugMode) {
        print('API Key: ${apiKey != null ? 'present' : 'null'}');
      }
      
      if (apiKey == null || apiKey.isEmpty) {
        return {'error': 'API key not configured'};
      }
      
      // Подготовка данных для отправки
      final data = {
        'model': model, // Модель для генерации ответа
        'messages': [
          {'role': 'user', 'content': message} // Сообщение пользователя
        ],
        'max_tokens': int.parse(dotenv.env['MAX_TOKENS'] ??
            '1000'), // Максимальное количество токенов
        'temperature': double.parse(
            dotenv.env['TEMPERATURE'] ?? '0.7'), // Температура генерации
        'stream': false, // Отключение потоковой передачи
      };

      if (kDebugMode) {
        print('Sending message to API: ${json.encode(data)}');
      }

      // Выполнение POST запроса
      final response = await http.post(
        Uri.parse('$currentBaseUrl/chat/completions'),
        headers: currentHeaders,
        body: json.encode(data),
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Message response status: ${response.statusCode}');
        print('Message response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        // Успешный ответ
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        return responseData;
      } else if (response.statusCode == 401) {
        // Неавторизованный доступ - API ключ неверный
        return {'error': 'Invalid API key. Please check your settings.'};
      } else if (response.statusCode == 429) {
        // Превышен лимит запросов
        return {'error': 'Rate limit exceeded. Please try again later.'};
      } else {
        // Обработка других ошибок
        try {
          final errorData = json.decode(utf8.decode(response.bodyBytes));
          return {
            'error': errorData['error']?['message'] ?? 'HTTP error ${response.statusCode}'
          };
        } catch (parseError) {
          return {
            'error': 'HTTP error ${response.statusCode}: ${response.body}'
          };
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
      return {'error': e.toString()};
    }
  }

  // Метод получения текущего баланса
  Future<String> getBalance() async {
    try {
      // Получаем текущий базовый URL и заголовки
      final currentBaseUrl = await getCurrentBaseUrl();
      final currentHeaders = await getHeaders();
      
      if (currentBaseUrl == null) {
        return 'Balance unavailable';
      }
      
      // Проверяем наличие API ключа
      final apiKey = await getCurrentApiKey();
      if (apiKey == null || apiKey.isEmpty) {
        return 'Balance unavailable';
      }
      
      // Выполнение GET запроса для получения баланса
      final response = await http.get(
        Uri.parse(currentBaseUrl.contains('vsegpt.ru') == true
            ? '$currentBaseUrl/balance'
            : '$currentBaseUrl/credits'),
        headers: currentHeaders,
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        print('Balance response status: ${response.statusCode}');
        print('Balance response body: ${response.body}');
      }

      if (response.statusCode == 200) {
        // Парсинг данных о балансе
        try {
          final data = json.decode(response.body);
          if (data != null && data['data'] != null) {
            if (currentBaseUrl.contains('vsegpt.ru') == true) {
              final credits =
                  double.tryParse(data['data']['credits'].toString()) ??
                      0.0; // Доступно средств
              return '${credits.toStringAsFixed(2)}₽'; // Расчет доступного баланса
            } else {
              final credits = data['data']['total_credits'] ?? 0; // Общие кредиты
              final usage =
                  data['data']['total_usage'] ?? 0; // Использованные кредиты
              return '\$${(credits - usage).toStringAsFixed(2)}'; // Расчет доступного баланса
            }
          }
        } catch (parseError) {
          if (kDebugMode) {
            print('Error parsing balance response: $parseError');
          }
        }
      } else if (response.statusCode == 401) {
        // Неавторизованный доступ
        return 'Balance unavailable';
      }
      
      // Возвращение значения по умолчанию
      return currentBaseUrl.contains('vsegpt.ru') == true
          ? '0.00₽'
          : '\$0.00';
    } catch (e) {
      if (kDebugMode) {
        print('Error getting balance: $e');
      }
      return 'Error'; // Возвращение ошибки в случае исключения
    }
  }

  // Метод форматирования цен
  String formatPricing(double pricing) {
    try {
      // Используем текущий базовый URL для определения провайдера
      // По умолчанию используем OpenRouter формат
      return '\$${(pricing * 1000000).toStringAsFixed(3)}/M';
    } catch (e) {
      if (kDebugMode) {
        print('Error formatting pricing: $e');
      }
      return '0.00';
    }
  }
}

