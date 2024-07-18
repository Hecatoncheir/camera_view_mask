part of 'camera_bloc.dart';

abstract class CameraEvent {
  const CameraEvent();
}

class OpenCamera extends CameraEvent {
  const OpenCamera();
}

class CloseCamera extends CameraEvent {
  const CloseCamera();
}

class PauseCamera extends CameraEvent {
  const PauseCamera();
}

class ResumeCamera extends CameraEvent {
  const ResumeCamera();
}

class ChangeFlashMode extends CameraEvent {
  final FlashMode flashMode;

  const ChangeFlashMode({required this.flashMode});
}

class TakePhoto extends CameraEvent {
  final double maxWidth;
  final double maxHeight;

  const TakePhoto({
    required this.maxWidth,
    required this.maxHeight,
  });
}

class AddTakePhotoCallback extends CameraEvent {
  final OnTakePhotoCallback callback;

  const AddTakePhotoCallback({required this.callback});
}

class RemoveTakePhotoCallback extends CameraEvent {
  final OnTakePhotoCallback callback;

  const RemoveTakePhotoCallback({required this.callback});
}

class RemoveAllTakePhotoCallbacks extends CameraEvent {
  const RemoveAllTakePhotoCallbacks();
}

class AddMask extends CameraEvent {
  final Mask mask;

  const AddMask({required this.mask});
}

class RemoveMask extends CameraEvent {
  final Mask mask;

  const RemoveMask({required this.mask});
}

class RemoveAllMasks extends CameraEvent {
  const RemoveAllMasks();
}
