import CSI 1.0
import QtQuick 2.0

import "../../../Defines"
import "../../../Helpers/FileSystem.js" as FS
import "../../../Helpers/Settings.js" as Settings

Module {
    id: settingsMGR
    property string device;

    MappingPropertyDescriptor { id: autoImport; path: "mapping.settings.autoimport"; type: MappingPropertyDescriptor.Boolean; value: true }
    MappingPropertyDescriptor { id: autoExport; path: "mapping.settings.autoexport"; type: MappingPropertyDescriptor.Boolean; value: true }

    // Traktor root path
    AppProperty { id: root; path: "app.traktor.settings.paths.root" }
    MappingPropertyDescriptor { id: osType; path: "mapping.state.osType"; type: MappingPropertyDescriptor.Integer; value: 0 }

    //HeaderText Settings
    MappingPropertyDescriptor { id: displayTopLeft; path: "mapping.state.displayTopLeft"; type: MappingPropertyDescriptor.Integer; value: 0 }
    MappingPropertyDescriptor { id: displayTopMid; path: "mapping.state.displayTopMid"; type: MappingPropertyDescriptor.Integer; value: 0 }
    MappingPropertyDescriptor { id: displayTopRight; path: "mapping.state.displayTopRight"; type: MappingPropertyDescriptor.Integer; value: 0 }

    MappingPropertyDescriptor { id: displayMidLeft; path: "mapping.state.displayMidLeft"; type: MappingPropertyDescriptor.Integer; value: 5 }
    MappingPropertyDescriptor { id: displayMidMid; path: "mapping.state.displayMidMid"; type: MappingPropertyDescriptor.Integer; value: 2 }
    MappingPropertyDescriptor { id: displayMidRight; path: "mapping.state.displayMidRight"; type: MappingPropertyDescriptor.Integer; value: 0 }

    MappingPropertyDescriptor { id: displayBottomLeft; path: "mapping.state.displayBottomLeft"; type: MappingPropertyDescriptor.Integer; value: 0 }
    MappingPropertyDescriptor { id: displayBottomMid; path: "mapping.state.displayBottomMid"; type: MappingPropertyDescriptor.Integer; value: 6 }
    MappingPropertyDescriptor { id: displayBottomRight; path: "mapping.state.displayBottomRight"; type: MappingPropertyDescriptor.Integer; value: 7 }

    //MixerFX Settings
    MappingPropertyDescriptor { id: mixerFXAssigned1; path: "mapping.state.mixerFXAssigned1"; type: MappingPropertyDescriptor.Integer; value: 0 }
    MappingPropertyDescriptor { id: mixerFXAssigned2; path: "mapping.state.mixerFXAssigned2"; type: MappingPropertyDescriptor.Integer; value: 0 }
    MappingPropertyDescriptor { id: mixerFXAssigned3; path: "mapping.state.mixerFXAssigned3"; type: MappingPropertyDescriptor.Integer; value: 0 }
    MappingPropertyDescriptor { id: mixerFXAssigned4; path: "mapping.state.mixerFXAssigned4"; type: MappingPropertyDescriptor.Integer; value: 0 }

    //KeyNotation Settings
    MappingPropertyDescriptor { id: keyNotationDisplayed; path: "mapping.state.keyNotationDisplayed"; type: MappingPropertyDescriptor.Integer; value: 0 }
    MappingPropertyDescriptor { id: keyNotationExported; path: "mapping.state.keyNotationExported"; type: MappingPropertyDescriptor.Integer; value: 0 }
    MappingPropertyDescriptor { id: keyNotationExportedByPass; path: "mapping.state.keyNotationExportedByPass"; type: MappingPropertyDescriptor.Integer; value: 0 }

    // Example of Traktor's macOS settings file path - Users:<username>:Documents:Native Instruments:Traktor 3.X
    // Example of Traktor's Windows settings file path - C:\Users\<username>\Documents\Native Instruments\Traktor 3.X

    function readTraktorSettings() {
        console.log("Reading Traktor Settings.tsi file...")
        const filePath = FS.filePath(root.value, "Traktor Settings.tsi");
        FS.open(filePath).then((settings) => assignTraktorSettings(settings)).catch((error) => {
            console.log("An error occured while loading Traktor Settings.tsi file... Error:\n", error)
            throw error
        })
    }

    //Extract different Traktor settings from TraktorSettings.tsi file
    function assignTraktorSettings(xml) {
        console.log("Assigning Traktor settings...")
        // console.log("RECEIVED XML:", xml)
        //Track Deck layout
        Settings.assignTSISetting(xml, "Fileinfo.Top.Left", displayTopLeft)
        Settings.assignTSISetting(xml, "Fileinfo.Top.Mid",  displayTopMid)
        Settings.assignTSISetting(xml, "Fileinfo.Top.Right", displayTopRight)

        Settings.assignTSISetting(xml, "Fileinfo.Mid.Left", displayMidLeft)
        Settings.assignTSISetting(xml, "Fileinfo.Mid.Mid", displayMidMid)
        Settings.assignTSISetting(xml, "Fileinfo.Mid.Right", displayMidRight)

        Settings.assignTSISetting(xml, "Fileinfo.Bottom.Left", displayBottomLeft)
        Settings.assignTSISetting(xml, "Fileinfo.Bottom.Mid", displayBottomMid)
        Settings.assignTSISetting(xml, "Fileinfo.Bottom.Right", displayBottomRight)

        //Mixer FX Names
        Settings.assignTSISetting(xml, "Audio.ChannelFX.1.Type", mixerFXAssigned1)
        Settings.assignTSISetting(xml, "Audio.ChannelFX.2.Type", mixerFXAssigned2)
        Settings.assignTSISetting(xml, "Audio.ChannelFX.3.Type", mixerFXAssigned3)
        Settings.assignTSISetting(xml, "Audio.ChannelFX.4.Type", mixerFXAssigned4)

        // Key Notation
        Settings.assignTSISetting(xml, "Browser.KeyNotation.Displayed", keyNotationDisplayed)
        Settings.assignTSISetting(xml, "Browser.KeyNotation.Exported", keyNotationExported)
        Settings.assignTSISetting(xml, "Browser.KeyNotation.Exported.ByPass", keyNotationExportedByPass)
    }

    function assignModSettings() {
        FS.exists(FS.filePath(FS.normalizedPath(root.value).concat("Settings"), `${device}.settings.json`)).then((exists) => {
            if (exists) {
                Settings.importSettings(root.value, device)
            } else {
                Settings.exportSettings(root.value, defaultSettings(), device)
            }
        })
    }

    function defaultSettings(device) {
        return {
            "others": {
                "autoimport": true,
                "autoexport": true
            }
        }
    }
}


