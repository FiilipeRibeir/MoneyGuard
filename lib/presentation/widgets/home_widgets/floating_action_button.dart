import 'package:flutter/material.dart';
import 'package:moneyguard/presentation/widgets/investment_widgets/investment_widgets.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final bool isInvestment;

  const CustomFloatingActionButton({super.key, required this.isInvestment});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true, // Importante para o teclado
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          builder: (_) => AddInvestmentForm(),
        );
      },
      label: const Text('Novo'),
      icon: const Icon(Icons.add),
    );
  }
}
