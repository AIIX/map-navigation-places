import QtQuick 2.9
import QtQuick.Controls 2.2
import QtPositioning 5.12
import QtLocation 5.12
import QtQuick.Layouts 1.3
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.4 as Kirigami

Button {
    Layout.fillWidth: true
    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary

    contentItem: Item {
        implicitWidth: delegateLayout.implicitWidth;
        implicitHeight: delegateLayout.implicitHeight;

        ColumnLayout {
            id: delegateLayout
            anchors {
                left: parent.left;
                top: parent.top;
                right: parent.right;
            }

            RowLayout {
                Layout.fillWidth: true

                Kirigami.Icon {
                    id: exploreTypeIcon
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    Layout.preferredHeight: units.iconSizes.small
                    Layout.preferredWidth: units.iconSizes.small
                    source: "go-next"
                }

                Kirigami.Heading {
                    id: exploreTypeLabel
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    height: paintedHeight
                    elide: Text.ElideRight
                    font.weight: Font.DemiBold
                    text: model.exploreTypeLabel
                    textFormat: Text.PlainText
                    level: 2
                }
            }
        }
    }

    onClicked: {
        placeSearchByTerm(model.exploreTypeLabel, QtPositioning.circle(map.center))
    }
}
