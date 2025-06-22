import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:translation_ai/Constants.dart';
import 'package:translation_ai/Screens/VisionScreen.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  late OnDeviceTranslator onDeviceTranslator;
  final languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
  final modelManager = OnDeviceTranslatorModelManager();
  bool isTranslatorReady = false;
  TextEditingController inputCon = TextEditingController();
  var resultText = "translated text";
  TranslateLanguage sourceLang = TranslateLanguage.english;
  TranslateLanguage targetLang = TranslateLanguage.spanish;
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  FlutterTts flutterTts = FlutterTts();
  String selectLocaleId = "en_US";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isModelDownloaded();
    _initSpeech();
    getLanguages();
    detectLanguage("hello how are you");
  }

  List<LocaleName> locales = [];
  getLanguages() async {
    locales = await _speechToText.locales();
    locales.forEach((item) {
      print("language = ${item.name}  ${item.localeId}");
    });

    List<dynamic> languages = await flutterTts.getLanguages;
    languages.forEach((item) {
      print("tts language=$item.");
    });

    flutterTts.setLanguage("es-ES");
    await flutterTts.setVoice({"name": "es-es-x-eea-local", "locale": "es-ES"});
    List<dynamic> voices = await flutterTts.getVoices;
    voices.forEach((item) {
      print("tts voice=" + item.toString());
    });
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: selectLocaleId,
    );
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      inputCon.text = result.recognizedWords;
      performTranslation();
    });
  }

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
      onDeviceTranslator = OnDeviceTranslator(
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
      );
      if (Constants.languagesMap.containsKey(sourceLang.name) &&
          isRecognitionSupported(Constants.languagesMap[sourceLang.name]!)) {
        selectLocaleId = Constants.languagesMap[sourceLang.name]!;
      } else {
        showDialog(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text("Speech Recognition"),
                content: Text(
                  'Speech recognition is not avialable ${sourceLang.name}. Kindly download this language in your device to use speech recognition',
                ),
              ),
        );
      }
      flutterTts.setLanguage(Constants.languagesMapTTS[targetLang.name]!);
    }
  }

  isRecognitionSupported(String localeId) {
    return locales.any((item) => item.localeId == localeId);
  }

  performTranslation() async {
    if (isTranslatorReady) {
      resultText = await onDeviceTranslator.translateText(inputCon.text);
      setState(() {
        resultText;
      });
    }
  }

  detectLanguage(String text) async {
    String lang = await languageIdentifier.identifyLanguage(text);
    sourceLang = TranslateLanguage.values.firstWhere((item) {
      return item.bcpCode == lang;
    }, orElse: () => TranslateLanguage.english);
    await isModelDownloaded();
    performTranslation();
    print("language code = " + lang);
  }

  bool isDetection = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Translator', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          Switch(
            value: isDetection,
            onChanged: (value) {
              setState(() {
                isDetection = value;
              });
            },
            activeColor: Colors.green,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      maxLines: 10,
                      decoration: const InputDecoration(
                        hintText: "Enter your text",
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 25),
                      ),
                      controller: inputCon,
                      style: TextStyle(fontSize: 25),
                      onChanged: (text) {
                        if (isDetection) {
                          detectLanguage(text);
                        } else {
                          performTranslation();
                        }
                      },
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            items:
                                TranslateLanguage.values.map((item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(item.name),
                                  );
                                }).toList(),
                            onChanged: (item) {
                              setState(() {
                                sourceLang = item!;
                                isModelDownloaded();
                              });
                            },
                            value: sourceLang,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                            items:
                                TranslateLanguage.values.map((item) {
                                  return DropdownMenuItem(
                                    value: item,
                                    child: Text(item.name),
                                  );
                                }).toList(),
                            onChanged: (item) {
                              setState(() {
                                targetLang = item!;
                                isModelDownloaded();
                              });
                            },
                            value: targetLang,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // ElevatedButton(onPressed: (){performTranslation();}, child: Text('Translate')),
              Expanded(
                child: Card(
                  color: Colors.white,
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          child: Text(
                            resultText,
                            style: TextStyle(fontSize: 25),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              color: Colors.blue.shade900,
                              child: InkWell(
                                onTap: () {
                                  Clipboard.setData(
                                    ClipboardData(text: resultText),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Copied')),
                                  );
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.copy,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              color: Colors.blue.shade900,
                              child: InkWell(
                                onTap: () {
                                  flutterTts.speak(resultText);
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.record_voice_over,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80),
                    ),
                    color: Colors.black,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => VisionScreen(
                                  ImageSource.gallery,
                                  onDeviceTranslator,
                                ),
                          ),
                        );
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.image,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80),
                    ),
                    color: Colors.blue.shade900,
                    child: InkWell(
                      onTap: () {
                        _startListening();
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.mic,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80),
                    ),
                    color: Colors.black,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => VisionScreen(
                                  ImageSource.camera,
                                  onDeviceTranslator,
                                ),
                          ),
                        );
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
