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
          return const Center(child: CircularProgressIndicator());
        }

        final size = MediaQuery.of(context).size;
        final previewSize = controller.cameraController!.value.previewSize!;
        final previewWidth = previewSize.width;
        final previewHeight = previewSize.height;

        return Column(
          children: [
            Stack(
              children: [
                // Camera Preview
                AspectRatio(
                  aspectRatio: previewHeight / previewWidth,
                  child: CameraPreview(controller.cameraController!),
                ),

                // Bounding Box Overlay
                if (controller.label.isNotEmpty &&
                    controller.w.value > 0 &&
                    controller.h.value > 0)
                  Positioned(
                    left: controller.x.value * size.width,
                    top: controller.y.value * size.height,
                    width: controller.w.value * size.width,
                    height: controller.h.value * size.height,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 3),
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          color: Colors.green,
                          padding: const EdgeInsets.all(2),
                          child: Text(
                            controller.label.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(16),
                color: Colors.black.withOpacity(0.7),
                child: Text(
                  controller.detectedLabel.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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
