import 'package:flutter/material.dart';
import 'package:moneyguard/data/repositories/investment_repository.dart';
import 'package:moneyguard/domain/entities/investment.dart';

class InvestmentProvider extends ChangeNotifier {
  // Dependência (acesso ao banco via repositório)
  final InvestmentRepository _repository = InvestmentRepository();

  //--------------------------------------------------------------------

  // Estado do Provider

  //--------------------------------------------------------------------

  List<InvestmentEntity> _investments = [];
  bool _isLoading = false;

  //--------------------------------------------------------------------

  // Getters para a UI consumir

  //--------------------------------------------------------------------

  bool get isLoading => _isLoading;
  List<InvestmentEntity> get investments => _investments;
  double get totalProfitability =>
      _investments.fold(
        0.0,
        (sum, investment) => sum + investment.profitability,
      ) /
      _investments.length;

  Map<AssetType, List<InvestmentEntity>> get groupedInvestments {
    Map<AssetType, List<InvestmentEntity>> groups = {};

    for (var investment in _investments) {
      if (!groups.containsKey(investment.type)) {
        groups[investment.type] = [];
      }
      groups[investment.type]!.add(investment);
    }
    return groups;
  }

  //--------------------------------------------------------------------

  // Lógica de negócios (métodos para manipular o estado)

  //--------------------------------------------------------------------

  String getAssetTypeName(AssetType type) {
    switch (type) {
      case AssetType.acao:
        return 'Ações';
      case AssetType.fii:
        return 'Fundos Imobiliários';
      case AssetType.stock:
        return 'Stocks';
      case AssetType.cripto:
        return 'Criptomoedas';
      case AssetType.etf:
        return 'ETFs';
      case AssetType.rendaFixa:
        return 'Renda Fixa';
    }
  }

  IconData getAssetTypeIcon(AssetType type) {
    switch (type) {
      case AssetType.acao:
        return Icons.show_chart;
      case AssetType.fii:
        return Icons.apartment;
      case AssetType.stock:
        return Icons.trending_up;
      case AssetType.cripto:
        return Icons.currency_bitcoin;
      case AssetType.etf:
        return Icons.pie_chart;
      case AssetType.rendaFixa:
        return Icons.account_balance;
    }
  }

  //--------------------------------------------------------------------

  // Banco de dados (repositório)

  //--------------------------------------------------------------------

  //carregar investimentos do banco de dados
  Future<void> loadInvestments() async {
    _setLoading(true);
    _investments = await _repository.getAllInvestments();
    _setLoading(false);
  }

  //adicionar investimento
  Future<void> addInvestment(InvestmentEntity investment) async {
    _setLoading(true);
    await _repository.addInvestment(investment);
    await loadInvestments();
  }

  //deletar investimento
  Future<void> deleteInvestment(String id) async {
    _setLoading(true);
    await _repository.deleteInvestment(id);
    await loadInvestments();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
