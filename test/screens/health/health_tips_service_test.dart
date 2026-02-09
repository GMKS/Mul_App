import 'package:flutter_test/flutter_test.dart';
import 'package:regional_shorts_app/screens/health/health_tips_screen.dart';
import 'package:regional_shorts_app/services/health_tips_service.dart';
import 'package:regional_shorts_app/models/health_tips_model.dart';

void main() {
  group('HealthTipsService', () {
    final service = HealthTipsService();

    test('getTips returns non-empty list', () async {
      final tips = await service.getTips();
      expect(tips, isNotEmpty);
    });

    test('getTipOfTheDay returns a tip', () async {
      final tip = await service.getTipOfTheDay();
      expect(tip, isNotNull);
      expect(tip!.isTipOfTheDay, isTrue);
    });

    test('getTipsByCategory filters by category', () async {
      final tips = await service.getTipsByCategory(HealthCategory.nutrition);
      expect(tips.every((t) => t.category == HealthCategory.nutrition), isTrue);
    });

    test('searchTips finds tips by keyword', () async {
      final tips = await service.searchTips('diet');
      expect(tips.any((t) => t.title.toLowerCase().contains('diet')), isTrue);
    });
  });
}
