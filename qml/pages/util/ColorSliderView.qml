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

SlideshowView {
	id: root
	property var colors: []

	signal colorSelected(color color)

	height: Theme.itemSizeSmall
	width: parent.width
	itemWidth: Theme.itemSizeLarge
	snapMode: PathView.SnapToItem

	model: 18
	currentIndex: 2
	delegate: Rectangle {
		width: root.itemWidth
		height: root.height
		color: root.colors[model.index]
		MouseArea {
			anchors.fill: parent
			onClicked: {
//				console.log("click " + index)
				autoHide.restart()
				colorSelected(root.colors[model.index])
			}
		}
	}

	onCurrentIndexChanged: {
//		console.log("current index: " + currentIndex)
		autoHide.stop()
	}

	function toogleShowHide() {
		if (height > 0) {
			showHideAnim.to = 0
		} else {
			showHideAnim.to = Theme.itemSizeSmall
		}
		showHideAnim.start()
	}

	function fastHide() {
		showHideAnim.stop()
		autoHide.stop()
		height = 0
	}

	Timer {
		id: autoHide
		interval: 3000
		running: false
		repeat: false
		onTriggered: {
			if (root.height > 0) {
				showHideAnim.to = 0
				showHideAnim.start()
			}
		}
	}

	NumberAnimation {
		id: showHideAnim
		target: colorSlider
		property: "height"
		duration: 800
		easing.type: Easing.OutCubic
	}

	ColorPicker {
		id: picker
		visible: false
		Component.onCompleted: {
			var moreColors = picker.colors
			moreColors.push("#000000")
			moreColors.push("#C0C0C0")
			moreColors.push("#FFFFFF")
			root.colors = moreColors
		}
	}
}
