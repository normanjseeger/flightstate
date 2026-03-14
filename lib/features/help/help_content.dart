/// Help content for FlightState app
/// Contains brief and detailed explanations for all aviation terms and features.

class HelpContent {
  // Takeoff Performance Help
  static const pressureAltitudeBrief = '''
Altitude corrected for non-standard atmospheric pressure.

Quick Formula:
PA = Field Elevation + (29.92 - QNH) × 1000 ft

Example: At sea level with QNH 30.12:
PA = 0 + (29.92 - 30.12) × 1000 = -200 ft
''';

  static const pressureAltitudeDetailed = '''
**Pressure Altitude** is the altitude in the International Standard Atmosphere (ISA) at which the pressure is the same as the actual atmospheric pressure.

**Why it matters:**
Aircraft performance charts are based on standard atmospheric conditions. Pressure altitude allows you to correct your field elevation for non-standard pressure.

**How to calculate:**

1. **From QNH (Altimeter Setting):**
   PA = Field Elevation + (29.92 - QNH) × 1000 ft

   Example:
   - Field elevation: 1,500 ft MSL
   - QNH: 30.12 inHg
   - PA = 1,500 + (29.92 - 30.12) × 1000
   - PA = 1,500 - 200 = 1,300 ft

2. **From Altimeter:**
   Set altimeter to 29.92 inHg (standard pressure)
   Read the indicated altitude = Pressure Altitude

3. **From QFE (if available):**
   PA = (1013.25 - QFE in hPa) × 30 ft

**Quick Reference:**
- Higher QNH → Lower pressure altitude → Better performance
- Lower QNH → Higher pressure altitude → Degraded performance

**Rule of Thumb:**
For every 1 inHg change from 29.92:
- Pressure altitude changes by ~1,000 ft
- Performance changes accordingly
''';

  static const aircraftMassBrief = '''
Total weight of the aircraft at takeoff.

Components:
• Basic Empty Weight (aircraft + fixed equipment)
• Pilot + Passengers
• Fuel
• Baggage

Check that you're within max takeoff weight!
''';

  static const aircraftMassDetailed = '''
**Aircraft Mass (Takeoff Weight)** is the total weight of the aircraft at the moment of takeoff.

**Components:**

1. **Basic Empty Weight (BEW):**
   - Airframe
   - Engine(s)
   - Fixed equipment (radios, instruments, etc.)
   - Unusable fuel and oil

2. **Useful Load:**
   - Pilot + passengers
   - Usable fuel
   - Baggage and cargo
   - Removable equipment

**Calculation:**
Takeoff Weight = BEW + Pilot + Passengers + Fuel + Baggage

**Weight Limits:**
- **Maximum Takeoff Weight (MTOW):** Never exceed this!
- **Maximum Landing Weight (MLW):** May be lower than MTOW
- **Maximum Zero Fuel Weight (MZFW):** Max weight before adding fuel

**Performance Impact:**
- Higher weight → Longer takeoff distance
- Higher weight → Reduced climb performance
- Higher weight → Higher stall speed
- Higher weight → Longer landing distance

**Center of Gravity (CG):**
Weight must be properly distributed within CG limits. Heavy weight with improper CG is dangerous!

**Weight & Balance:**
Always complete a weight & balance calculation before flight, especially with:
- Multiple passengers
- Full fuel tanks
- Heavy baggage
- Any load near maximum weight
''';

  static const groundRollBrief = '''
Distance from brake release to liftoff.

This is the runway length needed just to get airborne, not including any obstacles.

Surface conditions (wet, soft, grass) increase ground roll significantly.
''';

  static const groundRollDetailed = '''
**Ground Roll** is the horizontal distance traveled from the point where brakes are released until the aircraft lifts off the runway.

**What it includes:**
- Acceleration from standstill to rotation speed (Vr)
- Rotation and liftoff

**What it does NOT include:**
- Distance to clear obstacles
- Safety margins
- Climb distance

**Factors that increase ground roll:**

1. **Aircraft Factors:**
   - Higher weight
   - Aft center of gravity
   - Flaps retracted or minimal flap setting

2. **Environmental Factors:**
   - High pressure altitude (less dense air)
   - High temperature (less dense air)
   - Tailwind component
   - Upslope runway

3. **Runway Conditions:**
   - Wet surface (+15% to +25%)
   - Grass (+20% to +40%)
   - Soft field (+50% or more)
   - Contaminated (standing water, slush, snow)

4. **Technique:**
   - Soft field takeoff (longer roll)
   - Partial power during lineup (increases distance)

**Calculating Required Runway:**
Available runway must be GREATER than:
Ground Roll × Safety Factor

Typical safety factors:
- Paved, dry: 1.25× to 1.5×
- Grass, dry: 1.5× to 2.0×
- Short field: Use 50-ft obstacle distance instead

**Performance Charts:**
Your POH/AFM provides ground roll charts based on:
- Pressure altitude
- Temperature
- Aircraft weight
- Flap setting
- Runway slope
- Wind component

Always use conservative assumptions when interpolating!
''';

  static const takeoffDistance50ftBrief = '''
Total distance from brake release to clear a 50-foot obstacle.

Includes:
• Ground roll (distance to liftoff)
• Climb distance to 50 ft

This is the minimum runway length you need for a safe obstacle-clearance takeoff.
''';

  static const takeoffDistance50ftDetailed = '''
**Takeoff Distance to Clear 50-foot Obstacle** is the total horizontal distance from brake release to the point where the aircraft reaches 50 feet above the ground.

**Components:**

1. **Ground Roll:**
   Distance from brake release to liftoff

2. **Airborne Distance:**
   Distance traveled while climbing from ground to 50 ft AGL

**Why 50 feet?**
- Standard obstacle clearance reference height
- Typical height of trees, power lines, buildings at runway end
- Allows for safe clearance with margin

**Comparison with Ground Roll:**
Takeoff distance (50 ft) is typically 1.5× to 2.0× the ground roll.

Example:
- Ground roll: 1,000 ft
- Takeoff distance (50 ft): 1,500-2,000 ft

**When to use each:**

Use **Ground Roll** when:
- Runway has clear, flat surroundings
- No obstacles at departure end
- Maximum performance not required

Use **50-ft Obstacle Distance** when:
- Trees, buildings, or terrain near runway
- Short field operation
- Obstacle departure procedure required
- Conservative planning desired

**Factors affecting total distance:**

1. **All Ground Roll factors** (see Ground Roll help), PLUS:

2. **Climb Performance:**
   - Engine power
   - Climb speed (Vx vs Vy)
   - Aircraft configuration
   - Density altitude

3. **Technique:**
   - Short field technique (Vx climb): Minimum distance
   - Normal takeoff (Vy climb): Longer distance, better cooling
   - Soft field technique: May increase total distance

**Safety Margins:**

Minimum required runway = Takeoff Distance × Safety Factor

Recommended factors:
- Hard surface, no obstacles: 1.25×
- Hard surface, obstacles: 1.5×
- Grass or soft field: 2.0× or more
- High density altitude: Add 2.0× factor
- Student/low-experience pilot: Add additional margin

**Performance Degradation:**

Each 1,000 ft density altitude increase:
→ ~10-15% longer takeoff distance

Each 10% over max gross weight:
→ ~20% longer takeoff distance

**Abort Decision Point:**
Calculate your "go/no-go" point:
- If not airborne by 70% of available runway
- ABORT the takeoff
- Remaining runway must be enough to stop safely
''';

  // Flight Times Help
  static const directModeBrief = '''
Enter the actual flight time directly in hours.

Example:
• Total time: 3.5 hours (HOBBS meter difference)
• Tachometer time: 2.75 hours (Engine time)

The app calculates block off time by subtracting taxi time from total time.
''';

  static const directModeDetailed = '''
**Direct Mode (Difference Mode)** allows you to enter the actual flight times as decimal hours, without needing to record meter readings.

**How it works:**

1. **Note your times after flight:**
   - Total time (HOBBS difference): e.g., 3.5 hours
   - Tachometer time (engine hours): e.g., 2.75 hours
   - Block on time: Time you arrived at parking

2. **App calculates:**
   - Block off time = Block on - Total time
   - Engine start time = Block off - Taxi time
   - Flight time = Tachometer time (engine running time)

**When to use Direct Mode:**
- You already calculated the time differences
- You want quick entry without meter readings
- You're retrospectively logging flights
- Your meters don't reset (always accumulating)

**Example:**

Input:
- Block on time: 14:30 UTC
- Total time: 3.5 hours
- Tachometer time: 2.75 hours
- Taxi time: 10 minutes

Calculated:
- Block off: 14:30 - 3:30 = 11:00 UTC
- Engine start: 11:00 - 0:10 = 10:50 UTC
- Flight time: 2.75 hours = 2:45

**Time Format:**
Enter times as decimal hours:
- 1.5 = 1 hour 30 minutes
- 2.25 = 2 hours 15 minutes
- 0.75 = 45 minutes

**Converting minutes to decimal:**
Minutes ÷ 60 = Decimal hours
- 15 min = 0.25 hours
- 30 min = 0.5 hours
- 45 min = 0.75 hours
''';

  static const startEndModeBrief = '''
Record meter readings before and after flight.

Enter:
• Total time start: e.g., 8552.3
• Total time end: e.g., 8555.8
• Tachometer start: e.g., 7234.5
• Tachometer end: e.g., 7237.2

The app automatically calculates the differences and flight times.
''';

  static const startEndModeDetailed = '''
**Start/End Mode (Meter Reading Mode)** lets you record the actual meter readings from your aircraft instruments, and the app calculates everything else.

**How it works:**

**Before Engine Start:**
1. Note **Total time meter** (HOBBS): e.g., 8552.3
2. Note **Tachometer meter**: e.g., 7234.5

**After Shutdown:**
1. Note **Total time meter** (HOBBS): e.g., 8555.8
2. Note **Tachometer meter**: e.g., 7237.2
3. Note **Block on time**: Time you arrived at parking

**App calculates:**
- Total time = End - Start (8555.8 - 8552.3 = 3.5 hours)
- Tachometer time = End - Start (7237.2 - 7234.5 = 2.7 hours)
- Block off time = Block on - Total time
- Engine times and other values

**When to use Start/End Mode:**
- You want to record actual meter readings
- Required for maintenance tracking
- Official flight time logging
- Accurate billing/rental tracking
- You record meters during walk-around

**HOBBS Meter (Total Time):**
- Records time with master switch ON
- Usually starts at engine start
- Runs continuously while electrical system active
- Used for aircraft rental billing
- Required for maintenance intervals

**Tachometer Meter (Engine Time):**
- Records actual engine running time
- May run slower at idle, faster at high RPM
- Reflects actual engine wear
- Used for engine maintenance (oil changes, overhauls)
- More accurate for engine life tracking

**Voice Input Support:**

You can dictate meter readings digit-by-digit:

Example:
"Total time start 8 5 5 2 decimal 3 end 8 5 5 5 decimal 8"

The app understands:
- Individual digits: "8 5 5 2"
- Decimal separators: "decimal" or "point"
- Full meter readings with 4-5 digits

**Tips:**

1. **Record before engine start:**
   - Meters are easier to read when engine isn't running
   - Avoids forgetting during busy startup

2. **Double-check readings:**
   - Meter readings are permanent records
   - Used for maintenance and billing
   - Errors can affect aircraft status

3. **Record in logbook:**
   - Transfer meter readings to official logbook
   - Provides backup record
   - Required for maintenance tracking

4. **Consistency:**
   - Always use the same meters
   - Some aircraft have multiple meters
   - Note which meter you're using (HOBBS vs flight time)
''';
}
