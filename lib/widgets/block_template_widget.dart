import 'package:flutter/material.dart';
import '../models/block_type.dart';
import '../utils/block_colors.dart';

class BlockTemplateWidget extends StatelessWidget {
  final BlockType type;

  const BlockTemplateWidget({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final color = BlockColors.getColor(type);
    final title = BlockColors.getTitle(type);

    return Draggable<BlockType>(
      data: type,
      feedback: Material(
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
          ),
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
