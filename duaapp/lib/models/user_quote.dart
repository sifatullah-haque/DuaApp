import 'package:appwrite/models.dart';

class UserQuote {
  final String id;
  final String bengaliText;
  final String? arabicText;
  final String? englishText;
  final String reference;
  final DateTime createdAt;
  final List<String> moodIds;

  UserQuote({
    required this.id,
    required this.bengaliText,
    this.arabicText,
    this.englishText,
    required this.reference,
    required this.createdAt,
    required this.moodIds,
  });

  factory UserQuote.fromMap(dynamic data) {
    return UserQuote(
      id: data.$id,
      bengaliText: data.data['bengaliText'] ?? '',
      arabicText: data.data['arabicText'],
      englishText: data.data['englishText'],
      reference: data.data['reference'] ?? '',
      createdAt: DateTime.parse(data.$createdAt),
      moodIds: data.data['moodIds'] != null
          ? List<String>.from(data.data['moodIds'])
          : [],
    );
  }

  factory UserQuote.fromDocument(Document document) {
    return UserQuote(
      id: document.$id,
      bengaliText: document.data['bengaliText'] ?? '',
      arabicText: document.data['arabicText'],
      englishText: document.data['englishText'],
      reference: document.data['reference'] ?? '',
      createdAt: DateTime.parse(document.$createdAt),
      moodIds: document.data['moodIds'] != null
          ? List<String>.from(document.data['moodIds'])
          : [],
    );
  }
}
