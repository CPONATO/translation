// lib/screens/vision_screen.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/constants.dart';
import '../models/language_pair.dart';
import '../models/recognition.dart';
import '../services/translation_service.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/custom_snackbar.dart';

class VisionScreen extends StatefulWidget {
  final ImageSource imageSource;
  final LanguagePair languagePair;

  const VisionScreen({
    super.key,
    required this.imageSource,
    required this.languagePair,
  });

  @override
  State<VisionScreen> createState() => _VisionScreenState();
}

class _VisionScreenState extends State<VisionScreen>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final TranslationService _translationService = TranslationService();

  File? _selectedImage;
  ui.Image? _decodedImage;
  List<Recognition> _recognitions = [];
  String _currentDisplayMode = "Translated";
  double _fontSize = 14;
  bool _isProcessing = false;
  double _processingProgress = 0.0;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTranslation();
    _pickAndProcessImage();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: AppConstants.longAnimation,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _initializeTranslation() async {
    try {
      await _translationService.initializeTranslator(widget.languagePair);
    } catch (e) {
      CustomSnackBar.showError(context, 'Failed to initialize translator: $e');
    }
  }

  Future<void> _pickAndProcessImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: widget.imageSource,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _isProcessing = true;
          _processingProgress = 0.2;
        });

        await _decodeImage();
        await _performTextRecognition();
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      CustomSnackBar.showError(context, 'Failed to pick image: $e');
      Navigator.pop(context);
    }
  }

  Future<void> _decodeImage() async {
    if (_selectedImage == null) return;

    try {
      setState(() => _processingProgress = 0.4);
      final bytes = await _selectedImage!.readAsBytes();
      _decodedImage = await decodeImageFromList(bytes);
      setState(() {});
    } catch (e) {
      throw Exception('Failed to decode image: $e');
    }
  }

  Future<void> _performTextRecognition() async {
    if (_selectedImage == null) return;

    try {
      setState(() => _processingProgress = 0.6);

      final inputImage = InputImage.fromFile(_selectedImage!);
      final recognizedText = await _translationService.recognizeTextFromImage(
        inputImage,
      );

      setState(() => _processingProgress = 0.8);
      await _translateRecognizedText(recognizedText);

      setState(() {
        _isProcessing = false;
        _processingProgress = 1.0;
      });
    } catch (e) {
      setState(() => _isProcessing = false);
      CustomSnackBar.showError(context, 'Text recognition failed: $e');
    }
  }

  Future<void> _translateRecognizedText(RecognizedText recognizedText) async {
    _recognitions.clear();

    final lines = <TextLine>[];
    for (final block in recognizedText.blocks) {
      lines.addAll(block.lines);
    }

    for (int i = 0; i < lines.length; i++) {
      try {
        final line = lines[i];
        final translation = await _translationService.translateText(line.text);

        _recognitions.add(
          Recognition(
            translation: translation,
            originalText: line.text,
            boundingBox: line.boundingBox,
          ),
        );

        setState(() {
          _processingProgress = 0.8 + (0.2 * (i + 1) / lines.length);
        });
      } catch (e) {
        // Add original text if translation fails
        _recognitions.add(
          Recognition(
            translation: lines[i].text,
            originalText: lines[i].text,
            boundingBox: lines[i].boundingBox,
          ),
        );
      }
    }
  }

  void _toggleDisplayMode() {
    setState(() {
      _currentDisplayMode =
          _currentDisplayMode == "Original" ? "Translated" : "Original";
    });
  }

  void _extractAndReturnText() {
    final extractedText = _recognitions
        .map(
          (r) =>
              _currentDisplayMode == "Original"
                  ? r.originalText
                  : r.translation,
        )
        .join('\n');

    Navigator.pop(context, extractedText);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: LoadingOverlay(
        isLoading: _isProcessing,
        progress: _processingProgress,
        message: _getLoadingMessage(),
        child: _buildBody(),
      ),
    );
  }

  String _getLoadingMessage() {
    if (_processingProgress < 0.4) return 'Processing image...';
    if (_processingProgress < 0.6) return 'Recognizing text...';
    if (_processingProgress < 0.8) return 'Translating text...';
    return 'Finalizing...';
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppConstants.primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Image Translator',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      actions: [
        if (_recognitions.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.text_fields, color: Colors.white),
            onPressed: _extractAndReturnText,
            tooltip: 'Extract Text',
          ),
      ],
    );
  }

  Widget _buildBody() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Display Mode Toggle
            if (_recognitions.isNotEmpty) _buildDisplayModeToggle(),

            // Image Display
            Expanded(child: _buildImageDisplay()),

            // Font Size Slider
            if (_recognitions.isNotEmpty) _buildFontSizeSlider(),

            // Language Info
            _buildLanguageInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayModeToggle() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spacing),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _DisplayModeButton(
              text: "Original",
              isSelected: _currentDisplayMode == "Original",
              onTap: () => setState(() => _currentDisplayMode = "Original"),
            ),
          ),
          Expanded(
            child: _DisplayModeButton(
              text: "Translated",
              isSelected: _currentDisplayMode == "Translated",
              onTap: () => setState(() => _currentDisplayMode = "Translated"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacing),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child:
            _decodedImage != null
                ? _buildImageWithOverlay()
                : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImageWithOverlay() {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 3.0,
      child: FittedBox(
        child: SizedBox(
          width: _decodedImage!.width.toDouble(),
          height: _decodedImage!.height.toDouble(),
          child: CustomPaint(
            painter: TextOverlayPainter(
              image: _decodedImage!,
              recognitions: _recognitions,
              showOriginal: _currentDisplayMode == "Original",
              fontSize: _fontSize,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 64,
              color: AppConstants.textSecondaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Processing image...',
              style: TextStyle(
                color: AppConstants.textSecondaryColor,
                fontSize: AppConstants.fontSizeMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeSlider() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spacing),
      padding: const EdgeInsets.all(AppConstants.spacing),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Font Size: ${_fontSize.toInt()}',
            style: TextStyle(
              color: AppConstants.textSecondaryColor,
              fontSize: AppConstants.fontSizeSmall,
              fontWeight: FontWeight.w500,
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppConstants.primaryColor,
              inactiveTrackColor: AppConstants.primaryColor.withOpacity(0.3),
              thumbColor: AppConstants.primaryColor,
              overlayColor: AppConstants.primaryColor.withOpacity(0.2),
            ),
            child: Slider(
              value: _fontSize,
              min: 10,
              max: 50,
              divisions: 40,
              onChanged: (value) => setState(() => _fontSize = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageInfo() {
    final sourceInfo =
        AppConstants.languageInfo[widget.languagePair.source.name];
    final targetInfo =
        AppConstants.languageInfo[widget.languagePair.target.name];

    return Container(
      margin: const EdgeInsets.all(AppConstants.spacing),
      padding: const EdgeInsets.all(AppConstants.spacing),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _LanguageInfo(
            flag: sourceInfo?['flag'] ?? '',
            name:
                sourceInfo?['name'] ??
                widget.languagePair.source.name.toUpperCase(),
          ),
          Icon(Icons.arrow_forward, color: AppConstants.primaryColor, size: 20),
          _LanguageInfo(
            flag: targetInfo?['flag'] ?? '',
            name:
                targetInfo?['name'] ??
                widget.languagePair.target.name.toUpperCase(),
          ),
        ],
      ),
    );
  }
}

class _DisplayModeButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _DisplayModeButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.shortAnimation,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius - 2),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppConstants.textSecondaryColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: AppConstants.fontSizeMedium,
          ),
        ),
      ),
    );
  }
}

class _LanguageInfo extends StatelessWidget {
  final String flag;
  final String name;

  const _LanguageInfo({required this.flag, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (flag.isNotEmpty) ...[
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
        ],
        Text(
          name,
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: AppConstants.fontSizeSmall,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class TextOverlayPainter extends CustomPainter {
  final ui.Image image;
  final List<Recognition> recognitions;
  final bool showOriginal;
  final double fontSize;

  TextOverlayPainter({
    required this.image,
    required this.recognitions,
    required this.showOriginal,
    required this.fontSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the image
    canvas.drawImage(image, Offset.zero, Paint());

    if (!showOriginal) {
      // Paint for the overlay background
      final overlayPaint =
          Paint()
            ..color = Colors.white.withOpacity(0.9)
            ..style = PaintingStyle.fill;

      // Paint for the border
      final borderPaint =
          Paint()
            ..color = AppConstants.primaryColor.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;

      for (final recognition in recognitions) {
        // Draw overlay background
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            recognition.boundingBox,
            const Radius.circular(4),
          ),
          overlayPaint,
        );

        // Draw border
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            recognition.boundingBox,
            const Radius.circular(4),
          ),
          borderPaint,
        );

        // Draw translated text
        final textSpan = TextSpan(
          text: recognition.translation,
          style: TextStyle(
            color: AppConstants.textPrimaryColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            shadows: [
              Shadow(
                color: Colors.white,
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
          maxLines: null,
        );

        textPainter.layout(maxWidth: recognition.boundingBox.width);

        final textOffset = Offset(
          recognition.boundingBox.left + 4,
          recognition.boundingBox.top +
              (recognition.boundingBox.height - textPainter.height) / 2,
        );

        textPainter.paint(canvas, textOffset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
