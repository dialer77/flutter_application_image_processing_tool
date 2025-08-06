import '../block_type.dart';
import 'processing_block_base.dart';
import 'load_image_block.dart';
import 'grayscale_block.dart';
import 'blur_block.dart';
import 'brightness_block.dart';
import 'display_block.dart';

// 블록 팩토리 함수
ProcessingBlock createBlock(BlockType type, String id, [Map<String, dynamic>? parameters]) {
  switch (type) {
    case BlockType.loadImage:
      return LoadImageBlock(id: id, parameters: parameters);
    case BlockType.grayscale:
      return GrayscaleBlock(id: id, parameters: parameters);
    case BlockType.blur:
      return BlurBlock(id: id, parameters: parameters);
    case BlockType.brightness:
      return BrightnessBlock(id: id, parameters: parameters);
    case BlockType.display:
      return DisplayBlock(id: id, parameters: parameters);
  }
}
