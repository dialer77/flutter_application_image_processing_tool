import 'dart:ui' as ui;
import '../models/processing_block.dart';

class ImageProcessor {
  static Future<ProcessingResult> executeBlocks(List<ProcessingBlock> blocks) async {
    if (blocks.isEmpty) {
      return ProcessingResult(null, null);
    }

    ui.Image? currentImage;
    ui.Image? originalImage;

    for (ProcessingBlock block in blocks) {
      final result = await block.executeBlock(currentImage, originalImage);
      currentImage = result.currentImage;
      originalImage = result.originalImage ?? originalImage;
    }

    return ProcessingResult(originalImage, currentImage);
  }
}

class ProcessingResult {
  final ui.Image? originalImage;
  final ui.Image? processedImage;

  ProcessingResult(this.originalImage, this.processedImage);
}
