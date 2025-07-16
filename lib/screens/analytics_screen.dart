// screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/financial_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinancialProvider>();
    return Scaffold(
      appBar: AppBar(title: Text('Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Income: ${provider.totalIncome}'),
            Text('Total Expenses: ${provider.totalExpenses}'),
            Text('Profit/Loss: ${provider.profitLoss}'),
            // You can add a chart widget here in the future
          ],
        ),
      ),
    );
  }
}
