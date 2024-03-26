// Copyright (C) 2021 The Qt Company Ltd.
// Copyright (C) 2019 Luxoft Sweden AB
// Copyright (C) 2018 Pelagicore AG
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause


import QtQuick
import QtQuick.Window
import Example.If.InstrumentClusterModule

Window {
    id: root

    width: 1920
    height: 720
    title: qsTr("QtIF Instrument Cluster Chapter 5")
    visible: true
    color: "#0c0c0c"

    InstrumentCluster {
        id: instrumentCluster
    }

    DrivingData {
        id: dataPage
        enabled: topbar.selectedNavigatorIndex === 0
        visible: enabled

        anchors.centerIn: parent


        range: instrumentCluster.drivingData.range
        fuelEconomy: instrumentCluster.drivingData.mileage
        averageSpeed: instrumentCluster.drivingData.averageSpeed
    }

    Navigation {
        id: map

        enabled: topbar.selectedNavigatorIndex === 1
        visible: enabled
        width: 900

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.top: topbar.bottom
        anchors.topMargin: 35
        anchors.bottomMargin: 135
    }

    LeftDial {
        id: leftDial
        anchors.left: parent.left
        anchors.leftMargin: 0.1 * width
        anchors.verticalCenter: parent.verticalCenter

        value: instrumentCluster.speed
        metricSystem: instrumentCluster.systemType === InstrumentClusterModule.Metric
    }

    Text {
        id: dataUnavailableText
        text: "Weather data unavailable"
        anchors.centerIn: parent
        font.pixelSize: 16
        color: "white"
        visible: !weather.visible && weather.enabled
    }

    Weather {
        id: weather
        enabled: topbar.selectedNavigatorIndex === 2
        visible: enabled && instrumentCluster && instrumentCluster.weatherInfo.weathericon
        width: 0.66 * 720
        height: width

        anchors.centerIn: parent

        cityName: instrumentCluster.weatherInfo.city
        country: instrumentCluster.weatherInfo.country
        timestamp: instrumentCluster.weatherInfo.timestamp
        currentTemperature: instrumentCluster.weatherInfo.temperature
        feelsLikeTemperature: instrumentCluster.weatherInfo.feelslike
        humidity: instrumentCluster.weatherInfo.humidity
        weatherIconName: instrumentCluster.weatherInfo.weathericon
        isDay: instrumentCluster.weatherInfo.isday
    }

    RightDial {
        id: rightDial
        anchors.right: parent.right
        anchors.rightMargin: 0.1 * width

        value: instrumentCluster.rpm
        warningColor: instrumentCluster.currentWarning.color
        warningText: instrumentCluster.currentWarning.text
        warningIcon: instrumentCluster.currentWarning.icon
        fuelLevel: instrumentCluster.fuel
    }

    Top {
        id: topbar
        focus:true
        y: 7
        anchors.horizontalCenter: parent.horizontalCenter

        temperature: instrumentCluster.temperature

        Keys.onReleased: (event)=> {
            if (event.key === Qt.Key_Left)
            {
                selectedNavigatorIndex = Math.max(selectedNavigatorIndex-1, 0)
            }
            else if (event.key === Qt.Key_Right)
            {
                selectedNavigatorIndex = Math.min(selectedNavigatorIndex+1, 2)
            }
        }
    }

    Image {
        anchors.fill: parent
        source: Qt.resolvedUrl("images/mask_overlay.png")
    }
}
