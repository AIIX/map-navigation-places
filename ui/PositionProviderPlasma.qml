import QtQuick 2.9
import QtPositioning 5.12
import QtLocation 5.12
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaCore.DataSource {
    id: geoDataSource
    dataEngine: "geolocation"
    property var coordinates

    Component.onCompleted: {
            geoDataSource.connectedSources = ["location"]
    }

    onSourceAdded: {
        console.log(geoDataSource.engine)
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
