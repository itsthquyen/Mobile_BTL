// lib/ui/Home/TripDetails/Expenses/expense_fund_container.dart
import 'package:flutter/material.dart';
import 'add_expense.dart';
import 'add_fund.dart';
import 'add_transfer.dart'; // Import file mới

enum ExpenseScreen { expense, fund, transfer }

class ExpenseFundContainer extends StatefulWidget {
  const ExpenseFundContainer({super.key});

  @override
  State<ExpenseFundContainer> createState() => _ExpenseFundContainerState();
}

class _ExpenseFundContainerState extends State<ExpenseFundContainer> {
  ExpenseScreen _currentScreen = ExpenseScreen.expense;

  void _showExpense() => setState(() => _currentScreen = ExpenseScreen.expense);
  void _showFund() => setState(() => _currentScreen = ExpenseScreen.fund);
  void _showTransfer() => setState(() => _currentScreen = ExpenseScreen.transfer);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case ExpenseScreen.expense:
        return AddExpenseModal(
          key: const ValueKey('Expense'),
          onNavigateToFund: _showFund,
          onNavigateToTransfer: _showTransfer,
        );
      case ExpenseScreen.fund:
        return AddFundModal(
          key: const ValueKey('Fund'),
          onNavigateToExpense: _showExpense,
          onNavigateToTransfer: _showTransfer,
        );
      case ExpenseScreen.transfer:
        return AddTransferModal(
          key: const ValueKey('Transfer'),
          onNavigateToExpense: _showExpense,
          onNavigateToFund: _showFund,
        );
    }
  }
}
