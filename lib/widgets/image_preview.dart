import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../painters/image_painter.dart';

class ImagePreview extends StatelessWidget {
  final ui.Image? originalImage;
  final ui.Image? processedImage;

  const ImagePreview({
    super.key,
    this.originalImage,
    this.processedImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              '미리보기',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                if (originalImage != null) ...[
                  const Text('원본', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(border: Border.all()),
                      child: CustomPaint(
                        painter: ImagePainter(originalImage!),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ],
                if (processedImage != null) ...[
                  const Text('처리된 이미지', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(border: Border.all()),
                      child: CustomPaint(
                        painter: ImagePainter(processedImage!),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
