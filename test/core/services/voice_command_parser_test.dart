import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flightstate/core/services/voice_command_parser.dart';

void main() {
  late VoiceCommandParser parser;

  setUp(() {
    parser = VoiceCommandParser();
  });

  group('VoiceCommandParser - Direct Mode', () {
    test('parses simple direct mode command', () {
      final result = parser.parse('HOBBS 3.5, VUT 2.75, Block on at 14:30');

      expect(result.hasError, false);
      expect(result.data, isNotNull);
      expect(result.data!.mode, InputMode.direct);
      expect(result.data!.hobbsDiff, 3.5);
      expect(result.data!.vutDiff, 2.75);
      expect(result.data!.blockOnUtc, const TimeOfDay(hour: 14, minute: 30));
    });

    test('parses direct mode with optional parameters', () {
      final result = parser.parse(
        'HOBBS 3.5, VUT 2.75, Block on 14:30, taxi 5 minutes, UTC plus 2',
      );

      expect(result.hasError, false);
      expect(result.data, isNotNull);
      expect(result.data!.mode, InputMode.direct);
      expect(result.data!.hobbsDiff, 3.5);
      expect(result.data!.vutDiff, 2.75);
      expect(result.data!.blockOnUtc, const TimeOfDay(hour: 14, minute: 30));
      expect(result.data!.taxiMinutes, 5);
      expect(result.data!.utcOffsetHours, 2);
    });

    test('handles decimal number words', () {
      final result = parser.parse(
        'HOBBS three point five, VUT two point seven five, Block on 14:30',
      );

      expect(result.hasError, false);
      expect(result.data!.hobbsDiff, 3.5);
      expect(result.data!.vutDiff, 2.75);
    });

    test('returns error when HOBBS is missing', () {
      final result = parser.parse('VUT 2.75, Block on 14:30');

      expect(result.hasError, true);
      expect(result.errorMessage, contains('HOBBS'));
    });

    test('returns error when VUT is missing', () {
      final result = parser.parse('HOBBS 3.5, Block on 14:30');

      expect(result.hasError, true);
      expect(result.errorMessage, contains('VUT'));
    });

    test('returns error when Block On is missing', () {
      final result = parser.parse('HOBBS 3.5, VUT 2.75');

      expect(result.hasError, true);
      expect(result.errorMessage, contains('Block On'));
    });
  });

  group('VoiceCommandParser - Start/End Mode', () {
    test('parses start/end mode command', () {
      final result = parser.parse(
        'HOBBS start 1234.5 end 1238.0, VUT start 890 end 893, Block on 14:30',
      );

      expect(result.hasError, false);
      expect(result.data, isNotNull);
      expect(result.data!.mode, InputMode.readings);
      expect(result.data!.hobbsStart, 1234.5);
      expect(result.data!.hobbsEnd, 1238.0);
      expect(result.data!.vutStart, 890.0);
      expect(result.data!.vutEnd, 893.0);
      expect(result.data!.blockOnUtc, const TimeOfDay(hour: 14, minute: 30));
    });

    test('parses from/to syntax', () {
      final result = parser.parse(
        'HOBBS from 1234.5 to 1238.0, VUT from 890 to 893, Block on 14:30',
      );

      expect(result.hasError, false);
      expect(result.data!.mode, InputMode.readings);
      expect(result.data!.hobbsStart, 1234.5);
      expect(result.data!.hobbsEnd, 1238.0);
      expect(result.data!.vutStart, 890.0);
      expect(result.data!.vutEnd, 893.0);
    });

    test('parses with optional parameters', () {
      final result = parser.parse(
        'HOBBS start 1234.5 end 1238.0, VUT start 890 end 893, Block on 14:30, taxi 3 minutes, UTC plus 1',
      );

      expect(result.hasError, false);
      expect(result.data!.taxiMinutes, 3);
      expect(result.data!.utcOffsetHours, 1);
    });

    test('returns error when HOBBS start/end is incomplete', () {
      final result = parser.parse(
        'HOBBS start 1234.5, VUT start 890 end 893, Block on 14:30',
      );

      expect(result.hasError, true);
      expect(result.errorMessage, contains('HOBBS'));
    });

    test('returns error when VUT start/end is incomplete', () {
      final result = parser.parse(
        'HOBBS start 1234.5 end 1238.0, VUT start 890, Block on 14:30',
      );

      expect(result.hasError, true);
      expect(result.errorMessage, contains('VUT'));
    });
  });

  group('VoiceCommandParser - Mode Detection', () {
    test('detects direct mode when no start/end keywords', () {
      final result = parser.parse('HOBBS 3.5, VUT 2.75, Block on 14:30');

      expect(result.data!.mode, InputMode.direct);
    });

    test('detects readings mode with start/end keywords', () {
      final result = parser.parse(
        'HOBBS start 1234.5 end 1238.0, VUT start 890 end 893, Block on 14:30',
      );

      expect(result.data!.mode, InputMode.readings);
    });

    test('detects readings mode with from/to keywords', () {
      final result = parser.parse(
        'HOBBS from 1234.5 to 1238.0, VUT from 890 to 893, Block on 14:30',
      );

      expect(result.data!.mode, InputMode.readings);
    });
  });

  group('VoiceCommandParser - Time Formats', () {
    test('parses 24-hour time with colon', () {
      final result = parser.parse('HOBBS 3.5, VUT 2.75, Block on 14:30');

      expect(result.data!.blockOnUtc, const TimeOfDay(hour: 14, minute: 30));
    });

    test('parses 24-hour time without colon', () {
      final result = parser.parse('HOBBS 3.5, VUT 2.75, Block on 1430');

      expect(result.data!.blockOnUtc, const TimeOfDay(hour: 14, minute: 30));
    });

    test('parses time with "at" keyword', () {
      final result = parser.parse('HOBBS 3.5, VUT 2.75, Block on at 14:30');

      expect(result.data!.blockOnUtc, const TimeOfDay(hour: 14, minute: 30));
    });

    test('handles spoken time format', () {
      final result = parser.parse('HOBBS 3.5, VUT 2.75, Block on 14 30');

      expect(result.data!.blockOnUtc, const TimeOfDay(hour: 14, minute: 30));
    });
  });

  group('VoiceCommandParser - Number Normalization', () {
    test('normalizes single digit number words', () {
      final result = parser.parse(
        'HOBBS three point five, VUT two point seven five, Block on 14:30',
      );

      expect(result.data!.hobbsDiff, 3.5);
      expect(result.data!.vutDiff, 2.75);
    });

    test('normalizes number words in HOBBS/VUT values', () {
      // Speech-to-text engines typically output digits directly,
      // but we support basic number words for decimal values
      final result = parser.parse(
        'HOBBS three point five, VUT two point seven five, Block on 14:30',
      );

      expect(result.hasError, false);
      expect(result.data!.hobbsDiff, 3.5);
      expect(result.data!.vutDiff, 2.75);
      expect(result.data!.blockOnUtc, const TimeOfDay(hour: 14, minute: 30));
    });
  });

  group('VoiceCommandParser - Optional Parameters', () {
    test('parses taxi minutes', () {
      final result = parser.parse(
        'HOBBS 3.5, VUT 2.75, Block on 14:30, taxi 5 minutes',
      );

      expect(result.data!.taxiMinutes, 5);
    });

    test('parses taxi without "minutes" word', () {
      final result = parser.parse(
        'HOBBS 3.5, VUT 2.75, Block on 14:30, taxi 5',
      );

      expect(result.data!.taxiMinutes, 5);
    });

    test('parses UTC offset +1', () {
      final result = parser.parse(
        'HOBBS 3.5, VUT 2.75, Block on 14:30, UTC plus 1',
      );

      expect(result.data!.utcOffsetHours, 1);
    });

    test('parses UTC offset +2', () {
      final result = parser.parse(
        'HOBBS 3.5, VUT 2.75, Block on 14:30, UTC plus 2',
      );

      expect(result.data!.utcOffsetHours, 2);
    });

    test('handles missing optional parameters', () {
      final result = parser.parse('HOBBS 3.5, VUT 2.75, Block on 14:30');

      expect(result.data!.taxiMinutes, null);
      expect(result.data!.utcOffsetHours, null);
    });
  });

  group('VoiceCommandParser - Edge Cases', () {
    test('handles case-insensitive input', () {
      final result = parser.parse('hobbs 3.5, vut 2.75, block on 14:30');

      expect(result.hasError, false);
      expect(result.data!.hobbsDiff, 3.5);
      expect(result.data!.vutDiff, 2.75);
    });

    test('handles extra whitespace', () {
      final result = parser.parse('HOBBS  3.5,  VUT  2.75,  Block on  14:30');

      expect(result.hasError, false);
      expect(result.data!.hobbsDiff, 3.5);
      expect(result.data!.vutDiff, 2.75);
    });

    test('handles integer values as decimals', () {
      final result = parser.parse('HOBBS 3, VUT 2, Block on 14:30');

      expect(result.hasError, false);
      expect(result.data!.hobbsDiff, 3.0);
      expect(result.data!.vutDiff, 2.0);
    });
  });
}
