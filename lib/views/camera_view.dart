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
        const uiHeight = 290.0; // Fixed height for the UI section

        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                width: size.width,
                height: size.height - uiHeight,
                child: OverflowBox(
                  alignment: Alignment.topCenter,
                  child: AspectRatio(
                    aspectRatio: previewAspectRatio,
                    child: CameraPreview(controller.cameraController!),
                  ),
                ),
              ),
            ),

            // bottom UI area
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: uiHeight,
                color: Colors.grey[200],
                child: Center(
                  child: Obx(() {
                    return Text(
                      controller.detectedLabel.value,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
