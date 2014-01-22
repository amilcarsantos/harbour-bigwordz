/*
  Copyright (C) 2014 Amilcar Santos
  Contact: Amilcar Santos <amilcar.santos@gmail.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Amilcar Santos nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/


import QtQuick 2.0
import Sailfish.Silica 1.0
import "util"

Dialog {
	id: dialog

	// allowedOrientations: Orientation.All

	onAccepted: {
		if (themeColors.checked) {
			window.colorScheme = "theme"
		}
		if (blackWhiteColors.checked) {
			window.colorScheme = "blackWhite"
		}
		if (customColors.checked) {
			window.colorScheme = "custom"
			window.customSchemeColors = textColorPicker.color.toString() + backColorPicker.color.toString()
		}
	}

	Flickable {
		id: flick
		width: parent.width
		height: parent.height
		anchors.fill: parent
		contentHeight: column.height
		Column {
			id: column
			anchors.fill: parent

			function setColorScheme(type) {
				themeColors.checked = type === "theme"
				blackWhiteColors.checked = type === "blackWhite"
				customColors.checked = type === "custom"
				textColorPicker.enabled = customColors.checked
				backColorPicker.enabled = customColors.checked
		//		colorsLabel.text = colorsLabel.text + type.substring(0,1)
			}

			Component.onCompleted: {
				var colorScheme = window.colorScheme
				if (window.customSchemeColors) {
					textColorPicker.color = window.customSchemeColors.substring(0,7)
					backColorPicker.color = window.customSchemeColors.substring(7)
				}
				if (colorScheme) {
					column.setColorScheme(window.colorScheme)
				} else {
					column.setColorScheme("theme")
				}
			}

			DialogHeader {
				title: qsTr("Settings")
				acceptText: qsTr("Save")
			}
			SectionHeader {
				text: qsTr("Appearance")
			}

			Label {
				id: colorsLabel
				font.pixelSize: Theme.fontSizeLarge
				text: qsTr("Text colors")
			}

			// tipo cor/fundo
			TextSwitch {
				id: themeColors
				anchors.left: parent.left
				text: qsTr("Theme colors")
				automaticCheck: false
				onClicked: {
					column.setColorScheme("theme")
				}
			}
			TextSwitch {
				id: blackWhiteColors
				anchors.left: parent.left
				text: qsTr("Black and white")
				automaticCheck: false
				onClicked: {
					column.setColorScheme("blackWhite")
				}
			}
			TextSwitch {
				id: customColors
				anchors.left: parent.left
				text: qsTr("Customize")
				automaticCheck: false
				onClicked: {
					column.setColorScheme("custom")
				}
			}
			ColorPickerButton {
				id: textColorPicker
				x: Theme.itemSizeExtraSmall + Theme.paddingSmall
				text: qsTr("Text color")
				color: 'white'
			}

			ColorPickerButton {
				id: backColorPicker
				x: Theme.itemSizeExtraSmall + Theme.paddingSmall
				text: qsTr("Background")
				color: 'black'
			}

			SectionHeader {
				text: qsTr("General")
			}
			TextSwitch {
				id: tap2toggle
				text: qsTr("Double tap to toggle full screen")
				description: qsTr("Double tap over the words to swicth between full screen and edit mode")
				checked: window.tap2toggle
				onCheckedChanged: {
					window.tap2toggle = tap2toggle.checked
				}
			}
/* TODO
			TextSwitch {
				id: useSensors
				text: "Toogle Full Screen with Sensors"
				description: "Use accelerometer to switch between full screen and edit mode"
				onCheckedChanged: {
					window.useSensors = useSensors.checked
				}
			}*/
		}
	}
}





