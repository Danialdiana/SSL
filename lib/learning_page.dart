import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'words_by_letter_page.dart';
import 'colors.dart';

class LearningPage extends StatefulWidget {
  const LearningPage({super.key});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  final List<String> _kazakhAlphabet = [
    'А', 'Ә', 'Б', 'В', 'Г', 'Ғ', 'Д', 'Е', 'Ё', 'Ж', 'З',
    'И', 'Й', 'К', 'Қ', 'Л', 'М', 'Н', 'Ң', 'О', 'Ө', 'П',
    'Р', 'С', 'Т', 'У', 'Ұ', 'Ү', 'Ф', 'Х', 'Һ', 'Ц', 'Ч',
    'Ш', 'Щ', 'Ъ', 'Ы', 'І', 'Ь', 'Э', 'Ю', 'Я'
  ];

  String _searchQuery = '';

  List<String> get _filteredAlphabet {
    if (_searchQuery.isEmpty) return _kazakhAlphabet;
    return _kazakhAlphabet
        .where((letter) => letter.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  final List<Color?> _cardColors = [
    Colors.red[100],
    Colors.yellow[100],
    Colors.lightBlue[100],
    Colors.purple[100],
    Colors.green[100],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.homePageBackground,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchField(),
          Expanded(child: _buildLetterGrid()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1565C0), AppColor.gradientSecond],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.only(top: 30, left: 20),
      alignment: Alignment.centerLeft,
      child: Text(
        tr('dictionary'),
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        decoration: InputDecoration(
          hintText: tr('search_letter'),
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildLetterGrid() {
  return GridView.builder(
    padding: const EdgeInsets.all(12),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 3 / 3.2, // Увеличили высоту карточки
    ),
    itemCount: _filteredAlphabet.length,
    itemBuilder: (context, index) {
      final letter = _filteredAlphabet[index];
      final color = _cardColors[index % _cardColors.length]!;
      return _buildLetterCard(letter, color);
    },
  );
}

Widget _buildLetterCard(String letter, Color color) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WordsByLetterPage(letter: letter),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Фото в круглой рамке с белой обводкой
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/alphabet/$letter.png',
                fit: BoxFit.cover,
                width: 80,
                height: 80,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Кнопка "Изучить" — без скруглений, с серым бордером
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black54,
                side: const BorderSide(color: Colors.grey),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // Без скруглений
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WordsByLetterPage(letter: letter),
                  ),
                );
              },
              child:Text(
                tr('learn'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}



}
