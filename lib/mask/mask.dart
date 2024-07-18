import 'package:flutter/material.dart';

class Mask {
  final String? title;

  final Offset offset;
  final Size size;

  final Border border;
  final double borderRadius;

  const Mask({
    this.title,
    this.offset = Offset.zero,
    this.size = Size.zero,
    this.border = const Border(
      top: BorderSide.none,
      right: BorderSide.none,
      bottom: BorderSide.none,
      left: BorderSide.none,
    ),
    this.borderRadius = 0,
  });

  Path toPath() {
    final maskTop = offset.dy;
    final maskLeft = offset.dx;

    final maskWidth = size.width;
    final maskHeight = size.height;

    late Path maskPath;

    // ignore: prefer-conditional-expressions
    if (borderRadius == 0) {
      maskPath = Path()
        ..moveTo(
          maskLeft,
          maskTop,
        )
        ..lineTo(
          maskLeft + maskWidth,
          maskTop,
        )
        ..lineTo(
          maskLeft + maskWidth,
          maskTop + maskHeight,
        )
        ..lineTo(
          maskLeft,
          maskTop + maskHeight,
        )
        ..close();
    } else {
      maskPath = Path()
        ..moveTo(
          maskLeft,
          maskTop + borderRadius,
        )
        ..quadraticBezierTo(
          maskLeft,
          maskTop,
          maskLeft + borderRadius,
          maskTop,
        )
        ..lineTo(
          maskLeft + maskWidth - borderRadius,
          maskTop,
        )
        ..quadraticBezierTo(
          maskLeft + maskWidth,
          maskTop,
          maskLeft + maskWidth,
          maskTop + borderRadius,
        )
        ..lineTo(
          maskLeft + maskWidth,
          maskTop + maskHeight - borderRadius,
        )
        ..quadraticBezierTo(
          maskLeft + maskWidth,
          maskTop + maskHeight,
          maskLeft + maskWidth - borderRadius,
          maskTop + maskHeight,
        )
        ..lineTo(
          maskLeft + borderRadius,
          maskTop + maskHeight,
        )
        ..quadraticBezierTo(
          maskLeft,
          maskTop + maskHeight,
          maskLeft,
          maskTop + maskHeight - borderRadius,
        )
        ..close();
    }

    return maskPath;
  }

  Mask copyWith({
    String? title,
    Offset? offset,
    Size? size,
    Border? border,
    double? borderRadius,
  }) {
    return Mask(
      title: title ?? this.title,
      offset: offset ?? this.offset,
      size: size ?? this.size,
      border: border ?? this.border,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}
