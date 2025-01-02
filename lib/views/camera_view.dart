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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          backgroundColor: const Color.fromARGB(255, 223, 120, 156),
          title: const Text(
            'Realtime Object Detection',
            style: TextStyle(fontSize: 17, color: Colors.white),
          ),
        ),
      ),
      body: Obx(() {
        if (!controller.isCameraInitialized.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final previewSize = controller.cameraController!.value.previewSize!;
        final aspectRatio = previewSize.height / previewSize.width;

        return Stack(
          children: [
            // camera preview
            AspectRatio(
              aspectRatio: aspectRatio,
              child: CameraPreview(controller.cameraController!),
            ),

            // label
            Positioned(
              top: 515,
              left: 18,
              child: Container(
                width: 350,
                height: 50,
                decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 223, 120, 156).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
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
            ),

            // bounding box overlay (if u use it)
            if (controller.label.isNotEmpty &&
                controller.w.value > 0 &&
                controller.h.value > 0)
              Positioned(
                left: controller.x.value * MediaQuery.of(context).size.width,
                top: controller.y.value * MediaQuery.of(context).size.height,
                width: controller.w.value * MediaQuery.of(context).size.width,
                height: controller.h.value * MediaQuery.of(context).size.height,
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
        );
      }),
    );
  }
}
