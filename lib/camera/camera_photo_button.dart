import 'dart:math';

import 'package:flutter/material.dart';

typedef OnTakePhoto = Function();

class CameraPhotoButton extends StatelessWidget {
  final Color color;
  final OnTakePhoto? onTakePhoto;

  const CameraPhotoButton({
    super.key,
    required this.color,
    this.onTakePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTakePhoto,
      child: CustomPaint(
        painter: PhotoButtonPainter(color: color),
        child: const SizedBox(
          width: 80,
          height: 80,
        ),
      ),
    );
  }
}

class PhotoButtonPainter extends CustomPainter {
  final Color color;

  const PhotoButtonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final borderCirclePath = Path()
      ..addArc(
        Rect.fromCircle(
          center: Offset(width / 2, width / 2),
          radius: width / 2,
        ),
        pi / 2,
        pi * 2,
      );
    canvas.drawPath(
      borderCirclePath,
      borderPaint,
    );

    final circlePaint = Paint()..color = color;
    final circlePath = Path()
      ..addArc(
        Rect.fromCircle(
          center: Offset(width / 2, width / 2),
          radius: (width - 10) / 2,
        ),
        pi / 2,
        pi * 2,
      );
    canvas.drawPath(circlePath, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
