import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneyguard/domain/entities/transaction.dart';
import 'package:moneyguard/presentation/widgets/home_widgets/category_chart.dart';
import 'package:moneyguard/presentation/widgets/home_widgets/month_selector.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Stack(
      children: [
        Column(
          children: [
            // Card de Saldo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('Saldo Atual'),
                  Text(
                    currencyFormat.format(provider.totalAccountBalance),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => provider.previousYear(),
                ),
                Text(
                  "${provider.selectedDate.year}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () =>
                      provider.selectedDate.year >= DateTime.now().year
                      ? null
                      : provider.nextYear(),
                ),
                IconButton(
                  icon: const Icon(Icons.today),
                  onPressed: () => provider.changeMonth(DateTime.now()),
                ),
                //deleta all transactions (para testes)
                IconButton(
                  onPressed: provider.deleteAllTransactions,
                  icon: const Icon(Icons.delete),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: provider.isLoading
                      ? null
                      : () {
                          context.read<TransactionProvider>().importFromCsv();
                        },
                  icon: const Icon(Icons.file_present),
                  label: const Text('Nubank'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ],
            ),

            const MonthSelector(),
            const CategoryChart(),

            // Lista de Transações
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                        bottom: 100,
                      ), // espaço pro botão
                      itemCount: provider.filteredTransactions.length,
                      itemExtent: 80,
                      itemBuilder: (context, index) {
                        final tx = provider.filteredTransactions[index];
                        final isExpense = tx.type == TransactionType.expense;

                        return Dismissible(
                          key: Key(tx.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) {
                            provider.deleteTransaction(tx.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${tx.title} removido')),
                            );
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isExpense
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : Colors.green.withValues(alpha: 0.1),
                              child: Icon(
                                isExpense
                                    ? Icons.trending_down
                                    : Icons.trending_up,
                                color: isExpense ? Colors.red : Colors.green,
                              ),
                            ),
                            title: Text(
                              tx.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${DateFormat('dd MMM yyyy').format(tx.date)} • ${tx.category}',
                            ),
                            trailing: Text(
                              currencyFormat.format(tx.amount),
                              style: TextStyle(
                                color: isExpense ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
