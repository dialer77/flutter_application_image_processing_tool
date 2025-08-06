import 'package:flutter/material.dart';
import '../models/block_type.dart';
import '../utils/app_theme.dart';
import 'block_template_widget.dart';

class BlockPalette extends StatelessWidget {
  const BlockPalette({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppTheme.paletteBackground,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              '처리 블록',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryText,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: const [
                BlockTemplateWidget(type: BlockType.loadImage),
                BlockTemplateWidget(type: BlockType.grayscale),
                BlockTemplateWidget(type: BlockType.blur),
                BlockTemplateWidget(type: BlockType.brightness),
                BlockTemplateWidget(type: BlockType.display),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
