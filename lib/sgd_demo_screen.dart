// sgd_demo_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'sgd_optimizer.dart';

class SGDDemoScreen extends StatefulWidget {
  const SGDDemoScreen({super.key});

  @override
  State<SGDDemoScreen> createState() => _SGDDemoScreenState();
}

class _SGDDemoScreenState extends State<SGDDemoScreen> {
  late LinearRegressionSGD model;
  List<double> trainingLosses = [];
  List<List<double>> trainingData = [];
  List<double> trainingTargets = [];
  bool isTraining = false;
  double currentLoss = 0.0;
  int currentEpoch = 0;
  final int totalEpochs = 100;

  // UI Controllers
  final TextEditingController learningRateController = TextEditingController(
    text: '0.01',
  );
  final TextEditingController epochsController = TextEditingController(
    text: '100',
  );
  final TextEditingController predictionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    model = LinearRegressionSGD(learningRate: 0.01);
    generateData();
  }

  @override
  void dispose() {
    learningRateController.dispose();
    epochsController.dispose();
    predictionController.dispose();
    super.dispose();
  }

  void generateData() {
    var data = DataGenerator.generateLinearData(
      samples: 50,
      slope: 2.0,
      intercept: 1.0,
      noise: 0.5,
    );

    setState(() {
      trainingData = List<List<double>>.from(data['X'] ?? []);
      trainingTargets = List<double>.from(data['y'] ?? []);
      trainingLosses.clear();
      currentLoss = 0.0;
      currentEpoch = 0;
    });
  }

  Future<void> trainModel() async {
    if (isTraining) return;

    setState(() {
      isTraining = true;
      trainingLosses.clear();
      currentEpoch = 0;
    });

    // Reset model
    model = LinearRegressionSGD(
      learningRate: double.tryParse(learningRateController.text) ?? 0.01,
    );

    int epochs = int.tryParse(epochsController.text) ?? 100;

    for (int epoch = 0; epoch < epochs; epoch++) {
      if (!mounted) break;

      // Train one epoch
      List<double> epochLosses = model.train(
        trainingData,
        trainingTargets,
        epochs: 1,
      );

      setState(() {
        trainingLosses.add(epochLosses.first);
        currentLoss = epochLosses.first;
        currentEpoch = epoch + 1;
      });

      // Add delay to visualize training progress
      await Future.delayed(const Duration(milliseconds: 50));
    }

    setState(() {
      isTraining = false;
    });
  }

  void makePrediction() {
    double? input = double.tryParse(predictionController.text);
    if (input == null) return;

    double prediction = model.predict([input]);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Prediction for x=$input: ${prediction.toStringAsFixed(3)}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SGD Optimizer Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stochastic Gradient Descent (SGD)',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'SGD is an optimization algorithm used to minimize loss functions in machine learning. '
                      'It updates model parameters by computing gradients on small batches of data.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Training Parameters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: learningRateController,
                            decoration: const InputDecoration(
                              labelText: 'Learning Rate',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: epochsController,
                            decoration: const InputDecoration(
                              labelText: 'Epochs',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isTraining ? null : trainModel,
                            child: Text(
                              isTraining ? 'Training...' : 'Train Model',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: generateData,
                            child: const Text('Generate New Data'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (isTraining || trainingLosses.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Training Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isTraining)
                        LinearProgressIndicator(
                          value: currentEpoch / totalEpochs,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Epoch: $currentEpoch / ${epochsController.text}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Current Loss: ${currentLoss.toStringAsFixed(4)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (trainingLosses.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Loss History',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: CustomPaint(
                            painter: LossChartPainter(trainingLosses),
                            child: Container(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Make Predictions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: predictionController,
                            decoration: const InputDecoration(
                              labelText: 'Input Value (x)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: makePrediction,
                          child: const Text('Predict'),
                        ),
                      ],
                    ),
                    if (model.weights.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Model Parameters:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Weight: ${model.weights[0].toStringAsFixed(4)}'),
                      Text('Bias: ${model.bias.toStringAsFixed(4)}'),
                      Text(
                        'Equation: y = ${model.weights[0].toStringAsFixed(4)}x + ${model.bias.toStringAsFixed(4)}',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LossChartPainter extends CustomPainter {
  final List<double> losses;

  LossChartPainter(this.losses);

  @override
  void paint(Canvas canvas, Size size) {
    if (losses.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();

    double maxLoss = losses.reduce((a, b) => a > b ? a : b);
    double minLoss = losses.reduce((a, b) => a < b ? a : b);
    double range = maxLoss - minLoss;

    if (range == 0) range = 1.0;

    for (int i = 0; i < losses.length; i++) {
      double x = (i / (losses.length - 1)) * size.width;
      double y = size.height - ((losses[i] - minLoss) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
