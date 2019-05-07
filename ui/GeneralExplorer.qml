import QtQuick 2.9
import QtQuick.Controls 2.2
import QtPositioning 5.12
import QtLocation 5.12
import QtQuick.Layouts 1.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.4 as Kirigami

Item {
    anchors.fill: parent
    z: 100
    property alias inputBoxFocus: inputQuery.focus
    property alias explorerMenu: nearbyMenu
    property alias menuBar: menuBar

    ButtonGroup {
        buttons: mapSelectionRowOption.children
    }

    Rectangle {
        id: menuBar
        anchors.top: parent.top
        anchors.topMargin: Kirigami.Units.largeSpacing * 2
        anchors.left: parent.left
        anchors.leftMargin: Kirigami.Units.largeSpacing
        anchors.right: parent.right
        anchors.rightMargin: Kirigami.Units.largeSpacing
        height: Kirigami.Units.gridUnit * 3
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        color: Kirigami.Theme.backgroundColor
        radius: 10
        property bool open: false
        z: 10

        ColumnLayout {
            id: menuBarColumn
            anchors.fill: parent
            spacing: Kirigami.Units.largeSpacing

            RowLayout{
                Layout.minimumHeight: Kirigami.Units.gridUnit * 3
                Layout.maximumHeight: Kirigami.Units.gridUnit * 3
                spacing: Kirigami.Units.smallSpacing

                Button {
                    id: handleAnchor
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 3
                    Layout.fillHeight: true
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                    Kirigami.Icon {
                        id: iconMenuType
                        source: "application-menu"
                        anchors.centerIn: parent
                        width: Kirigami.Units.iconSizes.medium
                        height: Kirigami.Units.iconSizes.medium
                    }
                    onClicked: {
                        if(!menuBar.open) {
                            menuBar.open = true
                            menuBar.height = Kirigami.Units.gridUnit * 10
                        } else {
                            closeMenuBar()
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    PlasmaComponents.TextField {
                        id: inputQuery
                        clearButtonShown: true
                        anchors.fill: parent
                        placeholderText: "Search Here"
                        z: 10000

                        onTextChanged: {
                            if(inputQuery.text.length > 8)
                                autoCompleteListener(inputQuery.text, "General")
                        }

                        onAccepted: {
                            geoCodeQueryType = "General"
                            geoCodeModel.query = inputQuery.text
                            geoCodeModel.update()
                        }
                    }

                    LocationAutoCompleteGeneral {
                        id: suggestionsBox
                        model: autoCompleteListModelGeneral
                        width: parent.width
                        anchors.top: inputQuery.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        suggestionsModel: autoCompleteListModelGeneral
                        count: autoCompleteListModelGeneral.count
                        onItemSelected: complete(item)

                        function complete(item) {
                            if (item !== undefined)
                                inputQuery.text = item.label.replace(/<\/?[^>]+(>|$)/g, "");
                        }
                    }
                }

                Button{
                    id: micButton
                    Layout.preferredWidth: handleAnchor.width
                    Layout.fillHeight: true
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                    Kirigami.Icon {
                        id: iconSpeakType
                        source: "mic-on"
                        anchors.centerIn: parent
                        width: Kirigami.Units.iconSizes.medium
                        height: Kirigami.Units.iconSizes.medium
                    }
                }
            }

            Item {
                id: secondaryMenuArea
                Layout.preferredHeight: menuBar.open ? Kirigami.Units.gridUnit * 6.5 : 0
                visible: menuBar.open ? true : false

                ColumnLayout {
                    id: secondaryMenuItem
                    anchors.fill: parent

                    Kirigami.Heading{
                        text: "Map Style"
                        Layout.alignment: Qt.AlignTop
                        Layout.leftMargin: Kirigami.Units.largeSpacing
                        level: 3
                    }

                    GridLayout {
                        id: mapSelectionRowOption
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.alignment: Qt.AlignTop
                        Layout.leftMargin: Kirigami.Units.largeSpacing
                        columns: root.width > completeWidth ? 4 : 2
                        property int completeWidth: mapType1Btn.width + mapType2Btn.width + mapType3Btn.width + mapType4Btn.width

                        onColumnsChanged: {
                            if(menuBar.open && columns == 2){
                                secondaryMenuArea.height = completeWidth
                                menuBar.height = Kirigami.Units.gridUnit * 13
                            }
                            if(menuBar.open && columns == 4){
                                secondaryMenuArea.height = completeWidth
                                menuBar.height = Kirigami.Units.gridUnit * 10
                            }
                        }

                        Button {
                            id: mapType1Btn
                            contentItem: Image {
                                id: mapTypeImage1
                                source: "https://developer.here.com/documentation/maps/graphics/map-tile-normal-map.png"
                                anchors.fill: parent
                                anchors.margins: Kirigami.Units.largeSpacing * 1

                                Rectangle {
                                    id: mapTypeLabel1
                                    anchors.fill: parent
                                    anchors.margins: Kirigami.Units.largeSpacing * 1.5
                                    color: Kirigami.Theme.backgroundColor

                                    Label {
                                        anchors.centerIn: parent
                                        text: "Normal"
                                    }
                                }
                            }

                            checkable: true
                            checked: true
                            flat: true
                            Kirigami.Theme.inherit: false
                            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 6
                            Layout.maximumHeight: Kirigami.Units.gridUnit * 4

                            onCheckedChanged: {
                                if(checked){
                                    map.activeMapType = map.supportedMapTypes[0]
                                }
                            }
                        }

                        Button {
                            id: mapType2Btn
                            contentItem: Image {
                                id: mapTypeImage2
                                source: "https://developer.here.com/documentation/maps/graphics/map-tile-normal-map.png"
                                anchors.fill: parent
                                anchors.margins: Kirigami.Units.largeSpacing * 1

                                Rectangle {
                                    id: mapTypeLabel2
                                    anchors.fill: parent
                                    anchors.margins: Kirigami.Units.largeSpacing * 1.5
                                    color: Kirigami.Theme.backgroundColor

                                    Label {
                                        anchors.centerIn: parent
                                        text: "Terrain"
                                    }
                                }
                            }

                            checkable: true
                            checked: false
                            flat: true
                            Kirigami.Theme.inherit: false
                            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 6
                            Layout.maximumHeight: Kirigami.Units.gridUnit * 4

                            onCheckedChanged: {
                                if(checked){
                                    map.activeMapType = map.supportedMapTypes[4]
                                }
                            }
                        }

                        Button {
                            id: mapType3Btn
                            contentItem: Image {
                                id: mapTypeImage3
                                source: "https://developer.here.com/documentation/maps/graphics/map-tile-normal-map.png"
                                anchors.fill: parent
                                anchors.margins: Kirigami.Units.largeSpacing * 1

                                Rectangle {
                                    id: mapTypeLabel3
                                    anchors.fill: parent
                                    anchors.margins: Kirigami.Units.largeSpacing * 1.5
                                    color: Kirigami.Theme.backgroundColor

                                    Label {
                                        anchors.centerIn: parent
                                        text: "Transit"
                                    }
                                }
                            }

                            checkable: true
                            checked: false
                            flat: true
                            Kirigami.Theme.inherit: false
                            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 6
                            Layout.maximumHeight: Kirigami.Units.gridUnit * 4

                            onCheckedChanged: {
                                if(checked){
                                    map.activeMapType = map.supportedMapTypes[2]
                                }
                            }
                        }

                        Button {
                            id: mapType4Btn
                            contentItem: Image {
                                id: mapTypeImage4
                                source: "https://developer.here.com/documentation/maps/graphics/map-tile-normal-map.png"
                                anchors.fill: parent
                                anchors.margins: Kirigami.Units.largeSpacing * 1

                                Rectangle {
                                    id: mapTypeLabel4
                                    anchors.fill: parent
                                    anchors.margins: Kirigami.Units.largeSpacing * 1.5
                                    color: Kirigami.Theme.backgroundColor

                                    Label {
                                        anchors.centerIn: parent
                                        text: "Night"
                                    }
                                }
                            }

                            checkable: true
                            checked: false
                            flat: true
                            Kirigami.Theme.inherit: false
                            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 6
                            Layout.maximumHeight: Kirigami.Units.gridUnit * 4

                            onCheckedChanged: {
                                if(checked){
                                    map.activeMapType = map.supportedMapTypes[3]
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Button {
        id: footerExploreNearby
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Kirigami.Units.largeSpacing
        anchors.horizontalCenter: parent.horizontalCenter
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        flat: true
        hoverEnabled: true
        visible: generalPageItems.directionSheetPosition ? 0 : 1
        z: 100
        contentItem: RowLayout {
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            id: exploreBarLayout

            Kirigami.Icon {
                id: exploreNearbyIcon
                source: "internet-services"
                Layout.alignment: Qt.AlignCenter
                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            }

            Kirigami.Separator {
                id: exploreNearbySplit
                Layout.fillHeight: true
                Layout.preferredWidth: 1
            }

            Label {
                id: exploreNearbyButton
                text: "Explore Nearby"
            }
        }

        onClicked: {
            nearbyMenu.open()
        }

        Kirigami.OverlaySheet {
            id: nearbyMenu
            parent: root
            contentItem: ColumnLayout {
                PlasmaComponents.TextField{
                    Layout.fillWidth: true
                    Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                    placeholderText: "Custom Type.."
                    clearButtonShown: true
                }
                Repeater {
                    model: ExploreTypeModel{}
                    delegate: SimpleMenuDelegate{}
                }
            }
        }

    }

    RoundButton {
        id: centerButton
        anchors.bottom: directionButton.top
        anchors.bottomMargin: Kirigami.Units.largeSpacing
        anchors.right: parent.right
        anchors.rightMargin: Kirigami.Units.largeSpacing
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        width: Kirigami.Units.iconSizes.huge
        height: Kirigami.Units.iconSizes.huge
        visible: true
        onClicked: {
            if(map.center === root.startCoordinate && map.tilted || map.center === root.homeCoordinate && map.tilted) {
                map.tilt = 0
            } else if (map.center === root.startCoordinate && !map.tilted || map.center === root.homeCoordinate && !map.tilted ){
                map.tilt = 55
            } else {
                if(root.startCoordinate){
                    map.center = root.startCoordinate
                } else {
                    map.center = root.homeCoordinate
                }
            }
        }
        Kirigami.Icon {
            id: iconFocusType
            source: "snap-nodes-center"
            anchors.centerIn: parent
            width: Kirigami.Units.iconSizes.medium
            height: Kirigami.Units.iconSizes.medium
        }
        z: 2
    }

    RoundButton {
        id: directionButton
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Kirigami.Units.largeSpacing
        anchors.right: parent.right
        anchors.rightMargin: Kirigami.Units.largeSpacing
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        width: Kirigami.Units.iconSizes.huge
        height: Kirigami.Units.iconSizes.huge
        visible: true
        onClicked: {
            if(markerEnd.coordinate.latitude !== 0 && markerEnd.coordinate.longitude !==0 ){
                directionPageItems.inputBoxFromText = markerStart.coordinate.latitude + "," + markerStart.coordinate.longitude
                directionPageItems.inputBoxToText = markerEnd.coordinate.latitude + "," + markerEnd.coordinate.longitude
                checkRouteHygineL1()
            } else {
                goToDirectionState()
            }
        }
        Kirigami.Icon {
            id: iconDirType
            source: "svn-commit"
            anchors.centerIn: parent
            width: Kirigami.Units.iconSizes.medium
            height: Kirigami.Units.iconSizes.medium
        }
        z: 2
    }
}
