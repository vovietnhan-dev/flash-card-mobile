class Flashcard {
  final int id;
  final int deckId;
  final String front;
  final String back;
  final String? hint;
  final String? imageUrl;
  final String? audioUrl;
  final int order;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Spaced Repetition fields
  final int interval;
  final int repetitions;
  final double easeFactor;
  final DateTime? nextReviewDate;
  final DateTime? lastReviewedAt;
  final bool isMastered;

  Flashcard({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.hint,
    this.imageUrl,
    this.audioUrl,
    this.order = 0,
    required this.createdAt,
    this.updatedAt,
    this.interval = 0,
    this.repetitions = 0,
    this.easeFactor = 2.5,
    this.nextReviewDate,
    this.lastReviewedAt,
    this.isMastered = false,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'] as int,
      deckId: json['deckId'] as int,
      front: json['front'] as String,
      back: json['back'] as String,
      hint: json['hint'] as String?,
      imageUrl: json['imageUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      order: json['order'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      interval: json['interval'] as int? ?? 0,
      repetitions: json['repetitions'] as int? ?? 0,
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      nextReviewDate: json['nextReviewDate'] != null
          ? DateTime.parse(json['nextReviewDate'] as String)
          : null,
      lastReviewedAt: json['lastReviewedAt'] != null
          ? DateTime.parse(json['lastReviewedAt'] as String)
          : null,
      isMastered: json['isMastered'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deckId': deckId,
      'front': front,
      'back': back,
      'hint': hint,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
    };
  }

  Flashcard copyWith({
    int? id,
    int? deckId,
    String? front,
    String? back,
    String? hint,
    String? imageUrl,
    String? audioUrl,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? interval,
    int? repetitions,
    double? easeFactor,
    DateTime? nextReviewDate,
    DateTime? lastReviewedAt,
    bool? isMastered,
  }) {
    return Flashcard(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      hint: hint ?? this.hint,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      easeFactor: easeFactor ?? this.easeFactor,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      isMastered: isMastered ?? this.isMastered,
    );
  }
}
