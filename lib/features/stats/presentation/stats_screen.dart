import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../domain/statistics_models.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overallStatsAsync = ref.watch(overallStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê học tập')),
      body: overallStatsAsync.when(
        data: (stats) => _buildStatsContent(context, stats),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Lỗi: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(overallStatsProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, OverallStats stats) {
    final progress = stats.progress;
    final last7Days = stats.last30Days.take(7).toList().reversed.toList();

    // Calculate percentages for pie chart
    final totalCards = progress.totalCardsCreated > 0
        ? progress.totalCardsCreated
        : 1;
    final masteredPercent = (progress.totalCardsMastered / totalCards * 100)
        .round();
    final studiedPercent =
        ((progress.totalCardsStudied - progress.totalCardsMastered) /
                totalCards *
                100)
            .round();
    final unstudiedPercent = 100 - masteredPercent - studiedPercent;

    return RefreshIndicator(
      onRefresh: () async {
        // Trigger refresh
        return;
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overview Stats
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng quan',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      context,
                      'Tổng thẻ',
                      '${progress.totalCardsCreated}',
                      Icons.style,
                      AppColors.primary,
                    ),
                    _buildStatColumn(
                      context,
                      'Đã học',
                      '${progress.totalCardsStudied}',
                      Icons.check_circle,
                      AppColors.success,
                    ),
                    _buildStatColumn(
                      context,
                      'Streak',
                      '${progress.currentStreak} ngày',
                      Icons.local_fire_department,
                      AppColors.streak,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Today's Progress Card
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiến độ hôm nay',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: stats.todayCardsStudied >= stats.todayGoal
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${stats.todayCardsStudied}/${stats.todayGoal} thẻ',
                        style: TextStyle(
                          color: stats.todayCardsStudied >= stats.todayGoal
                              ? AppColors.success
                              : AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: stats.todayGoal > 0
                      ? (stats.todayCardsStudied / stats.todayGoal).clamp(
                          0.0,
                          1.0,
                        )
                      : 0.0,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    stats.todayCardsStudied >= stats.todayGoal
                        ? AppColors.success
                        : AppColors.primary,
                  ),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  stats.cardsDueToday > 0
                      ? 'Còn ${stats.cardsDueToday} thẻ cần ôn'
                      : 'Đã hoàn thành hôm nay! 🎉',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Weekly Chart
          if (last7Days.isNotEmpty)
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoạt động 7 ngày',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxY(last7Days),
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${rod.toY.round()} thẻ',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= last7Days.length)
                                  return const Text('');
                                final date = last7Days[value.toInt()].date;
                                final dayNames = [
                                  'CN',
                                  'T2',
                                  'T3',
                                  'T4',
                                  'T5',
                                  'T6',
                                  'T7',
                                ];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    dayNames[date.weekday % 7],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  '${value.toInt()}',
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: AppColors.divider,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(
                          last7Days.length,
                          (index) => _buildBarGroup(
                            index,
                            last7Days[index].cardsStudied.toDouble(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Progress Chart
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tiến độ học tập',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 60,
                      sections: [
                        if (masteredPercent > 0)
                          PieChartSectionData(
                            value: masteredPercent.toDouble(),
                            title: '$masteredPercent%',
                            color: AppColors.success,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        if (studiedPercent > 0)
                          PieChartSectionData(
                            value: studiedPercent.toDouble(),
                            title: '$studiedPercent%',
                            color: AppColors.warning,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        if (unstudiedPercent > 0)
                          PieChartSectionData(
                            value: unstudiedPercent.toDouble(),
                            title: '$unstudiedPercent%',
                            color: AppColors.error,
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildLegend(
                  progress.totalCardsMastered,
                  progress.totalCardsStudied,
                  progress.totalCardsCreated,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Study Time
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thời gian học',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTimeRow(
                  'Hôm nay',
                  last7Days.isNotEmpty
                      ? _formatDuration(last7Days.last.totalStudyTime)
                      : '0 phút',
                  AppColors.primary,
                ),
                const SizedBox(height: 12),
                _buildTimeRow(
                  'Tuần này',
                  _formatDuration(_calculateWeeklyTime(last7Days)),
                  AppColors.secondary,
                ),
                const SizedBox(height: 12),
                _buildTimeRow(
                  'Tổng cộng',
                  _formatDuration(progress.totalStudyTime),
                  AppColors.info,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Best Streak
          CustomCard(
            color: AppColors.streak.withOpacity(0.1),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.streak.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    size: 40,
                    color: AppColors.streak,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Streak tốt nhất',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${progress.longestStreak} ngày',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.streak,
                        ),
                      ),
                      Text(
                        progress.currentStreak >= progress.longestStreak
                            ? 'Kỷ lục mới! 🔥'
                            : 'Tiếp tục phấn đấu! �',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _getMaxY(List<DailyStats> stats) {
    if (stats.isEmpty) return 30;
    final max = stats
        .map((s) => s.cardsStudied)
        .reduce((a, b) => a > b ? a : b);
    return (max + 5).toDouble();
  }

  Duration _calculateWeeklyTime(List<DailyStats> last7Days) {
    return last7Days.fold(
      Duration.zero,
      (sum, day) => sum + day.totalStudyTime,
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '$hours giờ ${minutes > 0 ? "$minutes phút" : ""}';
    } else if (minutes > 0) {
      return '$minutes phút';
    } else {
      return '0 phút';
    }
  }

  Widget _buildStatColumn(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildLegend(int mastered, int studied, int total) {
    final unstudied = total - studied;
    final learning = studied - mastered;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('Đã thuộc ($mastered)', AppColors.success),
        _buildLegendItem('Đang học ($learning)', AppColors.warning),
        _buildLegendItem('Chưa học ($unstudied)', AppColors.error),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTimeRow(String label, String time, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
