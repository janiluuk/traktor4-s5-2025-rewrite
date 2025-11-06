import CSI 1.0
import QtQuick 2.0

Module
{
  id: module
  property bool shift: false
  property bool active: false
  property int deckIdx: 0
  property string surface: ""

  property int nudgePushAction: 0
  property int nudgeShiftPushAction: 0

  // Nudge buttons actions
  readonly property int nudgeTempoBend:            0
  readonly property int nudgeBeatjump:             1
  readonly property int nudgeTriggerHotcue_56:     2
  readonly property int nudgeDeleteHotcue_56:      3

  TransportSection
  {
    name: "transport"
    channel: module.deckIdx

    // syncColor: Color.Blue
    // fluxColor: Color.Blue
    // masterColor: Color.Blue
    syncColor: Color.Cyan
    fluxColor: Color.Red
    masterColor: Color.Red
  }

  AppProperty { id: deckIsLoaded; path: "app.traktor.decks." + deckIdx + ".is_loaded" }

  Beatgrid        { name: "beatgrid";   channel: module.deckIdx }
  ButtonBeatjump  { name: "beatjump";   channel: module.deckIdx }
  ButtonTempoBend { name: "tempo_bend"; channel: module.deckIdx }
  Hotcues         { name: "hotcues";    channel: module.deckIdx }

  SwitchTrigger { name: "sync_inverter" }
  SwitchTimer { name: "sync_inverter_timer"; setTimeout: 200 }
  
  readonly property real timeTolerance: 0.001 // seconds
  property bool activeCueWithPlayhead: Math.abs(activeCuePositionProp.value - playheadPositionProp.value) < timeTolerance
  AppProperty { id: activeCuePositionProp; path: "app.traktor.decks." + module.deckIdx + ".track.cue.active.start_pos"; }
  AppProperty { id: playheadPositionProp; path: "app.traktor.decks." + module.deckIdx + ".track.player.playhead_position" }
  AppProperty { id: deckPlayingProp; path: "app.traktor.decks." + module.deckIdx + ".play"; }
  AppProperty { id: deckCueingProp; path: "app.traktor.decks." + module.deckIdx + ".cue"; }
  AppProperty { id: deckRunningProp; path: "app.traktor.decks." + module.deckIdx + ".running" }
  AppProperty { id: deckSeekProp; path: "app.traktor.decks." + module.deckIdx + ".seek" }
  AppProperty { id: deckTypeProp; path: "app.traktor.decks." + module.deckIdx + ".type"; }
  AppProperty { id: gridTapProp; path: "app.traktor.decks." + module.deckIdx + ".track.grid.tap" }
  AppProperty { id: gridLockedProp; path: "app.traktor.decks." + module.deckIdx + ".track.grid.lock_bpm" }

  WiresGroup
  {
    enabled: module.active

    // Wire { from: "%surface%.play";      to: "transport.play"            ; enabled: !module.shift }
    // Wire { from: "%surface%.play";      to: "beatgrid.tap"              ; enabled:  module.shift }

    WiresGroup {
      enabled: (deckIsLoaded.value || deckTypeProp.value == DeckType.Remix)
      Wire { enabled: !module.shift; from: "%surface%.play"; to: ButtonScriptAdapter { color: Color.Green; brightness: deckPlayingProp.value; onPress: { deckPlayingProp.value = !deckPlayingProp.value } } }
      Wire { enabled: module.shift && !gridLockedProp.value && (deckTypeProp.value == DeckType.Track || deckTypeProp.value == DeckType.Stem); from: "%surface%.play"; to: ButtonScriptAdapter { color: Color.White; brightness: 0.0; onPress: { gridTapProp.value = !gridTapProp.value; brightness = 1.0 }onRelease: { brightness = 0.0 } } }
      // Wire { from: "%surface%.play"; to: ButtonScriptAdapter { color: Color.Green; brightness: 1.0 } enabled: deckPlayingProp.value }
      // Wire { enabled: module.shift && !gridLockedProp.value; from: "%surface%.play"; to: TriggerPropertyAdapter { path: "app.traktor.decks." + module.deckIdx + ".track.grid.tap" } }
    }

    Wire { from: "%surface%.sync";       to: "sync_inverter.input"      ; enabled: !module.shift }
    Wire { from: "%surface%.sync";       to: "sync_inverter_timer.input" ; enabled: !module.shift }
    Wire { from: "sync_inverter.output"; to: "transport.sync"           ; enabled: !module.shift }
    Wire { from: "%surface%.sync";       to: "transport.master"         ; enabled:  module.shift }

    Wire {
      enabled: !module.shift
      from: Or
      {
        inputs:
        [
          "sync_inverter_timer.output",
          "%surface%.loop.push",
          "%surface%.loop.is_turned"
        ]
      }
      to: "sync_inverter.reset"
    }

    Wire { from: "%surface%.rev";       to: "transport.flux_reverse"    ; enabled: !module.shift }
    Wire { from: "%surface%.rev";       to: "transport.flux"            ; enabled:  module.shift }
    // Wire { from: "%surface%.cue";       to: "transport.cue"             ; enabled: !module.shift }
    // Wire { from: "%surface%.cue";       to: "transport.return_to_zero"  ; enabled:  module.shift }

    WiresGroup {
      enabled: (deckIsLoaded.value || deckTypeProp.value == DeckType.Remix)
      Wire { enabled: !module.shift; from: "%surface%.cue"; to: ButtonScriptAdapter { color: Color.Yellow; brightness: activeCueWithPlayhead; onPress: { deckCueingProp.value = true } onRelease: { deckCueingProp.value = false } } }
      Wire { enabled: !module.shift && deckPlayingProp.value; from: "%surface%.cue"; to: ButtonScriptAdapter { color: Color.Yellow; brightness: activeCueWithPlayhead; } }
      Wire { enabled: module.shift; from: "%surface%.cue"; to: ButtonScriptAdapter { color: Color.Yellow; brightness: 0.0; onPress: { deckSeekProp.value = 0; brightness = 1.0 } onRelease: { brightness = 0.0 } } }
      Wire { enabled: !module.shift && !deckPlayingProp.value; from: "%surface%.cue.led"; to: "CueBlinker" }
    }
    
    WiresGroup
    {
      enabled: (!module.shift && nudgePushAction == nudgeTempoBend) || (module.shift && nudgeShiftPushAction == nudgeTempoBend)

      Wire { from: "%surface%.nudge_slow"; to: "tempo_bend.down" }
      Wire { from: "%surface%.nudge_fast"; to: "tempo_bend.up"   }
    }

    WiresGroup
    {
      enabled: !module.shift && (nudgePushAction == nudgeBeatjump)

      Wire { from: DirectPropertyAdapter { path: "mapping.settings.nudge_push_size"; input: false } to: "beatjump.size" }

      Wire { from: "%surface%.nudge_slow"; to: "beatjump.backward" }
      Wire { from: "%surface%.nudge_fast"; to: "beatjump.forward"  }
    }

    WiresGroup
    {
      enabled: !module.shift && (nudgePushAction == nudgeTriggerHotcue_56)

      Wire { from: "%surface%.nudge_slow"; to: "hotcues.5.trigger" }
      Wire { from: "%surface%.nudge_fast"; to: "hotcues.6.trigger" }
    }

    WiresGroup
    {
      enabled: module.shift && (nudgeShiftPushAction == nudgeBeatjump)

      Wire { from: DirectPropertyAdapter { path: "mapping.settings.nudge_shiftpush_size"; input: false } to: "beatjump.size" }

      Wire { from: "%surface%.nudge_slow"; to: "beatjump.backward" }
      Wire { from: "%surface%.nudge_fast"; to: "beatjump.forward"  }
    }

    WiresGroup
    {
      enabled: module.shift && (nudgeShiftPushAction == nudgeDeleteHotcue_56)

      Wire { from: "%surface%.nudge_slow"; to: "hotcues.5.delete" }
      Wire { from: "%surface%.nudge_fast"; to: "hotcues.6.delete" }
    }
  }
  
  //Play should BLINK When Deck is Loaded & Paused or warn when Cueing but not playing
  Wire { from: "%surface%.play.led"; to: "PlayBlinkerStopped"; enabled: module.active && (deckIsLoaded.value || deckTypeProp.value == DeckType.Remix) }
  Wire { from: "PlayBlinkerStopped.trigger"; to: ExpressionAdapter { type: ExpressionAdapter.Boolean; expression: module.active && !module.shift && !deckPlayingProp.value && (!deckCueingProp.value || (deckCueingProp.value && !deckRunningProp.value)) && (deckIsLoaded.value || deckTypeProp.value == DeckType.Remix) } }
  Blinker { name: "PlayBlinkerStopped"; cycle: 1000; color: Color.Green; defaultBrightness: 1.0; blinkBrightness: 0.0 }
  Wire { from: "%surface%.play.led"; to: "PlayBlinkerCueing"; enabled: module.active && (deckIsLoaded.value || deckTypeProp.value == DeckType.Remix) }
  Wire { from: "PlayBlinkerCueing.trigger"; to: ExpressionAdapter { type: ExpressionAdapter.Boolean; expression: module.active && !module.shift && !deckPlayingProp.value && deckCueingProp.value && deckRunningProp.value && (deckIsLoaded.value || deckTypeProp.value == DeckType.Remix) } }
  Blinker { name: "PlayBlinkerCueing"; cycle: 250; color: Color.Green; defaultBrightness: 1.0; blinkBrightness: 0.0 }

  //Cue should BLINK when deck is Stopped and not in the Active Cue
  // Blinker { name: "CueBlinker"; cycle: 500; color: Color.Yellow; defaultBrightness: activeCueWithPlayhead; blinkBrightness: !activeCueWithPlayhead } //CUE should BLINK when paused and out of Active Cue Position
  Blinker { name: "CueBlinker"; cycle: 500; color: Color.Yellow; defaultBrightness: 1.0; blinkBrightness: 0.0 } //CUE should BLINK when paused and out of Active Cue Position
  // Wire { from: "CueBlinker.trigger"; to: ExpressionAdapter { type: ExpressionAdapter.Boolean; expression: module.active && !module.shift && !deckRunningProp.value && !activeCueWithPlayhead && (deckIsLoaded.value || deckTypeProp.value == DeckType.Remix) } }
  Wire { from: "CueBlinker.trigger"; to: ExpressionAdapter { type: ExpressionAdapter.Boolean; expression: !activeCueWithPlayhead } }
  
}
