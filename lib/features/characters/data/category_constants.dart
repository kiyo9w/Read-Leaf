import 'package:flutter/material.dart';

/// Literary genres and categories for character classification
class CharacterCategories {
  // Main categories
  static const String all = 'All';
  static const String fiction = 'Fiction';
  static const String nonFiction = 'Non-Fiction';
  static const String custom = 'Custom';

  // Fiction subcategories
  static const String fantasy = 'Fantasy';
  static const String scienceFiction = 'Science Fiction';
  static const String romance = 'Romance';
  static const String mystery = 'Mystery';
  static const String thriller = 'Thriller';
  static const String horror = 'Horror';
  static const String historical = 'Historical';
  static const String adventure = 'Adventure';
  static const String youngAdult = 'Young Adult';
  static const String children = 'Children';
  static const String classics = 'Classics';

  // Non-fiction subcategories
  static const String academic = 'Academic';
  static const String biography = 'Biography';
  static const String selfHelp = 'Self-Help';
  static const String history = 'History';
  static const String science = 'Science';

  // Get all categories as list
  static List<String> getAllCategories() {
    return [
      all,
      fiction,
      fantasy,
      scienceFiction,
      romance,
      mystery,
      thriller,
      horror,
      historical,
      adventure,
      youngAdult,
      children,
      classics,
      nonFiction,
      academic,
      biography,
      selfHelp,
      history,
      science,
      custom,
    ];
  }

  // Get main categories only
  static List<String> getMainCategories() {
    return [
      all,
      fiction,
      nonFiction,
      custom,
    ];
  }

  // Get fiction categories only
  static List<String> getFictionCategories() {
    return [
      fiction,
      fantasy,
      scienceFiction,
      romance,
      mystery,
      thriller,
      horror,
      historical,
      adventure,
      youngAdult,
      children,
      classics,
    ];
  }

  // Get non-fiction categories only
  static List<String> getNonFictionCategories() {
    return [
      nonFiction,
      academic,
      biography,
      selfHelp,
      history,
      science,
    ];
  }

  // Get category icon
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case all:
        return Icons.category;
      case fiction:
        return Icons.auto_stories;
      case fantasy:
        return Icons.auto_awesome;
      case scienceFiction:
        return Icons.rocket_launch;
      case romance:
        return Icons.favorite;
      case mystery:
        return Icons.search;
      case thriller:
        return Icons.psychology;
      case horror:
        return Icons.nightlight;
      case historical:
        return Icons.history_edu;
      case adventure:
        return Icons.explore;
      case youngAdult:
        return Icons.people;
      case children:
        return Icons.child_care;
      case classics:
        return Icons.bookmark;
      case nonFiction:
        return Icons.school;
      case academic:
        return Icons.science;
      case biography:
        return Icons.face;
      case selfHelp:
        return Icons.self_improvement;
      case history:
        return Icons.history;
      case science:
        return Icons.biotech;
      case custom:
        return Icons.edit;
      default:
        return Icons.book;
    }
  }

  // Get category color
  static Color getCategoryColor(String category, ThemeData theme) {
    switch (category) {
      case fiction:
        return Colors.blue;
      case fantasy:
        return Colors.purple;
      case scienceFiction:
        return Colors.cyan;
      case romance:
        return Colors.pink;
      case mystery:
        return Colors.indigo;
      case thriller:
        return Colors.red.shade800;
      case horror:
        return Colors.grey.shade800;
      case historical:
        return Colors.brown;
      case adventure:
        return Colors.green;
      case youngAdult:
        return Colors.teal;
      case children:
        return Colors.orange;
      case classics:
        return Colors.amber.shade700;
      case nonFiction:
        return Colors.green.shade700;
      case academic:
        return Colors.lightBlue;
      case biography:
        return Colors.deepOrange;
      case selfHelp:
        return Colors.lightGreen;
      case history:
        return Colors.brown.shade600;
      case science:
        return Colors.blueGrey;
      case custom:
        return theme.primaryColor;
      default:
        return theme.colorScheme.primary;
    }
  }
}
