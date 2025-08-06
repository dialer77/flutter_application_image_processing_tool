import 'dart:ui' as ui;
import '../block_type.dart';
import '../../utils/image_algorithms.dart';
import 'processing_block_base.dart';

class LoadImageBlock extends ProcessingBlock {
  LoadImageBlock({
    required super.id,
    Map<String, dynamic>? parameters,
  }) : super(
          type: BlockType.loadImage,
          parameters: parameters ?? {},
        );

  @override
  Future<ProcessingBlockResult> executeBlock(ui.Image? currentImage, ui.Image? originalImage) async {
    final newImage = await ImageAlgorithms.createSampleImage();
    return ProcessingBlockResult(newImage, originalImage ?? newImage);
  }

  @override
  ProcessingBlock copyWith({
    String? id,
    Map<String, dynamic>? parameters,
  }) {
    return LoadImageBlock(
      id: id ?? this.id,
      parameters: parameters ?? this.parameters,
    );
  }
}
