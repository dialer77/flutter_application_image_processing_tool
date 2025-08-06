import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class ImageAlgorithms {
  static Future<ui.Image> createSampleImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    // 더 큰 이미지 생성 (400x400)
    const rect = Rect.fromLTWH(0, 0, 400, 400);

    // 배경 그라데이션
    final gradient = ui.Gradient.linear(
      const Offset(0, 0),
      const Offset(400, 400),
      [Colors.blue.shade100, Colors.purple.shade100],
    );

    paint.shader = gradient;
    canvas.drawRect(rect, paint);

    // 다양한 도형들 추가
    paint.shader = null;

    // 빨간 원
    paint.color = Colors.red;
    canvas.drawCircle(const Offset(100, 100), 40, paint);

    // 초록 사각형
    paint.color = Colors.green;
    canvas.drawRect(const Rect.fromLTWH(250, 80, 80, 80), paint);

    // 노란 삼각형 (다각형으로 그리기)
    paint.color = Colors.yellow;
    final path = Path();
    path.moveTo(200, 300);
    path.lineTo(150, 200);
    path.lineTo(250, 200);
    path.close();
    canvas.drawPath(path, paint);

    // 보라색 별 모양
    paint.color = Colors.purple;
    final starPath = Path();
    const center = Offset(320, 320);
    const radius = 30.0;
    for (int i = 0; i < 10; i++) {
      final angle = i * 0.2 * 3.14159;
      final r = i % 2 == 0 ? radius : radius * 0.5;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();
    canvas.drawPath(starPath, paint);

    // 텍스트 추가
    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Sample',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(150, 50));

    final picture = recorder.endRecording();
    return await picture.toImage(400, 400);
  }

  static Future<ui.Image> applyGrayscale(ui.Image image) async {
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return image;

    final Uint8List pixels = byteData.buffer.asUint8List();
    final Uint8List newPixels = Uint8List(pixels.length);

    for (int i = 0; i < pixels.length; i += 4) {
      int r = pixels[i];
      int g = pixels[i + 1];
      int b = pixels[i + 2];
      int a = pixels[i + 3];

      // 그레이스케일 변환
      int gray = (0.299 * r + 0.587 * g + 0.114 * b).round();

      newPixels[i] = gray; // R
      newPixels[i + 1] = gray; // G
      newPixels[i + 2] = gray; // B
      newPixels[i + 3] = a; // A
    }

    return await _createImageFromPixels(newPixels, image.width, image.height);
  }

  static Future<ui.Image> applyBlur(ui.Image image, double intensity) async {
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return image;

    final Uint8List pixels = byteData.buffer.asUint8List();
    final Uint8List newPixels = Uint8List.fromList(pixels);

    // 단순한 평균 블러
    int kernelSize = (intensity * 3).round() + 1;
    if (kernelSize % 2 == 0) kernelSize++;

    for (int y = kernelSize ~/ 2; y < image.height - kernelSize ~/ 2; y++) {
      for (int x = kernelSize ~/ 2; x < image.width - kernelSize ~/ 2; x++) {
        int rSum = 0, gSum = 0, bSum = 0;
        int count = 0;

        for (int ky = -kernelSize ~/ 2; ky <= kernelSize ~/ 2; ky++) {
          for (int kx = -kernelSize ~/ 2; kx <= kernelSize ~/ 2; kx++) {
            int index = ((y + ky) * image.width + (x + kx)) * 4;
            rSum += pixels[index];
            gSum += pixels[index + 1];
            bSum += pixels[index + 2];
            count++;
          }
        }

        int index = (y * image.width + x) * 4;
        newPixels[index] = rSum ~/ count;
        newPixels[index + 1] = gSum ~/ count;
        newPixels[index + 2] = bSum ~/ count;
      }
    }

    return await _createImageFromPixels(newPixels, image.width, image.height);
  }

  static Future<ui.Image> applyBrightness(ui.Image image, double factor) async {
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return image;

    final Uint8List pixels = byteData.buffer.asUint8List();
    final Uint8List newPixels = Uint8List(pixels.length);

    for (int i = 0; i < pixels.length; i += 4) {
      newPixels[i] = (pixels[i] * factor).clamp(0, 255).round(); // R
      newPixels[i + 1] = (pixels[i + 1] * factor).clamp(0, 255).round(); // G
      newPixels[i + 2] = (pixels[i + 2] * factor).clamp(0, 255).round(); // B
      newPixels[i + 3] = pixels[i + 3]; // A
    }

    return await _createImageFromPixels(newPixels, image.width, image.height);
  }

  static Future<ui.Image> _createImageFromPixels(Uint8List pixels, int width, int height) async {
    final Completer<ui.Image> completer = Completer<ui.Image>();

    ui.decodeImageFromPixels(
      pixels,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (ui.Image image) {
        completer.complete(image);
      },
    );

    return completer.future;
  }
}
