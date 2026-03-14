import 'package:flutter/material.dart';
import '../help_content.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Reference'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWelcomeSection(context),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Takeoff Performance',
            Icons.flight_takeoff,
            [
              _HelpTopic(
                'Pressure Altitude',
                HelpContent.pressureAltitudeDetailed,
              ),
              _HelpTopic(
                'Aircraft Mass',
                HelpContent.aircraftMassDetailed,
              ),
              _HelpTopic(
                'Ground Roll',
                HelpContent.groundRollDetailed,
              ),
              _HelpTopic(
                'Takeoff Distance (50 ft Obstacle)',
                HelpContent.takeoffDistance50ftDetailed,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Flight Times',
            Icons.access_time,
            [
              _HelpTopic(
                'Direct Mode',
                HelpContent.directModeDetailed,
              ),
              _HelpTopic(
                'Start/End Mode',
                HelpContent.startEndModeDetailed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.menu_book,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'FlightState Help',
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome to FlightState\'s comprehensive help system. '
              'Here you\'ll find detailed explanations of aviation terms, '
              'performance calculations, and how to use each feature.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tip: Look for the ⓘ icons throughout the app for quick help on specific terms.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<_HelpTopic> topics,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...topics.map((topic) => _buildTopicCard(context, topic)),
      ],
    );
  }

  Widget _buildTopicCard(BuildContext context, _HelpTopic topic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          topic.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        leading: const Icon(Icons.help_outline, size: 20),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildMarkdownText(context, topic.content),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkdownText(BuildContext context, String text) {
    final theme = Theme.of(context);
    final lines = text.trim().split('\n');
    final widgets = <Widget>[];

    for (var line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      // Handle bold text (**text**)
      if (line.startsWith('**') && line.contains('**', 2)) {
        final boldText = line.replaceAll('**', '').replaceAll(':', '');
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(
              boldText,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
      // Handle bullet points
      else if (line.trim().startsWith('•') || line.trim().startsWith('-')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(
                  child: Text(
                    line.trim().substring(1).trim(),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // Regular text
      else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              line,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}

class _HelpTopic {
  final String title;
  final String content;

  _HelpTopic(this.title, this.content);
}
