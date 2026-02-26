import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

import 'package:bankid_app/services/signature_service.dart';
import 'package:bankid_app/services/api_service.dart';
import 'package:bankid_app/models/signature.dart';
import 'package:bankid_app/config.dart';

class SignatureProvider extends ChangeNotifier {
  final SignatureService _signatureService;

  final List<SignatureItem> _items = [];
  bool _isLoading = false;

  SignatureProvider({SignatureService? signatureService})
    : _signatureService =
          signatureService ??
          SignatureService(apiService: ApiService(baseUrl: AppConfig.baseUrl));

  List<SignatureItem> get items => List.unmodifiable(_items);
  List<SignatureItem> get signatures => items;
  bool get isLoading => _isLoading;

  // ================================
  // LOAD SIGNATURES
  // ================================

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final remoteItems = await _signatureService.getSignatures();
      _items
        ..clear()
        ..addAll(remoteItems);
    } catch (e) {
      debugPrint('Error loading signatures: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ================================
  // FETCH SIGNATURE IMAGE (NEW API)
  // ================================

  Future<Uint8List> getSignatureImageBytes(String signatureId) async {
    try {
      final url = '${AppConfig.baseUrl}/signatures/$signatureId/image';

      return await _signatureService.apiService.getBytes(url);
    } catch (e) {
      debugPrint('Error fetching signature image: $e');
      rethrow;
    }
  }

  Future<Uint8List> getImageBytes(SignatureItem item) async {
    if (item.type == SignatureType.imageUpload ||
        item.type == SignatureType.imageHandwriting) {
      return getSignatureImageBytes(item.id);
    }

    if (item.type == SignatureType.svg && item.imageUrl != null) {
      return await _signatureService.apiService.getBytes(item.imageUrl!);
    }

    throw Exception('Signature type does not support image retrieval');
  }

  // ================================
  // DELETE
  // ================================

  Future<void> deleteSignature(String id) async {
    try {
      await _signatureService.deleteSignature(id);
      _items.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting signature: $e');
      rethrow;
    }
  }

  Future<void> deleteById(String id) => deleteSignature(id);

  // ================================
  // SET DEFAULT
  // ================================

  Future<void> setDefault(String id) async {
    try {
      final updated = await _signatureService.setDefaultSignature(id);

      for (int i = 0; i < _items.length; i++) {
        if (_items[i].id == id) {
          _items[i] = updated;
        } else if (_items[i].isDefault) {
          _items[i] = _items[i].copyWith(isDefault: false);
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error setting default signature: $e');
      rethrow;
    }
  }

  // ================================
  // ADD TEXT SIGNATURE
  // ================================

  Future<SignatureItem> addTextSignature({
    required String title,
    required String text,
  }) async {
    final item = await _signatureService.createSignature(
      name: title,
      type: 'text',
      textValue: text,
    );

    _items.add(item);
    notifyListeners();

    return item;
  }

  // ================================
  // ADD IMAGE SIGNATURE
  // ================================

  Future<SignatureItem> addImageSignature({
    required String title,
    required File source,
    Rect? cropRect,
    int? targetMaxWidth,
    bool forcePng = true,
  }) async {
    final rawBytes = await source.readAsBytes();
    final image = img.decodeImage(rawBytes);

    if (image == null) {
      throw Exception('Unsupported image');
    }

    img.Image processed = image;

    if (cropRect != null) {
      processed = img.copyCrop(
        image,
        x: cropRect.left.round(),
        y: cropRect.top.round(),
        width: cropRect.width.round(),
        height: cropRect.height.round(),
      );
    }

    if (targetMaxWidth != null && processed.width > targetMaxWidth) {
      final ratio = targetMaxWidth / processed.width;
      processed = img.copyResize(
        processed,
        width: targetMaxWidth,
        height: (processed.height * ratio).round(),
        interpolation: img.Interpolation.cubic,
      );
    }

    final filePath = await _saveTempImage(processed, forcePng);

    final item = await _signatureService.createSignature(
      name: title,
      type: 'image_upload',
      filePath: filePath,
    );

    _items.add(item);
    notifyListeners();

    await _cleanupTempFile(filePath);

    return item;
  }

  // ================================
  // ADD HANDWRITING SIGNATURE
  // ================================

  Future<SignatureItem> addHandwritingSignature({
    required String title,
    required List<Stroke> strokes,
    required Size canvasSize,
    Size exportSize = const Size(2400, 800),
    Color background = const Color(0x00000000),
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, exportSize.width, exportSize.height),
    );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, exportSize.width, exportSize.height),
      Paint()..color = background,
    );

    final sx = exportSize.width / canvasSize.width;
    final sy = exportSize.height / canvasSize.height;
    canvas.scale(sx, sy);

    for (final s in strokes) {
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = s.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      for (int i = 1; i < s.points.length; i++) {
        canvas.drawLine(s.points[i - 1], s.points[i], paint);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      exportSize.width.toInt(),
      exportSize.height.toInt(),
    );

    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    final filePath = await _saveRawBytes(bytes!.buffer.asUint8List());

    final item = await _signatureService.createSignature(
      name: title,
      type: 'image_handwriting',
      filePath: filePath,
    );

    _items.add(item);
    notifyListeners();

    await _cleanupTempFile(filePath);

    return item;
  }

  // ================================
  // UTILITIES
  // ================================

  Future<String> _saveTempImage(img.Image image, bool forcePng) async {
    final dir = await _getSignaturesDir();
    final id = DateTime.now().microsecondsSinceEpoch.toString();

    final path = '${dir.path}/$id.${forcePng ? 'png' : 'jpg'}';

    final file = File(path);

    await file.writeAsBytes(
      forcePng
          ? img.encodePng(image, level: 6)
          : img.encodeJpg(image, quality: 95),
    );

    return path;
  }

  Future<String> _saveRawBytes(Uint8List bytes) async {
    final dir = await _getSignaturesDir();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final path = '${dir.path}/$id.png';

    final file = File(path);
    await file.writeAsBytes(bytes);

    return path;
  }

  Future<void> _cleanupTempFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  Future<Directory> _getSignaturesDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final signaturesDir = Directory('${dir.path}/signatures');

    if (!await signaturesDir.exists()) {
      await signaturesDir.create(recursive: true);
    }

    return signaturesDir;
  }
}

// ================================
// STROKE MODEL
// ================================

class Stroke {
  final List<Offset> points;
  final double width;
  final Color color;

  Stroke({required this.points, required this.width, required this.color});
}
