import QtQuick 2.9
import QtQuick.Controls 2.2
import QtPositioning 5.12
import QtLocation 5.12
import QtQuick.Layouts 1.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.5 as Kirigami

ColumnLayout {
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
