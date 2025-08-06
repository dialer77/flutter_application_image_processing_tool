import 'dart:ui' as ui;
import '../block_type.dart';
import 'processing_block_base.dart';

class DisplayBlock extends ProcessingBlock {
  DisplayBlock({
    required super.id,
    Map<String, dynamic>? parameters,
  }) : super(
          type: BlockType.display,
          parameters: parameters ?? {},
        );

  @override
  Future<ProcessingBlockResult> executeBlock(ui.Image? currentImage, ui.Image? originalImage) async {
    // 디스플레이 블록은 이미지를 변경하지 않고 그대로 반환
    return ProcessingBlockResult(currentImage, originalImage);
  }

  @override
  ProcessingBlock copyWith({
    String? id,
    Map<String, dynamic>? parameters,
  }) {
    return DisplayBlock(
      id: id ?? this.id,
      parameters: parameters ?? this.parameters,
    );
  }
}
