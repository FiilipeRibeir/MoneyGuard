import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:moneyguard/presentation/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

class CategoryChart extends StatelessWidget {
  const CategoryChart({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    // Sincronizado com o seu CsvImportService
    final Map<String, Color> categoryStyles = {
      'Alimentação': Colors.orange,
      'Transporte': Colors.blue,
      'Educação': Colors.amber.shade700,
      'Rendimentos': Colors.green.shade700,
      'Investimentos': Colors.teal,
      'Compras': Colors.pink,
      'Outros': Colors.grey,
    };

    final allCategories = categoryStyles.keys.toList();

    // Cálculo dos totais por categoria (apenas despesas para o gráfico de pizza de gastos)
    final totals = <String, double>{
      for (final c in allCategories)
        c: provider
            .transactionsByCategory(c)
            .fold(0.0, (sum, tx) => sum + tx.amount),
    };

    final filteredTotals = totals.entries.where((e) => e.value > 0).toList();
    final totalExpense = provider.monthlyExpense;
    final totalIncome = provider.monthlyIncome;

    return Container(
      height: 240,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            "Visão Geral do Mês",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Row(
              children: [
                // GRÁFICO 1: ENTRADAS VS SAÍDAS
                Expanded(
                  child: Column(
                    children: [
                      const Text("Balanço", style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 25,
                            sections: [
                              PieChartSectionData(
                                value: totalExpense,
                                color: Colors.redAccent,
                                title: '', // Título vazio para não poluir
                                radius: 18,
                                badgeWidget: _buildBadge(
                                  totalExpense,
                                  totalIncome + totalExpense,
                                  Colors.redAccent,
                                ),
                                badgePositionPercentageOffset: 1.4,
                              ),
                              PieChartSectionData(
                                value: totalIncome,
                                color: Colors.green,
                                title: '',
                                radius: 18,
                                badgeWidget: _buildBadge(
                                  totalIncome,
                                  totalIncome + totalExpense,
                                  Colors.green,
                                ),
                                badgePositionPercentageOffset: 1.4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const VerticalDivider(width: 30, indent: 20, endIndent: 20),

                // GRÁFICO 2: DISTRIBUIÇÃO DE GASTOS
                Expanded(
                  child: Column(
                    children: [
                      const Text("Gastos", style: TextStyle(fontSize: 12)),
                      Expanded(
                        child: filteredTotals.isEmpty
                            ? const Center(
                                child: Text(
                                  "Sem gastos",
                                  style: TextStyle(fontSize: 10),
                                ),
                              )
                            : PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 25,
                                  sections: filteredTotals.map((entry) {
                                    final color =
                                        categoryStyles[entry.key] ??
                                        Colors.grey;
                                    return PieChartSectionData(
                                      value: entry.value,
                                      color: color,
                                      title: '', // Título oculto
                                      radius: 18,
                                      badgeWidget: _buildCategoryBadge(
                                        entry.key,
                                        color,
                                      ),
                                      badgePositionPercentageOffset: 1.5,
                                    );
                                  }).toList(),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar a porcentagem sem poluir o gráfico
  Widget _buildBadge(double value, double total, Color color) {
    if (total == 0) return const SizedBox();
    final percent = (value / total * 100).toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 2),
        ],
      ),
      child: Text(
        '$percent%',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // Widget para mostrar o ícone/ponto da categoria
  Widget _buildCategoryBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 8,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
