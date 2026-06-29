import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';
import 'expenses_chart_screen.dart';
import '../providers/api_key_provider.dart';

/// Главная страница приложения с навигацией между экранами
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  void _initializeScreens() {
    _screens = [
      const _ChatOrNoApiKeyScreen(),
      const StatisticsScreen(),
      const ExpensesChartScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF262626),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Чат',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Статистика',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Расходы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
        ],
      ),
    );
  }
}

/// Экран, который автоматически переключается между чатом и экраном без API ключа
class _ChatOrNoApiKeyScreen extends StatelessWidget {
  const _ChatOrNoApiKeyScreen();

  @override
  Widget build(BuildContext context) {
    return Consumer<ApiKeyProvider>(
      builder: (context, apiKeyProvider, child) {
        if (apiKeyProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (apiKeyProvider.hasValidApiKey) {
          return const ChatScreen();
        }

        return _NoApiKeyScreen();
      },
    );
  }
}

/// Экран для отображения когда нет валидного API ключа
class _NoApiKeyScreen extends StatelessWidget {
  const _NoApiKeyScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.api,
                size: 80,
                color: Colors.orange,
              ),
              const SizedBox(height: 24),
              Text(
                'Укажите рабочий API ключ в настройках',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Для работы с чатом необходимо настроить API ключ OpenRouter или VseGPT',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Переключаемся на экран настроек
                  if (context.mounted) {
                    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                    if (homeState != null) {
                      homeState._currentIndex = 3; // Индекс экрана настроек
                      // Обновляем состояние через setState
                      homeState.setState(() {});
                    }
                  }
                },
                icon: const Icon(Icons.settings),
                label: const Text('Перейти в настройки'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

