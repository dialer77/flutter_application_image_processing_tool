import 'dart:ui' as ui;
import '../models/processing_block.dart';
import '../models/block_type.dart';

class ImageProcessor {
  static Future<ProcessingResult> executeBlocks(List<ProcessingBlock> blocks) async {
    if (blocks.isEmpty) {
      return ProcessingResult(null, null);
    }

    ui.Image? currentImage;
    ui.Image? originalImage;

    for (ProcessingBlock block in blocks) {
      final result = await block.executeBlock(currentImage, originalImage);

      // 이미지 로드 블록인 경우 원본 이미지 설정
      if (block.type == BlockType.loadImage) {
        // 기존 이미지가 없을 때만 새로 설정
        originalImage ??= result.currentImage;
        currentImage = result.currentImage;
      } else {
        currentImage = result.currentImage;
        originalImage = result.originalImage ?? originalImage;
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
