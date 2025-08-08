import 'package:flutter/material.dart';
import '../models/block_type.dart';
import 'app_theme.dart';

class BlockColors {
  static Map<BlockType, Color> get colors => {
        BlockType.loadImage: AppTheme.blockColors['loadImage']!,
        BlockType.grayscale: AppTheme.blockColors['grayscale']!,
        BlockType.blur: AppTheme.blockColors['blur']!,
        BlockType.brightness: AppTheme.blockColors['brightness']!,
        BlockType.display: AppTheme.blockColors['display']!,
        BlockType.merge: Colors.orange,
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
    BlockType.merge: '병합',
  };

  static String getTitle(BlockType type) {
    return titles[type] ?? '알 수 없음';
  }
}
