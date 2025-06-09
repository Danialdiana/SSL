//home_page.dart
import 'package:flutter/material.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Главная страница')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/camera'),
              icon: const Icon(Icons.camera_alt, size: 32),
              label: const Text('Доступность (Камера)', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/learning'),
              child: const Text('Обучение / Словари', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
