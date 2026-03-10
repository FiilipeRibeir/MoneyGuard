import 'package:moneyguard/domain/entities/transaction.dart';

class BankTransactionService {
  static Future<List<TransactionEntity>> fetchExternalTransactions() async {
    await Future.delayed(const Duration(seconds: 2));

    // No BankTransactionService
    return [
      TransactionEntity(
        id: 'nu-001',
        title: 'Salário Mensal',
        amount: 5500.00,
        date: DateTime.now(),
        category: 'Outros',
        type: TransactionType.income,
      ),
      TransactionEntity(
        id: 'nu-002',
        title: 'iFood - Burger King',
        amount: 85.90,
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Alimentação',
        type: TransactionType.expense,
      ),
      TransactionEntity(
        id: 'nu-003',
        title: 'Posto Shell',
        amount: 250.00,
        date: DateTime.now().subtract(const Duration(days: 2)),
        category: 'Transporte',
        type: TransactionType.expense,
      ),
    ];
  }
}
