import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatar moeda e data
import 'package:moneyguard/domain/entities/transaction.dart';
import 'package:moneyguard/presentation/widgets/add_transaction_form.dart';
import 'package:moneyguard/presentation/widgets/category_chart.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final txs = provider.filteredTransactions;

    final filteredTotal = txs.fold<double>(0, (sum, tx) {
      return tx.type == TransactionType.income
          ? sum + tx.amount
          : sum - tx.amount;
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MoneyGuard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
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
                  currencyFormat.format(filteredTotal),
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
            ],
          ),
          // Exemplo de como construir o seletor
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 12, // Vamos mostrar os meses do ano atual
              itemBuilder: (context, index) {
                final monthDate = DateTime(
                  provider.selectedDate.year,
                  index + 1,
                );
                final isSelected =
                    monthDate.month == provider.selectedDate.month;

                return GestureDetector(
                  onTap: () => provider.changeMonth(monthDate),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: isSelected
                          ? Border(
                              bottom: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            )
                          : null,
                    ),
                    child: Text(
                      DateFormat('MMM').format(monthDate).toUpperCase(),
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const CategoryChart(),
          // Lista de Transações
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: provider.filteredTransactions.length,
                    itemExtent: 80, // Performance: define altura fixa
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
                          child: const Icon(Icons.delete, color: Colors.white),
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
                                ? Colors.red.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            child: Icon(
                              isExpense
                                  ? Icons.trending_down
                                  : Icons.trending_up,
                              color: isExpense ? Colors.red : Colors.green,
                            ),
                          ),
                          title: Text(
                            tx.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
      // No seu floatingActionButton da HomeScreen:
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Importante para o teclado
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            builder: (_) => const AddTransactionForm(),
          );
        },
        label: const Text('Novo'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
