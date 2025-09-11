import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Detection Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FaceDetectionTestScreen(),
    );
  }
}

class FaceDetectionTestScreen extends StatefulWidget {
  @override
  _FaceDetectionTestScreenState createState() => _FaceDetectionTestScreenState();
}

class _FaceDetectionTestScreenState extends State<FaceDetectionTestScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isDetecting = false;
  List<Face> _detectedFaces = [];

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.15,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        print('❌ No cameras available');
        return;
      }

      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
        _startFaceDetection();
      }
    } catch (e) {
      print('❌ Camera initialization error: $e');
    }
  }

  void _startFaceDetection() {
    if (_cameraController == null || !_isCameraInitialized) {
      print('❌ Camera not ready for face detection');
      return;
    }

    try {
      print('🚀 Starting face detection stream...');
      _cameraController!.startImageStream((CameraImage image) {
        if (_isDetecting || !mounted) return;
        
        _isDetecting = true;
        _processImage(image).catchError((error) {
          print('Error in image processing: $error');
          _isDetecting = false;
        });
      });
      print('✅ Face detection stream started successfully!');
    } catch (e) {
      print('💥 Failed to start image stream: $e');
    }
  }

  Future<void> _processImage(CameraImage image) async {
    try {
      print('🔍 Processing image: ${image.width}x${image.height}, format: ${image.format.group}');
      
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) {
        print('❌ Failed to convert camera image!');
        _isDetecting = false;
        return;
      }

      print('✅ Image converted successfully, running face detection...');

      final faces = await _faceDetector.processImage(inputImage);
      
      print('🔍 Face detection result: ${faces.length} faces found');
      
      if (faces.isNotEmpty) {
        final face = faces.first;
        print('✅ Face details:');
        print('   - Bounding box: ${face.boundingBox}');
        print('   - Head rotation Y: ${face.headEulerAngleY}');
        print('   - Head rotation Z: ${face.headEulerAngleZ}');
        print('   - Smiling probability: ${face.smilingProbability}');
        print('   - Left eye open probability: ${face.leftEyeOpenProbability}');
        print('   - Right eye open probability: ${face.rightEyeOpenProbability}');
        print('   - Landmarks: ${face.landmarks.length}');
      }
      
      if (mounted) {
        setState(() {
          _detectedFaces = faces;
        });
      }
    } catch (e) {
      print('💥 Error processing image: $e');
    } finally {
      _isDetecting = false;
    }
  }

  InputImage? _convertCameraImage(CameraImage image) {
    try {
      print('🔄 Converting camera image: ${image.width}x${image.height}, format: ${image.format.group}');

      final Size imageSize = Size(
        image.width.toDouble(),
        image.height.toDouble(),
      );

      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      final InputImageRotation imageRotation = _rotationIntToImageRotation(
        camera.sensorOrientation,
      );

      // Handle different image formats properly
      InputImageFormat inputImageFormat;
      Uint8List bytes;
      int bytesPerRow;

      if (image.format.group == ImageFormatGroup.yuv420) {
        // For YUV420 format, combine all planes
        final WriteBuffer allBytes = WriteBuffer();
        for (final Plane plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        bytes = allBytes.done().buffer.asUint8List();
        inputImageFormat = InputImageFormat.yuv420;
        bytesPerRow = image.planes[0].bytesPerRow;
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        // For BGRA8888 format, use the first plane
        bytes = image.planes[0].bytes;
        inputImageFormat = InputImageFormat.bgra8888;
        bytesPerRow = image.planes[0].bytesPerRow;
      } else {
        // Fallback to YUV420
        final WriteBuffer allBytes = WriteBuffer();
        for (final Plane plane in image.planes) {
          allBytes.putUint8List(plane.bytes);
        }
        bytes = allBytes.done().buffer.asUint8List();
        inputImageFormat = InputImageFormat.yuv420;
        bytesPerRow = image.planes[0].bytesPerRow;
      }

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: imageSize,
          rotation: imageRotation,
          format: inputImageFormat,
          bytesPerRow: bytesPerRow,
        ),
      );
    } catch (e) {
      print('💥 Error converting camera image: $e');
      return null;
    }
  }

  InputImageRotation _rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _cameraController == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Face Detection Test')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Initializing camera...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Face Detection Test'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          // Camera preview
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            ),
          ),
          // Face detection overlay
          if (_detectedFaces.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(
                painter: FaceDetectionPainter(
                  faces: _detectedFaces,
                  imageSize: Size(
                    _cameraController!.value.previewSize!.height,
                    _cameraController!.value.previewSize!.width,
                  ),
                  previewSize: Size(
                    _cameraController!.value.previewSize!.height,
                    _cameraController!.value.previewSize!.width,
                  ),
                ),
              ),
            ),
          // Status text
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Faces detected: ${_detectedFaces.length}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }
}

class FaceDetectionPainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final Size previewSize;

  FaceDetectionPainter({
    required this.faces,
    required this.imageSize,
    required this.previewSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (faces.isEmpty) return;

    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    for (final face in faces) {
      final boundingBox = face.boundingBox;
      
      // Transform coordinates to match camera preview
      final double scaleX = size.width / imageSize.width;
      final double scaleY = size.height / imageSize.height;
      
      final left = boundingBox.left * scaleX;
      final top = boundingBox.top * scaleY;
      final right = boundingBox.right * scaleX;
      final bottom = boundingBox.bottom * scaleY;
      
      final rect = Rect.fromLTRB(left, top, right, bottom);
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(FaceDetectionPainter oldDelegate) {
    return faces != oldDelegate.faces;
  }
}
