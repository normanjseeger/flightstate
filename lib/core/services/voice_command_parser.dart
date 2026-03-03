import 'package:flutter/material.dart';

/// Enum for input mode
enum InputMode {
  direct,
  readings,
}

/// Data model for parsed flight times voice input
class FlightTimesVoiceData {
  final InputMode? mode;
  final double? hobbsDiff;
  final double? vutDiff;
  final double? hobbsStart;
  final double? hobbsEnd;
  final double? vutStart;
  final double? vutEnd;
  final TimeOfDay? blockOnUtc;
  final int? taxiMinutes;
  final int? utcOffsetHours;

  const FlightTimesVoiceData({
    this.mode,
    this.hobbsDiff,
    this.vutDiff,
    this.hobbsStart,
    this.hobbsEnd,
    this.vutStart,
    this.vutEnd,
    this.blockOnUtc,
    this.taxiMinutes,
    this.utcOffsetHours,
  });
}

/// Result of voice command parsing
class VoiceParseResult {
  final FlightTimesVoiceData? data;
  final bool hasError;
  final String? errorMessage;

  const VoiceParseResult({
    this.data,
    this.hasError = false,
    this.errorMessage,
  });

  factory VoiceParseResult.success(FlightTimesVoiceData data) {
    return VoiceParseResult(data: data, hasError: false);
  }

  factory VoiceParseResult.error(String message) {
    return VoiceParseResult(hasError: true, errorMessage: message);
  }
}

/// Parser for flight times voice commands
class VoiceCommandParser {
  /// Parse a voice command into structured flight times data
  VoiceParseResult parse(String transcription) {
    try {
      // Pre-process the transcription
      final processed = _preProcess(transcription);

      // Detect input mode
      final mode = _detectMode(processed);

      // Extract data based on mode
      double? hobbsDiff;
      double? vutDiff;
      double? hobbsStart;
      double? hobbsEnd;
      double? vutStart;
      double? vutEnd;

      if (mode == InputMode.direct) {
        hobbsDiff = _extractDirectValue(processed, 'hobbs');
        vutDiff = _extractDirectValue(processed, 'vut');
      } else {
        final hobbsReadings = _extractStartEndValues(processed, 'hobbs');
        hobbsStart = hobbsReadings?.$1;
        hobbsEnd = hobbsReadings?.$2;

        final vutReadings = _extractStartEndValues(processed, 'vut');
        vutStart = vutReadings?.$1;
        vutEnd = vutReadings?.$2;
      }

      // Extract common values
      final blockOn = _extractBlockOn(processed);
      final taxiMinutes = _extractTaxiMinutes(processed);
      final utcOffset = _extractUtcOffset(processed);

      // Validate required fields
      final validation = _validate(
        mode: mode,
        hobbsDiff: hobbsDiff,
        vutDiff: vutDiff,
        hobbsStart: hobbsStart,
        hobbsEnd: hobbsEnd,
        vutStart: vutStart,
        vutEnd: vutEnd,
        blockOn: blockOn,
      );

      if (validation != null) {
        return VoiceParseResult.error(validation);
      }

      // Create result
      final data = FlightTimesVoiceData(
        mode: mode,
        hobbsDiff: hobbsDiff,
        vutDiff: vutDiff,
        hobbsStart: hobbsStart,
        hobbsEnd: hobbsEnd,
        vutStart: vutStart,
        vutEnd: vutEnd,
        blockOnUtc: blockOn,
        taxiMinutes: taxiMinutes,
        utcOffsetHours: utcOffset,
      );

      return VoiceParseResult.success(data);
    } catch (e) {
      return VoiceParseResult.error('Failed to parse voice command: $e');
    }
  }

  /// Pre-process the transcription
  String _preProcess(String text) {
    var processed = text.toLowerCase().trim();

    // First pass: normalize aviation terms (handles common misrecognitions)
    processed = _normalizeAviationTerms(processed);

    // Second pass: replace number words with digits
    processed = _replaceNumberWords(processed);

    // Third pass: normalize time formats (14 30 -> 14:30)
    processed = _normalizeTimeWords(processed);

    // Fourth pass: normalize decimal formats (3 point 5 -> 3.5)
    processed = _normalizeDecimals(processed);

    return processed;
  }

  /// Normalize aviation-specific terms that might be misrecognized
  String _normalizeAviationTerms(String text) {
    var result = text;

    // HOBBS variations (meter that tracks engine hours)
    result = result.replaceAllMapped(
      RegExp(r'\b(hobs|hobbs|hobbes|hobbs?)\s*(hours?|meter|time)?', caseSensitive: false),
      (match) => 'hobbs',
    );

    // VUT variations (vacuum under tension / engine run time)
    result = result.replaceAllMapped(
      RegExp(r'\b(v\.?\s*u\.?\s*t\.?|vut|view\s*tee|v\s*u\s*t)\b', caseSensitive: false),
      (match) => 'vut',
    );

    // Block on variations
    result = result.replaceAllMapped(
      RegExp(r'\b(block\s*on|blocked\s*on|lock\s*on)\b', caseSensitive: false),
      (match) => 'block on',
    );

    return result;
  }

  /// Replace number words with digits
  String _replaceNumberWords(String text) {
    final replacements = {
      'zero': '0',
      'one': '1',
      'two': '2',
      'three': '3',
      'four': '4',
      'five': '5',
      'six': '6',
      'seven': '7',
      'eight': '8',
      'nine': '9',
      'ten': '10',
      'eleven': '11',
      'twelve': '12',
      'thirteen': '13',
      'fourteen': '14',
      'fifteen': '15',
      'sixteen': '16',
      'seventeen': '17',
      'eighteen': '18',
      'nineteen': '19',
      'twenty': '20',
      'thirty': '30',
      'forty': '40',
      'fifty': '50',
    };

    var result = text;
    replacements.forEach((word, digit) {
      result = result.replaceAll(word, digit);
    });

    return result;
  }

  /// Normalize decimal formats
  String _normalizeDecimals(String text) {
    // Handle "point" for decimals - combine consecutive single digits after point
    return text.replaceAllMapped(
      RegExp(r'(\d+)\s+point\s+((?:\d+\s*)+)'),
      (match) {
        final wholePart = match.group(1)!;
        final decimalPart = match.group(2)!.replaceAll(RegExp(r'\s+'), '').trim();
        return '$wholePart.$decimalPart';
      },
    );
  }


  /// Normalize time words
  String _normalizeTimeWords(String text) {
    // Handle spoken times like "14 30" -> "14:30"
    // Match two-digit patterns that look like times (hour minute)
    var result = text.replaceAllMapped(
      RegExp(r'\b(\d{1,2})\s+(\d{2})\b'),
      (match) {
        final hour = int.tryParse(match.group(1)!);
        final minute = int.tryParse(match.group(2)!);
        // Only convert if it looks like a valid time
        if (hour != null && minute != null && hour <= 23 && minute <= 59) {
          return '${match.group(1)}:${match.group(2)}';
        }
        return match.group(0)!;
      },
    );

    return result;
  }

  /// Detect input mode from the transcription
  InputMode _detectMode(String text) {
    // Look for "start" and "end" keywords
    final hasStart = RegExp(r'\b(start|from)\b').hasMatch(text);
    final hasEnd = RegExp(r'\b(end|to)\b').hasMatch(text);

    // If both start and end are present, it's readings mode
    if (hasStart && hasEnd) {
      return InputMode.readings;
    }

    // Otherwise, it's direct mode
    return InputMode.direct;
  }

  /// Extract direct value (e.g., "hobbs 3.5")
  double? _extractDirectValue(String text, String field) {
    // Try pattern: "field number"
    final pattern = RegExp(r'\b' + field + r'\s+(\d+(?:\.\d+)?)', caseSensitive: false);
    final match = pattern.firstMatch(text);

    if (match != null) {
      return double.tryParse(match.group(1)!);
    }

    return null;
  }

  /// Extract start/end values (e.g., "hobbs start 1234.5 end 1238.0")
  (double, double)? _extractStartEndValues(String text, String field) {
    // Try pattern: "field start X end Y"
    final pattern1 = RegExp(
      r'\b' + field + r'\s+start\s+(\d+(?:\.\d+)?)\s+end\s+(\d+(?:\.\d+)?)',
      caseSensitive: false,
    );
    final match1 = pattern1.firstMatch(text);

    if (match1 != null) {
      final start = double.tryParse(match1.group(1)!);
      final end = double.tryParse(match1.group(2)!);
      if (start != null && end != null) {
        return (start, end);
      }
    }

    // Try pattern: "field from X to Y"
    final pattern2 = RegExp(
      r'\b' + field + r'\s+from\s+(\d+(?:\.\d+)?)\s+to\s+(\d+(?:\.\d+)?)',
      caseSensitive: false,
    );
    final match2 = pattern2.firstMatch(text);

    if (match2 != null) {
      final start = double.tryParse(match2.group(1)!);
      final end = double.tryParse(match2.group(2)!);
      if (start != null && end != null) {
        return (start, end);
      }
    }

    return null;
  }

  /// Extract block on time
  TimeOfDay? _extractBlockOn(String text) {
    // Try pattern: "block on [at] HH:MM" (with colon)
    final pattern1 = RegExp(
      r'\bblock\s+on\s+(?:at\s+)?(\d{1,2}):(\d{2})',
      caseSensitive: false,
    );
    final match1 = pattern1.firstMatch(text);

    if (match1 != null) {
      final hour = int.tryParse(match1.group(1)!);
      final minute = int.tryParse(match1.group(2)!);
      if (hour != null && minute != null && hour <= 23 && minute <= 59) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }

    // Try pattern: "block on [at] HH MM" (space-separated)
    final pattern2 = RegExp(
      r'\bblock\s+on\s+(?:at\s+)?(\d{1,2})\s+(\d{2})\b',
      caseSensitive: false,
    );
    final match2 = pattern2.firstMatch(text);

    if (match2 != null) {
      final hour = int.tryParse(match2.group(1)!);
      final minute = int.tryParse(match2.group(2)!);
      if (hour != null && minute != null && hour <= 23 && minute <= 59) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }

    // Try pattern: "block on [at] HHMM" (no colon, no space)
    final pattern3 = RegExp(
      r'\bblock\s+on\s+(?:at\s+)?(\d{3,4})\b',
      caseSensitive: false,
    );
    final match3 = pattern3.firstMatch(text);

    if (match3 != null) {
      final timeStr = match3.group(1)!.padLeft(4, '0');
      final hour = int.tryParse(timeStr.substring(0, 2));
      final minute = int.tryParse(timeStr.substring(2, 4));
      if (hour != null && minute != null && hour <= 23 && minute <= 59) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }

    return null;
  }

  /// Extract taxi minutes
  int? _extractTaxiMinutes(String text) {
    final pattern = RegExp(
      r'\btaxi\s+(\d+)\s*(?:minutes?|mins?)?',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(text);

    if (match != null) {
      return int.tryParse(match.group(1)!);
    }

    return null;
  }

  /// Extract UTC offset
  int? _extractUtcOffset(String text) {
    final pattern = RegExp(
      r'\butc\s+plus\s+([12])',
      caseSensitive: false,
    );
    final match = pattern.firstMatch(text);

    if (match != null) {
      return int.tryParse(match.group(1)!);
    }

    return null;
  }

  /// Validate parsed data
  String? _validate({
    required InputMode mode,
    double? hobbsDiff,
    double? vutDiff,
    double? hobbsStart,
    double? hobbsEnd,
    double? vutStart,
    double? vutEnd,
    TimeOfDay? blockOn,
  }) {
    // Check for required fields based on mode
    if (mode == InputMode.direct) {
      if (hobbsDiff == null) {
        return 'HOBBS value is required. Example: "HOBBS 3.5"';
      }
      if (vutDiff == null) {
        return 'VUT value is required. Example: "VUT 2.75"';
      }
    } else {
      if (hobbsStart == null || hobbsEnd == null) {
        return 'HOBBS start and end values are required. Example: "HOBBS start 1234.5 end 1238.0"';
      }
      if (vutStart == null || vutEnd == null) {
        return 'VUT start and end values are required. Example: "VUT start 890 end 893"';
      }
    }

    if (blockOn == null) {
      return 'Block On time is required. Example: "Block on at 14:30"';
    }

    return null;
  }
}
