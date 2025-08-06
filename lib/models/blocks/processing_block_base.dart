import 'dart:ui' as ui;
import '../block_type.dart';

// 추상 기본 클래스
abstract class ProcessingBlock {
  final String id;
  final BlockType type;
  final Map<String, dynamic> parameters;
  final ProcessingBlockResult? result; // 결과 데이터 추가

  ProcessingBlock({
    required this.id,
    required this.type,
    required this.parameters,
    this.result, // 결과 데이터 추가
  });

  // 각 블록이 구현해야 하는 메서드
  Future<ProcessingBlockResult> executeBlock(ui.Image? currentImage, ui.Image? originalImage);

  ProcessingBlock copyWith({
    String? id,
    Map<String, dynamic>? parameters,
    ProcessingBlockResult? result, // 결과 데이터 추가
  });
}

// 처리 결과를 담는 클래스
class ProcessingBlockResult {
  final ui.Image? currentImage;
  final ui.Image? originalImage;

  ProcessingBlockResult(this.currentImage, this.originalImage);
}
