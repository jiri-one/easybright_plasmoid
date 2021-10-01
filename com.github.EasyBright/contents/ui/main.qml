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
            console.log("")
        }
    }

    PlasmaCore.DataSource {
        id: ds_socket_server
        engine: 'executable'
        connectedSources: ["contents/websocket_server.py"]
    }

 function socket_reconnect() {
          socket.active = false;
          socket.active = true;
      }

    WebSocket {
        id: socket
        url: "ws://localhost:8888"
        active: false
        //onTextMessageReceived: {
            //counterNum = message
        //}
        onStatusChanged: if (socket.status == WebSocket.Error) {
                             console.log("Error: " + socket.errorString)
                         } else if (socket.status == WebSocket.Open) {
                             socket.sendTextMessage(counterNum)
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

