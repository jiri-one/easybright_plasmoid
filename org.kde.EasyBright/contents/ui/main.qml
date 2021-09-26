import QtQuick 2.0
import QtQuick.Layouts 1.1
import Qt.WebSockets 1.0
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaCore.IconItem {
    id: icon

    property int counterNum: 0
    property int step: 5
    property string konzole: "test"

    readonly property bool inPanel: (plasmoid.location === PlasmaCore.Types.TopEdge
        || plasmoid.location === PlasmaCore.Types.RightEdge
        || plasmoid.location === PlasmaCore.Types.BottomEdge
        || plasmoid.location === PlasmaCore.Types.LeftEdge)

    Layout.minimumWidth: {
        switch (plasmoid.formFactor) {
        case PlasmaCore.Types.Vertical:
            return 0;
        case PlasmaCore.Types.Horizontal:
            return height;
        default:
            return PlasmaCore.Units.gridUnit * 3;
        }
    }

    Layout.minimumHeight: {
        switch (plasmoid.formFactor) {
        case PlasmaCore.Types.Vertical:
            return width;
        case PlasmaCore.Types.Horizontal:
            return 0;
        default:
            return PlasmaCore.Units.gridUnit * 3;
        }
    }

    Layout.maximumWidth: inPanel ? PlasmaCore.Units.iconSizeHints.panel : -1;
    Layout.maximumHeight: inPanel ? PlasmaCore.Units.iconSizeHints.panel : -1;

    source: plasmoid.icon ? plasmoid.icon : "plasma"
    active: mouseArea.containsMouse

    PlasmaComponents.Label {
        id: counter
        text: counterNum.toString()
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        fontSizeMode: Text.Fit
        font.pointSize: counter.height
    }


    MouseArea {
        id: mouseArea

        //property bool wasExpanded: false

        anchors.fill: parent
        hoverEnabled: true
//        onPressed: wasExpanded = plasmoid.expanded
//        onClicked: plasmoid.expanded = !wasExpanded

        onWheel: {
            if (wheel.angleDelta.y > 0)
                if (counterNum <= (100 - step))
                    counterNum += step;
            if (wheel.angleDelta.y < 0)
                if (counterNum >= (0 + step))
                    counterNum -= step;
            socket_reconnect()
        }

    }

    PlasmaCore.DataSource {
        id: ds_ddcutil
        engine: 'executable'
        connectedSources: ["ddcutil get 10 --terse | pz 's.split()[3]'"]
        onNewData: {
            //socket_reconnect()
            counterNum = data.stdout;
        }
    }

    PlasmaCore.DataSource {
        id: ds_socket_server
        engine: 'executable'
        connectedSources: ["python /home/jiri/Workspace/EasyBright/easybright_plasmoid/org.kde.EasyBright/contents/handlers/websocket_server.py"]
    }

 function socket_reconnect() {
          socket.active = false;
          socket.active = true;
      }

    WebSocket {
        id: socket
        url: "ws://localhost:8888"
        active: true
        //onTextMessageReceived: {
            //counterNum = message
        //}
        onStatusChanged: if (socket.status == WebSocket.Error) {
                             console.log("Error: " + socket.errorString)
                         } else if (socket.status == WebSocket.Open) {
                             socket.sendTextMessage(counter.text)
                         }
    }


    function setMessage(message) {
          counterNum = message
      }

    WebSocketServer {
        id: server
        listen: true
        port: 8889
        onClientConnected: {
            webSocket.onTextMessageReceived.connect(function(message) {
                //setMessage(qsTr("Server received message: %1").arg(message));
                socket_reconnect()
                setMessage(message)
                //webSocket.sendTextMessage(qsTr("Hello Client!"));
            });
        }
        onErrorStringChanged: {
            appendMessage(qsTr("Server error: %1").arg(errorString));
        }

    }
}

