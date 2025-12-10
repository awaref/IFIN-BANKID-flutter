import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image/image.dart' as img;

enum SignatureType { text, image, handwriting, svg }

class SignatureItem {
  final String id;
  final String title;
  final SignatureType type;
  final String filePath;
  final DateTime createdAt;
  final int width;
  final int height;
  final bool transparent;

  SignatureItem({
    required this.id,
    required this.title,
    required this.type,
    required this.filePath,
    required this.createdAt,
    required this.width,
    required this.height,
    required this.transparent,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type.name,
        'filePath': filePath,
        'createdAt': createdAt.toIso8601String(),
        'width': width,
        'height': height,
        'transparent': transparent,
      };

  static SignatureItem fromJson(Map<String, dynamic> json) => SignatureItem(
        id: json['id'] as String,
        title: json['title'] as String,
        type: SignatureType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => SignatureType.image,
        ),
        filePath: json['filePath'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        width: json['width'] as int,
        height: json['height'] as int,
        transparent: (json['transparent'] as bool?) ?? true,
      );
}

class SignatureProvider extends ChangeNotifier {
  static const _prefsKey = 'signatures';
  final List<SignatureItem> _items = [];

  List<SignatureItem> get items => List.unmodifiable(_items);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    _items
      ..clear()
      ..addAll(raw.map((e) => SignatureItem.fromJson(jsonDecode(e))));
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _items.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<Directory> _ensureSignaturesDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final signaturesDir = Directory('${dir.path}/signatures');
    if (!await signaturesDir.exists()) {
      await signaturesDir.create(recursive: true);
    }
    return signaturesDir;
  }

  Future<void> deleteById(String id) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final path = _items[idx].filePath;
    _items.removeAt(idx);
    await _persist();
    try {
      final f = File(path);
      if (await f.exists()) {
        await f.delete();
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<SignatureItem> addTextSignature({
    required String title,
    required String text,
    required Color color,
    required double fontSize,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvasSize = const Size(2400, 800);
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height));
    final painter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontStyle: FontStyle.italic,
        fontFamily: 'Rubik',
      ),
    );
    painter.text = textSpan;
    painter.layout(maxWidth: canvasSize.width);
    final dx = (canvasSize.width - painter.width) / 2;
    final dy = (canvasSize.height - painter.height) / 2;
    painter.paint(canvas, Offset(dx, dy));
    final picture = recorder.endRecording();
    final image = await picture.toImage(canvasSize.width.toInt(), canvasSize.height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final signaturesDir = await _ensureSignaturesDir();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final path = '${signaturesDir.path}/$id.png';
    final file = File(path);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    final item = SignatureItem(
      id: id,
      title: title,
      type: SignatureType.text,
      filePath: path,
      createdAt: DateTime.now(),
      width: canvasSize.width.toInt(),
      height: canvasSize.height.toInt(),
      transparent: true,
    );
    _items.add(item);
    await _persist();
    notifyListeners();
    return item;
  }

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
      final cx = cropRect.left.round();
      final cy = cropRect.top.round();
      final cw = cropRect.width.round();
      final ch = cropRect.height.round();
      processed = img.copyCrop(image, x: cx, y: cy, width: cw, height: ch);
    }
    if (targetMaxWidth != null && processed.width > targetMaxWidth) {
      final ratio = targetMaxWidth / processed.width;
      final nh = (processed.height * ratio).round();
      processed = img.copyResize(processed, width: targetMaxWidth, height: nh, interpolation: img.Interpolation.cubic);
    }
    final signaturesDir = await _ensureSignaturesDir();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final outPath = '${signaturesDir.path}/$id.${forcePng ? 'png' : 'jpg'}';
    List<int> outBytes;
    if (forcePng) {
      outBytes = img.encodePng(processed, level: 6);
    } else {
      outBytes = img.encodeJpg(processed, quality: 95);
    }
    final file = File(outPath);
    await file.writeAsBytes(outBytes);
    final item = SignatureItem(
      id: id,
      title: title,
      type: SignatureType.image,
      filePath: outPath,
      createdAt: DateTime.now(),
      width: processed.width,
      height: processed.height,
      transparent: forcePng,
    );
    _items.add(item);
    await _persist();
    notifyListeners();
    return item;
  }

  Future<SignatureItem> addImageBytesSignature({
    required String title,
    required List<int> bytes,
    int? targetMaxWidth,
    bool forcePng = true,
  }) async {
    final image = img.decodeImage(Uint8List.fromList(bytes));
    if (image == null) {
      throw Exception('Unsupported image');
    }
    img.Image processed = image;
    if (targetMaxWidth != null && processed.width > targetMaxWidth) {
      final ratio = targetMaxWidth / processed.width;
      final nh = (processed.height * ratio).round();
      processed = img.copyResize(processed, width: targetMaxWidth, height: nh, interpolation: img.Interpolation.cubic);
    }
    final signaturesDir = await _ensureSignaturesDir();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final outPath = '${signaturesDir.path}/$id.${forcePng ? 'png' : 'jpg'}';
    List<int> outBytes;
    if (forcePng) {
      outBytes = img.encodePng(processed, level: 6);
    } else {
      outBytes = img.encodeJpg(processed, quality: 95);
    }
    final file = File(outPath);
    await file.writeAsBytes(outBytes);
    final item = SignatureItem(
      id: id,
      title: title,
      type: SignatureType.image,
      filePath: outPath,
      createdAt: DateTime.now(),
      width: processed.width,
      height: processed.height,
      transparent: forcePng,
    );
    _items.add(item);
    await _persist();
    notifyListeners();
    return item;
  }

  Future<SignatureItem> addSvgSignature({
    required String title,
    required String svgString,
  }) async {
    final signaturesDir = await _ensureSignaturesDir();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final path = '${signaturesDir.path}/$id.svg';
    final file = File(path);
    await file.writeAsString(svgString);
    final item = SignatureItem(
      id: id,
      title: title,
      type: SignatureType.svg,
      filePath: path,
      createdAt: DateTime.now(),
      width: 0,
      height: 0,
      transparent: true,
    );
    _items.add(item);
    await _persist();
    notifyListeners();
    return item;
  }

  Future<SignatureItem> addHandwritingSignature({
    required String title,
    required List<Stroke> strokes,
    required Size canvasSize,
    Size exportSize = const Size(2400, 800),
    Color background = const Color(0x00000000),
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, exportSize.width, exportSize.height));
    final bgPaint = Paint()
      ..color = background
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, exportSize.width, exportSize.height), bgPaint);
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
    final image = await picture.toImage(exportSize.width.toInt(), exportSize.height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final signaturesDir = await _ensureSignaturesDir();
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final path = '${signaturesDir.path}/$id.png';
    final file = File(path);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    final item = SignatureItem(
      id: id,
      title: title,
      type: SignatureType.handwriting,
      filePath: path,
      createdAt: DateTime.now(),
      width: exportSize.width.toInt(),
      height: exportSize.height.toInt(),
      transparent: true,
    );
    _items.add(item);
    await _persist();
    notifyListeners();
    return item;
  }
}

class Stroke {
  final List<Offset> points;
  final double width;
  final Color color;

  Stroke({required this.points, required this.width, required this.color});
}
