import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../widgets/block_palette.dart';
import '../widgets/block_editor.dart';
import '../widgets/image_preview.dart';
import '../models/block_type.dart';
import '../models/processing_block.dart';
import '../services/block_manager.dart';
// import '../services/image_processor.dart';
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import '../utils/image_algorithms.dart';

class ImageProcessorScreen extends StatefulWidget {
  const ImageProcessorScreen({super.key});

  @override
  _ImageProcessorScreenState createState() => _ImageProcessorScreenState();
}

class _ImageProcessorScreenState extends State<ImageProcessorScreen> {
  final BlockManager _blockManager = BlockManager();
  ui.Image? _originalImage;
  ui.Image? _processedImage;
  ui.Image? _previewImage; // 미리보기 이미지 추가
  bool _isPreviewMode = false; // 미리보기 모드 여부

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이미지 처리'),
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
              edges: _blockManager.edges,
              onBlockAdded: _addBlock,
              onBlockReordered: _reorderBlocks,
              onBlockDeleted: _deleteBlock,
              onParameterChanged: _updateParameter,
              onBlockTap: _onBlockTap, // 블록 클릭 이벤트 추가
              onLoadImage: _onLoadImage, // 이미지 로드 이벤트 추가
              onAddEdge: (fromId, toId) {
                setState(() {
                  _blockManager.addEdge(fromId, toId);
                });
              },
              onRemoveEdge: (fromId, toId) {
                setState(() {
                  _blockManager.removeEdge(fromId, toId);
                });
              },
              onExecute: _executeBlocks,
              onClear: _clearBlocks,
            ),
          ),

          // 이미지 미리보기 영역
          Expanded(
            flex: 1,
            child: ImagePreview(
              originalImage: _originalImage,
              processedImage: _isPreviewMode ? _previewImage : _processedImage,
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
      _clearPreview(); // 블록 삭제 시 미리보기 초기화
    });
  }

  void _updateParameter(int index, String key, dynamic value) {
    setState(() {
      _blockManager.updateBlockParameter(index, key, value);
      _clearPreview(); // 파라미터 변경 시 미리보기 초기화
    });
  }

  // 이미지 로드 버튼 클릭 시 해당 블록만 실행
  void _onLoadImage(int index) async {
    try {
      final block = _blockManager.blocks[index];
      if (block.type != BlockType.loadImage) {
        return;
      }

      // PC에서는 직접 파일 선택 다이얼로그 호출
      if (!kIsWeb && defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS) {
        await _loadImageFromFileDialog(index);
        return;
      }

      // 모바일/웹에서는 기존 방식 사용
      final result = await block.executeBlock(null, null);

      setState(() {
        _originalImage = result.currentImage;
        _processedImage = null;
        _previewImage = null;
      });

      // 결과 저장
      _blockManager.updateBlockResult(index, result);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지가 로드되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 로드 중 오류가 발생했습니다: $e')),
      );
    }
  }

  // PC에서 파일 선택 다이얼로그를 통한 이미지 로드
  Future<void> _loadImageFromFileDialog(int index) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        ui.Image? newImage;

        if (file.path != null) {
          final File imageFile = File(file.path!);
          final Uint8List bytes = await imageFile.readAsBytes();
          newImage = await _decodeImage(bytes);
        }

        if (newImage != null) {
          setState(() {
            _originalImage = newImage;
            _processedImage = null;
            _previewImage = null;
          });

          // 결과 저장
          final result = ProcessingBlockResult(newImage, newImage);
          _blockManager.updateBlockResult(index, result);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미지가 로드되었습니다.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미지를 로드할 수 없습니다.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('파일 선택 중 오류가 발생했습니다: $e')),
      );
    }
  }

  // 바이트 데이터를 ui.Image로 변환
  Future<ui.Image?> _decodeImage(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frameInfo = await codec.getNextFrame();
      return frameInfo.image;
    } catch (e) {
      debugPrint('이미지 디코딩 실패: $e');
      return null;
    }
  }

  // 블록 클릭 시: 실행은 하지 않고, 기존 결과가 있을 때만 미리보기 업데이트
  void _onBlockTap(int index) {
    final result = _blockManager.getBlockResult(index);
    if (result != null) {
      () async {
        final ui.Image displayImage = await ImageAlgorithms.cloneImage(result.currentImage!);
        if (!mounted) return;
        setState(() {
          _previewImage = displayImage; // 복제본으로 미리보기 표시
          _isPreviewMode = true; // 미리보기 모드 활성화
        });
      }();
    }
  }

  // 미리보기 초기화
  void _clearPreview() {
    setState(() {
      _previewImage = null;
      _isPreviewMode = false;
    });
  }

  void _executeBlocks() async {
    try {
      // 이미지가 없으면 샘플 이미지 생성
      if (_originalImage == null) {
        await _loadSampleImage();
        if (_originalImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('이미지를 로드할 수 없습니다.')),
          );
          return;
        }
      }

      // ImageProcessor 사용 대신 순차 실행하며 각 블록 결과 저장
      ui.Image? currentImage = _originalImage;
      ui.Image? originalImage = _originalImage;
      for (int i = 0; i < _blockManager.blocks.length; i++) {
        final block = _blockManager.blocks[i];
        final result = await block.executeBlock(currentImage, originalImage);
        _blockManager.updateBlockResult(i, result);
        currentImage = result.currentImage;
        originalImage = result.originalImage ?? originalImage;
      }

      setState(() {
        _processedImage = currentImage;
        _previewImage = null; // 실행 완료 시 미리보기 초기화
        _isPreviewMode = false; // 실행 모드로 전환
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지 처리가 완료되었습니다.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지 처리 중 오류가 발생했습니다: $e')),
      );
    }
  }

  // 샘플 이미지 로드
  Future<void> _loadSampleImage() async {
    try {
      // ImageAlgorithms에서 샘플 이미지 생성
      final sampleImage = await _createSampleImage();
      setState(() {
        _originalImage = sampleImage;
      });
    } catch (e) {
      debugPrint('샘플 이미지 생성 실패: $e');
    }
  }

  // 샘플 이미지 생성
  Future<ui.Image> _createSampleImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    // 더 큰 이미지 생성 (400x400)
    const rect = Rect.fromLTWH(0, 0, 400, 400);

    // 배경 그라데이션
    final gradient = ui.Gradient.linear(
      const Offset(0, 0),
      const Offset(400, 400),
      [Colors.blue.shade100, Colors.purple.shade100],
    );

    paint.shader = gradient;
    canvas.drawRect(rect, paint);

    // 다양한 도형들 추가
    paint.shader = null;

    // 빨간 원
    paint.color = Colors.red;
    canvas.drawCircle(const Offset(100, 100), 40, paint);

    // 초록 사각형
    paint.color = Colors.green;
    canvas.drawRect(const Rect.fromLTWH(250, 80, 80, 80), paint);

    // 노란 삼각형 (다각형으로 그리기)
    paint.color = Colors.yellow;
    final path = Path();
    path.moveTo(200, 300);
    path.lineTo(150, 200);
    path.lineTo(250, 200);
    path.close();
    canvas.drawPath(path, paint);

    // 보라색 별 모양
    paint.color = Colors.purple;
    final starPath = Path();
    const center = Offset(320, 320);
    const radius = 30.0;
    for (int i = 0; i < 10; i++) {
      final angle = i * 0.2 * 3.14159;
      final r = i % 2 == 0 ? radius : radius * 0.5;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();
    canvas.drawPath(starPath, paint);

    // 텍스트 추가
    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Sample',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(150, 50));

    final picture = recorder.endRecording();
    return await picture.toImage(400, 400);
  }

  void _clearBlocks() {
    setState(() {
      _blockManager.clearBlocks();
      _processedImage = null;
      _previewImage = null;
    });
  }
}
