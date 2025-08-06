import '../models/block_type.dart';

class ParameterUtils {
  static Map<String, dynamic> getDefaultParameters(BlockType type) {
    switch (type) {
      case BlockType.blur:
        return {'강도': 1.0};
      case BlockType.brightness:
        return {'밝기': 1.0};
      default:
        return {};
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
