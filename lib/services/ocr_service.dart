import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OCRService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final _picker = ImagePicker();

  /// Pick an image from camera or gallery and extract total amount
  Future<Map<String, dynamic>?> scanReceipt() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return null;

      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(
        inputImage,
      );

      String fullText = recognizedText.text;
      double? amount = _extractAmount(fullText);
      String? merchant = _extractMerchant(fullText);

      return {'amount': amount, 'merchant': merchant, 'text': fullText};
    } catch (e) {
      debugPrint('OCR Error: $e');
      return null;
    }
  }

  double? _extractAmount(String text) {
    // Basic regex to find patterns like "Total: 123.45" or "123,45"
    final RegExp amountRegExp = RegExp(
      r'(?:total|amount|sum|net|pay|paid)[:\s]*[₹$€£]?\s*(\d+[.,]\d{2})',
      caseSensitive: false,
    );
    final match = amountRegExp.firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(1)!.replaceAll(',', '.'));
    }

    // Fallback: look for the largest number in the text (often the total)
    final RegExp numericRegExp = RegExp(r'(\d+[.,]\d{2})');
    final matches = numericRegExp.allMatches(text);
    double maxAmount = 0;
    for (final m in matches) {
      double? val = double.tryParse(m.group(1)!.replaceAll(',', '.'));
      if (val != null && val > maxAmount) maxAmount = val;
    }
    return maxAmount > 0 ? maxAmount : null;
  }

  String? _extractMerchant(String text) {
    // The first line is often the merchant name
    final lines = text.split('\n');
    if (lines.isNotEmpty) {
      return lines.first.trim();
    }
    return null;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
