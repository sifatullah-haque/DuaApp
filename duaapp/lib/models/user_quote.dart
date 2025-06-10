import 'package:appwrite/models.dart';

class UserQuote {
  final String id;
  final String bengaliText;
  final String? arabicText;
  final String? englishText;
  final String reference;
  final List<String> moodIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final String? userEmail;

  UserQuote({
    required this.id,
    required this.bengaliText,
    this.arabicText,
    this.englishText,
    required this.reference,
    required this.moodIds,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'pending',
    this.userEmail,
  });

  factory UserQuote.fromMap(Map<String, dynamic> map) {
    return UserQuote(
      id: map['\$id'] as String,
      bengaliText: map['bengaliText'] as String,
      arabicText: map['arabicText'] as String?,
      englishText: map['englishText'] as String?,
      reference: map['reference'] as String,
      moodIds: List<String>.from(map['moodIds'] ?? []),
      createdAt: DateTime.parse(map['\$createdAt'] as String),
      updatedAt: DateTime.parse(map['\$updatedAt'] as String),
      status: map['status'] as String? ?? 'pending',
      userEmail: map['userEmail'] as String?,
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
      updatedAt: DateTime.parse(document.$updatedAt),
      moodIds: document.data['moodIds'] != null
          ? List<String>.from(document.data['moodIds'])
          : [],
      status: document.data['status'] ?? 'pending',
      userEmail: document.data['userEmail'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bengaliText': bengaliText,
      'arabicText': arabicText,
      'englishText': englishText,
      'reference': reference,
      'moodIds': moodIds,
      'status': status,
      'userEmail': userEmail,
    };
  }
}
