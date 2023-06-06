import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:toast/toast.dart';
import 'package:provider/provider.dart';

import '../app_model.dart';
import '../widgets/RecordingPopup.dart';
import '../widgets/Listing.dart';

enum RecordingStatuses { none, running, paused }

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BuildContext context;

  stt.SpeechToText _speech;
  // String _text = 'Press the button and start speaking';
  // double _confidence = 1.0;

  @override
  void initState() {
    super.initState();

    this.initSpeechRecognition();
  }

  @override
  void dispose() {
    // Disposing speech listener
    _speech.stop();
    _speech.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    setState(() => this.context = context);

    return Scaffold(
      // resizeToAvoidBottomPadding: false,
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Todo Voice"),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Material(
        color: Colors.grey[100],
        child: Center(
          child: Listing(noteDialog: this._noteDialog),
        ),
      ),
      floatingActionButton: Transform.scale(
        scale: 1.2,
        child: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.deepPurpleAccent,
          onPressed: this._noteDialog,
        ),
      ),
    );
  }

  initSpeechRecognition() {
    _speech = stt.SpeechToText();

    _speech
        .initialize(
          onStatus: this._onSpeechStatus,
          onError: this._onSpeechError,
        )
        .then(
          (value) => {
            // TODO: Show message in case of false value
            print(['_speech.initialize', value]),

            Provider.of<AppModel>(context, listen: false)
                .setRecognitionAvailability(value),
          },
        );
  }

  _noteDialog([DocumentSnapshot note]) {
    // Resetting all recording params
    Provider.of<AppModel>(context, listen: false).resetRecordingParams();

    // TODO: Get popup results and show it in listing
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: RecordingPopup(
            note: note,
            toggleRecording: this._speechRecording,
            clearRecording: this._clearRecordedText,
            saveNote: this._saveNote,
          ),
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        );
      },
    );
  }

  _saveNote(String title, String body, {String id}) {
    String _errorMessage = "";
    print(['_saveNote id:', id]);

    if (title.trim().isEmpty) {
      _errorMessage = "Note title is missing!";
    }

    if (body.trim().isEmpty) {
      _errorMessage = "Note text is missing!";
    }

    if (_errorMessage.isNotEmpty) {
      this._showToast(_errorMessage);

      return false;
    }

    var notes = FirebaseFirestore.instance.collection("notes");

    if (id != null) {
      // Updating existing Note with ID
      notes.doc(id).update({
        'title': title,
        'body': body,
      }).then((value) {
        this._showToast("Note updated successfully!");

        // Closing popup on successful operation
        Navigator.pop(context);
      }).catchError((error) {
        print(['catchError error:', error]);

        this._showToast("Unable to update note!");
      });
    } else {
      // Creating new Note on Cloud
      notes.add({
        'title': title,
        'body': body,
        'created': Timestamp.now(),
      }).then((value) {
        print(['then value:', value]);

        this._showToast("Note created successfully!");

        // Closing popup on successful operation
        Navigator.pop(context);
      }).catchError((error) {
        print(['catchError error:', error]);

        this._showToast("Unable to create note!");
      });
    }
  }

  _onSpeechStatus(value) {
    print(['onStatus', value]);

    if (value == 'notListening') {
      if (!Provider.of<AppModel>(context, listen: false).getRecognitionStatus())
        return false;

      Provider.of<AppModel>(context, listen: false).setRecognitionStatus(false);

      this._showToast("Tap again to start recording!");
    }
  }

  _onSpeechError(value) {
    print(['onError', value]);

    if (!Provider.of<AppModel>(context, listen: false).getRecognitionStatus())
      return false;

    // Stopping recording in case of any error
    Provider.of<AppModel>(context, listen: false).setRecognitionStatus(false);

    this._showToast("Tap again to start recording!");
  }

  _speechRecording([status = true]) {
    print({
      "=======",
      '_speechRecording',
      status,
    });

    if (status) {
      this._startListening();
    } else {
      this._stopListening();
    }
  }

  _startListening() async {
    Provider.of<AppModel>(context, listen: false).setRecognitionStatus(true);

    // Clearing recognized text in last session
    this._clearRecordedText();

    _speech.listen(onResult: (result) {
      // print(['result', result]);
      // print(['is final', result.finalResult]);

      String _recognizedText = result.recognizedWords;
      // print(['_recognizedText', _recognizedText]);

      if (result.finalResult) {
        print(['final recognized text', _recognizedText]);

        // Moving text to recognized text to state
        Provider.of<AppModel>(context, listen: false)
            .setRecognizedText(_recognizedText);
      }
    });
  }

  _stopListening() {
    print('called _stopListening');

    Provider.of<AppModel>(context, listen: false).setRecognitionStatus(false);

    _speech.stop();
  }

  _clearRecordedText() {
    // Clearing recognized text in last session
    Provider.of<AppModel>(context, listen: false).setRecognizedText("");
  }

  _showToast(String message) {
    Toast.show(
      message,
      context,
      duration: Toast.LENGTH_LONG,
      gravity: Toast.BOTTOM,
    );
  }

  _showSnackBar(String message) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
