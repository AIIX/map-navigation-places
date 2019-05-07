import QtQuick 2.9
import QtQuick.Controls 2.2
import QtPositioning 5.12
import QtLocation 5.12
import QtQuick.Layouts 1.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

Item {
    anchors.fill: parent

    Rectangle {
        id: navigationsBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Kirigami.Units.gridUnit * 5
        color: Kirigami.Theme.backgroundColor

        ListView {
            id: rootSlideShow
            model: routeInfoModel
            width: parent.width
            height: parent.height
            focus: true
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem;
            flickableDirection: Flickable.AutoFlickDirection
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightFollowsCurrentItem: true
            layoutDirection: Qt.LeftToRight
            clip: true
            delegate: Item {
                id: delegateLayout
                width: rootSlideShow.width
                height: rootSlideShow.height

                RowLayout {
                    id: rowItemNav
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: parent.height

                    Kirigami.Heading {
                        id: directionLabels
                        level: 2
                        Layout.fillWidth: true
                        Layout.leftMargin: Kirigami.Units.largeSpacing
                        text: model.instruction
                        wrapMode: Text.WrapAnywhere
                    }

                    Kirigami.Icon {
                        id: directionIcon
                        source: "draw-arrow-forward"
                        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                        Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                        Layout.rightMargin: Kirigami.Units.largeSpacing
                    }
                }
            }
        }
    }
}
