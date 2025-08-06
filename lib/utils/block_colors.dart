import 'package:flutter/material.dart';
import '../models/block_type.dart';

class BlockColors {
  static const Map<BlockType, Color> colors = {
    BlockType.loadImage: Colors.green,
    BlockType.grayscale: Colors.blue,
    BlockType.blur: Colors.orange,
    BlockType.brightness: Colors.purple,
    BlockType.display: Colors.red,
  };

  static Color getColor(BlockType type) {
    return colors[type] ?? Colors.grey;
  }

  static const Map<BlockType, String> titles = {
    BlockType.loadImage: '이미지 로드',
    BlockType.grayscale: '그레이스케일',
    BlockType.blur: '블러 효과',
    BlockType.brightness: '밝기 조절',
    BlockType.display: '결과 보기',
  };

  static String getTitle(BlockType type) {
    return titles[type] ?? '알 수 없음';
  }
}
