import 'package:flutter/material.dart';
import '../models/processing_block.dart';
import '../models/block_type.dart';
import '../utils/app_theme.dart';
import 'processing_block_widget.dart';

class BlockEditor extends StatefulWidget {
  final List<ProcessingBlock> blocks;
  final Function(BlockType) onBlockAdded;
  final Function(int, int) onBlockReordered;
  final Function(int) onBlockDeleted;
  final Function(int, String, dynamic) onParameterChanged;
  final Function(int)? onBlockTap;
  final Function(int)? onLoadImage;
  final VoidCallback onExecute;
  final VoidCallback onClear;

  const BlockEditor({
    super.key,
    required this.blocks,
    required this.onBlockAdded,
    required this.onBlockReordered,
    required this.onBlockDeleted,
    required this.onParameterChanged,
    this.onBlockTap,
    this.onLoadImage,
    required this.onExecute,
    required this.onClear,
  });

  @override
  State<BlockEditor> createState() => _BlockEditorState();
}

class _BlockEditorState extends State<BlockEditor> {
  final GlobalKey _canvasKey = GlobalKey();
  final Map<String, Offset> _blockPositions = {};
  final Map<String, Size> _blockSizes = {};
  final Map<String, GlobalKey> _blockKeys = {};
  Offset? _pendingDropPosition;

  @override
  void didUpdateWidget(covariant BlockEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIds = oldWidget.blocks.map((b) => b.id).toSet();
    final newIds = widget.blocks.map((b) => b.id).toSet();
    for (final id in newIds.difference(oldIds)) {
      _blockPositions[id] = _pendingDropPosition ?? _defaultNewBlockPosition();
    }
    for (final id in oldIds.difference(newIds)) {
      _blockPositions.remove(id);
      _blockSizes.remove(id);
      _blockKeys.remove(id);
    }
    _pendingDropPosition = null;
  }

  Offset _defaultNewBlockPosition() {
    if (_blockPositions.isEmpty) return const Offset(24, 24);
    final lastId = widget.blocks.isNotEmpty ? widget.blocks.last.id : _blockPositions.keys.last;
    final lastPos = _blockPositions[lastId] ?? const Offset(24, 24);
    return lastPos + const Offset(300, 0);
  }

  void _updateAllBlockSizesPostFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool changed = false;
      for (final block in widget.blocks) {
        final key = _blockKeys[block.id];
        if (key?.currentContext != null) {
          final Size size = (key!.currentContext!.findRenderObject() as RenderBox).size;
          if (_blockSizes[block.id] != size) {
            _blockSizes[block.id] = size;
            changed = true;
          }
        }
      }
      if (changed && mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.editorBackground,
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryText,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: widget.onExecute,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successButtonColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('실행'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: widget.onClear,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.dangerButtonColor,
                        foregroundColor: Colors.white,
                      ),
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
                final renderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
                if (renderBox != null) {
                  _pendingDropPosition = renderBox.globalToLocal(details.offset);
                }
                widget.onBlockAdded(details.data);
              },
              builder: (context, candidateData, rejectedData) {
                final bool hasDrag = candidateData.isNotEmpty;
                return Container(
                  key: _canvasKey,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: hasDrag ? AppTheme.activeBorderColor : AppTheme.borderColor,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: widget.blocks.isEmpty
                      ? const Center(
                          child: Text(
                            '여기에 블록을 드래그하세요',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.mutedText,
                            ),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            _updateAllBlockSizesPostFrame();
                            return Stack(
                              children: [
                                // 커넥터 페인팅
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(
                                      painter: _FreeConnectorPainter(
                                        blocks: widget.blocks,
                                        positions: Map<String, Offset>.from(_blockPositions),
                                        sizes: Map<String, Size>.from(_blockSizes),
                                      ),
                                    ),
                                  ),
                                ),

                                // 자유 배치 블록
                                ...widget.blocks.asMap().entries.map((entry) {
                                  final int index = entry.key;
                                  final ProcessingBlock block = entry.value;
                                  _blockKeys.putIfAbsent(block.id, () => GlobalKey());

                                  final Offset pos = _blockPositions[block.id] ?? _defaultNewBlockPosition();
                                  final Offset clamped = Offset(
                                    pos.dx.clamp(8.0, constraints.maxWidth - 260),
                                    pos.dy.clamp(8.0, constraints.maxHeight - 140),
                                  );
                                  _blockPositions[block.id] = clamped;

                                  return Positioned(
                                    left: clamped.dx,
                                    top: clamped.dy,
                                    child: GestureDetector(
                                      onPanUpdate: (details) {
                                        setState(() {
                                          final Offset next = _blockPositions[block.id]! + details.delta;
                                          _blockPositions[block.id] = Offset(
                                            next.dx.clamp(8.0, constraints.maxWidth - 260),
                                            next.dy.clamp(8.0, constraints.maxHeight - 140),
                                          );
                                        });
                                      },
                                      child: ConstrainedBox(
                                        key: _blockKeys[block.id],
                                        constraints: const BoxConstraints(
                                          minWidth: 220,
                                          maxWidth: 280,
                                        ),
                                        child: ProcessingBlockWidget(
                                          block: block,
                                          index: index,
                                          onDelete: () => widget.onBlockDeleted(index),
                                          onParameterChanged: (key, value) {
                                            widget.onParameterChanged(index, key, value);
                                          },
                                          onBlockTap: widget.onBlockTap != null ? () => widget.onBlockTap!(index) : null,
                                          onLoadImage: widget.onLoadImage != null ? () => widget.onLoadImage!(index) : null,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
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

class _FreeConnectorPainter extends CustomPainter {
  final List<ProcessingBlock> blocks;
  final Map<String, Offset> positions;
  final Map<String, Size> sizes;

  _FreeConnectorPainter({
    required this.blocks,
    required this.positions,
    required this.sizes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = AppTheme.borderColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < blocks.length - 1; i++) {
      final from = blocks[i];
      final to = blocks[i + 1];
      final fromPos = positions[from.id] ?? const Offset(0, 0);
      final toPos = positions[to.id] ?? const Offset(0, 0);
      final fromSize = sizes[from.id] ?? const Size(240, 120);
      final toSize = sizes[to.id] ?? const Size(240, 120);

      final Offset start = Offset(fromPos.dx + fromSize.width, fromPos.dy + fromSize.height / 2);
      final Offset end = Offset(toPos.dx, toPos.dy + toSize.height / 2);

      // 선
      canvas.drawLine(start, end - const Offset(8, 0), linePaint);

      // 화살표 머리
      final Path arrow = Path();
      final double ay = end.dy;
      final double ax = end.dx;
      arrow.moveTo(ax - 8, ay - 6);
      arrow.lineTo(ax, ay);
      arrow.lineTo(ax - 8, ay + 6);
      canvas.drawPath(arrow, linePaint..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant _FreeConnectorPainter oldDelegate) {
    return oldDelegate.positions != positions || oldDelegate.sizes != sizes || oldDelegate.blocks != blocks;
  }
}
