import 'package:flutter/material.dart';

/// Builds the app bar for the application.
///
/// This app bar includes a title and a popup menu button
/// with an 'About' option that shows an about dialog.
AppBar buildAppBar(BuildContext context) {
  return AppBar(
    title: const Text('Tanjun'),
    actions: [
      PopupMenuButton<String>(
        onSelected: (String result) {
          if (result == 'About') {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Tanjun'),
                  content: const Text('Version 0.0.1-alpha\nView source code at <>'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
        itemBuilder: (BuildContext context) {
          return [
            const PopupMenuItem<String>(
              value: 'About',
              child: Text('About'),
            ),
          ];
        },
        icon: const Icon(Icons.more_vert),
      ),
    ],
    automaticallyImplyLeading: true,
  );
}