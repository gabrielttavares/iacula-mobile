import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MeditationCard extends StatelessWidget {
  final String title;
  final IconData platformIcon;
  final String url;

  const MeditationCard({
    super.key,
    required this.title,
    required this.platformIcon,
    required this.url,
  });

  Future<void> _launchUrl() async {
    if (!await launchUrl(Uri.parse(url))) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF25211D),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _launchUrl,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(platformIcon, color: const Color(0xFFD6BA8E), size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFF8EFE1),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF837562), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
