// ignore_for_file: avoid_print, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('forest', (tester) async {
    debugPrintBeginFrameBanner = debugPrintEndFrameBanner = true;

    final pipelineOwner = PipelineOwner();
    final rootView = pipelineOwner.rootNode = MeasurementView();
    final buildOwner = BuildOwner(focusManager: FocusManager());

    var secondTreeWidgetBuildTime = 0;
    final secondTreeWidget = StatefulBuilder(builder: (_, setState) {
      print(
          'secondTreeWidget(StatefulBuilder).builder called ($secondTreeWidgetBuildTime)');

      SchedulerBinding.instance.addPostFrameCallback((_) {
        print('secondTreeWidget.setState');
        setState(() {});
      });

      secondTreeWidgetBuildTime++;

      return SizedBox(width: secondTreeWidgetBuildTime.toDouble(), height: 10);
    });

    // ignore: unused_local_variable
    final element = RenderObjectToWidgetAdapter<RenderBox>(
      container: rootView,
      debugShortDescription: '[root]',
      child: secondTreeWidget,
    ).attachToRenderTree(buildOwner);

    print('before pumpWidget');
    rootView.scheduleInitialLayout();
    // TODO has more steps?
    pipelineOwner.flushLayout();
    buildOwner.finalizeTree();
    print('rootView.size=${rootView.size}');

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(builder: (_, setState) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            print('mainTree(StatefulBuilder).setState');
            setState(() {});
          });

          for (var iter = 0; iter < 3; ++iter) {
            print(
                'mainTree(StatefulBuilder).builder, run second tree pipeline iter=#$iter');

            // TODO has more steps?
            pipelineOwner.flushLayout();
            buildOwner.finalizeTree();
            print('rootView.size=${rootView.size}');
          }

          return SizedBox(width: 20, height: 20);
        }),
      ),
    ));

    for (var i = 0; i < 5; ++i) {
      await tester.pump();
    }

    debugPrintBeginFrameBanner = debugPrintEndFrameBanner = false;
  });
}

class MeasurementView extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  @override
  void performLayout() {
    assert(child != null);
    child!.layout(const BoxConstraints(), parentUsesSize: true);
    size = child!.size;
  }

  @override
  void debugAssertDoesMeetConstraints() => true;
}
