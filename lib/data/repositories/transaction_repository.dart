import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction_model.dart';
import '../../domain/entities/transaction.dart';

class TransactionRepository {
  final String _boxName = 'transactions_box';

  // Abre a caixa do Hive (o "banco de dados")
  Future<Box<TransactionModel>> _openBox() async {
    return await Hive.openBox<TransactionModel>(_boxName);
  }

  // Salvar
  Future<void> addTransaction(TransactionEntity transaction) async {
    final box = await _openBox();
    final model = TransactionModel.fromEntity(transaction);
    await box.put(model.id, model);
  }

  // Ler todas
  Future<List<TransactionEntity>> getAllTransactions() async {
    final box = await _openBox();
    return box.values.map((model) => model.toEntity()).toList();
  }

  //delete all transactions (para testes)
  Future<void> deleteAllTransactions() async {
    final box = await _openBox();
    await box.clear();
  }

  // Eliminar
  Future<void> deleteTransaction(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }
}
