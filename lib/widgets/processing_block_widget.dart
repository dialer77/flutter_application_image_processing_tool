import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/processing_block.dart';
import '../models/block_type.dart';
import '../utils/block_colors.dart';
import '../utils/parameter_utils.dart';
import '../utils/app_theme.dart';

class ProcessingBlockWidget extends StatelessWidget {
  final ProcessingBlock block;
  final int index;
  final VoidCallback onDelete;
  final Function(String, dynamic) onParameterChanged;
  final VoidCallback? onBlockTap; // 블록 클릭 콜백 추가
  final VoidCallback? onLoadImage; // 이미지 로드 콜백 추가

  const ProcessingBlockWidget({
    super.key,
    required this.block,
    required this.index,
    required this.onDelete,
    required this.onParameterChanged,
    this.onBlockTap, // 블록 클릭 콜백 추가
    this.onLoadImage, // 이미지 로드 콜백 추가
  });

  @override
  Widget build(BuildContext context) {
    final color = BlockColors.getColor(block.type);
    final title = BlockColors.getTitle(block.type);

    return Card(
      key: ValueKey(block.id),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        // 클릭 가능하도록 InkWell 추가
        onTap: onBlockTap, // 블록 클릭 이벤트
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color),
          ),
          child: Row(
            children: [
              const Icon(Icons.drag_handle, color: AppTheme.iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        // 결과 데이터가 있으면 미리보기 아이콘 표시
                        if (block.result != null)
                          const Icon(
                            Icons.preview,
                            color: AppTheme.successButtonColor,
                            size: 16,
                          ),
                      ],
                    ),
                    if (block.parameters.isNotEmpty) ..._buildParameterControls(),
                    // 이미지 로드 블록일 때 로드 버튼 추가
                    if (block.type == BlockType.loadImage) _buildLoadImageButton(),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: AppTheme.deleteIconColor),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 이미지 로드 버튼 위젯
  Widget _buildLoadImageButton() {
    String buttonText = '샘플 이미지 로드';
    IconData buttonIcon = Icons.image;

    // PC가 아닌 경우에만 이미지 소스에 따라 버튼 텍스트와 아이콘 변경
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
      String imageSource = block.parameters['imageSource'] ?? 'sample';
      switch (imageSource) {
        case 'gallery':
          buttonText = '갤러리에서 선택';
          buttonIcon = Icons.photo_library;
          break;
        case 'camera':
          buttonText = '카메라로 촬영';
          buttonIcon = Icons.camera_alt;
          break;
        case 'file':
          buttonText = '파일에서 선택';
          buttonIcon = Icons.folder_open;
          break;
        case 'sample':
        default:
          buttonText = '샘플 이미지 로드';
          buttonIcon = Icons.image;
          break;
      }
    } else {
      // PC에서는 간단한 텍스트
      buttonText = '이미지 로드';
      buttonIcon = Icons.folder_open;
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: ElevatedButton.icon(
        onPressed: onLoadImage,
        icon: Icon(buttonIcon, size: 16),
        label: Text(buttonText),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.successButtonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          minimumSize: const Size(0, 32),
        ),
      ),
    );
  }

  List<Widget> _buildParameterControls() {
    List<Widget> controls = [];

    block.parameters.forEach((key, value) {
      if (value is double) {
        controls.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(key),
              Slider(
                value: value,
                min: ParameterUtils.getParameterMin(block.type, key),
                max: ParameterUtils.getParameterMax(block.type, key),
                onChanged: (newValue) {
                  onParameterChanged(key, newValue);
                },
              ),
            ],
          ),
        );
      } else if (key == 'imageSource' && block.type == BlockType.loadImage) {
        // PC가 아닌 경우에만 이미지 소스 선택 드롭다운 표시
        if (kIsWeb || defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
          controls.add(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('이미지 소스'),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: value as String,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  items: _buildImageSourceItems(),
                  onChanged: (newValue) {
                    if (newValue != null) {
                      onParameterChanged(key, newValue);
                    }
                  },
                ),
              ],
            ),
          );
        }
      }
    });

    return controls;
  }

  // 플랫폼에 따라 이미지 소스 옵션 생성
  List<DropdownMenuItem<String>> _buildImageSourceItems() {
    List<DropdownMenuItem<String>> items = [
      const DropdownMenuItem(value: 'sample', child: Text('샘플 이미지')),
    ];

    if (kIsWeb) {
      // 웹에서는 파일 선택만 지원
      items.add(const DropdownMenuItem(value: 'file', child: Text('파일에서 선택')));
    } else if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
      // 모바일에서는 갤러리와 카메라 지원
      items.add(const DropdownMenuItem(value: 'gallery', child: Text('갤러리에서 선택')));
      items.add(const DropdownMenuItem(value: 'camera', child: Text('카메라로 촬영')));
    }

    return items;
  }
}
