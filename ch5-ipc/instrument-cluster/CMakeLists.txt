set(CMAKE_AUTOMOC ON)

if(NOT DEFINED INSTALL_EXAMPLESDIR)
    set(INSTALL_EXAMPLESDIR "examples")
endif()

set(INSTALL_EXAMPLEDIR "${INSTALL_EXAMPLESDIR}/interfaceframework/qface-tutorial/chapter5-ipc")

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick Location Positioning)

qt_add_executable(ic_chapter5
    main.cpp
)

set_target_properties(ic_chapter5 PROPERTIES RUNTIME_OUTPUT_DIRECTORY ../)
set_target_properties(ic_chapter5 PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE FALSE
    QT_QML_IMPORT_PATH "${CMAKE_CURRENT_BINARY_DIR}/../imports"
)
set_property(TARGET ic_chapter5 APPEND PROPERTY QT_ANDROID_EXTRA_PLUGINS
    "${CMAKE_CURRENT_BINARY_DIR}/../interfaceframework")

target_link_libraries(ic_chapter5 PUBLIC
    Qt::Core
    Qt::Gui
    Qt::Qml
    Qt::Quick
)

# Resources:
set(app_resource_files
    "Cluster.qml"
    "Dial.qml"
    "DrivingData.qml"
    "Fuel.qml"
    "Label.qml"
    "LeftDial.qml"
    "Navigation.qml"
    "RightDial.qml"
    "Top.qml"
    "Weather.qml"
)

qt_add_resources(ic_chapter5 "app"
    PREFIX
        "/"
    FILES
        ${app_resource_files}
)

set(images_resource_files
    "../../images/+--.png"
    "../../images/P-R-N-D.png"
    "../../images/dial_cursor.png"
    "../../images/dial_cursor_right.png"
    "../../images/dial_fill_color.png"
    "../../images/dial_fill_color_left.png"
    "../../images/dial_pattern.png"
    "../../images/fuel.png"
    "../../images/fuel_level.png"
    "../../images/fuelsymbol_orange.png"
    "../../images/left_dial.png"
    "../../images/mask_overlay.png"
    "../../images/middle-bkg.png"
    "../../images/middle-circle.png"
    "../../images/right_dial.png"
    "../../images/top_bar.png"
    "../../images/car.png"
    "../../images/car.jpg"
)

qt_add_resources(ic_chapter5 "images"
    PREFIX
        "/images"
    BASE
        "../../images"
    FILES
        ${images_resource_files}
)

file(GLOB weather_images "../../images/weather/*.png")
file(GLOB drivingdata_images "../../images/drivingdata/*.png")

qt_add_resources(ic_chapter5 "weatherimages"
    PREFIX
        "/weatherimages"
    BASE
        "../../images/weather/"
    FILES
        ${weather_images}
)

qt_add_resources(ic_chapter5 "drivingdataimages"
    PREFIX
        "/drivingdataimages"
    BASE
        "../../images/drivingdata/"
    FILES
        ${drivingdata_images}
)

install(TARGETS ic_chapter5
    RUNTIME DESTINATION "${INSTALL_EXAMPLEDIR}"
    BUNDLE DESTINATION "${INSTALL_EXAMPLEDIR}"
    LIBRARY DESTINATION "${INSTALL_EXAMPLEDIR}"
)
