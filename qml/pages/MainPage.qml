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
import QtSensors 5.0
import "util"

Page {
	id: mainPage

	allowedOrientations: Orientation.All

	property bool isFullScreen: false

	property int wordsBoxHeight: 100
	property int wordsBoxWidth: 100

	onOrientationChanged: {
//		console.log("orientation changed: " + orientation + "; w: " + width + "; h: " + height)
		lazyUpdateWords.updateWidth = true
		lazyUpdateWords.updateHeight = true
		lazyUpdateWords.start()
		// some problems while editing and changing orienation thus force to close keyboard
		words.focus = true
		colorSlider.fastHide()
	}

	Component.onCompleted: {
		window.initialUpdate.connect(function() {
			// initial update
			wordsBoxHeight = mainPage.width
			wordsBoxWidth = mainPage.width
			inputText.text = window.currentText
		})
		window.onForceTextUpdate.connect(function() {
//			console.log("onForceTextUpdate: " + window.currentText)
			if (window.currentText === '') {
				if (isFullScreen) {
					wordsBox.toggleFullscreen()
				}
				inputText.text = ''
				inputText.forceEditFocus();
			} else {
				inputText.text = window.currentText
				wordsBox.forceActiveFocus()
			}
			flick.updateWords();
		})
	}

	onStatusChanged: {
		if (status === PageStatus.Activating) {
			colorSlider.fastHide()
		}
	}

	onIsFullScreenChanged: {
		colorSlider.fastHide()
	}

	SilicaFlickable {
		id: flick
		anchors.fill: parent

		contentHeight: parent.height

		PullDownMenu {
			MenuItem {
				text: qsTr("About")
				onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
			}
			MenuItem {
				text: qsTr("Settings")
				onClicked: {
					pageStack.push(Qt.resolvedUrl("SettingsDialog.qml"))
				}
			}
			MenuItem {
				text: qsTr("Toogle full screen")
				onClicked: {
					wordsBox.toggleFullscreen()
					lazyUpdateWords.start()
				}
				enabled: inputText.hasWords()
			}
		}

		PushUpMenu {
			id: upMenu
			property bool lockedScreen: false
			onActiveChanged: {
				lockedScreen = allowedOrientations !== Orientation.All
			}

			MenuItem {
				text: upMenu.lockedScreen ? qsTr("Unlock orientation") : qsTr("Lock orientation")
				visible: isFullScreen
				onClicked: {
					if (upMenu.lockedScreen) {
						// allow ony current orientation
						allowedOrientations = Orientation.All
					} else {
						// allow ony current orientation
						allowedOrientations = orientation
					}
				}
			}
			MenuItem {
				text: qsTr("Stored words")
				onClicked: {
					var page = pageStack.push(Qt.resolvedUrl("StoredWordsPage.qml"))
					page.textChanged.connect(function() {
						inputText.text = window.currentText
						flick.updateWords()
					})
				}
			}
			MenuItem {
				text: qsTr("Store current")
				visible: !window.autoStoreWord && !isFullScreen
//				enabled: inputText.hasWords() && (inputText.text.localeCompare(storedWordsModel.lastStoredWord()) !== 0)
				enabled: inputText.hasWords() && (inputText.text !== storedWordsModel.lastStoredWord())
				onClicked: {
					storedWordsModel.storeCurrentText()
				}
			}
		}

		function updateWords() {
//			console.log("flick.updateWords() - mainH: " + mainPage.height + "; mainPage.width: " + mainPage.width)
			if (isPortrait) {
				words.font.pixelSize = hiddenText.calcFontSize(480)
			} else {
				words.font.pixelSize = hiddenText.calcFontSize(520)
			}
			words.text = window.currentText
		}

		PageHeader {
			id: header1
			title: favs.visible ? "" : appname
		}

		FavoritesZone {
			id: favs
			anchors.top: parent.top
			itemHeigth: Theme.itemSizeLarge
			z: 1000
			model: favoriteWordsModel
			visible: model.count > 0 && isPortrait &&
					 (!isFullScreen || wordsBox.height < Screen.height)
			//enabled: !isFullScreen

			onContextMenuRequested: {
				colorSlider.fastHide()
			}
			onFavoriteSelected: {
				if (favoriteWord === window.currentText) {
					// skip updates...
					return
				}
//				window.currentText = favoriteWord
				inputText.text = favoriteWord
				flick.updateWords()
			}
			onRemoveFromFavorites: {
				favoriteWordsModel.removeFavoriteWord(favoriteWord)
			}
		}


		MouseArea {
			id: doubleTapDetector
			property int clickHitX: -1
			property int clickHitY: -1
			anchors.fill: wordsBox
			onClicked: {
				if (!window.tap2toggle) {
					return
				}
				if (clickHitX < 0) {
					// first click
					clickHitX = mouse.x
					clickHitY = mouse.y
					doubleTapTimeout.start()
					return
				}
				if (Math.abs(mouse.x - clickHitX) <= Theme.iconSizeLarge
						&& Math.abs(mouse.y - clickHitY) <= Theme.iconSizeLarge) {
					wordsBox.toggleFullscreen()
				}
				clickHitX = -1
				clickHitY = -1
			}

			onPressAndHold: {
				if (!isPortrait || isFullScreen
						|| wordsBox.height < mainPage.width || colorScheme != "custom") {
//					console.log("onPressAndHold... cancel slider")
					colorSlider.fastHide()
					return
				}
				// show/hide colors slider
				colorSlider.toogleShowHide()
			}

			Timer {
				id: doubleTapTimeout
				interval: 800 // ms
				running: false
				repeat: false
				onTriggered: {
					parent.clickHitX = -1
					parent.clickHitY = -1
				}
			}

			onEnabledChanged: {
				clickHitX = -1
			}
		}

		ColorSliderView {
			id: colorSlider
			height: 0
			anchors.bottom: wordsBox.top
			onColorSelected: {
				// change background color (maybe in tyhe future also change text color)
				var newColors = window.textColor() + color.toString()
//				console.log("new colors: " + newColors)
				window.customSchemeColors = newColors
			}
		}

		Rectangle {
			id: wordsBox
			width: wordsBoxWidth //parent.width
			height: wordsBoxHeight //width
			anchors.centerIn: parent
			color: window.backColor()
			clip: true
			z: upMenu.z + 1	// we want wordsBox to appear above the menu indicator and its dimmer

			function updateHeightOnEdit() {
//				console.log("wordsBox.updateHeightOnEdit() - orentation: " + orientation + "; rotation: " + rotation)
				if (isFullScreen) {
					return
				}
//				console.log("input y " + inputText.y + " header1++ " + (header1.y + header1.height + height))
				if (isPortrait) {
					if (inputText.y < (header1.y + header1.height + height)) {
						wordsBoxHeight = inputText.y - header1.y - header1.height
					} else {
						wordsBoxHeight = Screen.width
					}
					return
				}
				if (isLandscape) {
					wordsBoxHeight = Math.max(50, inputText.y - header1.y - header1.height)
//					console.log("wordsBoxHeight: " + wordsBoxHeight)
					return
				}
			}

			function updateHeight() {
//				console.log("wordsBox.updateHeight() - isFullScreen: " + isFullScreen)
				if (isFullScreen) {
					wordsBoxHeight = isLandscape ? Screen.width : Screen.height //mainPage.height
					return
				}
				if (isLandscape) {
					wordsBoxHeight = Math.max(50, inputText.y - header1.y - header1.height)
					return
				}
				wordsBoxHeight = mainPage.width
			}

			function updateWitdh() {
				if (isFullScreen) {
					wordsBoxWidth = mainPage.width
					return
				}
				wordsBoxWidth = mainPage.width
//				console.log("wordsBox.updateWitdh() wordsBoxWidth: " + wordsBoxWidth)
			}

			function toggleFullscreen() {
				words.focus = true		// force to close keyboard
				if (inputText.text.trim().length === 0 && !isFullScreen) {
					return
				}

				isFullScreen = !isFullScreen
				lazyUpdateWords.updateWidth = true
				lazyUpdateWords.updateHeight = true
				lazyUpdateWords.start()
				if (isFullScreen) {
					if (window.autoStoreWord) {
						storedWordsModel.storeCurrentText()
					}
				} else {
					allowedOrientations = Orientation.All
					upMenu.lockedScreen = false
				}
			}

			Label {
				// actual displayed words
				id: words
				anchors.fill: parent
				wrapMode: Text.WordWrap
				color: window.textColor()
				font.bold: true
				lineHeight: 0.96 //TODO reduce more the lineHeight and center

				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
			}
		}

		TextFieldEx {
			id: inputText
			width: mainPage.width - x
			anchors.bottom: parent.bottom
			maxLength: 80
			z: upMenu.z + 2

			function hasWords() {
				return inputText.text.trim().length > 0
			}

			onYChanged: {
				if (isFullScreen) {
					// isFullScreen requested while editing...
					return
				}
//				console.log("inputText.onYChanged " + y + " / height: " + height)
				wordsBox.updateHeightOnEdit()
				lazyUpdateWords.start()
				colorSlider.fastHide()
			}

			onTextChanged: {
//				console.log("inputText.onTextChanged: " + text)
				if (text === window.currentText) {
					// skip updates...
					return
				}
				window.currentText = text
				flick.updateWords()
			}

			Keys.onReturnPressed: words.focus = true
			Keys.onEnterPressed: words.focus = true

			Timer {
				// to prevent unnecessary calls to calcFontSize()
				property bool updateWidth: false
				property bool updateHeight: false
				id: lazyUpdateWords
				interval: 200
				running: false
				repeat: false
				onTriggered: {
//					console.log("lazyUpdateWords.onTriggered")
					if (updateWidth) {
						wordsBox.updateWitdh()
						updateWidth = false
					}
					if (updateHeight) {
						wordsBox.updateHeight()
						updateHeight = false
					}
					header1.visible = !isFullScreen
					inputText.visible = !isFullScreen
					words.font.pixelSize = 1 // forces item position update
					flick.updateWords()
				}
			}
		}

		Text {
			id: hiddenText
			visible: false
			font.bold: true
			//wrapMode: Text.WordWrap
			lineHeight: 0.95 //TODO reduce more the lineHeight and center


			function calcFontSize(startSize) {
				var h = wordsBox.height
				var w = wordsBox.width
				var size2 = startSize
				var testHW = (h + w) * 1.2

				hiddenText.text = window.currentText

				hiddenText.font.pixelSize = size2
				hiddenText.wrapMode = Text.NoWrap
//				console.log("w: " + w + ", h:" + h + ", w.y: " + words.y +	"  --- pw: " + hiddenText.paintedWidth + ", ph:" + hiddenText.paintedHeight + "; testHW=" + testHW)
				if (hiddenText.paintedWidth > w || hiddenText.paintedHeight > wordsBoxHeight) {
					hiddenText.wrapMode = Text.WordWrap
					hiddenText.width = w
//					console.log("pw2: " + hiddenText.paintedWidth + ", ph2:" + hiddenText.paintedHeight)
					while (hiddenText.paintedWidth >= w || hiddenText.paintedHeight >= h) {
						size2 = size2  - (hiddenText.paintedHeight + hiddenText.paintedWidth > testHW ? 40 : 8)
						hiddenText.font.pixelSize = size2
						if (size2 < 16) {
							break
						}
//						console.log("pixelSize: " + size2 + " painted W: " + hiddenText.paintedWidth + ", H: " + hiddenText.paintedHeight + "; w+h: " + (hiddenText.paintedHeight+hiddenText.paintedWidth))
					}
				}
				return size2
			}
		}
	}

	Accelerometer {
		property int posCount
		property string posDirection
		property bool lastToogleByAccel

		function calcDirection(x, y) {
			if (x > 8.5) {
				return "x"
			}
			if (x < -8.5) {
				return "-x"
			}
			if (y > 8.5) {
				return "y"
			}
			if (y < -8.5) {
				return "-y"
			}
			return "off"
		}

		id: accel
		active: window.useSensors && Qt.application.active && pageStack.depth == 1
		dataRate: 4
		onReadingChanged: {
//			console.log("---onReadingChanged--- x:" + reading.x + "; y: " + reading.y + "; z: "+ reading.z);

			var direction = calcDirection(reading.x, reading.y)
			if (direction === posDirection) {
				if (posCount >= 0 && inputText.hasWords()) {
					posCount++
				}
			} else {
				posCount = 0
				posDirection = direction
			}

			if (posCount > window.sensorsSensitivity) {
				if (isFullScreen && lastToogleByAccel && posDirection === "off") {
					// cancel fullscreen only if made by accelerometer
					lastToogleByAccel = false
					wordsBox.toggleFullscreen()
				}
				if (!isFullScreen && posDirection !== "off") {
					// set fullscreen
					lastToogleByAccel = true
					posCount = -1		// "standby until posDirection change" state
					wordsBox.toggleFullscreen()
				}
			}
//			console.log("posCount: " + posCount +"; dir: " + posDirection)
		}

		onActiveChanged: {
			if (active) {
				posCount = 0
				posDirection = ""
				lastToogleByAccel = false
			}
		}
	}
	Connections {
		ignoreUnknownSignals: true
		target: inputText
		onTextChanged: {
			// reset if text is being changed
			accel.posCount = 0
		}
	}

	ScreenBlank {
		id: screenBlank
		suspend: upMenu.lockedScreen
	}
}

