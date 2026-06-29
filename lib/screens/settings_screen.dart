import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/api_key_provider.dart';

/// Экран настроек провайдера и API ключей
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  String _selectedProvider = 'OpenRouter';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  /// Загружает текущие настройки из провайдера
  Future<void> _loadCurrentSettings() async {
    final apiKeyProvider = context.read<ApiKeyProvider>();
    
    setState(() {
      // Загружаем API ключ только если он есть и валиден
      if (apiKeyProvider.hasValidApiKey && apiKeyProvider.currentApiKey != null) {
        _apiKeyController.text = apiKeyProvider.currentApiKey!;
      } else {
        _apiKeyController.clear();
      }
      _selectedProvider = apiKeyProvider.currentProvider;
      _baseUrlController.text = apiKeyProvider.currentBaseUrl;
    });
  }
  
  /// Сбрасывает API ключ
  Future<void> _resetApiKey() async {
    try {
      final apiKeyProvider = context.read<ApiKeyProvider>();
      await apiKeyProvider.clearApiKey();
      
      setState(() {
        _apiKeyController.clear();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API ключ сброшен'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка сброса ключа: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Сохраняет настройки
  Future<void> _saveSettings() async {
    // Проверяем, есть ли уже валидный ключ
    final apiKeyProvider = context.read<ApiKeyProvider>();
    
    if (apiKeyProvider.hasValidApiKey) {
      // Если ключ уже валиден, показываем сообщение
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API ключ уже настроен и валиден'),
            backgroundColor: Colors.blue,
          ),
        );
      }
      return;
    }
    
    // Проверяем, введен ли новый ключ
    if (_apiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пожалуйста, введите API ключ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Обновляем API ключ через провайдер
      final success = await apiKeyProvider.updateApiKey(
        _apiKeyController.text,
        _selectedProvider,
        _baseUrlController.text,
      );

      if (mounted) {
        if (success) {
          // Очищаем поле ввода
          _apiKeyController.clear();
          
          // Показываем сообщение об успехе
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('API ключ успешно сохранен и валидирован!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Остаемся на экране настроек - пользователь сам решит, куда перейти
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Неверный API ключ. Проверьте ключ и попробуйте снова.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Настройки',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF262626),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Выбор провайдера
              Card(
                color: const Color(0xFF333333),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Провайдер',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedProvider,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Выберите провайдера',
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                        dropdownColor: const Color(0xFF333333),
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem(
                            value: 'OpenRouter',
                            child: Text('OpenRouter.ai'),
                          ),
                          DropdownMenuItem(
                            value: 'VseGPT',
                            child: Text('VseGPT.ru'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedProvider = value!;
                            if (value == 'OpenRouter') {
                              _baseUrlController.text = 'https://openrouter.ai/api/v1';
                            } else {
                              _baseUrlController.text = 'https://api.vsetgpt.ru/v1';
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

                             // API ключ
               Card(
                 color: const Color(0xFF333333),
                 child: Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                           Text(
                             'API ключ',
                             style: GoogleFonts.roboto(
                               fontSize: 18,
                               fontWeight: FontWeight.w600,
                               color: Colors.white,
                             ),
                           ),
                                                       // Кнопка сброса (активна только при наличии валидного ключа)
                            if (context.watch<ApiKeyProvider>().hasValidApiKey)
                              IconButton(
                                onPressed: _resetApiKey,
                                icon: const Icon(Icons.delete_forever, color: Colors.red),
                                tooltip: 'Сбросить ключ',
                              ),
                         ],
                       ),
                       const SizedBox(height: 12),
                       // Контейнер для API ключа
                       Consumer<ApiKeyProvider>(
                         builder: (context, apiKeyProvider, child) {
                           if (apiKeyProvider.hasValidApiKey) {
                             // Если ключ валиден - показываем заблокированный контейнер
                             return Container(
                               width: double.infinity,
                               padding: const EdgeInsets.all(16.0),
                               decoration: BoxDecoration(
                                 border: Border.all(color: Colors.green, width: 2),
                                 borderRadius: BorderRadius.circular(8),
                                 color: const Color(0xFF2A2A2A),
                               ),
                               child: Row(
                                 children: [
                                   const Icon(Icons.check_circle, color: Colors.green, size: 24),
                                   const SizedBox(width: 12),
                                   Expanded(
                                     child: Text(
                                       'Ключ валиден',
                                       style: GoogleFonts.roboto(
                                         fontSize: 16,
                                         fontWeight: FontWeight.w500,
                                         color: Colors.green,
                                       ),
                                     ),
                                   ),
                                   Text(
                                     'sk-***${apiKeyProvider.currentApiKey?.substring(3, 6)}***',
                                     style: GoogleFonts.roboto(
                                       fontSize: 14,
                                       color: Colors.white70,
                                     ),
                                   ),
                                 ],
                               ),
                             );
                           } else {
                             // Если ключа нет - показываем поле ввода
                             return TextFormField(
                               controller: _apiKeyController,
                               decoration: const InputDecoration(
                                 border: OutlineInputBorder(),
                                 labelText: 'Введите ваш API ключ',
                                 labelStyle: TextStyle(color: Colors.white70),
                                 hintText: 'sk-...',
                                 hintStyle: TextStyle(color: Colors.white38),
                               ),
                               style: const TextStyle(color: Colors.white),
                               obscureText: true,
                               validator: (value) {
                                 if (value == null || value.isEmpty) {
                                   return 'Пожалуйста, введите API ключ';
                                 }
                                 if (!value.startsWith('sk-')) {
                                   return 'API ключ должен начинаться с "sk-"';
                                 }
                                 return null;
                               },
                             );
                           }
                         },
                       ),
                     ],
                   ),
                 ),
               ),
              const SizedBox(height: 16),

              // Базовый URL
              Card(
                color: const Color(0xFF333333),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Базовый URL',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _baseUrlController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'URL API',
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Пожалуйста, введите URL';
                          }
                          final uri = Uri.tryParse(value);
                          if (uri == null || !uri.hasScheme) {
                            return 'Пожалуйста, введите корректный URL';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

                             // Кнопка сохранения
               Consumer<ApiKeyProvider>(
                 builder: (context, apiKeyProvider, child) {
                   final hasValidKey = apiKeyProvider.hasValidApiKey;
                   
                   return SizedBox(
                     width: double.infinity,
                     height: 50,
                     child: ElevatedButton(
                       onPressed: (_isLoading || hasValidKey) ? null : _saveSettings,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: hasValidKey ? Colors.grey : Colors.blue,
                         foregroundColor: Colors.white,
                       ),
                       child: _isLoading
                           ? const CircularProgressIndicator(color: Colors.white)
                           : Text(
                               hasValidKey ? 'Ключ уже настроен' : 'Сохранить настройки',
                               style: GoogleFonts.roboto(
                                 fontSize: 16,
                                 fontWeight: FontWeight.w600,
                               ),
                             ),
                     ),
                   );
                 },
               ),
              const SizedBox(height: 16), // Дополнительный отступ снизу
            ],
          ),
        ),
      ),
    );
  }
}

