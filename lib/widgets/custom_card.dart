import 'package:flutter/material.dart';

/// A [CustomCard] widget which displays an icon, a title, and content inside a card.
class CustomCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget content;

  const CustomCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(icon),
                ),
                const SizedBox(width: 10.0),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}