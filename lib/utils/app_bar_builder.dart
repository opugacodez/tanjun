import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Version 0.0.1-alpha"),
                      Row(
                        children: [
                          const Text("View the source code at "),
                          InkWell(
                              child: const Text('GitHub', style: TextStyle(
                                color: Colors.blue,
                              ),),
                              onTap: ()
                              {
                                launchUrl(Uri.parse('https://github.com/opugacodez/tanjun'));
                              }
                          ),
                        ],
                      ),
                    ],
                  ),
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