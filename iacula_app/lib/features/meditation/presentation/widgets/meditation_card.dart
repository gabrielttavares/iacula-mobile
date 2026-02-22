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

  Future<void> _launchUrl(BuildContext context) async {
    final parsedUrl = Uri.parse(url);
    if (!await launchUrl(parsedUrl)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF25211D),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _launchUrl(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(platformIcon, color: const Color(0xFFD6BA8E), size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFFF8EFE1),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF837562), size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
