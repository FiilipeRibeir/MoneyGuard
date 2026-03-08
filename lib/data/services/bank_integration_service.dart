import 'package:moneyguard/domain/entities/investment.dart';

class BankIntegrationService {
  static Future<List<InvestmentEntity>> fetchExternalData() async {
    await Future.delayed(const Duration(seconds: 2));

    return [
      InvestmentEntity(
        id: 'nubank-petr4',
        symbol: 'PETR4',
        name: 'Petrobras PN',
        quantity: 25,
        averagePrice: 31.20,
        currentPrice: 36.45,
        type: AssetType.acao,
      ),
      InvestmentEntity(
        id: 'nubank-hglg11',
        symbol: 'HGLG11',
        name: 'CSHG Logística FII',
        quantity: 12,
        averagePrice: 158.70,
        currentPrice: 164.10,
        type: AssetType.fii,
      ),
      InvestmentEntity(
        id: 'nubank-bova11',
        symbol: 'BOVA11',
        name: 'iShares Ibovespa ETF',
        quantity: 18,
        averagePrice: 112.35,
        currentPrice: 118.90,
        type: AssetType.etf,
      ),
    ];
  }
}
