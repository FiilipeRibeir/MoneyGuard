import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:moneyguard/domain/entities/transaction.dart';

class CsvImportService {
  static Future<List<TransactionEntity>> importNubankCsv() async {
    print("--- 📂 Operação Limpeza Total Iniciada ---");

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
      if (result == null || result.files.single.path == null) return [];

      final file = File(result.files.single.path!);
      List<String> lines = await file
          .readAsLines(encoding: utf8)
          .catchError((_) => file.readAsLines(encoding: latin1));

      if (lines.length <= 1) return [];

      List<TransactionEntity> transactions = [];

      for (var i = 1; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.isEmpty) continue;

        List<String> columns = line.split(',');
        if (columns.length < 4) continue;

        try {
          final String rawDesc = columns[3].trim().replaceAll('"', '');
          final String id = columns[2].trim();
          final double amount = _parseAmount(columns[1].trim());
          final DateTime date = _parseDate(columns[0].trim());

          // APLICAÇÃO DOS FILTROS "GOSTOSOS"
          final String cleanTitle = _limparDescricao(rawDesc);
          final String autoCategory = _definirCategoria(rawDesc, amount);

          transactions.add(
            TransactionEntity(
              id: id,
              title: cleanTitle,
              amount: amount.abs(),
              date: date,
              type: amount >= 0
                  ? TransactionType.income
                  : TransactionType.expense,
              category: autoCategory,
            ),
          );
        } catch (e) {
          print("⚠️ Erro na linha $i: $e");
        }
      }

      print("✅ Dados filtrados e prontos!");
      return transactions;
    } catch (e) {
      print("❌ Erro: $e");
      return [];
    }
  }

  static String _limparDescricao(String desc) {
    final d = desc.toLowerCase();

    // Se for positivo e vier do NuInvest/Crédito em conta
    if ((d.contains('nuinvest') || d.contains('crédito em conta')) &&
        !d.contains('transferência enviada')) {
      return "Proventos / Dividendos";
    }

    if (d.contains('mobilidade') || d.contains('070')) {
      return "Recarga Transporte (BRB)";
    }

    // ... restante dos seus filtros (Pix, Compra no débito, etc)
    if (d.contains('compra no débito')) return desc.split('-').last.trim();

    return desc.length > 35 ? "${desc.substring(0, 32)}..." : desc;
  }

  static String _definirCategoria(String desc, double amount) {
    final d = desc.toLowerCase();

    // 1. EDUCAÇÃO / CONCURSOS (PMDF Focus)
    if (d.contains('quadrix') ||
        d.contains('cebraspe') ||
        d.contains('instituto')) {
      return 'Educação';
    }

    // 2. TRANSPORTE (Uber & BRB)
    // Adicionado '070' e 'brb' para o seu cartão de mobilidade
    if (d.contains('mobilidade') ||
        d.contains('070') ||
        d.contains('brb') ||
        d.contains('parking') ||
        d.contains('uber') ||
        d.contains('99app') ||
        d.contains('combustivel') ||
        d.contains('posto')) {
      return 'Transporte';
    }

    // 3. RENDIMENTOS E INVESTIMENTOS
    if (d.contains('nuinvest') ||
        d.contains('rdb') ||
        d.contains('crédito em conta')) {
      // Se o dinheiro ENTRA (amount positivo), é rendimento (proventos)
      if (amount > 0) return 'Rendimentos';
      // Se o dinheiro SAI, é você aplicando em investimentos
      return 'Investimentos';
    }

    // 4. ALIMENTAÇÃO
    if (d.contains('burguer') ||
        d.contains('ifood') ||
        d.contains('restaurante') ||
        d.contains('valdirene') ||
        d.contains('padaria') ||
        d.contains('lanche')) {
      return 'Alimentacao';
    }

    // 5. COMPRAS
    if (d.contains('americanas') ||
        d.contains('loja') ||
        d.contains('shopping') ||
        d.contains('mercado')) {
      return 'Compras';
    }

    return 'Outros';
  }

  static double _parseAmount(String value) {
    String clean = value.replaceAll('R\$', '').replaceAll(' ', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }

  static DateTime _parseDate(String value) {
    try {
      final p = value.split('/');
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    } catch (_) {
      return DateTime.now();
    }
  }
}
