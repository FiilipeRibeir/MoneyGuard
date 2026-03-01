import 'package:flutter/material.dart';
import 'package:moneyguard/presentation/providers/investment_provider.dart';
import 'package:moneyguard/presentation/widgets/home_widgets/floating_action_button.dart';
import 'package:provider/provider.dart';

class InvestmentScreen extends StatelessWidget {
  const InvestmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvestmentProvider>();
    final grouped = provider.groupedInvestments;
    final categories = grouped.keys.toList();

    return Stack(
      children: [
        Column(
          children: [
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
                    'R\$ 0,00',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Text(
                    'Variação Anual: +0,00%',
                    style: TextStyle(fontSize: 16, color: Colors.green),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  //Meus Ativos
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Meus Ativos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  //cards
                  Expanded(
                    child: provider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : provider.investments.isEmpty
                        ? const Center(
                            child: Text('Nenhum investimento encontrado.'),
                          )
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
                                    provider.getAssetTypeIcon(type),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  title: Text(provider.getAssetTypeName(type)),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'R\$ ${investment.totalInvested.toStringAsFixed(1)}',
                                            style: TextStyle(
                                              color:
                                                  investment.profitability >= 0
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${investment.profitability.toStringAsFixed(0)}%',
                                            style: TextStyle(
                                              color:
                                                  investment.profitability >= 0
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
              ),
            ),
          ],
        ),
        const Positioned(
          right: 16,
          bottom: 16,
          child: CustomFloatingActionButton(isInvestment: true),
        ),
      ],
    );
  }
}
