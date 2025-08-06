import '../models/processing_block.dart';
import '../models/block_type.dart';
import '../utils/parameter_utils.dart';

class BlockManager {
  final List<ProcessingBlock> _blocks = [];

  List<ProcessingBlock> get blocks => List.unmodifiable(_blocks);

  void addBlock(BlockType type) {
    final block = ProcessingBlock(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      parameters: ParameterUtils.getDefaultParameters(type),
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
      _blocks[index].parameters[key] = value;
    }
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
