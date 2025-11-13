import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../../stats/domain/statistics_models.dart';
import '../domain/deck_model.dart';
import '../domain/deck_sort_type.dart';
import 'widgets/add_deck_dialog.dart';
import 'widgets/sort_decks_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // State: Kiểu sắp xếp
  DeckSortType _currentSort = DeckSortType.newestFirst;

  // Sắp xếp danh sách bộ thẻ
  List<Deck> _sortDecks(List<Deck> decks) {
    final sortedDecks = List<Deck>.from(decks);

    switch (_currentSort) {
      case DeckSortType.nameAsc:
        sortedDecks.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case DeckSortType.nameDesc:
        sortedDecks.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case DeckSortType.newestFirst:
        sortedDecks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case DeckSortType.oldestFirst:
        sortedDecks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case DeckSortType.mostCards:
        sortedDecks.sort((a, b) => b.totalCards.compareTo(a.totalCards));
        break;
      case DeckSortType.leastCards:
        sortedDecks.sort((a, b) => a.totalCards.compareTo(b.totalCards));
        break;
      case DeckSortType.mostLearned:
        sortedDecks.sort((a, b) => b.masteredCards.compareTo(a.masteredCards));
        break;
      case DeckSortType.leastLearned:
        sortedDecks.sort((a, b) => a.masteredCards.compareTo(b.masteredCards));
        break;
    }

    return sortedDecks;
  }

  // Thay đổi kiểu sắp xếp
  void _changeSortType(DeckSortType newSort) {
    setState(() {
      _currentSort = newSort;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📊 Sắp xếp theo: ${newSort.label}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Thêm bộ thẻ mới
  Future<void> _addDeck(String name, Color color, IconData icon) async {
    try {
      final colorHex = '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
      final iconName = _getIconName(icon);

      final deckRepo = ref.read(deckRepositoryProvider);
      await deckRepo.createDeck(name: name, description: null, color: colorHex, icon: iconName, isPublic: false);

      // Refresh danh sách decks
      ref.invalidate(decksProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã tạo bộ thẻ "$name"'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Helper method to convert IconData to icon name string
  String _getIconName(IconData icon) {
    if (icon == Icons.language) return 'language';
    if (icon == Icons.school) return 'school';
    if (icon == Icons.translate) return 'translate';
    if (icon == Icons.history_edu) return 'history_edu';
    if (icon == Icons.science) return 'science';
    return 'book';
  }

  // Xóa bộ thẻ
  Future<void> _deleteDeck(int deckId, String deckName) async {
    try {
      final deckRepo = ref.read(deckRepositoryProvider);
      await deckRepo.deleteDeck(deckId);

      // Refresh danh sách decks
      ref.invalidate(decksProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🗑️ Đã xóa "$deckName"'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi xóa: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final decksAsync = ref.watch(decksProvider);
    final overallStatsAsync = ref.watch(overallStatsProvider);

    return decksAsync.when(
      data: (decks) => overallStatsAsync.when(
        data: (stats) => _buildHomeContent(context, decks, stats),
        loading: () => _buildHomeContent(context, decks, null),
        error: (error, stack) {
          // Log error but still show content with decks
          debugPrint('⚠️ OverallStats Error: $error');
          return _buildHomeContent(context, decks, null);
        },
      ),
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Bộ Thẻ Của Tôi')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) {
        // Log error for debugging
        debugPrint('❌ Decks Error: $error');
        debugPrint('Stack: $stack');

        return Scaffold(
          appBar: AppBar(title: const Text('Bộ Thẻ Của Tôi')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                const Text('Không thể tải dữ liệu'),
                const SizedBox(height: 8),
                Text(error.toString(), style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(decksProvider);
                    ref.invalidate(overallStatsProvider);
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeContent(BuildContext context, List<Deck> decks, OverallStats? stats) {
    final sortedDecks = _sortDecks(decks);
    final progress = stats?.progress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bộ Thẻ Của Tôi'),
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart), onPressed: () => context.push('/stats'), tooltip: 'Thống kê'),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: 'Cài đặt',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(decksProvider);
          ref.invalidate(overallStatsProvider);
          await Future.delayed(const Duration(milliseconds: 500));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật')));
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Stats Card
            CustomCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mục tiêu hôm nay',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      TextButton.icon(
                        onPressed: () => _showDailyGoalDialog(context, stats?.todayGoal ?? 20),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Điều chỉnh'),
                        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        context,
                        'Streak',
                        '${progress?.currentStreak ?? 0} ngày',
                        Icons.local_fire_department,
                        AppColors.streak,
                      ),
                      _buildStatItem(
                        context,
                        'Hôm nay',
                        '${stats?.todayCardsStudied ?? 0}/${stats?.todayGoal ?? 20}',
                        Icons.today,
                        AppColors.primary,
                      ),
                      _buildStatItem(
                        context,
                        'Tổng',
                        '${progress?.totalCardsCreated ?? decks.fold<int>(0, (sum, deck) => sum + deck.totalCards)} thẻ',
                        Icons.collections_bookmark,
                        AppColors.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (stats?.todayGoal ?? 0) > 0
                        ? ((stats?.todayCardsStudied ?? 0) / (stats?.todayGoal ?? 1)).clamp(0.0, 1.0)
                        : 0.0,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      (stats?.todayCardsStudied ?? 0) >= (stats?.todayGoal ?? 20)
                          ? AppColors.success
                          : AppColors.primary,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (stats?.todayCardsStudied ?? 0) >= (stats?.todayGoal ?? 20)
                        ? '🎉 Đã hoàn thành mục tiêu hôm nay!'
                        : 'Còn ${(stats?.todayGoal ?? 20) - (stats?.todayCardsStudied ?? 0)} thẻ nữa',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: (stats?.todayCardsStudied ?? 0) >= (stats?.todayGoal ?? 20) ? AppColors.success : null,
                      fontWeight: (stats?.todayCardsStudied ?? 0) >= (stats?.todayGoal ?? 20) ? FontWeight.w600 : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bộ thẻ của bạn (${decks.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => SortDecksDialog(currentSort: _currentSort, onSortSelected: _changeSortType),
                    );
                  },
                  icon: const Icon(Icons.sort, size: 18),
                  label: const Text('Sắp xếp'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Deck List
            if (decks.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Column(
                    children: [
                      Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa có bộ thẻ nào',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text('Nhấn nút + để tạo bộ thẻ đầu tiên', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              )
            else
              ...sortedDecks.map(
                (deck) => Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildDeckCard(context, deck)),
              ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDeckDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Thêm bộ thẻ'),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 28, color: color),
        ),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildDeckCard(BuildContext context, Deck deck) {
    final progress = deck.totalCards > 0 ? deck.reviewedCards / deck.totalCards : 0.0;

    return CustomCard(
      onTap: () => context.push('/deck/${deck.id}?name=${deck.name}'),
      child: Column(
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(color: deck.color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(deck.icon, color: deck.color, size: 30),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${deck.reviewedCards}/${deck.totalCards} đã ôn',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (deck.masteredCards > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${deck.masteredCards} thành thạo',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [Icon(Icons.edit_outlined, size: 20), SizedBox(width: 12), Text('Chỉnh sửa')]),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                        SizedBox(width: 12),
                        Text('Xóa', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteConfirmDialog(context, deck);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(deck.color),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      ),
    );
  }

  void _showAddDeckDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddDeckDialog(onAdd: _addDeck),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, Deck deck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc muốn xóa bộ thẻ "${deck.name}"?\n\nTất cả ${deck.totalCards} thẻ trong bộ này sẽ bị xóa vĩnh viễn.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteDeck(deck.id, deck.name);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showDailyGoalDialog(BuildContext context, int currentGoal) {
    final controller = TextEditingController(text: currentGoal.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mục tiêu hàng ngày'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Đặt số thẻ bạn muốn học mỗi ngày:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Số thẻ mỗi ngày',
                hintText: 'VD: 20',
                suffixText: 'thẻ',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                final goal = int.tryParse(value);
                if (goal != null && goal > 0) {
                  Navigator.pop(context);
                  _updateDailyGoal(goal);
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Gợi ý: 10-30 thẻ/ngày phù hợp với hầu hết người học',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          FilledButton(
            onPressed: () {
              final goal = int.tryParse(controller.text);
              if (goal != null && goal > 0) {
                Navigator.pop(context);
                _updateDailyGoal(goal);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Vui lòng nhập số thẻ hợp lệ (> 0)'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateDailyGoal(int newGoal) async {
    try {
      final statsRepo = ref.read(statisticsRepositoryProvider);
      await statsRepo.updateUserSettings(dailyGoal: newGoal);

      // Refresh stats
      ref.invalidate(overallStatsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã cập nhật mục tiêu: $newGoal thẻ/ngày'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
