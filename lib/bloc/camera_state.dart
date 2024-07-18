part of 'camera_bloc.dart';

typedef OnTakePhotoCallback = Function(
  String path,
  List<int> bytes,
  Map<Mask, List<int>> croppedPhotoByMask,
);

class CameraState extends Equatable {
  final bool isCameraOpen;
  final bool isCameraPaused;
  final camera.CameraController? cameraController;

  final bool isPhotoReady;
  final bool isTakePhotoInProgress;
  final List<int>? photoBytes;

  final List<Mask> masks;
  final Map<Mask, List<int>> photoByMasks;

  final List<OnTakePhotoCallback> takePhotoCallbacks;

  final FlashMode flashMode;

  const CameraState({
    this.isCameraOpen = false,
    this.isCameraPaused = false,
    this.cameraController,
    this.isPhotoReady = false,
    this.isTakePhotoInProgress = false,
    this.photoBytes,
    this.masks = const [],
    this.photoByMasks = const {},
    this.takePhotoCallbacks = const [],
    this.flashMode = FlashMode.auto,
  });

  CameraState copyWith({
    bool? isCameraOpen,
    bool? isCameraPaused,
    camera.CameraController? cameraController,
    bool? isPhotoReady,
    bool? isTakePhotoInProgress,
    List<int>? photoBytes,
    List<Mask>? masks,
    Map<Mask, List<int>>? photoByMasks,
    List<OnTakePhotoCallback>? takePhotoCallbacks,
    FlashMode? flashMode,
  }) {
    return CameraState(
      isCameraOpen: isCameraOpen ?? this.isCameraOpen,
      isCameraPaused: isCameraPaused ?? this.isCameraPaused,
      cameraController: cameraController ?? this.cameraController,
      isPhotoReady: isPhotoReady ?? this.isPhotoReady,
      isTakePhotoInProgress:
          isTakePhotoInProgress ?? this.isTakePhotoInProgress,
      photoBytes: photoBytes ?? this.photoBytes,
      masks: masks ?? this.masks,
      photoByMasks: photoByMasks ?? this.photoByMasks,
      takePhotoCallbacks: takePhotoCallbacks ?? this.takePhotoCallbacks,
      flashMode: flashMode ?? this.flashMode,
    );
  }

  @override
  List<Object?> get props => [
        isCameraOpen,
        isCameraPaused,
        cameraController,
        isPhotoReady,
        isTakePhotoInProgress,
        photoBytes.hashCode,
        masks.length,
        photoByMasks.length,
        takePhotoCallbacks.length,
        flashMode,
      ];
}
