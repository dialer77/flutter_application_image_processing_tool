import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'screens/image_processor_screen.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '블록코딩 이미지 처리',
      theme: AppTheme.lightTheme,
      home: const ImageProcessorScreen(),
    );
  }
}
