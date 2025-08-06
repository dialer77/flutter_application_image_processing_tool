import '../models/processing_block.dart';
import '../models/block_type.dart';
import '../utils/parameter_utils.dart';
import 'dart:ui' as ui;

class BlockManager {
  final List<ProcessingBlock> _blocks = [];

  List<ProcessingBlock> get blocks => List.unmodifiable(_blocks);

  void addBlock(BlockType type) {
    final block = createBlock(
      type,
      DateTime.now().millisecondsSinceEpoch.toString(),
      ParameterUtils.getDefaultParameters(type),
    );
    _blocks.add(block);
  }

  void removeBlock(int index) {
    if (index >= 0 && index < _blocks.length) {
      _blocks.removeAt(index);
    }
  }

  void reorderBlocks(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final ProcessingBlock item = _blocks.removeAt(oldIndex);
    _blocks.insert(newIndex, item);
  }

  void updateBlockParameter(int index, String key, dynamic value) {
    if (index >= 0 && index < _blocks.length) {
      final oldBlock = _blocks[index];
      final newParameters = Map<String, dynamic>.from(oldBlock.parameters);
      newParameters[key] = value;
      _blocks[index] = oldBlock.copyWith(parameters: newParameters);
    }
  }

  // 블록 결과 데이터 저장
  void updateBlockResult(int index, ProcessingBlockResult result) {
    if (index >= 0 && index < _blocks.length) {
      final oldBlock = _blocks[index];
      _blocks[index] = oldBlock.copyWith(result: result);
    }
  }

  // 특정 블록의 결과 데이터 가져오기
  ProcessingBlockResult? getBlockResult(int index) {
    if (index >= 0 && index < _blocks.length) {
      return _blocks[index].result;
    }
    return null;
  }

  // 모든 블록의 결과 데이터 초기화
  void clearAllResults() {
    for (int i = 0; i < _blocks.length; i++) {
      final oldBlock = _blocks[i];
      _blocks[i] = oldBlock.copyWith(result: null);
    }
  }

  // 특정 블록의 결과 데이터 초기화
  void clearBlockResult(int index) {
    if (index >= 0 && index < _blocks.length) {
      final oldBlock = _blocks[index];
      _blocks[index] = oldBlock.copyWith(result: null);
    }
  }

  // 블록이 결과 데이터를 가지고 있는지 확인
  bool hasBlockResult(int index) {
    if (index >= 0 && index < _blocks.length) {
      return _blocks[index].result != null;
    }
    return false;
  }

  // 특정 블록까지의 누적 결과 이미지 가져오기 (미리보기용)
  ui.Image? getCumulativeResultImage(int blockIndex) {
    if (blockIndex < 0 || blockIndex >= _blocks.length) {
      return null;
    }

    // 해당 블록까지의 결과를 순차적으로 계산
    ui.Image? currentImage;
    ui.Image? originalImage;

    for (int i = 0; i <= blockIndex; i++) {
      final block = _blocks[i];
      if (block.result != null) {
        currentImage = block.result!.currentImage;
        originalImage = block.result!.originalImage;
      }
    }

    return currentImage;
  }

  void clearBlocks() {
    _blocks.clear();
  }

  bool hasBlockType(BlockType type) {
    return _blocks.any((block) => block.type == type);
  }

  int getBlockCount() {
    return _blocks.length;
  }

  List<ProcessingBlock> getBlocksByType(BlockType type) {
    return _blocks.where((block) => block.type == type).toList();
  }
}
