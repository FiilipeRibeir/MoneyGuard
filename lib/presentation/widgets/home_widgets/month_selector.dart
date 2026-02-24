import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneyguard/presentation/providers/transaction_provider.dart';
import 'package:provider/provider.dart';

class MonthSelector extends StatelessWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 12,
        itemBuilder: (context, index) {
          final monthDate = DateTime(provider.selectedDate.year, index + 1);
          final isSelected = monthDate.month == provider.selectedDate.month;

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
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
