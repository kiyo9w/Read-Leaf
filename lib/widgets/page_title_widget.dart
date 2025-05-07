// Flutter imports:
import 'package:flutter/material.dart';

/// A widget for displaying a title text with consistent styling.
/// The text to display should be passed as a parameter and should be
/// already localized using S.of(context) before passing it to this widget.
class TitleText extends StatelessWidget {
  const TitleText(this.text, {super.key});

  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 7),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
