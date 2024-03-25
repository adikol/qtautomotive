import QtQuick
import QtLocation
import QtPositioning 6.6
import QtQml

 Map {
    id: map

    property var pathArray: []
    property var segmentArray: []
    property var currentPosition: ({})
    property var currentSegment: ({})

    property real distanceToDestination: 0

    property date timeOfArrival: new Date()
    property var locale: Qt.locale()

    Behavior on center {
      CoordinateAnimation {
        duration: 900
        easing.type: Easing.InOutQuad
       }
    }

    property real myBearing
    onMyBearingChanged: {
         map.bearing = myBearing
    }

    RotationAnimation {
        id: bearingAnimation
        target: map
        property: "myBearing"
        direction: RotationAnimation.Shortest
        duration: 500

        function distance(a, b)
        {
            var mx = Math.max(a, b)
            var mn = Math.min(a, b)

            return Math.min( mx - mn, mn + 360 - mx)
        }

        function startBearingAnimation(to)
        {
            bearingAnimation.stop()
            bearingAnimation.from = map.bearing
            bearingAnimation.to = to
            if(Math.abs(bearingAnimation.from - bearingAnimation.to) > 15) {
                bearingAnimation.start()
            }
        }
    }

    // helper function
    function convertToDegrees(radian) {
      return (radian * 180) / Math.PI;
    }

    function getCurrentDirection(previousCoordinates, currentCoordinates) {
      const diffLat = currentCoordinates.latitude - previousCoordinates.latitude;
      const diffLng = currentCoordinates.longitude - previousCoordinates.longitude;
      const anticlockwiseAngleFromEast = convertToDegrees(
        Math.atan2(diffLat, diffLng)
      );

      const clockwiseAngleFromNorth = 90 - anticlockwiseAngleFromEast;
      return clockwiseAngleFromNorth;
    }

    MapQuickItem {
        id: carItem
        anchorPoint.x: carImage.width * 0.5
        anchorPoint.y: carImage.height

        Behavior on coordinate {
          CoordinateAnimation {
            duration: 900
            easing.type: Easing.InOutQuad
           }
        }

        sourceItem: Image {
            id: carImage
            width: 40
            height: 40
            source: Qt.resolvedUrl("images/car.png")
        }
    }

    Rectangle {
        id: instructionsArea
        property alias navText: instructionText.text
        anchors {
            left: map.left
            right: map.right
        }
        z: 1
        height: 50
        anchors{
            top: map.top
            left: map.left
            right: map.right
        }
        color: "brown"
        Text {
            id: instructionText
            anchors {
                left: parent.left
                right: parent.right
                margins: 50
            }
            height: parent.height
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: 18
            color: "white"
            wrapMode: Text.WordWrap
        }
    }

    Rectangle {
        id: informationArea
        property alias arrivalText: informationText.text
        width: map.width
        z: 1
        height: 40
        anchors{
            bottom: map.bottom
            left: map.left
            right: map.right
        }
        color: "brown"
        Text {
            id: informationText
            anchors {
                left: parent.left
                right: parent.right
                margins: 10
            }
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: 16
            color: "white"
            text : "Distance to destination: " + distanceToDestination + " km" + "\nArriving at " + timeOfArrival.toLocaleTimeString(locale, Locale.ShortFormat)
        }
    }

    Timer {
        id: timer
        repeat: true
        interval: 900
        onTriggered: {
            if(pathArray.length)
            {
                var previousPosition = currentPosition
                currentPosition = pathArray.shift()

                if(currentPosition != previousPosition)
                {
                    map.center = currentPosition
                    carItem.coordinate = currentPosition

                    var directionAngle = getCurrentDirection(previousPosition, currentPosition)
                    //map.bearing = directionAngle

                    bearingAnimation.startBearingAnimation(directionAngle)

                    if(!currentSegment.path.includes(currentPosition))
                    {
                        distanceToDestination -= (Math.ceil(currentSegment.distance/10)*10) / 1000
                        distanceToDestination = distanceToDestination.toFixed(1)

                        currentSegment = segmentArray.shift()

                        if(segmentArray.length == 0)
                        {
                            distanceToDestination = 0
                        }
                    }

                    function convertFirstLetterToLowerCase(string) {
                        return string.charAt(0).toLowerCase() + string.slice(1);
                    }

                    instructionsArea.navText = "In " + Math.round(Math.ceil(currentSegment.distance/10)*10) + "m, " +  convertFirstLetterToLowerCase(segmentArray[0].maneuver.instructionText)
                }
            }
        }
    }

    WheelHandler {
        id: wheel
        // workaround for QTBUG-87646 / QTBUG-112394 / QTBUG-112432:
        // Magic Mouse pretends to be a trackpad but doesn't work with PinchHandler
        // and we don't yet distinguish mice and trackpads on Wayland either
        acceptedDevices: Qt.platform.pluginName === "cocoa" || Qt.platform.pluginName === "wayland"
                         ? PointerDevice.Mouse | PointerDevice.TouchPad
                         : PointerDevice.Mouse
        rotationScale: 1/120
        property: "zoomLevel"
    }

    DragHandler {
        id: drag
        target: null
        onTranslationChanged: (delta) => map.pan(-delta.x, -delta.y)
    }

    PinchHandler {
       id: pinch
       target: null
       onActiveChanged: if (active) {
           map.startCentroid = map.toCoordinate(pinch.centroid.position, false)
       }
       onScaleChanged: (delta) => {
           map.zoomLevel += Math.log2(delta)
           map.alignCoordinateToPoint(map.startCentroid, pinch.centroid.position)
       }
       onRotationChanged: (delta) => {
           map.bearing -= delta
           map.alignCoordinateToPoint(map.startCentroid, pinch.centroid.position)
       }
       grabPermissions: PointerHandler.TakeOverForbidden
   }

    Component.onCompleted: {
        console.log("max zoom level: " + maximumZoomLevel)
        console.log("min zoom level: " + minimumZoomLevel)

        console.log("max tilt level: " + maximumTilt)
        console.log("min tilt level: " + minimumTilt)
        query.addWaypoint(QtPositioning.coordinate(60.170448, 24.942046))
        query.addWaypoint(QtPositioning.coordinate(60.1783, 24.8329))
        query.travelModes = RouteQuery.CarTravel

        for(var i = 0; i< supportedMapTypes.length; i++)
        {
            console.log("supported map type: " + supportedMapTypes[i])
        }
    }

    RouteQuery {
        id: query
    }

    RouteModel {
        id: routeModel
        plugin: plugin
        query: query
        autoUpdate: true
        onStatusChanged: {
            if (status == RouteModel.Ready) {
                map.zoomLevel = 17
                map.tilt = 60
                map.pathArray = routeModel.get(0).path
                map.segmentArray = routeModel.get(0).segments
                map.currentSegment = map.segmentArray.shift()
                map.addMapItem(carItem)

                distanceToDestination = (routeModel.get(0).distance / 1000).toFixed(1)

                timeOfArrival.setSeconds(timeOfArrival.getSeconds() + routeModel.get(0).travelTime)

                timer.running = true
            } else if (status == RouteModel.Error) {
                console.log("route error")
            }
        }
    }

    MapItemView {
        model: routeModel
        delegate: routeDelegate
        autoFitViewport: true
    }

    Component {
        id: routeDelegate

        MapRoute {
            route: routeData
            line.color: "blue"
            line.width: 3
            smooth: true
            opacity: 0.6
        }
    }

    plugin: Plugin {
        id: plugin
        name: "osm"

        PluginParameter {
           name: "osm.mapping.providersrepository.address"
           value: "https://tile.thunderforest.com/transport/{z}/{x}/{y}.png?apikey=caa503811c50429580c87668294868d5"
           //value: "https://tile.thunderforest.com/neighbourhood/{z}/{x}/{y}.png?apikey=caa503811c50429580c87668294868d5"
           //value: "https://tile.thunderforest.com/transport-dark/{z}/{x}/{y}.png?apikey=caa503811c50429580c87668294868d5"
        }

        PluginParameter {
            name: "osm.mapping.highdpi_tiles"
            value: true
        }

        PluginParameter {
            name: "osm.mapping.providersrepository.disabled"
            value: true
        }
    }

    center: QtPositioning.coordinate(60.170448, 24.942046) // Helsinki
    copyrightsVisible: false
    activeMapType: supportedMapTypes[0]
}
