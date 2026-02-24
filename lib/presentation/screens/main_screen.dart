import 'package:flutter/material.dart';
import 'package:moneyguard/presentation/screens/home_screen.dart';
import 'package:moneyguard/presentation/screens/investment_screen.dart';
import 'package:moneyguard/presentation/screens/profile_screen.dart';
import 'package:moneyguard/presentation/widgets/main_widgets/bottom_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  final List<Widget> _screens = [
    const InvestmentScreen(),
    const HomeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      appBar: AppBar(title: const Text('MoneyGuard'), centerTitle: true),
      bottomNavigationBar: BottomBar(
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        currentIndex: _selectedIndex,
      ),
    );
  }
}
