import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flightstate/widgets/help_icon.dart';

/// A slider with an editable text field that shows the current value.
/// The slider operates on [value] (internal units), while the text field
/// shows [displayValue] (possibly converted to display units).
/// When the user types, the value is converted back via [displayToValue].
class EditableSlider extends StatefulWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String unit;
  final double displayValue;
  final ValueChanged<double> onChanged;
  final String? subtitle;
  final int decimals;

  /// Converts a display-unit value back to the internal slider value.
  /// Defaults to identity (display == internal).
  final double Function(double displayVal)? displayToValue;

  /// Fixed width for the text field + unit area. Ensures consistent alignment.
  final double fieldWidth;

  /// Optional help text to show in a dialog when help icon is tapped
  final String? helpText;

  /// Optional route to detailed help page
  final String? helpRoute;

  const EditableSlider({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.unit,
    required this.displayValue,
    required this.onChanged,
    this.subtitle,
    this.decimals = 1,
    this.displayToValue,
    this.fieldWidth = 120,
    this.helpText,
    this.helpRoute,
  });

  @override
  State<EditableSlider> createState() => _EditableSliderState();
}

class _EditableSliderState extends State<EditableSlider> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.displayValue.toStringAsFixed(widget.decimals),
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(EditableSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing) {
      _controller.text = widget.displayValue.toStringAsFixed(widget.decimals);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      setState(() => _isEditing = true);
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    } else {
      _submitValue();
      setState(() => _isEditing = false);
    }
  }

  void _submitValue() {
    final parsed = double.tryParse(_controller.text);
    if (parsed != null) {
      // Convert display value back to internal value
      final converter = widget.displayToValue ?? (v) => v;
      final internalVal = converter(parsed);
      final clamped = internalVal.clamp(widget.min, widget.max);
      widget.onChanged(clamped);

      // Unfocus to trigger text sync and mark editing as complete
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(widget.icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (widget.helpText != null) ...[
              const SizedBox(width: 4),
              HelpIcon(
                title: widget.label,
                briefExplanation: widget.helpText!,
                detailedRoute: widget.helpRoute,
              ),
            ],
            SizedBox(
              width: widget.fieldWidth,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[-\d.]')),
                ],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: theme.colorScheme.onPrimaryContainer,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  suffixText: widget.unit,
                  suffixStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.primaryContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                onSubmitted: (_) => _submitValue(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: widget.value,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions,
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}
