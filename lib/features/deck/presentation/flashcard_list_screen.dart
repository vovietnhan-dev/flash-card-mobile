import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../domain/flashcard_model.dart';
import 'flashcard_search_screen.dart';

class FlashcardListScreen extends ConsumerStatefulWidget {
  final int deckId;
  final String deckName;

  const FlashcardListScreen({super.key, required this.deckId, required this.deckName});

  @override
  ConsumerState<FlashcardListScreen> createState() => _FlashcardListScreenState();
}

class _FlashcardListScreenState extends ConsumerState<FlashcardListScreen> {
  // Thêm flashcard mới
  Future<void> _addFlashcard(String front, String back, [String? hint]) async {
    try {
      final flashcardRepo = ref.read(flashcardRepositoryProvider);
      await flashcardRepo.createFlashcard(deckId: widget.deckId, front: front, back: back, hint: hint);

      // Refresh danh sách flashcards
      ref.invalidate(flashcardsProvider(widget.deckId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã thêm thẻ mới'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
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

  // Cập nhật flashcard
  Future<void> _updateFlashcard(Flashcard oldCard, String front, String back, [String? hint]) async {
    try {
      final flashcardRepo = ref.read(flashcardRepositoryProvider);
      await flashcardRepo.updateFlashcard(oldCard.id, front: front, back: back, hint: hint);

      // Refresh danh sách flashcards
      ref.invalidate(flashcardsProvider(widget.deckId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã cập nhật thẻ'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
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

  // Xóa flashcard
  Future<void> _deleteFlashcard(Flashcard card) async {
    try {
      final flashcardRepo = ref.read(flashcardRepositoryProvider);
      await flashcardRepo.deleteFlashcard(card.id);

      // Refresh danh sách flashcards
      ref.invalidate(flashcardsProvider(widget.deckId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🗑️ Đã xóa thẻ "${card.front}"'),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
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
    final flashcardsAsync = ref.watch(flashcardsProvider(widget.deckId));

    return flashcardsAsync.when(
      data: (flashcards) => _buildContent(context, flashcards),
      loading: () => Scaffold(
        appBar: AppBar(title: Text(widget.deckName)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: Text(widget.deckName)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Lỗi: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(flashcardsProvider(widget.deckId)),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Flashcard> flashcards) {
    // Thống kê mới: Đếm số thẻ đã được ôn tập ít nhất 1 lần
    final reviewedCount = flashcards.where((c) => c.lastReviewedAt != null).length;
    final masteredCount = flashcards.where((c) => c.isMastered).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FlashcardSearchScreen(deckId: widget.deckId, deckName: widget.deckName),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Stats
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildHeaderStat(context, 'Tổng số', '${flashcards.length}', Icons.style, AppColors.primary),
                    _buildHeaderStat(context, 'Đã ôn', '$reviewedCount', Icons.check_circle, AppColors.success),
                    _buildHeaderStat(context, 'Thành thạo', '$masteredCount', Icons.star, AppColors.warning),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Bắt đầu học',
                  onPressed: () async {
                    if (flashcards.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('⚠️ Chưa có thẻ để học. Hãy thêm thẻ trước!'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                      return;
                    }

                    // Navigate to study screen
                    context.push('/study/${widget.deckId}?deckName=${widget.deckName}');
                  },
                  icon: Icons.play_arrow,
                ),
              ],
            ),
          ),

          // Flashcard List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(flashcardsProvider(widget.deckId));
              },
              child: flashcards.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.style_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có thẻ nào',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Text('Nhấn nút + để thêm thẻ mới', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: flashcards.length,
                      itemBuilder: (context, index) {
                        final card = flashcards[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildFlashcardItem(context, card, index),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeaderStat(BuildContext context, String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hôm nay';
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else if (diff.inDays < 0 && diff.inDays > -7) {
      return '${-diff.inDays} ngày nữa';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildFlashcardItem(BuildContext context, Flashcard card, int index) {
    return CustomCard(
      child: Row(
        children: [
          // Number
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        card.front,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Tag "Đã ôn" cho thẻ đã học
                    if (card.lastReviewedAt != null && !card.isMastered)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 14, color: AppColors.info),
                            SizedBox(width: 4),
                            Text(
                              'Đã ôn',
                              style: TextStyle(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    // Tag "Thành thạo" cho thẻ đã thuộc
                    if (card.isMastered)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.success.withOpacity(0.3), width: 1),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 14, color: AppColors.success),
                            SizedBox(width: 4),
                            Text(
                              'Thành thạo',
                              style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  card.back,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                // Thông tin ôn tập
                if (card.lastReviewedAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 12, color: AppColors.textSecondary.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Ôn lần cuối: ${_formatDate(card.lastReviewedAt!)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary.withOpacity(0.8),
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (card.nextReviewDate != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.event, size: 12, color: AppColors.primary.withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Ôn tiếp: ${_formatDate(card.nextReviewDate!)}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: AppColors.primary.withOpacity(0.8), fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Actions
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, size: 20),
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
              if (value == 'edit') {
                _showAddEditDialog(context, card: card);
              } else if (value == 'delete') {
                _deleteFlashcard(card);
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {Flashcard? card}) {
    final isEdit = card != null;
    final frontController = TextEditingController(text: card?.front);
    final backController = TextEditingController(text: card?.back);
    final hintController = TextEditingController(text: card?.hint);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(isEdit ? Icons.edit : Icons.add_card, size: 24),
            const SizedBox(width: 12),
            Text(isEdit ? 'Chỉnh sửa thẻ' : 'Thêm thẻ mới'),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: frontController,
                  decoration: const InputDecoration(
                    labelText: 'Mặt trước *',
                    hintText: 'VD: Hello',
                    prefixIcon: Icon(Icons.flip_to_front),
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                  maxLines: 2,
                  minLines: 1,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập nội dung';
                    }
                    if (value.trim().length < 2) {
                      return 'Nội dung quá ngắn (tối thiểu 2 ký tự)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: backController,
                  decoration: const InputDecoration(
                    labelText: 'Mặt sau *',
                    hintText: 'VD: Xin chào',
                    prefixIcon: Icon(Icons.flip_to_back),
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  minLines: 1,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập nội dung';
                    }
                    if (value.trim().length < 2) {
                      return 'Nội dung quá ngắn (tối thiểu 2 ký tự)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: hintController,
                  decoration: const InputDecoration(
                    labelText: 'Gợi ý (tùy chọn)',
                    hintText: 'VD: Lời chào thường gặp',
                    prefixIcon: Icon(Icons.lightbulb_outline),
                    border: OutlineInputBorder(),
                    helperText: 'Gợi ý giúp bạn nhớ từ dễ hơn',
                  ),
                  maxLines: 2,
                  minLines: 1,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
          FilledButton.icon(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final front = frontController.text.trim();
                final back = backController.text.trim();
                final hint = hintController.text.trim().isEmpty ? null : hintController.text.trim();

                if (isEdit) {
                  _updateFlashcard(card, front, back, hint);
                } else {
                  _addFlashcard(front, back, hint);
                }

                Navigator.pop(dialogContext);
              }
            },
            icon: Icon(isEdit ? Icons.check : Icons.add),
            label: Text(isEdit ? 'Cập nhật' : 'Thêm'),
          ),
        ],
      ),
    );
  }
}
