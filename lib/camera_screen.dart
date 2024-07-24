import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'bloc/camera_bloc.dart';
import 'camera/camera.dart';
import 'camera/theme/camera_theme.dart';
import 'mask/mask.dart';

export 'camera/camera.dart';

typedef AfterCameraOpenFirstTime = Function(CameraController);

class CameraScreen extends StatefulWidget {
  final CameraBloc cameraBloc;
  final CameraTheme theme;

  final AfterCameraOpenFirstTime? onAfterCameraOpenFirstTime;
  final OnClose? onClose;

  const CameraScreen({
    super.key,
    required this.cameraBloc,
    this.theme = defaultCameraTheme,
    this.onAfterCameraOpenFirstTime,
    this.onClose,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  late final CameraBloc cameraBloc;
  late StreamSubscription<CameraState> cameraBlocSubscription;

  late final GlobalKey cameraPreviewKey;
  late final Size cameraPreviewSize;
  CameraController? cameraController;

  List<Mask>? cameraMasks;

  late final StreamController<bool> isReadyController;
  late final Stream<bool> isReadyStream;
  late final StreamSubscription<bool> isReadySubscription;

  late final StreamController<bool> blinkVisibleController;
  late final Stream<bool> blinkVisibleStream;

  late final StreamController<double> blinkOpacityController;
  late final Stream<double> blinkOpacityStream;

  @override
  void initState() {
    super.initState();

    cameraPreviewKey = GlobalKey();

    cameraBloc = widget.cameraBloc;

    isReadyController = StreamController<bool>();
    isReadyStream = isReadyController.stream.asBroadcastStream();

    isReadySubscription = isReadyStream.listen((isReady) async {
      if (!isReady) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final cameraPreview =
            cameraPreviewKey.currentContext?.findRenderObject() as RenderBox;
        cameraPreviewSize = cameraPreview.size;

        final defaultMask = Mask(
          title: 'default',
          offset: const Offset(0, 90),
          size: Size(
            cameraPreviewSize.width,
            cameraPreviewSize.height - 260,
          ),
          border: Border.all(
            color: const Color(0xFFffffff).withOpacity(0.3),
          ),
          borderRadius: 12,
        );
        cameraBloc.add(AddMask(mask: defaultMask));
      });

      isReadySubscription.cancel();
    });

    blinkVisibleController = StreamController<bool>();
    blinkVisibleStream = blinkVisibleController.stream.asBroadcastStream();

    blinkOpacityController = StreamController<double>();
    blinkOpacityStream = blinkOpacityController.stream.asBroadcastStream();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController =
        cameraBloc.state.cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      cameraBloc.add(const ResumeCamera());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    bool? isFirstStateAfterCameraOpen;

    cameraBloc.add(const OpenCamera());
    cameraBlocSubscription = cameraBloc.stream.listen((state) async {
      if (state.isCameraOpen) {
        if (!mounted) return;

        final defaultCameraController = state.cameraController;
        if (defaultCameraController == null) return;

        cameraController = defaultCameraController;

        if (isFirstStateAfterCameraOpen ?? true) {
          final afterCameraOpenFirstTimeCallback =
              widget.onAfterCameraOpenFirstTime;
          if (afterCameraOpenFirstTimeCallback != null) {
            afterCameraOpenFirstTimeCallback(defaultCameraController);
          }

          Future(() => cameraController?.pausePreview());
          isFirstStateAfterCameraOpen = false;
        }

        cameraMasks = state.masks;

        isReadyController.add(true);
      }

      if (!state.isCameraOpen) {
        cameraController = null;
        isReadyController.add(false);
      }

      if (state.isTakePhotoInProgress) blinkVisibleController.add(true);
      if (!state.isTakePhotoInProgress) blinkOpacityController.add(0);
    });
  }

  @override
  dispose() {
    isReadyController.add(false);
    isReadyController.close();

    blinkVisibleController.close();
    blinkOpacityController.close();

    cameraBlocSubscription.cancel();

    cameraController = null;
    cameraBloc.add(const CloseCamera());

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: isReadyStream,
      initialData: false,
      builder: (context, snapshot) {
        final isReady = snapshot.data;
        if (isReady == null || !isReady) return Container();

        final cameraController = this.cameraController;
        if (cameraController == null) return Container();

        return Stack(
          children: [
            Positioned.fill(
              child: Camera(
                key: const Key("camera"),
                previewKey: cameraPreviewKey,
                theme: widget.theme,
                controller: cameraController,
                masks: cameraMasks ?? [],
                onTakePhoto: () => cameraBloc.add(TakePhoto(
                  maxWidth: cameraPreviewSize.width,
                  maxHeight: cameraPreviewSize.height,
                )),
                onChangeFlashMode: (mode) =>
                    cameraBloc.add(ChangeFlashMode(flashMode: mode)),
                onClose: onClose,
              ),
            ),
            Positioned.fill(
              child: StreamBuilder<bool>(
                initialData: false,
                stream: blinkVisibleStream,
                builder: (context, snapshot) {
                  final visible = snapshot.data!;
                  if (visible) blinkOpacityController.add(1);
                  return Visibility(
                    visible: visible,
                    child: StreamBuilder<double>(
                      initialData: 1,
                      stream: blinkOpacityStream,
                      builder: (context, snapshot) {
                        final opacity = snapshot.data!;
                        return AnimatedOpacity(
                          opacity: opacity,
                          duration: const Duration(milliseconds: 100),
                          onEnd: () => opacity == 0
                              ? blinkVisibleController.add(false)
                              : blinkOpacityController.add(0),
                          child: Container(
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> onClose() async {
    final callback = widget.onClose;
    if (callback == null) return;
    callback();
  }
}
