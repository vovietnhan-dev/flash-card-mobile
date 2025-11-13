import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../../deck/domain/flashcard_model.dart';
import '../domain/review_quality.dart';

class StudyScreen extends ConsumerStatefulWidget {
  final int deckId;
  final String deckName;

  const StudyScreen({super.key, required this.deckId, required this.deckName});

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  bool _showBack = false;
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showHint = false; // Toggle state for hint visibility

  // Study data
  List<Flashcard> _studyCards = [];
  int? _sessionId;
  final Map<int, DateTime> _cardStartTimes = {};
  final Set<int> _notMasteredCardIds = {}; // Track cards marked as "Chưa thuộc"

  // Stats - Simplified to 2 options
  int _masteredCount = 0; // Đã thuộc
  int _notMasteredCount = 0; // Chưa thuộc

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _flipController, curve: Curves.easeInOut));

    _initializeStudySession();
  }

  Future<void> _initializeStudySession() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final studyRepo = ref.read(studyRepositoryProvider);

      // 1. Get due cards
      final dueResponse = await studyRepo.getDueCards(deckId: widget.deckId, limit: 50);

      if (dueResponse.cards.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'no_cards';
        });
        return;
      }

      // 2. Start study session
      final session = await studyRepo.startSession(deckId: widget.deckId);

      setState(() {
        _studyCards = dueResponse.cards;
        _sessionId = session.id;
        _isLoading = false;

        // Populate _notMasteredCardIds with cards that are NOT mastered
        _notMasteredCardIds.clear();
        for (var card in _studyCards) {
          if (!card.isMastered) {
            _notMasteredCardIds.add(card.id);
          }
        }

        // Start timer for first card
        _cardStartTimes[_studyCards[0].id] = DateTime.now();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showBack) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _showBack = !_showBack;
    });
  }

  Future<void> _handleAnswer(ReviewQuality quality) async {
    final currentCard = _studyCards[_currentIndex];
    final startTime = _cardStartTimes[currentCard.id];
    final timeTaken = startTime != null ? DateTime.now().difference(startTime).inSeconds : 5;

    try {
      final studyRepo = ref.read(studyRepositoryProvider);

      // Submit review to API
      await studyRepo.submitReview(
        flashcardId: currentCard.id,
        quality: quality,
        timeTakenSeconds: timeTaken,
        studySessionId: _sessionId,
      );

      // Update stats - Simplified
      setState(() {
        if (quality == ReviewQuality.perfect) {
          _masteredCount++;
          // Remove from not mastered list if it was there
          _notMasteredCardIds.remove(currentCard.id);
        } else {
          _notMasteredCount++;
          // Add to not mastered list
          _notMasteredCardIds.add(currentCard.id);
        }

        // Move to next card
        if (_currentIndex < _studyCards.length - 1) {
          _currentIndex++;
          _showBack = false;
          _showHint = false; // Reset hint for next card
          _flipController.reset();

          // Start timer for next card
          _cardStartTimes[_studyCards[_currentIndex].id] = DateTime.now();
        } else {
          _endSession();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Lỗi: ${e.toString()}'), backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _endSession() async {
    if (_sessionId == null) return;

    try {
      final studyRepo = ref.read(studyRepositoryProvider);
      final endedSession = await studyRepo.endSession(_sessionId!);

      // Wait a bit for backend to update
      await Future.delayed(const Duration(milliseconds: 500));

      // Force refresh decks và flashcards
      ref.invalidate(decksProvider);
      ref.invalidate(flashcardsProvider(widget.deckId));

      // Trigger immediate reload
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        _showCompletionDialog(endedSession.accuracyRate);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi kết thúc session: ${e.toString()}'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showCompletionDialog(double accuracyRate) {
    final totalReviews = _masteredCount + _notMasteredCount;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Hoàn thành!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn đã hoàn thành $totalReviews thẻ!', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'Độ chính xác: ${(accuracyRate * 100).toStringAsFixed(1)}%',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const Divider(height: 24),
            _buildResultRow('Đã thuộc', _masteredCount, AppColors.success, Icons.check_circle),
            _buildResultRow('Chưa thuộc', _notMasteredCount, AppColors.error, Icons.cancel),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng dialog
              Navigator.of(context).pop(); // Quay về FlashcardListScreen
            },
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng dialog
              _restartSession();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Học lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, int count, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color)),
          const Spacer(),
          Text(
            '$count',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _restartSession() {
    // Nếu có thẻ chưa thuộc, chỉ học lại những thẻ đó
    if (_notMasteredCardIds.isNotEmpty) {
      setState(() {
        // Filter only not mastered cards
        _studyCards = _studyCards.where((card) => _notMasteredCardIds.contains(card.id)).toList();
        _masteredCount = 0;
        _notMasteredCount = 0;
        _currentIndex = 0;
        _showBack = false;
        _showHint = false; // Reset hint
        _flipController.reset();
        _cardStartTimes.clear();
        _isLoading = false;
        _errorMessage = null;

        // Start timer for first card
        if (_studyCards.isNotEmpty) {
          _cardStartTimes[_studyCards[0].id] = DateTime.now();
        }
      });

      // Start new session
      _startNewSession();
    } else {
      // Nếu không có thẻ nào chưa thuộc, load lại tất cả
      setState(() {
        _masteredCount = 0;
        _notMasteredCount = 0;
        _currentIndex = 0;
        _showBack = false;
        _showHint = false; // Reset hint
        _flipController.reset();
        _cardStartTimes.clear();
        _notMasteredCardIds.clear();
      });
      _initializeStudySession();
    }
  }

  Future<void> _startNewSession() async {
    try {
      final studyRepo = ref.read(studyRepositoryProvider);
      final session = await studyRepo.startSession(deckId: widget.deckId);

      setState(() {
        _sessionId = session.id;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi khởi tạo session: ${e.toString()}'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.deckName), backgroundColor: AppColors.primary),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Đang tải thẻ...')],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.deckName), backgroundColor: AppColors.primary),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _errorMessage == 'no_cards' ? Icons.check_circle : Icons.error,
                size: 64,
                color: _errorMessage == 'no_cards' ? AppColors.success : AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage == 'no_cards' ? 'Không có thẻ cần ôn tập!\nChúc mừng bạn!' : 'Lỗi: $_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Quay lại'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    }

    final currentCard = _studyCards[_currentIndex];
    final progress = (_currentIndex + 1) / _studyCards.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName),
        backgroundColor: AppColors.primary,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_currentIndex + 1}/${_studyCards.length}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surface,
            color: AppColors.primary,
            minHeight: 6,
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _flipCard,
                      child: AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, child) {
                          final angle = _flipAnimation.value * pi;
                          final isFrontVisible = angle < pi / 2;

                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateX(angle),
                            alignment: Alignment.center,
                            child: isFrontVisible
                                ? _buildCardSide(currentCard.front, 'Nhấn để lật', AppColors.primary)
                                : Transform(
                                    transform: Matrix4.identity()..rotateX(pi),
                                    alignment: Alignment.center,
                                    child: _buildCardSide(currentCard.back, 'Mặt sau', AppColors.secondary),
                                  ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_showBack) _buildAnswerButtons(),
                  ],
                ),
              ),
            ),
          ),
          _buildStatsBar(),
        ],
      ),
    );
  }

  Widget _buildCardSide(String text, String label, Color color) {
    final currentCard = _studyCards[_currentIndex];
    final isNotMastered = _notMasteredCardIds.contains(currentCard.id);
    final isFrontSide = !_showBack; // Check if showing front side
    final hasHint = currentCard.hint != null && currentCard.hint!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 300),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isNotMastered ? Border.all(color: AppColors.error, width: 3) : null,
        boxShadow: [
          BoxShadow(
            color: isNotMastered ? AppColors.error.withOpacity(0.3) : color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hint toggle button (only on front side)
          if (hasHint && isFrontSide) ...[
            if (!_showHint)
              TextButton.icon(
                onPressed: () => setState(() => _showHint = true),
                icon: const Icon(Icons.lightbulb_outline, size: 20),
                label: const Text('💡 Hiện gợi ý'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lightbulb, size: 16, color: Colors.amber),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        currentCard.hint!,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
          ],
          if (isNotMastered) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error, width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning, size: 16, color: AppColors.error),
                  SizedBox(width: 6),
                  Text(
                    'Chưa thuộc',
                    style: TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            label,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _buildAnswerButton('Chưa thuộc', Icons.close, AppColors.error, ReviewQuality.incorrect)),
          const SizedBox(width: 16),
          Expanded(child: _buildAnswerButton('Đã thuộc', Icons.check, AppColors.success, ReviewQuality.perfect)),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(String label, IconData icon, Color color, ReviewQuality quality) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => _handleAnswer(quality),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Đã thuộc', _masteredCount, AppColors.success),
          _buildStatItem('Chưa thuộc', _notMasteredCount, AppColors.error),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
