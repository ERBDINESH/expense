import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../widgets/filter_bar.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final categoryTotals = provider.categoryTotals;
    final totalExpense = provider.totalDebit;
    final filteredTransactions = provider.filteredTransactions;
    final format = NumberFormat.simpleCurrency(locale: 'en_IN', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const FilterBar(),
          const SizedBox(height: 32),
          
          if (categoryTotals.isEmpty)
            _buildEmptyState(context)
          else ...[
            _buildSection(
              context: context,
              title: 'Category Distribution',
              child: _buildEnhancedPieChart(context, categoryTotals, totalExpense, format),
            ),
            const SizedBox(height: 32),
            
            _buildSection(
              context: context,
              title: 'Spending Trend',
              child: _buildLineChart(context, filteredTransactions),
            ),
            const SizedBox(height: 32),
            
            _buildSection(
              context: context,
              title: 'Detailed Breakdown',
              child: _buildDetailedBreakdown(context, categoryTotals, totalExpense, format),
            ),
            const SizedBox(height: 60),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({required BuildContext context, required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white10),
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Column(
          children: [
            Icon(Icons.insights_rounded, size: 64, color: Colors.white10),
            const SizedBox(height: 16),
            const Text('Not enough data for insights', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedPieChart(BuildContext context, Map<String, double> data, double total, NumberFormat format) {
    final colors = [
      Theme.of(context).colorScheme.primary,
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
      const Color(0xFF4CAF50),
    ];

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  sectionsSpace: 4,
                  centerSpaceRadius: 60,
                  sections: data.entries.mapIndexed((index, entry) {
                    final isTouched = index == touchedIndex;
                    final fontSize = isTouched ? 16.0 : 12.0;
                    final radius = isTouched ? 50.0 : 40.0;
                    final percentage = (entry.value / total) * 100;

                    return PieChartSectionData(
                      color: colors[index % colors.length],
                      value: entry.value,
                      title: isTouched ? '${percentage.toStringAsFixed(1)}%' : '',
                      radius: radius,
                      titleStyle: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    touchedIndex == -1 ? 'Total' : data.keys.elementAt(touchedIndex),
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  Text(
                    format.format(touchedIndex == -1 ? total : data.values.elementAt(touchedIndex)),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: data.entries.take(6).mapIndexed((index, entry) {
            final isTouched = index == touchedIndex;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length].withValues(alpha: isTouched ? 1.0 : 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 11, 
                    color: isTouched ? Colors.white : Colors.white38,
                    fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLineChart(BuildContext context, List<dynamic> transactions) {
    final expenses = transactions.where((tx) => !tx.isCredit).toList();
    expenses.sort((a, b) => a.date.compareTo(b.date));

    final dayMap = <DateTime, double>{};
    for (var tx in expenses) {
      final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
      dayMap[day] = (dayMap[day] ?? 0) + tx.amount;
    }

    final sortedDays = dayMap.keys.toList()..sort();
    if (sortedDays.length < 2) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('Need more data for trend', style: TextStyle(color: Colors.white24, fontSize: 12))),
      );
    }

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: sortedDays.mapIndexed((index, day) {
                return FlSpot(index.toDouble(), dayMap[day]!);
              }).toList(),
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedBreakdown(BuildContext context, Map<String, double> data, double total, NumberFormat format) {
    return Column(
      children: data.entries.map((entry) {
        final percentage = total > 0 ? (entry.value / total) : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70)),
                  Text(format.format(entry.value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage,
                  minHeight: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${(percentage * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
