import 'package:hive/hive.dart';
import '../../domain/entities/transaction.dart';

// Este arquivo será gerado pelo build_runner
part 'transaction_model.g.dart';

@HiveType(typeId: 0)
class TransactionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final bool isExpense; // Hive simplificado: true = despesa, false = receita

  @HiveField(5)
  final String? category;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isExpense,
    required this.category,
  });

  // Mapper: Converte Model (Data) para Entity (Domain)
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      title: title,
      amount: amount,
      date: date,
      type: isExpense ? TransactionType.expense : TransactionType.income,
      category: category ?? 'Outros',
    );
  }

  // Factory: Converte Entity para Model
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      date: entity.date,
      isExpense: entity.type == TransactionType.expense,
      category: entity.category,
    );
  }
}
