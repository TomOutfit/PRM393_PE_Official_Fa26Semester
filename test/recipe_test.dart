import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_box/models/recipe_model.dart';

void main() {
  group('1. RecipeModel Unit Tests', () {
    test('RecipeModel initializes with correct values and defaults', () {
      final recipe = RecipeModel(
        id: 'rec_01',
        userId: 'user_123',
        name: 'Spaghetti Carbonara',
        category: 'Dinner',
        difficulty: 'Medium',
        cookTime: 20,
      );

      expect(recipe.id, equals('rec_01'));
      expect(recipe.userId, equals('user_123'));
      expect(recipe.name, equals('Spaghetti Carbonara'));
      expect(recipe.category, equals('Dinner'));
      expect(recipe.difficulty, equals('Medium'));
      expect(recipe.cookTime, equals(20));
      expect(recipe.servings, isNull);
      expect(recipe.favorite, isFalse);
      expect(recipe.notes, isNull);
    });

    test('RecipeModel copyWith updates specified fields correctly', () {
      final recipe = RecipeModel(
        id: 'rec_01',
        userId: 'user_123',
        name: 'Original Pancake',
        category: 'Breakfast',
        difficulty: 'Easy',
        cookTime: 15,
        favorite: false,
      );

      final updated = recipe.copyWith(
        name: 'Updated Pancake',
        cookTime: 20,
        favorite: true,
      );

      expect(updated.id, equals('rec_01'));
      expect(updated.name, equals('Updated Pancake'));
      expect(updated.cookTime, equals(20));
      expect(updated.favorite, isTrue);
      expect(updated.category, equals('Breakfast'));
    });

    test('RecipeModel toMap serializes fields accurately', () {
      final now = DateTime(2026, 11, 3, 12, 0, 0);
      final recipe = RecipeModel(
        id: 'rec_02',
        userId: 'user_abc',
        name: 'Beef Pho',
        category: 'Breakfast',
        difficulty: 'Hard',
        cookTime: 180,
        servings: 4,
        favorite: true,
        notes: 'Simmer broth for hours',
        createdAt: now,
      );

      final map = recipe.toMap();

      expect(map['userId'], equals('user_abc'));
      expect(map['name'], equals('Beef Pho'));
      expect(map['category'], equals('Breakfast'));
      expect(map['difficulty'], equals('Hard'));
      expect(map['cookTime'], equals(180));
      expect(map['servings'], equals(4));
      expect(map['favorite'], isTrue);
      expect(map['notes'], equals('Simmer broth for hours'));
    });
  });

  group('2. Sorting Specification Tests (Section 2.3 B)', () {
    test('Sorts by cookTime ascending (shortest first)', () {
      final list = [
        RecipeModel(id: '1', userId: 'u', name: 'Slow Stew', category: 'Dinner', difficulty: 'Hard', cookTime: 120),
        RecipeModel(id: '2', userId: 'u', name: 'Toast', category: 'Breakfast', difficulty: 'Easy', cookTime: 5),
        RecipeModel(id: '3', userId: 'u', name: 'Salad', category: 'Lunch', difficulty: 'Easy', cookTime: 15),
      ];

      list.sort((a, b) {
        int cookCompare = a.cookTime.compareTo(b.cookTime);
        if (cookCompare != 0) return cookCompare;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      expect(list.map((r) => r.name).toList(), equals(['Toast', 'Salad', 'Slow Stew']));
    });

    test('Tie-breaker: equal cook times sorted by name case-insensitively', () {
      final list = [
        RecipeModel(id: '1', userId: 'u', name: 'waffles', category: 'Breakfast', difficulty: 'Easy', cookTime: 15),
        RecipeModel(id: '2', userId: 'u', name: 'Apple Pie', category: 'Dessert', difficulty: 'Medium', cookTime: 15),
        RecipeModel(id: '3', userId: 'u', name: 'banana Smoothie', category: 'Breakfast', difficulty: 'Easy', cookTime: 15),
      ];

      list.sort((a, b) {
        int cookCompare = a.cookTime.compareTo(b.cookTime);
        if (cookCompare != 0) return cookCompare;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      expect(list.map((r) => r.name).toList(), equals(['Apple Pie', 'banana Smoothie', 'waffles']));
    });
  });

  group('3. Filter & Search Tests (Section 2.3 C)', () {
    final sampleRecipes = [
      RecipeModel(id: '1', userId: 'u', name: 'Pho Bo', category: 'Breakfast', difficulty: 'Hard', cookTime: 180, favorite: true, notes: 'Beef soup'),
      RecipeModel(id: '2', userId: 'u', name: 'Pancakes', category: 'Breakfast', difficulty: 'Easy', cookTime: 15, favorite: false, notes: 'Sweet breakfast with maple'),
      RecipeModel(id: '3', userId: 'u', name: 'Caesar Salad', category: 'Lunch', difficulty: 'Easy', cookTime: 15, favorite: true, notes: 'Crispy salad'),
      RecipeModel(id: '4', userId: 'u', name: 'Steak', category: 'Dinner', difficulty: 'Medium', cookTime: 25, favorite: false, notes: 'Garlic butter steak'),
      RecipeModel(id: '5', userId: 'u', name: 'Lava Cake', category: 'Dessert', difficulty: 'Hard', cookTime: 30, favorite: true, notes: 'Rich chocolate dessert'),
    ];

    test('Filters by category correctly', () {
      final breakfastOnly = sampleRecipes.where((r) => r.category == 'Breakfast').toList();
      expect(breakfastOnly.length, equals(2));
      expect(breakfastOnly.map((r) => r.name), containsAll(['Pho Bo', 'Pancakes']));
    });

    test('Filters by difficulty correctly', () {
      final hardOnly = sampleRecipes.where((r) => r.difficulty == 'Hard').toList();
      expect(hardOnly.length, equals(2));
      expect(hardOnly.map((r) => r.name), containsAll(['Pho Bo', 'Lava Cake']));
    });

    test('Filters by favorites only switch', () {
      final favoritesOnly = sampleRecipes.where((r) => r.favorite).toList();
      expect(favoritesOnly.length, equals(3));
      expect(favoritesOnly.map((r) => r.name), containsAll(['Pho Bo', 'Caesar Salad', 'Lava Cake']));
    });

    test('Searches by name or notes (case-insensitive, trimmed)', () {
      const query = '  BEEF  ';
      final q = query.trim().toLowerCase();
      final searchResults = sampleRecipes.where((r) {
        final matchName = r.name.toLowerCase().contains(q);
        final matchNotes = r.notes != null && r.notes!.toLowerCase().contains(q);
        return matchName || matchNotes;
      }).toList();

      expect(searchResults.length, equals(1));
      expect(searchResults.first.name, equals('Pho Bo'));
    });

    test('Combined filter: Category + Difficulty + Favorites + Search', () {
      final combined = sampleRecipes.where((r) {
        if (r.category != 'Breakfast') return false;
        if (r.difficulty != 'Hard') return false;
        if (!r.favorite) return false;
        final q = 'pho';
        final matchName = r.name.toLowerCase().contains(q);
        final matchNotes = r.notes != null && r.notes!.toLowerCase().contains(q);
        return matchName || matchNotes;
      }).toList();

      expect(combined.length, equals(1));
      expect(combined.first.name, equals('Pho Bo'));
    });
  });

  group('4. Summary Calculations & Category Ordering Tests (Section 2.3 C)', () {
    final testList = [
      RecipeModel(id: '1', userId: 'u', name: 'A', category: 'Breakfast', difficulty: 'Easy', cookTime: 10, favorite: true),
      RecipeModel(id: '2', userId: 'u', name: 'B', category: 'Lunch', difficulty: 'Medium', cookTime: 20, favorite: false),
      RecipeModel(id: '3', userId: 'u', name: 'C', category: 'Lunch', difficulty: 'Easy', cookTime: 15, favorite: true),
      RecipeModel(id: '4', userId: 'u', name: 'D', category: 'Dinner', difficulty: 'Hard', cookTime: 30, favorite: true),
      RecipeModel(id: '5', userId: 'u', name: 'E', category: 'Dessert', difficulty: 'Easy', cookTime: 25, favorite: false),
    ];

    test('Calculates total recipes count, favorites count, and total cook time', () {
      final totalCount = testList.length;
      final favCount = testList.where((r) => r.favorite).length;
      final totalTime = testList.fold(0, (sum, r) => sum + r.cookTime);

      expect(totalCount, equals(5));
      expect(favCount, equals(3));
      expect(totalTime, equals(100));
    });

    test('Category breakdown: most recipes first; ties ordered Breakfast -> Lunch -> Dinner -> Dessert', () {
      final Map<String, int> categoryCounts = {};
      for (var recipe in testList) {
        categoryCounts[recipe.category] = (categoryCounts[recipe.category] ?? 0) + 1;
      }

      final constOrder = ['Breakfast', 'Lunch', 'Dinner', 'Dessert'];
      final entries = categoryCounts.entries.where((e) => e.value > 0).toList();

      entries.sort((a, b) {
        int countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) return countCompare;
        int orderA = constOrder.indexOf(a.key);
        int orderB = constOrder.indexOf(b.key);
        if (orderA == -1) orderA = 99;
        if (orderB == -1) orderB = 99;
        return orderA.compareTo(orderB);
      });

      // Lunch has 2, Breakfast has 1, Dinner has 1, Dessert has 1
      // Expected order: Lunch (2), Breakfast (1), Dinner (1), Dessert (1)
      final orderedCategories = entries.map((e) => '${e.key}:${e.value}').toList();
      expect(orderedCategories, equals(['Lunch:2', 'Breakfast:1', 'Dinner:1', 'Dessert:1']));
    });
  });

  group('5. Exact Validation Error Messages Tests', () {
    // Helper validators matching form validator functions
    String? validateName(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Name is required';
      }
      if (value.trim().length > 80) {
        return 'Name must be at most 80 characters';
      }
      return null;
    }

    String? validateCategory(String? value) {
      if (value == null || value == 'Choose category') {
        return 'Please choose a category';
      }
      return null;
    }

    String? validateDifficulty(String? value) {
      if (value == null || value == 'Choose difficulty') {
        return 'Please choose a difficulty';
      }
      return null;
    }

    String? validateCookTime(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Cook time is required';
      }
      final cookVal = int.tryParse(value.trim());
      if (cookVal == null || cookVal < 1 || cookVal > 600) {
        return 'Cook time must be a whole number from 1 to 600';
      }
      return null;
    }

    String? validateServings(String? value) {
      if (value != null && value.trim().isNotEmpty) {
        final servingsVal = int.tryParse(value.trim());
        if (servingsVal == null || servingsVal < 1 || servingsVal > 20) {
          return 'Servings must be a whole number from 1 to 20';
        }
      }
      return null;
    }

    String? validateNotes(String? value) {
      if (value != null && value.trim().length > 300) {
        return 'Notes must be at most 300 characters';
      }
      return null;
    }

    String? validateEmail(String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Email is required';
      }
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value.trim())) {
        return 'Please enter a valid email address';
      }
      return null;
    }

    String? validatePassword(String? value, {bool isRegister = false}) {
      if (value == null || value.isEmpty) {
        return 'Password is required';
      }
      if (isRegister && value.length < 6) {
        return 'Password must be at least 6 characters';
      }
      return null;
    }

    String? validateConfirmPassword(String? value, String password) {
      if (value == null || value.isEmpty) {
        return 'Confirm password is required';
      }
      if (value != password) {
        return 'Passwords do not match';
      }
      return null;
    }

    test('Name validation exact error messages', () {
      expect(validateName(''), equals('Name is required'));
      expect(validateName('   '), equals('Name is required'));
      expect(validateName('a' * 81), equals('Name must be at most 80 characters'));
      expect(validateName('Pho Bo'), isNull);
    });

    test('Category validation exact error messages', () {
      expect(validateCategory(null), equals('Please choose a category'));
      expect(validateCategory('Choose category'), equals('Please choose a category'));
      expect(validateCategory('Breakfast'), isNull);
      expect(validateCategory('Lunch'), isNull);
    });

    test('Difficulty validation exact error messages', () {
      expect(validateDifficulty(null), equals('Please choose a difficulty'));
      expect(validateDifficulty('Choose difficulty'), equals('Please choose a difficulty'));
      expect(validateDifficulty('Easy'), isNull);
      expect(validateDifficulty('Hard'), isNull);
    });

    test('Cook time validation exact error messages', () {
      expect(validateCookTime(''), equals('Cook time is required'));
      expect(validateCookTime('abc'), equals('Cook time must be a whole number from 1 to 600'));
      expect(validateCookTime('0'), equals('Cook time must be a whole number from 1 to 600'));
      expect(validateCookTime('601'), equals('Cook time must be a whole number from 1 to 600'));
      expect(validateCookTime('25'), isNull);
    });

    test('Servings validation exact error messages', () {
      expect(validateServings(''), isNull);
      expect(validateServings(null), isNull);
      expect(validateServings('0'), equals('Servings must be a whole number from 1 to 20'));
      expect(validateServings('21'), equals('Servings must be a whole number from 1 to 20'));
      expect(validateServings('4'), isNull);
    });

    test('Notes validation exact error messages', () {
      expect(validateNotes(null), isNull);
      expect(validateNotes(''), isNull);
      expect(validateNotes('a' * 301), equals('Notes must be at most 300 characters'));
      expect(validateNotes('a' * 300), isNull);
    });

    test('Auth validation exact error messages', () {
      expect(validateEmail(''), equals('Email is required'));
      expect(validateEmail('notanemail'), equals('Please enter a valid email address'));
      expect(validateEmail('test@example.com'), isNull);

      expect(validatePassword(''), equals('Password is required'));
      expect(validatePassword('12345', isRegister: true), equals('Password must be at least 6 characters'));
      expect(validatePassword('123456', isRegister: true), isNull);

      expect(validateConfirmPassword('', '123456'), equals('Confirm password is required'));
      expect(validateConfirmPassword('123457', '123456'), equals('Passwords do not match'));
      expect(validateConfirmPassword('123456', '123456'), isNull);
    });
  });

  group('6. Duplicate Recipe Name (Case-insensitive) Logic Tests', () {
    test('Identifies duplicate recipe name for same user regardless of case and trimming', () {
      final existingNames = ['Pho Bo', 'Spaghetti Carbonara', 'Pancakes'];

      bool isDuplicate(String newName) {
        final target = newName.trim().toLowerCase();
        return existingNames.any((name) => name.trim().toLowerCase() == target);
      }

      expect(isDuplicate('pho bo'), isTrue);
      expect(isDuplicate('  PHO BO  '), isTrue);
      expect(isDuplicate('pAnCaKeS'), isTrue);
      expect(isDuplicate('Pho Ga'), isFalse);
    });
  });
}
