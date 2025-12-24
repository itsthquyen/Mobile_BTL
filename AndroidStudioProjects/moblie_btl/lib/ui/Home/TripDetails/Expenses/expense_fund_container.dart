// lib/ui/Home/TripDetails/Expenses/expense_fund_container.dart
import 'package:flutter/material.dart';
import 'add_expense.dart';
import 'add_fund.dart';
import 'add_transfer.dart';

enum ExpenseScreen { expense, fund, transfer }

class ExpenseFundContainer extends StatefulWidget {
  final String tripId; // Nhận tripId từ TripDetailsPage
  const ExpenseFundContainer({super.key, required this.tripId});

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
          tripId: widget.tripId, // Truyền tripId xuống
          onNavigateToFund: _showFund,
          onNavigateToTransfer: _showTransfer,
        );
      case ExpenseScreen.fund:
        return AddFundModal(
          key: const ValueKey('Fund'),
          tripId: widget.tripId, // Truyền tripId xuống
          onNavigateToExpense: _showExpense,
          onNavigateToTransfer: _showTransfer,
        );
      case ExpenseScreen.transfer:
        return AddTransferModal(
          key: const ValueKey('Transfer'),
          tripId: widget.tripId, // Truyền tripId xuống
          onNavigateToExpense: _showExpense,
          onNavigateToFund: _showFund,
        );
    }
  }
}
