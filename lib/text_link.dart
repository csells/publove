import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TextLink extends StatelessWidget {
  TextLink(
    this.text, {
    required String url,
    super.key,
  }) : url = Uri.parse(url);

  final String text;
  final Uri url;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => launchUrl(url, webOnlyWindowName: '_blank'),
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
