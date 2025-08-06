import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';

class ImageAlgorithms {
  static Future<ui.Image> createSampleImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    // 간단한 그라데이션 이미지 생성
    const rect = Rect.fromLTWH(0, 0, 200, 200);
    final gradient = ui.Gradient.linear(
      const Offset(0, 0),
      const Offset(200, 200),
      [Colors.red, Colors.blue, Colors.green],
    );

    paint.shader = gradient;
    canvas.drawRect(rect, paint);

    // 원 몇 개 추가
    paint.shader = null;
    paint.color = Colors.yellow;
    canvas.drawCircle(const Offset(50, 50), 20, paint);

    paint.color = Colors.purple;
    canvas.drawCircle(const Offset(150, 150), 30, paint);

    final picture = recorder.endRecording();
    return await picture.toImage(200, 200);
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
    final ui.Codec codec = await ui.instantiateImageCodec(
      pixels.buffer.asUint8List(),
      targetWidth: width,
      targetHeight: height,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
}
