import 'package:flutter/foundation.dart';

class AppModel with ChangeNotifier {
  bool recognitionStatus = false;
  bool recognitionAvailability = false;
  String recognizedText = "";

  bool getRecognitionAvailability() => recognitionAvailability;

  void setRecognitionAvailability(bool status) {
    recognitionAvailability = status;
    notifyListeners();
  }

  bool getRecognitionStatus() => recognitionStatus;

  void setRecognitionStatus(bool status) {
    recognitionStatus = status;
    notifyListeners();
  }

  String getRecognizedText() => recognizedText;

  void setRecognizedText(String text) {
    recognizedText = text;
    notifyListeners();
  }

  void resetRecordingParams() {
    recognizedText = "";
    recognitionStatus = false;
    recognitionAvailability = false;
  }
}
