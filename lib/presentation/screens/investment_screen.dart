import 'package:flutter/material.dart';
import 'package:moneyguard/domain/entities/investment.dart';
import 'package:moneyguard/presentation/providers/investment_provider.dart';
import 'package:provider/provider.dart';

class InvestmentScreen extends StatelessWidget {
  const InvestmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvestmentProvider>();
    final grouped = provider.groupedInvestments;
    final categories = grouped.keys.toList();

    return Column(
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
              const Text('Total Investido'),
              Text(
                'R\$ 0,00', // Placeholder para o saldo total dos investimentos
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              //variação percentual do ano
              const Text(
                'Variação Anual: +0,00%',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green, // Verde para variação positiva
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.investments.isEmpty
              ? const Center(child: Text('Nenhum investimento encontrado.'))
              : ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final type = categories[index];
                    final assetsInType = grouped[type]!;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ExpansionTile(
                        leading: Icon(
                          type == AssetType.acao
                              ? Icons.show_chart
                              : Icons.account_balance_wallet,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(type == AssetType.acao ? 'Ações' : 'Ativo'),
                        subtitle: Text(
                          '${assetsInType.length} ${assetsInType.length > 1 ? 'ativos' : 'ativo'}',
                        ),

                        children: assetsInType.map((investment) {
                          return ListTile(
                            title: Text(investment.name),
                            subtitle: Text(
                              'Quantidade: ${investment.quantity} | Preço Médio: R\$ ${investment.averagePrice.toStringAsFixed(2)}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'R\$ ${investment.totalInvested.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: investment.profitability >= 0
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${investment.profitability.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: investment.profitability >= 0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
