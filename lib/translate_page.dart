//translate_page.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
class TranslatePage extends StatefulWidget {
  @override
  _TranslatePageState createState() => _TranslatePageState();
}
class _TranslatePageState extends State<TranslatePage> {
  final List<String> _allLetters = [];
  int _currentIndex = -1;
  bool _isPlaying = false;
  String _inputWord = '';

  void _translateWord() {
    setState(() {
      _allLetters.clear();
      _inputWord.runes.forEach((rune) {
        final letter = String.fromCharCode(rune).toUpperCase();
        _allLetters.add(letter);
      });
      _currentIndex = 0;
      _isPlaying = true;
    });
    _showNextLetter();
  }

  void _showNextLetter() {
    Future.delayed(const Duration(seconds: 2), () {
      if (_currentIndex < _allLetters.length - 1) {
        setState(() => _currentIndex++);
        _showNextLetter();
      } else {
        setState(() => _isPlaying = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLetter = (_currentIndex >= 0 && _currentIndex < _allLetters.length)
        ? _allLetters[_currentIndex]
        : null;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 50),
          if (!_isPlaying)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) => _inputWord = value,
                    decoration: InputDecoration(
                      labelText: tr('enter_words'),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _translateWord,
                    child: Text(tr('show_gestures')),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Builder(
                builder: (_) {
                  if (_isPlaying && currentLetter != null) {
                    return Image.asset(
                      'assets/alphabet/$currentLetter.png',
                      height: screenHeight * 0.8,
                      width: screenWidth,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Text(
                        currentLetter,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 120,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  } else {
                    return Image.asset(
                      'assets/default.jpg',
                      height: screenHeight * 0.6,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text(
                        'Нет изображения',
                        style: TextStyle(color: Colors.black, fontSize: 24),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
