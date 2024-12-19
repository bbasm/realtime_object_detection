import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_object_detection/controller/scan_controller.dart';


class CameraView extends StatelessWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScanController()); // Ensures a single instance

    return Scaffold(
      body: Obx(() {
        if (!controller.isCameraInitialized.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final size = MediaQuery.of(context).size;
        final deviceRatio = size.width / size.height;
        final cameraAspectRatio = controller.cameraController!.value.aspectRatio;

        // If the camera's aspect ratio is greater than the device's aspect ratio (wider than the screen)
        if (cameraAspectRatio > deviceRatio) {
          // Fit width and add black bars on top and bottom (letterboxing)
          return Center(
            child: SizedBox(
              width: size.width,
              height: size.width / cameraAspectRatio,
              child: CameraPreview(controller.cameraController!),
            ),
          );
        } else {
          // If the camera is taller than the screen, fit height and add black bars on the sides (pillarboxing)
          return Center(
            child: SizedBox(
              height: size.height,
              width: size.height * cameraAspectRatio,
              child: CameraPreview(controller.cameraController!),
            ),
          );
        }
      }),
    );
  }
}




// class CameraView extends StatelessWidget {
//   const CameraView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GetBuilder<ScanController>(
//           init: ScanController(),
//           builder: (controller) {
//             return controller.isCameraInitialized.value
//                 ? SizedBox(
//                     width: MediaQuery.of(context).size.width,
//                     height: MediaQuery.of(context).size.height,
//                     child: CameraPreview(controller.cameraController),
//                   )
//                 : const Center(
//                     child: Text("Loading Preview..."),
//                   );
//           }),
//     );
//   }
// }
