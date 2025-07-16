// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/financial_provider.dart';
import '../providers/auth_provider.dart';
import '../models/financial_models.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/financial_summary_card.dart';
import '../widgets/weather_card.dart';
import '../widgets/task_summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinancialProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<FinancialProvider>().loadData();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.green[100],
                            child: Icon(
                              Icons.agriculture,
                              size: 30,
                              color: Colors.green[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'welcome_back'.tr(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  auth.userName ?? 'Farmer',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Financial Summary
              Consumer<FinancialProvider>(
                builder: (context, financial, child) {
                  return FinancialSummaryCard(
                    totalIncome: financial.totalIncome,
                    totalExpenses: financial.totalExpenses,
                    profitLoss: financial.profitLoss,
                  );
                },
              ),

              const SizedBox(height: 16),

              // Weather Card
              Consumer<FinancialProvider>(
                builder: (context, financial, child) {
                  return WeatherCard(
                    weather: financial.currentWeather,
                    onRefresh: () async {
                      await context
                          .read<FinancialProvider>()
                          .loadWeather('Nairobi');
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // Quick Actions
              Text(
                'quick_actions'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  QuickActionCard(
                    icon: Icons.add_circle,
                    title: 'add_income'.tr(),
                    color: Colors.green,
                    onTap: () {
                      _showAddTransactionDialog(
                        context,
                        TransactionType.income,
                      );
                    },
                  ),
                  QuickActionCard(
                    icon: Icons.remove_circle,
                    title: 'add_expense'.tr(),
                    color: Colors.red,
                    onTap: () {
                      _showAddTransactionDialog(
                        context,
                        TransactionType.expense,
                      );
                    },
                  ),
                  QuickActionCard(
                    icon: Icons.task,
                    title: 'add_task'.tr(),
                    color: Colors.blue,
                    onTap: () {
                      _showAddTaskDialog(context);
                    },
                  ),
                  QuickActionCard(
                    icon: Icons.camera_alt,
                    title: 'scan_receipt'.tr(),
                    color: Colors.orange,
                    onTap: () {
                      _scanReceipt(context);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Recent Transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'recent_transactions'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to finance screen
                      DefaultTabController.of(context).animateTo(1);
                    },
                    child: Text('view_all'.tr()),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Consumer<FinancialProvider>(
                builder: (context, financial, child) {
                  final recentTransactions = financial.getRecentTransactions();
                  if (recentTransactions.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'no_transactions_yet'.tr(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: recentTransactions
                        .take(3)
                        .map(
                          (transaction) => _buildTransactionTile(transaction),
                        )
                        .toList(),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Task Summary
              Consumer<FinancialProvider>(
                builder: (context, financial, child) {
                  final upcomingTasks = financial.getUpcomingTasks();
                  final overdueTasks = financial.getOverdueTasks();
                  return TaskSummaryCard(
                    upcomingTasks: upcomingTasks,
                    overdueTasks: overdueTasks,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.type == TransactionType.income
              ? Colors.green[100]
              : Colors.red[100],
          child: Icon(
            transaction.type == TransactionType.income
                ? Icons.trending_up
                : Icons.trending_down,
            color: transaction.type == TransactionType.income
                ? Colors.green[600]
                : Colors.red[600],
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${transaction.category} • ${DateFormat('MMM dd').format(transaction.date)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Text(
          '${transaction.type == TransactionType.income ? '+' : '-'}${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: transaction.type == TransactionType.income
                ? Colors.green[600]
                : Colors.red[600],
          ),
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, TransactionType type) {
    showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(type: type),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const AddTaskDialog());
  }

  void _scanReceipt(BuildContext context) {
    // TODO: Implement receipt scanning
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('receipt_scanning_coming_soon'.tr())),
    );
  }
}

// Placeholder dialogs - these would be implemented as separate widgets
class AddTransactionDialog extends StatelessWidget {
  final TransactionType type;

  const AddTransactionDialog({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        type == TransactionType.income ? 'add_income'.tr() : 'add_expense'.tr(),
      ),
      content: const Text('Transaction dialog coming soon...'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('cancel'.tr()),
        ),
      ],
    );
  }
}

class AddTaskDialog extends StatelessWidget {
  const AddTaskDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('add_task'.tr()),
      content: const Text('Task dialog coming soon...'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('cancel'.tr()),
        ),
      ],
    );
  }
}
