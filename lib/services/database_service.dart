// services/database_service.dart
// This file is now a stub. All methods throw UnimplementedError.
// Replace usages with a REST API service (e.g., MySQLService).

class DatabaseService {
  Future<int> insertTransaction(dynamic transaction) async {
    throw UnimplementedError('Use MySQLService instead.');
  }

  Future<List<dynamic>> getTransactions({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    dynamic type,
  }) async {
    throw UnimplementedError('Use MySQLService instead.');
  }

  Future<double> getTotalIncome({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    throw UnimplementedError('Use MySQLService instead.');
  }

  Future<double> getTotalExpenses({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    throw UnimplementedError('Use MySQLService instead.');
  }

  Future<int> insertFarmSection(dynamic section) async {
    throw UnimplementedError('Use MySQLService instead.');
  }

  Future<List<dynamic>> getFarmSections({String? userId}) async {
    throw UnimplementedError('Use MySQLService instead.');
  }

  Future<int> insertTask(dynamic task) async {
    throw UnimplementedError('Use MySQLService instead.');
  }

  Future<List<dynamic>> getTasks({
    String? userId,
    dynamic status,
    DateTime? dueDate,
  }) async {
    throw UnimplementedError('Use MySQLService instead.');
  }

  Future<int> updateTaskStatus(String taskId, dynamic status) async {
    throw UnimplementedError('Use MySQLService instead.');
  }

  Future<int> insertYieldRecord(dynamic yield) async {
    throw UnimplementedError('Use MySQLService instead.');
  }

  Future<List<dynamic>> getYieldRecords({
    String? userId,
    String? cropType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    throw UnimplementedError('Use MySQLService instead.');
  }

  Future<int> insertWeatherInfo(dynamic weather) async {
    throw UnimplementedError('Use MySQLService instead.');
  }

  Future<dynamic> getLatestWeather(String location) async {
    throw UnimplementedError('Use MySQLService instead.');
  }

  Future<List<Map<String, dynamic>>> getPendingSyncData(String table) async {
    throw UnimplementedError('Use MySQLService instead.');
  }

  Future<void> markAsSynced(String table, String id) async {
    throw UnimplementedError('Use MySQLService instead.');
  }

  Future<Map<String, double>> getCategoryTotals({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    required dynamic type,
  }) async {
    throw UnimplementedError('Use MySQLService instead.');
  }

  Future<double> getProfitLoss({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    throw UnimplementedError('Use MySQLService instead.');
  }
}
