import 'package:camera_view_mask/flash_mode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef OnChangeFlashMode = Function(FlashMode);

class CameraFlashMode extends StatelessWidget {
  final FlashMode flashMode;
  final Color? color;
  final OnChangeFlashMode? onChangeFlashMode;

  const CameraFlashMode({
    super.key,
    this.flashMode = FlashMode.auto,
    this.onChangeFlashMode,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    const itemExtent = 32.0;
    return CupertinoPicker(
      itemExtent: itemExtent,
      onSelectedItemChanged: (mode) => _onModeChanged(FlashMode.values[mode]),
      children: [
        for (final mode in FlashMode.values)
          switch (mode) {
            FlashMode.auto => Icon(Icons.flash_auto, color: color),
            FlashMode.on => Icon(Icons.flash_on, color: color),
            FlashMode.off => Icon(Icons.flash_off, color: color),
          },
      ],
    );
  }

  Future<void> _onModeChanged(FlashMode mode) async {
    final callback = onChangeFlashMode;
    if (callback == null) return;
    callback(mode);
  }
}
