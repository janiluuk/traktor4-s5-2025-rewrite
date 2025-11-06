import CSI 1.0
import QtQuick 2.0

Module {

//-----------------------------------------------------------------------------------------------------------------------------------
// CUSTOMIZABLE TRACK DECK HEADER (In the Preferences Menu of the controller --> Global Options --> Deck Header --> "Traktor")
//-----------------------------------------------------------------------------------------------------------------------------------

    /*
    Here are the numbers that are associated to each entry:

        0:  "title",             1: "artist",		      2:  "release",
        3:  "mix",               4: "remixer",		      5:  "genre",
        6:  "track length",      7: "comment",		      8:  "comment2",
        9:  "label",             10: "catNo",		      11: "bitrate",
        12: "gain",              13: "elapsed time",      14: "remaining time",
        15: "beats",             16: "beats to next cue", 17: "sync/master indicator",
        18: "original bpm",      19: "bpm",               20: "stable bpm",
        21: "tempo",             22: "stable tempo",  	  23: "tempo range",
        24: "original key",      25: "resulting key",     26: "original keyText",
        27: "resulting keyText", 28: "remixBeats",        29: "remixQuantize",
        30: "capture source",    31: "mixerFX",           32: "mixerFXshort",
        33: "off"
    */

  property int topLeftState:      0;			property int topMiddleState:    14;			property int topRightState:     20;
  property int midLeftState:      1;			property int midMiddleState:    6;			property int midRightState:     22;
  property int bottomLeftState:   7;			property int bottomMiddleState: 5;			property int bottomRightState:  21;
}
