import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './ListItem.dart';
import './NoteSwipe.dart';

class Listing extends StatefulWidget {
  final Function noteDialog;

  const Listing({
    Key key,
    this.noteDialog,
  }) : super(key: key);

  @override
  _ListingState createState() => _ListingState();
}

class _ListingState extends State<Listing> {
  List items = [];
  DocumentSnapshot deletedNote;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: this._renderListView(context),
    );
  }

  @override
  initState() {
    super.initState();
  }

  _renderListView(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("notes")
            .orderBy("created", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // In case of error
          if (snapshot.hasError) {
            return Center(
              child: Text('Unexpected error, unable to load notes!'),
            );
          }

          //TODO: In case of no Data, show different message
          // Showing Loading indicator based on Connection state and if there is no data available at the momet
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // print(['single doc:', snapshot.data.documents[0]['title']]);

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {
              // print([
              //   'itemBuilder [title]',
              //   snapshot.data.documents[index]['title']
              // ]);
              return this
                  ._renderListItem(context, snapshot.data.documents[index]);
            },
            separatorBuilder: (BuildContext context, int index) =>
                SizedBox(height: 18),
          );
        });
  }

  _renderListItem(BuildContext context, DocumentSnapshot item) {
    return Dismissible(
      // Each Dismissible must contain a Key. Keys allow Flutter to
      // uniquely identify widgets.
      key: Key(item.id),
      child: ListItem(item: item, editNote: this._editNote),
      // Provide a function that tells the app
      // what to do after an item has been swiped away.
      background: rightSwipe(),
      secondaryBackground: leftSwipe(),
      onDismissed: (direction) {},
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text(
                  "Are you sure to delete \"" + item['title'] + "\" ?",
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      "Cancel",
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  FlatButton(
                    child: Text(
                      "Confirm",
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                    onPressed: () => this._removeNote(context, item),
                  ),
                ],
              );
            },
          );
        } else {
          // TODO: Navigate to edit page;
          // showDialog(
          //   context: context,
          //   child: AlertDialog(
          //     title: Text("Editing Note!"),
          //   ),
          // );

          this._editNote(item);
        }
      },
    );
  }

  _editNote(DocumentSnapshot note) {
    widget.noteDialog(note);
  }

  _removeNote(BuildContext context, DocumentSnapshot item) async {
    // Saved removing note to state
    setState(() => deletedNote = item);

    // Deleting note from Cloud
    var notesRef = FirebaseFirestore.instance.collection("notes");
    // TODO: Use "await" with proper indicator
    notesRef
        .doc(item.id)
        .delete()
        .then((value) =>
            {this._showNoteRemoveNotification(item['title'] + " is removed")})
        .catchError((error) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("Unable to delete note!")));
    });

    // FirebaseFirestore.instance
    //     .runTransaction((Transaction myTransaction) async {
    //   await myTransaction.delete(item.reference);
    // });

    Navigator.of(context).pop();
  }

  _showNoteRemoveNotification(String message) {
    // Removing currently shown snackbar
    Scaffold.of(context).removeCurrentSnackBar();

    // Show a snackbar. This snackbar could also contain "Undo" actions.
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
            label: "UNDO",
            onPressed: () {
              // TODO: Check if deleteNote object have value or not
              // Re-adding last removed not to Cloud
              var notesRef = FirebaseFirestore.instance.collection("notes");
              notesRef.add({
                'title': deletedNote['title'],
                'body': deletedNote['body'],
                'created': deletedNote['created'],
              }).then((value) {
                print(['then value:', value]);
              }).catchError((error) {
                print(['catchError error:', error]);
              });
            }),
      ),
    );
  }
}
