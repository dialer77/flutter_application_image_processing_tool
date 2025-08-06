import 'package:flutter/material.dart';
import '../models/processing_block.dart';
import '../utils/block_colors.dart';
import '../utils/parameter_utils.dart';

class ProcessingBlockWidget extends StatelessWidget {
  final ProcessingBlock block;
  final int index;
  final VoidCallback onDelete;
  final Function(String, dynamic) onParameterChanged;

  const ProcessingBlockWidget({
    super.key,
    required this.block,
    required this.index,
    required this.onDelete,
    required this.onParameterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = BlockColors.getColor(block.type);
    final title = BlockColors.getTitle(block.type);

    return Card(
      key: ValueKey(block.id),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Row(
          children: [
            const Icon(Icons.drag_handle, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (block.parameters.isNotEmpty) ..._buildParameterControls(),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParameterControls() {
    List<Widget> controls = [];

    block.parameters.forEach((key, value) {
      if (value is double) {
        controls.add(
          Row(
            children: [
              Text('$key: '),
              Expanded(
                child: Slider(
                  value: value,
                  min: ParameterUtils.getParameterMin(block.type, key),
                  max: ParameterUtils.getParameterMax(block.type, key),
                  divisions: 20,
                  label: value.toStringAsFixed(1),
                  onChanged: (newValue) {
                    onParameterChanged(key, newValue);
                  },
                ),
              ),
            ],
          ),
        );
      }
    });

    return controls;
  }
}
