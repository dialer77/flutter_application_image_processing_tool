import 'block_type.dart';

class ProcessingBlock {
  final String id;
  final BlockType type;
  final Map<String, dynamic> parameters;

  ProcessingBlock({
    required this.id,
    required this.type,
    required this.parameters,
  });

  ProcessingBlock copyWith({
    String? id,
    BlockType? type,
    Map<String, dynamic>? parameters,
  }) {
    return ProcessingBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      parameters: parameters ?? this.parameters,
    );
  }
}
