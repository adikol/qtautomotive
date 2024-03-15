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

    LeftDial {
        id: leftDial
        anchors.left: parent.left
        anchors.leftMargin: 0.1 * width

        value: instrumentCluster.speed
        metricSystem: instrumentCluster.systemType === InstrumentClusterModule.Metric
    }

    Navigation {
        id: map

        enabled: topbar.selectedNavigatorIndex === 1
        visible: enabled
        width: 0.6 * 720

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.top: topbar.bottom
        anchors.margins: 3
    }

    Weather {
        id: weather
        tabVisible: topbar.selectedNavigatorIndex === 2
        enabled: tabVisible
        visible: tabVisible

        width: 0.66 * 720
        height: width

        anchors.centerIn: parent
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
