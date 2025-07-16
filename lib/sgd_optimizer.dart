// sgd_optimizer.dart
import 'dart:math';

/// Stochastic Gradient Descent (SGD) Optimizer
///
/// This class implements the SGD algorithm for optimizing model parameters.
/// SGD is a popular optimization algorithm used in machine learning for
/// training neural networks and other models.
class SGDOptimizer {
  final double learningRate;
  final double momentum;
  final List<double> velocities;

  SGDOptimizer({this.learningRate = 0.01, this.momentum = 0.9})
      : velocities = [];

  /// Update parameters using SGD with momentum
  ///
  /// [parameters] - Current parameter values
  /// [gradients] - Gradients of the loss function with respect to parameters
  /// Returns updated parameters
  List<double> update(List<double> parameters, List<double> gradients) {
    if (velocities.isEmpty) {
      velocities.addAll(List.filled(parameters.length, 0.0));
    }

    List<double> updatedParameters = List.from(parameters);

    for (int i = 0; i < parameters.length; i++) {
      // Update velocity with momentum
      velocities[i] = momentum * velocities[i] - learningRate * gradients[i];

      // Update parameters
      updatedParameters[i] = parameters[i] + velocities[i];
    }

    return updatedParameters;
  }

  /// Reset optimizer state
  void reset() {
    velocities.clear();
  }
}

/// Simple Linear Regression Model using SGD
class LinearRegressionSGD {
  List<double> weights;
  double bias;
  final SGDOptimizer optimizer;

  LinearRegressionSGD({int inputSize = 1, double learningRate = 0.01})
      : weights = List.filled(inputSize, 0.0),
        bias = 0.0,
        optimizer = SGDOptimizer(learningRate: learningRate);

  /// Predict output for given input
  double predict(List<double> input) {
    if (input.length != weights.length) {
      throw ArgumentError('Input size must match weights size');
    }

    double prediction = bias;
    for (int i = 0; i < input.length; i++) {
      prediction += weights[i] * input[i];
    }
    return prediction;
  }

  /// Train the model using SGD
  ///
  /// [X] - Training features
  /// [y] - Training targets
  /// [epochs] - Number of training epochs
  /// Returns training history (loss values)
  List<double> train(List<List<double>> X, List<double> y, {int epochs = 100}) {
    List<double> losses = [];

    for (int epoch = 0; epoch < epochs; epoch++) {
      double totalLoss = 0.0;
      List<double> weightGradients = List.filled(weights.length, 0.0);
      double biasGradient = 0.0;

      // Stochastic gradient descent - process one sample at a time
      for (int i = 0; i < X.length; i++) {
        double prediction = predict(X[i]);
        double error = prediction - y[i];
        double loss = 0.5 * error * error;
        totalLoss += loss;

        // Compute gradients
        for (int j = 0; j < weights.length; j++) {
          weightGradients[j] += error * X[i][j];
        }
        biasGradient += error;
      }

      // Average gradients
      for (int j = 0; j < weights.length; j++) {
        weightGradients[j] /= X.length;
      }
      biasGradient /= X.length;

      // Update parameters using SGD
      List<double> allGradients = [...weightGradients, biasGradient];
      List<double> allParameters = [...weights, bias];
      List<double> updatedParameters = optimizer.update(
        allParameters,
        allGradients,
      );

      // Extract updated weights and bias
      weights = updatedParameters.sublist(0, weights.length);
      bias = updatedParameters.last;

      losses.add(totalLoss / X.length);
    }

    return losses;
  }

  /// Get model parameters
  Map<String, dynamic> getParameters() {
    return {'weights': List.from(weights), 'bias': bias};
  }

  /// Set model parameters
  void setParameters(Map<String, dynamic> params) {
    weights = List.from(params['weights']);
    bias = params['bias'];
  }
}

/// Utility class for generating synthetic data
class DataGenerator {
  static Random random = Random(42); // Fixed seed for reproducibility

  /// Generate synthetic linear data with noise
  static Map<String, List> generateLinearData({
    int samples = 100,
    double slope = 2.0,
    double intercept = 1.0,
    double noise = 0.1,
  }) {
    List<List<double>> X = [];
    List<double> y = [];

    for (int i = 0; i < samples; i++) {
      double x = random.nextDouble() * 10.0; // Random x values
      double noiseValue = (random.nextDouble() - 0.5) * 2 * noise;
      double target = slope * x + intercept + noiseValue;

      X.add([x]);
      y.add(target);
    }

    return {'X': X, 'y': y};
  }

  /// Generate synthetic classification data
  static Map<String, List> generateClassificationData({
    int samples = 100,
    double separation = 1.0,
  }) {
    List<List<double>> X = [];
    List<double> y = [];

    for (int i = 0; i < samples; i++) {
      double x1 = random.nextDouble() * 4.0 - 2.0;
      double x2 = random.nextDouble() * 4.0 - 2.0;

      // Simple linear separation
      double decision = x1 + x2 + separation;
      double label = decision > 0 ? 1.0 : 0.0;

      X.add([x1, x2]);
      y.add(label);
    }

    return {'X': X, 'y': y};
  }
}
