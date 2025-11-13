import 'package:flutter/material.dart';

class Deck {
  final int id;
  final String userId;
  final String name;
  final String? description;
  final int totalCards;
  final int masteredCards;
  final int reviewedCards;
  final String? colorHex;
  final String? iconName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPublic;

  Deck({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.totalCards = 0,
    this.masteredCards = 0,
    this.reviewedCards = 0,
    this.colorHex,
    this.iconName,
    required this.createdAt,
    this.updatedAt,
    this.isPublic = false,
  });

  // Helper getters for UI
  Color get color {
    if (colorHex == null || colorHex!.isEmpty) {
      return Colors.blue;
    }
    final hex = colorHex!.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  IconData get icon => _getIconFromName(iconName ?? 'book');

  factory Deck.fromJson(Map<String, dynamic> json) {
    // Fallback: if reviewedCards not provided, use masteredCards or 0
    final reviewedCards =
        json['reviewedCards'] as int? ?? json['masteredCards'] as int? ?? 0;

    return Deck(
      id: json['id'] as int,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      totalCards: json['totalCards'] as int? ?? 0,
      masteredCards: json['masteredCards'] as int? ?? 0,
      reviewedCards: reviewedCards,
      colorHex: json['color'] as String?,
      iconName: json['icon'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isPublic: json['isPublic'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'color': colorHex,
      'icon': iconName,
      'isPublic': isPublic,
    };
  }

  Deck copyWith({
    int? id,
    String? userId,
    String? name,
    String? description,
    int? totalCards,
    int? masteredCards,
    int? reviewedCards,
    String? colorHex,
    String? iconName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
  }) {
    return Deck(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      totalCards: totalCards ?? this.totalCards,
      masteredCards: masteredCards ?? this.masteredCards,
      reviewedCards: reviewedCards ?? this.reviewedCards,
      colorHex: colorHex ?? this.colorHex,
      iconName: iconName ?? this.iconName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  static IconData _getIconFromName(String name) {
    switch (name.toLowerCase()) {
      case 'language':
        return Icons.language;
      case 'school':
        return Icons.school;
      case 'translate':
        return Icons.translate;
      case 'history_edu':
        return Icons.history_edu;
      case 'book':
        return Icons.book;
      case 'science':
        return Icons.science;
      default:
        return Icons.collections_bookmark;
    }
  }
}
