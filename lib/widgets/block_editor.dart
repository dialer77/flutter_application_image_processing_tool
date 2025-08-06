import 'package:flutter/material.dart';
import '../models/processing_block.dart';
import '../models/block_type.dart';
import '../utils/parameter_utils.dart';
import 'processing_block_widget.dart';

class BlockEditor extends StatelessWidget {
  final List<ProcessingBlock> blocks;
  final Function(BlockType) onBlockAdded;
  final Function(int, int) onBlockReordered;
  final Function(int) onBlockDeleted;
  final Function(int, String, dynamic) onParameterChanged;
  final VoidCallback onExecute;
  final VoidCallback onClear;

  const BlockEditor({
    super.key,
    required this.blocks,
    required this.onBlockAdded,
    required this.onBlockReordered,
    required this.onBlockDeleted,
    required this.onParameterChanged,
    required this.onExecute,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '블록 편집기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: onExecute,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      child: const Text('실행'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: onClear,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('초기화'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 블록 편집 영역
          Expanded(
            child: DragTarget<BlockType>(
              onAcceptWithDetails: (details) {
                onBlockAdded(details.data);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: candidateData.isNotEmpty ? Colors.blue : Colors.grey[300]!,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: blocks.isEmpty
                      ? Center(
                          child: Text(
                            '여기에 블록을 드래그하세요',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : ReorderableListView(
                          onReorder: onBlockReordered,
                          children: blocks.asMap().entries.map((entry) {
                            int index = entry.key;
                            ProcessingBlock block = entry.value;

                            return ProcessingBlockWidget(
                              key: ValueKey(block.id),
                              block: block,
                              index: index,
                              onDelete: () => onBlockDeleted(index),
                              onParameterChanged: (key, value) {
                                onParameterChanged(index, key, value);
                              },
                            );
                          }).toList(),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
