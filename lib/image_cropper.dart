import 'dart:typed_data';

import 'package:image/image.dart';

import 'mask/mask.dart';

class ImageCropper {
  static Future<List<int>?> byMask({
    required Uint8List imageBytes,
    required Mask mask,
    required double maxWidth,
    required double maxHeight,
  }) async {
    final image = decodeImage(imageBytes);
    if (image == null) return null;

    final maskTop = mask.offset.dy;
    final maskTopPercent = maskTop / maxHeight * 100;
    final maskTopOfImage = (maskTopPercent / 100) * image.height;

    final maskLeft = mask.offset.dx;
    final maskLeftPercent = maskLeft / maxWidth * 100;
    final maskLeftOfImage = (maskLeftPercent / 100) * image.width;

    final maskWidth = mask.size.width;
    final maskWidthPercent = maskWidth / maxWidth * 100;
    final maskWidthOfImage = (maskWidthPercent / 100) * image.width;

    final maskHeight = mask.size.height;
    final maskHeightPercent = maskHeight / maxHeight * 100;
    final maskHeightOfImage = (maskHeightPercent / 100) * image.height;

    return ImageCropper.byArea(
      image: image,
      top: maskTopOfImage,
      left: maskLeftOfImage,
      width: maskWidthOfImage,
      height: maskHeightOfImage,
    );
  }

  static Future<List<int>?> byArea({
    required Image image,
    required double top,
    required double left,
    required double width,
    required double height,
  }) async {
    final croppedImage = copyCrop(
      image,
      x: left.toInt(),
      y: top.toInt(),
      width: width.toInt(),
      height: height.toInt(),
    );

    return encodeJpg(croppedImage);
  }
}
