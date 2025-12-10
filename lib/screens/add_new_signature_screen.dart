import 'package:flutter/material.dart';
import 'package:bankid_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:bankid_app/providers/language_provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bankid_app/providers/signature_provider.dart';

class AddNewSignatureScreen extends StatefulWidget {
  const AddNewSignatureScreen({super.key});

  @override
  State<AddNewSignatureScreen> createState() => _AddNewSignatureScreenState();
}

class _AddNewSignatureScreenState extends State<AddNewSignatureScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _signatureNameController = TextEditingController();
  late final TabController _tabController;
  final List<Tab> _tabs = const [
    Tab(text: 'Text'),
    Tab(text: 'Image'),
    Tab(text: 'Handwriting'),
  ];

  final TextEditingController _textController = TextEditingController();
  double _textFontSize = 48;
  Color _textColor = const Color(0xFF111827);

  String? _selectedSvgPath;
  Uint8List? _selectedRasterBytes;
  final CropController _cropController = CropController();
  int _targetWidth = 2400;

  final List<Stroke> _strokes = [];
  final List<Stroke> _redo = [];
  double _brushSize = 6;
  Color _brushColor = const Color(0xFF111827);
  Stroke? _currentStroke;
  final Size _canvasSize = const Size(600, 200);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _signatureNameController.dispose();
    _textController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.addNewSignature,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: languageProvider.isRTL ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    Text(
                      l10n.signatureName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF212B36)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _signatureNameController,
                      decoration: InputDecoration(
                        hintText: l10n.enterNameHere,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Colors.black,
                        indicatorColor: Theme.of(context).primaryColor,
                        tabs: _tabs,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 460,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTextTab(context, l10n),
                          _buildImageTab(context, l10n),
                          _buildHandwritingTab(context, l10n),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF212B36)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF37C293),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.saveSignature,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextTab(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: l10n.enterNameHere,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            _textController.text.isEmpty ? l10n.enterNameHere : _textController.text,
            style: TextStyle(
              fontSize: _textFontSize,
              fontStyle: FontStyle.italic,
              color: _textColor,
              fontFamily: 'Rubik',
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Font Size'),
                  Slider(
                    value: _textFontSize,
                    min: 16,
                    max: 96,
                    onChanged: (v) => setState(() => _textFontSize = v),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Color'),
                  Wrap(
                    spacing: 8,
                    children: [
                      _colorDot(const Color(0xFF111827)),
                      _colorDot(const Color(0xFFDC2626)),
                      _colorDot(const Color(0xFF2563EB)),
                      _colorDot(const Color(0xFF10B981)),
                      _colorDot(const Color(0xFF6B7280)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _colorDot(Color c) {
    return GestureDetector(
      onTap: () => setState(() => _textColor = c),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: Colors.black12)),
      ),
    );
  }

  Widget _buildImageTab(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedRasterBytes == null && _selectedSvgPath == null)
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFEFEEF5).withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFEFEEF5), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const HugeIcon(icon: HugeIcons.strokeRoundedImage01, color: Color(0xFF212B36), size: 16),
                  const SizedBox(width: 16),
                  Text(l10n.uploadImages, style: const TextStyle(fontSize: 12, color: Color(0xFF212B36))),
                ],
              ),
            ),
          ),
        if (_selectedRasterBytes != null)
          Expanded(
            child: Crop(
              image: _selectedRasterBytes!,
              controller: _cropController,
              onCropped: (bytes) {
                setState(() {
                  _selectedRasterBytes = bytes;
                });
              },
            ),
          ),
        if (_selectedRasterBytes != null)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _cropController.crop(),
                  child: const Text('Apply Crop'),
                ),
              ),
            ],
          ),
        if (_selectedSvgPath != null)
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE0E0E0), width: 1)),
            alignment: Alignment.center,
            child: SvgPicture.file(File(_selectedSvgPath!), fit: BoxFit.contain),
          ),
        const SizedBox(height: 12),
        if (_selectedRasterBytes != null)
          Row(
            children: [
              const Text('Max Width'),
              Expanded(
                child: Slider(
                  value: _targetWidth.toDouble(),
                  min: 600,
                  max: 3600,
                  divisions: 10,
                  label: _targetWidth.toString(),
                  onChanged: (v) => setState(() => _targetWidth = v.round()),
                ),
              ),
            ],
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (_selectedRasterBytes != null || _selectedSvgPath != null)
              Expanded(
                child: TextButton.icon(
                  style: TextButton.styleFrom(backgroundColor: const Color(0xFFF9E4E7), padding: const EdgeInsets.symmetric(vertical: 7), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () {
                    setState(() {
                      _selectedRasterBytes = null;
                      _selectedSvgPath = null;
                    });
                  },
                  icon: const Icon(Icons.close, color: Color(0xFFD01F39)),
                  label: Text(l10n.deleteImage, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFD01F39), height: 2.0)),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildHandwritingTab(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE0E0E0), width: 1)),
          child: Listener(
            onPointerDown: (e) {
              _redo.clear();
              _currentStroke = Stroke(points: [e.localPosition], width: _widthForPressure(e.pressure), color: _brushColor);
              setState(() {});
            },
            onPointerMove: (e) {
              if (_currentStroke != null) {
                _currentStroke!.points.add(e.localPosition);
                _currentStroke = Stroke(points: List.of(_currentStroke!.points), width: _widthForPressure(e.pressure), color: _brushColor);
                setState(() {});
              }
            },
            onPointerUp: (e) {
              if (_currentStroke != null) {
                _strokes.add(_currentStroke!);
                _currentStroke = null;
                setState(() {});
              }
            },
            child: CustomPaint(
              painter: _SignaturePainter(strokes: _strokes, current: _currentStroke, bgColor: const Color(0x00000000)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Brush Size'),
                  Slider(
                    value: _brushSize,
                    min: 1,
                    max: 24,
                    onChanged: (v) => setState(() => _brushSize = v),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Color'),
                  Wrap(
                    spacing: 8,
                    children: [
                      _brushColorDot(const Color(0xFF111827)),
                      _brushColorDot(const Color(0xFFDC2626)),
                      _brushColorDot(const Color(0xFF2563EB)),
                      _brushColorDot(const Color(0xFF10B981)),
                      _brushColorDot(const Color(0xFF6B7280)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _undo,
                child: const Text('Undo'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _redoAction,
                child: const Text('Redo'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _clear,
                child: const Text('Clear'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _widthForPressure(double pressure) {
    final p = pressure.clamp(0.0, 1.0);
    return _brushSize * (0.5 + p * 0.5);
  }

  Widget _brushColorDot(Color c) {
    return GestureDetector(
      onTap: () => setState(() => _brushColor = c),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: Colors.black12)),
      ),
    );
  }

  void _undo() {
    if (_strokes.isNotEmpty) {
      _redo.add(_strokes.removeLast());
      setState(() {});
    }
  }

  void _redoAction() {
    if (_redo.isNotEmpty) {
      _strokes.add(_redo.removeLast());
      setState(() {});
    }
  }

  void _clear() {
    _strokes.clear();
    _redo.clear();
    setState(() {});
  }


  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['png', 'jpg', 'jpeg', 'svg']);
    if (result == null) return;
    final f = result.files.single;
    if (f.size > 2 * 1024 * 1024) {
      return;
    }
    final path = f.path;
    if (path == null) return;
    if (path.toLowerCase().endsWith('.svg')) {
      setState(() {
        _selectedSvgPath = path;
        _selectedRasterBytes = null;
      });
    } else {
      final bytes = await File(path).readAsBytes();
      setState(() {
        _selectedRasterBytes = bytes;
        _selectedSvgPath = null;
      });
    }
  }

  Future<void> _onSave() async {
    final title = _signatureNameController.text.trim().isEmpty ? 'Signature' : _signatureNameController.text.trim();
    final provider = Provider.of<SignatureProvider>(context, listen: false);
    final tab = _tabController.index;
    final navigator = Navigator.of(context);
    if (tab == 0) {
      if (_textController.text.trim().isEmpty) return;
      await provider.addTextSignature(title: title, text: _textController.text.trim(), color: _textColor, fontSize: _textFontSize);
      navigator.pop();
    } else if (tab == 1) {
      if (_selectedSvgPath != null) {
        final svgString = await File(_selectedSvgPath!).readAsString();
        await provider.addSvgSignature(title: title, svgString: svgString);
        navigator.pop();
        return;
      }
      if (_selectedRasterBytes != null) {
        await provider.addImageBytesSignature(title: title, bytes: _selectedRasterBytes!, targetMaxWidth: _targetWidth, forcePng: true);
        navigator.pop();
      }
    } else {
      if (_strokes.isEmpty) return;
      await provider.addHandwritingSignature(title: title, strokes: _strokes, canvasSize: _canvasSize);
      navigator.pop();
    }
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Stroke> strokes;
  final Stroke? current;
  final Color bgColor;
  _SignaturePainter({required this.strokes, required this.current, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = bgColor..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bg);
    for (final s in strokes) {
      final p = Paint()
        ..color = s.color
        ..strokeWidth = s.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      for (int i = 1; i < s.points.length; i++) {
        canvas.drawLine(s.points[i - 1], s.points[i], p);
      }
    }
    if (current != null) {
      final p = Paint()
        ..color = current!.color
        ..strokeWidth = current!.width
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      for (int i = 1; i < current!.points.length; i++) {
        canvas.drawLine(current!.points[i - 1], current!.points[i], p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) {
    return oldDelegate.strokes != strokes || oldDelegate.current != current || oldDelegate.bgColor != bgColor;
  }
}
