# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-bigwordz

CONFIG += sailfishapp

SOURCES += src/harbour-bigwordz.cpp

OTHER_FILES += qml/harbour-bigwordz.qml \
	qml/cover/CoverPage.qml \
	qml/pages/AboutPage.qml \
	qml/pages/MainPage.qml \
	qml/pages/SettingsDialog.qml \
	qml/pages/StoredWordsPage.qml \
	qml/pages/util/ColorPickerButton.qml \
	qml/pages/util/ColorSliderView.qml \
	qml/pages/util/TextFieldEx.qml \
    qml/pages/util/ScreenBlank.qml \
	qml/pages/util/Persistence.js \
	rpm/harbour-bigwordz.spec \
	rpm/harbour-bigwordz.yaml \
	harbour-bigwordz.desktop

RESOURCES += \
	qrc.qrc
