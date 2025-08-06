import 'dart:ui' as ui;
import '../block_type.dart';

// 추상 기본 클래스
abstract class ProcessingBlock {
  final String id;
  final BlockType type;
  final Map<String, dynamic> parameters;

  ProcessingBlock({
    required this.id,
    required this.type,
    required this.parameters,
  });

  // 각 블록이 구현해야 하는 메서드
  Future<ProcessingBlockResult> executeBlock(ui.Image? currentImage, ui.Image? originalImage);

  ProcessingBlock copyWith({
    String? id,
    Map<String, dynamic>? parameters,
  });
}

// 처리 결과를 담는 클래스
class ProcessingBlockResult {
  final ui.Image? currentImage;
  final ui.Image? originalImage;

  ProcessingBlockResult(this.currentImage, this.originalImage);
}
