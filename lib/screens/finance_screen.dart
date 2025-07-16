// screens/finance_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/financial_provider.dart';
import '../models/financial_models.dart';
import '../widgets/financial_summary_card.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    return Scaffold(
      appBar: AppBar(title: const Text('Finance')),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<FinancialProvider>().loadTransactions();
        },
        child: Consumer<FinancialProvider>(
          builder: (context, financial, child) {
            final transactions = financial.transactions;
            return Scrollbar(
              thumbVisibility: true,
              controller: scrollController,
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  FinancialSummaryCard(
                    totalIncome: financial.totalIncome,
                    totalExpenses: financial.totalExpenses,
                    profitLoss: financial.profitLoss,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (transactions.isEmpty)
                    const Center(
                      child: Text(
                        'No transactions yet.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ...transactions
                        .take(10)
                        .map((t) => Card(
                              child: ListTile(
                                leading: Icon(
                                  t.type == TransactionType.income
                                      ? Icons.trending_up
                                      : Icons.trending_down,
                                  color: t.type == TransactionType.income
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                title: Text(t.title),
                                subtitle: Text(
                                    '${t.category} • ${t.date.toLocal().toString().split(' ')[0]}'),
                                trailing: Text(
                                  '${t.type == TransactionType.income ? '+' : '-'}${t.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: t.type == TransactionType.income
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
