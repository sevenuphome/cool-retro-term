/*******************************************************************************
* Copyright (c) 2013-2021 "Filippo Scognamiglio"
* https://github.com/Swordfish90/cool-retro-term
*
* This file is part of cool-retro-term.
*
* cool-retro-term is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program.  If not, see <http://www.gnu.org/licenses/>.
*******************************************************************************/
import QtQuick 2.2
import QtMultimedia

import "menus"

QtObject {
    id: appRoot

    property ApplicationSettings appSettings: ApplicationSettings {
        onInitializedSettings: appRoot.createWindow()
    }

    property TimeManager timeManager: TimeManager {
        enableTimer: windowsModel.count > 0
    }

    property SoundEffect crtSound: SoundEffect {
        property bool enabled: appSettings.humSoundEnabled
        source: "qrc:/sounds/crt-hum-and-hiss.wav"
        loops: SoundEffect.Infinite
        volume: appSettings.humSoundVolume
        onEnabledChanged: enabled ? play() : stop()
        onStatusChanged: {
            if (appSettings.verbose)
                console.log("CRT sound status:", status)
            if (status === SoundEffect.Ready && enabled)
                play()
        }
        onPlayingChanged: if (appSettings.verbose) console.log("CRT sound playing:", playing)
    }

    property SoundEffect keySound: SoundEffect {
        source: "qrc:/sounds/mechanical-key.wav"
        volume: appSettings.typingSoundVolume
        muted: !appSettings.typingSoundEnabled
        onStatusChanged: if (appSettings.verbose) console.log("Keyboard sound status:", status)
    }

    property SettingsWindow settingsWindow: SettingsWindow {
        visible: false
    }

    property AboutDialog aboutDialog: AboutDialog {
        visible: false
    }

    property Component windowComponent: Component {
        TerminalWindow { }
    }

    property ListModel windowsModel: ListModel { }

    function createWindow() {
        var window = windowComponent.createObject(null)
        if (!window)
            return

        windowsModel.append({ window: window })
        window.show()
        window.requestActivate()
    }

    function closeWindow(window) {
        for (var i = 0; i < windowsModel.count; i++) {
            if (windowsModel.get(i).window === window) {
                windowsModel.remove(i)
                break
            }
        }

        window.destroy()

        if (windowsModel.count === 0) {
            appSettings.close()
        }
    }
}
