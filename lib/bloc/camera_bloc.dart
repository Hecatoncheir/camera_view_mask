import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart' as camera;
import 'package:camera_view_mask/flash_mode.dart';
import 'package:camera_view_mask/image_cropper.dart';
import 'package:camera_view_mask/mask/mask.dart';
import 'package:equatable/equatable.dart';
import 'package:logging/logging.dart';

part 'camera_event.dart';
part 'camera_state.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  final Logger log;

  CameraBloc()
      : log = Logger("CameraBloc"),
        super(const CameraState()) {
    on<OpenCamera>(onOpenDefaultCamera);
    on<CloseCamera>(onCloseDefaultCamera);
    on<PauseCamera>(onPauseDefaultCamera);
    on<ResumeCamera>(onResumeDefaultCamera);
    on<ChangeFlashMode>(onChangeFlashMode);
    on<AddTakePhotoCallback>(onAddTakePhotoCallback);
    on<RemoveTakePhotoCallback>(onRemoveTakePhotoCallback);
    on<RemoveAllTakePhotoCallbacks>(onRemoveAllTakePhotoCallbacks);
    on<TakePhoto>(onTakePhoto);
    on<AddMask>(onAddMask);
    on<RemoveMask>(onRemoveMask);
    on<RemoveAllMasks>(onRemoveAllMasks);
  }

  Future<void> onOpenDefaultCamera(_, Emitter<CameraState> emit) async {
    final openedCamera = state.cameraController;
    if (openedCamera != null) {
      emit(state.copyWith(
        isCameraOpen: true,
        cameraController: openedCamera,
      ));
      return;
    }

    final cameras = await camera.availableCameras();

    final defaultCameraController = camera.CameraController(
      cameras[0],
      enableAudio: false,
      camera.ResolutionPreset.high,
    );

    await defaultCameraController.initialize();

    emit(state.copyWith(
      isCameraOpen: true,
      cameraController: defaultCameraController,
    ));
  }

  Future<void> onCloseDefaultCamera(_, Emitter<CameraState> emit) async {
    // Прежде чем закрыть камеру нужно что бы виджеты в
    // дереве отреагировали на это до её закрытия.
    emit(state.copyWith(
      isCameraOpen: false,
      cameraController: null,
    ));
    if (state.isCameraOpen) await state.cameraController?.dispose();
  }

  Future<void> onPauseDefaultCamera(_, Emitter<CameraState> emit) async {
    final controller = state.cameraController;
    if (controller == null) return;
    controller.pausePreview();
    emit(state.copyWith(isCameraPaused: true));
  }

  Future<void> onResumeDefaultCamera(_, Emitter<CameraState> emit) async {
    final controller = state.cameraController;
    if (controller == null) return;
    controller.resumePreview();
    emit(state.copyWith(isCameraPaused: false));
  }

  Future<void> onChangeFlashMode(
    ChangeFlashMode event,
    Emitter<CameraState> emit,
  ) async {
    final flashMode = event.flashMode;
    emit(state.copyWith(flashMode: flashMode));
  }

  Future<void> onAddMask(
    AddMask event,
    Emitter<CameraState> emit,
  ) async {
    final mask = event.mask;
    final masks = state.masks.toList();
    masks.remove(mask);
    masks.add(mask);
    emit(state.copyWith(masks: masks));
  }

  Future<void> onRemoveMask(
    RemoveMask event,
    Emitter<CameraState> emit,
  ) async {
    final mask = event.mask;
    final masks = state.masks.toList();
    masks.remove(mask);
    emit(state.copyWith(masks: masks));
  }

  Future<void> onRemoveAllMasks(
    RemoveAllMasks _,
    Emitter<CameraState> emit,
  ) async {
    emit(state.copyWith(masks: <Mask>[]));
  }

  Future<void> onAddTakePhotoCallback(
    AddTakePhotoCallback event,
    Emitter<CameraState> emit,
  ) async {
    final takePhotoCallback = event.callback;
    final takePhotoCallbacks = state.takePhotoCallbacks.toList();
    takePhotoCallbacks.remove(takePhotoCallback);
    takePhotoCallbacks.add(takePhotoCallback);
    emit(state.copyWith(takePhotoCallbacks: takePhotoCallbacks));
  }

  Future<void> onRemoveTakePhotoCallback(
    RemoveTakePhotoCallback event,
    Emitter<CameraState> emit,
  ) async {
    final takePhotoCallback = event.callback;
    final takePhotoCallbacks = state.takePhotoCallbacks.toList();
    takePhotoCallbacks.remove(takePhotoCallback);
    emit(state.copyWith(takePhotoCallbacks: takePhotoCallbacks));
  }

  Future<void> onRemoveAllTakePhotoCallbacks(
    RemoveAllTakePhotoCallbacks _,
    Emitter<CameraState> emit,
  ) async {
    emit(state.copyWith(takePhotoCallbacks: <OnTakePhotoCallback>[]));
  }

  Future<void> onTakePhoto(
    TakePhoto event,
    Emitter<CameraState> emit,
  ) async {
    log.info('TakePhoto event begin.');
    emit(state.copyWith(
      isPhotoReady: false,
      isTakePhotoInProgress: true,
      photoBytes: <int>[],
    ));
    final cameraController = state.cameraController;
    if (cameraController == null) return;
    if (!cameraController.value.isInitialized) return;
    if (cameraController.value.isTakingPicture) return;

    final flashMode = state.flashMode;
    final flash = switch (flashMode) {
      FlashMode.auto => camera.FlashMode.auto,
      FlashMode.on => camera.FlashMode.always,
      FlashMode.off => camera.FlashMode.off,
    };
    await cameraController.setFlashMode(flash);

    const focus = camera.FocusMode.auto;
    await cameraController.setFocusMode(focus);

    const exposureMode = camera.ExposureMode.auto;
    cameraController.setExposureMode(exposureMode);

    final file = await cameraController.takePicture();
    final photoPath = file.path;
    final photoBytes = await file.readAsBytes();

    final maxWidth = event.maxWidth;
    final maxHeight = event.maxHeight;

    final photoByMasks = <Mask, List<int>>{};
    for (final mask in state.masks) {
      final cropPhoto = await ImageCropper.byMask(
        imageBytes: photoBytes,
        mask: mask,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      if (cropPhoto == null) continue;
      photoByMasks.addAll({mask: cropPhoto});
    }

    final takePhotoCallbacks = state.takePhotoCallbacks.toList();
    for (final callback in takePhotoCallbacks) {
      callback(photoPath, photoBytes, photoByMasks);
    }

    emit(state.copyWith(
      isPhotoReady: true,
      isTakePhotoInProgress: false,
      photoBytes: photoBytes,
      photoByMasks: photoByMasks,
    ));

    log.info('TakePhoto event end. Photo bytes length: ${photoBytes.length}');

    emit(state.copyWith(
      isPhotoReady: false,
      isTakePhotoInProgress: false,
      photoBytes: [],
      photoByMasks: {},
    ));
  }
}
