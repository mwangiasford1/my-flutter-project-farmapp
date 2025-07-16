# Farmer's Financial Tracker App

A comprehensive Flutter mobile application designed to empower farmers in managing their finances, productivity, and agricultural decisions—especially in rural environments with limited connectivity.

## 🌟 Key Features

### 💰 Financial Management
- **Record Expenses**: Log purchases (seeds, fertilizer, veterinary services) categorized by type
- **Track Income**: Document product sales (milk, crops, livestock) and services
- **Profit/Loss Analysis**: Visual summaries by day, month, crop, or farm section
- **Receipts Upload**: Snap and save receipts for future reference (coming soon)

### 📊 Productivity & Planning Tools
- **Task Scheduler**: Set daily, weekly, and seasonal farming tasks with reminders
- **Yield Estimator**: Track productivity over time by crop or livestock
- **Weather-Aware Planning**: Basic forecasts to guide planting and harvest decisions

### 🎙️ Accessibility & Interaction
- **Voice Input Support**: Speech-to-text for farmers with limited literacy or multitasking needs
- **Offline Mode**: Core features work without internet; auto-sync when online
- **Local Language Options**: Interface supports English and Swahili

### 🔐 Cloud & Data Integration
- **MongoDB Integration**: NoSQL database for flexible data storage and scalability
- **Firebase Integration**: For secure syncing, real-time data access, and backup
- **User Profiles**: Allow multi-farm tracking or sharing insights with cooperatives
- **MongoDB Atlas**: Cloud-hosted database for production deployment

### ⚖️ Ethical Insights
- **Fair AI Tips**: Suggestions on optimizing yield without bias or manipulation
- **Simple Financial Health Scores**: Promote sustainable practices through personalized advice

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator
- MongoDB (local or MongoDB Atlas)

### MongoDB Setup

#### Option 1: Local MongoDB
1. Install MongoDB Community Server
2. Start MongoDB service
3. Update `lib/config/mongodb_config.dart` to use local connection

#### Option 2: MongoDB Atlas (Recommended for Production)
1. Create MongoDB Atlas account
2. Create a new cluster
3. Get connection string
4. Update `lib/config/mongodb_config.dart` with Atlas connection string

### Installation
1. Clone the repository
2. Navigate to the project directory
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Configure MongoDB connection in `lib/config/mongodb_config.dart`
5. Run the app:
   ```bash
   flutter run
   ```

## 📱 App Structure

### Screens
- **Home**: Dashboard with financial summary, weather, and quick actions
- **Finance**: Detailed financial management and transaction history
- **Tasks**: Farm task management and scheduling
- **Analytics**: Data visualization and reporting
- **Profile**: User settings and account management

### Core Components
- **Models**: Data structures for transactions, tasks, farm sections, etc.
- **Providers**: State management using Provider pattern
- **Services**: MongoDB service for data operations
- **Widgets**: Reusable UI components

## 🛠️ Technical Stack

### Dependencies
- **State Management**: Provider
- **Database**: MongoDB (mongo_dart package)
- **Authentication**: Firebase Auth
- **Storage**: Firebase Storage
- **Charts**: FL Chart
- **Speech Recognition**: Speech to Text
- **Localization**: Easy Localization
- **Connectivity**: Connectivity Plus
- **Image Picker**: Camera and gallery access

### Architecture
- **MVVM Pattern**: Model-View-ViewModel with Provider
- **Repository Pattern**: Data access abstraction
- **MongoDB Integration**: NoSQL database with flexible schema
- **Responsive Design**: Works on various screen sizes

## 🗄️ MongoDB Schema

### Collections
- **transactions**: Financial transactions (income/expenses)
- **farm_sections**: Farm area management
- **farm_tasks**: Task scheduling and management
- **yield_records**: Crop and livestock production tracking
- **weather_info**: Weather data storage
- **users**: User profiles and authentication

### Indexes
- User-based queries for multi-tenant support
- Date-based queries for time-series analysis
- Category-based queries for financial reporting
- Location-based queries for weather data

## 🌍 Localization

The app supports multiple languages:
- **English** (en-US)
- **Swahili** (sw-KE)

Translation files are located in `assets/translations/`

## 📊 Features in Development

### Current Status
- ✅ Basic app structure and navigation
- ✅ Financial models and MongoDB schema
- ✅ Home screen with dashboard
- ✅ Provider state management
- ✅ Localization setup
- ✅ MongoDB integration
- ✅ Database configuration

### Coming Soon
- 🔄 Finance screen with transaction management
- 🔄 Task management screen
- 🔄 Analytics and reporting
- 🔄 Voice input functionality
- 🔄 Receipt scanning
- 🔄 Weather integration
- 🔄 Firebase integration
- 🔄 User authentication

## 🎨 UI/UX Design

### Theme
- **Primary Color**: Green (representing agriculture)
- **Material Design 3**: Modern, accessible interface
- **Responsive Layout**: Adapts to different screen sizes
- **Intuitive Navigation**: Bottom navigation for easy access

### Accessibility
- **Voice Input**: Speech-to-text for hands-free operation
- **Large Touch Targets**: Easy interaction for all users
- **High Contrast**: Clear visibility in various lighting conditions
- **Local Language Support**: Native language interface

## 🔧 Development

### Project Structure
```
lib/
├── config/         # Configuration files (MongoDB, etc.)
├── models/         # Data models
├── providers/      # State management
├── screens/        # UI screens
├── services/       # Business logic (MongoDB service)
├── widgets/        # Reusable components
└── main.dart       # App entry point
```

### MongoDB Configuration
```dart
// lib/config/mongodb_config.dart
class MongoDBConfig {
  static const String connectionString = 'mongodb://localhost:27017/farmers_financial_tracker';
  static const String databaseName = 'farmers_financial_tracker';
  // ... more configuration
}
```

## 🚀 Deployment

### MongoDB Atlas Setup
1. Create MongoDB Atlas account
2. Create new cluster
3. Configure network access
4. Create database user
5. Get connection string
6. Update configuration

### Environment Configuration
- **Development**: Local MongoDB
- **Production**: MongoDB Atlas
- **Testing**: MongoDB Atlas test cluster

## 🤝 Contributing

We welcome contributions! Please feel free to:
- Report bugs
- Suggest new features
- Submit pull requests
- Improve documentation

## 📄 License

This project is open source and available under the MIT License.

## 📞 Support

For support and questions:
- Create an issue on GitHub
- Contact the development team
- Check the documentation

---

**Built with ❤️ for farmers worldwide**
