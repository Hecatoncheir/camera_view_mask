import 'package:flutter/widgets.dart';

import 'camera_mask_base.dart';
import 'camera_mask_base_with_backdrop_filter.dart';
import 'mask.dart';

// ignore: avoid-returning-widgets
Widget cameraMaskBaseBuilder(Mask mask) => switch (mask.title) {
      'default' => CameraMaskBaseWithBackdropFilter(
          key: ValueKey(mask),
          mask: mask,
        ),
      _ => CameraMaskBase(
          key: ValueKey(mask),
          mask: mask,
        ),
    };
