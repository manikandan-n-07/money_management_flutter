import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_management/widgets/app_logo.dart';

void main() {
  testWidgets('Generate launcher icons from AppLogo', (WidgetTester tester) async {
    final mipmaps = {
      'mipmap-mdpi': 48,
      'mipmap-hdpi': 72,
      'mipmap-xhdpi': 96,
      'mipmap-xxhdpi': 144,
      'mipmap-xxxhdpi': 192,
    };

    for (final entry in mipmaps.entries) {
      final folder = entry.key;
      final double size = entry.value.toDouble();

      final key = UniqueKey();

      // We wrap the widget in a RepaintBoundary
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: RepaintBoundary(
                key: key,
                child: AppLogo(size: size, flatCorners: true),
              ),
            ),
          ),
        ),
      );

      // Wait for rendering
      await tester.pump();

      // Get the RepaintBoundary
      final RenderRepaintBoundary boundary =
          tester.renderObject(find.byKey(key));
      
      await tester.runAsync(() async {
        // Convert to image
        final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();

        // Save to path
        final file = File('android/app/src/main/res/$folder/ic_launcher.png');
        await file.create(recursive: true);
        await file.writeAsBytes(pngBytes);
        debugPrint('Generated: ${file.path} ($size x $size)');
      });
    }
  });
}
