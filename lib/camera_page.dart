//camera_page.dart
import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'main.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? cameraController;
  String result = 'Инициализация...';
  bool modelLoaded = false;
  bool cameraInitialized = false;
  Interpreter? interpreter;
  List<String> labels = [];
  bool isRearCamera = true;

  
  // Изоляция для обработки
  bool _isolateRunning = false;
  late ReceivePort _receivePort;
  SendPort? _isolateSendPort;

  @override
  void initState() {
    super.initState();
    _receivePort = ReceivePort();
    _initializeApp();
    _initIsolate();
  }

  Future<void> _initializeApp() async {
    try {
      await _loadModel();
      await _loadLabels();
      await _initCamera();
      setState(() => result = 'Готово к распознаванию');
    } catch (e) {
      setState(() => result = 'Ошибка: ${e.toString()}');
      print('Initialization error: $e');
    }
  }

  Future<void> _initIsolate() async {
    _receivePort.listen(_handleModelResults);
    await Isolate.spawn(_modelRunner, _receivePort.sendPort);
  }

static void _modelRunner(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);
    
    Interpreter? isolateInterpreter;
    List<String> isolateLabels = [];

    await for (final message in port) {
      if (message is List) {
        if (message[0] == 'init') {
          try {
            isolateInterpreter = message[1] as Interpreter;
            isolateLabels = message[2] as List<String>;
            
            // Проверяем входные и выходные тензоры
            print('Input tensor: ${isolateInterpreter.getInputTensor(0).shape}');
            print('Output tensor: ${isolateInterpreter.getOutputTensor(0).shape}');
            
            sendPort.send('model_ready');
          } catch (e) {
            sendPort.send('model_error: ${e.toString()}');
          }
        }
        else if (message[0] == 'process') {
          try {
            final planeY = message[1] as Uint8List;
            final width = message[2] as int;
            final height = message[3] as int;
            
            // Создаем Float32List напрямую
            final input = Float32List(width * height * 3);
            for (int i = 0; i < planeY.length; i++) {
              final val = planeY[i] / 255.0;
              input[i*3] = val;     // R
              input[i*3+1] = val;   // G
              input[i*3+2] = val;   // B
            }

            // Получаем реальную форму из модели
            final inputShape = isolateInterpreter!.getInputTensor(0).shape;
            final outputShape = isolateInterpreter.getOutputTensor(0).shape;
            
            // Подготавливаем выходной буфер
            final output = Float32List(outputShape.reduce((a, b) => a * b));
            
            // Запускаем модель
            isolateInterpreter.run(input.reshape(inputShape), output.reshape(outputShape));

            // Находим лучший результат
            int maxIndex = 0;
            double maxProb = output[0];
            for (int i = 1; i < output.length; i++) {
              if (output[i] > maxProb) {
                maxProb = output[i];
                maxIndex = i;
              }
            }

            sendPort.send({
              'label': isolateLabels[maxIndex],
              'confidence': maxProb,
            });
          } catch (e) {
            sendPort.send({'error': e.toString()});
          }
        }
      }
    }
  }
void _handleModelResults(dynamic message) {
  if (message is SendPort) {
    _isolateSendPort = message;
    _isolateSendPort?.send(['init', interpreter, labels]);
  } 
  else if (message is String && message == 'model_ready') {
    print('Model ready in isolate');
  }
  else if (message is Map) {
    if (message.containsKey('error')) {
      print('Isolate error: ${message['error']}');
      setState(() => result = "Ошибка обработки");
    } else {
      setState(() {
        result = "${message['label']} (${(message['confidence'] * 100).toStringAsFixed(0)}%)";
      });
    }
    _isolateRunning = false;
  }
}

Future<void> _loadModel() async {
  try {
    interpreter = await Interpreter.fromAsset(
      'assets/models/models_our.tflite',
      options: InterpreterOptions()..threads = 2,
    );
    
    // Проверка формы ввода/вывода
    final inputTensor = interpreter!.getInputTensor(0);
    final outputTensor = interpreter!.getOutputTensor(0);
    print('Input shape: ${inputTensor.shape}');
    print('Output shape: ${outputTensor.shape}');
    
    modelLoaded = true;
  } catch (e) {
    print('Failed to load model: $e');
    throw Exception('Failed to load model');
  }
}

  Future<void> _loadLabels() async {
    try {
      final rawLabels = await rootBundle.loadString('assets/models/labels.txt');
      labels = rawLabels.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      print('Labels loaded: ${labels.length}');
    } catch (e) {
      print('Error loading labels: $e');
      throw Exception('Не удалось загрузить метки');
    }
  }

Future<void> _initCamera() async {
  try {
    // Динамически выбираем камеру на основе переменной isRearCamera
    final cameraIndex = isRearCamera ? 0 : 1;
    
    if (cameras.isEmpty) {
      throw Exception('Камеры не найдены');
    }

    cameraController = CameraController(
      cameras[cameraIndex], // Используем выбранную камеру
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await cameraController!.initialize();

    if (!mounted) return;

    setState(() {
      cameraInitialized = true;
    });

    cameraController!.startImageStream((image) {
      if (_isolateRunning || !modelLoaded || _isolateSendPort == null) return;

      _isolateRunning = true;
      // Передаем только Y-плоскость для экономии памяти
      final planeY = Uint8List.fromList(image.planes[0].bytes);
      _isolateSendPort?.send([
        'process',
        planeY,
        image.width,
        image.height
      ]);
    });
  } catch (e) {
    print('Ошибка инициализации камеры: $e');
    throw Exception('Не удалось инициализировать камеру');
  }
}


  @override
  void dispose() {
    _receivePort.close();
    cameraController?.dispose();
    interpreter?.close();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // Камера на весь экран
        if (cameraInitialized)
          Positioned.fill(  // Использование Positioned.fill для растягивания на весь экран
            child: CameraPreview(cameraController!),
          )
        else
          const Center(child: CircularProgressIndicator()),

        // Результат распознавания
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.only(bottom: 50),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              result,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Кнопка переключения камеры
        Positioned(
          top: 40,
          right: 20,
          child: IconButton(
            icon: const Icon(
              Icons.flip_camera_android,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () async {
              setState(() {
                isRearCamera = !isRearCamera; // Переключение типа камеры
              });

              // Остановка текущего потока изображений, закрытие камеры и переинициализация
              await cameraController?.stopImageStream();
              await cameraController?.dispose();
              await _initCamera(); // Переинициализация камеры с новым типом
            },
          ),
        ),
      ],
    ),
  );
}


}