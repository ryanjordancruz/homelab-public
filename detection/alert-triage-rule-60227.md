# Alert Triage: Wazuh Rule 60227, External Device Recognized

## Summary

| Field | Details |
|-------|---------|
| Date | 2026-08-10 |
| Rule | 60227, "A new external device was recognized by the system" (level 8) |
| Source event | Windows Security Event ID 6416 (PnP activity) |
| Agent | `<WINDOWS_AGENT_NAME>` |
| Occurrences | 9 alerts in 40 seconds |
| Disposition | **Closed: benign true positive** |

A real alert, not a simulation. A burst of device-recognition alerts fired on my monitored Windows endpoint, and I worked it the way a SOC analyst would, from the raw log fields to a verified root cause on the physical machine.

---

## Alert Evidence (as received)

| Field | Value |
|-------|-------|
| Device class | Keyboard (HID) |
| Device description | HID Keyboard Device |
| Device ID | `HID\VirtualDevice&10&Col03\...` |
| Vendor ID | `VID_1B1C` |
| Subject | `<HOSTNAME>$` / SYSTEM (S-1-5-18) |

---

## 1. Initial Triage

Level 8 is moderate: worth a look, but not grounds to assume an incident.

The first field I checked was **Subject**, which showed the machine account running as SYSTEM instead of a logged-in user. That isn't a red flag here. Plug and Play device enumeration is a kernel-level operation and always logs under SYSTEM, whether the device is legitimate or not, so I set it aside as expected noise.

## 2. Investigation

Two details in the raw fields stood out before I touched any hardware:

- **`VID_1B1C` resolves to Corsair** in a USB vendor ID lookup. That didn't match the two USB peripherals I first thought of (a headset dongle and a mouse dongle).
- **The bus enumerator is `HID\VirtualDevice`**, not a physical bus path. That suggests a software-created HID node, not a newly plugged-in device.

Then I checked the physical machine, because the hardware is the ground truth:

- A **Corsair RGB keyboard** is wired directly into the PC. That's a third device I hadn't considered at first. The vendor ID belongs to hardware I own.
- All 9 events fell within 40 seconds of the PC powering on, lining up with the keyboard's RGB lighting starting up.

## 3. Root Cause

At boot, the keyboard's lighting profile initializes and the Corsair driver renegotiates the device's HID collections. The keyboard exposes several interfaces (standard input, media controls, vendor-specific lighting control), and `Col03` is one of them. Each renegotiation can fire Event 6416 on its own, so you get a short burst instead of one clean event.

## 4. MITRE ATT&CK Consideration

Device-recognition events can map to **T1200 (Hardware Additions)** when they represent unauthorized physical hardware. I ruled it out:

- The device is owned and was physically verified.
- The pattern doesn't fit a hardware implant: a known vendor ID, a virtual HID enumerator, and a burst tied to power-on that repeats for the same device at every boot.

## 5. Disposition

**Benign true positive.** The rule worked correctly and detected expected activity from known hardware. No indicators of compromise. No further action needed.

## 6. Recommendation

This keyboard will re-enumerate on every boot, adding a recurring level 8 alert to the queue. A Wazuh rule exception keyed to this specific device ID and vendor ID pair would lower or suppress that one device, while leaving rule 60227 fully active for any device that hasn't been baselined.

---

## Skills Demonstrated

- Reading raw Windows event fields and separating expected noise from real signal
- Vendor ID lookup and device enumeration analysis
- Verifying findings against ground truth instead of relying on log inference alone
- Mapping to MITRE ATT&CK and ruling a technique out with reasoning
- Writing a clear disposition and a tuning recommendation
