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

  var cameraCount = 0;

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
    print("Requesting permissions...");
    if (await Permission.camera.request().isGranted) {
      try {
        cameras = await availableCameras();
        print("Available cameras: ${cameras.length}");
        if (cameras.isNotEmpty) {
          cameraController = CameraController(
            cameras[0],
            ResolutionPreset.medium,
          );

          await cameraController?.initialize();

          if (isModelLoaded.value) {
            await cameraController?.startImageStream((image) {
              cameraCount++;
              if (cameraCount % 10 == 0) {
                cameraCount = 0;
                objectDetector(image);
              }
            });
          }

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

  Future<void> initTFLite() async {
    try {
      String? result = await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
        numThreads: 1,
        useGpuDelegate: false,
      );
      if (result != null) {
        print("Model loaded: $result");
        isModelLoaded(true);
      } else {
        print("Failed to load model");
      }
    } catch (e) {
      print("Error loading TFLite model: $e");
    }
  }

  Future<void> objectDetector(CameraImage image) async {
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

      if (results != null && results.isNotEmpty) {
        String result = results.first['label'] as String;
        detectedLabel.value = result.replaceAll(RegExp(r'^\d+\s*'), '');
        print("Detected: ${detectedLabel.value}");
      } else {
        detectedLabel.value = 'Detecting...';
      }
    } catch (e) {
      print("Error during detection: $e");
    }
  }
}
