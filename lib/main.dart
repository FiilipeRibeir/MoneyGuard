import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moneyguard/data/models/transaction_model.dart';
import 'package:moneyguard/presentation/providers/investment_provider.dart';
import 'package:moneyguard/presentation/screens/main_screen.dart';
import 'package:provider/provider.dart';

import 'presentation/providers/transaction_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionModelAdapter());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TransactionProvider()..loadTransactions(),
        ),
        ChangeNotifierProvider(create: (_) => InvestmentProvider()),
      ],
      child: const MoneyGuardApp(),
    ),
  );
}

class MoneyGuardApp extends StatelessWidget {
  const MoneyGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoneyGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.light,
      ),
      home: MainScreen(),
    );
  }
}
