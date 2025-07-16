// config/mongodb_config.dart
class MongoDBConfig {
  // Local MongoDB connection (for development)
  static const String localConnectionString = 'mongodb://localhost:27017/farmers_financial_tracker';
  
  // MongoDB Atlas connection (for production)
  static const String atlasConnectionString = 'mongodb+srv://username:password@cluster.mongodb.net/farmers_financial_tracker?retryWrites=true&w=majority';
  
  // Current connection string (change this based on environment)
  static const String connectionString = localConnectionString;
  
  // Database name
  static const String databaseName = 'farmers_financial_tracker';
  
  // Collection names
  static const String transactionsCollection = 'transactions';
  static const String farmSectionsCollection = 'farm_sections';
  static const String tasksCollection = 'farm_tasks';
  static const String yieldsCollection = 'yield_records';
  static const String weatherCollection = 'weather_info';
  static const String usersCollection = 'users';
  
  // Connection options
  static const int connectionTimeout = 30000; // 30 seconds
  static const int socketTimeout = 30000; // 30 seconds
  static const int serverSelectionTimeout = 30000; // 30 seconds
  
  // Index configurations
  static const Map<String, List<String>> indexes = {
    transactionsCollection: ['userId', 'date', 'type', 'category'],
    farmSectionsCollection: ['userId', 'cropType'],
    tasksCollection: ['userId', 'dueDate', 'status'],
    yieldsCollection: ['userId', 'cropType', 'harvestDate'],
    weatherCollection: ['location', 'date'],
    usersCollection: ['email'],
  };
} 