// models/financial_models.dart
import 'package:uuid/uuid.dart';

/// Financial transaction model for income and expenses
class Transaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? description;
  final String? receiptPath;
  final String? farmSection;
  final String userId;

  Transaction({
    String? id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.description,
    this.receiptPath,
    this.farmSection,
    required this.userId,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.toString(),
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'receiptPath': receiptPath,
      'farmSection': farmSection,
      'userId': userId,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      category: json['category'],
      date: DateTime.parse(json['date']),
      description: json['description'],
      receiptPath: json['receiptPath'],
      farmSection: json['farmSection'],
      userId: json['userId'],
    );
  }
}

enum TransactionType { income, expense }

/// Predefined categories for transactions
class TransactionCategories {
  static const List<String> incomeCategories = [
    'Crop Sales',
    'Livestock Sales',
    'Milk Sales',
    'Egg Sales',
    'Honey Sales',
    'Agricultural Services',
    'Government Subsidies',
    'Other Income',
  ];

  static const List<String> expenseCategories = [
    'Seeds',
    'Fertilizers',
    'Pesticides',
    'Animal Feed',
    'Veterinary Services',
    'Equipment',
    'Fuel',
    'Labor',
    'Transportation',
    'Irrigation',
    'Storage',
    'Insurance',
    'Other Expenses',
  ];

  static List<String> getCategories(TransactionType type) {
    return type == TransactionType.income
        ? incomeCategories
        : expenseCategories;
  }
}

/// Farm section model for organizing farm areas
class FarmSection {
  final String id;
  final String name;
  final String description;
  final double area; // in acres/hectares
  final String cropType;
  final DateTime plantingDate;
  final DateTime? harvestDate;
  final String userId;

  FarmSection({
    String? id,
    required this.name,
    required this.description,
    required this.area,
    required this.cropType,
    required this.plantingDate,
    this.harvestDate,
    required this.userId,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'area': area,
      'cropType': cropType,
      'plantingDate': plantingDate.toIso8601String(),
      'harvestDate': harvestDate?.toIso8601String(),
      'userId': userId,
    };
  }

  factory FarmSection.fromJson(Map<String, dynamic> json) {
    return FarmSection(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      area: json['area'].toDouble(),
      cropType: json['cropType'],
      plantingDate: DateTime.parse(json['plantingDate']),
      harvestDate: json['harvestDate'] != null
          ? DateTime.parse(json['harvestDate'])
          : null,
      userId: json['userId'],
    );
  }
}

/// Task model for farm management
class FarmTask {
  final String? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final TaskStatus status;
  final String? farmSection;
  final String userId;
  final bool isRecurring;
  final String? recurrencePattern; // daily, weekly, monthly

  FarmTask({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.status = TaskStatus.pending,
    this.farmSection,
    required this.userId,
    this.isRecurring = false,
    this.recurrencePattern,
  });

  Map<String, dynamic> toJson() {
    final map = {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.name,
      'status': status.name,
      'farmSection': farmSection,
      'userId': userId,
      'isRecurring': isRecurring,
      'recurrencePattern': recurrencePattern,
    };
    if (id != null && id!.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }

  factory FarmTask.fromJson(Map<String, dynamic> json) {
    return FarmTask(
      id: json['id']?.toString(), // convert int to String
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      farmSection: json['farmSection'],
      userId: json['userId'],
      isRecurring: json['isRecurring'] ?? false,
      recurrencePattern: json['recurrencePattern'],
    );
  }
}

enum TaskPriority { low, medium, high, urgent }

enum TaskStatus { pending, inProgress, completed, cancelled }

/// Yield tracking model
class YieldRecord {
  final String id;
  final String cropType;
  final String farmSection;
  final double quantity;
  final String unit; // kg, tons, bags, etc.
  final DateTime harvestDate;
  final double area; // area harvested
  final String userId;
  final String? notes;

  YieldRecord({
    String? id,
    required this.cropType,
    required this.farmSection,
    required this.quantity,
    required this.unit,
    required this.harvestDate,
    required this.area,
    required this.userId,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cropType': cropType,
      'farmSection': farmSection,
      'quantity': quantity,
      'unit': unit,
      'harvestDate': harvestDate.toIso8601String(),
      'area': area,
      'userId': userId,
      'notes': notes,
    };
  }

  factory YieldRecord.fromJson(Map<String, dynamic> json) {
    return YieldRecord(
      id: json['id'],
      cropType: json['cropType'],
      farmSection: json['farmSection'],
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
      harvestDate: DateTime.parse(json['harvestDate']),
      area: json['area'].toDouble(),
      userId: json['userId'],
      notes: json['notes'],
    );
  }

  double get yieldPerUnit => area > 0 ? quantity / area : 0;
}

/// Weather information model
class WeatherInfo {
  final DateTime date;
  final double temperature;
  final double humidity;
  final String condition;
  final double? rainfall;
  final String location;

  WeatherInfo({
    required this.date,
    required this.temperature,
    required this.humidity,
    required this.condition,
    this.rainfall,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'temperature': temperature,
      'humidity': humidity,
      'condition': condition,
      'rainfall': rainfall,
      'location': location,
    };
  }

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      date: DateTime.parse(json['date']),
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
      condition: json['condition'],
      rainfall: json['rainfall']?.toDouble(),
      location: json['location'],
    );
  }
}

/// Financial health score model
class FinancialHealthScore {
  final double score; // 0-100
  final String level; // Poor, Fair, Good, Excellent
  final List<String> recommendations;
  final DateTime calculatedDate;

  FinancialHealthScore({
    required this.score,
    required this.level,
    required this.recommendations,
    required this.calculatedDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'level': level,
      'recommendations': recommendations,
      'calculatedDate': calculatedDate.toIso8601String(),
    };
  }

  factory FinancialHealthScore.fromJson(Map<String, dynamic> json) {
    return FinancialHealthScore(
      score: json['score'].toDouble(),
      level: json['level'],
      recommendations: List<String>.from(json['recommendations']),
      calculatedDate: DateTime.parse(json['calculatedDate']),
    );
  }
}
