import 'package:flutter/material.dart';
import 'package:moneyguard/domain/entities/investment.dart';

class InvestmentProvider extends ChangeNotifier {
  //--------------------------------------------------------------------

  // Estado do Provider

  //--------------------------------------------------------------------

  List<InvestmentEntity> _investments = [
    InvestmentEntity(
      id: '1',
      symbol: 'VALE3',
      quantity: 100,
      averagePrice: 70.0,
      currentPrice: 75.50, // Lucro
      name: "Vale", // Exemplo de nome
      type: AssetType.acao, // Exemplo de tipo de ativo
    ),
    InvestmentEntity(
      id: '2',
      symbol: 'PETR4',
      quantity: 50,
      averagePrice: 40.0,
      currentPrice: 38.20, // Prejuízo
      name: "Petrobras", // Exemplo de nome
      type: AssetType.acao, // Exemplo de tipo de ativo
    ),
    InvestmentEntity(
      id: '3',
      symbol: 'ITUB4',
      quantity: 200,
      averagePrice: 25.0,
      currentPrice: 32.0,
      name: "Banco Itaú", // Exemplo de nome
      type: AssetType.acao, // Lucro alto
    ),
  ];
  bool _isLoading = false;

  //--------------------------------------------------------------------

  // Getters para a UI consumir

  //--------------------------------------------------------------------

  bool get isLoading => _isLoading;
  List<InvestmentEntity> get investments => _investments;

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

  // Banco de dados (repositório)

  //--------------------------------------------------------------------
}
