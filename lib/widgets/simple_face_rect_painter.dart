import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

// Simple face rectangle painter for debugging
class SimpleFaceRectPainter extends CustomPainter {
  final Face face;
  final Size imageSize;
  final Color color;

  SimpleFaceRectPainter({
    required this.face,
    required this.imageSize,
    this.color = Colors.green,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final boundingBox = face.boundingBox;
    
    // Calculate scaling factors
    final double scaleX = size.width / imageSize.width;
    final double scaleY = size.height / imageSize.height;
    
    // Transform coordinates
    final double left = boundingBox.left * scaleX;
    final double top = boundingBox.top * scaleY;
    final double right = boundingBox.right * scaleX;
    final double bottom = boundingBox.bottom * scaleY;
    
    // Mirror horizontally for front camera
    final double mirroredLeft = size.width - right;
    final double mirroredRight = size.width - left;
    
    final rect = Rect.fromLTRB(mirroredLeft, top, mirroredRight, bottom);
    
    // Draw rectangle
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawRect(rect, paint);
    
    // Draw corner markers
    final cornerLength = 20.0;
    final cornerPaint = Paint()
      ..color = color
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.top + cornerLength),
      cornerPaint,
    );
    
    // Top-right corner
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right - cornerLength, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      cornerPaint,
    );
    
    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left, rect.bottom - cornerLength),
      cornerPaint,
    );
    
    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right - cornerLength, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(SimpleFaceRectPainter oldDelegate) {
    return face != oldDelegate.face;
  }
}
