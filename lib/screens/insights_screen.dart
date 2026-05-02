import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../models/expense_transaction.dart';
import '../widgets/filter_bar.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  int touchedIndex = -1;
  bool showIncomePie = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final filteredTransactions = provider.filteredTransactions;
    
    final expenseCategoryTotals = provider.getExpenseCategoryTotals(filteredTransactions);
    final incomeCategoryTotals = provider.getIncomeCategoryTotals(filteredTransactions);
    
    final totalExpense = provider.totalDebit;
    final totalIncome = provider.totalCredit;
    
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
          
          if (filteredTransactions.isEmpty)
            _buildEmptyState(context)
          else ...[
            _buildSection(
              context: context,
              title: 'Distribution',
              child: Column(
                children: [
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Expenses'), icon: Icon(Icons.arrow_downward, size: 16)),
                      ButtonSegment(value: true, label: Text('Income'), icon: Icon(Icons.arrow_upward, size: 16)),
                    ],
                    selected: {showIncomePie},
                    onSelectionChanged: (val) => setState(() => showIncomePie = val.first),
                  ),
                  const SizedBox(height: 24),
                  _buildEnhancedPieChart(
                    context, 
                    showIncomePie ? incomeCategoryTotals : expenseCategoryTotals, 
                    showIncomePie ? totalIncome : totalExpense, 
                    format,
                    isIncome: showIncomePie,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            _buildSection(
              context: context,
              title: 'Daily Comparison',
              child: _buildBarChart(context, filteredTransactions),
            ),
            const SizedBox(height: 32),
            
            _buildSection(
              context: context,
              title: 'Trend (Income vs Expense)',
              child: _buildTrendChart(context, filteredTransactions),
            ),
            const SizedBox(height: 32),
            
            _buildSection(
              context: context,
              title: 'Detailed Breakdown',
              child: _buildDetailedBreakdown(
                context, 
                showIncomePie ? incomeCategoryTotals : expenseCategoryTotals, 
                showIncomePie ? totalIncome : totalExpense, 
                format,
              ),
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

  Widget _buildEnhancedPieChart(BuildContext context, Map<String, double> data, double total, NumberFormat format, {required bool isIncome}) {
    if (data.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Text('No data for this type', style: TextStyle(color: Colors.white24))));
    }

    final expenseColors = [
      Theme.of(context).colorScheme.primary,
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFF00BCD4),
    ];

    final incomeColors = [
      Colors.greenAccent,
      Colors.tealAccent,
      Colors.lightGreenAccent,
      Colors.cyanAccent,
    ];

    final colors = isIncome ? incomeColors : expenseColors;

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
                    final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;

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
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          children: data.entries.take(8).mapIndexed((index, entry) {
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

  Widget _buildTrendChart(BuildContext context, List<ExpenseTransaction> transactions) {
    if (transactions.length < 2) return const SizedBox();

    final txs = List<ExpenseTransaction>.from(transactions)..sort((a, b) => a.date.compareTo(b.date));
    final dayMapExpense = <DateTime, double>{};
    final dayMapIncome = <DateTime, double>{};

    for (var tx in txs) {
      final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (tx.isCredit) {
        dayMapIncome[day] = (dayMapIncome[day] ?? 0) + tx.amount;
      } else {
        dayMapExpense[day] = (dayMapExpense[day] ?? 0) + tx.amount;
      }
    }

    final allDays = {...dayMapExpense.keys, ...dayMapIncome.keys}.toList()..sort();
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(context, 'Income', Colors.greenAccent),
            const SizedBox(width: 16),
            _buildLegendItem(context, 'Expense', Theme.of(context).colorScheme.primary),
          ],
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: max(MediaQuery.of(context).size.width - 88, allDays.length * 40.0),
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < allDays.length && index % max(1, (allDays.length / 10).floor()) == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('dd').format(allDays[index]),
                              style: const TextStyle(fontSize: 10, color: Colors.white24),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Income Line
                  LineChartBarData(
                    spots: allDays.mapIndexed((index, day) {
                      return FlSpot(index.toDouble(), dayMapIncome[day] ?? 0);
                    }).toList(),
                    isCurved: true,
                    color: Colors.greenAccent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                  // Expense Line
                  LineChartBarData(
                    spots: allDays.mapIndexed((index, day) {
                      return FlSpot(index.toDouble(), dayMapExpense[day] ?? 0);
                    }).toList(),
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(BuildContext context, List<ExpenseTransaction> transactions) {
    final txs = List<ExpenseTransaction>.from(transactions)..sort((a, b) => a.date.compareTo(b.date));
    final dayMapExpense = <DateTime, double>{};
    final dayMapIncome = <DateTime, double>{};

    for (var tx in txs) {
      final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (tx.isCredit) {
        dayMapIncome[day] = (dayMapIncome[day] ?? 0) + tx.amount;
      } else {
        dayMapExpense[day] = (dayMapExpense[day] ?? 0) + tx.amount;
      }
    }

    final allDays = {...dayMapExpense.keys, ...dayMapIncome.keys}.toList()..sort();
    // Show last 14 days or all if less, to make it scrollable
    final displayDays = allDays.length > 14 ? allDays.sublist(allDays.length - 14) : allDays;

    if (displayDays.isEmpty) return const SizedBox();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: max(MediaQuery.of(context).size.width - 88, displayDays.length * 60.0),
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < displayDays.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          DateFormat('dd').format(displayDays[value.toInt()]), 
                          style: const TextStyle(fontSize: 10, color: Colors.white24),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: displayDays.mapIndexed((index, day) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: dayMapIncome[day] ?? 0,
                    color: Colors.greenAccent,
                    width: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  BarChartRodData(
                    toY: dayMapExpense[day] ?? 0,
                    color: Theme.of(context).colorScheme.primary,
                    width: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ],
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
