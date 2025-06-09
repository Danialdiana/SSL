//words_by_letter_page.dart
import 'package:flutter/material.dart';
import 'video_page.dart';
import 'database_service.dart'; 
import 'package:easy_localization/easy_localization.dart';

class WordsByLetterPage extends StatefulWidget {
  final String letter;

  const WordsByLetterPage({required this.letter});

  @override
  _WordsByLetterPageState createState() => _WordsByLetterPageState();
}

class _WordsByLetterPageState extends State<WordsByLetterPage> {
  late Future<List<Map<String, String>>> _wordsFuture;

  @override
  void initState() {
    super.initState();
    _wordsFuture = _fetchWords(widget.letter);
  }

  Future<List<Map<String, String>>> _fetchWords(String letter) async {
    return DatabaseService.fetchWordsByLetter(letter); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6C63FF),
        title: Text(
          '${tr('words_with_letter')} ${widget.letter}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _wordsFuture,
        builder: (context, snapshot) {
          // Ожидание загрузки данных
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Ошибка при загрузке данных
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          // Если нет данных или список пуст
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет слов для этой буквы.'));
          }

          final words = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: words.length,
            itemBuilder: (context, index) {
              final word = words[index];

              return GestureDetector(
                onTap: () {
                  final videoUrl = word['url']!;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPage(videoUrl: videoUrl),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    title: Text(
                      word['word']!,  // Получаем слово из базы данных
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.play_circle_fill,
                      color: Color(0xFF6C63FF),
                      size: 28,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
