import 'package:flutter/material.dart';
import 'package:moneyguard/data/services/bank_transaction_service.dart';
import '../../domain/entities/transaction.dart';
import '../../data/repositories/transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();

  //--------------------------------------------------------------------

  // Estado do Provider

  //--------------------------------------------------------------------

  DateTime _selectedDate = DateTime.now();
  List<TransactionEntity> _transactions = [];
  bool _isLoading = false;
  TransactionType? _selectedTypeFilter;

  //--------------------------------------------------------------------

  // Getters para a UI consumir

  //--------------------------------------------------------------------

  // Getters simples (UI consome o estado)
  List<TransactionEntity> get transactions => _transactions;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;
  TransactionType? get selectedTypeFilter => _selectedTypeFilter;

  // Getter com lógica de filtragem
  List<TransactionEntity> get filteredTransactions {
    final monthYearFiltered = _transactions.where(
      (tx) =>
          tx.date.month == _selectedDate.month &&
          tx.date.year == _selectedDate.year,
    );

    if (_selectedTypeFilter == null) return monthYearFiltered.toList();

    return monthYearFiltered
        .where((tx) => tx.type == _selectedTypeFilter)
        .toList();
  }

  double get filteredTotal {
    return filteredTransactions.fold<double>(0, (sum, tx) {
      return tx.type == TransactionType.income
          ? sum + tx.amount
          : sum - tx.amount;
    });
  }

  // Derivação por categoria (ainda é “lógica”, não banco)
  List<TransactionEntity> transactionsByCategory(String category) {
    final result = filteredTransactions
        .where(
          (tx) => tx.category == category && tx.type == TransactionType.expense,
        )
        .toList();

    return result;
  }

  // Cálculos do mês (Lógica de Negócio Simples)
  double get monthlyExpense {
    double total = 0;
    for (var tx in filteredTransactions) {
      if (tx.type == TransactionType.expense) {
        total += tx.amount;
      }
    }
    return total;
  }

  double get monthlyIncome {
    double total = 0;
    for (var tx in filteredTransactions) {
      if (tx.type == TransactionType.income) {
        total += tx.amount;
      }
    }
    return total;
  }

  // Saldo Total (Lógica de Negócio Simples)
  double get totalBalance {
    double total = 0;
    for (var tx in _transactions) {
      if (tx.type == TransactionType.income) {
        total += tx.amount;
      } else {
        total -= tx.amount;
      }
    }
    return total;
  }

  //--------------------------------------------------------------------

  // Ação de filtro (muda estado)

  //--------------------------------------------------------------------

  void setTypeFilter(TransactionType? type) {
    _selectedTypeFilter = type;
    notifyListeners();
  }

  //--------------------------------------------------------------------

  // Navegação (muda estado)

  //--------------------------------------------------------------------

  void nextYear() {
    _selectedDate = DateTime(_selectedDate.year + 1, _selectedDate.month);
    notifyListeners();
  }

  void previousYear() {
    _selectedDate = DateTime(_selectedDate.year - 1, _selectedDate.month);
    notifyListeners();
  }

  void changeMonth(DateTime newDate) {
    _selectedDate = newDate;
    notifyListeners();
  }

  //--------------------------------------------------------------------

  // Banco de dados (repositório)

  //--------------------------------------------------------------------

  // Carregar transações do Hive
  Future<void> loadTransactions() async {
    _setLoading(true);
    _transactions = await _repository.getAllTransactions();
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    _setLoading(false);
  }

  // Adicionar nova transação
  Future<void> addTransaction(TransactionEntity transaction) async {
    await _repository.addTransaction(transaction);
    await loadTransactions();
  }

  // Deletar transação
  Future<void> deleteTransaction(String id) async {
    await _repository.deleteTransaction(id);
    await loadTransactions();
  }

  Future<void> importTransactionsFromBank() async {
    _setLoading(true);
    try {
      final externalTransactions =
          await BankTransactionService.fetchExternalTransactions();

      for (var tx in externalTransactions) {
        await _repository.addTransaction(tx);
      }

      await loadTransactions();
    } catch (e) {
      // Tratar erros de importação, se necessário
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
