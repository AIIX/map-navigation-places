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
    visible: map.state == "Direction" ? true : false
    property alias inputBoxFromFocus: inputQueryFrom.focus
    property alias inputBoxFromText: inputQueryFrom.text
    property alias inputBoxToFocus: inputQueryTo.focus
    property alias inputBoxToText: inputQueryTo.text
    property alias directionSheetPosition: directionsSheet.opened

    function directionSheetOpen(){
        directionsSheet.open()
    }

    function directionSheetClose(){
        directionsSheet.close()
    }

    z: 100

    Rectangle {
        id: directionBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Kirigami.Units.gridUnit * 6
        color: Kirigami.Theme.backgroundColor

        ColumnLayout{
            id: directionBarLayout
            anchors.fill: parent
            anchors.margins: Kirigami.Units.largeSpacing
            RowLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    RowLayout {
                        id: navigateTopRow
                        Layout.fillWidth: true
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                        z: 200
                        Kirigami.Icon{
                            id: fromIcon
                            source: "math2"
                            Layout.preferredWidth: Kirigami.Units.iconSizes.small
                            Layout.preferredHeight: Kirigami.Units.iconSizes.small
                        }
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            z: 200
                            PlasmaComponents.TextField {
                                id: inputQueryFrom
                                clearButtonShown: true
                                anchors.fill: parent
                                placeholderText: "From"
                                z: 10

                                onTextChanged: {
                                    if(inputQueryFrom.text.length > 8){
                                        autoCompleteListener(inputQueryFrom.text, "From")
                                    }
                                }
                            }

                            LocationAutoCompleteFrom {
                                id: suggestionsBox2
                                model: autoCompleteListModelFrom
                                width: parent.width
                                anchors.top: inputQueryFrom.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                suggestionsModel: autoCompleteListModelFrom
                                count: autoCompleteListModelFrom.count
                                onItemSelected: complete(item)
                                z: 200

                                function complete(item) {
                                    if (item !== undefined)
                                        inputQueryFrom.text = item.label.replace(/<\/?[^>]+(>|$)/g, "");
                                }
                            }
                        }
                    }
                    RowLayout {
                        id: navigateBottomRow
                        Layout.fillWidth: true
                        Layout.preferredHeight: Kirigami.Units.gridUnit * 3
                        Kirigami.Icon{
                            id: toIcon
                            source: "speaker"
                            Layout.preferredWidth: Kirigami.Units.iconSizes.small
                            Layout.preferredHeight: Kirigami.Units.iconSizes.small
                        }
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            PlasmaComponents.TextField {
                                id: inputQueryTo
                                clearButtonShown: true
                                anchors.fill: parent
                                placeholderText: "Destination"
                                z: 2

                                onTextChanged: {
                                    if(inputQueryTo.text.length > 8){
                                        autoCompleteListener(inputQueryTo.text, "To")
                                    }
                                }
                            }

                            LocationAutoCompleteTo {
                                id: suggestionsBox3
                                model: autoCompleteListModelTo
                                width: parent.width
                                anchors.top: inputQueryTo.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                suggestionsModel: autoCompleteListModelTo
                                count: autoCompleteListModelTo.count
                                onItemSelected: complete(item)
                                z: 2

                                function complete(item) {
                                    if (item !== undefined)
                                        inputQueryTo.text = item.label.replace(/<\/?[^>]+(>|$)/g, "");
                                }
                            }
                        }
                    }
                }
                Button {
                Layout.fillHeight: true
                Layout.preferredWidth: Kirigami.Units.gridUnit * 3
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                text: "Go"
                flat: true
                onClicked: {
                    routeQuery.clearWaypoints();
                    geoCodeQueryType = "From"
                    geoCodeModel.query = inputQueryFrom.text
                    geoCodeModel.update()
                    }
                }
            }
        }
    }

    RoundButton {
        id: backButtonDirections
        anchors.left: parent.left
        anchors.leftMargin: Kirigami.Units.largeSpacing
        anchors.top: directionBar.bottom
        anchors.topMargin: Kirigami.Units.largeSpacing
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        width: Kirigami.Units.iconSizes.large
        height: Kirigami.Units.iconSizes.large
        visible: true
        onClicked: {
            goToGeneralState()
        }
        Kirigami.Icon {
            id: iconFocusTypeClear
            source: "arrow-left"
            anchors.centerIn: parent
            width: Kirigami.Units.iconSizes.smallMedium
            height: Kirigami.Units.iconSizes.smallMedium
        }
        z: 2
    }

    RoundButton {
        id: navigationButtonDirections
        anchors.right: parent.right
        anchors.rightMargin: Kirigami.Units.largeSpacing
        anchors.top: directionBar.bottom
        anchors.topMargin: Kirigami.Units.largeSpacing
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        width: Kirigami.Units.iconSizes.huge
        height: Kirigami.Units.iconSizes.huge
        visible: routeModel.status == RouteModel.Ready
        onClicked: {
            goToNavigationState()
        }
        Kirigami.Icon {
            id: iconFocusTypeNavigation
            source: "followmouse"
            anchors.centerIn: parent
            width: Kirigami.Units.iconSizes.medium
            height: Kirigami.Units.iconSizes.medium
        }
        z: 2
    }


    RoundButton {
        id: centerButton2
        anchors.verticalCenter: directionsSheet.position ? parent.verticalCenter : parent.bottom
        anchors.verticalCenterOffset: directionsSheet.position ? 0 : - Kirigami.Units.gridUnit * 2
        anchors.right: parent.right
        anchors.rightMargin: Kirigami.Units.largeSpacing
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        width: Kirigami.Units.iconSizes.huge
        height: Kirigami.Units.iconSizes.huge
        visible: true
        onClicked: {
            if(map.center === root.startCoordinate && map.tilted) {
                map.tilt = 0
            } else if (map.center === root.startCoordinate && !map.tilted){
                map.tilt = 55
            } else {
                console.log(root.startCoordinate)
                map.center = root.startCoordinate
            }
        }
        Kirigami.Icon {
            id: iconFocusType2
            source: "snap-nodes-center"
            anchors.centerIn: parent
            width: Kirigami.Units.iconSizes.medium
            height: Kirigami.Units.iconSizes.medium
        }
        z: 2
    }

    RoundButton {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Kirigami.Units.largeSpacing
        anchors.left: parent.left
        anchors.leftMargin: Kirigami.Units.largeSpacing
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
        width: Kirigami.Units.iconSizes.huge
        height: Kirigami.Units.iconSizes.huge
        visible: routeModel.status == RouteModel.Ready && directionsSheet._isVisible == false ? true : false
        onClicked: directionsSheet.open()
        Kirigami.Icon {
            id: iconDirectionType
            source: "curve-connector"
            anchors.centerIn: parent
            width: Kirigami.Units.iconSizes.medium
            height: Kirigami.Units.iconSizes.medium
        }
        z: 2
    }

    PulleyItem {
        id: directionsSheet
        model: routeInfoModel
        barColor: Kirigami.Theme.backgroundColor
        delegate: Kirigami.BasicListItem {
            RowLayout {
                Layout.preferredWidth: parent.width
                Layout.preferredHeight: Kirigami.Units.gridUnit * 2
                spacing: 10
                Label { text: (1 + index) + "." }
                Label {
                    text: model.instruction
                }
                Label{
                    text: model.distance
                }
            }
            onPressed: {
                console.log(model.latitude)
                console.log(model.longitude)
                map.center = QtPositioning.coordinate(model.latitude, model.longitude)
                map.zoomLevel = 18
            }
        }
    }
}
