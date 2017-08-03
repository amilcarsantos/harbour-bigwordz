/*
  Copyright (C) 2017 Amilcar Santos
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

	property alias label: comboBox.label
	property alias menu: comboBox.menu
	property alias currentIndex: comboBox.currentIndex
	property real labelMargin: Theme.paddingLarge

	width: parent ? parent.width : 0
	height: comboBox.height

	ComboBox {
		id: comboBox
		anchors {
			left: parent.left
			right: parent.right
			verticalCenter: parent.verticalCenter
		}
		contentHeight: visible ? Math.max(column.height + 2*Theme.paddingMedium, Theme.itemSizeSmall) : 0
		enabled: root.enabled

		Column {
			id: column

			anchors {
				left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter
				leftMargin: root.labelMargin; rightMargin: Theme.paddingLarge

			}
			Flow {
				id: flow

				width: parent.width
				move: Transition { NumberAnimation { properties: "x,y"; easing.type: Easing.InOutQuad; duration: root._duration } }

				Label {
					id: titleText
					color: comboBox.down ? Theme.highlightColor : Theme.primaryColor
					width: Math.min(implicitWidth + Theme.paddingMedium, parent.width)
					height: Theme.iconSizeMedium
					verticalAlignment: Text.AlignVCenter
					truncationMode: TruncationMode.Fade
				}

				Image {
					id: img
					fillMode: Image.Pad
					height: Theme.iconSizeMedium
				}
			}
		}

		onCurrentItemChanged: {
			if (currentItem && currentItem.hasOwnProperty("__bigworz_iconmenuitem")) {
				img.source = 'image://theme/' + currentItem.source + '?' + Theme.highlightColor;
				img.rotation = currentItem.rotation;
				root.currentIndex = currentIndex;
			}
		}
	}

    Component.onCompleted: {
		// hack: hide normal combo box
		comboBox.labelColor = 'transparent'
		comboBox.valueColor = 'transparent'

		titleText.text = comboBox.label
    }
}
