import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../block_type.dart';
import '../../utils/image_algorithms.dart';
import 'processing_block_base.dart';

class LoadImageBlock extends ProcessingBlock {
  LoadImageBlock({
    required super.id,
    Map<String, dynamic>? parameters,
    super.result,
  }) : super(
          type: BlockType.loadImage,
          parameters: parameters ?? {},
        );

  @override
  Future<ProcessingBlockResult> executeBlock(ui.Image? currentImage, ui.Image? originalImage) async {
    // 파라미터에서 이미지 소스 확인
    String imageSource = parameters['imageSource'] ?? 'sample';

    ui.Image? newImage;

    if (imageSource == 'gallery') {
      // 갤러리에서 이미지 선택 (모바일)
      newImage = await _loadFromGallery();
    } else if (imageSource == 'camera') {
      // 카메라에서 이미지 촬영 (모바일)
      newImage = await _loadFromCamera();
    } else if (imageSource == 'file') {
      // 파일에서 이미지 선택 (웹)
      newImage = await _loadFromFile();
    } else {
      // PC에서는 파일 선택 다이얼로그, 그 외에는 샘플 이미지 생성
      if (kIsWeb || defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
        newImage = await ImageAlgorithms.createSampleImage();
      } else {
        // PC에서는 파일 선택 다이얼로그
        newImage = await _loadFromFile();
      }
    }

    newImage ??= await ImageAlgorithms.createSampleImage();

    return ProcessingBlockResult(newImage, originalImage ?? newImage);
  }

  // 갤러리에서 이미지 로드 (모바일)
  Future<ui.Image?> _loadFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();
        return await _decodeImage(bytes);
      }
    } catch (e) {
      debugPrint('갤러리에서 이미지 로드 실패: $e');
    }
    return null;
  }

  // 카메라에서 이미지 로드 (모바일)
  Future<ui.Image?> _loadFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();
        return await _decodeImage(bytes);
      }
    } catch (e) {
      debugPrint('카메라에서 이미지 로드 실패: $e');
    }
    return null;
  }

  // 파일에서 이미지 로드 (윈도우/웹)
  Future<ui.Image?> _loadFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (kIsWeb) {
          // 웹에서는 bytes를 직접 사용
          if (file.bytes != null) {
            return await _decodeImage(file.bytes!);
          }
        } else {
          // 데스크톱에서는 파일 경로 사용
          if (file.path != null) {
            final File imageFile = File(file.path!);
            final Uint8List bytes = await imageFile.readAsBytes();
            return await _decodeImage(bytes);
          }
        }
      }
    } catch (e) {
      debugPrint('파일에서 이미지 로드 실패: $e');
    }
    return null;
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

  @override
  ProcessingBlock copyWith({
    String? id,
    Map<String, dynamic>? parameters,
    ProcessingBlockResult? result,
  }) {
    return LoadImageBlock(
      id: id ?? this.id,
      parameters: parameters ?? this.parameters,
      result: result ?? this.result,
    );
  }
}
