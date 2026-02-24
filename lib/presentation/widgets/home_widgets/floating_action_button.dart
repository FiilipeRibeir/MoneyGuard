import 'package:flutter/material.dart';
import 'package:moneyguard/presentation/widgets/home_widgets/add_transaction_form.dart';

class CustomFloatingActionButton extends StatelessWidget {
  const CustomFloatingActionButton({super.key});

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
          builder: (_) => const AddTransactionForm(),
        );
      },
      label: const Text('Novo'),
      icon: const Icon(Icons.add),
    );
  }
}
