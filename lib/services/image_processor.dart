import 'dart:ui' as ui;
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:collection';
import 'dart:async';
import '../models/processing_block.dart';
import '../models/block_type.dart';
import '../models/graph.dart';
import '../utils/image_algorithms.dart';

class ImageProcessor {
  static Future<ProcessingResult> executeBlocks(List<ProcessingBlock> blocks) async {
    if (blocks.isEmpty) {
      return ProcessingResult(null, null);
    }

    ui.Image? currentImage;
    ui.Image? originalImage;

    for (ProcessingBlock block in blocks) {
      final result = await block.executeBlock(currentImage, originalImage);

      // 이미지 로드 블록인 경우 원본 이미지 설정
      if (block.type == BlockType.loadImage) {
        // 기존 이미지가 없을 때만 새로 설정
        originalImage ??= result.currentImage;
        currentImage = result.currentImage;
      } else {
        currentImage = result.currentImage;
        originalImage = result.originalImage ?? originalImage;
      }
    }

    return ProcessingResult(originalImage, currentImage);
  }

  // ===== 그래프 기반 병렬 실행 =====
  // 병합 규칙: 여러 입력이 들어오면 마지막 완료 입력을 선택
  static Future<Map<String, Uint8List>> executeGraphBytes({
    required List<ProcessingBlock> blocks,
    required List<GraphEdge> edges,
    required Uint8List initialPixels,
    required int width,
    required int height,
    int concurrency = 4,
  }) async {
    // 인접/역인접, 진입차수 계산
    final idToBlock = {for (final b in blocks) b.id: b};
    final followers = <String, List<String>>{}; // from -> [to]
    final indegree = <String, int>{};
    final predecessors = <String, List<String>>{}; // to -> [from]
    for (final b in blocks) {
      followers[b.id] = [];
      indegree[b.id] = 0;
      predecessors[b.id] = [];
    }
    for (final e in edges) {
      followers[e.fromId]!.add(e.toId);
      predecessors[e.toId]!.add(e.fromId);
      indegree[e.toId] = (indegree[e.toId] ?? 0) + 1;
    }

    // 입력 없는 루트 후보: indegree==0
    // 각 루트의 입력은 initialPixels
    final Map<String, Uint8List> results = {};
    final ready = <String>[];
    indegree.forEach((id, deg) {
      if (deg == 0) ready.add(id);
    });

    // 간단한 워커 세마포어
    // 간단한 작업 큐로 동시성 제한
    final Queue<String> readyQ = Queue.of(ready);
    int active = 0;
    int remaining = blocks.length;
    final completer = Completer<void>();

    void tryLaunch() {
      while (active < concurrency && readyQ.isNotEmpty) {
        final nodeId = readyQ.removeFirst();
        active++;
        final block = idToBlock[nodeId]!;
        Future<Uint8List> task;
        if (block.type == BlockType.merge) {
          // 모든 선행 결과를 수집해 병합
          final inputs = <Uint8List>[];
          for (final prevId in predecessors[nodeId]!) {
            final data = results[prevId];
            if (data != null) inputs.add(data);
          }
          task = _runMergeNode(block, width, height, inputs);
        } else {
          final input = () {
            if (predecessors[nodeId]!.isEmpty) return initialPixels;
            for (int i = predecessors[nodeId]!.length - 1; i >= 0; i--) {
              final prevId = predecessors[nodeId]![i];
              final data = results[prevId];
              if (data != null) return data;
            }
            return initialPixels;
          }();
          task = _runNode(block, width, height, input);
        }

        task.then((outBytes) {
          results[nodeId] = outBytes;
          remaining--;
          for (final next in followers[nodeId]!) {
            indegree[next] = (indegree[next] ?? 1) - 1;
            if (indegree[next] == 0) {
              readyQ.add(next);
            }
          }
        }).whenComplete(() {
          active--;
          if (remaining == 0 && active == 0 && readyQ.isEmpty) {
            completer.complete();
          } else {
            tryLaunch();
          }
        });
      }
    }

    tryLaunch();
    await completer.future;
    return results;
  }

  static Future<Uint8List> _runNode(ProcessingBlock block, int width, int height, Uint8List input) async {
    // 블록 타입에 따라 bytes 처리
    return Isolate.run(() {
      switch (block.type) {
        case BlockType.grayscale:
          return ImageAlgorithms.applyGrayscaleBytes(input, width, height);
        case BlockType.blur:
          final intensity = block.parameters['강도'] ?? 1.0;
          return ImageAlgorithms.applyBlurBytes(input, width, height, intensity);
        case BlockType.brightness:
          final factor = block.parameters['밝기'] ?? 1.0;
          return ImageAlgorithms.applyBrightnessBytes(input, width, height, factor);
        case BlockType.display:
        case BlockType.loadImage:
        case BlockType.merge:
          return input;
      }
    });
  }

  static Future<Uint8List> _runMergeNode(ProcessingBlock block, int width, int height, List<Uint8List> inputs) async {
    // 임시 병합: 평균 병합
    return Isolate.run(() => ImageAlgorithms.mergeAverageBytes(inputs, width, height));
  }
}

class ProcessingResult {
  final ui.Image? originalImage;
  final ui.Image? processedImage;

  ProcessingResult(this.originalImage, this.processedImage);
}
