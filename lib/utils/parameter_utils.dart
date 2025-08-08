import 'package:flutter/foundation.dart';
import '../models/block_type.dart';

class ParameterUtils {
  static Map<String, dynamic> getDefaultParameters(BlockType type) {
    switch (type) {
      case BlockType.loadImage:
        return {'imageSource': _getDefaultImageSource()};
      case BlockType.blur:
        return {'강도': 1.0};
      case BlockType.brightness:
        return {'밝기': 1.0};
      case BlockType.merge:
        // 임시 병합: 평균 병합 모드
        return {'mode': 'average'};
      default:
        return {};
    }
  }

  // 플랫폼에 따라 기본 이미지 소스 반환
  static String _getDefaultImageSource() {
    if (kIsWeb) {
      return 'file'; // 웹에서는 파일 선택을 기본값으로
    } else if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
      return 'gallery'; // 모바일에서는 갤러리를 기본값으로
    } else {
      return 'file'; // 데스크톱에서는 파일 선택을 기본값으로
    }
  }

  static double getParameterMin(BlockType type, String parameter) {
    if (type == BlockType.blur && parameter == '강도') return 0.1;
    if (type == BlockType.brightness && parameter == '밝기') return 0.1;
    return 0.0;
  }

  static double getParameterMax(BlockType type, String parameter) {
    if (type == BlockType.blur && parameter == '강도') return 5.0;
    if (type == BlockType.brightness && parameter == '밝기') return 3.0;
    return 1.0;
  }
}
