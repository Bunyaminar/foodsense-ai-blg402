import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App Theme Tests', () {

    Color getScoreColor(int score) {
      if (score >= 65) return const Color(0xFF2E7D32);
      if (score >= 40) return const Color(0xFFFF8F00);
      return const Color(0xFFE53935);
    }

    bool isDarkColor(Color color) {
      return color.computeLuminance() < 0.5;
    }

    test('healthy score should return green color', () {
      final color = getScoreColor(80);
      expect(color, const Color(0xFF2E7D32));
    });

    test('medium score should return orange color', () {
      final color = getScoreColor(50);
      expect(color, const Color(0xFFFF8F00));
    });

    test('low score should return red color', () {
      final color = getScoreColor(20);
      expect(color, const Color(0xFFE53935));
    });

    test('boundary score 65 should be green', () {
      expect(getScoreColor(65), const Color(0xFF2E7D32));
    });

    test('boundary score 40 should be orange', () {
      expect(getScoreColor(40), const Color(0xFFFF8F00));
    });

    test('boundary score 39 should be red', () {
      expect(getScoreColor(39), const Color(0xFFE53935));
    });

    test('primary green color should be dark', () {
      final color = const Color(0xFF2E7D32);
      expect(isDarkColor(color), true);
    });

    test('white color should not be dark', () {
      final color = Colors.white;
      expect(isDarkColor(color), false);
    });
  });
}
