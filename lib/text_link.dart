import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TextLink extends StatelessWidget {
  const TextLink(
    this.text, {
    required this.url,
    super.key,
  });

  final String text;
  final String url;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse(url),
        webOnlyWindowName: '_blank',
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
