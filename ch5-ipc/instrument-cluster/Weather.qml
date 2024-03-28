import QtQuick
import QtQuick.Layouts

Rectangle {
    width: 500
    height: 400
    color: "transparent"

    property string xweatherAPIId: "Vto2pITyX364VYjy9JiZL"
    property string xweatherAPISecretKey: "scMTmStpATW8ORNPrzNRV6MPIhR7tAHFYcKlSbms"
    property string apiUrl: "https://api.aerisapi.com/forcasts/:auto?format=json&plimit=1&filter=1min&client_id=%1&client_secret=%2".arg(xweatherAPIId).arg(xweatherAPISecretKey)

    property string cityName: "helsinki"
    property string country: "fi"
    property double timestamp: 1710422700
    property real currentTemperature: Math.round(2.91).toFixed(1)
    property real feelsLikeTemperature: Math.round(0.18).toFixed(1)
    property real minTemperature: Math.round(2.91).toFixed(1)
    property real maxTemperature: Math.round(2.91).toFixed(1)
    property real windMps: 5
    property real humidity: 87
    property string weatherIconName: "sunny.png" // lets be positive :)
    property bool isDay: true
    property int uvIndex: 0

    function convertFirstLetterToUpperCase(string) {
        return string.charAt(0).toUpperCase() + string.slice(1);
    }

    Text {
        id: locationText
        text: convertFirstLetterToUpperCase(cityName) + ", " + country.toUpperCase()
        anchors.bottom: weatherImage.top
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 30
        color: "white"
    }

    Image {
        id: weatherImage
        source: weatherIconName ? Qt.resolvedUrl("weatherimages/%1".arg(weatherIconName)) : ""
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 70
        width: parent.width * 0.4
        height: width
        fillMode: Image.PreserveAspectCrop
    }

    Text {
        id: currentTempText
        text: currentTemperature + "°C"
        font.pixelSize: 60
        anchors.verticalCenter: weatherImage.verticalCenter
        anchors.left: weatherImage.right
        anchors.leftMargin: 20
        color: "white"
    }

    Text {
        id: minmaxTempText
        text: minTemperature + "°C" + " / " + maxTemperature + "°C"
        font.pixelSize: 20
        anchors.horizontalCenter: currentTempText.horizontalCenter
        anchors.top: currentTempText.bottom
        color: "white"
    }

    Column {
        spacing: 2
        anchors.top: weatherImage.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        Text {
            id: feelsLikeText
            text: "Feels like: " + feelsLikeTemperature + " °C"
            font.pixelSize: 20
            color: "white"
        }
        /*Text {
            id: humidityText
            text: "Humidity: " + humidity + " %"
            font.pixelSize: 20
            color: "white"
        }*/
    }

    RowLayout {
        spacing: 50
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        Layout.preferredWidth: parent.width * 0.75
        Layout.preferredHeight: 20
        RowLayout {
            spacing: 10
            Image {
                source: Qt.resolvedUrl("weatherimages/humidity.png")
                fillMode: Image.PreserveAspectCrop
            }
            Text {
                text: humidity + " %"
                font.pixelSize: 20
                color: "white"
            }
        }
        RowLayout {
            spacing: 10
            Image {
                source: Qt.resolvedUrl("weatherimages/windspeed.png")
                fillMode: Image.PreserveAspectCrop
            }
            Text {
                text: windMps + " m/s"
                font.pixelSize: 20
                color: "white"
            }
        }
    }
}
