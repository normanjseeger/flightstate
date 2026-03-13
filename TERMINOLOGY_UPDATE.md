# Terminology Update Summary

## Changes Made

### 1. App Name: acf_perf → FlightState

**File: `README.md`**
- Updated project name from "acf_perf" to "FlightState"
- Updated description to: "FlightState — Aircraft Flight Calculation Toolbox for GA pilots"

### 2. Aviation Term: VUT → Flight time

All user-facing references to "VUT" have been changed to "Flight time" throughout the application.

#### Files Updated:

**`lib/features/flight_times/views/flight_times_view.dart`**
- Section header: "HOBBS & VUT" → "HOBBS & Flight time"
- Field labels:
  - "VUT (hours)" → "Flight time (hours)"
  - "VUT Start" → "Flight time Start"
  - "VUT End" → "Flight time End"
- Results display: "VUT" chip → "Flight time" chip
- Voice command examples:
  - "HOBBS 3.5, VUT 2.75..." → "HOBBS 3.5, Flight time 2.75..."
  - "VUT start 890 end 893" → "Flight time start 890 end 893"
- Help text: "Use HOBBS, VUT, and Block on..." → "Use HOBBS, Flight time, and Block on..."
- Comments updated

**`lib/features/flight_times/viewmodels/flight_times_viewmodel.dart`**
- Comments:
  - "Input mode for HOBBS/VUT values" → "Input mode for HOBBS/Flight time values"
  - "Effective VUT hours" → "Effective Flight time hours"
  - "VUT time formatted" → "Flight time formatted"
  - "Takeoff (UTC) = Arrival - VUT time" → "Takeoff (UTC) = Arrival - Flight time"
- Whisper API prompt: "VUT hours" → "Flight time hours"

**`lib/core/services/voice_command_parser.dart`**
- Comment: "VUT variations" → "Flight time variations"
- Error messages:
  - "VUT value is required. Example: 'VUT 2.75'" → "Flight time value is required. Example: 'Flight time 2.75'"
  - "VUT start and end values are required. Example: 'VUT start 890 end 893'" → "Flight time start and end values are required. Example: 'Flight time start 890 end 893'"

**`WHISPER_INTEGRATION.md`**
- All references to "VUT" replaced with "Flight time" throughout documentation

### Internal Code (Unchanged)

The following **internal code** elements were **intentionally kept as-is** for consistency:
- Variable names: `vutDiff`, `vutStart`, `vutEnd`, `vutHours`, `vutFormatted`
- Method names: `setVutDiff()`, `setVutStart()`, `setVutEnd()`
- Voice recognition regex: Still recognizes "vut" spoken word for backward compatibility

This maintains code consistency while updating all user-facing terminology.

## Verification

✅ **Flutter analysis**: No issues found
✅ **Compilation**: Successful
✅ **All user-facing text**: Updated to "Flight time"
✅ **All documentation**: Updated
✅ **App name**: Changed to FlightState

## Summary

All user-visible references have been updated:
- App name: **acf_perf** → **FlightState**
- Aviation term: **VUT** → **Flight time**

Internal code variable names remain unchanged for code consistency, but all UI labels, comments, documentation, and error messages now use the new terminology.
