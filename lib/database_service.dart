//database_servise.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<List<Map<String, String>>> fetchWordsByLetter(String letter) async {
  try {
    final snapshot = await _db.collection('urls')
        .doc(letter) 
        .collection(letter) 
        .get();

    return snapshot.docs.map((doc) {
      return {
        'word': doc['word'] as String,  
        'url': doc['url'] as String,    
      };
    }).toList();
  } catch (e) {
    throw Exception('Ошибка при загрузке данных: $e');
  }
}

}


