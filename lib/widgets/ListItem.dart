import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class ListItem extends StatefulWidget {
  final DocumentSnapshot item;
  final Function editNote;

  const ListItem({Key key, this.item, this.editNote}) : super(key: key);

  // ListItem(var item, Function editNote) {
  //   this.item = item;
  //   this.editNote = editNote;
  // }

  @override
  _ListItemState createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: this._renderItem(),
    );
  }

  _renderItem() {
    // Converting "Created" date Timestamp to DateTime object
    DateTime _createdAt = DateTime.fromMicrosecondsSinceEpoch(
        widget.item['created'].microsecondsSinceEpoch);

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shape: Border(left: BorderSide(color: Colors.deepPurpleAccent, width: 5)),
      child: InkWell(
        onTap: this._onItemTap,
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(
            vertical: 10.0,
            horizontal: 15.0,
          ),
          title: Text(
            widget.item['title'],
            style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
          ),
          subtitle: Text(DateFormat('MMM dd, yyyy').format(_createdAt)),
          trailing: Text(DateFormat('kk:mm').format(_createdAt)),
        ),
      ),
    );
  }

  _onItemTap() {
    widget.editNote(widget.item);

    // showDialog(
    //       context: context,
    //       child: AlertDialog(
    //         title: Text("Note Tapped"),
    //       ));
  }
}
