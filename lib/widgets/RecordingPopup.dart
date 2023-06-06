import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/app_model.dart';

// TODO: Move all recording and stateful actions to main screen or create Screen widget for it

class RecordingPopup extends StatefulWidget {
  final Function toggleRecording;
  final Function clearRecording;
  final Function saveNote;
  final DocumentSnapshot note;

  const RecordingPopup(
      {Key key,
      this.toggleRecording,
      this.clearRecording,
      this.saveNote,
      this.note})
      : super(key: key);

  @override
  _RecordingPopupState createState() => _RecordingPopupState();
}

class _RecordingPopupState extends State<RecordingPopup> {
  BuildContext context;

  FocusNode noteTitleFocusNode;
  FocusNode speechTextFocusNode;

  String test;

  final titleInputController = TextEditingController();
  final speechInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    setState(() => this.context = context);

    return Container(
      child: SingleChildScrollView(
        child: this._renderPopupContent(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    noteTitleFocusNode = FocusNode();
    speechTextFocusNode = FocusNode();

    this._setEditNoteValues();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    noteTitleFocusNode.dispose();
    speechTextFocusNode.dispose();

    super.dispose();
  }

  _setEditNoteValues() {
    DocumentSnapshot _note = widget.note;

    if (_note != null) {
      titleInputController.text = _note['title'];
      speechInputController.text = _note['body'];
    }
  }

  _renderPopupContent() {
    var _header = this._renderPopupHeader();
    var _body = this._renderPopupBody();
    var _footer = this._renderPopupFooter();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _header,
        _body,
        _footer,
      ],
    );
  }

  _renderPopupHeader() {
    var _headerInput = TextField(
      controller: titleInputController,
      focusNode: noteTitleFocusNode,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 26.0,
        color: Colors.deepPurpleAccent,
      ),
      decoration: InputDecoration(
        hintText: 'Untitled Note',
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(0),
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.0, color: Colors.deepPurpleAccent),
        ),
      ),
      child: _headerInput,
    );
  }

  _renderPopupBody() {
    return Consumer<AppModel>(builder: (contet, model, child) {
      String recognizedText = model.getRecognizedText();

      // Only compiling text which is not empty/null
      if (recognizedText.trim().isNotEmpty) {
        print(['getRecognizedText', recognizedText]);

        String _textAdditionPrefix =
            speechInputController.text.length > 0 ? " " : "";

        // TODO: Look for possibillity to add text where cursor is placed
        // Appending new recognized text to TextField
        speechInputController.text += _textAdditionPrefix + recognizedText;

        // Moving cursor position to the end of edit field
        speechInputController.selection = TextSelection.fromPosition(
            TextPosition(offset: speechInputController.text.length));
      }

      return Container(
        padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0),
        constraints: BoxConstraints(),
        decoration: BoxDecoration(
            // border: Border(
            //   bottom: BorderSide(width: 1.0, color: Colors.deepPurpleAccent),
            // ),
            ),
        child: TextField(
          controller: speechInputController,
          showCursor: true,
          focusNode: speechTextFocusNode,
          maxLines: 14,
          style: TextStyle(
            fontSize: 24.0,
          ),
          decoration: InputDecoration.collapsed(
            border: InputBorder.none,
            hintText: "Press the button to start speaking",
          ),
        ),
      );
    });
  }

  _renderPopupFooter() {
    List<Widget> _actionsList = [this._btnClosePopup()];

    // if (this._isSpeechAvailable) {
    _actionsList.add(this._btnToggleNoteRecording());
    _actionsList.add(this._btnSaveNote());
    // }

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _actionsList,
      ),
    );
  }

  _renderPopupActions(icon, tap) {
    double _actionSize = 60;
    double _iconSize = 45.0;
    Color _actionBgColor = Colors.white;
    Color _iconColor = Colors.deepPurpleAccent;

    // _actionBgColor = Colors.red;

    return ClipOval(
      child: Material(
        color: _actionBgColor,
        child: InkWell(
          child: SizedBox(
            width: _actionSize,
            height: _actionSize,
            child: Icon(
              icon,
              size: _iconSize,
              color: _iconColor,
            ),
          ),
          onTap: tap,
        ),
      ),
    );
  }

  _renderRecordAction(icon, tap) {
    IconData _actionIcon = Icons.mic;
    double _actionSize = 40.0;
    double _iconSize = 45.0;
    Color _actionBgColor = Colors.deepPurpleAccent;
    Color _iconColor = Colors.white;
    bool _animateBtn = false;

    return Consumer<AppModel>(builder: (context, model, child) {
      _actionIcon = model.getRecognitionStatus() ? Icons.pause : Icons.mic;
      _actionBgColor =
          model.getRecognitionStatus() ? Colors.black : Colors.deepPurpleAccent;
      _animateBtn = model.getRecognitionStatus();

      return AvatarGlow(
        animate: _animateBtn,
        glowColor: _actionBgColor,
        endRadius: 70.0,
        duration: Duration(milliseconds: 2000),
        repeat: true,
        showTwoGlows: true,
        repeatPauseDuration: Duration(milliseconds: 100),
        child: Material(
          elevation: 8.0,
          shape: CircleBorder(),
          child: GestureDetector(
            child: CircleAvatar(
              backgroundColor: _actionBgColor,
              child: Icon(
                _actionIcon,
                size: _iconSize,
                color: _iconColor,
              ),
              radius: _actionSize,
            ),
            onTap: tap,
          ),
        ),
      );
    });
  }

  _btnToggleNoteRecording() {
    final appModel = Provider.of<AppModel>(context, listen: false);

    return this._renderRecordAction(
      Icons.mic,
      () => {
        // FocusScope.of(context).unfocus(),
        widget.toggleRecording(!appModel.getRecognitionStatus()),
      },
    );
  }

  _btnSaveNote() {
    return this._renderPopupActions(
      Icons.check,
      this._submitNote,
    );
  }

  _btnClosePopup() {
    return this._renderPopupActions(
      Icons.close,
      () => Navigator.pop(context),
    );
  }

  _submitNote() {
    DocumentSnapshot _note = widget.note;
    String _noteTitle = titleInputController.text;
    String _noteBody = speechInputController.text;

    // print(['_note.id', _note.id]);
    // return;

    // print(['_noteTitle', _noteTitle]);
    // print(['_noteBody', _noteBody]);

    widget.saveNote(_noteTitle, _noteBody,
        id: (_note != null ? _note.id : null));
  }
}
