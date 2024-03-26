import QtQuick
import QtQuick.Layouts

Item {
    width: 500
    height: 400
    readonly property real rowSpacing: 15
    readonly property real colSpacing: 25
    readonly property real imageWidth: 64
    readonly property int fontSize: 23

    //reasonable defaults
    property int range: 800
    property real fuelEconomy: 5.0
    property int averageSpeed: 50

    Column {
        id: dataCols
        anchors.centerIn: parent
        spacing: colSpacing


        RowLayout {
            spacing: rowSpacing
            Image {
                id: weatherImage
                source: Qt.resolvedUrl("drivingdataimages/range.png")
                Layout.preferredWidth: imageWidth
                Layout.preferredHeight: width
                fillMode: Image.PreserveAspectCrop
            }
            Text {
                id: rangeText
                text: range + " km" + "\nRange"
                font.pixelSize: fontSize
                font.bold: true
                color: "white"
            }
        }

        RowLayout {
            spacing: rowSpacing
            Image {
                id: mileageImage
                source: Qt.resolvedUrl("drivingdataimages/mileage.png")
                Layout.preferredWidth: imageWidth
                Layout.preferredHeight: width
                fillMode: Image.PreserveAspectCrop
            }
            Text {
                id: mileage
                text: fuelEconomy.toFixed(1) + " l / 100 km" + "\nAvg. Fuel Usage"
                font.pixelSize: fontSize
                font.bold: true
                color: "white"
            }
        }

        RowLayout {
            spacing: rowSpacing
            Image {
                id: avgSpeedImage
                source: Qt.resolvedUrl("drivingdataimages/averagespeed.png")
                Layout.preferredWidth: imageWidth
                Layout.preferredHeight: width
                fillMode: Image.PreserveAspectCrop
            }
            Text {
                id: avgSpeed
                text: averageSpeed + " km/h" + "\nAvg. Speed"
                font.pixelSize: fontSize
                font.bold: true
                color: "white"
            }
        }
    }
}
