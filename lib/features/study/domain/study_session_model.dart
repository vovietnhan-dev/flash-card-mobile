class StudySession {
  final int id;
  final DateTime startTime;
  final DateTime? endTime;
  final int totalCardsStudied;
  final int correctAnswers;
  final int incorrectAnswers;
  final Duration? totalDuration;
  final double accuracyRate;
  final int? deckId;

  StudySession({
    required this.id,
    required this.startTime,
    this.endTime,
    this.totalCardsStudied = 0,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
    this.totalDuration,
    this.accuracyRate = 0.0,
    this.deckId,
  });

  bool get isActive => endTime == null;

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      totalCardsStudied: json['totalCardsStudied'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      incorrectAnswers: json['incorrectAnswers'] as int? ?? 0,
      totalDuration: json['totalDuration'] != null
          ? _parseDuration(json['totalDuration'] as String)
          : null,
      accuracyRate: (json['accuracyRate'] as num?)?.toDouble() ?? 0.0,
      deckId: json['deckId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'totalCardsStudied': totalCardsStudied,
      'correctAnswers': correctAnswers,
      'incorrectAnswers': incorrectAnswers,
      'totalDuration': totalDuration?.toString(),
      'accuracyRate': accuracyRate,
      'deckId': deckId,
    };
  }

  static Duration _parseDuration(String duration) {
    final parts = duration.split(':');
    if (parts.length < 3) return Duration.zero;

    return Duration(
      hours: int.parse(parts[0]),
      minutes: int.parse(parts[1]),
      seconds: int.parse(parts[2].split('.')[0]),
    );
  }

  StudySession copyWith({
    int? id,
    DateTime? startTime,
    DateTime? endTime,
    int? totalCardsStudied,
    int? correctAnswers,
    int? incorrectAnswers,
    Duration? totalDuration,
    double? accuracyRate,
    int? deckId,
  }) {
    return StudySession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalCardsStudied: totalCardsStudied ?? this.totalCardsStudied,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
      totalDuration: totalDuration ?? this.totalDuration,
      accuracyRate: accuracyRate ?? this.accuracyRate,
      deckId: deckId ?? this.deckId,
    );
  }
}
