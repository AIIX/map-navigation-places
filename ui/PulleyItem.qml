import QtQuick 2.9
import QtQuick.Controls 2.2
import QtPositioning 5.12
import QtLocation 5.12
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.5 as Kirigami

Item {
 id: pulleyFrame
 anchors.left: parent.left
 anchors.right: parent.right
 anchors.bottom: parent.bottom
 height: parent.height / 2
 property bool opened: state === "PulleyExpanded"
 property bool closed: state === "PulleyClosed"
 property bool _isVisible: false
 property var barColor
 property alias model: pulleyListView.model
 property alias delegate: pulleyListView.delegate
 signal pulleyExpanded()
 signal pulleyClosed()

 function open() {
     pulleyFrame.state = "PulleyExpanded";
     pulleyExpanded();
     _isVisible = true
 }

 function close() {
     pulleyFrame.state = "PulleyClosed";
     pulleyListView.positionViewAtBeginning()
     pulleyClosed();
     _isVisible = false
 }

 states: [
     State {
         name: "PulleyExpanded"
         PropertyChanges { target: pulleyMenu; height: pulleyFrame.height - pulleyIconBar.height; }
         PropertyChanges { target: pulleyListView; interactive: true; }
         PropertyChanges { target: menudrawIcon; source: "go-down";}
     },
     State {
         name: "PulleyClosed"
         PropertyChanges { target: pulleyMenu; height: 0; }
         PropertyChanges { target: pulleyListView; interactive: false; }
         PropertyChanges { target: menudrawIcon; source: "go-up";}
     }
    ]


 transitions: [
     Transition {
         to: "*"
         NumberAnimation { target: pulleyMenu; properties: "height"; duration: 450; easing.type: Easing.OutCubic; }
     }
    ]

    Rectangle {
      id: pulleyIconBar
      anchors.bottom: pulleyMenu.top
      anchors.bottomMargin: 4
      height: Kirigami.Units.gridUnit * 0.40
      color: barColor
      width: root.width
        Kirigami.Icon {
                id: menudrawIcon
                visible: true
                anchors.centerIn: parent
                source: "go-up"
                width: Kirigami.Units.gridUnit * 1.25
                height: Kirigami.Units.gridUnit * 1.25
            }

        MouseArea{
            anchors.fill: parent
            propagateComposedEvents: true
            onClicked: {
                if (pulleyFrame.opened) {
                    pulleyFrame.close();
                } else {
                    pulleyFrame.open();
                }
            }
        }
    }

    Rectangle {
        id: pulleyMenu
        width: parent.width
        color: Kirigami.Theme.backgroundColor
        anchors.bottom: parent.bottom
        height: 0

        ListView {
            id: pulleyListView
            width: parent.width
            anchors.top: parent.top
            anchors.bottom: pulleyEndArea.bottom
            clip: true
            interactive: false;
            spacing: 5
         }

         Item {
                id: pulleyEndArea
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Kirigami.Units.gridUnit * 1.22
                width: parent.width
                height: Kirigami.Units.gridUnit * 2.5
            }
        }
    }
