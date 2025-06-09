//scan_controller.dart
import 'dart:typed_data';
import 'dart:io'; // Для сохранения отладочных изображений
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class ScanController {
  late Interpreter _interpreter;
  bool _isDetecting = false;
  List<String> _labels = [];
  bool _modelLoaded = false;

  Future<void> loadModel() async {
    try {
      print("Пытаюсь загрузить модель...");
      _interpreter = await Interpreter.fromAsset('model_unquant.tflite');
      
      // Проверка входного/выходного тензора модели
      print("Входные тензоры модели: ${_interpreter.getInputTensors()}");
      print("Выходные тензоры модели: ${_interpreter.getOutputTensors()}");
      
      // Загружаем labels
      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData.split('\n');
      _modelLoaded = true;
      
      print("Модель успешно загружена");
      print("Загружено ${_labels.length} лейблов");
    } catch (e) {
      print("Ошибка загрузки модели: $e");
      _modelLoaded = false;
    }
  }

  Future<String?> detectGesture(CameraImage image) async {
    if (_isDetecting || !_modelLoaded) return null;
    _isDetecting = true;

    try {
      // Проверка на валидность кадра
      if (image.width == 0 || image.height == 0) {
        print("Ошибка: изображение пустое (${image.width}x${image.height})");
        return null;
      }

      print("Обработка кадра: ${image.width}x${image.height}, формат: ${image.format.group}");

      // Преобразование CameraImage -> RGB -> Tensor
      final input = await _preprocessCameraImage(image);

      // Если input пустой — выходим
      if (input.isEmpty || input[0].isEmpty || input[0][0].isEmpty) {
        print("Ошибка: входной тензор пустой");
        return null;
      }

      // Создаем буфер для результата
      var output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);

      // Выполняем инференс
      _interpreter.run(input, output);

      // Логируем результаты
      print("Результаты классификации:");
      for (int i = 0; i < output[0].length; i++) {
        print("${_labels[i]}: ${output[0][i].toStringAsFixed(4)}");
      }

      // Ищем индекс с наибольшим значением
      final index = _argMax(output[0]);
      final confidence = output[0][index];

      print("Наивысшая уверенность: ${_labels[index]} (${confidence.toStringAsFixed(2)})");

      if (confidence > 0.5) {
        return _labels[index];
      } else {
        print("Уверенность слишком низкая, жест не распознан");
      }
    } catch (e, stackTrace) {
      print("Ошибка инференса: $e");
      print("Стек вызовов: $stackTrace");
    } finally {
      _isDetecting = false;
    }

    return null;
  }

  Future<List<List<List<double>>>> _preprocessCameraImage(CameraImage image) async {
    try {
      // Преобразуем в RGB image
      final imgImage = _convertYUV420ToImage(image);

      // Сохраняем для отладки
      await _saveDebugImage(imgImage, 'original.png');

      // Защита от пустого изображения
      if (imgImage.width == 0 || imgImage.height == 0) {
        print("Ошибка: невозможно преобразовать изображение");
        return [];
      }

      // Изменим размер до 224x224, если модель требует
      final resized = img.copyResize(imgImage, width: 224, height: 224);
      await _saveDebugImage(resized, 'resized.png');

      // Нормализуем и преобразуем в тензор
      List<List<List<double>>> input = List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              pixel.r / 255.0,
              pixel.g / 255.0,
              pixel.b / 255.0,
            ];
          },
        ),
      );

      return input;
    } catch (e) {
      print("Ошибка при предобработке изображения: $e");
      return [];
    }
  }

  Future<void> _saveDebugImage(img.Image image, String filename) async {
    try {
      final directory = Directory.systemTemp;
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(img.encodePng(image));
      print("Отладочное изображение сохранено: ${file.path}");
    } catch (e) {
      print("Не удалось сохранить отладочное изображение: $e");
    }
  }

  img.Image _convertYUV420ToImage(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;

      final y = image.planes[0].bytes;
      final u = image.planes[1].bytes;
      final v = image.planes[2].bytes;

      final uvRowStride = image.planes[1].bytesPerRow;
      final uvPixelStride = image.planes[1].bytesPerPixel!;

      final img.Image imgImage = img.Image(width: width, height: height);

      for (int h = 0; h < height; h++) {
        for (int w = 0; w < width; w++) {
          final int uvIndex = uvPixelStride * (w ~/ 2) + uvRowStride * (h ~/ 2);
          final yp = y[h * width + w];
          final up = u[uvIndex];
          final vp = v[uvIndex];

          final r = (yp + (1.370705 * (vp - 128))).clamp(0, 255).toInt();
          final g = (yp - (0.337633 * (up - 128)) - (0.698001 * (vp - 128))).clamp(0, 255).toInt();
          final b = (yp + (1.732446 * (up - 128))).clamp(0, 255).toInt();

          imgImage.setPixelRgb(w, h, r, g, b);
        }
      }

      return imgImage;
    } catch (e) {
      print("Ошибка конвертации YUV420: $e");
      return img.Image(width: 1, height: 1); // Возвращаем пустое изображение
    }
  }

  int _argMax(List<double> list) {
    double max = list[0];
    int index = 0;
    for (int i = 1; i < list.length; i++) {
      if (list[i] > max) {
        max = list[i];
        index = i;
      }
    }
    return index;
  }
}