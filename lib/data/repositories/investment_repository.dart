import 'package:hive/hive.dart';
import 'package:moneyguard/data/models/investment_model.dart';
import 'package:moneyguard/domain/entities/investment.dart';

class InvestmentRepository {
  final String _boxName = 'investment_box';
  // Abre a caixa do Hive (o "banco de dados")
  Future<Box<InvestmentModel>> _openBox() async {
    return await Hive.openBox<InvestmentModel>(_boxName);
  }

  // Salvar
  Future<void> addInvestment(InvestmentEntity investment) async {
    final box = await _openBox();
    final model = InvestmentModel.fromEntity(investment);
    await box.put(model.id, model);
  }

  // Ler todas
  Future<List<InvestmentEntity>> getAllInvestments() async {
    final box = await _openBox();
    return box.values.map((model) => model.toEntity()).toList();
  }

  // Eliminar
  Future<void> deleteInvestment(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }
}
