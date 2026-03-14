import 'package:flutter/material.dart';

/// A reusable help icon that shows a brief explanation dialog
/// with an optional link to detailed help.
class HelpIcon extends StatelessWidget {
  final String title;
  final String briefExplanation;
  final String? detailedRoute; // Route to detailed help section

  const HelpIcon({
    super.key,
    required this.title,
    required this.briefExplanation,
    this.detailedRoute,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info_outline, size: 18),
      tooltip: 'Help: $title',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: () => _showHelpDialog(context),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            briefExplanation,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
        actions: [
          if (detailedRoute != null)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, detailedRoute!);
              },
              icon: const Icon(Icons.article_outlined, size: 18),
              label: const Text('Learn More'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
