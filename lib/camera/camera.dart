import 'package:camera/camera.dart' as camera;
import 'package:camera_view_mask/flash_mode.dart';
import 'package:camera_view_mask/mask/camera_mask_base_builder.dart';
import 'package:camera_view_mask/mask/mask.dart';
import 'package:flutter/material.dart';

import 'camera_flash_mode.dart';
import 'camera_photo_button.dart';
import 'theme/camera_theme.dart';

typedef OnClose = Function();
typedef CameraMaskBuilder = Widget Function(Mask mask);

class Camera extends StatelessWidget {
  final GlobalKey? previewKey;

  final camera.CameraController controller;

  final OnClose? onClose;
  final OnTakePhoto? onTakePhoto;
  final OnChangeFlashMode? onChangeFlashMode;

  final List<Mask> masks;
  final CameraMaskBuilder cameraMaskBuilder;

  final CameraTheme theme;

  const Camera({
    super.key,
    this.previewKey,
    required this.controller,
    this.theme = defaultCameraTheme,
    this.masks = const <Mask>[],
    this.cameraMaskBuilder = cameraMaskBaseBuilder,
    this.onClose,
    this.onTakePhoto,
    this.onChangeFlashMode,
  });

  @override
  Widget build(BuildContext context) {
    final backButton = theme.backButton;
    final photoButton = theme.photoButton;
    final flashButton = theme.flashButton;

    final defaultFlashMode = switch (controller.value.flashMode) {
      camera.FlashMode.auto => FlashMode.auto,
      camera.FlashMode.off => FlashMode.off,
      camera.FlashMode.always => FlashMode.on,
      camera.FlashMode.torch => FlashMode.on,
    };

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                key: const Key("camera_preview"),
                child: camera.CameraPreview(
                  key: previewKey,
                  controller,
                ),
              ),
              for (final mask in masks)
                Positioned.fill(
                  child: cameraMaskBuilder(mask),
                ),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: const EdgeInsets.only(top: 30),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  child: GestureDetector(
                    key: const Key("camera_close"),
                    onTap: onClose,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: backButton,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 42),
                        child: SizedBox(
                          width: 90,
                          height: 90,
                          key: const Key("camera_change_flash_light"),
                          child: CameraFlashMode(
                            flashMode: defaultFlashMode,
                            onChangeFlashMode: onChangeFlashMode,
                            color: flashButton,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 42),
                        child: CameraPhotoButton(
                          key: const Key("camera_take_photo"),
                          color: photoButton,
                          onTakePhoto: onTakePhoto,
                        ),
                      ),
                      const SizedBox(
                        width: 90,
                        height: 90,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
