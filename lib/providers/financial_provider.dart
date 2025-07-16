// providers/financial_provider.dart
import 'package:flutter/foundation.dart';
import '../models/financial_models.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../services/weather_service.dart';
import '../services/task_service.dart';
import '../providers/auth_provider.dart';
// TODO: import 'transaction_service.dart';
// TODO: import 'yield_service.dart';
// TODO: import 'farm_section_service.dart';

class FinancialProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<FarmSection> _farmSections = [];
  List<FarmTask> _tasks = [];
  List<YieldRecord> _yields = [];
  WeatherInfo? _currentWeather;
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double _profitLoss = 0.0;
  String? _currentCity;

  FinancialProvider() {
    _loadData();
  }

  // Getters
  List<Transaction> get transactions => _transactions;
  List<FarmSection> get farmSections => _farmSections;
  List<FarmTask> get tasks => _tasks;
  List<YieldRecord> get yields => _yields;
  WeatherInfo? get currentWeather => _currentWeather;
  double get totalIncome => _totalIncome;
  double get totalExpenses => _totalExpenses;
  double get profitLoss => _profitLoss;
  String? get currentCity => _currentCity;

  final WeatherService _weatherService = WeatherService();
  final TaskService _taskService = TaskService();
  // TODO: final TransactionService _transactionService = TransactionService();
  // TODO: final YieldService _yieldService = YieldService();
  // TODO: final FarmSectionService _farmSectionService = FarmSectionService();

  Future<void> _loadData() async {
    await Future.wait([
      loadTransactions(),
      loadFarmSections(),
      loadTasks(),
      loadYields(),
      loadWeather('Nairobi'), // Ensure weather is loaded
    ]);
    _calculateTotals();
  }

  Future<void> loadData() async {
    await _loadData();
  }

  // Transaction methods
  Future<void> loadTransactions({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    TransactionType? type,
  }) async {
    // TODO: Replace with REST API call to fetch transactions from MySQL backend
    _transactions = [];
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    // TODO: Replace with REST API call to add transaction to MySQL backend
    _transactions.add(transaction);
    _calculateTotals();
    notifyListeners();
  }

  Future<void> deleteTransaction(String transactionId) async {
    // TODO: Replace with REST API call to delete transaction from MySQL backend
    _transactions.removeWhere((t) => t.id == transactionId);
    _calculateTotals();
    notifyListeners();
  }

  // Farm section methods
  Future<void> loadFarmSections() async {
    // TODO: Replace with REST API call to fetch farm sections from MySQL backend
    _farmSections = [];
    notifyListeners();
  }

  Future<void> addFarmSection(FarmSection section) async {
    // TODO: Replace with REST API call to add farm section to MySQL backend
    _farmSections.add(section);
    notifyListeners();
  }

  Future<void> updateFarmSection(FarmSection section) async {
    // TODO: Replace with REST API call to update farm section in MySQL backend
    final index = _farmSections.indexWhere((s) => s.id == section.id);
    if (index != -1) {
      _farmSections[index] = section;
      notifyListeners();
    }
  }

  // Task methods
  Future<void> loadTasks() async {
    // Get the current userId from AuthProvider
    final authProvider = AuthProvider();
    final userId = authProvider.userId ?? '';
    _tasks = await _taskService.fetchTasks(userId: userId);
    notifyListeners();
  }

  Future<void> addTask(FarmTask task) async {
    final newTask = await _taskService.addTask(task);
    _tasks.add(newTask);
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    await _taskService.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> updateTask(FarmTask updatedTask) async {
    final task = await _taskService.updateTask(updatedTask);
    final idx = _tasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) _tasks[idx] = task;
    notifyListeners();
  }

  // Yield methods
  Future<void> loadYields({String? cropType}) async {
    // TODO: Replace with REST API call to fetch yields from MySQL backend
    _yields = [];
    notifyListeners();
  }

  Future<void> addYieldRecord(YieldRecord yieldRecord) async {
    // TODO: Replace with REST API call to add yield record to MySQL backend
    _yields.add(yieldRecord);
    notifyListeners();
  }

  // Weather methods
  Future<void> loadWeather(String location) async {
    _currentWeather = await _weatherService.getLatestWeather(location);
    notifyListeners();
  }

  Future<void> updateWeather(WeatherInfo weather) async {
    // MongoDBService.insertWeatherInfo(weather); // This line was removed as per the edit hint
    _currentWeather = weather;
    notifyListeners();
  }

  Future<void> loadWeatherForCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Reverse geocode to get city
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      _currentCity = placemarks.first.locality ??
          placemarks.first.subAdministrativeArea ??
          placemarks.first.country;
    }

    // Fetch weather using lat,lon
    await loadWeather('${position.latitude},${position.longitude}');
    notifyListeners();
  }

  // Analytics methods
  void _calculateTotals() {
    _totalIncome = _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    _totalExpenses = _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    _profitLoss = _totalIncome - _totalExpenses;
  }

  Future<Map<String, double>> getCategoryTotals({
    DateTime? startDate,
    DateTime? endDate,
    required TransactionType type,
  }) async {
    // MongoDBService.getCategoryTotals( // This line was removed as per the edit hint
    //   startDate: startDate,
    //   endDate: endDate,
    //   type: type,
    // );
    return {}; // Placeholder for now
  }

  List<Transaction> getRecentTransactions({int limit = 5}) {
    final sorted = List<Transaction>.from(_transactions);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  List<FarmTask> getUpcomingTasks({int days = 7}) {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: days));

    return _tasks.where((task) {
      return task.status == TaskStatus.pending &&
          task.dueDate.isAfter(now) &&
          task.dueDate.isBefore(endDate);
    }).toList();
  }

  List<FarmTask> getOverdueTasks() {
    final now = DateTime.now();
    return _tasks.where((task) {
      return task.status == TaskStatus.pending && task.dueDate.isBefore(now);
    }).toList();
  }

  // Financial health calculation
  FinancialHealthScore calculateFinancialHealth() {
    double score = 0.0;
    List<String> recommendations = [];

    // Profit margin (40% of score)
    if (_totalIncome > 0) {
      double profitMargin = (_profitLoss / _totalIncome) * 100;
      if (profitMargin >= 30) {
        score += 40;
      } else if (profitMargin >= 20) {
        score += 30;
      } else if (profitMargin >= 10) {
        score += 20;
      } else if (profitMargin >= 0) {
        score += 10;
      }

      if (profitMargin < 20) {
        recommendations.add(
          'Consider reducing expenses or increasing income to improve profit margin',
        );
      }
    }

    // Expense control (30% of score)
    if (_totalExpenses > 0) {
      double expenseRatio = _totalExpenses / (_totalIncome + _totalExpenses);
      if (expenseRatio <= 0.6) {
        score += 30;
      } else if (expenseRatio <= 0.7) {
        score += 20;
      } else if (expenseRatio <= 0.8) {
        score += 10;
      }

      if (expenseRatio > 0.7) {
        recommendations.add('Focus on reducing operational costs');
      }
    }

    // Cash flow (20% of score)
    if (_profitLoss > 0) {
      score += 20;
    } else if (_profitLoss > -_totalIncome * 0.1) {
      score += 10;
    }

    if (_profitLoss < 0) {
      recommendations.add(
        'Work on improving cash flow through better planning',
      );
    }

    // Task completion (10% of score)
    if (_tasks.isNotEmpty) {
      int completedTasks =
          _tasks.where((t) => t.status == TaskStatus.completed).length;
      double completionRate = completedTasks / _tasks.length;
      if (completionRate >= 0.8) {
        score += 10;
      } else if (completionRate >= 0.6) {
        score += 5;
      }

      if (completionRate < 0.7) {
        recommendations.add(
          'Improve task completion rates for better productivity',
        );
      }
    }

    // Determine health level
    String level;
    if (score >= 80) {
      level = 'Excellent';
    } else if (score >= 60) {
      level = 'Good';
    } else if (score >= 40) {
      level = 'Fair';
    } else {
      level = 'Poor';
    }

    return FinancialHealthScore(
      score: score,
      level: level,
      recommendations: recommendations,
      calculatedDate: DateTime.now(),
    );
  }
}
