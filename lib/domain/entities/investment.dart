enum AssetType { acao, fii, stock, cripto, etf, rendaFixa }

class InvestmentEntity {
  final String id;
  final String symbol;
  final String name; // Ex: Petrobras
  final double quantity;
  final double averagePrice;
  final double currentPrice;
  final AssetType type; // O agrupador da imagem

  InvestmentEntity({
    required this.id,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.averagePrice,
    required this.currentPrice,
    required this.type,
  });

  double get totalInvested => quantity * averagePrice;
  double get currentTotalValue => quantity * currentPrice;
  double get profitability => ((currentPrice / averagePrice) - 1) * 100;
}
