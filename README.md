# CameraViewMask package


<br>![flutter_widget_screenshot](/preview/0.jpg "Flutter widget example preview") ![flutter_widget_screenshot](/preview/1.jpg "Flutter widget example preview")

### CameraBloc events:

```dart
OpenCamera
CloseCamera
PauseCamera
ResumeCamera
ChangeFlashMode
AddTakePhotoCallback
RemoveTakePhotoCallback
RemoveAllTakePhotoCallbacks
TakePhoto
AddMask
RemoveMask
RemoveAllMasks
```

### Example:
```dart
import 'package:camera_view_mask/camera_view_mask.dart';

class CameraScreen extends StatelessWidget {

  const CameraScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cameraBloc = BlocProvider.of<CameraBloc>(context, listen: true);
    final cameraTheme = Theme.of(context).application.camera;

    return CameraScreen(
        cameraBloc: cameraBloc,
        theme: cameraTheme,
        onAfterCameraOpenFirstTime: (cameraController) => cameraController
            .lockCaptureOrientation(DeviceOrientation.portraitUp),
      );
  }
}
```
