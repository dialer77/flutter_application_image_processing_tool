import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../widgets/block_palette.dart';
import '../widgets/block_editor.dart';
import '../widgets/image_preview.dart';
import '../models/processing_block.dart';
import '../models/block_type.dart';
import '../services/block_manager.dart';
import '../services/image_processor.dart';
import '../utils/parameter_utils.dart';

class ImageProcessorScreen extends StatefulWidget {
  const ImageProcessorScreen({super.key});

  @override
  _ImageProcessorScreenState createState() => _ImageProcessorScreenState();
}

class _ImageProcessorScreenState extends State<ImageProcessorScreen> {
  final BlockManager _blockManager = BlockManager();
  ui.Image? _originalImage;
  ui.Image? _processedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('블록코딩 이미지 처리'),
        backgroundColor: Colors.indigo,
      ),
      body: Row(
        children: [
          // 블록 팔레트
          const BlockPalette(),

          // 블록 편집 영역
          Expanded(
            flex: 2,
            child: BlockEditor(
              blocks: _blockManager.blocks,
              onBlockAdded: _addBlock,
              onBlockReordered: _reorderBlocks,
              onBlockDeleted: _deleteBlock,
              onParameterChanged: _updateParameter,
              onExecute: _executeBlocks,
              onClear: _clearBlocks,
            ),
          ),

          // 이미지 미리보기 영역
          Expanded(
            flex: 1,
            child: ImagePreview(
              originalImage: _originalImage,
              processedImage: _processedImage,
            ),
          ),
        ],
      ),
    );
  }

  void _addBlock(BlockType blockType) {
    setState(() {
      _blockManager.addBlock(blockType);
    });
  }

  void _reorderBlocks(int oldIndex, int newIndex) {
    setState(() {
      _blockManager.reorderBlocks(oldIndex, newIndex);
    });
  }

  void _deleteBlock(int index) {
    setState(() {
      _blockManager.removeBlock(index);
    });
  }

  void _updateParameter(int index, String key, dynamic value) {
    setState(() {
      _blockManager.updateBlockParameter(index, key, value);
    });
  }

  void _clearBlocks() {
    setState(() {
      _blockManager.clearBlocks();
      _originalImage = null;
      _processedImage = null;
    });
  }

  Future<void> _executeBlocks() async {
    if (_blockManager.getBlockCount() == 0) return;

    try {
      final result = await ImageProcessor.executeBlocks(_blockManager.blocks);

      setState(() {
        if (result.originalImage != null) {
          _originalImage = result.originalImage;
        }
        if (result.processedImage != null) {
          _processedImage = result.processedImage;
        }
      });
    } catch (e) {
      // 에러 처리
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 처리 중 오류가 발생했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
