import 'package:flutter/material.dart';
import 'package:moneyguard/domain/entities/investment.dart';
import 'package:moneyguard/presentation/providers/investment_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class AddInvestmentForm extends StatefulWidget {
  const AddInvestmentForm({super.key});

  @override
  State<AddInvestmentForm> createState() => _AddInvestmentFormState();
}

class _AddInvestmentFormState extends State<AddInvestmentForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _quantityController = TextEditingController();
  final _averagePriceController = TextEditingController();
  final _currentPriceController = TextEditingController();

  AssetType? _selectedType;

  void _submitData() {
    if (_formKey.currentState!.validate()) {
      final newInvestment = InvestmentEntity(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        symbol: _symbolController.text.trim().toUpperCase(),
        quantity: double.parse(_quantityController.text),
        averagePrice: double.parse(_averagePriceController.text),
        currentPrice: double.parse(_currentPriceController.text),
        type: _selectedType!,
      );

      context.read<InvestmentProvider>().addInvestment(newInvestment);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _symbolController.dispose();
    _quantityController.dispose();
    _averagePriceController.dispose();
    _currentPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Novo Investimento',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do ativo',
                  hintText: 'Ex: Vale',
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Digite o nome do ativo'
                    : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _symbolController,
                decoration: const InputDecoration(
                  labelText: 'Código',
                  hintText: 'Ex: VALE3',
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Digite o código do ativo'
                    : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantidade',
                  hintText: 'Ex: 100',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (val) {
                  final quantity = double.tryParse(val ?? '');
                  if (quantity == null || quantity <= 0) {
                    return 'Digite uma quantidade válida';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _averagePriceController,
                decoration: const InputDecoration(
                  labelText: 'Preço médio',
                  hintText: 'Ex: 70.50',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (val) {
                  final price = double.tryParse(val ?? '');
                  if (price == null || price <= 0) {
                    return 'Digite um preço médio válido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _currentPriceController,
                decoration: const InputDecoration(
                  labelText: 'Preço atual',
                  hintText: 'Ex: 75.30',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (val) {
                  final price = double.tryParse(val ?? '');
                  if (price == null || price <= 0) {
                    return 'Digite um preço atual válido';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<AssetType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(labelText: 'Tipo de ativo'),
                items: const [
                  DropdownMenuItem(value: AssetType.acao, child: Text('Ações')),
                  DropdownMenuItem(
                    value: AssetType.fii,
                    child: Text('Fundos Imobiliários'),
                  ),
                  DropdownMenuItem(
                    value: AssetType.stock,
                    child: Text('Stocks'),
                  ),
                  DropdownMenuItem(
                    value: AssetType.cripto,
                    child: Text('Criptomoedas'),
                  ),
                  DropdownMenuItem(value: AssetType.etf, child: Text('ETFs')),
                  DropdownMenuItem(
                    value: AssetType.rendaFixa,
                    child: Text('Renda Fixa'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedType = val);
                  }
                },
                validator: (val) =>
                    val == null ? 'Escolha um tipo de ativo' : null,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text('Salvar'),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
