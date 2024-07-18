import 'dart:ui';

import 'package:flutter/material.dart';

import 'mask.dart';

class CameraMaskBaseWithBackdropFilter extends StatelessWidget {
  final Mask mask;

  const CameraMaskBaseWithBackdropFilter({
    super.key,
    required this.mask,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BorderMask(mask: mask),
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(
            mask.borderRadius,
          ),
        ),
        child: ClipPath(
          clipper: ClipMask(mask: mask),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 36, // ignore: no-magic-number
              sigmaY: 36, // ignore: no-magic-number
            ),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.5), // ignore: no-magic-number
            ),
          ),
        ),
      ),
    );
  }
}

class ClipMask extends CustomClipper<Path> {
  final Mask mask;

  ClipMask({required this.mask});

  @override
  Path getClip(Size size) {
    final mainPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final maskPath = mask.toPath();

    mainPath.extendWithPath(maskPath, Offset.zero);

    final path = Path.combine(
      PathOperation.difference,
      mainPath,
      maskPath,
    );

    return path;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) => false;
}

class BorderMask extends CustomPainter {
  final Mask mask;
  BorderMask({required this.mask});

  @override
  void paint(Canvas canvas, Size size) {
    final maskPath = mask.toPath();
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = mask.border.top.color
      ..strokeWidth = mask.border.top.width;
    canvas.drawPath(maskPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
