import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

/// Экран статистики использования токенов моделями
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Статистика',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF262626),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              // Обновление статистики
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Общая статистика
                _buildSummaryCard(),
                const SizedBox(height: 16),

                // Статистика по моделям
                _buildModelsStatisticsCard(),
                const SizedBox(height: 16),

                // Детальная статистика
                Expanded(
                  child: _buildDetailedStatisticsList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Карточка с общей статистикой
  Widget _buildSummaryCard() {
    return Card(
      color: const Color(0xFF333333),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Общая статистика',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Всего токенов',
                    '1,234',
                    Icons.token,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Общая стоимость',
                    '\$12.34',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Сообщений',
                    '56',
                    Icons.message,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Моделей',
                    '3',
                    Icons.model_training,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Карточка со статистикой по моделям
  Widget _buildModelsStatisticsCard() {
    return Card(
      color: const Color(0xFF333333),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Статистика по моделям',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildModelStatItem(
              'GPT-4',
              '456 токенов',
              '\$4.56',
              '23 сообщения',
              0.4,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildModelStatItem(
              'Claude-3',
              '678 токенов',
              '\$6.78',
              '18 сообщений',
              0.6,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildModelStatItem(
              'Gemini Pro',
              '100 токенов',
              '\$1.00',
              '15 сообщений',
              0.1,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  /// Список детальной статистики
  Widget _buildDetailedStatisticsList() {
    return Card(
      color: const Color(0xFF333333),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Детальная статистика',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailedStatItem(
            'Сегодня',
            '123 токена',
            '\$1.23',
            '5 сообщений',
            Colors.blue,
          ),
          _buildDetailedStatItem(
            'Вчера',
            '234 токена',
            '\$2.34',
            '8 сообщений',
            Colors.green,
          ),
          _buildDetailedStatItem(
            'На этой неделе',
            '567 токенов',
            '\$5.67',
            '22 сообщения',
            Colors.orange,
          ),
          _buildDetailedStatItem(
            'В прошлом месяце',
            '2,345 токенов',
            '\$23.45',
            '89 сообщений',
            Colors.purple,
          ),
        ],
      ),
    );
  }

  /// Элемент статистики
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Элемент статистики модели
  Widget _buildModelStatItem(
    String modelName,
    String tokens,
    String cost,
    String messages,
    double usagePercent,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.model_training, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  modelName,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$tokens • $cost • $messages',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(usagePercent * 100).toInt()}%',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              LinearProgressIndicator(
                value: usagePercent,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Элемент детальной статистики
  Widget _buildDetailedStatItem(
    String period,
    String tokens,
    String cost,
    String messages,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF424242),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$tokens • $cost • $messages',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white54,
            size: 16,
          ),
        ],
      ),
    );
  }
}

