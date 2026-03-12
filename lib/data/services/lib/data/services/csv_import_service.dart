import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:moneyguard/domain/entities/transaction.dart';
import 'package:uuid/uuid.dart';

class CsvImportService {
  static Future<List<TransactionEntity>> importNubankCsv() async {
    print("--- 📂 Iniciando Processamento de Arquivo ---");

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result == null || result.files.single.path == null) {
        print("❌ Operação cancelada pelo usuário.");
        return [];
      }

      final file = File(result.files.single.path!);

      // Lendo como linhas para evitar problemas de fim de linha (EOL)
      // Usamos latin1 como fallback se o utf8 falhar, para não quebrar o app
      List<String> lines = await file
          .readAsLines(encoding: utf8)
          .catchError((_) => file.readAsLines(encoding: latin1));

      if (lines.length <= 1) {
        print(
          "⚠️ O arquivo parece não ter dados (apenas ${lines.length} linhas).",
        );
        return [];
      }

      print("📊 Total de linhas encontradas: ${lines.length}");

      List<TransactionEntity> transactions = [];

      // Pula a primeira linha (cabeçalho)
      for (var i = 1; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.isEmpty) continue;

        // O Nubank usa vírgula como padrão no CSV
        List<String> columns = line.split(',');

        if (columns.length < 4) continue;

        try {
          final String dateStr = columns[0].trim();
          final String amountStr = columns[1].trim();
          final String description = columns[3].trim().replaceAll('"', '');

          final double amount = _parseAmount(amountStr);
          final DateTime date = _parseDate(dateStr);

          transactions.add(
            TransactionEntity(
              id: const Uuid().v4(),
              title: description,
              amount: amount.abs(),
              date: date,
              type: amount >= 0
                  ? TransactionType.income
                  : TransactionType.expense,
              category: 'Outros',
            ),
          );
        } catch (e) {
          print("⚠️ Falha ao processar linha $i: $line. Erro: $e");
        }
      }

      print(
        "✅ Importação concluída: ${transactions.length} transações criadas.",
      );
      return transactions;
    } catch (e) {
      print("❌ Erro fatal no CsvImportService: $e");
      return [];
    }
  }

  static double _parseAmount(String value) {
    // Remove R$, espaços e ajusta para o formato double (Ex: -15.00)
    String clean = value.replaceAll('R\$', '').replaceAll(' ', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }

  static DateTime _parseDate(String value) {
    // Nubank envia como DD/MM/YYYY
    try {
      final p = value.split('/');
      if (p.length == 3) {
        return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
      }
    } catch (_) {}
    return DateTime.tryParse(value) ?? DateTime.now();
  }
}
