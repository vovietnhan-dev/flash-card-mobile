class UserProgress {
  final int totalCardsCreated;
  final int totalCardsMastered;
  final int totalCardsStudied;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastStudyDate;
  final Duration totalStudyTime;
  final int totalStudySessions;
  final int level;
  final int experiencePoints;
  final int masteryPercentage;

  UserProgress({
    this.totalCardsCreated = 0,
    this.totalCardsMastered = 0,
    this.totalCardsStudied = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStudyDate,
    this.totalStudyTime = Duration.zero,
    this.totalStudySessions = 0,
    this.level = 1,
    this.experiencePoints = 0,
    this.masteryPercentage = 0,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      totalCardsCreated: json['totalCardsCreated'] as int? ?? 0,
      totalCardsMastered: json['totalCardsMastered'] as int? ?? 0,
      totalCardsStudied: json['totalCardsStudied'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastStudyDate: json['lastStudyDate'] != null ? DateTime.parse(json['lastStudyDate'] as String) : null,
      totalStudyTime: _parseDuration(json['totalStudyTime'] as String? ?? '00:00:00'),
      totalStudySessions: json['totalStudySessions'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      experiencePoints: json['experiencePoints'] as int? ?? 0,
      masteryPercentage: json['masteryPercentage'] as int? ?? 0,
    );
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
}

class DailyStats {
  final DateTime date;
  final int cardsStudied;
  final int newCardsLearned;
  final int cardsReviewed;
  final int correctAnswers;
  final int incorrectAnswers;
  final Duration totalStudyTime;
  final int studySessionsCount;
  final double accuracyRate;

  DailyStats({
    required this.date,
    this.cardsStudied = 0,
    this.newCardsLearned = 0,
    this.cardsReviewed = 0,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
    this.totalStudyTime = Duration.zero,
    this.studySessionsCount = 0,
    this.accuracyRate = 0.0,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date'] as String),
      cardsStudied: json['cardsStudied'] as int? ?? 0,
      newCardsLearned: json['newCardsLearned'] as int? ?? 0,
      cardsReviewed: json['cardsReviewed'] as int? ?? 0,
      correctAnswers: json['correctAnswers'] as int? ?? 0,
      incorrectAnswers: json['incorrectAnswers'] as int? ?? 0,
      totalStudyTime: _parseDuration(json['totalStudyTime'] as String? ?? '00:00:00'),
      studySessionsCount: json['studySessionsCount'] as int? ?? 0,
      accuracyRate: (json['accuracyRate'] as num?)?.toDouble() ?? 0.0,
    );
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
}

class UserSettings {
  final int dailyGoal;
  final int newCardsPerDay;
  final bool enableNotifications;
  final bool enableSound;
  final bool autoPlayAudio;
  final bool showHints;
  final String language;
  final String theme;
  final String spacedRepetitionPreset;

  UserSettings({
    this.dailyGoal = 20,
    this.newCardsPerDay = 10,
    this.enableNotifications = true,
    this.enableSound = true,
    this.autoPlayAudio = false,
    this.showHints = true,
    this.language = 'vi',
    this.theme = 'light',
    this.spacedRepetitionPreset = 'normal',
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      dailyGoal: json['dailyGoal'] as int? ?? 20,
      newCardsPerDay: json['newCardsPerDay'] as int? ?? 10,
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      enableSound: json['enableSound'] as bool? ?? true,
      autoPlayAudio: json['autoPlayAudio'] as bool? ?? false,
      showHints: json['showHints'] as bool? ?? true,
      language: json['language'] as String? ?? 'vi',
      theme: json['theme'] as String? ?? 'light',
      spacedRepetitionPreset: json['spacedRepetitionPreset'] as String? ?? 'normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyGoal': dailyGoal,
      'newCardsPerDay': newCardsPerDay,
      'enableNotifications': enableNotifications,
      'enableSound': enableSound,
      'autoPlayAudio': autoPlayAudio,
      'showHints': showHints,
      'language': language,
      'theme': theme,
      'spacedRepetitionPreset': spacedRepetitionPreset,
    };
  }
}

class OverallStats {
  final UserProgress progress;
  final List<DailyStats> last30Days;
  final int todayCardsStudied;
  final int todayGoal;
  final int cardsDueToday;

  OverallStats({
    required this.progress,
    this.last30Days = const [],
    this.todayCardsStudied = 0,
    this.todayGoal = 20,
    this.cardsDueToday = 0,
  });

  factory OverallStats.fromJson(Map<String, dynamic> json) {
    return OverallStats(
      progress: UserProgress.fromJson(json['progress'] as Map<String, dynamic>),
      last30Days:
          (json['last30Days'] as List<dynamic>?)?.map((e) => DailyStats.fromJson(e as Map<String, dynamic>)).toList() ??
          [],
      todayCardsStudied: json['todayCardsStudied'] as int? ?? 0,
      todayGoal: json['todayGoal'] as int? ?? 20,
      cardsDueToday: json['cardsDueToday'] as int? ?? 0,
    );
  }
}
