import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_tools/binding.dart';

void main() {
  final binding = SmoothAutomatedTestWidgetsFlutterBinding.ensureInitialized();

  group('SmoothSchedulerBindingMixin', () {
    testWidgets('beginFrameDateTime', (tester) async {
      // very naive test, because clock has not even run for a millisecond
      // during this whole test!
      final expectBeginFrameDateTime = clock.now();
      await tester.pumpWidget(Container());
      expect(binding.beginFrameDateTime, expectBeginFrameDateTime);
    });
  });
}
