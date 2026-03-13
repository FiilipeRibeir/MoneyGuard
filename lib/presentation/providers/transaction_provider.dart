import 'package:flutter/material.dart';
import 'package:moneyguard/data/services/csv_import_service.dart';
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

  // Calcula o saldo que veio dos meses anteriores
  double get carryoverBalance {
    // Primeiro dia do mês atual selecionado
    final firstDayOfCurrentMonth = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      1,
    );

    return _transactions
        .where((tx) => tx.date.isBefore(firstDayOfCurrentMonth))
        .fold<double>(0, (sum, tx) {
          return tx.type == TransactionType.income
              ? sum + tx.amount
              : sum - tx.amount;
        });
  }

  // O Saldo Total exibido (Saldo Anterior + Saldo do Mês)
  double get totalAccountBalance {
    return carryoverBalance + filteredTotal;
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

  Future<void> importFromCsv() async {
    _isLoading = true;
    notifyListeners();

    try {
      final newTransactions = await CsvImportService.importNubankCsv();

      if (newTransactions.isNotEmpty) {
        int adicionados = 0;
        int pulados = 0;

        for (var tx in newTransactions) {
          // AQUI ESTÁ A TRAVA:
          // Verifica se já existe uma transação com o MESMO TÍTULO, VALOR e DATA
          // (Já que o Uuid() gera um id novo toda vez, temos que comparar os dados reais)
          bool jaExiste = _transactions.any(
            (t) =>
                t.title == tx.title &&
                t.amount == tx.amount &&
                t.date.day == tx.date.day &&
                t.date.month == tx.date.month,
          );

          if (!jaExiste) {
            await _repository.addTransaction(tx);
            adicionados++;
          } else {
            pulados++;
          }
        }

        await loadTransactions();
        print(
          "🚀 Processo finalizado: $adicionados novos, $pulados ignorados.",
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAllTransactions() async {
    // 1. Limpa no repositório (Hive)
    await _repository.deleteAllTransactions();

    // 2. Atualiza a lista local e notifica a UI
    _transactions.clear();
    await loadTransactions();
    notifyListeners();

    print("🧹 Quartel limpo! Todas as transações foram removidas.");
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
