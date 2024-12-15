import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String date;
  final String description;
  final String imageUrl;
  final String author;

  Event({
    required this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.imageUrl,
    required this.author,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);
    Map data = doc.data() as Map;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      date: data['date'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      author: data['author'] ?? '',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'date': date,
      'description': description,
      'imageUrl': imageUrl,
      'author': author,
    };
  }
}