import 'dart:ui' as ui;
import '../block_type.dart';
import '../../utils/image_algorithms.dart';
import 'processing_block_base.dart';

class GrayscaleBlock extends ProcessingBlock {
  GrayscaleBlock({
    required super.id,
    Map<String, dynamic>? parameters,
    super.result,
  }) : super(
          type: BlockType.grayscale,
          parameters: parameters ?? {},
        );

  @override
  Future<ProcessingBlockResult> executeBlock(ui.Image? currentImage, ui.Image? originalImage) async {
    if (currentImage == null) {
      return ProcessingBlockResult(null, originalImage);
    }

    final processedImage = await ImageAlgorithms.applyGrayscale(currentImage);
    return ProcessingBlockResult(processedImage, originalImage);
  }

  @override
  ProcessingBlock copyWith({
    String? id,
    Map<String, dynamic>? parameters,
    ProcessingBlockResult? result,
  }) {
    return GrayscaleBlock(
      id: id ?? this.id,
      parameters: parameters ?? this.parameters,
      result: result ?? this.result,
    );
  }
}
