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
		if (customGradColors.checked) {
			window.colorScheme = "customGrad"
			window.customSchemeColors = textGradColorPicker.color.toString()
					+ backGradColorPicker1.color.toString() + backGradColorPicker2.color.toString()
					+ '<' + directionGradPicker.currentIndex
		}
		window.tap2toggle = tap2toggle.checked
		window.useSensors = useSensors.checked
		window.sensorsSensitivity = sensorsSensitivity.sliderValue
		window.startWithStoredWord = startWithStoredWord.checked
		window.autoStoreWord = autoStoreWord.checked
		window.markupWord = markupWord.checked

		//console.log(window.colorScheme, window.customSchemeColors);
	}

	SilicaFlickable {
		id: flick
		anchors.fill: parent
		contentHeight: column.height
		Column {
			id: column
			width: parent.width
//			anchors.fill: parent

			function setColorScheme(type) {
				themeColors.checked = type === "theme"
				blackWhiteColors.checked = type === "blackWhite"
				customColors.checked = type === "custom"
				textColorPicker.enabled = customColors.checked
				backColorPicker.enabled = customColors.checked
				customGradColors.checked = type === "customGrad"
				textGradColorPicker.enabled = customGradColors.checked
				backGradColorPicker1.enabled = customGradColors.checked
				backGradColorPicker2.enabled = customGradColors.checked
				directionGradPicker.enabled = customGradColors.checked
			}

			Component.onCompleted: {
				var colorScheme = window.colorScheme
				//console.log(colorScheme, window.customSchemeColors);
				if (window.customSchemeColors) {
					if (window.customSchemeColors.length <=14) {
						textColorPicker.color = window.customSchemeColorAt(0)
						backColorPicker.color = window.customSchemeColorAt(1)
					} else {
						textGradColorPicker.color = window.customSchemeColorAt(0)
						backGradColorPicker1.color = window.customSchemeColorAt(1)
						backGradColorPicker2.color = window.customSchemeColorAt(2)
						directionGradPicker.currentIndex = parseInt(window.customSchemeColors.charAt(22));
					}
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
				x: Theme.paddingSmall
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

			TextSwitch {
				id: customGradColors
				anchors.left: parent.left
				text: qsTr("Customize")
				automaticCheck: false
				onClicked: {
					column.setColorScheme("customGrad")
				}
			}
			ColorPickerButton {
				id: textGradColorPicker
				x: Theme.itemSizeExtraSmall + Theme.paddingSmall
				text: qsTr("Text color")
				color: 'white'
			}

			ColorPickerButton {
				id: backGradColorPicker1
				x: Theme.itemSizeExtraSmall + Theme.paddingSmall
				text: qsTr("Background")
				color: 'black'
			}
			ColorPickerButton {
				id: backGradColorPicker2
				x: Theme.itemSizeExtraSmall + Theme.paddingSmall
				text: qsTr("Background")
				color: 'grey'
			}
			IconComboBox {
				id: directionGradPicker
				width: parent.width
				label: qsTr("Direction")
				currentIndex: 0
				labelMargin: Theme.itemSizeExtraSmall + Theme.paddingSmall

				menu: ContextMenu {
					IconMenuItem { source: "icon-m-page-down" }
					IconMenuItem { source: "icon-m-page-up"; rotation: 90 }
					IconMenuItem { source: "icon-m-page-up" }
					IconMenuItem { source: "icon-m-page-down"; rotation: 90 }
				}
			}

			SectionHeader {
				text: qsTr("General")
			}
			TextSwitch {
				id: startWithStoredWord
				text: qsTr("Start with latest stored word")
				description: qsTr("Next restart the initial word is the latest stored word")
				checked: window.startWithStoredWord
			}
			TextSwitch {
				id: autoStoreWord
				text: qsTr("Store words automatically")
				description: qsTr("Store words when switching to full screen or only by the pull up menu")
				checked: window.autoStoreWord
			}
			TextSwitch {
				id: markupWord
				text: qsTr("Enable short text styling markup")
				description: qsTr("Allows usage of symbols to apply style to the text")
				checked: window.markupWord
			}
			TextSwitch {
				id: tap2toggle
				text: qsTr("Double tap to toggle full screen")
				description: qsTr("Double tap over the words to switch between edit mode and full screen")
				checked: window.tap2toggle
			}
			TextSwitch {
				id: useSensors
				text: qsTr("Toggle full screen with sensors")
				description: qsTr("Set the screen vertically to switch from edit mode to full screen")
				checked: window.useSensors
			}
			Slider {
				id: sensorsSensitivity
				enabled: useSensors.checked
				handleVisible: useSensors.checked
				maximumValue: 10
				minimumValue: 2
				stepSize: 1
				value: window.sensorsSensitivity
				leftMargin: Theme.itemSizeExtraSmall
				width: parent.width
				label: infoLabel()

				function infoLabel() {
					if (sliderValue === maximumValue) {
						return qsTr("Slowest")
					}
					if (sliderValue > 6) {
						return qsTr("Slower")
					}
					if (sliderValue === minimumValue) {
						return qsTr("Fastest")
					}
					if (sliderValue < 6) {
						return qsTr("Faster")
					}
					return qsTr("Default")
				}
			}
		}
		VerticalScrollDecorator {}
	}
}





