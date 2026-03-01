import 'package:hive_flutter/hive_flutter.dart';
import 'package:moneyguard/domain/entities/investment.dart';

part 'investment_model.g.dart';

@HiveType(typeId: 1)
class InvestmentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String symbol;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final double quantity;

  @HiveField(4)
  final double averagePrice;

  @HiveField(5)
  final double currentPrice;

  @HiveField(6)
  final String type;

  InvestmentModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.averagePrice,
    required this.currentPrice,
    required this.type,
  });

  InvestmentEntity toEntity() {
    return InvestmentEntity(
      id: id,
      symbol: symbol,
      name: name,
      quantity: quantity,
      averagePrice: averagePrice,
      currentPrice: currentPrice,
      type: _assetTypeFromString(type),
    );
  }

  factory InvestmentModel.fromEntity(InvestmentEntity entity) {
    return InvestmentModel(
      id: entity.id,
      symbol: entity.symbol,
      name: entity.name,
      quantity: entity.quantity,
      averagePrice: entity.averagePrice,
      currentPrice: entity.currentPrice,
      type: entity.type.name,
    );
  }

  static AssetType _assetTypeFromString(String value) {
    switch (value) {
      case 'acao':
        return AssetType.acao;
      case 'fii':
        return AssetType.fii;
      case 'stock':
        return AssetType.stock;
      case 'cripto':
        return AssetType.cripto;
      case 'etf':
        return AssetType.etf;
      case 'rendaFixa':
        return AssetType.rendaFixa;
      default:
        return AssetType.acao;
    }
  }
}
