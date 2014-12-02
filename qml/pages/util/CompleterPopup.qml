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

BackgroundItem {

	id: root

	property bool disabled: false
	property string text
	property string highlightedText
	property variant model

	height: Theme.fontSizeSmall + Theme.paddingMedium * 2
	anchors.left: parent.left
	anchors.right: parent.right

	visible: false
	signal textSelected(string text)

	function complete(text) {
		if (disabled) {
			return
		}
		if (text.length < 3) {
			highlightedText = ''
			root.state = 'no_minimal'
			searchTimer.running = false
			return
		}
		if (root.text === text) {
			// selection
			root.state = 'finalize'
			return
		}

		var reset = highlightedText.length > text.length
		if (state == 'no_match' && !reset) {
			// skip searchs until next reset
//			console.log(highlightedText)
			searchTimer.running = false
			return
		}

		highlightedText = text.toLowerCase()
		searchTimer.startSearch(reset);
	}

//	Rectangle {
//		anchors.fill: parent
//		color: Theme.highlightBackgroundColor
//		opacity: 0.3
//	}

	Image {
		anchors.top: parent.top
		width: parent.width
		height: parent.height
		fillMode: Image.Stretch
		source: "image://theme/graphic-system-gradient?" + Theme.highlightBackgroundColor
	}

	Label {
		anchors.fill: parent
		anchors.leftMargin: Theme.paddingSmall
		text: root.highlightedText.length < 3 ? ""
				: formatText(root.text, root.highlightedText)
		color: Theme.primaryColor
		font.pixelSize: Theme.fontSizeSmall
		verticalAlignment: Text.AlignVCenter

		function formatText(text, highlightText) {
			if (text === undefined) {
				return ''
			}

			if (text.indexOf('<') >= 0) {
				text = text.replace('<', '&lt;')
			}

			if (highlightText) {
				return Theme.highlightText(text, highlightText, Theme.highlightColor)
			}
			return text
		}
	}

	Timer {
		id: searchTimer

		property int lastPos: 0
		property int foundPos: -1
		property int loopCount: 1

		interval: 100
		repeat: true

		function startSearch(reset) {
			restart();
			if (reset) {
				lastPos = 0
			} else {
				lastPos = Math.max(foundPos, 0)
			}

			loopCount = Math.abs(Math.min(root.model.count / 20, 20))
//			console.log("text to search: '" + root.highlightedText + "'; "  + reset)
			root.state = 'search'
			foundPos = -1
		}

		onTriggered: {

			var endPos = Math.min(root.model.count, lastPos + loopCount + 1);
			for (var i = lastPos; i < endPos; i++) {
				if (disabled) {
					stop()
					return
				}
				var text = root.model.get(i).text
//				console.log("text(" + i + "):" + text)
				if (text.length < 51 && text.toLowerCase().indexOf(root.highlightedText) !== -1) {
					stop()
					root.text = text
					root.state = 'found'
					foundPos = i
					return
				}
			}
			lastPos = endPos
			if (endPos === root.model.count) {
				foundPos = -1
				root.state = 'no_match'
				stop()
			}
		}
	}

	onDisabledChanged: {
		if (disabled) {
			root.state = 'disabled'
		} else {
			root.state = 'finalize'
		}
	}

	states: [
		State {
			name: 'disabled'
			PropertyChanges {target: root; visible: false; restoreEntryValues: false}
		},
		State {
			name: 'no_minimal'
			PropertyChanges {target: root; visible: false; restoreEntryValues: false}
		},
		State {
			name: 'search'
		},
		State {
			name: 'no_match'
			PropertyChanges {target: root; visible: false; restoreEntryValues: false}
		},
		State {
			name: 'found'
			PropertyChanges {target: root; visible: true; restoreEntryValues: false}
		},
		State {
			name: 'finalize'
			PropertyChanges {target: root; visible: false; restoreEntryValues: false}
		}
	]

	onClicked: {
		textSelected(root.text)
	}
}
