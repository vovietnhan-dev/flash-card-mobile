import 'package:flutter/material.dart';

enum DeckSortType {
  nameAsc,
  nameDesc,
  newestFirst,
  oldestFirst,
  mostCards,
  leastCards,
  mostLearned,
  leastLearned,
}

extension DeckSortTypeExtension on DeckSortType {
  String get label {
    switch (this) {
      case DeckSortType.nameAsc:
        return 'Tên A-Z';
      case DeckSortType.nameDesc:
        return 'Tên Z-A';
      case DeckSortType.newestFirst:
        return 'Mới nhất';
      case DeckSortType.oldestFirst:
        return 'Cũ nhất';
      case DeckSortType.mostCards:
        return 'Nhiều thẻ nhất';
      case DeckSortType.leastCards:
        return 'Ít thẻ nhất';
      case DeckSortType.mostLearned:
        return 'Học nhiều nhất';
      case DeckSortType.leastLearned:
        return 'Học ít nhất';
    }
  }

  IconData get icon {
    switch (this) {
      case DeckSortType.nameAsc:
      case DeckSortType.nameDesc:
        return Icons.sort_by_alpha;
      case DeckSortType.newestFirst:
      case DeckSortType.oldestFirst:
        return Icons.access_time;
      case DeckSortType.mostCards:
      case DeckSortType.leastCards:
        return Icons.numbers;
      case DeckSortType.mostLearned:
      case DeckSortType.leastLearned:
        return Icons.trending_up;
    }
  }
}
