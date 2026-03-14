import 'package:flutter/material.dart';
import '../../features/flight_times/viewmodels/flight_times_viewmodel.dart';

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
      print('DEBUG: Parsing transcription: $transcription');

      // Pre-process the transcription
      final processed = _preProcess(transcription);
      print('DEBUG: After preprocessing: $processed');

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
    } catch (e, stackTrace) {
      print('DEBUG: Parse error: $e');
      print('DEBUG: Stack trace: $stackTrace');
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

    // Total time (HOBBS/Ops) variations
    result = result.replaceAllMapped(
      RegExp(r'\b(total|hobs|hobbs|hobbes|ops|operation|operating)\s*(hours?|meter|time)?', caseSensitive: false),
      (match) => 'hobbs ',  // Keep trailing space
    );

    // Tachometer time (Engine time/Flight time) variations
    result = result.replaceAllMapped(
      RegExp(r'\b(tachometer|tach|engine|v\.?\s*u\.?\s*t\.?|vut|view\s*tee|v\s*u\s*t|flight?|fly|flying)\s*(time|hours?)?', caseSensitive: false),
      (match) => 'vut ',  // Keep trailing space
    );

    // Block on variations
    result = result.replaceAllMapped(
      RegExp(r'\b(block\s*on\s*time|block\s*on|blocked\s*on|lock\s*on|log\s*on|logged\s*on|clock\s*on)\b', caseSensitive: false),
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
    var result = text;

    // Handle "9H45min" or "9h45m" format -> "9:45"
    result = result.replaceAllMapped(
      RegExp(r'(\d{1,2})[hH](\d{2})[mM](?:in)?', caseSensitive: false),
      (match) {
        final hour = match.group(1)!;
        final minute = match.group(2)!;
        return '$hour:$minute';
      },
    );

    // Handle time with decimal point: "9.45" -> "9:45"
    // Only convert if minutes part is valid (00-59) to avoid affecting decimal hours
    result = result.replaceAllMapped(
      RegExp(r'\b(\d{1,2})\.(\d{2})\b'),
      (match) {
        final hour = int.tryParse(match.group(1)!);
        final minute = int.tryParse(match.group(2)!);
        // Only convert if it looks like a valid time (hour <= 23, minute <= 59)
        if (hour != null && minute != null && hour <= 23 && minute <= 59) {
          return '$hour:$minute';
        }
        return match.group(0)!; // Keep as-is if not a valid time
      },
    );

    // Handle "half past X" -> "X:30"
    result = result.replaceAllMapped(
      RegExp(r'\bhalf\s+past\s+(\d{1,2})\b', caseSensitive: false),
      (match) {
        final hour = match.group(1)!;
        return '$hour:30';
      },
    );

    // Handle "quarter past X" -> "X:15"
    result = result.replaceAllMapped(
      RegExp(r'\bquarter\s+past\s+(\d{1,2})\b', caseSensitive: false),
      (match) {
        final hour = match.group(1)!;
        return '$hour:15';
      },
    );

    // Handle "quarter to X" -> "(X-1):45"
    result = result.replaceAllMapped(
      RegExp(r'\bquarter\s+to\s+(\d{1,2})\b', caseSensitive: false),
      (match) {
        final nextHour = int.parse(match.group(1)!);
        final hour = nextHour - 1;
        return '$hour:45';
      },
    );

    // Handle "o'clock" format: "10 o'clock" -> "10:00"
    // Matches: "10 o'clock", "10 oclock", "10 o clock"
    result = result.replaceAllMapped(
      RegExp(r"\b(\d{1,2})\s+o'?\s*clock\b", caseSensitive: false),
      (match) {
        final hour = match.group(1)!;
        return '$hour:00';
      },
    );

    // Handle spoken times like "14 30" -> "14:30"
    // Match two-digit patterns that look like times (hour minute)
    result = result.replaceAllMapped(
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
    // Flexible validation: require at least ONE field to be provided
    // This allows partial voice input to fill only specific fields

    bool hasAnyField = false;

    // Check if any direct mode fields are provided
    if (hobbsDiff != null || vutDiff != null) {
      hasAnyField = true;
    }

    // Check if any readings mode fields are provided
    if (hobbsStart != null || hobbsEnd != null || vutStart != null || vutEnd != null) {
      hasAnyField = true;
    }

    // Check if block on time is provided
    if (blockOn != null) {
      hasAnyField = true;
    }

    // If no fields were recognized, return an error
    if (!hasAnyField) {
      return 'No fields recognized. Please dictate at least one field.\n\n'
          'Examples:\n'
          '• "Block on time 14:30"\n'
          '• "Total time 3.5"\n'
          '• "Tachometer time 2.75"\n'
          '• "Total time start 8552.3 end 8552.8"';
    }

    // Validate paired fields in readings mode
    // If start is provided, end should also be provided (and vice versa)
    if ((hobbsStart != null && hobbsEnd == null) || (hobbsStart == null && hobbsEnd != null)) {
      return 'Total time needs both start AND end values. Example: "Total time start 8552.3 end 8552.8"';
    }

    if ((vutStart != null && vutEnd == null) || (vutStart == null && vutEnd != null)) {
      return 'Tachometer time needs both start AND end values. Example: "Tachometer time start 7234.5 end 7235.0"';
    }

    return null;
  }
}
