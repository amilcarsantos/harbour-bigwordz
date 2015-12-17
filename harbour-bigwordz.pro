# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
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
	qml/pages/util/CompleterPopup.qml \
	qml/pages/util/TextFieldEx.qml \
	qml/pages/util/ScreenBlank.qml \
	qml/pages/util/FavoritesZone.qml \
	qml/pages/util/Persistence.js \
	qml/pages/util/Markup.js \
	rpm/harbour-bigwordz.spec \
	rpm/harbour-bigwordz.yaml \
	translations/*.ts \
	harbour-bigwordz.desktop \
	rpm/harbour-bigwordz.changes

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-bigwordz-pt.ts \
	translations/harbour-bigwordz-de.ts \
	translations/harbour-bigwordz-zh.ts \
	translations/harbour-bigwordz-fr.ts
