import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QMLTermWidget 2.0

Window {
    id: preview
    title: qsTr("TV Design Preview")
    width: 1000
    height: 750
    minimumWidth: 480
    minimumHeight: 360
    color: "#050807"

    Image {
        id: cabinet
        anchors.fill: parent
        source: "qrc:/images/tv-frame-v1.png"
        fillMode: Image.PreserveAspectFit
        smooth: true
    }
    Loader {
        active: preview.visible
        x: (cabinet.width - cabinet.paintedWidth) / 2 + cabinet.paintedWidth * 0.22
        y: (cabinet.height - cabinet.paintedHeight) / 2 + cabinet.paintedHeight * 0.27
        width: cabinet.paintedWidth * 0.56
        height: cabinet.paintedHeight * 0.47
        sourceComponent: QMLTermWidget {
            id: liveTerminal
            font.family: "Menlo"
            font.pixelSize: Math.max(12, Math.min(18, preview.width / 65))
            colorScheme: "cool-retro-term"
            blinkingCursor: true
            layer.enabled: true
            layer.effect: ShaderEffect {
                property variant source
                fragmentShader: "qrc:/shaders/tv_preview_text.frag.qsb"
            }
            session: QMLTermSession {
                id: liveSession
                onFinished: preview.close()
            }
            Component.onCompleted: {
                liveSession.setShellProgram("/bin/zsh")
                liveSession.setArgs(["-l", "-c", "python3 \"$1\" 2; exec /bin/zsh -il", "tv-preview", previewFeedPath])
                liveSession.startShellProgram()
                forceActiveFocus()
            }
            Connections {
                target: preview
                function onActiveChanged() {
                    if (preview.active)
                        liveTerminal.forceActiveFocus()
                }
            }
        }
    }
    Shortcut {
        sequence: StandardKey.Close
        onActivated: preview.close()
    }
}
