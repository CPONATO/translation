// lib/utils/image_utils.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart';

class ImageUtils {
  // FIX: Đổi return type thành Future<ui.Image>
  static Future<ui.Image> decodeImageFromFile(File file) async {
    final Uint8List bytes = await file.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  static Future<Size> getImageSize(File file) async {
    final image = await decodeImageFromFile(file);
    return Size(image.width.toDouble(), image.height.toDouble());
  }

  static Future<File> compressImage(
    File file, {
    int maxWidth = 1920,
    int maxHeight = 1080,
    int quality = 85,
  }) async {
    // This is a placeholder implementation
    // In a real app, you'd use packages like image or flutter_image_compress
    return file;
  }

  // Helper method để decode image từ bytes
  static Future<ui.Image> decodeImageFromList(Uint8List bytes) async {
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  // Helper method để get image bytes
  static Future<Uint8List> getImageBytes(File file) async {
    return await file.readAsBytes();
  }
}
