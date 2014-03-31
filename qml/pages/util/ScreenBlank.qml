import QtQuick 2.0

Timer {
    id: timer
	running: false

    property bool suspend: false
	// TODO suport the 'suspend screen saver' in future releases
}
