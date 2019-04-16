import QtQuick 2.9
import QtQuick.Controls 2.2
import QtPositioning 5.12
import QtLocation 5.12
import QtQuick.Layouts 1.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.4 as Kirigami
import Mycroft 1.0 as Mycroft

Mycroft.Delegate {
    id: root
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    leftPadding: -Kirigami.Units.smallSpacing 
    topPadding: -Kirigami.Units.smallSpacing
    property var geoLat
    property var geoLong
    property var geoCountry
    property var startCoordinate
    property var endCoordinate
    property var homeCoordinate
    property alias inputBoxFocus: inputQuery.focus
    property alias inputBoxFromFocus: inputQueryFrom.focus
    property alias inputBoxToFocus: inputQueryTo.focus
    property var geoCodeQueryType
    property var mycroftLocationQuery: sessionData.locationQuery

    onMycroftLocationQueryChanged: {
        geoCodeQueryType = "General"
        geoCodeModel.query = mycroftLocationQuery
        geoCodeModel.update()
        inputQuery.text = mycroftLocationQuery
        console.log(mycroftLocationQuery)
    }
    
    Component.onCompleted: {
        geoDataSource.connectedSources = ["location"]
    }

    function formatTime(sec)
    {
        var value = sec
        var seconds = value % 60
        value /= 60
        value = (value > 1) ? Math.round(value) : 0
        var minutes = value % 60
        value /= 60
        value = (value > 1) ? Math.round(value) : 0
        var hours = value
        if (hours > 0) value = hours + "h:"+ minutes + "m"
        else value = minutes + "min"
        return value
    }

    function formatDistance(meters)
    {
        var dist = Math.round(meters)
        if (dist > 1000 ){
            if (dist > 100000){
                dist = Math.round(dist / 1000)
            }
            else{
                dist = Math.round(dist / 100)
                dist = dist / 10
            }
            dist = dist + " km"
        }
        else{
            dist = dist + " m"
        }
        return dist
    }

    function calculateRoute() {
        closeAllOverlaySheets()
        map.state = "Direction"
        // clear away any old data in the query
        routeQuery.clearWaypoints();
        // add the start and end coords as waypoints on the route
        routeQuery.addWaypoint(homeCoordinate)
        routeQuery.addWaypoint(endCoordinate)
        //routeQuery.travelModes = routeDialog.travelMode
        //routeQuery.routeOptimizations = routeDialog.routeOptimization
        routeModel.update();
        // center the map on the start coord
        map.center = homeCoordinate;
        markerHome.coordinate = homeCoordinate
        markerEnd.coordinate = endCoordinate
        map.zoomLevel = 14
    }

    function calculateRouteDirectionSheet() {
        closeAllOverlaySheets()
        map.state = "Direction"
        //markerStart.coordinate = startCoordinate
        //markerEnd.coordinate = endCoordinate
        // clear away any old data in the query
        routeQuery.clearWaypoints();
        // add the start and end coords as waypoints on the route
        routeQuery.addWaypoint(markerStart.coordinate)
        routeQuery.addWaypoint(markerEnd.coordinate)
        //routeQuery.travelModes = routeDialog.travelMode
        //routeQuery.routeOptimizations = routeDialog.routeOptimization
        routeModel.update();
        map.zoomLevel = 14
    }

    function autoCompleteListener(query, querytype) {
        var doc = new XMLHttpRequest()
        var url = 'https://autocomplete.geocoder.api.here.com/6.2/suggest.json'

        var params = '?' +
                'query=' + query +   // The search text which is the basis of the query
                '&beginHighlight=' + '<mark>' + //  Mark the beginning of the match in a token.
                '&endHighlight=' + '</mark>' + //  Mark the end of the match in a token.
                '&maxresults=5' +  // The upper limit the for number of suggestions to be included
                // in the response.  Default is set to 5.
                '&app_id=' + 'c8OJFSMPYCg6Q1IYG01P' +
                '&app_code=' + '6iK0piwLxIpbn2jPaj8QKQ';
        doc.open('GET', url + params );
        doc.send();

        doc.onreadystatechange = function() {
            if (doc.readyState === XMLHttpRequest.DONE) {
                var resultsJson = JSON.parse(doc.responseText)
                if(querytype == "General"){
                    autoCompleteListModelGeneral.clear()
                    for(var i = 0; i < resultsJson.suggestions.length; i++) {
                        autoCompleteListModelGeneral.append({"label": resultsJson.suggestions[i].label})
                    }
                } else if (querytype == "From"){
                    autoCompleteListModelFrom.clear()
                    for(var z = 0; z < resultsJson.suggestions.length; z++) {
                        autoCompleteListModelFrom.append({"label": resultsJson.suggestions[z].label})
                    }
                } else if (querytype == "To"){
                    autoCompleteListModelTo.clear()
                    for(var z = 0; z < resultsJson.suggestions.length; z++) {
                        autoCompleteListModelTo.append({"label": resultsJson.suggestions[z].label})
                    }
                }
            }
        }
    }

    function closeMenuBar(){
        menuBar.open = false
        menuBar.height = Kirigami.Units.gridUnit * 3
    }

    function closeAllOverlaySheets(){
        nearbyMenu.close()
        placeSearchOverlaySheet.close()
        pinDropSelectionOverviewSheet.close()
        directionsSheet.close()
    }

    function showPlaceOfInterest() {
        markerStart.coordinate = homeCoordinate
        markerEnd.coordinate = endCoordinate
        map.center = endCoordinate
        map.zoomLevel = 14
    }

    function placeSearchByTerm(term, area){
        placeSearchModel.searchTerm = term
        placeSearchModel.searchArea = area
        placeSearchModel.update()
    }

    function pinDropSelectionMap(cords){
        endCoordinate = cords
        markerEnd.coordinate = cords
        map.center = markerEnd.coordinate
        pinDropSelectionOverviewSheet.open()
    }

    function updateMapFromPoint(){
        markerStart.coordinate = startCoordinate
        map.center = startCoordinate
        geoCodeQueryType = "To"
        geoCodeModel.query = inputQueryTo.text
        geoCodeModel.update()
    }

    function updateMapToPoint(){
        markerEnd.coordinate = endCoordinate
        map.center = endCoordinate
        console.log(endCoordinate)
        calculateRouteDirectionSheet()
    }

    PlasmaCore.DataSource {
        id: geoDataSource
        dataEngine: "geolocation"
        property var coordinates

        onSourceAdded: {
            connectSource(source)
        }

        onNewData: {
            if (sourceName == "location"){
                geoLat = data.latitude
                geoLong = data.longitude
                geoCountry = data.country
                map.center = QtPositioning.coordinate(data.latitude, data.longitude)
                coordinates = QtPositioning.coordinate(data.latitude, data.longitude)
                root.homeCoordinate = QtPositioning.coordinate(data.latitude, data.longitude)
                markerHome.coordinate = QtPositioning.coordinate(data.latitude, data.longitude)
            }
        }
    }

    ListModel {
        id: autoCompleteListModelGeneral
    }

    ListModel {
        id: autoCompleteListModelFrom
    }

    ListModel {
        id: autoCompleteListModelTo
    }

    ButtonGroup {
        buttons: mapSelectionRowOption.children
    }

    DropArea {
        anchors.fill: parent
        onDropped: {
            var coord = map.toCoordinate(Qt.point(drop.x, drop.y));
        }
        Map {
            id: map
            width: root.width
            height: directionsSheet.position == 0 ? root.height : root.height / 1
            tilt: 0
            activeMapType: supportedMapTypes[0]
            plugin: Plugin {
                name: "osm"
                //PluginParameter { name: "here.app_id"; value: "c8OJFSMPYCg6Q1IYG01P" }
                //PluginParameter { name: "here.token"; value: "6iK0piwLxIpbn2jPaj8QKQ" }
                //PluginParameter { name: "here.mapping.highdpi_tiles"; value: true }
                PluginParameter { name: "osm.mapping.highdpi_tiles"; value: true}
            }
            copyrightsVisible: false
            center: QtPositioning.coordinate(0, 0)
            zoomLevel: 16
            gesture.flickDeceleration: 3000
            gesture.enabled: true
            property bool tilted: tilt > 0 ? true : false
            property GeocodeModel geocodeModel: GeocodeModel {
                id: geoCodeModel
                plugin: Plugin {
                    name: "here"
                    PluginParameter { name: "here.app_id"; value: "c8OJFSMPYCg6Q1IYG01P" }
                    PluginParameter { name: "here.token"; value: "6iK0piwLxIpbn2jPaj8QKQ" }
                }
                autoUpdate: false
                onLocationsChanged: {
                    if(count){
                        //console.log(root.startCoordinate)
                        //console.log(get(0).coordinate)
                        //routeQuery.addWaypoint(root.startCoordinate)
                        //routeQuery.addWaypoint(get(0).coordinate)
                        switch(geoCodeQueryType){
                        case "General":
                            root.endCoordinate = get(0).coordinate
                            showPlaceOfInterest()
                            break;
                        case "From":
                            console.log("inFrom")
                            root.startCoordinate = get(0).coordinate
                            updateMapFromPoint()
                            break;
                        case "To":
                            console.log("inTo")
                            root.endCoordinate = get(0).coordinate
                            updateMapToPoint()
                            break;
                        }
                        //map.center = root.endCoordinate
                        //directionsSheet.open()
                        //calculateRoute()
                    }
                }
                onErrorChanged: {
                    console.log(errorString)
                }
            }

            states: [
                State {
                    name: "General"
                    PropertyChanges {target: generalPageItems; visible: true; enabled: true}
                    PropertyChanges {target: directionPageItems; visible: false; enabled: false}
                },
                State {
                    name: "Direction"
                    PropertyChanges {target: directionPageItems; visible: true; enabled: true}
                    PropertyChanges {target: generalPageItems; visible: false; enabled: false}
                }
            ]

            MapQuickItem {
                id: markerHome
                coordinate: QtPositioning.coordinate(0, 0)
                sourceItem: Kirigami.Icon {
                    id: currentLocIcon
                    source: "go-home"
                    width: Kirigami.Units.iconSizes.medium
                    height: Kirigami.Units.iconSizes.medium
                    color: Kirigami.Theme.backgroundColor
                }
                anchorPoint.x: currentLocIcon.width / 2
                anchorPoint.y: currentLocIcon.height
            }


            MapQuickItem {
                id: markerStart
                coordinate: QtPositioning.coordinate(0, 0)
                sourceItem: Kirigami.Icon {
                    id: startLocIcon
                    source: "step_object_Pin"
                    width: Kirigami.Units.iconSizes.medium
                    height: Kirigami.Units.iconSizes.medium
                    color: Kirigami.Theme.backgroundColor
                }
                anchorPoint.x: startLocIcon.width / 2
                anchorPoint.y: startLocIcon.height
            }

            MapQuickItem {
                id: markerEnd
                coordinate: QtPositioning.coordinate(0, 0)
                sourceItem: Kirigami.Icon {
                    id: endLocIcon
                    source: "step_object_Pin"
                    width: Kirigami.Units.iconSizes.medium
                    height: Kirigami.Units.iconSizes.medium
                    color: Kirigami.Theme.backgroundColor
                }
                anchorPoint.x: endLocIcon.width / 2
                anchorPoint.y: endLocIcon.height
            }

            MapItemView {
                id: markerPlaces
                model: placeSearchModel
                z: 10
                delegate: MapQuickItem {
                    coordinate: model.place.location.coordinate
                    sourceItem: Image {
                        id: markerPlacesImage
                        source: model.place.icon.parameters.iconPrefix + model.place.icon.parameters.nokiaIcon
                        width: Kirigami.Units.iconSizes.medium
                        height: Kirigami.Units.iconSizes.medium
                    }

                    MouseArea {
                        anchors.fill: parent
                        propagateComposedEvents: true
                        onClicked: {
                            pCard.open()
                        }
                    }

                    Popup {
                        id: pCard
                        modal: false
                        clip: true
                        margins: Kirigami.Units.largeSpacing
                        contentItem: ColumnLayout {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            RowLayout {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                Image {
                                    Layout.alignment: Qt.AlignCenter
                                    source: model.place.icon.parameters.iconPrefix + model.place.icon.parameters.nokiaIcon
                                }
                                Kirigami.Separator {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 1
                                }
                                ColumnLayout {
                                    Layout.fillHeight: true
                                    Label {
                                        text: model.place.name
                                        Layout.fillWidth: true
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    }
                                    Label {
                                        text: model.place.location.address.text
                                        Layout.fillWidth: true
                                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    }
                                }
                                Kirigami.Separator {
                                    Layout.fillHeight: true
                                    Layout.preferredWidth: 1
                                }
                                Button {
                                    text: "Navigate"
                                    flat: true
                                    Kirigami.Theme.inherit: false
                                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                                }
                            }
                        }
                    }
                }
            }


            MapItemView {
                model: routeModel
                autoFitViewport: true
                delegate: Component{
                    MapRoute{
                        route: routeData;
                        line.color: "lime"
                        line.width: 5
                        smooth: true
                    }
                }
            }

            Item {
                id: generalPageItems
                anchors.fill: parent
                z: 100

                Rectangle {
                    id: menuBar
                    anchors.top: parent.top
                    anchors.topMargin: Kirigami.Units.largeSpacing * 2
                    anchors.left: parent.left
                    anchors.leftMargin: Kirigami.Units.largeSpacing
                    anchors.right: parent.right
                    anchors.rightMargin: Kirigami.Units.largeSpacing
                    height: Kirigami.Units.gridUnit * 3
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
                    visible: directionsSheet.position ? 0 : 1
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
                        if(map.center === homeCoordinate && map.tilted) {
                            map.tilt = 0
                        } else if (map.center === homeCoordinate && !map.tilted){
                            map.tilt = 55
                        } else {
                            map.center = homeCoordinate
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
                            calculateRoute()
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

            Item {
                id: directionPageItems
                anchors.fill: parent
                visible: map.state == "Direction" ? true : false
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
                                                    console.log("Here")
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
                                                    console.log("Here")
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
                        if(map.center === startCoordinate && map.tilted) {
                            map.tilt = 0
                        } else if (map.center === startCoordinate && !map.tilted){
                            map.tilt = 55
                        } else {
                            map.center = startCoordinate
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
                    visible: routeModel.status == RouteModel.Ready && directionsSheet.position == 0 ? true : false
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
            }

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true

                onClicked: {
                    map.focus = true
                }

                onPressAndHold: {
                    console.log(map.toCoordinate(Qt.point(mouseX, mouseY)))
                    pinDropSelectionMap(map.toCoordinate(Qt.point(mouseX, mouseY)))
                }
            }
        }
    }

    PlaceSearchModel {
        id: placeSearchModel
        plugin: Plugin {
            name: "here"
            PluginParameter { name: "here.app_id"; value: "c8OJFSMPYCg6Q1IYG01P" }
            PluginParameter { name: "here.token"; value: "6iK0piwLxIpbn2jPaj8QKQ" }
        }
        limit: 10

        onStatusChanged: {
            switch (status) {
            case PlaceSearchModel.Loading:
                closeAllOverlaySheets()
                break;
            case PlaceSearchModel.Ready:
                if (count > 0){
                    console.log(JSON.stringify(placeSearchModel))
                    placeSearchOverlaySheet.open()
                    markerPlaces.visible = true
                }
                else {
                    console.log(qsTr("Search Place Error"),qsTr("Place not found !"))
                }
                break;
            case PlaceSearchModel.Error:
                console.log(qsTr("Search Place Error"),errorString())
                break;
            }
        }
    }

    Popup {
        id: pinDropSelectionOverviewSheet
        parent: root
        x: (parent.width - width) / 2
        y: (parent.height - height) / 1
        closePolicy: Popup.CloseOnPressOutsideParent | Popup.CloseOnEscape
        contentItem: ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Kirigami.Heading {
                level: 2
                text: "Dropped Pin"
                Layout.fillWidth: true
                height: paintedHeight
            }
            Label {
                text: markerEnd.coordinate.latitude + " , " + markerEnd.coordinate.longitude
            }
            RowLayout {
                Button {
                    Layout.fillWidth: true
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                    text: "Directions"
                }
                Button {
                    Layout.fillWidth: true
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                    text: "Navigation"
                }
                Button {
                    Layout.fillWidth: true
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                    text: "Explore Nearby"
                }
            }
        }
    }

    Kirigami.OverlaySheet {
        id: placeSearchOverlaySheet
        parent: root
        contentItem: ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Repeater {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: placeSearchModel
                delegate: ColumnLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    RowLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Image {
                            Layout.alignment: Qt.AlignCenter
                            source: model.place.icon.parameters.iconPrefix + model.place.icon.parameters.nokiaIcon
                        }
                        Kirigami.Separator {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 1
                        }
                        ColumnLayout {
                            Layout.fillHeight: true
                            Label {
                                text: model.place.name
                                Layout.fillWidth: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            }
                            Label {
                                text: model.place.location.address.text
                                Layout.fillWidth: true
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            }
                        }
                        Kirigami.Separator {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 1
                        }
                        Button {
                            text: "Navigate"
                            flat: true
                            Kirigami.Theme.inherit: false
                            Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                        }
                    }
                    Kirigami.Separator {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                    }
                }
            }
        }
    }

    RouteModel {
        id: routeModel
        plugin: map.plugin
        query: RouteQuery { id: routeQuery }

        onRoutesChanged: {
            routeInfoModel.clear()
            console.log(routeModel.count)
            if (RouteModel.Ready) {
                console.log(routeModel.get(0).segments)
                for (var i = 0; i < routeModel.get(0).segments.length; i++) {
                    routeInfoModel.append({
                                              "instruction": routeModel.get(0).segments[i].maneuver.instructionText,
                                              "distance": formatDistance(routeModel.get(0).segments[i].maneuver.distanceToNextInstruction),
                                              "latitude": routeModel.get(0).segments[i].maneuver.waypoint.latitude,
                                              "longitude": routeModel.get(0).segments[i].maneuver.waypoint.longitude,
                                              "turn": routeModel.get(0).segments[i].maneuver.extendedAttributes.modifier,
                                              "turnType": routeModel.get(0).segments[i].maneuver.extendedAttributes.type
                                          });
                    console.log(JSON.stringify(routeModel.get(0).segments[i].maneuver))
                }
                directionsSheet.open()
            }
            routeInfoModel.travelTime = routeModel.count == 0 ? "" : formatTime(routeModel.get(0).travelTime)
            routeInfoModel.distance = routeModel.count == 0 ? "" : formatDistance(routeModel.get(0).distance)
        }
    }

    ListModel {
        id: routeInfoModel
        property string travelTime
        property string distance
    }

    Kirigami.OverlayDrawer {
        id: directionsSheet
        edge: Qt.BottomEdge
        height: root.height / 3
        width:  root.width
        dim: false
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

        onOpened: {
            console.log(endLocIcon.visible)
        }

        ListView {
            model: routeInfoModel
            visible: true
            width: parent.width
            height: parent.height
            clip: true
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
                    map.center = QtPositioning.coordinate(model.latitude, model.longitude)
                    map.zoomLevel = 17
                }
            }

            ScrollBar.vertical: ScrollBar {
                active: true
            }
        }
    }
}
