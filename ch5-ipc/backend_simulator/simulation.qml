// Copyright (C) 2021 The Qt Company Ltd.
// Copyright (C) 2019 Luxoft Sweden AB
// Copyright (C) 2018 Pelagicore AG
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtPositioning
import Example.If.InstrumentClusterModule.simulation

QtObject {
    property var settings : IfSimulator.findData(IfSimulator.simulationData, "InstrumentCluster")
    property bool defaultInitialized: false
    property LoggingCategory qLcInstrumentCluster: LoggingCategory {
        name: "example.if.instrumentclustermodule.simulation.instrumentclusterbackend"
    }
    property var backend : InstrumentClusterBackend {


        //Weather values
        property string cityName: "helsinki"
        property string country: "fi"
        property double timestamp: 1710422700
        property real currentTemperature: Math.round(2.91).toFixed(1)
        property real feelsLikeTemperature: Math.round(0.18).toFixed(1)
        property real minTemperature: 10
        property real maxTemperature: 20
        property real windMps: 5
        property real humidity: 87
        property string weatherIconName: "sunny.png" // lets be positive :)
        property bool isDay: true
        property int uvIndex: 0

        //Weather API keys
        property string xweatherAPIId: "Vto2pITyX364VYjy9JiZL"
        property string xweatherAPISecretKey: "scMTmStpATW8ORNPrzNRV6MPIhR7tAHFYcKlSbms"
        property string apiUrl: "https://api.aerisapi.com/forecasts/:auto?format=json&plimit=1&filter=1min&client_id=%1&client_secret=%2".arg(xweatherAPIId).arg(xweatherAPISecretKey)

        function initialize() {
            console.log(qLcInstrumentCluster, "INITIALIZE")
            if (!defaultInitialized) {
                IfSimulator.initializeDefault(settings, backend)
                defaultInitialized = true
            }
            Base.initialize()
        }

        //Gear values
        property int gearSpeed: 260 / 6
        property int currentGear: speed / gearSpeed
        rpm : currentGear >= 1 ? 3000 + (speed % gearSpeed) / gearSpeed * 2000
                               : (speed % gearSpeed) / gearSpeed * 5000


        //Driving data values
        readonly property int maxRange: 800
        readonly property int worstEconomyFigure: 10
        readonly property int maxAverageSpeed: 100
        readonly property int odometerDefaultValue: 5000
        property int range: maxRange
        property real fuelEconomy: 5.0
        property int averageSpeed: 50
        property int odometerValue: odometerDefaultValue


        property var animation: SequentialAnimation {
            loops: Animation.Infinite
            running: true

            ParallelAnimation {
                SequentialAnimation {

                    NumberAnimation {
                        target: backend
                        property: "speed"
                        from: 0
                        to: 80
                        duration: 4000
                    }

                    NumberAnimation {
                        target: backend
                        property: "speed"
                        to: 50
                        duration: 2000
                    }

                    NumberAnimation {
                        target: backend
                        property: "speed"
                        to: 200
                        duration: 7000
                    }

                    ScriptAction {
                        script: {
                            backend.currentWarning = InstrumentClusterModule.warning("red","LOW FUEL", "images/fuelsymbol_orange.png")
                        }
                    }

                    NumberAnimation {
                        target: backend
                        property: "speed"
                        to: 0
                        duration: 5000
                    }

                    ScriptAction {
                        script: {
                            backend.currentWarning = InstrumentClusterModule.warning()
                        }
                    }
                }

                NumberAnimation {
                    target: backend
                    property: "fuel"
                    from: 1
                    to: 0
                }
            }

            NumberAnimation {
                target: backend
                property: "fuel"
                from: 0
                to: 1
                duration: 4000
            }
        }

        property var positionalInfo: PositionSource {
                id: src
                updateInterval: 600
                active: true
                preferredPositioningMethods: PositionSource.AllPositioningMethods
                name: "corelocation"

                PluginParameter { name: "RequestAlwaysPermission"; value: true }


                Component.onCompleted: {
                      src.start()
                      src.update()
                      var supPos  = "Unknown"
                      if (src.supportedPositioningMethods == PositionSource.NoPositioningMethods) {
                           supPos = "NoPositioningMethods"
                      } else if (src.supportedPositioningMethods == PositionSource.AllPositioningMethods) {
                           supPos = "AllPositioningMethods"
                      } else if (src.supportedPositioningMethods == PositionSource.SatellitePositioningMethods) {
                           supPos = "SatellitePositioningMethods"
                      } else if (src.supportedPositioningMethods == PositionSource.NonSatellitePositioningMethods) {
                           supPos = "NonSatellitePositioningMethods"
                      }
                      console.log("Position Source Loaded || Supported: "+supPos+" Valid: "+valid);

                      console.log("\n position error: " + sourceError)
                }

                onPositionChanged: {
                    var coord = src.position.coordinate;
                    console.log("Coordinate:", coord.longitude, coord.latitude);
                    backend.longitude = coord.longitude;
                    backend.latitude = coord.latitude;
                    console.log(src.nmeaSource)
                }
            }

        // A timer to refresh the forecast every 5 minutes
        property var timer: Timer {
            interval: 300000
            repeat: true
            triggeredOnStart: true
            running: true
            onTriggered: {
                var xhr = new XMLHttpRequest;
                xhr.open("GET",
                         backend.apiUrl);
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        console.log("response text: " + xhr.responseText)
                        var a = JSON.parse(xhr.responseText);
                        backend.parseWeatherData(a);
                    }
                }
                xhr.send();
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
                    maxTemperature = Math.round(periodObj.maxTempC).toFixed(1)
                    minTemperature = Math.round(periodObj.minTempC).toFixed(1)
                    windMps = periodObj.windSpeedMPS
                    humidity = periodObj.humidity
                    weatherIconName = periodObj.icon
                    isDay = periodObj.isDay
                    uvIndex = periodObj.uvi
                }
            }
            backend.weatherInfo = InstrumentClusterModule.weatherInfo(cityName, country, timestamp, currentTemperature, minTemperature, maxTemperature, windMps, feelsLikeTemperature, humidity, weatherIconName, isDay, uvIndex)
        }


        property var drivingDataTimer: Timer {
            interval: 7200
            repeat: true
            triggeredOnStart: true
            running: true
            onTriggered: {
                backend.range =  backend.range - 1
                if(backend.range === 0)
                {
                    backend.range = maxRange
                }
                backend.fuelEconomy = Math.floor(Math.random() * backend.worstEconomyFigure);
                backend.averageSpeed = Math.floor(Math.random() * backend.maxAverageSpeed);
                backend.odometerValue += 1

                backend.drivingData = InstrumentClusterModule.drivingData(backend.range, backend.fuelEconomy, backend.averageSpeed, backend.odometerValue)
            }
        }
    }
}

