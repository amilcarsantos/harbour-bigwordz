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

	property alias model: repeater.model
	property int itemWidth: width / 4
	property int itemHeigth: itemWidth
	property Item _menu

	signal favoriteSelected(string favoriteWord)
	signal contextMenuRequested
	signal removeFromFavorites(string favoriteWord)

	function moveX(pixels) {
		moveAnim.to = flickable.contentX + pixels;
		moveAnim.start();
	}

	function showContextMenu(word, menuParent) {
		if (_menu == null) {
			_menu = contextMenuComponent.createObject(root)
		}
		_menu.favoriteWord = word
		contextMenuRequested()
		_menu.show(flickable)
	//	_menu.show(menuParent)
	}

	width: screen.width
	height: root._menu !== null ? root.itemHeigth + root._menu.height : root.itemHeigth

	Component {
		id: contextMenuComponent
		ContextMenu {
			property string favoriteWord
			x: 0
			width: root.width
			MenuItem {
				text: qsTr("Remove from favorites")
				onClicked: {
//					console.log("favoriteWord: " + favoriteWord)
					removeFromFavorites(favoriteWord)
				}
			}
		}
	}

	Flickable {
		id: flickable

		anchors.fill: parent
		contentWidth: itemWidth * repeater.model.count;
		contentHeight: itemHeigth
		interactive: repeater.model.count > 4
		flickableDirection: Flickable.HorizontalFlick

		onMovementEnded: {
//			console.log("onMovementEnded " + flickable.contentX + "; veol_ " + flickable.horizontalVelocity)
			var itemIndex = Math.floor(flickable.contentX / itemWidth)
			var itemOffset = flickable.contentX - itemIndex * itemWidth
			if (itemOffset >= 1) {
				var dist = -itemOffset
				if (itemOffset > itemWidth / 2) {
					dist = itemWidth - itemOffset
				}
//				console.log("itemOffset " + itemOffset + "; dist: " + dist)
				moveX(dist)
			}
		}

		Row {
			x: 0
			spacing: 0
			Repeater {
				id: repeater
				property Item _ignoreDimmed
				delegate: BackgroundItem {
					width: root.itemWidth
					height: root.itemHeigth
					clip: true

					onPressAndHold: {
						if (down) {
							showContextMenu(model.text)
							repeater._ignoreDimmed = dimmed
						}
					}
					onClicked: {
//						console.log("item: " + model.text + "; line count: " + txt.lineCount)
						favoriteSelected(model.text)
					}

					Image {
						id: favoriteImage
						anchors.fill: parent
						fillMode: Image.Stretch
						source: "image://theme/graphic-avatar-text-back"
					}
					Label {
						id: txt
						anchors.fill: parent
						anchors.leftMargin: 4
						anchors.rightMargin: 4
						text: model.text
						truncationMode: TruncationMode.Fade
						wrapMode: Text.WordWrap
						elide: Text.ElideRight
						font.pixelSize: model.text.length > 20 ? Theme.fontSizeSmall : Theme.fontSizeMedium
						horizontalAlignment: Text.AlignHCenter
						verticalAlignment: Text.AlignVCenter
					}
					Rectangle {
						id: dimmed
						anchors.fill: parent
						Behavior on opacity { FadeAnimation {} }
						color: Theme.highlightDimmerColor
						opacity: root._menu !== null && root._menu.active && repeater._ignoreDimmed !== dimmed ? 0.5 : 0
					}
				}
			}
		}
	}

	NumberAnimation {
		id: moveAnim
		target: flickable
		property: "contentX"
		duration: 400
		easing.type: Easing.OutCubic
	}
}

