# Plan: Debug StallGuard DIAG Pin Detection in ESPHome

## Problem Summary
StallGuard stall detection works in Arduino (`diag_connection_test.ino`) but NOT in ESPHome, despite identical TMC2209 register configuration:
- Motor movement works fine in both
- SG_RESULT register (0x41) shows valid values (2-48) when motor stalls
- DIAG pin never goes HIGH in ESPHome (confirmed with multimeter)
- All register settings match: GCONF, TCOOLTHRS=0xFFFFF, TPWMTHRS=0, SGTHRS=100

## Root Cause Analysis

**Key difference between Arduino and ESPHome:**

| Aspect | Arduino (working) | ESPHome (not working) |
|--------|-------------------|----------------------|
| DIAG detection | `digitalRead()` polled in step loop | GPIO interrupt handler |
| Step generation | Direct `digitalWrite()` with `delayMicroseconds(600)` | Main loop with `yield()` calls |
| Step rate | ~833 steps/s | ~140 steps/s max (main loop limited) |

**Hypothesis:** The ESPHome component's GPIO interrupt may not be configured correctly, or the interrupt is firing but getting lost due to timing issues with the slower step rate.

## Debugging Strategy

### Step 1: Confirm Hardware Works (Arduino Re-test)
Upload `diag_connection_test.ino` to verify DIAG pin still triggers on stall.

```bash
cd /Users/jklein/GitHubRepos/arduino_scripts/automated_blinds/diag_connection_test
arduino-cli compile --fqbn esp32:esp32:esp32 .
arduino-cli upload -p /dev/cu.usbserial* --fqbn esp32:esp32:esp32 .
arduino-cli monitor -p /dev/cu.usbserial* -c baudrate=115200
```

**Expected:** ">>> STALL DETECTED!" messages when motor is blocked.

### Step 2: Add GPIO Polling as Alternative Detection

Modify ESPHome config to poll DIAG pin directly during movement (bypass interrupt):

```yaml
# Add binary sensor for direct DIAG pin reading
binary_sensor:
  - platform: gpio
    pin:
      number: GPIO25
      mode: INPUT_PULLDOWN
    name: "DIAG Pin State"
    id: diag_sensor
    on_press:
      - logger.log: "DIAG went HIGH (polling detected)!"
      - stepper.stop: blind_motor

# Modify interval to also check DIAG
interval:
  - interval: 50ms  # Faster polling
    then:
      - if:
          condition:
            lambda: 'return id(sg_monitoring);'
          then:
            - lambda: |-
                bool diag_state = digitalRead(25);
                uint32_t sg = id(blind_motor)->read_register(0x41) & 0x3FF;
                if (diag_state) {
                  ESP_LOGE("stall", "DIAG=HIGH SG=%d - STALL!", sg);
                  id(blind_motor)->stop();
                }
                ESP_LOGW("sg", "DIAG=%d SG=%d", diag_state, sg);
```

### Step 3: Check ESPHome Component Interrupt Setup

The external component may have issues with interrupt configuration. Check if:
1. Interrupt is attached with correct trigger mode (RISING vs HIGH)
2. Interrupt handler properly defers to main loop
3. DIAG pin configuration in GCONF is being overwritten

### Step 4: Alternative - Use SG_RESULT Threshold Instead of DIAG

If DIAG interrupt cannot be fixed, implement software-based stall detection:

```yaml
interval:
  - interval: 100ms
    then:
      - if:
          condition:
            stepper.is_running: blind_motor
          then:
            - lambda: |-
                uint32_t sg = id(blind_motor)->read_register(0x41) & 0x3FF;
                uint32_t sgthrs = id(blind_motor)->read_register(0x40);
                // Stall when SG_RESULT < 2 * SGTHRS
                if (sg < (2 * sgthrs)) {
                  ESP_LOGE("stall", "Software stall detect: SG=%d < threshold=%d", sg, 2*sgthrs);
                  id(blind_motor)->stop();
                }
```

## Files to Modify
- `/Users/jklein/GitHubRepos/arduino_scripts/automated_blinds/automated_blinds_esphome.yaml`

## Verification Plan

1. **Step 1 verification:** Arduino shows "STALL DETECTED" when motor blocked
2. **Step 2 verification:** ESPHome logs show `DIAG=1` when motor blocked
3. **Step 4 verification:** ESPHome logs show "Software stall detect" when motor blocked

## Recommended Approach

1. First do Step 1 to confirm hardware is good
2. Then implement Step 2 (GPIO polling) as it most closely matches the working Arduino approach
3. If GPIO polling shows DIAG going HIGH, the issue is interrupt-related
4. If GPIO polling also shows DIAG=0, there's a deeper register configuration issue
