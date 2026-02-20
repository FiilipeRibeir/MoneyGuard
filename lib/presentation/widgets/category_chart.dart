import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:moneyguard/presentation/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

class CategoryChart extends StatefulWidget {
  const CategoryChart({super.key});

  @override
  State<CategoryChart> createState() => _CategoryChartState();
}

class _CategoryChartState extends State<CategoryChart> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    final categories = [
      'Alimentação',
      'Transporte',
      'Casa',
      'Lazer',
      'Saúde',
      'Outros',
    ];

    final totals = <String, double>{
      for (final c in categories)
        c: provider
            .transactionsByCategory(c)
            .fold(0.0, (sum, tx) => sum + tx.amount),
    };

    final filteredTotals = totals.entries.where((e) => e.value > 0).toList();

    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: provider.monthlyExpense,
                      color: Colors.redAccent,
                      title:
                          '${(provider.monthlyExpense / (provider.monthlyIncome + provider.monthlyExpense) * 100).toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: provider.monthlyIncome,
                      color: Colors.green,
                      title:
                          '${((provider.monthlyIncome / (provider.monthlyIncome + provider.monthlyExpense)) * 100).toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: PieChart(
                PieChartData(
                  sections: filteredTotals.map((entry) {
                    return PieChartSectionData(
                      value: entry.value,
                      color:
                          Colors.primaries[categories.indexOf(entry.key) %
                              Colors.primaries.length],
                      title:
                          '${entry.key}\n${(entry.value / filteredTotals.fold(0.0, (sum, e) => sum + e.value) * 100).toStringAsFixed(1)}%',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
