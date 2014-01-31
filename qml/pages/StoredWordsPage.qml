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


Page {
	id: storedWordsPage

	allowedOrientations: Orientation.All

	property string searchString: ""

	signal textChanged

	onSearchStringChanged: {
		listModel.update()
	}

	Component.onCompleted: {
		listModel.update()
	}

	Column {
		id: headerContainer
		width: storedWordsPage.width

		PageHeader {
			title: qsTr("Stored Words")
		}

		SearchField {
			id: searchField
			width: parent.width

			Binding {
				target: storedWordsPage
				property: "searchString"
				value: searchField.text.toLowerCase().trim()
			}

			Keys.onReturnPressed: storedWordsPage.focus = true
			Keys.onEnterPressed: storedWordsPage.focus = true
		}
	}

	SilicaListView {
		id: listView
		model: listModel
		anchors.fill: parent
		header: Item {
			id: header
			width: headerContainer.width
			height: headerContainer.height
			Component.onCompleted: headerContainer.parent = header
		}

		PullDownMenu {
			MenuItem {
				function restoreControls() {
					listView.enabled = true
				}
				enabled: storedWordsModel.count > 0
				text: qsTr("Delete All")
				onClicked: {
					// 1st) block user iteraction with listview
					listView.enabled = false;
					// start remorse action
					remorsePopup.execute(qsTr("Deleting all stored words"), function() {
						while (listModel.count > 0) {
							listModel.remove(listModel.count - 1)
						}
						storedWordsModel.removeAll()
						restoreControls()
					})
					remorsePopup.canceled.connect(restoreControls)
				}
			}
		}

		delegate: ListItem {
			id: delegate
			menu: contextMenu

			ListView.onRemove: animateRemoval(delegate)

			Label {
				id: label
				x: searchField.textLeftMargin
				width: parent.width - x - Theme.paddingMedium
				anchors.verticalCenter: parent.verticalCenter
				color: searchString.length > 0 ? (highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)
												: (highlighted ? Theme.highlightColor : Theme.primaryColor)
				textFormat: Text.StyledText
				text: Theme.highlightText(model.text, searchString, Theme.highlightColor)
				//truncationMode: TruncationMode.Fade
				//elide: Text.ElideRight
			}
			OpacityRampEffect {
				sourceItem: label
				offset: 0.3
				slope: 1.4
			}
			function deleteWord() {
				remorseAction(qsTr("Deleting"), function() {
					storedWordsModel.removeStoredWord(model.text)
					listModel.remove(index)
				})
			}

			onClicked: {
				window.currentText = model.text
				storedWordsModel.storeCurrentText()
				textChanged()
				pageStack.pop()
			}

			Component {
				id: contextMenu
				ContextMenu {
					MenuItem {
						text: qsTr("Delete")
						onClicked: deleteWord()
					}
				}
			}
		}
		VerticalScrollDecorator {}
	}

	RemorsePopup {
		id: remorsePopup
	}

	ListModel {
		id: listModel

		function update() {
			var words = window.storedWords()

			var filteredWords = words.filter(function (word) {
				return word.toLowerCase().indexOf(searchString) !== -1
			})
			while (count > filteredWords.length) {
			remove(filteredWords.length)
			}
			for (var index = 0; index < filteredWords.length; index++) {
				if (index < count) {
					setProperty(index, "text", filteredWords[index])
				} else {
					append({ "text": filteredWords[index]})
				}
			}
		}
	}
}





