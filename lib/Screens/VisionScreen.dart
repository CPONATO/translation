import 'dart:io';
import 'dart:math';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';

import '../Models/Recognition.dart';

class VisionScreen extends StatefulWidget {
  ImageSource imageSource;
  OnDeviceTranslator onDeviceTranslator;
  VisionScreen(this.imageSource, this.onDeviceTranslator);

  @override
  State<VisionScreen> createState() => _VisionScreenState();
}

class _VisionScreenState extends State<VisionScreen> {
  final ImagePicker picker = ImagePicker();
  File? selectedImage;
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  var resultText = "recognized text here...";
  List<Recognition> recognitions = [];
  TranslateLanguage sourceLang = TranslateLanguage.english;
  TranslateLanguage targetLang = TranslateLanguage.spanish;
  var currentSelection = "Translated";
  double fontSize = 14;
  initState() {
    super.initState();
    chooseImage();
  }

  chooseImage() async {
    final XFile? image = await picker.pickImage(
      source: this.widget.imageSource,
    );
    if (image != null) {
      selectedImage = File(image.path);
      showEditedImage();
      performTextRecognition();
      setState(() {});
    }
  }

  var image;
  showEditedImage() async {
    var bytes = await selectedImage!.readAsBytes();
    image = await decodeImageFromList(bytes);
    setState(() {
      image;
    });
  }

  captureImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
    }
  }

  late RecognizedText recognizedText;
  performTextRecognition() async {
    InputImage inputImage = InputImage.fromFile(selectedImage!);
    recognizedText = await textRecognizer.processImage(inputImage);

    String text = recognizedText.text;
    setState(() {
      resultText = text;
    });
    // performTranslation(text);
    performTranslationLineByLine();
  }

  performTranslationLineByLine() async {
    recognitions.clear();
    for (TextBlock block in recognizedText.blocks) {
      final Rect rect = block.boundingBox;
      final List<Point<int>> cornerPoints = block.cornerPoints;
      final String text = block.text;
      final List<String> languages = block.recognizedLanguages;

      for (TextLine line in block.lines) {
        // Same getters as TextBlock
        recognitions.add(
          Recognition(await performTranslation(line.text), line.boundingBox),
        );
        setState(() {
          recognitions;
        });
        for (TextElement element in line.elements) {
          // Same getters as TextBlock
        }
      }
    }
  }

  performTranslation(String text) async {
    return await this.widget.onDeviceTranslator.translateText(text);
  }

  final modelManager = OnDeviceTranslatorModelManager();
  bool isTranslatorReady = false;
  isModelDownloaded() async {
    print("language code=" + sourceLang.bcpCode);
    bool isSourceDownloaded = await modelManager.isModelDownloaded(
      sourceLang.bcpCode,
    );
    bool isTargetDownloaded = await modelManager.isModelDownloaded(
      targetLang.bcpCode,
    );
    if (isSourceDownloaded && isTargetDownloaded) {
      isTranslatorReady = true;
    } else {
      if (isSourceDownloaded == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloading ' + sourceLang.name)),
        );
        isSourceDownloaded = await modelManager.downloadModel(
          sourceLang.bcpCode,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded ' + sourceLang.name)),
        );
      }

      if (isTargetDownloaded == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloading ' + targetLang.name)),
        );
        isTargetDownloaded = await modelManager.downloadModel(
          targetLang.bcpCode,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded ' + targetLang.name)),
        );
      }

      if (isSourceDownloaded && isTargetDownloaded) {
        isTranslatorReady = true;
      }
    }

    if (isTranslatorReady) {
      this.widget.onDeviceTranslator = OnDeviceTranslator(
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
      );
      performTranslationLineByLine();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 25),
              child: AnimatedToggleSwitch<String>.size(
                textDirection: TextDirection.rtl,
                current: currentSelection,
                values: const ["Original", "Translated"],
                indicatorSize: const Size.fromWidth(130),
                iconBuilder: (value) {
                  return Text(
                    value,
                    style: TextStyle(
                      color:
                          value == currentSelection
                              ? Colors.white
                              : Colors.black,
                    ),
                  );
                },
                borderWidth: 0.0,
                iconAnimationType: AnimationType.onHover,
                style: ToggleStyle(
                  borderColor: Colors.transparent,
                  backgroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(50.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 1.5),
                    ),
                  ],
                ),
                styleBuilder:
                    (i) => ToggleStyle(indicatorColor: Colors.blue.shade900),
                onChanged: (i) => setState(() => currentSelection = i),
              ),
            ),

            Expanded(
              child: Card(
                color: Colors.white,
                margin: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: 20,
                  bottom: 20,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child:
                      image != null
                          ? //Image.file(selectedImage!)
                          FittedBox(
                            child: SizedBox(
                              width: image.width.toDouble(),
                              height: image.height.toDouble(),
                              child: CustomPaint(
                                painter: CustomImagePainter(
                                  image: image,
                                  recognitions: recognitions,
                                  showOriginal:
                                      currentSelection == "Original"
                                          ? true
                                          : false,
                                  fontSize: fontSize,
                                ),
                              ),
                            ),
                          )
                          : Icon(Icons.image, size: 200),
                ),
              ),
            ),

            Slider(
              value: fontSize,
              min: 10,
              max: 50,
              divisions: 40,
              onChanged: (value) {
                setState(() {
                  fontSize = value;
                });
              },
              activeColor: Colors.blue.shade900,
              label: "$fontSize",
            ),
            Container(
              margin: EdgeInsets.only(left: 15, right: 15, top: 0, bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.blue.shade900,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              iconSize: 0,
                              items:
                                  TranslateLanguage.values.map((item) {
                                    return DropdownMenuItem(
                                      value: item,
                                      child: Text(
                                        item.name,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (item) {
                                setState(() {
                                  sourceLang = item!;
                                  isModelDownloaded();
                                });
                              },
                              alignment: Alignment.center,
                              value: sourceLang,
                              dropdownColor: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      color: Colors.blue.shade900,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                              iconSize: 0,
                              items:
                                  TranslateLanguage.values.map((item) {
                                    return DropdownMenuItem(
                                      value: item,
                                      child: Text(
                                        item.name,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (item) {
                                setState(() {
                                  targetLang = item!;
                                  isModelDownloaded();
                                });
                              },
                              alignment: Alignment.center,
                              value: targetLang,
                              dropdownColor: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Expanded(
            //     child: Card(
            //       color: Colors.white,
            //   margin: EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
            //   child: Container(
            //     child: Padding(
            //       padding: const EdgeInsets.all(8.0),
            //       child: SingleChildScrollView(child: Text(resultText)),
            //     ),
            //     width: MediaQuery.of(context).size.width,
            //   ),
            // ))
          ],
        ),
      ),
    );
  }

  double currentValue = 12;
}

class CustomImagePainter extends CustomPainter {
  dynamic image;
  List<Recognition> recognitions;
  bool showOriginal;
  double fontSize;
  CustomImagePainter({
    this.image,
    required this.recognitions,
    required this.showOriginal,
    required this.fontSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    canvas.drawImage(image, Offset.zero, Paint());

    Paint paint = Paint();
    paint.color = Colors.white;
    paint.style = PaintingStyle.fill;
    if (showOriginal == false) {
      recognitions.forEach((item) {
        canvas.drawRect(item.boundingBox, paint);
        TextSpan span = TextSpan(
          text: item.tranlation,
          style: TextStyle(color: Colors.black, fontSize: fontSize),
        );
        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, Offset(item.boundingBox.left, item.boundingBox.top));
      });
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
