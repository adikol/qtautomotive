import QtQuick
import QtCharts 2.6

Rectangle {
    width: 500
    height: 400
    color: "transparent"

    property string xweatherAPIId: "Vto2pITyX364VYjy9JiZL"
    property string xweatherAPISecretKey: "scMTmStpATW8ORNPrzNRV6MPIhR7tAHFYcKlSbms"
    property string apiUrl: "https://api.aerisapi.com/conditions/:auto?format=json&plimit=1&filter=1min&client_id=%1&client_secret=%2".arg(xweatherAPIId).arg(xweatherAPISecretKey)

    property string cityName: "helsinki"
    property string country: "fi"
    property double timestamp: 1710422700
    property real currentTemperature: Math.round(2.91).toFixed(1)
    property real feelsLikeTemperature: Math.round(0.18).toFixed(1)
    property real humidity: 87
    property string weatherIconName: "sunny.png" // lets be positive :)
    property bool isDay: true
    property bool tabVisible: false

    function convertFirstLetterToUpperCase(string) {
        return string.charAt(0).toUpperCase() + string.slice(1);
    }

    // A timer to refresh the forecast every 5 minutes
    Timer {
        interval: 300000
        repeat: true
        triggeredOnStart: true
        running: tabVisible
        onTriggered: {
            var xhr = new XMLHttpRequest;
            xhr.open("GET",
                     apiUrl);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    console.log("response text: " + xhr.responseText)
                    var a = JSON.parse(xhr.responseText);
                    parseWeatherData(a);
                }
            }
            xhr.send();
        }
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
        source: Qt.resolvedUrl("weatherimages/%1".arg(weatherIconName))
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 70
        width: parent.width * 0.4
        height: width
        fillMode: Image.PreserveAspectCrop
    }

    Text {
        id: currentTempText
        text: currentTemperature + " °C"
        font.pixelSize: 60
        anchors.verticalCenter: weatherImage.verticalCenter
        anchors.left: weatherImage.right
        anchors.leftMargin: 20
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
        Text {
            id: humidityText
            text: "Humidity: " + humidity + " %"
            font.pixelSize: 20
            color: "white"
        }
    }

    function parseWeatherData(weatherData) {

        for (var i in weatherData.response) {

            var responseObj = weatherData.response[i];

            cityName = responseObj.place.name
            country = responseObj.place.country

            for (var j in responseObj.periods) {
                var periodObj = responseObj.periods[j];
                timestamp = periodObj.timestamp

                currentTemperature = Math.round(periodObj.tempC).toFixed(1)
                feelsLikeTemperature = Math.round(periodObj.feelslikeC).toFixed(1)
                humidity = periodObj.humidity
                weatherIconName = periodObj.icon
                isDay = periodObj.isDay

                console.log("ts: " + timestamp)
                console.log("cityname: " + cityName)
                console.log("country: " + country)
                console.log("current temp: " + currentTemperature)
                console.log("icon name: " + weatherIconName)
            }
        }
    }
}
