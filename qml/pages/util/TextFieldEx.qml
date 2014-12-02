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

Item {
	id: root

	property string text: ''
	property int maxLength: 255
	property alias editFocus: _inputField.focus

	height: _inputField.height

	function forceEditFocus() {
//		console.log("setInputFocus")
		if (!_inputField.focus) {
			_inputField.forceActiveFocus()
		}
	}

	onTextChanged: {
		_inputField.text = text
	}

	TextField {
		id: _inputField
		anchors.left: parent.left
		width:  parent.width - Theme.iconSizeSmall - Theme.paddingSmall
//		anchors.right: clearButton.left

		onTextChanged: {
//			console.log("TextField text change: " + text)
			if (text.length > maxLength) {
				root.text = text.substring(0, maxLength)
				color = 'red'
			} else {
				root.text = text
				color = Theme.primaryColor
			}
		}
		EnterKey.iconSource: "image://theme/icon-m-enter-close"
		EnterKey.onClicked: focus = false
	}

	IconButton {
		id: _clearButton
		anchors.right: parent.right
		anchors.top: parent.top
//		width: Theme.iconSizeSmall

		icon.source: "image://theme/icon-m-clear"
		enabled: _inputField.text

		onClicked: {
			_inputField.focusOutBehavior = FocusBehavior.KeepFocus
			_inputField.text = ""
			if (!_inputField.focus) {
				_inputField.forceActiveFocus()
			}
			_inputField.focusOutBehavior = FocusBehavior.ClearItemFocus
		}
	}
}
