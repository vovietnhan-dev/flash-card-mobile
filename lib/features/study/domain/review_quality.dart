/// Review quality ratings for spaced repetition
/// Based on SM-2 algorithm
enum ReviewQuality {
  /// 0 - Complete blackout (forgot completely)
  completeBlackout,

  /// 1 - Incorrect, but remembered upon seeing answer
  incorrect,

  /// 2 - Incorrect, but seemed easy upon seeing answer
  incorrectEasy,

  /// 3 - Correct, but difficult to recall
  correctDifficult,

  /// 4 - Correct, with some hesitation
  correctHesitation,

  /// 5 - Perfect response
  perfect;

  String get label {
    switch (this) {
      case ReviewQuality.completeBlackout:
        return 'Quên hoàn toàn';
      case ReviewQuality.incorrect:
        return 'Sai';
      case ReviewQuality.incorrectEasy:
        return 'Sai nhưng dễ';
      case ReviewQuality.correctDifficult:
        return 'Đúng nhưng khó';
      case ReviewQuality.correctHesitation:
        return 'Đúng với chút do dự';
      case ReviewQuality.perfect:
        return 'Hoàn hảo';
    }
  }

  String get description {
    switch (this) {
      case ReviewQuality.completeBlackout:
        return 'Không nhớ gì cả';
      case ReviewQuality.incorrect:
        return 'Nhớ lại khi xem đáp án';
      case ReviewQuality.incorrectEasy:
        return 'Dễ khi xem đáp án';
      case ReviewQuality.correctDifficult:
        return 'Nhớ nhưng mất nhiều thời gian';
      case ReviewQuality.correctHesitation:
        return 'Nhớ với chút do dự';
      case ReviewQuality.perfect:
        return 'Nhớ ngay lập tức';
    }
  }
}
