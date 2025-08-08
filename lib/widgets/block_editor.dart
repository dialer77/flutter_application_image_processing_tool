import 'package:flutter/material.dart';
import '../models/graph.dart';
import '../models/processing_block.dart';
import '../models/block_type.dart';
import '../utils/app_theme.dart';
import 'processing_block_widget.dart';

class BlockEditor extends StatefulWidget {
  final List<ProcessingBlock> blocks;
  final List<GraphEdge> edges;
  final Function(BlockType) onBlockAdded;
  final Function(int, int) onBlockReordered;
  final Function(int) onBlockDeleted;
  final Function(int, String, dynamic) onParameterChanged;
  final Function(int)? onBlockTap;
  final Function(int)? onLoadImage;
  final void Function(String fromId, String toId)? onAddEdge;
  final void Function(String fromId, String toId)? onRemoveEdge;
  final VoidCallback onExecute;
  final VoidCallback onClear;

  const BlockEditor({
    super.key,
    required this.blocks,
    required this.edges,
    required this.onBlockAdded,
    required this.onBlockReordered,
    required this.onBlockDeleted,
    required this.onParameterChanged,
    this.onBlockTap,
    this.onLoadImage,
    this.onAddEdge,
    this.onRemoveEdge,
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
  String? _connectingFromId;
  Offset? _connectingCursor;

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
                                        edges: widget.edges,
                                        positions: Map<String, Offset>.from(_blockPositions),
                                        sizes: Map<String, Size>.from(_blockSizes),
                                        connectingFromId: _connectingFromId,
                                        connectingCursor: _connectingCursor,
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
                                        child: Stack(
                                          children: [
                                            ProcessingBlockWidget(
                                              block: block,
                                              index: index,
                                              onDelete: () => widget.onBlockDeleted(index),
                                              onParameterChanged: (key, value) {
                                                widget.onParameterChanged(index, key, value);
                                              },
                                              onBlockTap: widget.onBlockTap != null ? () => widget.onBlockTap!(index) : null,
                                              onLoadImage: widget.onLoadImage != null ? () => widget.onLoadImage!(index) : null,
                                            ),
                                            // 입력 핀 (좌)
                                            const Positioned(
                                              left: 2,
                                              top: 0,
                                              bottom: 0,
                                              child: Center(
                                                heightFactor: 1,
                                                child: _PinDot(color: AppTheme.borderColor),
                                              ),
                                            ),
                                            // 출력 핀 (우) - 드래그로 연결 시작
                                            Positioned(
                                              right: 2,
                                              top: 0,
                                              bottom: 0,
                                              child: Center(
                                                heightFactor: 1,
                                                child: _PinDot(
                                                  color: AppTheme.activeBorderColor,
                                                  onDragStart: (globalPos) {
                                                    final rb = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
                                                    setState(() {
                                                      _connectingFromId = block.id;
                                                      _connectingCursor = rb?.globalToLocal(globalPos);
                                                    });
                                                  },
                                                  onDragUpdate: (globalPos) {
                                                    final rb = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
                                                    setState(() {
                                                      _connectingCursor = rb?.globalToLocal(globalPos);
                                                    });
                                                  },
                                                  onDragEnd: () {
                                                    if (_connectingFromId == null) return;
                                                    final fromId = _connectingFromId!;
                                                    final cursor = _connectingCursor;
                                                    String? targetId;
                                                    if (cursor != null) {
                                                      double bestDist = 1e9;
                                                      for (final entry in widget.blocks) {
                                                        if (entry.id == fromId) continue;
                                                        final pos2 = _blockPositions[entry.id];
                                                        final sz2 = _blockSizes[entry.id];
                                                        if (pos2 == null || sz2 == null) continue;
                                                        // 입력 핀(좌측) 중심은 블록 좌측에서 약 6px 안쪽
                                                        final inputCenter = Offset(pos2.dx + 6, pos2.dy + sz2.height / 2);
                                                        final d = (inputCenter - cursor).distance;
                                                        if (d < bestDist) {
                                                          bestDist = d;
                                                          targetId = entry.id;
                                                        }
                                                      }
                                                      // 스냅 반경 확대
                                                      if (bestDist < 40 && targetId != null) {
                                                        widget.onAddEdge?.call(fromId, targetId);
                                                      }
                                                    }
                                                    setState(() {
                                                      _connectingFromId = null;
                                                      _connectingCursor = null;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
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
  final List<GraphEdge> edges;
  final Map<String, Offset> positions;
  final Map<String, Size> sizes;
  final String? connectingFromId;
  final Offset? connectingCursor;

  _FreeConnectorPainter({
    required this.blocks,
    required this.edges,
    required this.positions,
    required this.sizes,
    required this.connectingFromId,
    required this.connectingCursor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = AppTheme.borderColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 실제 edges 기반 연결선
    for (final e in edges) {
      final fromPos = positions[e.fromId];
      final toPos = positions[e.toId];
      final fromSize = sizes[e.fromId];
      final toSize = sizes[e.toId];
      if (fromPos == null || toPos == null || fromSize == null || toSize == null) continue;

      final start = Offset(fromPos.dx + fromSize.width - 2, fromPos.dy + fromSize.height / 2);
      final end = Offset(toPos.dx + 2, toPos.dy + toSize.height / 2);
      canvas.drawLine(start, end - const Offset(8, 0), linePaint);
      final Path arrow = Path()
        ..moveTo(end.dx - 8, end.dy - 6)
        ..lineTo(end.dx, end.dy)
        ..lineTo(end.dx - 8, end.dy + 6);
      canvas.drawPath(arrow, linePaint..style = PaintingStyle.fill);
    }

    // 드래그 중 임시 연결선
    if (connectingFromId != null && connectingCursor != null) {
      final fromPos = positions[connectingFromId!];
      final fromSize = sizes[connectingFromId!];
      if (fromPos != null && fromSize != null) {
        final start = Offset(fromPos.dx + fromSize.width - 2, fromPos.dy + fromSize.height / 2);
        canvas.drawLine(start, connectingCursor!, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FreeConnectorPainter oldDelegate) {
    return oldDelegate.positions != positions ||
        oldDelegate.sizes != sizes ||
        oldDelegate.blocks != blocks ||
        oldDelegate.edges != edges ||
        oldDelegate.connectingFromId != connectingFromId ||
        oldDelegate.connectingCursor != connectingCursor;
  }
}

class _PinDot extends StatelessWidget {
  final Color color;
  final void Function(Offset globalPosition)? onDragStart;
  final void Function(Offset globalPosition)? onDragUpdate;
  final VoidCallback? onDragEnd;

  const _PinDot({
    required this.color,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: onDragStart != null ? (d) => onDragStart!(d.globalPosition) : null,
      onPanUpdate: onDragUpdate != null ? (d) => onDragUpdate!(d.globalPosition) : null,
      onPanEnd: onDragEnd != null ? (_) => onDragEnd!() : null,
      child: Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
        ),
      ),
    );
  }
}
