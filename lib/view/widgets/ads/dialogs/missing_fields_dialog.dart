import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qarsspin/l10n/l10n.dart';

import '../../../../l10n/app_localizations.dart';

class MissingFieldsDialog {
  static void show(BuildContext context, List<String> missingFields) {
    var lc = AppLocalizations.of(context)!;
    String fieldsText = missingFields.join(', ');
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title:  Text(lc.missing_info),
        content: Text('${lc.please_fill_info}:\n${lc.getText(fieldsText)}'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child:  Text(
              lc.ok_lbl,
              style: TextStyle(color: CupertinoColors.activeBlue),
            ),
          ),
        ],
      ),
    );
  }
}
