import 'package:flutter/material.dart';
import 'add_expense.dart';
import 'add_fund.dart';

// Đã bỏ chức năng Chuyển tiền
enum ExpenseScreen { expense, fund }

class ExpenseFundContainer extends StatefulWidget {
  final String tripId;
  const ExpenseFundContainer({super.key, required this.tripId});

  @override
  State<ExpenseFundContainer> createState() => _ExpenseFundContainerState();
}

class _ExpenseFundContainerState extends State<ExpenseFundContainer> {
  ExpenseScreen _currentScreen = ExpenseScreen.expense;

  void _showExpense() => setState(() => _currentScreen = ExpenseScreen.expense);
  void _showFund() => setState(() => _currentScreen = ExpenseScreen.fund);

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
          key: const ValueKey('ChiPhi'), // Đã sửa
          tripId: widget.tripId,
          onNavigateToFund: _showFund,
        );
      case ExpenseScreen.fund:
        return AddFundModal(
          key: const ValueKey('Quy'), // Đã sửa
          tripId: widget.tripId,
          onNavigateToExpense: _showExpense,
        );
    }
  }
}
