import 'package:flutter/painting.dart';

part 'default_camera_theme.dart';

class CameraTheme {
  final Color backButton;
  final Color flashButton;
  final Color photoButton;

  const CameraTheme({
    required this.backButton,
    required this.flashButton,
    required this.photoButton,
  });
}
