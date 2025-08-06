import 'dart:ui' as ui;
import '../block_type.dart';
import '../../utils/image_algorithms.dart';
import 'processing_block_base.dart';

class BlurBlock extends ProcessingBlock {
  BlurBlock({
    required super.id,
    Map<String, dynamic>? parameters,
  }) : super(
          type: BlockType.blur,
          parameters: parameters ?? {},
        );

  @override
  Future<ProcessingBlockResult> executeBlock(ui.Image? currentImage, ui.Image? originalImage) async {
    if (currentImage == null) {
      return ProcessingBlockResult(null, originalImage);
    }

    double intensity = parameters['강도'] ?? 1.0;
    final processedImage = await ImageAlgorithms.applyBlur(currentImage, intensity);
    return ProcessingBlockResult(processedImage, originalImage);
  }

  @override
  ProcessingBlock copyWith({
    String? id,
    Map<String, dynamic>? parameters,
  }) {
    return BlurBlock(
      id: id ?? this.id,
      parameters: parameters ?? this.parameters,
    );
  }
}
