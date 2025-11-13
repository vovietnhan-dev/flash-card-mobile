import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../data/flashcard_repository.dart';
import '../domain/flashcard_model.dart';

class FlashcardSearchScreen extends ConsumerStatefulWidget {
  final int deckId;
  final String deckName;

  const FlashcardSearchScreen({super.key, required this.deckId, required this.deckName});

  @override
  ConsumerState<FlashcardSearchScreen> createState() => _FlashcardSearchScreenState();
}

class _FlashcardSearchScreenState extends ConsumerState<FlashcardSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  FlashcardStatus _selectedStatus = FlashcardStatus.all;

  SearchFlashcardsResponse? _searchResult;
  bool _isLoading = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    // Tự động search khi vào màn hình (hiển thị tất cả)
    _performSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final repository = ref.read(flashcardRepositoryProvider);
      final result = await repository.searchFlashcards(
        SearchFlashcardsRequest(
          searchTerm: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
          deckId: widget.deckId,
          status: _selectedStatus,
        ),
      );

      setState(() {
        _searchResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Lỗi tìm kiếm: ${e.toString()}'), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tìm kiếm - ${widget.deckName}'), backgroundColor: AppColors.primary),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          _buildStatsSummary(),
          Expanded(child: _buildSearchResults()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm theo mặt trước hoặc sau...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        onChanged: (value) {
          // Debounce search
          Future.delayed(const Duration(milliseconds: 500), () {
            if (_searchController.text == value) {
              _performSearch();
            }
          });
        },
        onSubmitted: (value) => _performSearch(),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Tất cả', FlashcardStatus.all, _searchResult?.totalCount ?? 0, Colors.blue),
            const SizedBox(width: 8),
            _buildFilterChip('Chưa học', FlashcardStatus.unstudied, _searchResult?.unstudiedCount ?? 0, Colors.grey),
            const SizedBox(width: 8),
            _buildFilterChip('Đang học', FlashcardStatus.studying, _searchResult?.studyingCount ?? 0, Colors.orange),
            const SizedBox(width: 8),
            _buildFilterChip(
              'Đã thuộc',
              FlashcardStatus.mastered,
              _searchResult?.masteredCount ?? 0,
              AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, FlashcardStatus status, int count, Color color) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedStatus = status);
        _performSearch();
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildStatsSummary() {
    if (_searchResult == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            'Tìm thấy ${_searchResult!.flashcards.length} thẻ',
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text('Nhập từ khóa để tìm kiếm', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    if (_searchResult == null || _searchResult!.flashcards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty ? 'Không có thẻ nào' : 'Không tìm thấy kết quả',
              style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty ? 'Thêm thẻ mới để bắt đầu học' : 'Thử từ khóa khác hoặc thay đổi bộ lọc',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResult!.flashcards.length,
      itemBuilder: (context, index) {
        final card = _searchResult!.flashcards[index];
        return _buildFlashcardItem(card);
      },
    );
  }

  Widget _buildFlashcardItem(Flashcard card) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Show detail dialog
          _showFlashcardDetail(card);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status badge
              Row(
                children: [
                  _buildStatusBadge(card),
                  const Spacer(),
                  if (card.hint != null && card.hint!.isNotEmpty)
                    const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                ],
              ),
              const SizedBox(height: 12),
              // Front
              Text(
                card.front,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              // Back
              Text(card.back, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
              // Stats
              if (card.lastReviewedAt != null) ...[const SizedBox(height: 12), _buildCardStats(card)],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Flashcard card) {
    String label;
    Color color;
    IconData icon;

    if (card.isMastered) {
      label = 'Đã thuộc';
      color = AppColors.success;
      icon = Icons.check_circle;
    } else if (card.lastReviewedAt != null) {
      label = 'Đang học';
      color = Colors.orange;
      icon = Icons.schedule;
    } else {
      label = 'Chưa học';
      color = Colors.grey;
      icon = Icons.fiber_new;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCardStats(Flashcard card) {
    return Row(
      children: [
        Icon(Icons.repeat, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text('${card.repetitions} lần', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(width: 16),
        Icon(Icons.timelapse, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text('${card.interval} ngày', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  void _showFlashcardDetail(Flashcard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết thẻ'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusBadge(card),
              const SizedBox(height: 16),
              const Text('Mặt trước:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(card.front),
              const SizedBox(height: 16),
              const Text('Mặt sau:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(card.back),
              if (card.hint != null && card.hint!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.lightbulb, size: 16, color: Colors.amber),
                    SizedBox(width: 4),
                    Text('Gợi ý:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(card.hint!),
              ],
              if (card.lastReviewedAt != null) ...[const Divider(height: 32), _buildDetailStats(card)],
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))],
      ),
    );
  }

  Widget _buildDetailStats(Flashcard card) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Thống kê:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildStatRow('Số lần ôn', '${card.repetitions}'),
        _buildStatRow('Khoảng cách', '${card.interval} ngày'),
        _buildStatRow('Độ dễ', card.easeFactor.toStringAsFixed(2)),
        if (card.nextReviewDate != null) _buildStatRow('Ôn lại vào', _formatDate(card.nextReviewDate!)),
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.inDays == 0) return 'Hôm nay';
    if (diff.inDays == 1) return 'Ngày mai';
    if (diff.inDays == -1) return 'Hôm qua';
    if (diff.inDays < 0) return '${-diff.inDays} ngày trước';
    return '${diff.inDays} ngày nữa';
  }
}
