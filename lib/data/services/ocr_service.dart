import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';

class OcrService {
  final textRecognizer = TextRecognizer();
  
  Future<String> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      return 'خطأ في قراءة النص: $e';
    }
  }
  
  void dispose() {
    textRecognizer.close();
  }
}