import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

/// Экран с графиком расходов по дням
class ExpensesChartScreen extends StatefulWidget {
  const ExpensesChartScreen({super.key});

  @override
  State<ExpensesChartScreen> createState() => _ExpensesChartScreenState();
}

class _ExpensesChartScreenState extends State<ExpensesChartScreen> {
  String _selectedPeriod = '7 дней';
  final List<String> _periods = ['7 дней', '30 дней', '90 дней', '1 год'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'График расходов',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF262626),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => _periods
                .map((period) => PopupMenuItem(
                      value: period,
                      child: Text(period),
                    ))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_selectedPeriod),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Сводка расходов
                _buildExpensesSummary(),
                const SizedBox(height: 24),

                // График расходов
                SizedBox(
                  height: 200,
                  child: _buildExpensesChart(),
                ),
                const SizedBox(height: 24),

                // Детализация по дням
                _buildDailyBreakdown(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Сводка расходов
  Widget _buildExpensesSummary() {
    return Card(
      color: const Color(0xFF333333),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Сводка расходов',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Общие расходы',
                    '\$45.67',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Средний день',
                    '\$2.34',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Пиковый день',
                    '\$8.90',
                    Icons.show_chart,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// График расходов
  Widget _buildExpensesChart() {
    return Card(
      color: const Color(0xFF333333),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'График расходов',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  /// Детализация по дням
  Widget _buildDailyBreakdown() {
    return Card(
      color: const Color(0xFF333333),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Детализация по дням',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 7,
              itemBuilder: (context, index) {
                final day = DateTime.now().subtract(Duration(days: 6 - index));
                final cost = _getMockCost(index);
                final tokens = _getMockTokens(index);
                
                return _buildDayItem(
                  _getDayName(day),
                  cost,
                  tokens,
                  index,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Элемент сводки
  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 18,
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

  /// График
  Widget _buildChart() {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: _ExpensesChartPainter(),
    );
  }

  /// Элемент дня
  Widget _buildDayItem(String day, String cost, String tokens, int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
    ];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF424242),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors[index % colors.length].withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors[index % colors.length].withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.calendar_today,
              color: colors[index % colors.length],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$tokens • $cost',
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
                cost,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors[index % colors.length],
                ),
              ),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: colors[index % colors.length].withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _getCostFactor(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Получение названия дня
  String _getDayName(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day) return 'Сегодня';
    if (date.day == now.day - 1) return 'Вчера';
    
    final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[date.weekday - 1];
  }

  /// Получение моковой стоимости
  String _getMockCost(int index) {
    final costs = [2.34, 1.87, 3.45, 2.12, 4.56, 1.23, 3.78];
    return '\$${costs[index]}';
  }

  /// Получение моковых токенов
  String _getMockTokens(int index) {
    final tokens = [234, 187, 345, 212, 456, 123, 378];
    return '${tokens[index]} токенов';
  }

  /// Получение фактора стоимости для прогресс-бара
  double _getCostFactor(int index) {
    final costs = [2.34, 1.87, 3.45, 2.12, 4.56, 1.23, 3.78];
    final maxCost = costs.reduce((a, b) => a > b ? a : b);
    return costs[index] / maxCost;
  }
}

/// Кастомный художник для графика
class _ExpensesChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final points = _generateChartPoints(size);

    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }

    // Рисуем область под графиком
    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.lineTo(points.first.dx, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, paint);
    canvas.drawPath(path, strokePaint);

    // Рисуем точки
    for (final point in points) {
      canvas.drawCircle(point, 4, Paint()..color = Colors.blue);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  /// Генерирует точки для графика
  List<Offset> _generateChartPoints(Size size) {
    final points = <Offset>[];
    final mockData = [0.2, 0.4, 0.3, 0.6, 0.8, 0.5, 0.7];
    
    for (int i = 0; i < mockData.length; i++) {
      final x = (i / (mockData.length - 1)) * size.width;
      final y = (1 - mockData[i]) * size.height;
      points.add(Offset(x, y));
    }
    
    return points;
  }
}

