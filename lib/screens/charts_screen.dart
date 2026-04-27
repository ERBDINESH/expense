import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../providers/expense_provider.dart';
import '../widgets/filter_bar.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final categoryTotals = provider.categoryTotals;
    final totalExpense = provider.totalDebit;
    final filteredTransactions = provider.filteredTransactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
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
            _buildSectionHeader('Category Distribution', context),
            const SizedBox(height: 20),
            _buildPieChart(context, categoryTotals, totalExpense),
            const SizedBox(height: 40),
            
            _buildSectionHeader('Spending Trend', context),
            const SizedBox(height: 20),
            _buildLineChart(context, filteredTransactions),
            const SizedBox(height: 40),
            
            _buildSectionHeader('Weekly Activity', context),
            const SizedBox(height: 20),
            _buildBarChart(context, filteredTransactions),
            const SizedBox(height: 60),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.pie_chart_outline_rounded, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
            ),
            const SizedBox(height: 24),
            const Text('No Data to Analyze', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Try adjusting your filters or add transactions.', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(BuildContext context, Map<String, double> data, double total) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = [
      colorScheme.primary,
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
    ];

    return Container(
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 35,
                sections: data.entries.take(6).mapIndexed((index, entry) {
                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: entry.value,
                    title: '',
                    radius: 50,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.entries.take(4).mapIndexed((index, entry) {
                final percentage = (entry.value / total) * 100;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 11, color: Colors.white38, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
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
      return Container(
        height: 150,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(32),
        ),
        child: const Text('Add more data to see trends', style: TextStyle(color: Colors.white24)),
      );
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(10, 30, 24, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white10),
      ),
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
                color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, List<dynamic> transactions) {
    final expenses = transactions.where((tx) => !tx.isCredit).toList();
    final dayMap = <int, double>{}; 
    for (var tx in expenses) {
      dayMap[tx.date.weekday] = (dayMap[tx.date.weekday] ?? 0) + tx.amount;
    }

    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(10, 24, 10, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white10),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (dayMap.values.isEmpty ? 100 : dayMap.values.reduce(max)) * 1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt() - 1;
                  if (index >= 0 && index < 7) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(days[index], style: const TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) {
            final day = index + 1;
            return BarChartGroupData(
              x: day,
              barRods: [
                BarChartRodData(
                  toY: dayMap[day] ?? 0,
                  color: Theme.of(context).colorScheme.primary.withOpacity(dayMap[day] != null ? 1.0 : 0.1),
                  width: 12,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
