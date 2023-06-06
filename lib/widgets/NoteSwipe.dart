import 'package:flutter/material.dart';

var swipeConfig = {
  "iconColor": Colors.white,
  "textStyle": TextStyle(
    color: Colors.white,
    fontSize: 17.0,
    fontWeight: FontWeight.w700,
  ),
};
var originSpace = SizedBox(
  width: 20,
);

Widget leftSwipe() {
  return Container(
    color: Colors.deepPurpleAccent,
    child: Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Icon(
            Icons.edit,
            color: swipeConfig["iconColor"],
          ),
          Text(
            " Edit",
            style: swipeConfig["textStyle"],
            textAlign: TextAlign.left,
          ),
          originSpace,
        ],
      ),
      alignment: Alignment.centerRight,
    ),
  );
}

Widget rightSwipe() {
  return Container(
    color: Colors.blueGrey,
    child: Align(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          originSpace,
          Icon(
            Icons.delete,
            color: swipeConfig["iconColor"],
          ),
          Text(
            " Delete",
            style: swipeConfig["textStyle"],
            textAlign: TextAlign.right,
          ),
        ],
      ),
      alignment: Alignment.centerLeft,
    ),
  );
}
