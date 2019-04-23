import QtQuick 2.9
import QtQuick.Controls 2.2
import QtPositioning 5.12
import QtLocation 5.12
import QtQuick.Layouts 1.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.5 as Kirigami

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
    property var geoCodeQueryType
    property var mycroftLocationQuery: sessionData.locationQuery
    property bool isRouteError: false
    property bool isHomeSet: false

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
        map.state = "Direction"
        map.center = homeCoordinate;
        markerHome.coordinate = homeCoordinate
        markerEnd.coordinate = endCoordinate
        map.zoomLevel = 14
        closeAllOverlaySheets()
        directionsSheet.open()
    }

    function checkRouteHygineL1(){
        if (isRouteError) {
            errorInfoSheet.open()
            console.log("InRouteErrorHygineL1")
        } else {
            setRoute()
            routeModel.update()
            console.log("InRouteHyginePassL1")
        }
    }

    function checkRouteHygineL2(){
        if (isRouteError) {
            errorInfoSheet.open()
            console.log("InRouteErrorHygineL2")
        } else {
            setRouteDirectionState()
            routeModel.update()
            console.log("InRouteHyginePassL2")
        }
    }

    function setRoute(){
        routeModel.reset()
        routeQuery.clearWaypoints();
        routeQuery.addWaypoint(homeCoordinate)
        routeQuery.addWaypoint(endCoordinate)
    }

    function setRouteDirectionState(){
        routeModel.reset()
        routeQuery.clearWaypoints();
        routeQuery.addWaypoint(markerStart.coordinate)
        routeQuery.addWaypoint(markerEnd.coordinate)
        calculateRouteDirectionSheet()
    }

    function calculateRouteDirectionSheet() {
        closeAllOverlaySheets()
        map.state = "Direction"
        routeModel.update();
        map.center = markerEnd.coordinate
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
        generalPageItems.menuBar.open = false
        generalPageItems.menuBar.height = Kirigami.Units.gridUnit * 3
    }

    function closeAllOverlaySheets(){
        generalPageItems.explorerMenu.close()
        placeSearchOverlaySheet.close()
        pinDropSelectionOverviewSheet.close()
        directionsSheet.close()
    }

    function showPlaceOfInterest() {
        markerStart.coordinate = homeCoordinate
        markerEnd.coordinate = endCoordinate
        map.center = endCoordinate
        //map.zoomLevel = 14
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
        //map.center = startCoordinate
        geoCodeQueryType = "To"
        geoCodeModel.query = directionPageItems.inputBoxToText
        geoCodeModel.update()
    }

    function updateMapToPoint(){
        markerEnd.coordinate = endCoordinate
        //map.center = endCoordinate
        checkRouteHygineL2()
    }

    function goToGeneralState(){
        routeQuery.clearWaypoints();
        routeModel.reset()
        map.clearData()
        map.state = "General"
    }

    function goToDirectionState(){
        map.state = "Direction"
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
                console.log(isHomeSet)
                geoLat = data.latitude
                geoLong = data.longitude
                geoCountry = data.country
                if (!isHomeSet){
                    map.center = QtPositioning.coordinate(data.latitude, data.longitude)
                    isHomeSet = true
                }
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
                        switch(geoCodeQueryType){
                        case "General":
                            root.endCoordinate = get(0).coordinate
                            showPlaceOfInterest()
                            break;
                        case "From":
                            //console.log("inFrom")
                            root.startCoordinate = get(0).coordinate
                            updateMapFromPoint()
                            break;
                        case "To":
                            //console.log("inTo")
                            root.endCoordinate = get(0).coordinate
                            updateMapToPoint()
                            break;
                        }
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
                },
                State {
                    name: "Navigation"
                    PropertyChanges {target: directionPageItems; visible: false; enabled: false}
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
                autoFitViewport: true
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

            GeneralExplorer {
                id: generalPageItems
                anchors.fill: parent
                z: 100
            }

            DirectionsExplorer {
                id: directionPageItems
                anchors.fill: parent
                visible: map.state == "Direction" ? true : false
                z: 100
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

                    onClicked: {
                            endCoordinate = QtPositioning.coordinate(markerEnd.coordinate.latitude, markerEnd.coordinate.longitude)
                            checkRouteHygineL1()
                    }
                }
                Button {
                    Layout.fillWidth: true
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                    text: "Navigation"

                    onClicked: {
                        endCoordinate = QtPositioning.coordinate(markerEnd.coordinate.latitude, markerEnd.coordinate.longitude)
                        //calculateNavRoute()
                    }
                }
                Button {
                    Layout.fillWidth: true
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
                    text: "Explore Nearby"

                    onClicked: {
                       map.center = QtPositioning.coordinate(markerEnd.coordinate.latitude, markerEnd.coordinate.longitude)
                       pinDropSelectionOverviewSheet.close()
                       generalPageItems.explorerMenu.open()
                    }
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
                delegate: PlacesDelegate {}
            }
        }
    }

    RouteModel {
        id: routeModel
        //plugin: map.plugin
        plugin: Plugin {
            name: "here"
            PluginParameter { name: "here.app_id"; value: "c8OJFSMPYCg6Q1IYG01P" }
            PluginParameter { name: "here.token"; value: "6iK0piwLxIpbn2jPaj8QKQ" }
        }
        query: RouteQuery {
            id: routeQuery
        }

        onErrorStringChanged: {
            console.log(routeModel.errorString)
            if(error == 2){
                console.log(routeModel.errorString)
                isRouteError = true
            } else {
                isRouteError = false
            }
        }

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
                    //console.log(JSON.stringify(routeModel.get(0).segments[i].maneuver))
                }
                if (map.state == "General"){
                    calculateRoute()
                }
            } else if (RouteModel.Error){
                console.log("Error")
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

    Kirigami.OverlaySheet {
        id: errorInfoSheet
        parent: root
        contentItem: ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Label {
                text: "No Route Found!"
            }
        }
    }
}
