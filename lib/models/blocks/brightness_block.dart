import 'dart:ui' as ui;
import '../block_type.dart';
import '../../utils/image_algorithms.dart';
import 'processing_block_base.dart';

class BrightnessBlock extends ProcessingBlock {
  BrightnessBlock({
    required super.id,
    Map<String, dynamic>? parameters,
  }) : super(
          type: BlockType.brightness,
          parameters: parameters ?? {},
        );

  @override
  Future<ProcessingBlockResult> executeBlock(ui.Image? currentImage, ui.Image? originalImage) async {
    if (currentImage == null) {
      return ProcessingBlockResult(null, originalImage);
    }

    double factor = parameters['밝기'] ?? 1.0;
    final processedImage = await ImageAlgorithms.applyBrightness(currentImage, factor);
    return ProcessingBlockResult(processedImage, originalImage);
  }

  @override
  ProcessingBlock copyWith({
    String? id,
    Map<String, dynamic>? parameters,
  }) {
    return BrightnessBlock(
      id: id ?? this.id,
      parameters: parameters ?? this.parameters,
    );
  }
}
