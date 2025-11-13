import '../../../core/api/api_client.dart';
import '../domain/statistics_models.dart';

class StatisticsRepository {
  final ApiClient _apiClient;

  StatisticsRepository(this._apiClient);

  /// Lấy tổng quan thống kê
  Future<OverallStats> getOverview() async {
    final response = await _apiClient.get('/Statistics/overview');
    return OverallStats.fromJson(response.data);
  }

  /// Lấy thống kê theo ngày
  Future<List<DailyStats>> getDailyStats({int days = 30}) async {
    final response = await _apiClient.get('/Statistics/daily', queryParameters: {'days': days});
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => DailyStats.fromJson(json)).toList();
  }

  /// Lấy tiến độ người dùng
  Future<UserProgress> getUserProgress() async {
    final response = await _apiClient.get('/Statistics/progress');
    return UserProgress.fromJson(response.data);
  }

  /// Lấy cài đặt người dùng
  Future<UserSettings> getUserSettings() async {
    final response = await _apiClient.get('/Statistics/settings');
    return UserSettings.fromJson(response.data);
  }

  /// Cập nhật cài đặt người dùng
  Future<UserSettings> updateUserSettings({
    int? dailyGoal,
    int? newCardsPerDay,
    bool? enableNotifications,
    bool? enableSound,
    bool? autoPlayAudio,
    bool? showHints,
    String? language,
    String? theme,
    String? spacedRepetitionPreset,
  }) async {
    final data = <String, dynamic>{};
    if (dailyGoal != null) data['dailyGoal'] = dailyGoal;
    if (newCardsPerDay != null) data['newCardsPerDay'] = newCardsPerDay;
    if (enableNotifications != null) data['enableNotifications'] = enableNotifications;
    if (enableSound != null) data['enableSound'] = enableSound;
    if (autoPlayAudio != null) data['autoPlayAudio'] = autoPlayAudio;
    if (showHints != null) data['showHints'] = showHints;
    if (language != null) data['language'] = language;
    if (theme != null) data['theme'] = theme;
    if (spacedRepetitionPreset != null) data['spacedRepetitionPreset'] = spacedRepetitionPreset;

    final response = await _apiClient.put('/Statistics/settings', data: data);
    return UserSettings.fromJson(response.data);
  }
}
