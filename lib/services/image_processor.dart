import 'dart:ui' as ui;
import 'package:flutter_application_image_processing_tool/utils/image_algorithms.dart';

import '../models/processing_block.dart';
import '../models/block_type.dart';
import '../utils/image_algorithms.dart';

class ImageProcessor {
  static Future<ProcessingResult> executeBlocks(List<ProcessingBlock> blocks) async {
    if (blocks.isEmpty) {
      return ProcessingResult(null, null);
    }

    ui.Image? currentImage;
    ui.Image? originalImage;

    for (ProcessingBlock block in blocks) {
      switch (block.type) {
        case BlockType.loadImage:
          currentImage = await ImageAlgorithms.createSampleImage();
          originalImage ??= currentImage;
          break;

        case BlockType.grayscale:
          if (currentImage != null) {
            currentImage = await ImageAlgorithms.applyGrayscale(currentImage);
          }
          break;

        case BlockType.blur:
          if (currentImage != null) {
            double intensity = block.parameters['강도'] ?? 1.0;
            currentImage = await ImageAlgorithms.applyBlur(currentImage, intensity);
          }
          break;

        case BlockType.brightness:
          if (currentImage != null) {
            double factor = block.parameters['밝기'] ?? 1.0;
            currentImage = await ImageAlgorithms.applyBrightness(currentImage, factor);
          }
          break;

        case BlockType.display:
          // 디스플레이 블록은 결과를 반환하기 위한 마커
          break;
      }
    }

    return ProcessingResult(originalImage, currentImage);
  }
}

class ProcessingResult {
  final ui.Image? originalImage;
  final ui.Image? processedImage;

  ProcessingResult(this.originalImage, this.processedImage);
}
