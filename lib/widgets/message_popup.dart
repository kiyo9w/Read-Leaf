import 'package:flutter/material.dart';
import 'package:read_leaf/generated/l10n.dart';

Future<void> messagePopup(BuildContext context, String title, String message) {
  Widget okButton = TextButton(
    child: Text(S.of(context).ok),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(message),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
