// import 'package:camera/camera.dart';
// import 'package:get/get.dart';
// import 'package:permission_handler/permission_handler.dart';

// class ScanController extends GetxController {
//   @override
//   void onInit() {
//     super.onInit();
//     initCamera();
//   }

//   @override
//   void dispose() {
//     cameraController.dispose();
//     super.dispose();
//   }

//   late CameraController cameraController;
//   late List<CameraDescription> cameras;

//   var isCameraInitialized = false.obs;

//   initCamera() async {
//     if (await Permission.camera.request().isGranted &&
//         await Permission.microphone.request().isGranted) {
//       cameras = await availableCameras();

//       cameraController = CameraController(cameras[0], ResolutionPreset.max);

//       await cameraController.initialize();
//       isCameraInitialized(true);
//     } else {
//       print("Permission denied");
//     }
//   }
// }

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {
  CameraController? cameraController; // Nullable controller
  late List<CameraDescription> cameras;

  var isCameraInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    initCamera();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }

  initCamera() async {
    print("Requesting permissions...");
    if (await Permission.camera.request().isGranted &&
        await Permission.microphone.request().isGranted) {
      try {
        cameras = await availableCameras();
        print("Available cameras: ${cameras.length}");
        if (cameras.isNotEmpty) {
          cameraController = CameraController(
            cameras[0],
            ResolutionPreset.max,
          );
          print("Initializing camera...");
          await cameraController!.initialize();
          isCameraInitialized(true);
          print("Camera initialized!");

          
        } else {
          print("No cameras found");
        }
      } catch (e) {
        print("Error initializing camera: $e");
      }
    } else {
      print("Permissions denied");
    }
  }
}
