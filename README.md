# Traktor Pro 4 — S5 Optimized QML Pack (2025 rewrite)

A refactored QML bundle for **Native Instruments Traktor Pro 4** that preserves a proven S5 performance workflow while cleaning the codebase, tightening compatibility, and upgrading the UI to modern level.

---

## What’s inside

### Controller features (S5)
- **Browse Encoder upgrades**  
  Turn = list navigation · **Shift+Turn** = cycle sort column · **Push** = load to focused deck · **Shift+Push** = pre-listen.
- **Loop Encoder ergonomics**  
  Turn = loop size step · **Push** = set in/out · **Shift** = fine step.
- **Touch Strips, performance-first**  
  Default = pitch bend · **Shift** = seek (fast, precise scrubbing).
- **Pads with clear layer logic**  
  Hotcues / Loops as primary layers; alternate layers on **Shift**. LEDs colored by cue type for instant recognition.

### On-device screens (S5 via S8 views)
- **Deck HUD clarity**  
  Compact header shows **Title → Artist → BPM → Key → Phase**, with predictable truncation so the important data stays visible.
- **Browser quality-of-life**  
  Custom **Header/Footer** expose active sort, column hints, and path breadcrumbs directly on the device—less laptop peeking.
- **Minimal ↔ Performance HUD**  
  Toggleable overlay density to match dark clubs or info-rich prep sessions.

### Under-the-hood improvements
- **Compatibility shim**  
  `Defines/AppPaths.qml` centralizes AppProperty paths so future NI renames require a single edit.
- **Import hygiene**  
  QML imports normalized to **QtQuick 2.0** where possible for TP4 stability.

---

## Fixes & polish

- Normalized S5 wiring across decks: consistent browse/loop/strip behavior on A–D.
- Aligned LED color mapping for hotcues and states; reduces ambiguous pad feedback.
- Restores enhanced S8 screen components (used by S5) trimmed in stock TP4 builds.

---

## UI mods at a glance

- **Deck Header**: tighter layout, persistent BPM/Key, predictable truncation.  
- **Browser**: on-screen sort indicator, column legend, path breadcrumbs.  
- **Phase/Sync bar**: compact drift check under the header.  
- **Theme-friendly**: legible in bright booths and dark rooms.

---

## Installation

1. Back up the existing Traktor QML folder: `Resources/qml`.  
2. Copy this package’s `qml/` into the TP4 installation:

   **macOS**  
   `/Applications/Traktor Pro 4.app/Contents/Resources/qml`

   **Windows**  
   `C:\Program Files\Native Instruments\Traktor Pro 4\Resources\qml`

3. Restart Traktor Pro 4.

> A `Settings.tsi` snapshot is included for reference (no overwrite required).

---

## Controller behavior (S5 quick sheet)

- **Browse Encoder**:  
  Turn = navigate · **Shift+Turn** = sort column · **Push** = load · **Shift+Push** = pre-listen  
- **Loop Encoder**:  
  Turn = size · **Push** = loop in/out · **Shift** = fine step  
- **Touch Strips**:  
  Default = bend · **Shift** = seek  
- **Pads**:  
  Primary = Hotcues/Loops · Alternate layers on **Shift** · LED colors reflect cue types

---

## Compatibility

- Built for **Traktor Pro 4**.  
- S5 uses S8 screen components; all bindings routed through `Defines/AppPaths.qml` to cushion NI property name changes.  
- QML imports favor **QtQuick 2.0** to avoid version-pin issues in TP4.

---

## File map

```
qml/
  CSI/S5/                # S5 mapping modules (encoders, pads, side, mixer, deck)
  CSI/S8/                # S8 mapping modules (deck, mixer, channel)
  CSI/Common/            # Shared modules (Deck_S8Style, BrowserModule, Settings)
  Screens/S8/            # Deck & Browser UI used by S5 and S8 screens
  Defines/               # Global QML definitions (ScreenView, LoopSize, PadsMode, etc.)
  Helpers/               # Utilities (LED maps, DeckHelpers, Settings.js, FileSystem.js)
  Settings/              # Customization modules (CustomWaveform, DeckHeader, PadFXs)
README.md
Settings.tsi             # Preferences snapshot (reference)
```

---

## Roadmap (optional add-ons)

- Single-gesture HUD toggle (bindable) for Minimal/Performance.  
- Daylight/Club theme presets that flip multiple visual settings at once.  
- Per-deck role profiles (e.g., A/B track, C/D stems) with automatic HUD & pad-layer tweaks.

---

