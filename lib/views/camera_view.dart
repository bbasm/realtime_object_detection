import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_object_detection/controller/scan_controller.dart';

class CameraView extends StatelessWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScanController());

    return Scaffold(
      body: Obx(() {
        if (!controller.isCameraInitialized.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final size = MediaQuery.of(context).size;
        final previewSize = controller.cameraController!.value.previewSize!;
        final previewAspectRatio = previewSize.height / previewSize.width;
        const uiHeight = 275.0; // Fixed height for the UI section

        return Stack(
          children: [
            // Camera Preview at the Top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                width: size.width,
                height: size.height - uiHeight, // Space excluding the UI area
                child: OverflowBox(
                  alignment: Alignment.topCenter, // Align the camera to the top
                  child: AspectRatio(
                    aspectRatio: previewAspectRatio,
                    child: CameraPreview(controller.cameraController!),
                  ),
                ),
              ),
            ),
            // Bottom UI Area
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: uiHeight,
                color: Colors.grey[200],
                child: Center(
                  child: Text(
                    "Add your UI here",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}