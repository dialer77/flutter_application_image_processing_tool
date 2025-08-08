import 'dart:ui' as ui;
import '../block_type.dart';
import 'processing_block_base.dart';

// 병합 블록: 그래프 실행기에서 바이트 단위로 처리되며,
// 체인 실행에서는 입력 이미지를 변경하지 않고 그대로 전달합니다.
class MergeBlock extends ProcessingBlock {
  MergeBlock({
    required super.id,
    Map<String, dynamic>? parameters,
    super.result,
  }) : super(
          type: BlockType.merge,
          parameters: parameters ?? const {},
        );

  @override
  Future<ProcessingBlockResult> executeBlock(ui.Image? currentImage, ui.Image? originalImage) async {
    // 체인 모드에서는 변경 없이 통과
    return ProcessingBlockResult(currentImage, originalImage);
  }

  @override
  ProcessingBlock copyWith({
    String? id,
    Map<String, dynamic>? parameters,
    ProcessingBlockResult? result,
  }) {
    return MergeBlock(
      id: id ?? this.id,
      parameters: parameters ?? this.parameters,
      result: result ?? this.result,
    );
  }
}
