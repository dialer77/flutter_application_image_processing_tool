import 'dart:ui' as ui;
// Removed interactive loading in execute; no extra imports needed
import '../block_type.dart';
import '../../utils/image_algorithms.dart';
import 'processing_block_base.dart';

class LoadImageBlock extends ProcessingBlock {
  LoadImageBlock({
    required super.id,
    Map<String, dynamic>? parameters,
    super.result,
  }) : super(
          type: BlockType.loadImage,
          parameters: parameters ?? {},
        );

  @override
  Future<ProcessingBlockResult> executeBlock(ui.Image? currentImage, ui.Image? originalImage) async {
    // 실행 시에는 외부 다이얼로그를 열지 않음
    // 이미 로드된 이미지(current/original)가 있으면 그것을 사용, 없으면 샘플 생성
    ui.Image? source = currentImage ?? originalImage;
    source ??= await ImageAlgorithms.createSampleImage();
    return ProcessingBlockResult(source, originalImage ?? source);
  }

  @override
  ProcessingBlock copyWith({
    String? id,
    Map<String, dynamic>? parameters,
    ProcessingBlockResult? result,
  }) {
    return LoadImageBlock(
      id: id ?? this.id,
      parameters: parameters ?? this.parameters,
      result: result ?? this.result,
    );
  }
}
