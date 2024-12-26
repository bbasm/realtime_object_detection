import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_v2/tflite_v2.dart';

class ScanController extends GetxController {
  CameraController? cameraController;
  late List<CameraDescription> cameras;

  var isCameraInitialized = false.obs;
  var isModelLoaded = false.obs;
  var detectedLabel = 'Detecting...'.obs;

  var x = 0.0.obs, y = 0.0.obs, w = 0.0.obs, h = 0.0.obs;
  var label = "".obs;

  int cameraCount = 0;

  @override
  void onInit() {
    super.onInit();
    initCamera();
    initTFLite();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    Tflite.close();
    super.dispose();
  }

  Future<void> initCamera() async {
    if (await Permission.camera.request().isGranted) {
      try {
        cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          cameraController = CameraController(
            cameras[0],
            ResolutionPreset.medium,
          );

          await cameraController?.initialize();

          cameraController?.startImageStream((image) {
            cameraCount++;
            if (cameraCount % 10 == 0) {
              objectDetector(image);
            }
          });

          isCameraInitialized(true);
        }
      } catch (e) {
        print("Error initializing camera: $e");
      }
    } else {
      print("Camera permission denied.");
    }
  }

  Future<void> initTFLite() async {
    try {
      String? result = await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
        numThreads: 1,
        useGpuDelegate: false,
      );
      if (result != null) {
        isModelLoaded(true);
      }
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<void> objectDetector(CameraImage image) async {
    if (!isModelLoaded.value) return;

    try {
      var results = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((e) => e.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 1,
        threshold: 0.4,
      );

      print("Detection results: $results"); // Debug log

      if (results != null && results.isNotEmpty) {
        var detectedObject = results.first;

        if (detectedObject.containsKey('rect')) {
          x.value = (detectedObject['rect']['x'] ?? 0).toDouble();
          y.value = (detectedObject['rect']['y'] ?? 0).toDouble();
          w.value = (detectedObject['rect']['w'] ?? 0).toDouble();
          h.value = (detectedObject['rect']['h'] ?? 0).toDouble();
        } else {
          x.value = y.value = w.value = h.value = 0.0; // Reset values
          print("Bounding box data missing in detection results.");
        }

        String result = detectedObject['label'] as String;
        detectedLabel.value = result.replaceAll(RegExp(r'^\d+\s*'), '');
        label.value = detectedObject['label'].toString();
      } else {
        detectedLabel.value = 'Detecting...';
        x.value = y.value = w.value = h.value = 0.0; // Reset values
      }
    } catch (e) {
      print("Error during detection: $e");
    }
  }
}
