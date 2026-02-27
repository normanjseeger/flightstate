import 'package:flutter/material.dart';

/// A collapsible panel that displays AFM CONDITIONS and NOTES.
///
/// Used in both takeoff and landing views to show the relevant
/// conditions and notes from the Aircraft Flight Manual.
class AfmRemarksPanel extends StatefulWidget {
  final String title;
  final List<String> conditions;
  final List<String> notes;
  final bool initiallyExpanded;

  const AfmRemarksPanel({
    super.key,
    required this.title,
    required this.conditions,
    required this.notes,
    this.initiallyExpanded = false,
  });

  @override
  State<AfmRemarksPanel> createState() => _AfmRemarksPanelState();
}

class _AfmRemarksPanelState extends State<AfmRemarksPanel> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (clickable to expand/collapse)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue.shade700,
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          if (_isExpanded) ...[
            const Divider(height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CONDITIONS section
                  Text(
                    'CONDITIONS OF POH BASE CASE CALCULATIONS:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.conditions.map((condition) => Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.blue.shade800,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                condition,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),

                  const SizedBox(height: 16),

                  // NOTES section
                  Text(
                    'NOTES:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...widget.notes.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final note = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$index. ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              note,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
