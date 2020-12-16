/*
Author: Soh Wei Meng (swmeng@yes.my)
Date: 12 September 2019
Sparta App
*/

import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final BuildContext ctx;
  final String _message;
  final String _title;

  ErrorDialog(this.ctx, this._title, this._message);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_title),
      content: Text(_message),
      actions: <Widget>[
        FlatButton(
          child: Text('Okay'),
          onPressed: () {
            Navigator.of(ctx).pop();
          },
        )
      ],
    );
  }
}
