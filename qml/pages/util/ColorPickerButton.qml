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

	property alias text: label.text
	property alias color: colorIndicator.color

	height: Theme.itemSizeSmall
	Row {
		anchors.left: parent.left
		height: parent.height
		spacing: Theme.paddingMedium
		Rectangle {
			id: colorIndicator
			width: Theme.itemSizeSmall
			height: parent.height
			color: "#e60003"
			opacity: root.enabled ? 1.0 : 0.4
		}
		Label {
			id: label
			color: colorState()
			anchors.verticalCenter: parent.verticalCenter

			function colorState() {
				if (root.enabled) {
					return root.down ? Theme.highlightColor : Theme.primaryColor
				}
				return Theme.secondaryColor
			}
		}
	}
	onClicked: {
		var dialog = pageStack.push("Sailfish.Silica.ColorPickerDialog")
		var moreColors = dialog.colors
		moreColors.push("#000000")
		moreColors.push("#C0C0C0")
		moreColors.push("#FFFFFF")
		dialog.colors = moreColors

		dialog.accepted.connect(function() {
			colorIndicator.color = dialog.color
		})
	}
}
