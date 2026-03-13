// ignore_for_file: constant_identifier_names

enum TransactionType { income, expense }

enum CategoryType {
  Alimentacao,
  Transporte,
  Lazer,
  Saude,
  Educacao,
  Rendimentos, // Para seus proventos de NuInvest
  Investimentos, // Para o dinheiro que você guarda (RDB)
  Moradia,
  Compras,
  Outros,
}

class TransactionEntity {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final String category;

  TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
  });
}
